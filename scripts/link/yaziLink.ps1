Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\windows\Common.ps1')

$repoRoot = Resolve-RepoRoot -ScriptRoot $PSScriptRoot
$source = Join-Path $repoRoot 'yazi'
$target = Join-Path $env:APPDATA 'yazi\config'

if (-not (Test-Path -LiteralPath $source)) {
    throw "Source directory not found: $source"
}

New-SafeSymbolicLink -Target $source -Path $target -Directory
