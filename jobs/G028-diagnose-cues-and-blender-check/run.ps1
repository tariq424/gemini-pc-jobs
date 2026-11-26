$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$orig = 'F:\videos_test\jobs\20261124_232033'
Write-Output '=== BLENDER ==='
$bl = 'C:\Users\Tarri\AppData\Local\Programs\Blender Foundation\blender-5.2.3-windows-x64\blender.exe'
if (Test-Path $bl) { & $bl --version | Select-Object -First 2 } else { Write-Output 'BLENDER_NOT_AT_DEFAULT_PATH' }
Write-Output '=== ORIG FILES ==='
Get-ChildItem "$orig\short" -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Output ($_.Name + ' ' + $_.Length) }
Write-Output '=== CUES SAMPLE ==='
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
& $py -c "import json; from pathlib import Path; c=json.loads(Path(r'F:\videos_test\jobs\20261124_232033\src\source_cues.json').read_text(encoding='utf-8')); print('TYPE:',type(c).__name__,'LEN:',len(c)); print('SAMPLE:',c[:5])" 2>&1
Write-Output '=== AUTO_REQUEST ==='
$sv = Get-Content "$g\app\studio\source_visuals.py"
$i = ($sv | Select-String 'def auto_request\(' | Select-Object -First 1).LineNumber
if ($i) { $sv[($i-1)..([math]::Min($i+38, $sv.Count-1))] | ForEach-Object -Begin {$n=$i} -Process { Write-Output ("$n`: $_"); $n++ } }

