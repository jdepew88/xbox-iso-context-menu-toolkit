$ErrorActionPreference = 'Stop'
foreach ($ext in @('.7z','.zip','.rar')) {
    $key = "HKCU:\Software\Classes\SystemFileAssociations\$ext\shell\XboxISO"
    if (Test-Path -LiteralPath $key) { Remove-Item -LiteralPath $key -Recurse -Force; Write-Host "Removed $ext menu" }
}
Write-Host 'Application files and game files preserved.'
