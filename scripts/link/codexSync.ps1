Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\windows\Common.ps1')

$repoRoot = Resolve-RepoRoot -ScriptRoot $PSScriptRoot
$sourceRoot = Join-Path $repoRoot '.codex'
$targetRoot = Join-Path $HOME '.codex'

if (-not (Test-Path -LiteralPath $sourceRoot)) {
    throw "Source directory not found: $sourceRoot"
}

New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

$files = Get-ChildItem -Path $sourceRoot -Recurse -File
foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($sourceRoot.Length).TrimStart('\')
    $destination = Join-Path $targetRoot $relativePath
    $parent = Split-Path -Parent $destination
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Backup-FileIfDifferent -Source $file.FullName -Destination $destination
    Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
    Write-Info "Synced $relativePath into $targetRoot"
}
