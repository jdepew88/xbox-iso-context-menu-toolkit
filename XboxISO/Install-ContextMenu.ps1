$ErrorActionPreference = 'Stop'
$converter = Join-Path $env:LOCALAPPDATA 'XboxISO\Convert-XboxISO.ps1'
if (-not (Test-Path -LiteralPath $converter -PathType Leaf)) { throw "Missing converter: $converter" }
$ps = Join-Path $PSHOME 'powershell.exe'
foreach ($ext in @('.7z','.zip','.rar')) {
    $key = "HKCU:\Software\Classes\SystemFileAssociations\$ext\shell\XboxISO"
    New-Item -Path "$key\command" -Force | Out-Null
    Set-Item -Path $key -Value 'Create Xbox ISO (xDVDFS)'
    $command = '"{0}" -NoProfile -ExecutionPolicy Bypass -NoExit -File "{1}" "%1"' -f $ps,$converter
    Set-Item -Path "$key\command" -Value $command
    Write-Host "Installed menu for $ext"
}
