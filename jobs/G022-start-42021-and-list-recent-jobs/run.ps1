$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$liveConn = Get-NetTCPConnection -LocalPort 42020 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
$py = 'F:\code\video-studio\app\env\Scripts\python.exe'
if ($liveConn) {
   $wp = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $liveConn.OwningProcess) -ErrorAction SilentlyContinue
   if ($wp -and $wp.ExecutablePath -and (Test-Path $wp.ExecutablePath)) { $py = $wp.ExecutablePath }
}
Write-Output ("USING_PY=" + $py)
$up = Get-NetTCPConnection -LocalPort 42021 -State Listen -ErrorAction SilentlyContinue
if (-not $up) {
   $env:PORT = '42021'
   $env:PYTHONUNBUFFERED = '1'
   $env:PATH = "C:\pinokio\bin\miniconda;C:\pinokio\bin\miniconda\Scripts;C:\pinokio\bin\miniconda\Library\bin;" + $env:PATH
   $p = Start-Process -FilePath $py -ArgumentList 'server.py' -WorkingDirectory "$g\app" -RedirectStandardOutput "$g\server_42021.out.log" -RedirectStandardError "$g\server_42021.err.log" -WindowStyle Hidden -PassThru
   Write-Output ("STARTED_42021_PID=" + $p.Id)
   Start-Sleep -Seconds 5
}
try {
   $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:42021/' -TimeoutSec 10
   Write-Output ("HTTP_42021=" + $r.StatusCode)
} catch {
   Write-Output ("HTTP_42021_ERR=" + $_.Exception.Message)
   if (Test-Path "$g\server_42021.err.log") { Get-Content "$g\server_42021.err.log" -Tail 12 }
}
Write-Output '=== RECENT 12 JOBS ==='
Get-ChildItem 'F:\videos\video_studio\jobs' -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 12 | ForEach-Object {
   $d = $_.FullName
   $title = ''
   foreach ($jf in @('src\meta.json','job.json','meta.json')) {
       $jp = Join-Path $d $jf
       if (-not $title -and (Test-Path $jp)) {
           $raw = Get-Content $jp -Raw
           $m = [regex]::Match($raw, '"title"\s*:\s*"([^"]{1,80})')
           if ($m.Success) { $title = $m.Groups[1].Value }
       }
   }
   $mp4s = (Get-ChildItem $d -Filter '*.mp4' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name) -join ','
   Write-Output ($_.Name + ' | ' + $_.LastWriteTime.ToString('MM-dd HH:mm') + ' | ' + $title + ' | mp4=' + $mp4s)
}

