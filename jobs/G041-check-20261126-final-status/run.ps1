$ErrorActionPreference = 'Continue'
$d = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs/20261126_125425' -TimeoutSec 15
Write-Output ('STATUS=' + $d.status + ' | STAGE=' + $d.stage + ' | ERR=' + $d.error)
if ($d.log) { $d.log | Select-Object -Last 12 | ForEach-Object { Write-Output ('LOG: ' + $_) } }
$jdir = 'F:\videos\video_studio\jobs\20261126_125425'
if (Test-Path $jdir) {
    Get-ChildItem $jdir -Recurse -Filter '*.mp4' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\src\\' } | Select-Object -First 10 | ForEach-Object { Write-Output ('MP4: ' + $_.FullName.Replace($jdir,'') + ' (' + [math]::Round($_.Length/1KB,1) + ' KB)') }
    $se = (Get-ChildItem "$jdir\short\source_excerpts" -ErrorAction SilentlyContinue | Measure-Object).Count
    $st = (Get-ChildItem "$jdir\short\stock" -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Output ("COUNTS: source_excerpts=$se stock=$st")
}

