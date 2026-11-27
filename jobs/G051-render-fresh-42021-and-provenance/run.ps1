$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
Write-Output ('HEAD=' + (& git -C $g rev-parse --short HEAD))
$conn = Get-NetTCPConnection -LocalPort 42021 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($conn) {
    $oldPid = $conn.OwningProcess
    Write-Output ('RESTARTING_42021_OLD_PID=' + $oldPid)
    & $py -c "import os, signal; os.kill($oldPid, signal.SIGTERM)" 2>&1
    Start-Sleep -Seconds 3
}
$env:PORT = '42021'
$env:VIDEO_STUDIO_PORT = '42021'
$outLog = "$g\server_42021.out.log"
$errLog = "$g\server_42021.err.log"
$proc = Start-Process -FilePath $py -ArgumentList '-u','server.py','--port','42021' -WorkingDirectory "$g\app" -RedirectStandardOutput $outLog -RedirectStandardError $errLog -PassThru -WindowStyle Hidden
Write-Output ('STARTED_42021_PID=' + $proc.Id)
$ready = $false
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Seconds 2
    try {
        $r = Invoke-WebRequest -Uri 'http://127.0.0.1:42021/api/jobs' -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -eq 200) { $ready = $true; break }
    } catch {}
}
Write-Output ('SERVER_42021_READY=' + $ready)
if (-not $ready) {
    if (Test-Path $errLog) { Get-Content $errLog -Tail 20 | ForEach-Object { Write-Output ('ERR: ' + $_) } }
    exit 1
}
$runPy = @(
'import json, sys, time, urllib.request'
'from pathlib import Path'
'import requests'
'cands = ['
'    Path(r"F:\videos_test\jobs\20261124_232033\src\2026-11-24_22-51-56.mp4"),'
'    Path(r"F:\videos\video_studio\jobs\20261124_232033_gsmoke\src\2026-11-24_22-51-56.mp4"),'
']'
'src = next((p for p in cands if p.exists()), None)'
'assert src is not None, "source mp4 not found"'
'print("SRC_MP4:", src)'
'with open(src, "rb") as fh:'
'    resp = requests.post('
'        "http://127.0.0.1:42021/api/jobs",'
'        files={"file": (src.name, fh, "video/mp4")},'
'        data={'
'            "title": "AI Image Models Are Cheating",'
'            "mode": "smoke",'
'            "own_source": "true",'
'            "auto_approve": "true",'
'            "visual_review": "never",'
'            "captions": "true",'
'        },'
'        timeout=120,'
'    )'
'resp.raise_for_status()'
'info = resp.json()'
'jid = info.get("id") or info.get("job_id")'
'print("CREATED_JOB_ID:", jid)'
'assert jid, f"no job id in {info}"'
'last_stage = ""'
't0 = time.time()'
'status, stage, err = "", "", ""'
'data = {}'
'while time.time() - t0 < 1320:'
'    r = requests.get(f"http://127.0.0.1:42021/api/jobs/{jid}", timeout=15)'
'    data = r.json()'
'    status = data.get("status", "")'
'    stage = data.get("stage", "")'
'    err = data.get("error", "")'
'    if stage != last_stage:'
'        print(f"STAGE_CHANGE [{int(time.time()-t0)}s]: status={status} stage={stage}")'
'        last_stage = stage'
'    if status in ("finished", "error", "failed", "cancelled"):'
'        break'
'    time.sleep(15)'
'print(f"FINAL: id={jid} status={status} stage={stage} err={err}")'
'jdir = Path(r"F:\videos\video_studio\jobs") / jid'
'mp4s = [p for p in jdir.rglob("*.mp4") if "\\src\\" not in str(p)] if jdir.exists() else []'
'for m in sorted(mp4s):'
'    print(f"MP4: {m} ({m.stat().st_size/1048576:.2f} MB)")'
'print("=== PROVENANCE TABLE ===")'
'fb_f = jdir / "short" / "fallback.json"'
'if fb_f.exists():'
'    fb = json.loads(fb_f.read_text(encoding="utf-8"))'
'    for bid, items in sorted(fb.items()):'
'        if not isinstance(items, list): continue'
'        for idx, it in enumerate(items, 1):'
'            rung = it.get("rung") or it.get("tag") or it.get("type") or "unknown"'
'            ts = it.get("timestamp")'
'            ts_s = f"{float(ts):.2f}s" if ts is not None else "-"'
'            src_s = it.get("src") or it.get("site") or it.get("g", {}).get("kind", "")'
'            print(f"BEAT={bid} | SLOT={idx} | RUNG={rung} | TS={ts_s} | SRC={src_s}")'
'ch_f = jdir / "short" / "fallback" / "chains.json"'
'if ch_f.exists():'
'    ch = json.loads(ch_f.read_text(encoding="utf-8"))'
'    print("=== RUNG CHAINS ===")'
'    for bid, info_b in sorted(ch.items()):'
'        print(f"CHAIN {bid}: {json.dumps(info_b)[:320]}")'
'if status != "finished":'
'    for ln in (data.get("log") or [])[-15:]:'
'        print("LOG:", ln)'
'    sys.exit(1)'
)
[System.IO.File]::WriteAllLines("$g\tools\run_g051_render.py", [string[]]$runPy, [System.Text.UTF8Encoding]::new($false))
& $py "$g\tools\run_g051_render.py" 2>&1
Write-Output ('RENDER_EXIT=' + $LASTEXITCODE)

