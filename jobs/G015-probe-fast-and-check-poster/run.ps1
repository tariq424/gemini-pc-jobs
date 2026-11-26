$ErrorActionPreference = 'Continue'
$g13 = 'F:\code\gemini-helper\jobs-repo\results\G013-probe-42021-and-trump-ps.log'
if (Test-Path $g13) { Write-Output '--- G013 ---'; Get-Content $g13 }
Write-Output '--- PORTS ---'
netstat -ano | Select-String ':42020|:42021|:42030|:42031|:42040|:42041' | Select-String 'LISTENING'
Write-Output '--- BAT & DIRS ---'
$bat = 'F:\code\gvideo-studio\start-video-studio.bat'
if (Test-Path $bat) { Get-Content $bat }
Get-ChildItem 'F:\code\video-studio-test' -Directory | Select-Object -ExpandProperty Name
Write-Output '--- POSTER ---'
$post = 'F:\code\gemini-helper\gemini-results-poster.ps1'
if (Test-Path $post) { Select-String -Path $post -Pattern 'exit|results|posted|Sleep|Get-ChildItem' | Select-Object -First 15 }

