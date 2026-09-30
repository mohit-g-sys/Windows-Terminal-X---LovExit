$ErrorActionPreference = 'Stop'

$guid = '{b3f1c7a2-5d84-4e6b-9a10-7c2e8f4d1a55}'
$installDir = Join-Path $env:USERPROFILE 'LovExit'

$wtCandidates = @(
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json')
)

$settingsPath = $wtCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    $settings.profiles.list = @($settings.profiles.list | Where-Object { $_.guid -ne $guid })
    if ($settings.defaultProfile -eq $guid) {
        $settings.defaultProfile = $settings.profiles.list[0].guid
    }
    $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding UTF8
}

if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
}

Write-Host "LovExit Launcher removed."

