$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
$hit = Get-ChildItem 'F:\' -Directory -Filter '20261124_232033' -Recurse -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
$origPath = if ($hit) { $hit.FullName } else { '' }
Write-Output ("FOUND_20261124=" + $origPath)
$sm = "$g\smoke_test_g027.py"
$lines = @(
   'import json, shutil, sys, tempfile',
   'from pathlib import Path',
   'from PIL import Image, ImageDraw',
   'sys.path.insert(0, r"F:\code\gvideo-studio\app")',
   'from studio import source_visuals, footage, unreal_mrq',
   'orig = Path(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1] else Path("")',
   'copy_dir = Path(r"F:\code\gvideo-studio\smoke_20261124_232033")',
   '(copy_dir / "src").mkdir(parents=True, exist_ok=True)',
   'if orig and orig.exists():',
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
   '    im = Image.new("RGB", (320, 180), (20, 20, 20))',
   '    d = ImageDraw.Draw(im)',
   '    for x in range(0, 320, 16):',
   '        for y in range(0, 180, 16):',
   '            if (x // 16 + y // 16) % 2 == 0: d.rectangle([x, y, x+15, y+15], fill=(235, 235, 235))',
   '    im.save(img)',
   '    orig_vis = footage._vision',
   '    footage._vision = lambda cfg, i, p: json.dumps({"seen": "office worker smiling at desk", "fits": "yes"})',
   '    ok1, why1, _ = footage.verify({"vet_provider": "local", "clip_check_v2": False}, {"id": "t1", "desc": "office worker", "query": "ai test"}, img, lambda m: None)',
   '    print("TEST_BAN_PEOPLE:", ok1, "|", why1)',
   '    def _boom(cfg, i, p): raise RuntimeError("ollama down")',
   '    footage._vision = _boom',
   '    ok2, why2, _ = footage.verify({"vet_provider": "local", "clip_check_v2": False}, {"id": "t2", "desc": "server rack", "query": "servers"}, img, lambda m: None)',
   '    print("TEST_FAIL_CLOSED:", ok2, "|", why2)',
   '    footage._vision = orig_vis',
   'print("TEST_UNREAL_FALLBACK:", unreal_mrq.find_unreal({}))'
)
[System.IO.File]::WriteAllLines($sm, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
& $py $sm $origPath 2>&1
$r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:42021/' -TimeoutSec 10
Write-Output ("HTTP_42021=" + $r.StatusCode)

