param([Parameter(Mandatory=$true,Position=0)][string]$ArchivePath)
$ErrorActionPreference = 'Stop'
try {
    $archive = Get-Item -LiteralPath $ArchivePath -ErrorAction Stop
    if ($archive.PSIsContainer -or $archive.Extension.ToLowerInvariant() -notin @('.7z','.zip','.rar')) { throw 'Select a .7z, .zip, or .rar archive.' }
    $xdvdfs = Join-Path $env:LOCALAPPDATA 'XboxISO\xdvdfs.exe'
    if (-not (Test-Path -LiteralPath $xdvdfs -PathType Leaf)) { throw "xdvdfs.exe not found at $xdvdfs" }
    $sevenZip = @((Join-Path $env:ProgramFiles '7-Zip\7z.exe'))
    if (${env:ProgramFiles(x86)}) { $sevenZip += (Join-Path ${env:ProgramFiles(x86)} '7-Zip\7z.exe') }
    $sevenZip = @($sevenZip | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1)
    if ($sevenZip.Count -eq 0) {
        $cmd = Get-Command '7z.exe' -ErrorAction SilentlyContinue
        if (-not $cmd) { throw '7z.exe not found. Install 7-Zip.' }
        $sevenZip = @($cmd.Source)
    }
    $output = Join-Path $archive.DirectoryName ($archive.BaseName + '.iso')
    if (Test-Path -LiteralPath $output) { throw "Output already exists: $output" }
    $temp = Join-Path $archive.DirectoryName ('.XboxISO-' + [guid]::NewGuid().ToString('N'))
    $pending = Join-Path $archive.DirectoryName ('.XboxISO-' + [guid]::NewGuid().ToString('N') + '.iso')
    try {
        New-Item -ItemType Directory -Path $temp -ErrorAction Stop | Out-Null
        Write-Host "Extracting $($archive.Name)..." -ForegroundColor Cyan
        & $sevenZip[0] x '-y' "-o$temp" $archive.FullName
        if ($LASTEXITCODE -ne 0) { throw "7-Zip exited with code $LASTEXITCODE (1 indicates warnings). Review archive integrity." }
        $gameRoot = $temp
        while (-not (Test-Path -LiteralPath (Join-Path $gameRoot 'default.xbe') -PathType Leaf)) {
            $entries = @(Get-ChildItem -LiteralPath $gameRoot -Force)
            if ($entries.Count -ne 1 -or -not $entries[0].PSIsContainer) { throw 'No unambiguous game folder with default.xbe at its root.' }
            $gameRoot = $entries[0].FullName
        }
        Write-Host 'Packing Xbox ISO...' -ForegroundColor Cyan
        & $xdvdfs pack $gameRoot $pending
        if ($LASTEXITCODE -ne 0) { throw "xDVDFS pack failed with exit code $LASTEXITCODE" }
        if (-not (Test-Path -LiteralPath $pending -PathType Leaf) -or (Get-Item -LiteralPath $pending).Length -eq 0) { throw 'Packed ISO was missing or empty.' }
        $listing = & $xdvdfs ls $pending 2>&1
        if ($LASTEXITCODE -ne 0 -or -not (($listing | Out-String) -match '(?i)default\.xbe')) { throw 'Failed to verify default.xbe in ISO listing.' }
        if (Test-Path -LiteralPath $output) { throw "Output appeared during processing: $output" }
        Rename-Item -LiteralPath $pending -NewName ($archive.BaseName + '.iso') -ErrorAction Stop
        Write-Host "SUCCESS: $output" -ForegroundColor Green
        Write-Host 'Original archive preserved.'
    }
    finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path -LiteralPath $pending) { Remove-Item -LiteralPath $pending -Force -ErrorAction SilentlyContinue }
    }
}
catch { Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red; exit 1 }
