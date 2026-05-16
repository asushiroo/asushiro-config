Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\windows\Common.ps1')

$requiredPackages = @(
    @{ Id = 'Neovim.Neovim'; Commands = @('nvim'); Name = 'Neovim' },
    @{ Id = 'BurntSushi.ripgrep.MSVC'; Commands = @('rg'); Name = 'ripgrep' },
    @{ Id = 'sharkdp.fd'; Commands = @('fd'); Name = 'fd' },
    @{ Id = 'junegunn.fzf'; Commands = @('fzf'); Name = 'fzf' },
    @{ Id = 'ajeetdsouza.zoxide'; Commands = @('zoxide'); Name = 'zoxide' },
    @{ Id = 'OpenJS.NodeJS.LTS'; Commands = @('node', 'npm'); Name = 'Node.js LTS' }
)

foreach ($package in $requiredPackages) {
    Install-WingetPackageIfMissing -Id $package.Id -Commands $package.Commands -Name $package.Name
}

$optionalPackages = @(
    @{ Id = 'Kitware.CMake'; Commands = @('cmake'); Name = 'CMake' },
    @{ Id = 'ImageMagick.ImageMagick'; Commands = @('magick'); Name = 'ImageMagick' }
)

foreach ($package in $optionalPackages) {
    try {
        Install-WingetPackageIfMissing -Id $package.Id -Commands $package.Commands -Name $package.Name
    }
    catch {
        Write-WarnLog "$($package.Name) install skipped: $($_.Exception.Message)"
    }
}

$repoRoot = Resolve-RepoRoot -ScriptRoot $PSScriptRoot
$mdmathJsDir = Join-Path $repoRoot 'nvim\vendor\mdmath.nvim\mdmath-js'
if (Test-Path -LiteralPath (Join-Path $mdmathJsDir 'package.json')) {
    Write-Info 'Installing mdmath.js dependencies...'
    Push-Location $mdmathJsDir
    try {
        & npm install --no-fund --no-audit
        if ($LASTEXITCODE -ne 0) {
            throw 'npm install failed for mdmath.js'
        }
    }
    finally {
        Pop-Location
    }
}

if (-not (Get-CommandPath -Name 'rsvg-convert')) {
    Write-WarnLog 'rsvg-convert is not installed on this Windows machine. Markdown SVG/LaTeX rendering fallback may be limited.'
}

Write-Info "Neovim is ready: $((& nvim --version | Select-Object -First 1))"
