Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\windows\Common.ps1')

$repoRoot = Resolve-RepoRoot -ScriptRoot $PSScriptRoot
$source = Join-Path $repoRoot 'nvim'
$target = Join-Path $env:LOCALAPPDATA 'nvim'

if (-not (Test-Path -LiteralPath $source)) {
    throw "Source directory not found: $source"
}

New-SafeSymbolicLink -Target $source -Path $target -Directory
