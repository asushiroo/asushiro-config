Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\windows\Common.ps1')

$repoRoot = Resolve-RepoRoot -ScriptRoot $PSScriptRoot
$source = Join-Path $repoRoot 'starship.toml'
$target = Join-Path $HOME '.config\starship.toml'

if (-not (Test-Path -LiteralPath $source)) {
    throw "Source file not found: $source"
}

New-SafeSymbolicLink -Target $source -Path $target
