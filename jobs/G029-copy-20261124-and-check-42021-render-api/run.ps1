$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
$orig = 'F:\videos_test\jobs\20261124_232033'
$dst = 'F:\videos\video_studio\jobs\20261124_232033_gsmoke'
if (-not (Test-Path "$dst\src")) { New-Item -ItemType Directory -Path "$dst\src" -Force | Out-Null }
Copy-Item "$orig\src\*" "$dst\src\" -Force
foreach ($f in @('job.json','state.json','script.json')) {
   if (Test-Path "$orig\$f") { Copy-Item "$orig\$f" "$dst\$f" -Force }
}
Write-Output ("COPIED_SRC_FILES=" + ((Get-ChildItem "$dst\src" | Select-Object -ExpandProperty Name) -join ','))
& $py -c "import sys; sys.path.insert(0,r'F:\code\gvideo-studio\app'); from studio import source_visuals; from pathlib import Path; j=Path(r'F:\videos\video_studio\jobs\20261124_232033_gsmoke'); print('OWN:',source_visuals.own(j)); print('MATCH:',source_visuals.auto_request(j,{'vo':'First I went to Grok and asked him to make an image of President Trump'},min_overlap=2))" 2>&1
Write-Output '=== 42021 RENDER ROUTES ==='
Select-String -Path "$g\app\server.py" -Pattern '@app\.route\(' | Where-Object { $_.Line -match 'short|run|resume|start|job|smoke' } | Select-Object -First 20 | ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }
Write-Output '=== LOCAL SERVICES ==='
foreach ($u in @('http://127.0.0.1:42021/','http://127.0.0.1:11434/api/tags')) {
   try { $r = Invoke-WebRequest -UseBasicParsing -Uri $u -TimeoutSec 5; Write-Output ("UP $u => " + $r.StatusCode) }
   catch { Write-Output ("DOWN $u => " + $_.Exception.Message) }
}

