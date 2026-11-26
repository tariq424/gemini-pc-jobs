$ErrorActionPreference = 'Continue'
Write-Output '=== JOB 20261126_125425 STATUS ==='
try {
    $d = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs/20261126_125425' -TimeoutSec 15
    Write-Output ('STATUS=' + $d.status + ' | STAGE=' + $d.stage + ' | ERR=' + $d.error)
    if ($d.log) { $d.log | Select-Object -Last 10 | ForEach-Object { Write-Output ('LOG: ' + $_) } }
} catch { Write-Output ('API_ERR=' + $_.Exception.Message) }
$jdir = 'F:\videos\video_studio\jobs\20261126_125425'
if (Test-Path $jdir) {
    Write-Output '=== FINAL MP4S ==='
    Get-ChildItem $jdir -Recurse -Filter '*.mp4' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\src\\' } | ForEach-Object { Write-Output ('MP4: ' + $_.FullName + ' (' + [math]::Round($_.Length/1MB,2) + ' MB)') }
}
Write-Output '=== RECENT 42021 QUEUE (TOP 5) ==='
try {
    $jobs = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs' -TimeoutSec 15
    $jobs | Select-Object -First 5 | ForEach-Object { Write-Output ('JOB: ' + $_.id + ' | ' + $_.status + ' | ' + $_.stage + ' | ' + $_.title) }
} catch { Write-Output ('QUEUE_ERR=' + $_.Exception.Message) }

