Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\windows\Common.ps1')

Install-WingetPackageIfMissing -Id 'Starship.Starship' -Commands @('starship') -Name 'Starship'
Write-Info "Starship is ready: $((& starship --version))"
