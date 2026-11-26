$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$live = Get-NetTCPConnection -LocalPort 42020 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($live) {
   $wp = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $live.OwningProcess) -ErrorAction SilentlyContinue
   Write-Output ("LIVE_CMD=" + $wp.CommandLine)
}
$cands = @(
   'F:\code\video-studio-test\app\env\Scripts\python.exe',
   'F:\code\video-studio-test\env\Scripts\python.exe',
   'C:\pinokio\api\video-studio.git\app\env\Scripts\python.exe',
   'C:\pinokio\bin\miniconda\python.exe'
)
$py = $null
foreach ($c in $cands) {
   if (Test-Path $c) {
       $v = & $c -c "import sys,flask,matplotlib; print(sys.version_info[:2])" 2>&1
       Write-Output ("CAND $c => " + ($v -join ' '))
       if ($LASTEXITCODE -eq 0 -and ($v -join ' ') -match '3, 1[2-9]') { $py = $c; break }
   }
}
if ($py) {
   $env:PORT = '42021'
   $env:PYTHONUNBUFFERED = '1'
   $env:PATH = (Split-Path $py) + ";C:\pinokio\bin\miniconda;C:\pinokio\bin\miniconda\Scripts;C:\pinokio\bin\miniconda\Library\bin;" + $env:PATH
   $p = Start-Process -FilePath $py -ArgumentList 'server.py' -WorkingDirectory "$g\app" -RedirectStandardOutput "$g\server_42021.out.log" -RedirectStandardError "$g\server_42021.err.log" -WindowStyle Hidden -PassThru
   Write-Output ("STARTED_42021_PID=" + $p.Id + " PY=" + $py)
   Start-Sleep -Seconds 6
   try {
       $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:42021/' -TimeoutSec 10
       Write-Output ("HTTP_42021=" + $r.StatusCode)
   } catch {
       Write-Output ("HTTP_42021_ERR=" + $_.Exception.Message)
       if (Test-Path "$g\server_42021.err.log") { Get-Content "$g\server_42021.err.log" -Tail 10 }
   }
} else {
   Write-Output 'NO_PY312_VENV_FOUND_IN_CANDS'
}
Write-Output '=== LIVE 42020 /api/jobs ==='
try {
   $jobs = Invoke-RestMethod -Uri 'http://127.0.0.1:42020/api/jobs' -TimeoutSec 10
   $list = if ($jobs -is [array]) { $jobs } elseif ($jobs.jobs) { $jobs.jobs } else { @($jobs) }
   Write-Output ("JOB_COUNT=" + $list.Count)
   $list | Select-Object -First 8 | ForEach-Object { Write-Output ($_.id + ' | ' + $_.title + ' | ' + $_.status + ' | dir=' + $_.dir) }
   $list | Where-Object { ($_.title -match 'trump|cheating|likeness') -or ($_.id -match 'trump|cheating|likeness') } | Select-Object -First 5 | ForEach-Object { Write-Output ('MATCH: ' + $_.id + ' | ' + $_.title + ' | dir=' + $_.dir) }
} catch {
   Write-Output ("JOBS_API_ERR=" + $_.Exception.Message)
}

