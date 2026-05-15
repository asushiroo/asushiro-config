Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\windows\Common.ps1')

$requiredPackages = @(
    @{ Id = 'sxyazi.yazi'; Commands = @('yazi', 'ya'); Name = 'Yazi' },
    @{ Id = 'Gyan.FFmpeg'; Commands = @('ffmpeg'); Name = 'FFmpeg' },
    @{ Id = 'jqlang.jq'; Commands = @('jq'); Name = 'jq' }
)

foreach ($package in $requiredPackages) {
    Install-WingetPackageIfMissing -Id $package.Id -Commands $package.Commands -Name $package.Name
}

$optionalPackages = @(
    @{ Id = '7zip.7zip'; Commands = @('7z'); Name = '7-Zip' },
    @{ Id = 'oschwartz10612.Poppler'; Commands = @('pdftoppm'); Name = 'Poppler' }
)

foreach ($package in $optionalPackages) {
    try {
        Install-WingetPackageIfMissing -Id $package.Id -Commands $package.Commands -Name $package.Name
    }
    catch {
        Write-WarnLog "$($package.Name) install skipped: $($_.Exception.Message)"
    }
}

$gitCommand = Get-Command git -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -ne $gitCommand) {
    $gitRoot = Resolve-Path (Join-Path (Split-Path -Parent $gitCommand.Source) '..') | Select-Object -ExpandProperty Path
    $fileExe = Join-Path $gitRoot 'usr\bin\file.exe'
    $caBundle = Join-Path $gitRoot 'mingw64\etc\ssl\certs\ca-bundle.crt'
    if (Test-Path -LiteralPath $fileExe) {
        [Environment]::SetEnvironmentVariable('YAZI_FILE_ONE', $fileExe, 'User')
        $env:YAZI_FILE_ONE = $fileExe
        Write-Info "Configured YAZI_FILE_ONE=$fileExe"
    }
    else {
        Write-WarnLog 'Git was found, but file.exe was not found under its usr\bin directory.'
    }
}
else {
    Write-WarnLog 'Git was not found. Yazi MIME detection on Windows depends on Git for Windows file.exe.'
}

$yaBinary = Ensure-BinaryAvailable -ExeName 'ya.exe'
if ($null -eq $yaBinary) {
    $yaBinary = Ensure-BinaryAvailable -ExeName 'ya'
}

if ($null -ne $yaBinary) {
    Write-Info 'Installing Yazi plugin: dedukun/relative-motions'
    if ($gitCommand -and (Test-Path -LiteralPath $caBundle)) {
        $env:GIT_SSL_CAINFO = $caBundle
    }
    & $yaBinary pkg add dedukun/relative-motions
    if ($LASTEXITCODE -ne 0) {
        Write-WarnLog 'Failed to install Yazi plugin dedukun/relative-motions'
    }
}
else {
    Write-WarnLog "Skipping Yazi plugin install because 'ya' is unavailable in the current session"
}

if (-not (Get-CommandPath -Name 'resvg')) {
    Write-WarnLog 'resvg is not installed. Yazi SVG previews may be limited.'
}

Write-Info "Yazi is ready: $((& yazi --version))"
