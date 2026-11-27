$ErrorActionPreference = 'Continue'
$s = 'F:\code\gvideo-studio\app\studio'
Write-Output '=== SHORT.PY 540-625 ==='
$sh = Get-Content "$s\short.py"
540..625 | ForEach-Object { if ($_ -le $sh.Count) { Write-Output ("{0}: {1}" -f $_, $sh[$_-1]) } }
Write-Output '=== SHORT.PY 626-690 ==='
626..690 | ForEach-Object { if ($_ -le $sh.Count) { Write-Output ("{0}: {1}" -f $_, $sh[$_-1]) } }
Write-Output '=== SOURCE_VISUALS.PY _best_framed & auto_request ==='
$sv = Get-Content "$s\source_visuals.py"
$hits = $sv | Select-String -Pattern '^def (auto_request|_best_framed|make|snapshot)'
foreach ($h in $hits) {
    $ln = $h.LineNumber
    Write-Output ("--- line $ln ---")
    $ln..[math]::Min($sv.Count, $ln+22) | ForEach-Object { Write-Output ("{0}: {1}" -f $_, $sv[$_-1]) }
}

