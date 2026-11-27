$ErrorActionPreference = 'Continue'
$s = 'F:\code\gvideo-studio\app\studio'
Write-Output '=== QC_REPAIR RUNGS ==='
$q = Get-Content "$s\qc_repair.py"
$idx = ($q | Select-String -Pattern '^RUNGS\s*=' | Select-Object -First 1).LineNumber
if ($idx) { $q[($idx-1)..[math]::Min($q.Count-1, $idx+35)] | ForEach-Object { Write-Output $_ } }
Write-Output '=== SHORT.PY LADDER & OWN_FOOTAGE ==='
Select-String -Path "$s\short.py" -Pattern 'own_footage|source_visuals|ladder\.run|illustrate|silhouette|cloudgen|visual_ladder' | Select-Object -First 35 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }
Write-Output '=== LADDER.PY TAIL (150-210) ==='
$ld = Get-Content "$s\ladder.py"
$ld[149..[math]::Min($ld.Count-1, 209)] | ForEach-Object { Write-Output $_ }
Write-Output '=== SOURCE_VISUALS.PY DEFS ==='
Select-String -Path "$s\source_visuals.py" -Pattern '^def |own_footage|_best_framed' | Select-Object -First 25 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }

