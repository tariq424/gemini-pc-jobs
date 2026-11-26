$ErrorActionPreference = 'Continue'
function Log($m) { Write-Output ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }
function Write-Lines($path, $lines) {
   $dir = Split-Path -Parent $path
   if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
   [System.IO.File]::WriteAllLines($path, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
}

Log "G006 start"
$repo = 'F:\code\gvideo-studio'
if (-not (Test-Path (Join-Path $repo '.git'))) { Log "ERROR: $repo is not a git repo"; exit 1 }

# 1. Disk space & Epic Games Launcher check
Log "--- Disk Space ---"
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null } | ForEach-Object {
   Log ("Drive {0}: {1} GB free" -f $_.Name, [math]::Round($_.Free / 1GB, 1))
}
$epicPaths = @(
   'C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe',
   'C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe',
   'C:\Program Files\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe'
)
$epicExe = $epicPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($epicExe) { Log ("Epic Games Launcher found: " + $epicExe) } else { Log "Epic Games Launcher not installed yet (needs Epic sign-in + UAC to install UE5)" }

# 2. Scaffold ue_studio/GVideoStudio.uproject
$ueRoot = Join-Path $repo 'ue_studio'
$ueScripts = Join-Path $ueRoot 'Scripts'
New-Item -ItemType Directory -Path (Join-Path $ueRoot 'Content\Templates') -Force | Out-Null

Write-Lines (Join-Path $ueRoot 'GVideoStudio.uproject') @(
   '{',
   '  "FileVersion": 3,',
   '  "EngineAssociation": "5.5",',
   '  "Category": "",',
   '  "Description": "GVideoStudio preconfigured UE5 Movie Render Queue templates",',
   '  "Plugins": [',
   '    { "Name": "MovieRenderPipeline", "Enabled": true },',
   '    { "Name": "PythonScriptPlugin", "Enabled": true },',
   '    { "Name": "EditorScriptingUtilities", "Enabled": true },',
   '    { "Name": "MediaPlate", "Enabled": true }',
   '  ]',
   '}'
)

# 3. Scaffold ue_studio/Scripts/build_templates.py
Write-Lines (Join-Path $ueScripts 'build_templates.py') @(
   '"""Generate starter UE5 .umap templates: T_DataWall, T_ComparisonLadder, T_ProofScreen."""',
   'import unreal',
   '',
   'TEMPLATES = [',
   '    ("/Game/Templates/T_DataWall", "3D Data Wall"),',
   '    ("/Game/Templates/T_ComparisonLadder", "3D Comparison Ladder"),',
   '    ("/Game/Templates/T_ProofScreen", "3D Proof Screen"),',
   ']',
   '',
   'def create_starter_level(asset_path: str, label: str) -> None:',
   '    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):',
   '        unreal.log(f"[GVideoStudio] Template already exists: {asset_path}")',
   '        return',
   '    subsys = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)',
   '    subsys.new_level(asset_path)',
   '    cam = unreal.EditorLevelLibrary.spawn_actor_from_class(',
   '        unreal.CineCameraActor, unreal.Vector(-420.0, 0.0, 140.0), unreal.Rotator(0.0, 0.0, 0.0)',
   '    )',
   '    if cam: cam.set_actor_label("GVS_Camera")',
   '    t = unreal.EditorLevelLibrary.spawn_actor_from_class(',
   '        unreal.TextRenderActor, unreal.Vector(0.0, 0.0, 220.0), unreal.Rotator(0.0, 180.0, 0.0)',
   '    )',
   '    if t:',
   '        t.set_actor_label("GVS_Title")',
   '        c = t.get_component_by_class(unreal.TextRenderComponent)',
   '        if c: c.set_text(unreal.Text(label)); c.set_world_size(42.0)',
   '    s = unreal.EditorLevelLibrary.spawn_actor_from_class(',
   '        unreal.TextRenderActor, unreal.Vector(0.0, 0.0, 140.0), unreal.Rotator(0.0, 180.0, 0.0)',
   '    )',
   '    if s:',
   '        s.set_actor_label("GVS_Subtitle")',
   '        c = s.get_component_by_class(unreal.TextRenderComponent)',
   '        if c: c.set_text(unreal.Text("Parameterized MRQ Beat")); c.set_world_size(24.0)',
   '    l = unreal.EditorLevelLibrary.spawn_actor_from_class(unreal.PointLight, unreal.Vector(-200.0, 120.0, 280.0))',
   '    if l: l.set_actor_label("GVS_KeyLight")',
   '    subsys.save_current_level()',
   '    unreal.log(f"[GVideoStudio] Created starter template: {asset_path}")',
   '',
   'for p, lbl in TEMPLATES:',
   '    create_starter_level(p, lbl)'
)

# 4. Scaffold ue_studio/Scripts/mrq_render.py
Write-Lines (Join-Path $ueScripts 'mrq_render.py') @(
   '"""Headless UE5 Movie Render Queue (MRQ) beat renderer."""',
   'import json, os, unreal',
   '',
   'def main() -> None:',
   '    params_path = os.environ.get("GVS_MRQ_PARAMS", "")',
   '    if not params_path or not os.path.exists(params_path):',
   '        raise RuntimeError(f"GVS_MRQ_PARAMS not found: {params_path}")',
   '    with open(params_path, "r", encoding="utf-8") as f:',
   '        spec = json.load(f)',
   '    template = spec.get("template", "T_DataWall")',
   '    level_path = f"/Game/Templates/{template}"',
   '    if not unreal.EditorAssetLibrary.does_asset_exist(level_path):',
   '        raise RuntimeError(f"UE5 template level missing: {level_path}")',
   '    subsys = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)',
   '    subsys.load_level(level_path)',
   '    for actor in unreal.EditorLevelLibrary.get_all_level_actors():',
   '        lbl = actor.get_actor_label()',
   '        if lbl == "GVS_Title" and spec.get("title"):',
   '            c = actor.get_component_by_class(unreal.TextRenderComponent)',
   '            if c: c.set_text(unreal.Text(str(spec["title"])))',
   '        elif lbl == "GVS_Subtitle" and spec.get("subtitle"):',
   '            c = actor.get_component_by_class(unreal.TextRenderComponent)',
   '            if c: c.set_text(unreal.Text(str(spec["subtitle"])))',
   '    qs = unreal.get_editor_subsystem(unreal.MoviePipelineQueueEngineSubsystem)',
   '    q = qs.get_queue()',
   '    q.delete_all_jobs()',
   '    job = q.allocate_new_job(unreal.MoviePipelineExecutorJob)',
   '    job.job_name = spec.get("job_name", "gvs_beat")',
   '    job.map = unreal.SoftObjectPath(level_path)',
   '    cfg = job.get_configuration()',
   '    out = cfg.find_or_add_setting_by_class(unreal.MoviePipelineOutputSetting)',
   '    out.output_directory = unreal.DirectoryPath(spec["output_dir"])',
   '    out.output_resolution = unreal.IntPoint(int(spec.get("width", 1080)), int(spec.get("height", 1920)))',
   '    out.file_name_format = "frame_{frame_number}"',
   '    out.use_custom_frame_rate = True',
   '    out.output_frame_rate = unreal.FrameRate(int(spec.get("fps", 30)), 1)',
   '    aa = cfg.find_or_add_setting_by_class(unreal.MoviePipelineAntiAliasingSetting)',
   '    aa.spatial_sample_count = int(spec.get("aa_samples", 4))',
   '    aa.temporal_sample_count = 1',
   '    aa.override_anti_aliasing = True',
   '    cfg.find_or_add_setting_by_class(unreal.MoviePipelineDeferredPassBase)',
   '    cfg.find_or_add_setting_by_class(unreal.MoviePipelineImageSequenceOutput_PNG)',
   '    qs.render_queue_with_executor_instance(unreal.MoviePipelinePIEExecutor())',
   '',
   'if __name__ == "__main__":',
   '    main()'
)

# 5. Add app/studio/unreal_mrq.py
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
   '        if p.exists(): return p',
   '    env_p = os.environ.get("UNREAL_EDITOR_CMD")',
   '    if env_p and Path(env_p).exists(): return Path(env_p)',
   '    found = [Path(h) for r in SEARCH_ROOTS for h in glob.glob(os.path.join(r, "UE_*", "Engine", "Binaries", "Win64", "UnrealEditor-Cmd.exe"))]',
   '    if not found: return None',
   '    found.sort(reverse=True)',
   '    return found[0]',
   '',
   'def render_beat(spec: dict[str, Any], out_mp4: Path, cfg: Optional[dict[str, Any]] = None, log: Optional[Callable[[str]], None] = None, timeout_s: int = 600) -> Optional[Path]:',
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
   '        emit("unreal_mrq: no PNG frames produced; falling back")',
   '        return None',
   '        ff = subprocess.run(["ffmpeg", "-y", "-framerate", str(fps), "-i", str(frames_dir / "frame_%04d.png"), "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", str(out_mp4)], capture_output=True, text=True, timeout=180)',
   '        if ff.returncode != 0 or not out_mp4.exists():',
   '            emit("unreal_mrq: ffmpeg encode failed; falling back")',
   '            return None',
   '        emit(f"unreal_mrq: rendered {out_mp4.name} ({len(pngs)} frames)")',
   '        return out_mp4'
)
Log "Wrote ue_studio scaffold and app/studio/unreal_mrq.py"

# 6. Apply Phase 1 surgical fixes in Python
$patchFile = Join-Path $env:TEMP 'g006_patch.py'
Write-Lines $patchFile @(
   'from pathlib import Path',
   'repo = Path(r"F:\code\gvideo-studio")',
   'def patch_file(rel, old, new, label):',
   '    p = repo / rel',
   '    txt = p.read_text(encoding="utf-8")',
   '    if new in txt: print(f"[SKIP] {label}"); return',
   '    if old not in txt: print(f"[WARN] {label}: anchor not found"); return',
   '    p.write_text(txt.replace(old, new, 1), encoding="utf-8")',
   '    print(f"[OK]   {label}")',
   'patch_file("app/studio/source_visuals.py", "auto_request(job, sec, secs=clip_secs(cfg))", "auto_request(job, sec, min_overlap=2 if own(job) else 3, secs=clip_secs(cfg))", "source_visuals own_footage min_overlap=2")',
   'ym_p = repo / "app/studio/youtube_main.py"',
   'ym = ym_p.read_text(encoding="utf-8")',
   'if "youtube_main_allow_short_only" not in ym and "if \"long\" not in vids:" in ym:',
   '    out = []',
   '    done = False',
   '    for line in ym.splitlines():',
   '        if "if \"long\" not in vids:" in line and not done:',
   '            ind = line[:len(line) - len(line.lstrip())]',
   '            out.append(ind + "if \"long\" not in vids and not (cfg.get(\"youtube_main_allow_short_only\", True) and \"short\" in vids):")',
   '            done = True',
   '        else:',
   '            out.append(line)',
   '    ym_p.write_text("\n".join(out) + "\n", encoding="utf-8")',
   '    print("[OK]   youtube_main allow_short_only")',
   'else:',
   '    print("[SKIP] youtube_main allow_short_only")'
)
& python $patchFile 2>&1 | ForEach-Object { Log $_ }
[System.IO.File]::Delete($patchFile)

# 7. Compile check, commit, and push to tariq424/gvideo-studio
Log "--- Python compile check ---"
& python -m py_compile (Join-Path $repo 'app\studio\unreal_mrq.py') (Join-Path $repo 'app\studio\source_visuals.py') (Join-Path $repo 'app\studio\youtube_main.py') 2>&1 | ForEach-Object { Log $_ }
Log ("py_compile exit code: " + $LASTEXITCODE)
if ($LASTEXITCODE -eq 0) {
   & git -C $repo status --short 2>&1 | ForEach-Object { Log ("git status: " + $_) }
   & git -C $repo add ue_studio app/studio/unreal_mrq.py app/studio/source_visuals.py app/studio/youtube_main.py 2>&1 | ForEach-Object { Log $_ }
   & git -C $repo commit -m "Add UE5 MRQ scaffold/driver + own_footage overlap & short-only upload fixes" 2>&1 | ForEach-Object { Log $_ }
   & git -C $repo push origin main 2>&1 | ForEach-Object { Log $_ }
   Log ("git push exit code: " + $LASTEXITCODE)
   Log ("New HEAD: " + (& git -C $repo rev-parse --short HEAD))
}
Log "G006 done"

