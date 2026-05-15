Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'scripts\windows\Common.ps1')

function Ensure-PowerShellProfile {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $profileScript = Join-Path $RepoRoot 'shell\profile.ps1'
    $sourceLine = ". `"$profileScript`""

    $profilePath = $PROFILE.CurrentUserCurrentHost
    if ([string]::IsNullOrWhiteSpace($profilePath)) {
        $profilePath = Join-Path $HOME 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
    }

    $parent = Split-Path -Parent $profilePath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $content = Get-Content -LiteralPath $profilePath -Raw
    if ($null -eq $content) {
        $content = ''
    }
    if ($content -notmatch [Regex]::Escape($profileScript)) {
        Add-Content -LiteralPath $profilePath -Value "`r`n# dotfiles PowerShell init`r`n$sourceLine`r`n"
        Write-Info "Added PowerShell init to $profilePath"
    }
    else {
        Write-Info "PowerShell init already present in $profilePath"
    }
}

$repoRoot = $PSScriptRoot

Write-Info 'Running Windows install scripts...'
& (Join-Path $repoRoot 'scripts\installAll.ps1')

Write-Info 'Ensuring PowerShell profile is configured...'
Ensure-PowerShellProfile -RepoRoot $repoRoot

Write-Info 'Running Windows link scripts...'
& (Join-Path $repoRoot 'scripts\linkAll.ps1')

Write-Info 'Windows setup completed.'
