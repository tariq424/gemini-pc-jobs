$ErrorActionPreference = 'Continue'
$jobs = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs' -TimeoutSec 15
$list = if ($jobs -is [array]) { $jobs } elseif ($jobs.jobs) { $jobs.jobs } else { @($jobs) }
$list | Select-Object -First 3 | ForEach-Object { Write-Output ('JOB: ' + $_.id + ' | ' + $_.status + ' | ' + $_.stage + ' | ' + $_.title) }
$top = $list | Select-Object -First 1
if ($top -and $top.id) {
   $d = Invoke-RestMethod -Uri ('http://127.0.0.1:42021/api/jobs/' + $top.id) -TimeoutSec 15
   Write-Output ('TOP_STATUS=' + $d.status + ' | STAGE=' + $d.stage + ' | ERR=' + $d.error)
   if ($d.log) { $d.log | Select-Object -Last 12 | ForEach-Object { Write-Output ('LOG: ' + $_) } }
}

