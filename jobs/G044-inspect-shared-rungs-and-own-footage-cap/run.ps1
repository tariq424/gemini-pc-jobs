$ErrorActionPreference = 'Continue'
$s = 'F:\code\gvideo-studio\app\studio'
Write-Output '=== RUNGS IN qc_repair.py ==='
if (Test-Path "$s\qc_repair.py") {
    Select-String -Path "$s\qc_repair.py" -Pattern 'RUNGS|def |cloudflare|blender|unreal|flow|silhouette|illustration' | Select-Object -First 40 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }
}
Write-Output '=== LADDER.PY ==='
if (Test-Path "$s\ladder.py") {
    Select-String -Path "$s\ladder.py" -Pattern 'def |RUNGS|stock|wangp|cloudflare|blender|flow|illustration|silhouette' | Select-Object -First 40 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }
}
Write-Output '=== OWN_FOOTAGE CAP IN short.py ==='
Select-String -Path "$s\short.py" -Pattern 'own_footage|source_visuals|auto_request|Picture|slot' | Select-Object -First 35 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }

