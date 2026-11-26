$ErrorActionPreference = 'Continue'
foreach ($p in @(42020,42021,42030,42031,42040,42041)) {
   $c = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
   Write-Output ("PORT $p=" + $(if ($c) { "UP(PID " + $c[0].OwningProcess + ")" } else { "free" }))
}
$bat = 'F:\code\gvideo-studio\start-video-studio.bat'
if (Test-Path $bat) { Write-Output ("BAT: " + ((Get-Content $bat) -join ' | ')) }
$g12 = 'F:\code\gemini-helper\g012_probe.py'
if (Test-Path $g12) { Write-Output ("G12_HEAD: " + ((Get-Content $g12 -TotalCount 3) -join ' // ')) }
foreach ($root in @('F:\code\video-studio-test','F:\code\video-studio','F:\code\gvideo-studio')) {
   foreach ($sub in @('jobs','data\jobs','runs')) {
       $d = Join-Path $root $sub
       if (Test-Path $d) {
           Write-Output ("JOBROOT: $d count=" + (Get-ChildItem $d -Directory).Count)
           Get-ChildItem $d -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 8 | ForEach-Object {
               $m = Join-Path $_.FullName 'src\meta.json'
               $t = if (Test-Path $m) { (Get-Content $m -Raw) } else { '' }
               if ($t -match 'trump|cheating|likeness' -or $_.Name -match 'trump|cheating|likeness') {
                   Write-Output ("HIT: " + $_.FullName + " cues=" + (Test-Path (Join-Path $_.FullName 'src\source_cues.json')) + " vid=" + (Test-Path (Join-Path $_.FullName 'src\source_video.mp4')))
               }
           }
       }
   }
}

