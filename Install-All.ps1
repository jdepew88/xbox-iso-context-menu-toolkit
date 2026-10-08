$ErrorActionPreference = 'Stop'
$source = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($folder in @('XboxISO','Xbox360ISOExtractor')) {
    $dest = Join-Path $env:LOCALAPPDATA $folder
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Get-ChildItem -LiteralPath (Join-Path $source $folder) -Filter '*.ps1' | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $dest -Force }
}
$xdvdfs = Join-Path $env:LOCALAPPDATA 'XboxISO\xdvdfs.exe'
if (-not (Test-Path -LiteralPath $xdvdfs)) { Write-Warning 'Install upstream xdvdfs.exe (v0.8.2+) into %LOCALAPPDATA%\XboxISO before converting games.' }
& (Join-Path $env:LOCALAPPDATA 'XboxISO\Install-ContextMenu.ps1')
& (Join-Path $env:LOCALAPPDATA 'Xbox360ISOExtractor\Install-ContextMenu.ps1')
Write-Host 'Both Windows context menus registered.' -ForegroundColor Green
