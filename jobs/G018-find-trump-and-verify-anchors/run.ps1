$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
Write-Output '=== VENVS ==='
foreach ($p in @("$g\app\env\Scripts\python.exe","$g\.venv\Scripts\python.exe",'F:\code\video-studio-test\.venv\Scripts\python.exe','F:\code\video-studio\app\env\Scripts\python.exe')) {
   if (Test-Path $p) { Write-Output ("PY: " + $p) }
}
Write-Output '=== JOBS_DIR & TRUMP ==='
& python -c "import sys,json; sys.path.insert(0,r'F:\code\gvideo-studio\app'); from studio import config; from pathlib import Path; jd=Path(config.load()['jobs_dir']); print('JOBS_DIR:',jd); hits=[d for d in sorted(jd.iterdir(),reverse=True) if d.is_dir() and ('trump' in (d/'src'/'meta.json').read_text(errors='ignore').lower() or 'cheating' in (d/'src'/'meta.json').read_text(errors='ignore').lower()) if (d/'src'/'meta.json').exists()]; print('HITS:',[str(h) for h in hits[:3]]); print('META:',(hits[0]/'src'/'meta.json').read_text(errors='ignore')[:400] if hits else 'NONE')" 2>&1
Write-Output '=== BEST_FRAMED CALLERS ==='
Select-String -Path "$g\app\studio\source_visuals.py" -Pattern '_best_framed' -Context 2,2 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }
Write-Output '=== FOOTAGE VERIFY ==='
$fl = Get-Content "$g\app\studio\footage.py"
$i = ($fl | Select-String 'def verify\(' | Select-Object -First 1).LineNumber
if ($i) { $fl[($i-1)..([math]::Min($i+55, $fl.Count-1))] | ForEach-Object -Begin {$n=$i} -Process { Write-Output ("$n`: $_"); $n++ } }

