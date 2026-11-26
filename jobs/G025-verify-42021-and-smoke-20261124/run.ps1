$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
Write-Output '=== 42021 HEALTH ==='
$up = Get-NetTCPConnection -LocalPort 42021 -State Listen -ErrorAction SilentlyContinue
Write-Output ("PORT_42021_LISTEN=" + [bool]$up)
try {
   $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:42021/' -TimeoutSec 10
   Write-Output ("HTTP_42021_ROOT=" + $r.StatusCode)
   $j = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs' -TimeoutSec 10
   $cnt = if ($j -is [array]) { $j.Count } elseif ($j.jobs) { $j.jobs.Count } else { 1 }
   Write-Output ("API_42021_JOBS=" + $cnt)
} catch {
   Write-Output ("HTTP_42021_ERR=" + $_.Exception.Message)
}
if (Test-Path "$g\server_42021.out.log") { Write-Output '--- 42021 OUT ---'; Get-Content "$g\server_42021.out.log" -Tail 6 }
if (Test-Path "$g\server_42021.err.log") { Write-Output '--- 42021 ERR ---'; Get-Content "$g\server_42021.err.log" -Tail 6 }
Write-Output '=== COPY-ONLY SMOKE TEST 20261124_232033 ==='
$sm = "$g\smoke_test_g025.py"
$lines = @(
   'import json, re, shutil, sys',
   'from pathlib import Path',
   'sys.path.insert(0, r"F:\code\gvideo-studio\app")',
   'from studio import config, source_visuals, footage, youtube_main, unreal_mrq',
   'cfg = config.load()',
   'jd = Path(cfg["jobs_dir"])',
   'orig = jd / "20261124_232033"',
   'print("ORIG_EXISTS:", orig.exists(), "PATH:", orig)',
   'meta_p = orig / "src" / "meta.json"',
   'if meta_p.exists():',
   '    m = json.loads(meta_p.read_text(encoding="utf-8", errors="ignore"))',
   '    print("ORIG_META:", {k: m.get(k) for k in ("title","own_footage","source_file","duration") if k in m})',
   'print("ORIG_CUES:", (orig / "src" / "source_cues.json").exists(), "SRC_VID:", (orig / "src" / "source_video.mp4").exists())',
   'copy_dir = Path(r"F:\code\gvideo-studio\smoke_20261124_232033")',
   '(copy_dir / "src").mkdir(parents=True, exist_ok=True)',
   'for fn in ("meta.json", "source_cues.json"):',
   '    if (orig / "src" / fn).exists(): shutil.copy2(orig / "src" / fn, copy_dir / "src" / fn)',
   'print("OWN_FOOTAGE_DETECTED:", source_visuals.own(copy_dir))',
   'if (copy_dir / "src" / "source_cues.json").exists():',
   '    sec = {"narration": "AI image generators are cheating on the Trump likeness test", "visual_prompt": "screen recording of Trump prompt in AI image generator"}',
   '    req = source_visuals.auto_request(copy_dir, sec, min_overlap=2 if source_visuals.own(copy_dir) else 3)',
   '    print("AUTO_REQUEST_MATCH:", req)',
   'print("UNREAL_FIND:", unreal_mrq.find_unreal(cfg))',
   'ft = Path(r"F:\code\gvideo-studio\app\studio\footage.py").read_text(encoding="utf-8")',
   'ym = Path(r"F:\code\gvideo-studio\app\studio\youtube_main.py").read_text(encoding="utf-8")',
   'print("CHECKS:", "fail_closed" in ft, "stock_ban_people" in ft, "youtube_main_allow_short_only" in ym)'
)
[System.IO.File]::WriteAllLines($sm, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
& $py $sm 2>&1

