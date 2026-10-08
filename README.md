# Xbox ISO Toolkit

**Two Windows Explorer right-click workflows for original Xbox and Xbox 360 game files, powered by [xDVDFS](https://github.com/antangelo/xdvdfs).**

This is a community-created **PowerShell wrapper**, not a fork of xDVDFS and not affiliated with Microsoft, Xbox, or the xDVDFS maintainers.

## What it does

| Console | Input | Context menu | Output | Intended use |
| --- | --- | --- | --- | --- |
| Original Xbox | `.7z`, `.zip`, `.rar` archive containing an extracted game folder with `default.xbe` | **Create Xbox ISO (xDVDFS)** | `.iso` alongside archive | Build XISO-format images from extracted original Xbox game files |
| Xbox 360 | Supported `.iso` disc image | **Extract Xbox 360 ISO (xDVDFS)** | Folder alongside ISO containing `default.xex` | Prepare supported Xbox 360 extracted game files for use with software such as Xenia |

**Important:** These are two *different* workflows. The Xbox 360 extractor does **not** turn any arbitrary `.iso` into a playable Xbox 360 game. xDVDFS must recognize the image, and having `default.xex` does not guarantee emulator compatibility.

## Download

Download the repository ZIP using **Code → Download ZIP**, or download the packaged ZIP from [GitHub Releases](../../releases) once a release has been published. The source ZIP does **not** bundle `xdvdfs.exe` or 7-Zip; obtain those from their official projects.

## System requirements

- Windows 10 or 11 (Windows PowerShell 5.1)
- [xDVDFS CLI for Windows](https://github.com/antangelo/xdvdfs/releases), **v0.8.2 or newer** for Xbox 360 XGD2/XGD3 support
- [7-Zip](https://www.7-zip.org/) for original Xbox archive conversion (`7z.exe`)
- Enough free space on the source disk for temporary extracted data and the resulting files
- Game backups you are legally permitted to use

xDVDFS added Xbox 360 image offsets in v0.8.2; see [upstream releases](https://github.com/antangelo/xdvdfs/releases). This toolkit does not bypass encryption, copy protection, or format incompatibilities.

## Quick installation

1. Download and extract this toolkit anywhere (for example, Downloads).
2. Download the **Windows CLI** `xdvdfs.exe` from [antangelo/xdvdfs releases](https://github.com/antangelo/xdvdfs/releases). Check the actual CLI binary name if the release ships in an archive.
3. Open a normal **Windows PowerShell** session in the extracted toolkit directory and run:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-All.ps1
   ```
4. Copy `xdvdfs.exe` into `%LOCALAPPDATA%\XboxISO\xdvdfs.exe` (create the folder if necessary; the installer creates it automatically).
5. Install [7-Zip](https://www.7-zip.org/) if you want archive → original Xbox ISO conversion.

`Install-All.ps1` copies the PowerShell scripts into your own **AppData\Local** directory and creates right-click entries for the current Windows account only. **No administrative rights required.** On Windows 11 the entries may appear under **Show more options**.

### Installed layout

```text
%LOCALAPPDATA%/
  XboxISO/
    xdvdfs.exe                   # Download separately from upstream
    Convert-XboxISO.ps1
    Install-ContextMenu.ps1
    Uninstall-ContextMenu.ps1
  Xbox360ISOExtractor/
    Extract-Xbox360ISO.ps1
    Install-ContextMenu.ps1
    Uninstall-ContextMenu.ps1
```

The Xbox 360 extractor reuses the **same** `xdvdfs.exe` in the `XboxISO` folder.

## Workflow 1: original Xbox archive → ISO

Right-click a `.7z`, `.zip`, or `.rar` file and choose **Create Xbox ISO (xDVDFS)**.

Example archive `Midnight Club 3 DUB Edition [!].7z` contains:

```text
Midnight Club 3 DUB Edition/
  default.xbe
  DATA/
  ...
```

Expected output alongside the archive: `Midnight Club 3 DUB Edition [!].iso`.

The script:

1. Uses 7-Zip to extract into a uniquely named staging directory **on the archive's drive**.
2. Descends through any single enclosing folders until `default.xbe` is at the selected game root.
3. Calls `xdvdfs pack` and then `xdvdfs ls` to perform a basic sanity check.
4. Moves the completed ISO to the final name and deletes staging files.

The archive stays untouched. Existing output ISOs are not overwritten. Archive warnings (including 7-Zip exit code 1) stop the operation instead of being silently ignored; inspect the warning and archive before retrying.

## Workflow 2: Xbox 360 ISO → extracted game folder

Right-click a compatible `.iso` file and choose **Extract Xbox 360 ISO (xDVDFS)**.

Example: `Game of Thrones [NTSCU].iso` → `Game of Thrones [NTSCU]\default.xex` and game assets.

The script invokes `xdvdfs unpack`, checks that a nonempty `default.xex` exists at the extracted root, and renames the temporary directory into the final game folder. The source ISO stays untouched, and preexisting folders are never overwritten. Afterward, open `default.xex` in Xenia as appropriate.

Some Xbox 360 disc images may require formats, keys, or tooling outside the scope of xDVDFS. Multi-disc, installation, unsupported, damaged, or protected images may not extract into a launchable `default.xex` folder.

## Direct script usage (without context menu)

```powershell
& "$env:LOCALAPPDATA\XboxISO\Convert-XboxISO.ps1" 'L:\Console Games and Roms\XBOX\Game.7z'
& "$env:LOCALAPPDATA\Xbox360ISOExtractor\Extract-Xbox360ISO.ps1" 'D:\Games\Game.iso'
```

## Uninstall

Remove **both** right-click menus without deleting any software or games:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall-All.ps1
```

Run it from the downloaded toolkit directory. Alternatively, run each installed `Uninstall-ContextMenu.ps1` individually. If you want to remove the tool completely, uninstall the menus first, then delete `%LOCALAPPDATA%\XboxISO` and `%LOCALAPPDATA%\Xbox360ISOExtractor` manually. Game archives, ISOs, and extracted folders remain untouched.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Right-click menu missing | On Windows 11 open **Show more options**; rerun `Install-All.ps1`. |
| `xdvdfs.exe` not found | Place the CLI binary at `%LOCALAPPDATA%\XboxISO\xdvdfs.exe`. |
| `7z.exe` not found | Install 7-Zip from the official website. |
| Archive extracts with warnings | Check the archive with 7-Zip **Test** before converting. |
| No `default.xbe` | Check the original Xbox archive folder structure; this workflow requires a game root containing `default.xbe`. |
| No `default.xex` | The Xbox 360 image may be unsupported, not a game disc, or have an unexpected layout. |
| Existing destination | Move/rename the existing ISO or folder first; the tool never overwrites it. |
| Disk space issues | Staging is on the source drive; ensure it has enough space. |
| Xenia won't launch extracted files | Verify the game, emulator compatibility, and the presence of a valid `default.xex`. File presence alone is not sufficient. |

## Security and limitations

- Context menus register under `HKEY_CURRENT_USER`, not machine-wide registry settings.
- Explorer launches the PowerShell scripts using `-ExecutionPolicy Bypass` **for that invocation**, not by permanently changing the system policy. Only install scripts you have inspected and trust.
- Treat downloaded archives and ISOs as untrusted input; exercise care before running extracted game executables.
- These scripts were prepared for **Windows PowerShell 5.1**; they have not been end-to-end tested on every Xbox image variant.
- Verification is a basic file-presence check, **not** a complete boot or integrity test.
- No copyrighted games or game content are included.

## Upstream project and attribution

This toolkit depends on **[xdvdfs by antangelo](https://github.com/antangelo/xdvdfs)** for image creation, listing, and extraction. Its upstream CLI provides [`pack`, `unpack`, and `ls`](https://github.com/antangelo/xdvdfs). The xDVDFS project is distributed under the **MIT License**; see its [upstream LICENSE](https://github.com/antangelo/xdvdfs/blob/main/LICENSE). **This repository does not include the xDVDFS source or binary.** Please report image-format issues to the upstream project only after confirming the issue occurs with xDVDFS directly; wrapper/script issues belong here.

[7-Zip](https://www.7-zip.org/) is a separate dependency and is not included here.

## License

The **toolkit's original PowerShell scripts and documentation** are licensed under the **GNU General Public License, version 3.0** (`GPL-3.0-only`); see [LICENSE](LICENSE). This choice does not alter the license of xDVDFS or 7-Zip.

## Contributions

Issues and pull requests for bugs, compatibility notes, and improved diagnostics are welcome. Please do not submit copyrighted game assets or disc images.
