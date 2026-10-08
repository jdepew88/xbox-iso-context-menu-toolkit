$ErrorActionPreference = 'Stop'

$extractor = Join-Path $env:LOCALAPPDATA 'Xbox360ISOExtractor\Extract-Xbox360ISO.ps1'
if (-not (Test-Path -LiteralPath $extractor -PathType Leaf)) {
    throw "Extractor script not found: $extractor"
}

$key = 'HKCU:\Software\Classes\SystemFileAssociations\.iso\shell\Xbox360ISOExtractor'
$commandKey = Join-Path $key 'command'
New-Item -Path $commandKey -Force | Out-Null
Set-Item -Path $key -Value 'Extract Xbox 360 ISO (xDVDFS)'
# Use the Windows PowerShell executable and quote both paths for spaces.
$ps = Join-Path $PSHOME 'powershell.exe'
$command = '"{0}" -NoProfile -ExecutionPolicy Bypass -NoExit -File "{1}" "%1"' -f $ps, $extractor
Set-Item -Path $commandKey -Value $command
Write-Host 'Installed: Extract Xbox 360 ISO (xDVDFS)' -ForegroundColor Green
Write-Host 'Right-click an .iso file; on Windows 11 choose Show more options.'
