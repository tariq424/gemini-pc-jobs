$ErrorActionPreference = 'Continue'
$py = 'F:\code\gemini-helper\setup_results_form.py'
Invoke-WebRequest -UseBasicParsing -Uri 'https://drive.google.com/uc?export=download&id=11rFuZsgJWP4ASl_qs9urZrbQw9NbyImO' -OutFile $py -TimeoutSec 60
$h = (Get-FileHash $py -Algorithm SHA256).Hash.ToLower()
Write-Output ("SHA256=" + $h)
if ($h -ne '34ccb9f10a97f7f2dc600ed2c8918cb002f3cccedeedb286480fefb0b8e1ead0') { Write-Output 'HASH MISMATCH'; exit 1 }
$inner = 'F:\code\pc-helper\claude-runner\inbox\g011_run.ps1'
[System.IO.File]::WriteAllLines($inner, [string[]]@('& python F:\code\gemini-helper\setup_results_form.py 2>&1'), [System.Text.UTF8Encoding]::new($false))
& powershell -NoProfile -ExecutionPolicy Bypass -File 'F:\code\pc-helper\claude-runner\claude-run.ps1' -Script $inner -TimeoutSec 300 -Name 'G011-form-setup'

