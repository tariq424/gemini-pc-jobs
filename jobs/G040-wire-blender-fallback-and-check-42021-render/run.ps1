$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
$mrq = "$g\app\studio\unreal_mrq.py"
$txt = [System.IO.File]::ReadAllText($mrq)
$old = 'emit("unreal_mrq: UnrealEditor-Cmd.exe not installed; skipping UE5 rung")' + "`n" + '        return None'
$oldCr = 'emit("unreal_mrq: UnrealEditor-Cmd.exe not installed; skipping UE5 rung")' + "`r`n" + '        return None'
$rep = 'emit("unreal_mrq: UE5 not installed; falling back to Blender 5.2.3 template rung")' + "`n" + '        from . import blender_templates; return blender_templates.render_beat(spec, out_mp4, cfg=cfg, log=log, timeout_s=min(timeout_s, 300))'
if ($txt.Contains($oldCr)) { $txt = $txt.Replace($oldCr, $rep); Write-Output '[OK] wired blender fallback (CRLF)' }
elseif ($txt.Contains($old)) { $txt = $txt.Replace($old, $rep); Write-Output '[OK] wired blender fallback (LF)' }
else { Write-Output '[SKIP] blender fallback already wired or anchor absent' }
[System.IO.File]::WriteAllText($mrq, $txt, [System.Text.UTF8Encoding]::new($false))
& $py -m py_compile $mrq 2>&1
Write-Output ('PY_COMPILE=' + $LASTEXITCODE)
if ($LASTEXITCODE -eq 0) {
    & git -C $g add app/studio/unreal_mrq.py 2>&1
    & git -C $g commit -m "Wire Blender 5.2.3 templates as automatic fallback in unreal_mrq.py" 2>&1
    & git -C $g push origin main 2>&1
    Write-Output ('HEAD=' + (& git -C $g rev-parse --short HEAD))
}
Write-Output '=== 42021 JOB 20261126_125425 ==='
$d = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs/20261126_125425' -TimeoutSec 15
Write-Output ('STATUS=' + $d.status + ' | STAGE=' + $d.stage + ' | ERR=' + $d.error)
if ($d.log) { $d.log | Select-Object -Last 10 | ForEach-Object { Write-Output ('LOG: ' + $_) } }
$jdir = 'F:\videos\video_studio\jobs\20261126_125425'
if (Test-Path $jdir) {
    Get-ChildItem $jdir -Recurse -Filter '*.mp4' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\src\\' } | Select-Object -First 8 | ForEach-Object { Write-Output ('MP4: ' + $_.FullName.Replace($jdir,'') + ' (' + [math]::Round($_.Length/1KB,1) + ' KB)') }
    $se = (Get-ChildItem "$jdir\short\source_excerpts" -ErrorAction SilentlyContinue | Measure-Object).Count
    $st = (Get-ChildItem "$jdir\short\stock" -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Output ("COUNTS: source_excerpts=$se stock=$st")
}

