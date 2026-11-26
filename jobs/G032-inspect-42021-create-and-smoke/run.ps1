$ErrorActionPreference = 'Continue'
$s = Get-Content 'F:\code\gvideo-studio\app\server.py'
Write-Output '=== POST /api/jobs (66-128) ==='
$s[65..127] | ForEach-Object -Begin {$n=66} -Process { Write-Output ("$n`: $_"); $n++ }
Write-Output '=== POST /api/smoke (161-186) ==='
$s[160..185] | ForEach-Object -Begin {$n=161} -Process { Write-Output ("$n`: $_"); $n++ }

