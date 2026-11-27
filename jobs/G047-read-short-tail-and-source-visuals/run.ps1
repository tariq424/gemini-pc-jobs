$ErrorActionPreference = 'Continue'
$s = 'F:\code\gvideo-studio\app\studio'
$sh = Get-Content "$s\short.py"
Write-Output '=== SHORT 589-695 ==='
589..695 | ForEach-Object { if ($_ -le $sh.Count) { $t = $sh[$_-1].TrimEnd(); if ($t -and -not $t.TrimStart().StartsWith('#')) { Write-Output ("{0}:{1}" -f $_, $t) } } }
Write-Output '=== SOURCE_VISUALS 195-260 ==='
$sv = Get-Content "$s\source_visuals.py"
195..260 | ForEach-Object { if ($_ -le $sv.Count) { $t = $sv[$_-1].TrimEnd(); if ($t -and -not $t.TrimStart().StartsWith('#')) { Write-Output ("{0}:{1}" -f $_, $t) } } }
Write-Output '=== CLOUDGEN 90-120 ==='
$cg = Get-Content "$s\cloudgen.py"
90..120 | ForEach-Object { if ($_ -le $cg.Count) { $t = $cg[$_-1].TrimEnd(); if ($t -and -not $t.TrimStart().StartsWith('#')) { Write-Output ("{0}:{1}" -f $_, $t) } } }

