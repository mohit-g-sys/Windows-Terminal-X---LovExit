$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = 'LovExit'

$e    = [char]27
$User = if ($env:USERNAME) { $env:USERNAME } else { 'User' }
$FULL = [string][char]0x2588
$LINE = [string][char]0x2500
$DOT  = [string][char]0x2022
$PTR  = [string][char]0x25BA
$SH1  = [string][char]0x2592
$SH2  = [string][char]0x2591

function Fg($r, $g, $b) { "$e[38;2;${r};${g};${b}m" }
$RESET = "$e[0m"
$BOLD  = "$e[1m"
$cAccent = Fg 0 229 255
$cPink   = Fg 199 146 234
$cText   = Fg 230 230 240
$cDim    = Fg 120 120 155

$letterColor = Fg 0 0 0
$gr = 0; $gg = 229; $gb = 255
$glowOn = $false

$rSep = 8; $rHello = 10; $rTag = 11; $rClock = 13; $rHead = 15; $rMenu = 17; $rArt = 9

$sty = @(
  "$e[0m",
  ("$e[0m" + (Fg $gr $gg $gb)),
  ("$e[0m" + (Fg ([int]($gr * 0.55)) ([int]($gg * 0.55)) ([int]($gb * 0.55)))),
  ("$e[0m" + $letterColor)
)
$g1 = ' '; $g2 = ' '
if ($glowOn) { $g1 = $SH1; $g2 = $SH2 }
$chr = @(' ', $g1, $g2, $FULL)

$glyph = @{
  L = '#    ','#    ','#    ','#    ','#####'
  O = ' ### ','#   #','#   #','#   #',' ### '
  V = '#   #','#   #','#   #',' # # ','  #  '
  E = '#####','#    ','#### ','#    ','#####'
  X = '#   #',' # # ','  #  ',' # # ','#   #'
  I = '#####','  #  ','  #  ','  #  ','#####'
  T = '#####','  #  ','  #  ','  #  ','  #  '
}
$word = 'LOVEXIT'.ToCharArray()
$art = @()
for ($r = 0; $r -lt 5; $r++) {
  $row = (($word | ForEach-Object { $glyph["$_"][$r] }) -join '  ')
  $row = $row.Replace('#', 'X').Replace(' ', '  ').Replace('X', 'XX')
  $art += $row + (' ' * 16)
}
$LOOP  = $art[0].Length
$fullC = [char]0x2588

$isL = @()
for ($g = 0; $g -lt 7; $g++) { $isL += ,(New-Object bool[] $LOOP) }
for ($r = 0; $r -lt 5; $r++) {
  for ($c = 0; $c -lt $LOOP; $c++) {
    if ($art[$r][$c] -eq 'X') { $isL[$r + 1][$c] = $true }
  }
}

$kind = @()
for ($g = 0; $g -lt 7; $g++) {
  $kr = New-Object int[] $LOOP
  for ($c = 0; $c -lt $LOOP; $c++) {
    if ($isL[$g][$c]) { $kr[$c] = 3; continue }
    $best = 9
    for ($dy = -1; $dy -le 1; $dy++) {
      $gg2 = $g + $dy
      if ($gg2 -lt 0 -or $gg2 -gt 6) { continue }
      for ($dx = -4; $dx -le 4; $dx++) {
        $cc = ($c + $dx + $LOOP) % $LOOP
        if ($isL[$gg2][$cc]) {
          $d = [math]::Ceiling([math]::Abs($dx) / 2) + [math]::Abs($dy)
          if ($d -lt $best) { $best = $d }
        }
      }
    }
    if ($best -eq 1) { $kr[$c] = 1 } elseif ($best -eq 2) { $kr[$c] = 2 }
  }
  $kind += ,$kr
}

$script:bStr = @()
$script:bIdx = @()

function Build-Banner($w) {
  $reps  = [int][math]::Ceiling($w / $LOOP) + 2
  $total = $LOOP * $reps
  $script:bStr = @()
  $script:bIdx = @()
  for ($g = 0; $g -lt 7; $g++) {
    $sb   = New-Object System.Text.StringBuilder
    $ix   = New-Object int[] ($total + 1)
    $prev = -1
    $kr   = $kind[$g]
    for ($c = 0; $c -lt $total; $c++) {
      $k = $kr[$c % $LOOP]
      if ($k -ne $prev) { [void]$sb.Append($sty[$k]); $prev = $k }
      $ix[$c] = $sb.Length
      [void]$sb.Append($chr[$k])
    }
    $ix[$total] = $sb.Length
    $script:bStr += $sb.ToString()
    $script:bIdx += ,$ix
  }
}

$script:dots = $null
$script:aRows = 0
$script:aCols = 0
$script:artLines = @()
$script:artCols = 0
$script:artKey = ''
$script:artNote = ''
$bits = @( @(1, 8), @(2, 16), @(4, 32), @(64, 128) )

$dir = $PSScriptRoot
if (-not $dir) { $dir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$artPath = Join-Path $dir 'art.txt'
if (Test-Path $artPath) {
  $ln = [System.IO.File]::ReadAllLines($artPath, [System.Text.Encoding]::UTF8)
  $lnCols = 0
  foreach ($l in $ln) { if ($l.Length -gt $lnCols) { $lnCols = $l.Length } }
  $masks = @()
  foreach ($l in $ln) {
    $mr = New-Object int[] $lnCols
    for ($c = 0; $c -lt $l.Length; $c++) {
      $ch = [int]$l[$c]
      if ($ch -ge 0x2800 -and $ch -le 0x28FF) { $mr[$c] = $ch - 0x2800 }
    }
    $masks += ,$mr
  }
  $minR = $ln.Count; $maxR = -1; $minC = $lnCols; $maxC = -1
  for ($r = 0; $r -lt $ln.Count; $r++) {
    for ($c = 0; $c -lt $lnCols; $c++) {
      if ($masks[$r][$c] -ne 0) {
        if ($r -lt $minR) { $minR = $r }
        if ($r -gt $maxR) { $maxR = $r }
        if ($c -lt $minC) { $minC = $c }
        if ($c -gt $maxC) { $maxC = $c }
      }
    }
  }
  if ($maxR -ge 0) {
    $script:aRows = $maxR - $minR + 1
    $script:aCols = $maxC - $minC + 1
    $DW = $script:aCols * 2
    $DH = $script:aRows * 4
    $script:dots = @()
    for ($y = 0; $y -lt $DH; $y++) {
      $dl = New-Object byte[] $DW
      $cr = $minR + ($y -shr 2)
      $cy = $y -band 3
      for ($x = 0; $x -lt $DW; $x++) {
        $cc = $minC + ($x -shr 1)
        $cx = $x -band 1
        if ($masks[$cr][$cc] -band $bits[$cy][$cx]) { $dl[$x] = 1 }
      }
      $script:dots += ,$dl
    }
  } else {
    $script:artNote = 'art.txt found, but it has no braille characters (save it as UTF-8)'
  }
} else {
  $script:artNote = "art.txt not found in $dir"
}

function Build-Art($availCols, $availRows) {
  $key = "$availCols x $availRows"
  if ($key -eq $script:artKey) { return }
  $script:artKey = $key
  $script:artLines = @()
  $script:artCols = 0
  if (-not $script:dots -or $availCols -lt 1 -or $availRows -lt 1) { return }

  $s = [math]::Min(1.0, [math]::Min($availCols / $script:aCols, $availRows / $script:aRows))
  if ($s -lt 0.25) { return }
  $tc = [int][math]::Floor($script:aCols * $s)
  $tr = [int][math]::Floor($script:aRows * $s)
  if ($tc -lt 1 -or $tr -lt 1) { return }

  $TW = $tc * 2; $TH = $tr * 4
  $DW = $script:aCols * 2; $DH = $script:aRows * 4
  $lines = @()
  for ($r = 0; $r -lt $tr; $r++) {
    $sb = New-Object System.Text.StringBuilder
    for ($c = 0; $c -lt $tc; $c++) {
      $mask = 0
      for ($cy = 0; $cy -lt 4; $cy++) {
        $ty = $r * 4 + $cy
        $y0 = [int][math]::Floor($ty * $DH / $TH)
        $y1 = [int][math]::Max($y0, [math]::Ceiling(($ty + 1) * $DH / $TH) - 1)
        for ($cx = 0; $cx -lt 2; $cx++) {
          $tx = $c * 2 + $cx
          $x0 = [int][math]::Floor($tx * $DW / $TW)
          $x1 = [int][math]::Max($x0, [math]::Ceiling(($tx + 1) * $DW / $TW) - 1)
          $cnt = 0; $tot = 0
          for ($yy = $y0; $yy -le $y1; $yy++) {
            $d = $script:dots[$yy]
            for ($xx = $x0; $xx -le $x1; $xx++) { $cnt += $d[$xx]; $tot++ }
          }
          if ($tot -gt 0 -and ($cnt / $tot) -ge 0.2) { $mask += $bits[$cy][$cx] }
        }
      }
      [void]$sb.Append([char](0x2800 + $mask))
    }
    $lines += $sb.ToString()
  }
  $script:artLines = $lines
  $script:artCols = $tc
}

$items = @(
  @{ Name = 'Command Prompt';     Desc = 'classic cmd';    Exe = 'cmd.exe';        Args = @() }
  @{ Name = 'Windows PowerShell'; Desc = 'powershell 5.1'; Exe = 'powershell.exe'; Args = @('-NoLogo') }
)
if (Get-Command pwsh.exe) { $items += @{ Name = 'PowerShell 7'; Desc = 'pwsh';        Exe = 'pwsh.exe'; Args = @('-NoLogo') } }
if (Get-Command wsl.exe)  { $items += @{ Name = 'WSL';          Desc = 'linux shell'; Exe = 'wsl.exe';  Args = @() } }
$items += @{ Name = 'Exit'; Desc = 'close this tab'; Exe = $null; Args = @() }

$script:W = 0

function Draw-Static {
  $w  = [Console]::WindowWidth
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append("$e[0m$e[2J$e[?25l")
  [void]$sb.Append("$e[${rSep};1H" + $cDim + ($LINE * $w) + $RESET)
  [void]$sb.Append("$e[${rHello};4H" + $BOLD + $cText + "Hey " + $cAccent + $User + $RESET)
  [void]$sb.Append("$e[${rTag};4H" + $cPink + "What are we cooking today?" + $RESET)
  [void]$sb.Append("$e[${rHead};4H" + $cDim + "S E L E C T   A   S H E L L" + $RESET)
  $foot = $rMenu + $items.Count + 1
  [void]$sb.Append("$e[${foot};4H" + $cDim + "Up/Down move  $DOT  Enter launch  $DOT  1-$($items.Count) quick pick  $DOT  Esc quit" + $RESET)
  if ($script:artNote) {
    [void]$sb.Append("$e[$($foot + 2);4H" + $cDim + $script:artNote + $RESET)
  }

  $na = $script:artLines.Count
  if ($na -gt 0) {
    $col = $w - $script:artCols - 2
    for ($i = 0; $i -lt $na; $i++) {
      $t = 0
      if ($na -gt 1) { $t = $i / ($na - 1) }
      $cc2 = Fg ([int](199 * $t)) ([int](229 - 83 * $t)) ([int](255 - 21 * $t))
      [void]$sb.Append("$e[$($rArt + $i);${col}H" + $cc2 + $script:artLines[$i])
    }
    [void]$sb.Append($RESET)
  }
  [Console]::Write($sb.ToString())
}

function Draw-Menu($sel) {
  $sb = New-Object System.Text.StringBuilder
  for ($i = 0; $i -lt $items.Count; $i++) {
    $row  = $rMenu + $i
    $num  = $i + 1
    $name = $items[$i].Name.PadRight(22)
    $desc = $items[$i].Desc.PadRight(20)
    if ($i -eq $sel) {
      [void]$sb.Append("$e[${row};4H" + $cAccent + $BOLD + "$PTR $num  " + $name + $RESET + $cPink + $desc + $RESET)
    } else {
      [void]$sb.Append("$e[${row};4H" + $cText + "  $num  " + $name + $RESET + $cDim + $desc + $RESET)
    }
  }
  [Console]::Write($sb.ToString())
}

function Draw-Marquee($off) {
  $sb = New-Object System.Text.StringBuilder
  $o  = $off % $LOOP
  for ($g = 0; $g -lt 7; $g++) {
    $ix = $script:bIdx[$g]
    $s  = $sty[$kind[$g][$o]] + $script:bStr[$g].Substring($ix[$o], $ix[$o + $script:W] - $ix[$o])
    [void]$sb.Append("$e[$($g + 1);1H" + $s)
  }
  [void]$sb.Append($RESET)
  [Console]::Write($sb.ToString())
}

function Draw-Clock {
  $now = Get-Date
  [Console]::Write("$e[${rClock};4H" + $BOLD + $cAccent + $now.ToString('hh:mm:ss tt') + $RESET + $cDim + "  $DOT  " + $now.ToString('dddd, dd MMMM yyyy') + $RESET + (' ' * 20))
}

function Start-Launcher {
  $sel = 0; $lastW = -1; $lastH = -1; $lastSec = -1
  $sw  = [System.Diagnostics.Stopwatch]::StartNew()
  while ($true) {
    $w = [Console]::WindowWidth
    $h = [Console]::WindowHeight
    if ($w -ne $lastW -or $h -ne $lastH) {
      $script:W = $w
      Build-Banner $w
      Build-Art ($w - 72) ($h - $rArt)
      Draw-Static; Draw-Menu $sel
      $lastW = $w; $lastH = $h; $lastSec = -1
    }

    Draw-Marquee ([int]($sw.Elapsed.TotalSeconds * 22))

    $sec = (Get-Date).Second
    if ($sec -ne $lastSec) { Draw-Clock; $lastSec = $sec }

    while ([Console]::KeyAvailable) {
      $k = [Console]::ReadKey($true)
      switch ($k.Key) {
        'UpArrow'   { $sel = ($sel - 1 + $items.Count) % $items.Count; Draw-Menu $sel }
        'DownArrow' { $sel = ($sel + 1) % $items.Count; Draw-Menu $sel }
        'Enter'     { return $sel }
        'Escape'    { return ($items.Count - 1) }
        default {
          $d = [string]$k.KeyChar
          if ($d -match '^[1-9]$' -and ([int]$d - 1) -lt $items.Count) { return ([int]$d - 1) }
        }
      }
    }
    Start-Sleep -Milliseconds 30
  }
}

while ($true) {
  $choice = Start-Launcher
  $item   = $items[$choice]
  if (-not $item.Exe) { break }
  [Console]::Write("$e[0m$e[2J$e[H$e[?25h")
  $Host.UI.RawUI.WindowTitle = $item.Name
  & $item.Exe @($item.Args)
  $Host.UI.RawUI.WindowTitle = 'LovExit'
}
[Console]::Write("$e[0m$e[2J$e[H$e[?25h")
