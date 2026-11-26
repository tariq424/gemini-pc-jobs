$ErrorActionPreference = 'Continue'
$body = @{
   src_path      = 'F:\videos\video_studio\jobs\20261124_232033_gsmoke\src\source_video.mp4'
   src_title     = 'AI is cheating in Image generation (42021 smoke)'
   mode          = 'smoke'
   own_source    = $true
   auto_approve  = $true
   visual_review = 'never'
   captions      = $true
| ConvertTo-Json
Write-Output '=== POST /api/jobs (42021) ==='
$res = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs' -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 30
$jid = $res.id
Write-Output ("CREATED_42021_JOB_ID=" + $jid)
if ($jid) {
   Start-Sleep -Seconds 15
   $st = Invoke-RestMethod -Uri ("http://127.0.0.1:42021/api/jobs/" + $jid) -TimeoutSec 15
   Write-Output ("STATUS=" + $st.status + " | STAGE=" + $st.stage + " | ERROR=" + $st.error)
   if ($st.log) { $st.log | Select-Object -Last 10 | ForEach-Object { Write-Output ('LOG: ' + $_) } }
}

