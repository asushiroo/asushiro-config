Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('info', 'warn', 'error')]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[$Level] $Message"
}

function Write-Info {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Level info -Message $Message
}

function Write-WarnLog {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Level warn -Message $Message
}

function Write-ErrorLog {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Level error -Message $Message
}

function Resolve-RepoRoot {
    param([Parameter(Mandatory = $true)][string]$ScriptRoot)
    (Resolve-Path (Join-Path $ScriptRoot '..\..')).Path
}

function Get-CommandPath {
    param([Parameter(Mandatory = $true)][string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $command) {
        return $command.Source
    }

    return $null
}

function Refresh-ProcessPathFromRegistry {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')

    $entries = @()
    foreach ($segment in @($env:Path, $machinePath, $userPath)) {
        if ([string]::IsNullOrWhiteSpace($segment)) {
            continue
        }

        foreach ($entry in ($segment -split ';')) {
            if ([string]::IsNullOrWhiteSpace($entry)) {
                continue
            }

            if ($entries -notcontains $entry) {
                $entries += $entry
            }
        }
    }

    $env:Path = ($entries -join ';')
}

function Add-DirectoryToProcessPath {
    param([Parameter(Mandatory = $true)][string]$Directory)

    if (-not (Test-Path -LiteralPath $Directory)) {
        return
    }

    $pathEntries = @($env:Path -split ';' | Where-Object { $_ -ne '' })
    if ($pathEntries -contains $Directory) {
        return
    }

    $env:Path = "$Directory;$env:Path"
}

function Find-BinaryPath {
    param([Parameter(Mandatory = $true)][string]$ExeName)

    $existing = Get-CommandPath -Name $ExeName
    if ($null -ne $existing) {
        return $existing
    }

    $searchRoots = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'),
        (Join-Path $env:LOCALAPPDATA 'Programs'),
        ${env:ProgramFiles},
        ${env:ProgramFiles(x86)}
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

    foreach ($root in $searchRoots) {
        $match = Get-ChildItem -Path $root -Recurse -Filter $ExeName -File -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName
        if ($null -ne $match) {
            return $match
        }
    }

    return $null
}

function Ensure-BinaryAvailable {
    param([Parameter(Mandatory = $true)][string]$ExeName)

    $binary = Find-BinaryPath -ExeName $ExeName
    if ($null -eq $binary) {
        return $null
    }

    Add-DirectoryToProcessPath -Directory (Split-Path -Parent $binary)
    return $binary
}

function Test-CommandAvailable {
    param([Parameter(Mandatory = $true)][string]$Name)
    $null -ne (Get-CommandPath -Name $Name)
}

function Invoke-WingetInstall {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [string]$Name = $Id
    )

    Write-Info "Installing $Name via winget..."
    & winget install --id $Id --exact --source winget --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
    if ($LASTEXITCODE -ne 0) {
        throw "winget install failed for $Id"
    }

    Refresh-ProcessPathFromRegistry
}

function Test-WingetPackageInstalled {
    param([Parameter(Mandatory = $true)][string]$Id)

    & winget list --id $Id --exact --accept-source-agreements | Out-Null
    return $LASTEXITCODE -eq 0
}

function Install-WingetPackageIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [string[]]$Commands,

        [string]$Name = $Id
    )

    foreach ($command in $Commands) {
        if (Test-CommandAvailable -Name $command) {
            Write-Info "$Name is already available via '$command'"
            return
        }
    }

    Refresh-ProcessPathFromRegistry
    foreach ($command in $Commands) {
        $binary = Ensure-BinaryAvailable -ExeName "$command.exe"
        if ($null -ne $binary) {
            Write-Info "$Name is already available: $binary"
            return
        }

        $binary = Ensure-BinaryAvailable -ExeName $command
        if ($null -ne $binary) {
            Write-Info "$Name is already available: $binary"
            return
        }
    }

    if (Test-WingetPackageInstalled -Id $Id) {
        Write-WarnLog "$Name is already installed according to winget, but the command is not on PATH yet"
        Refresh-ProcessPathFromRegistry
    }
    else {
        Invoke-WingetInstall -Id $Id -Name $Name
    }

    foreach ($command in $Commands) {
        $binary = Ensure-BinaryAvailable -ExeName "$command.exe"
        if ($null -ne $binary) {
            Write-Info "$Name is ready: $binary"
            return
        }

        $binary = Ensure-BinaryAvailable -ExeName $command
        if ($null -ne $binary) {
            Write-Info "$Name is ready: $binary"
            return
        }
    }

    throw "$Name installation finished, but none of these commands are available: $($Commands -join ', ')"
}

function Backup-FileIfDifferent {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Destination)) {
        return
    }

    $sourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
    $destinationHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
    if ($sourceHash -eq $destinationHash) {
        return
    }

    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backupPath = "$Destination.$timestamp.bak"
    Copy-Item -LiteralPath $Destination -Destination $backupPath -Force
    Write-WarnLog "Backed up existing file to $backupPath"
}

function Move-ExistingPathToBackup {
    param([Parameter(Mandatory = $true)][string]$Path)

    $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -eq $existing) {
        return
    }

    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backupPath = "$Path.$timestamp.bak"
    Move-Item -LiteralPath $Path -Destination $backupPath -Force
    Write-WarnLog "Moved existing path to $backupPath"
}

function New-SafeSymbolicLink {
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Path,
        [switch]$Directory
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        $isReparsePoint = (($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
        if ($isReparsePoint) {
            if ($existing.PSIsContainer) {
                cmd /c rmdir "$Path" 2>$null | Out-Null
            }
            else {
                Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
            }

            if (Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue) {
                Remove-Item -LiteralPath $Path -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        else {
            Move-ExistingPathToBackup -Path $Path
        }
    }

    New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
    Write-Info "Linked $Path -> $Target"
}
