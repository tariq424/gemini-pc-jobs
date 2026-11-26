$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio\app\env\Scripts\python.exe'
$up = Get-NetTCPConnection -LocalPort 42021 -State Listen -ErrorAction SilentlyContinue
if (-not $up) {
   $env:PORT = '42021'
   $env:PYTHONUNBUFFERED = '1'
   $env:PATH = "F:\code\video-studio\app\env\Scripts;C:\pinokio\bin\miniconda;C:\pinokio\bin\miniconda\Scripts;C:\pinokio\bin\miniconda\Library\bin;" + $env:PATH
   $p = Start-Process -FilePath $py -ArgumentList 'server.py' -WorkingDirectory "$g\app" -RedirectStandardOutput "$g\server_42021.out.log" -RedirectStandardError "$g\server_42021.err.log" -WindowStyle Hidden -PassThru
   Write-Output ("STARTED_42021_PID=" + $p.Id)
   Start-Sleep -Seconds 6
}
try {
   $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:42021/' -TimeoutSec 10
   Write-Output ("HTTP_42021=" + $r.StatusCode)
   if (Test-Path "$g\server_42021.out.log") { Get-Content "$g\server_42021.out.log" -Tail 6 }
} catch {
   Write-Output ("HTTP_42021_ERR=" + $_.Exception.Message)
   if (Test-Path "$g\server_42021.err.log") { Get-Content "$g\server_42021.err.log" -Tail 12 }
}
Write-Output '=== LIVE 42020 CONFIG & RECENT JOBS ==='
try {
   $cfg = Invoke-RestMethod -Uri 'http://127.0.0.1:42020/api/config' -TimeoutSec 10
   Write-Output ("LIVE_JOBS_DIR=" + $cfg.jobs_dir)
   if ($cfg.jobs_dir -and (Test-Path $cfg.jobs_dir)) {
       Get-ChildItem $cfg.jobs_dir -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | ForEach-Object {
           $m = Join-Path $_.FullName 'src\meta.json'
           $t = ''
           if (Test-Path $m) { $mt = [regex]::Match((Get-Content $m -Raw), '"title"\s*:\s*"([^"]{1,80})'); if ($mt.Success) { $t = $mt.Groups[1].Value } }
           Write-Output ($_.Name + ' | ' + $_.LastWriteTime.ToString('MM-dd HH:mm') + ' | ' + $t)
       }
   }
} catch {
   Write-Output ("LIVE_CFG_ERR=" + $_.Exception.Message)
}

