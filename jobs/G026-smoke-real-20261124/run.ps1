$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
$sm = "$g\smoke_test_g026.py"
$lines = @(
   'import json, shutil, sys, tempfile',
   'from pathlib import Path',
   'from PIL import Image',
   'sys.path.insert(0, r"F:\code\gvideo-studio\app")',
   'from studio import source_visuals, footage, youtube_main, unreal_mrq',
   'vcfg = Path(r"F:\code\video-studio-test\app\config.json")',
   'jdir = Path(json.loads(vcfg.read_text(encoding="utf-8")).get("jobs_dir", "")) if vcfg.exists() else Path(r"F:\videos\video_studio_test\jobs")',
   'orig = jdir / "20261124_232033"',
   'if not orig.exists():',
   '    for cand in [Path(r"F:\videos\video_studio_test\jobs"), Path(r"F:\code\video-studio-test\jobs"), Path(r"F:\videos\video_studio\jobs")]:',
   '        if (cand / "20261124_232033").exists(): orig = cand / "20261124_232033"; break',
   'print("REAL_ORIG:", orig, "EXISTS:", orig.exists())',
   'copy_dir = Path(r"F:\code\gvideo-studio\smoke_20261124_232033")',
   '(copy_dir / "src").mkdir(parents=True, exist_ok=True)',
   'if orig.exists():',
   '    for fn in ("meta.json", "source_cues.json"):',
   '        if (orig / "src" / fn).exists(): shutil.copy2(orig / "src" / fn, copy_dir / "src" / fn)',
   '    m = json.loads((copy_dir / "src" / "meta.json").read_text(encoding="utf-8", errors="ignore")) if (copy_dir / "src" / "meta.json").exists() else {}',
   '    print("ORIG_META:", {k: m.get(k) for k in ("title","own_footage","source_file","duration") if k in m})',
   '    print("HAS_CUES:", (copy_dir / "src" / "source_cues.json").exists(), "HAS_SRC_VID:", (orig / "src" / "source_video.mp4").exists())',
   '    print("OWN_DETECTED:", source_visuals.own(copy_dir))',
   '    if (copy_dir / "src" / "source_cues.json").exists():',
   '        cues = json.loads((copy_dir / "src" / "source_cues.json").read_text(encoding="utf-8"))',
   '        print("CUE_COUNT:", len(cues))',
   '        sec = {"narration": "AI image generators are cheating on the Trump likeness test", "visual_prompt": "Trump image generator prompt"}',
   '        print("AUTO_REQ_OWN:", source_visuals.auto_request(copy_dir, sec, min_overlap=2 if source_visuals.own(copy_dir) else 3))',
   'with tempfile.TemporaryDirectory() as td:',
   '    img = Path(td) / "sheet.jpg"',
   '    im = Image.new("RGB", (320, 180), (120, 130, 140))',
   '    for x in range(0, 320, 8): im.putpixel((x, 90), (255, 255, 255))',
   '    im.save(img)',
   '    orig_vis = footage._vision',
   '    footage._vision = lambda cfg, i, p: "{\"seen\": \"office worker smiling at desk\", \"fits\": \"yes\"}"',
   '    ok1, why1, _ = footage.verify({"vet_provider": "local", "clip_check_v2": False}, {"id": "t1", "desc": "office worker", "query": "ai test"}, img, lambda m: None)',
   '    print("TEST_BAN_PEOPLE:", ok1, why1)',
   '    def _boom(cfg, i, p): raise RuntimeError("ollama down")',
   '    footage._vision = _boom',
   '    ok2, why2, _ = footage.verify({"vet_provider": "local", "clip_check_v2": False}, {"id": "t2", "desc": "server rack", "query": "servers"}, img, lambda m: None)',
   '    print("TEST_FAIL_CLOSED:", ok2, why2)',
   '    footage._vision = orig_vis',
   'print("TEST_UNREAL_FALLBACK:", unreal_mrq.find_unreal({}))'
)
[System.IO.File]::WriteAllLines($sm, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
& $py $sm 2>&1
$r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:42021/' -TimeoutSec 10
Write-Output ("HTTP_42021=" + $r.StatusCode)

