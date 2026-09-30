# LovExit Terminal Launcher

<p align="center">
  <img src="Terminal.png" alt="LovExit Terminal Launcher Preview" width="900">
</p>

A dark, animated Windows Terminal launcher for **LovExit**.

**Developed by mohit.sys**

## Features

- Animated `LOVEXIT` banner
- Optional cyan glow effect
- Responsive terminal layout
- Braille/Unicode artwork loaded from `art.txt`
- Command Prompt
- Windows PowerShell 5.1
- PowerShell 7 when installed
- WSL when installed
- Keyboard navigation
- Automatic Windows username detection
- No hardcoded user-directory paths
- Windows Terminal profile installer
- Easy uninstall

## Requirements

- Windows 10 or Windows 11
- Windows Terminal
- Windows PowerShell 5.1
- UTF-8 support in the terminal
- PowerShell 7 and WSL are optional

The launcher itself does not require PowerShell 7 or WSL. If they are installed, they are detected automatically.

## Project Structure

```text
LovExit-Terminal-Launcher/
├── launcher.ps1
├── art.txt
├── settings.json
├── install.ps1
├── uninstall.ps1
└── README.md
```

### File roles

- `launcher.ps1` — main launcher.
- `art.txt` — Unicode/Braille artwork displayed by the launcher.
- `settings.json` — reference Windows Terminal configuration.
- `install.ps1` — installs the launcher and adds its Windows Terminal profile automatically.
- `uninstall.ps1` — removes the installed profile and launcher.
- `README.md` — setup and usage guide.

## Recommended Setup

### 1. Download the project

Clone the repository:

```powershell
git clone YOUR_REPOSITORY_URL
cd LovExit-Terminal-Launcher
```

Or download the repository as a ZIP and extract it.

### 2. Run the installer

Open PowerShell in the project folder and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1
```

The installer copies the launcher and artwork to:

```text
%USERPROFILE%\LovExit
```

For example, if the Windows username is `alex`, the files are installed to:

```text
C:\Users\alex\LovExit
```

The installer then finds your Windows Terminal settings file and adds the **LovExit Launcher** profile.

A backup of the original Windows Terminal settings file is created with a `.bak` extension before changes are made.

### 3. Open Windows Terminal

Close and reopen Windows Terminal if it was already running.

Open the profile menu and select:

```text
LovExit Launcher
```

The launcher should start.

## Direct Run

You can run the launcher without modifying Windows Terminal:

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\LovExit\launcher.ps1"
```

You can also run the copy directly from the project folder:

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\launcher.ps1"
```

Keep `art.txt` next to `launcher.ps1` when running from the project folder.

## Controls

| Key | Action |
|---|---|
| `↑` | Move up |
| `↓` | Move down |
| `Enter` | Launch selected shell |
| `1-9` | Quick select |
| `Esc` | Exit |

The available shell list changes automatically depending on what is installed on the PC.

## Glow Effect

The glow switch is in `launcher.ps1`:

```powershell
$glowOn = $false
```

Set it to:

```powershell
$glowOn = $true
```

to enable the banner glow.

Keep it as `$false` if you want the non-glowing version.

The glow colors can also be changed here:

```powershell
$gr = 0
$gg = 229
$gb = 255
```

These values are RGB.

The letter color is controlled by:

```powershell
$letterColor = Fg 0 0 0
```

## Changing the Display Name

The launcher automatically uses the Windows username:

```powershell
$User = if ($env:USERNAME) { $env:USERNAME } else { 'User' }
```

This means the same project works on other PCs without changing a personal username.

## Changing the Artwork

`art.txt` is loaded from the same directory as `launcher.ps1`.

Do not move it to a different folder unless you also update the launcher.

The supplied artwork is preserved as UTF-8 Unicode text.

## Windows Terminal Settings

`settings.json` is provided as a reference/template.

It intentionally does **not** contain a personal `C:\Users\...` path.

The installer generates the correct launcher path for the current Windows user automatically.

Do not blindly replace your entire existing Windows Terminal `settings.json` with this file if you already have custom profiles. Use `install.ps1` instead.

The installer understands Windows Terminal's JSON-with-comments settings format and adds/updates only the LovExit profile.

## Manual Windows Terminal Setup

If you do not want to use `install.ps1`:

1. Open Windows Terminal.
2. Open **Settings**.
3. Select **Add a new profile**.
4. Create a profile named:

```text
LovExit Launcher
```

5. Set the command line to:

```text
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "C:\Users\YOUR_USERNAME\LovExit\launcher.ps1"
```

Replace `YOUR_USERNAME` with your Windows username.

Example:

```text
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "C:\Users\alex\LovExit\launcher.ps1"
```

6. Save the profile.

## Uninstall

Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\uninstall.ps1
```

This removes the LovExit profile and the installed:

```text
%USERPROFILE%\LovExit
```

directory.

Your installer-created Windows Terminal backup remains available as a `.bak` file.

## Troubleshooting

### `art.txt not found`

Make sure these files are together:

```text
launcher.ps1
art.txt
```

The launcher searches for `art.txt` beside the PowerShell script.

### The artwork looks wrong

Make sure the files are saved as UTF-8 and use a terminal font with Unicode/Braille support.

Windows Terminal with Cascadia Mono is recommended.

### The launcher does not start

Try running:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\launcher.ps1"
```

If that works, the Windows Terminal profile is the part that needs checking.

### PowerShell 7 does not appear

Install PowerShell 7 and restart Windows Terminal.

The launcher checks for:

```text
pwsh.exe
```

### WSL does not appear

Install and configure WSL, then restart Windows Terminal.

The launcher checks for:

```text
wsl.exe
```

### Windows Terminal settings were changed incorrectly

The installer creates a backup before modifying settings.

Look beside the Windows Terminal `settings.json` file for a backup ending in:

```text
settings.json.bak
```

Restore that backup only after closing Windows Terminal.

## Credits

**LovExit Terminal Launcher**

Developed by **mohit.sys**

Built with:

- PowerShell
- Windows Terminal
- Unicode/Braille artwork
- ANSI true-color escape sequences

## License

If you publish this repository publicly, add the license you want to use before accepting outside contributions.

---

**LovExit — terminal experience by mohit.sys**
