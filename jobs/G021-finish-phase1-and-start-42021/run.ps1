$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$sv = "$g\app\studio\source_visuals.py"
$t1 = [System.IO.File]::ReadAllText($sv)
$o1 = 'try: start = _best_framed(source, start, duration, dest, total, req, log)'
$n1 = 'try: start = start if own(job) else _best_framed(source, start, duration, dest, total, req, log)'
if ($t1.Contains($o1)) { $t1 = $t1.Replace($o1, $n1); [System.IO.File]::WriteAllText($sv, $t1, [System.Text.UTF8Encoding]::new($false)); Write-Output '[OK] sv own_footage _best_framed bypass' } else { Write-Output '[SKIP] sv' }
$sp = "$g\app\server.py"
$t2 = [System.IO.File]::ReadAllText($sp)
$o2 = 'if not reload or os.environ.get("WERKZEUG_RUN_MAIN"):'
$n2 = 'if port == 42020 and (not reload or os.environ.get("WERKZEUG_RUN_MAIN")):'
if ($t2.Contains($o2)) { $t2 = $t2.Replace($o2, $n2); [System.IO.File]::WriteAllText($sp, $t2, [System.Text.UTF8Encoding]::new($false)); Write-Output '[OK] server.py gate sweeps to 42020' } else { Write-Output '[SKIP] server.py' }
& python -m py_compile $sv $sp 2>&1
Write-Output ("PY_COMPILE=" + $LASTEXITCODE)
if ($LASTEXITCODE -eq 0) {
   & git -C $g add app/studio/source_visuals.py app/server.py 2>&1
   & git -C $g commit -m "Bypass _best_framed on own_footage and isolate background sweeps to port 42020" 2>&1
   & git -C $g push origin main 2>&1
   Write-Output ("HEAD=" + (& git -C $g rev-parse --short HEAD))
}
Write-Output '=== FIND TRUMP JOB ==='
Get-ChildItem 'F:\videos\video_studio\jobs' -Directory | Sort-Object Name -Descending | ForEach-Object {
   $d = $_.FullName
   $m = Join-Path $d 'src\meta.json'
   $hit = $false
   if (Test-Path $m) { $raw = Get-Content $m -Raw; if ($raw -match 'trump-likeness|cheating|AI_Image_Generators|own_footage.*true') { $hit = $true } }
   if (-not $hit -and (Get-ChildItem $d -Filter '*Cheating*' -ErrorAction SilentlyContinue)) { $hit = $true }
   if ($hit) { Write-Output ("TRUMP_HIT: " + $d + " | own=" + ($raw -match '"own_footage"\s*:\s*true')) }
}
Write-Output '=== START 42021 ==='
$up = Get-NetTCPConnection -LocalPort 42021 -State Listen -ErrorAction SilentlyContinue
if (-not $up) {
   $env:PORT = '42021'
   $env:PYTHONUNBUFFERED = '1'
   $env:PATH = "C:\pinokio\bin\miniconda;C:\pinokio\bin\miniconda\Scripts;C:\pinokio\bin\miniconda\Library\bin;" + $env:PATH
   $py = 'F:\code\video-studio-test\.venv\Scripts\python.exe'
   $p = Start-Process -FilePath $py -ArgumentList 'server.py' -WorkingDirectory "$g\app" -RedirectStandardOutput "$g\server_42021.out.log" -RedirectStandardError "$g\server_42021.err.log" -WindowStyle Hidden -PassThru
   Write-Output ("STARTED 42021 PID=" + $p.Id)
   Start-Sleep -Seconds 5
}
try {
   $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:42021/' -TimeoutSec 10
   Write-Output ("HTTP_42021=" + $r.StatusCode)
} catch {
   Write-Output ("HTTP_42021_ERR=" + $_.Exception.Message)
   if (Test-Path "$g\server_42021.err.log") { Get-Content "$g\server_42021.err.log" -Tail 10 }
}

