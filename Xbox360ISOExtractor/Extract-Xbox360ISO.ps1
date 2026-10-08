param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$IsoPath
)

$ErrorActionPreference = 'Stop'

try {
    $iso = Get-Item -LiteralPath $IsoPath -ErrorAction Stop
    if ($iso.PSIsContainer -or $iso.Extension -ine '.iso') {
        throw 'Please select an .iso file.'
    }

    $xdvdfs = Join-Path $env:LOCALAPPDATA 'XboxISO\xdvdfs.exe'
    if (-not (Test-Path -LiteralPath $xdvdfs -PathType Leaf)) {
        throw "xDVDFS not found at: $xdvdfs. Install xDVDFS v0.8.2 or newer in the existing XboxISO folder."
    }

    $outputDir = Join-Path $iso.DirectoryName $iso.BaseName
    if (Test-Path -LiteralPath $outputDir) {
        throw "Destination already exists; nothing was overwritten: $outputDir"
    }

    # Stage beside the ISO so a successful rename stays on the same drive.
    $stagingDir = Join-Path $iso.DirectoryName ('.Xbox360ISO-' + [guid]::NewGuid().ToString('N'))
    $completed = $false
    try {
        New-Item -ItemType Directory -Path $stagingDir -ErrorAction Stop | Out-Null
        Write-Host "Extracting: $($iso.Name)" -ForegroundColor Cyan
        Write-Host "Using: $xdvdfs"
        & $xdvdfs unpack $iso.FullName $stagingDir
        if ($LASTEXITCODE -ne 0) {
            throw "xDVDFS extraction failed with exit code $LASTEXITCODE. Check that the ISO is supported and that xDVDFS is v0.8.2 or newer."
        }

        $xbe = Join-Path $stagingDir 'default.xex'
        if (-not (Test-Path -LiteralPath $xbe -PathType Leaf)) {
            throw 'Extraction finished but default.xex was not found at the extracted game root. This may not be an executable Xbox 360 game disc, or extraction may be incomplete.'
        }
        if ((Get-Item -LiteralPath $xbe).Length -eq 0) {
            throw 'Extracted default.xex is empty.'
        }

        if (Test-Path -LiteralPath $outputDir) {
            throw "Destination appeared during extraction; nothing was overwritten: $outputDir"
        }
        Rename-Item -LiteralPath $stagingDir -NewName $iso.BaseName -ErrorAction Stop
        $completed = $true
        Write-Host "SUCCESS: $outputDir" -ForegroundColor Green
        Write-Host "Launch in Xenia using: $(Join-Path $outputDir 'default.xex')" -ForegroundColor Green
        Write-Host 'The original ISO was not modified.'
    }
    finally {
        if (-not $completed -and (Test-Path -LiteralPath $stagingDir)) {
            Write-Host "Cleaning up incomplete extraction: $stagingDir" -ForegroundColor Yellow
            Remove-Item -LiteralPath $stagingDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
