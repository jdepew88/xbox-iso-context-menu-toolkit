$ErrorActionPreference = 'Stop'
$key = 'HKCU:\Software\Classes\SystemFileAssociations\.iso\shell\Xbox360ISOExtractor'
if (Test-Path -LiteralPath $key) {
    Remove-Item -LiteralPath $key -Recurse -Force
    Write-Host 'Removed: Extract Xbox 360 ISO (xDVDFS)' -ForegroundColor Green
} else {
    Write-Host 'Xbox 360 ISO context menu is not installed.' -ForegroundColor Yellow
}
Write-Host 'Application scripts, xDVDFS, original ISOs and extracted games were not deleted.'
