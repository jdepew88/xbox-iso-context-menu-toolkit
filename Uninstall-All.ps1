$ErrorActionPreference = 'Stop'
foreach ($path in @('XboxISO\Uninstall-ContextMenu.ps1','Xbox360ISOExtractor\Uninstall-ContextMenu.ps1')) {
    $script = Join-Path $env:LOCALAPPDATA $path
    if (Test-Path -LiteralPath $script) { & $script } else { Write-Warning "Not installed: $script" }
}
Write-Host 'Right-click entries removed; tool files and games preserved.'
