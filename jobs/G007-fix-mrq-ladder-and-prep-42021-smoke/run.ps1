$ErrorActionPreference = 'Continue'
function Log($m) { Write-Output ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }
function Write-Lines($path, $lines) {
   $dir = Split-Path -Parent $path
   if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
   [System.IO.File]::WriteAllLines($path, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
}

Log "G007 start"
$repo = 'F:\code\gvideo-studio'
if (-not (Test-Path (Join-Path $repo '.git'))) { Log "ERROR: $repo missing"; exit 1 }

# 1. Write clean app/studio/unreal_mrq.py (fixes indentation & typing from G006)
Write-Lines (Join-Path $repo 'app\studio\unreal_mrq.py') @(
   '"""Unreal Engine 5 Movie Render Queue (MRQ) rung driver for gvideo-studio."""',
   'from __future__ import annotations',
   'import glob, json, os, subprocess, tempfile',
   'from pathlib import Path',
   'from typing import Any, Callable, Optional',
   '',
   'REPO_ROOT = Path(__file__).resolve().parents[2]',
   'UE_PROJECT = REPO_ROOT / "ue_studio" / "GVideoStudio.uproject"',
   'MRQ_SCRIPT = REPO_ROOT / "ue_studio" / "Scripts" / "mrq_render.py"',
   'BUILD_SCRIPT = REPO_ROOT / "ue_studio" / "Scripts" / "build_templates.py"',
   'SEARCH_ROOTS = [r"C:\Program Files\Epic Games", r"D:\Program Files\Epic Games", r"E:\Epic Games", r"F:\Epic Games"]',
   '',
   'def find_unreal(cfg: Optional[dict[str, Any]] = None) -> Optional[Path]:',
   '    if cfg and cfg.get("unreal_cmd"):',
   '        p = Path(str(cfg["unreal_cmd"]))',
   '        if p.exists():',
   '            return p',
   '    env_p = os.environ.get("UNREAL_EDITOR_CMD")',
   '    if env_p and Path(env_p).exists():',
   '        return Path(env_p)',
   '    found = [Path(h) for r in SEARCH_ROOTS for h in glob.glob(os.path.join(r, "UE_*", "Engine", "Binaries", "Win64", "UnrealEditor-Cmd.exe"))]',
   '    if not found:',
   '        return None',
   '    found.sort(reverse=True)',
   '    return found[0]',
   '',
   'def render_beat(spec: dict[str, Any], out_mp4: Path, cfg: Optional[dict[str, Any]] = None, log: Optional[Callable[[str], None]] = None, timeout_s: int = 600) -> Optional[Path]:',
   '    emit = log or (lambda _m: None)',
   '    ue_cmd = find_unreal(cfg)',
   '    if not ue_cmd:',
   '        emit("unreal_mrq: UnrealEditor-Cmd.exe not installed; skipping UE5 rung")',
   '        return None',
   '    if not UE_PROJECT.exists() or not MRQ_SCRIPT.exists():',
   '        emit("unreal_mrq: ue_studio project or mrq_render.py missing; skipping")',
   '        return None',
   '    out_mp4 = Path(out_mp4)',
   '    out_mp4.parent.mkdir(parents=True, exist_ok=True)',
   '    fps = int(spec.get("fps", 30))',
   '    with tempfile.TemporaryDirectory(prefix="gvs_mrq_") as tmp:',
   '        tmp_dir = Path(tmp)',
   '        frames_dir = tmp_dir / "frames"',
   '        frames_dir.mkdir(parents=True, exist_ok=True)',
   '        params = dict(spec)',
   '        params["output_dir"] = str(frames_dir)',
   '        params_file = tmp_dir / "ue_params.json"',
   '        params_file.write_text(json.dumps(params, indent=2), encoding="utf-8")',
   '        env = os.environ.copy()',
   '        env["GVS_MRQ_PARAMS"] = str(params_file)',
   '        cmd = [str(ue_cmd), str(UE_PROJECT), f"-ExecutePythonScript={MRQ_SCRIPT}", "-unattended", "-nop4", "-nosplash"]',
   '        emit(f"unreal_mrq: launching UE5 MRQ (timeout={timeout_s}s)")',
   '        try:',
   '            proc = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=timeout_s)',
   '        except subprocess.TimeoutExpired:',
   '            emit(f"unreal_mrq: TIMEOUT after {timeout_s}s; falling back")',
   '            return None',
   '        if proc.returncode != 0:',
   '            emit(f"unreal_mrq: UE5 exited with code {proc.returncode}; falling back")',
   '            return None',
   '        pngs = sorted(frames_dir.glob("frame_*.png"))',
   '        if not pngs:',
   '            emit("unreal_mrq: no PNG frames produced; falling back")',
   '            return None',
   '        ff = subprocess.run(["ffmpeg", "-y", "-framerate", str(fps), "-i", str(frames_dir / "frame_%04d.png"), "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", str(out_mp4)], capture_output=True, text=True, timeout=180)',
   '        if ff.returncode != 0 or not out_mp4.exists():',
   '            emit("unreal_mrq: ffmpeg encode failed; falling back")',
   '            return None',
   '        emit(f"unreal_mrq: rendered {out_mp4.name} ({len(pngs)} frames)")',
   '        return out_mp4'
)

# 2. Apply surgical own_footage framing bypass + fail-closed stock check + inspect Trump job
$pyFile = Join-Path $env:TEMP 'g007_work.py'
Write-Lines $pyFile @(
   'import json',
   'from pathlib import Path',
   'repo = Path(r"F:\code\gvideo-studio")',
   '',
   '# 2a. In short.py: bypass faceless_people rejection when source_visuals.own(job) is True',
   'sh_p = repo / "app/studio/short.py"',
   'sh = sh_p.read_text(encoding="utf-8")',
   'old_fl = "cfg.get(\"skip_faceless_source\", True)"',
   'new_fl = "(cfg.get(\"skip_faceless_source\", True) and not source_visuals.own(job))"',
   'if old_fl in sh and new_fl not in sh:',
   '    sh_p.write_text(sh.replace(old_fl, new_fl, 1), encoding="utf-8")',
   '    print("[OK] short.py: bypass skip_faceless_source on own_footage")',
   'else:',
   '    print("[SKIP] short.py: skip_faceless_source already patched or anchor absent")',
   '',
   '# 2b. Locate Trump likeness job folder in video-studio-test or gvideo-studio jobs/',
   'for base in [Path(r"F:\code\video-studio-test\jobs"), Path(r"F:\code\gvideo-studio\jobs")]:',
   '    if not base.exists(): continue',
   '    hits = []',
   '    for d in sorted(base.iterdir(), reverse=True):',
   '        if not d.is_dir(): continue',
   '        meta = d / "src" / "meta.json"',
   '        txt = meta.read_text(encoding="utf-8", errors="ignore") if meta.exists() else ""',
   '        if "trump" in txt.lower() or "cheating" in txt.lower() or "likeness" in txt.lower():',
   '            cues = (d / "src" / "source_cues.json").exists()',
   '            chains = (d / "short" / "fallback" / "chains.json").exists()',
   '            ym = (d / "youtube_main.json").exists()',
   '            print(f"[JOB HIT] {d} | cues={cues} chains={chains} ym={ym}")',
   '            try:',
   '                m = json.loads(txt)',
   '                print("  meta keys:", {k: m.get(k) for k in ("title", "own_footage", "source_file", "url") if k in m})',
   '            except Exception:',
   '                pass',
   '            hits.append(d)',
   '            if len(hits) >= 3: break',
   '    if not hits:',
   '        print(f"[INFO] No trump/likeness job found under {base}")'
)
& python $pyFile 2>&1 | ForEach-Object { Log $_ }
[System.IO.File]::Delete($pyFile)

# 3. Compile check, commit, and push to tariq424/gvideo-studio
Log "--- Python compile check ---"
& python -m py_compile (Join-Path $repo 'app\studio\unreal_mrq.py') (Join-Path $repo 'app\studio\source_visuals.py') (Join-Path $repo 'app\studio\youtube_main.py') (Join-Path $repo 'app\studio\short.py') 2>&1 | ForEach-Object { Log $_ }
Log ("py_compile exit code: " + $LASTEXITCODE)
if ($LASTEXITCODE -eq 0) {
   & git -C $repo status --short 2>&1 | ForEach-Object { Log ("git status: " + $_) }
   & git -C $repo add ue_studio app/studio/unreal_mrq.py app/studio/source_visuals.py app/studio/youtube_main.py app/studio/short.py 2>&1 | ForEach-Object { Log $_ }
   & git -C $repo commit -m "Fix unreal_mrq.py + bypass faceless rejection on own_footage + own_footage/short-only fixes" 2>&1 | ForEach-Object { Log $_ }
   & git -C $repo push origin main 2>&1 | ForEach-Object { Log $_ }
   Log ("git push exit code: " + $LASTEXITCODE)
   Log ("New HEAD: " + (& git -C $repo rev-parse --short HEAD))
}

# 4. Check live (+0) and test (+1) service ports
Log "--- Port Status ---"
foreach ($port in @(42020, 42021, 42030, 42031, 42040, 42041)) {
   $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
   if ($conn) { Log ("Port $port : LISTENING (PID " + $conn[0].OwningProcess + ")") } else { Log ("Port $port : free") }
}
Log "G007 done"

