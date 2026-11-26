$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$v = 'F:\code\video-studio-test'
Write-Output '=== START FILES ==='
Get-ChildItem $g -File | Where-Object { $_.Name -match 'start|run|server|main|bat|ps1' } | ForEach-Object { Write-Output $_.Name }
$bat = Join-Path $g 'start-video-studio.bat'
if (Test-Path $bat) { Get-Content $bat | Select-Object -First 20 }
Write-Output '=== JOB DIRS ==='
Get-ChildItem $v -Directory | Select-Object -ExpandProperty Name
Select-String -Path "$v\app\*.py","$v\app\studio\*.py" -Pattern 'JOBS_DIR|jobs_dir|42020|42030' -ErrorAction SilentlyContinue | Select-Object -First 12 | ForEach-Object { Write-Output ($_.Filename + ':' + $_.LineNumber + ' ' + $_.Line.Trim()) }
Write-Output '=== SOURCE_VISUALS ==='
Select-String -Path "$g\app\studio\source_visuals.py" -Pattern 'def _best_framed|FRAMED_MIN|def own' -Context 0,4 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()); $_.Context.PostContext | ForEach-Object { Write-Output ('  ' + $_.Trim()) } }
Write-Output '=== FOOTAGE ==='
Select-String -Path "$g\app\studio\footage.py" -Pattern 'def verify|return True|return False' -Context 1,2 | Select-Object -First 12 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }

