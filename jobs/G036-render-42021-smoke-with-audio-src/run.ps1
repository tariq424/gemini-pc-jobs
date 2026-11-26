$ErrorActionPreference = 'Continue'
$h = New-Object hashtable
$h['src_path'] = 'F:\videos\video_studio\jobs\20261124_232033_gsmoke\src\2026-11-24_22-51-56.mp4'
$h['src_title'] = 'AI is cheating in Image generation (42021 smoke)'
$h['mode'] = 'smoke'
$h['own_source'] = $true
$h['auto_approve'] = $true
$h['visual_review'] = 'never'
$h['captions'] = $true
$body = $h | ConvertTo-Json
$res = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs' -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 120
$jid = $res.id
Write-Output ("CREATED_42021_JOB_ID=" + $jid)
if ($jid) {
   Start-Sleep -Seconds 25
   $st = Invoke-RestMethod -Uri ("http://127.0.0.1:42021/api/jobs/" + $jid) -TimeoutSec 15
   Write-Output ("STATUS=" + $st.status + " | STAGE=" + $st.stage + " | ERROR=" + $st.error)
   if ($st.log) { $st.log | Select-Object -Last 12 | ForEach-Object { Write-Output ('LOG: ' + $_) } }
}

