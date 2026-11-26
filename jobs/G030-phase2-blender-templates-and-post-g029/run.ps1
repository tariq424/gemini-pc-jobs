$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
$formUrl = $null
foreach ($f in (Get-ChildItem 'F:\code\gemini-helper' -File | Where-Object { $_.Name -match 'poster|form' })) {
   $m = [regex]::Match((Get-Content $f.FullName -Raw), 'https://docs\.google\.com/forms/d/e/[A-Za-z0-9_-]+/formResponse')
   if ($m.Success) { $formUrl = $m.Value; break }
}
function Post-Form($jid, $text) {
   if (-not $formUrl) { return }
   if ($text.Length -gt 10000) { $text = $text.Substring(0, 10000) }
   $body = @{ 'entry.490326550' = $jid; 'entry.599161689' = $text }
   Invoke-WebRequest -UseBasicParsing -Uri $formUrl -Method Post -Body $body -TimeoutSec 30 | Out-Null
}
$g29log = 'F:\code\gemini-helper\jobs-repo\results\G029-copy-20261124-and-check-42021-render-api.log'
if (Test-Path $g29log) { Post-Form 'G029-copy-20261124-and-check-42021-render-api' (Get-Content $g29log -Raw) }
$out = New-Object System.Collections.Generic.List[string]
function Say($s) { Write-Output $s; $out.Add($s) }
New-Item -ItemType Directory -Path "$g\blender_studio" -Force | Out-Null
$rtLines = @(
   'import bpy, json, math, os',
   'from pathlib import Path',
   'def clear_scene():',
   '    bpy.ops.wm.read_factory_settings(use_empty=True)',
   'def make_mat(name, color, emit=0.0, rough=0.35, metal=0.2):',
   '    m = bpy.data.materials.new(name)',
   '    m.use_nodes = True',
   '    bsdf = m.node_tree.nodes.get("Principled BSDF")',
   '    bsdf.inputs["Base Color"].default_value = (*color, 1.0)',
   '    bsdf.inputs["Roughness"].default_value = rough',
   '    bsdf.inputs["Metallic"].default_value = metal',
   '    if emit > 0 and "Emission Strength" in bsdf.inputs:',
   '        bsdf.inputs["Emission Color"].default_value = (*color, 1.0)',
   '        bsdf.inputs["Emission Strength"].default_value = emit',
   '    return m',
   'def add_text(txt, loc, size=0.45, mat=None, extrude=0.04):',
   '    bpy.ops.object.text_add(location=loc, rotation=(math.pi/2, 0, 0))',
   '    obj = bpy.context.active_object',
   '    obj.data.body = str(txt)[:80]',
   '    obj.data.size = size',
   '    obj.data.align_x = "CENTER"',
   '    obj.data.extrude = extrude',
   '    if mat: obj.data.materials.append(mat)',
   '    return obj',
   'def main():',
   '    spec = json.loads(Path(os.environ["GVS_BLENDER_PARAMS"]).read_text(encoding="utf-8"))',
   '    clear_scene()',
   '    sc = bpy.context.scene',
   '    sc.render.engine = "BLENDER_EEVEE"',
   '    sc.render.resolution_x = int(spec.get("width", 540))',
   '    sc.render.resolution_y = int(spec.get("height", 960))',
   '    sc.render.fps = int(spec.get("fps", 24))',
   '    frames = max(12, int(float(spec.get("duration_s", 2.0)) * sc.render.fps))',
   '    sc.frame_start = 1; sc.frame_end = frames',
   '    w = bpy.data.worlds.new("GVSWorld"); sc.world = w; w.use_nodes = True',
   '    bg = w.node_tree.nodes.get("Background")',
   '    if bg: bg.inputs[0].default_value = (0.015, 0.02, 0.035, 1.0)',
   '    m_floor = make_mat("Floor", (0.04, 0.05, 0.08), rough=0.25, metal=0.6)',
   '    m_cyan = make_mat("Cyan", (0.12, 0.78, 1.0), emit=2.5, rough=0.2)',
   '    m_amber = make_mat("Amber", (1.0, 0.55, 0.15), emit=2.2, rough=0.2)',
   '    m_white = make_mat("White", (0.95, 0.97, 1.0), emit=1.4, rough=0.2)',
   '    m_slate = make_mat("Slate", (0.08, 0.1, 0.16), rough=0.35, metal=0.5)',
   '    bpy.ops.mesh.primitive_plane_add(size=30, location=(0, 0, -1.5))',
   '    bpy.context.active_object.data.materials.append(m_floor)',
   '    bpy.ops.object.light_add(type="AREA", location=(-4, -5, 4))',
   '    l1 = bpy.context.active_object; l1.data.energy = 600; l1.data.color = (0.3, 0.8, 1.0)',
   '    bpy.ops.object.light_add(type="AREA", location=(4, -4, 3))',
   '    l2 = bpy.context.active_object; l2.data.energy = 450; l2.data.color = (1.0, 0.6, 0.25)',
   '    tpl = spec.get("template", "T_DataWall")',
   '    add_text(spec.get("title", "AI PROOF"), (0, 0, 1.85), size=0.42, mat=m_white)',
   '    add_text(spec.get("subtitle", tpl), (0, 0, 1.25), size=0.22, mat=m_cyan, extrude=0.02)',
   '    if tpl == "T_ComparisonLadder":',
   '        vals = [0.6, 1.1, 1.7, 2.3]',
   '        for idx, h in enumerate(vals):',
   '            bpy.ops.mesh.primitive_cube_add(size=1, location=(-1.35 + idx*0.9, 0.3, -1.5 + h/2))',
   '            b = bpy.context.active_object; b.scale = (0.32, 0.32, h/2)',
   '            b.data.materials.append(m_amber if idx == 3 else m_cyan)',
   '    elif tpl == "T_ProofScreen":',
   '        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.2, -0.1))',
   '        frm = bpy.context.active_object; frm.scale = (1.6, 0.08, 1.0); frm.data.materials.append(m_slate)',
   '        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.14, -0.1))',
   '        scr = bpy.context.active_object; scr.scale = (1.5, 0.02, 0.9); scr.data.materials.append(m_cyan)',
   '    else:',
   '        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.5, 0.2))',
   '        wall = bpy.context.active_object; wall.scale = (2.4, 0.12, 1.8); wall.data.materials.append(m_slate)',
   '        for idx, h in enumerate([0.7, 1.3, 1.9]):',
   '            bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.9 + idx*0.9, -0.1, -1.5 + h/2))',
   '            col = bpy.context.active_object; col.scale = (0.28, 0.28, h/2)',
   '            col.data.materials.append(m_amber if idx == 2 else m_cyan)',
   '    bpy.ops.object.camera_add(location=(0, -7.2, 0.5), rotation=(math.pi/2 - 0.04, 0, 0))',
   '    cam = bpy.context.active_object; sc.camera = cam',
   '    cam.keyframe_insert(data_path="location", frame=1)',
   '    cam.location = (0.35, -5.8, 0.75)',
   '    cam.keyframe_insert(data_path="location", frame=frames)',
   '    sc.render.image_settings.file_format = "PNG"',
   '    sc.render.filepath = str(Path(spec["output_dir"]) / "frame_")',
   '    bpy.ops.render.render(animation=True)',
   'if __name__ == "__main__":',
   '    main()'
)
[System.IO.File]::WriteAllLines("$g\blender_studio\render_template.py", [string[]]$rtLines, [System.Text.UTF8Encoding]::new($false))
$drvLines = @(
   '"""Blender 5.2.3 headless 3D template driver sharing the unreal_mrq.py JSON contract."""',
   'from __future__ import annotations',
   'import glob, json, os, shutil, subprocess, tempfile',
   'from pathlib import Path',
   'from typing import Any, Callable, Optional',
   'REPO_ROOT = Path(__file__).resolve().parents[2]',
   'RENDER_SCRIPT = REPO_ROOT / "blender_studio" / "render_template.py"',
   'def find_blender(cfg: Optional[dict[str, Any]] = None) -> Optional[Path]:',
   '    if cfg and cfg.get("blender_exe") and Path(str(cfg["blender_exe"])).exists(): return Path(str(cfg["blender_exe"]))',
   '    w = shutil.which("blender")',
   '    if w: return Path(w)',
   '    pats = [os.path.expandvars(r"%LOCALAPPDATA%\Programs\Blender Foundation\blender-*\blender.exe"), r"C:\Program Files\Blender Foundation\Blender*\blender.exe"]',
   '    hits = [Path(h) for p in pats for h in glob.glob(p)]',
   '    hits.sort(reverse=True)',
   '    return hits[0] if hits else None',
   'def render_beat(spec: dict[str, Any], out_mp4: Path, cfg: Optional[dict[str, Any]] = None, log: Optional[Callable[[str], None]] = None, timeout_s: int = 300) -> Optional[Path]:',
   '    emit = log or (lambda _m: None)',
   '    bl = find_blender(cfg)',
   '    if not bl or not RENDER_SCRIPT.exists():',
   '        emit("blender_templates: blender or render_template.py missing")',
   '        return None',
   '    out_mp4 = Path(out_mp4); out_mp4.parent.mkdir(parents=True, exist_ok=True)',
   '    fps = int(spec.get("fps", 24))',
   '    with tempfile.TemporaryDirectory(prefix="gvs_bl_") as tmp:',
   '        fdir = Path(tmp) / "frames"; fdir.mkdir(parents=True, exist_ok=True)
   '        params = dict(spec); params["output_dir"] = str(fdir)',
   '        pfile = Path(tmp) / "params.json"; pfile.write_text(json.dumps(params, indent=2), encoding="utf-8")',
   '        env = os.environ.copy(); env["GVS_BLENDER_PARAMS"] = str(pfile)',
   '        proc = subprocess.run([str(bl), "--background", "--python", str(RENDER_SCRIPT)], env=env, capture_output=True, text=True, timeout=timeout_s)',
   '        pngs = sorted(fdir.glob("frame_*.png"))',
   '        if proc.returncode != 0 or not pngs:',
   '            emit(f"blender_templates: rc={proc.returncode} pngs={len(pngs)} err={proc.stderr[-300:]}")',
   '            return None',
   '        ff = subprocess.run(["ffmpeg", "-y", "-framerate", str(fps), "-i", str(fdir / "frame_%04d.png"), "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", str(out_mp4)], capture_output=True, text=True, timeout=120)',
   '        if ff.returncode != 0 or not out_mp4.exists(): return None',
   '        emit(f"blender_templates: rendered {out_mp4.name} ({len(pngs)} frames)")',
   '        return out_mp4'
)
[System.IO.File]::WriteAllLines("$g\app\studio\blender_templates.py", [string[]]$drvLines, [System.Text.UTF8Encoding]::new($false))
& $py -m py_compile "$g\app\studio\blender_templates.py" "$g\blender_studio\render_template.py" 2>&1 | ForEach-Object { Say $_ }
Say ("PY_COMPILE=" + $LASTEXITCODE)
$testRes = & $py -c "import sys; sys.path.insert(0,r'F:\code\gvideo-studio\app'); from pathlib import Path; from studio import blender_templates as bt; print('BLENDER:',bt.find_blender()); p=bt.render_beat({'template':'T_DataWall','title':'AI LIKENESS TEST','subtitle':'WORTH KNOWING 3D RUNG','width':540,'height':960,'fps':24,'duration_s':1.5}, Path(r'F:\code\gvideo-studio\smoke_blender_T_DataWall.mp4'), log=print); print('RENDERED:',p, p.stat().st_size if p and p.exists() else 0)" 2>&1
$testRes | ForEach-Object { Say $_ }
& git -C $g add blender_studio app/studio/blender_templates.py 2>&1 | ForEach-Object { Say $_ }
& git -C $g commit -m "Add Phase 2 Blender 5.2.3 3D templates (T_DataWall, T_ComparisonLadder, T_ProofScreen)" 2>&1 | ForEach-Object { Say $_ }
& git -C $g push origin main 2>&1 | ForEach-Object { Say $_ }
Say ("HEAD=" + (& git -C $g rev-parse --short HEAD))
Post-Form 'G030-phase2-blender-templates-and-post-g029' ($out -join "`n")

