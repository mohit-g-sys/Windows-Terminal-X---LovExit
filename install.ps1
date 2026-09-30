$ErrorActionPreference = 'Stop'

function Remove-JsonComments {
    param([string]$Text)
    $sb = New-Object System.Text.StringBuilder
    $inString = $false
    $escape = $false
    $inLineComment = $false
    $inBlockComment = $false

    for ($i = 0; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        $next = if ($i + 1 -lt $Text.Length) { $Text[$i + 1] } else { [char]0 }

        if ($inLineComment) {
            if ($ch -eq "`r" -or $ch -eq "`n") {
                $inLineComment = $false
                [void]$sb.Append($ch)
            }
            continue
        }

        if ($inBlockComment) {
            if ($ch -eq '*' -and $next -eq '/') {
                $inBlockComment = $false
                $i++
            } elseif ($ch -eq "`r" -or $ch -eq "`n") {
                [void]$sb.Append($ch)
            }
            continue
        }

        if ($inString) {
            [void]$sb.Append($ch)
            if ($escape) {
                $escape = $false
            } elseif ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq '"') {
                $inString = $false
            }
            continue
        }

        if ($ch -eq '"') {
            $inString = $true
            [void]$sb.Append($ch)
            continue
        }

        if ($ch -eq '/' -and $next -eq '/') {
            $inLineComment = $true
            $i++
            continue
        }

        if ($ch -eq '/' -and $next -eq '*') {
            $inBlockComment = $true
            $i++
            continue
        }

        [void]$sb.Append($ch)
    }

    return $sb.ToString()
}

function Read-TerminalSettings {
    param([string]$Path)
    $raw = Get-Content $Path -Raw
    $json = Remove-JsonComments $raw
    return $json | ConvertFrom-Json
}

$projectDir = $PSScriptRoot
$installDir = Join-Path $env:USERPROFILE 'LovExit'
$launcherSource = Join-Path $projectDir 'launcher.ps1'
$artSource = Join-Path $projectDir 'art.txt'

if (-not (Test-Path $launcherSource)) {
    throw "launcher.ps1 was not found next to install.ps1."
}

New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Copy-Item $launcherSource (Join-Path $installDir 'launcher.ps1') -Force
if (Test-Path $artSource) {
    Copy-Item $artSource (Join-Path $installDir 'art.txt') -Force
}

$wtCandidates = @(
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json')
)

$settingsPath = $wtCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $settingsPath) {
    Write-Host ""
    Write-Host "Windows Terminal settings.json was not found."
    Write-Host "The launcher was installed to: $installDir"
    Write-Host "Run it directly with:"
    Write-Host "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$installDir\launcher.ps1`""
    exit 0
}

$backup = "$settingsPath.bak"
Copy-Item $settingsPath $backup -Force

$settings = Read-TerminalSettings $settingsPath

if (-not $settings.profiles -or -not $settings.profiles.list) {
    throw "Windows Terminal profiles.list could not be read."
}

$guid = '{b3f1c7a2-5d84-4e6b-9a10-7c2e8f4d1a55}'
$command = "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$installDir\launcher.ps1`""
$existing = @($settings.profiles.list) | Where-Object { $_.guid -eq $guid } | Select-Object -First 1

if ($existing) {
    $existing.name = 'LovExit Launcher'
    $existing.commandline = $command
    $existing.hidden = $false
    $existing.padding = '0,8,0,8'
    $existing.suppressApplicationTitle = $true
    $existing.tabTitle = 'LovExit'
} else {
    $profile = [pscustomobject][ordered]@{
        guid = $guid
        name = 'LovExit Launcher'
        commandline = $command
        hidden = $false
        padding = '0,8,0,8'
        suppressApplicationTitle = $true
        tabTitle = 'LovExit'
    }
    $settings.profiles.list = @($settings.profiles.list) + $profile
}

$settings.defaultProfile = $guid
$settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding UTF8

Write-Host ""
Write-Host "LovExit Launcher installed."
Write-Host "Launcher: $installDir\launcher.ps1"
Write-Host "Terminal settings backup: $backup"
Write-Host "Open Windows Terminal and select 'LovExit Launcher'."

