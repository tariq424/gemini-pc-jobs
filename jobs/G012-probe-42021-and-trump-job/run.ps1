$ErrorActionPreference = 'Continue'
$py = 'F:\code\gemini-helper\g012_probe.py'
Invoke-WebRequest -UseBasicParsing -Uri 'https://drive.google.com/uc?export=download&id=1TS6EOVM-ahtMxeOJ9igZQPVfVM1B-laN' -OutFile $py -TimeoutSec 60
$h = (Get-FileHash $py -Algorithm SHA256).Hash.ToLower()
Write-Output ("SHA256=" + $h)
if ($h -ne 'cc707e8ed475df4e019dcd0aee64cda813f50e94b3acb5c3a2ca14a1a5b4e2a8') { Write-Output 'HASH MISMATCH'; exit 1 }
& python $py 2>&1

