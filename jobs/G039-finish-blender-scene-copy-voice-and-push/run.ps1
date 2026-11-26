$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
$vf = Get-ChildItem 'F:\code\video-studio','F:\code\video-studio-test' -Filter 'voice_ref_*.wav' -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 5
if ($vf) {
    New-Item -ItemType Directory -Path "$g\assets" -Force | Out-Null
    $vf | ForEach-Object { Copy-Item $_.FullName "$g\assets\" -Force; Write-Output ('COPIED_VOICE=' + $_.FullName) }
}
$st = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs/20261126_125425' -TimeoutSec 15
Write-Output ('JOB_STATUS_BEFORE=' + $st.status + ' | STAGE=' + $st.stage)
if ($st.status -eq 'error') {
    Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs/20261126_125425/resume' -Method Post -TimeoutSec 15 | Out-Null
    Write-Output 'RESUMED_20261126_125425'
}
$p2 = @(
    'def main():',
    '    spec = json.loads(Path(os.environ["GVS_BLENDER_PARAMS"]).read_text(encoding="utf-8"))',
    '    bpy.ops.wm.read_factory_settings(use_empty=True)',
    '    sc = bpy.context.scene',
    '    sc.render.engine = "BLENDER_EEVEE"',
    '    sc.render.resolution_x = int(spec.get("width", 540))',
    '    sc.render.resolution_y = int(spec.get("height", 960))',
    '    sc.render.fps = int(spec.get("fps", 24))',
    '    frames = max(12, int(float(spec.get("duration_s", 1.5)) * sc.render.fps))',
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
    '    vals = [0.6, 1.1, 1.7, 2.3] if tpl == "T_ComparisonLadder" else [0.7, 1.3, 1.9]',
    '    if tpl == "T_ProofScreen":',
    '        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.2, -0.1))',
    '        f1 = bpy.context.active_object; f1.scale = (1.6, 0.08, 1.0); f1.data.materials.append(m_slate)',
    '    else:',
    '        for idx, h in enumerate(vals):',
    '            bpy.ops.mesh.primitive_cube_add(size=1, location=(-1.1 + idx*0.85, 0.1, -1.5 + h/2))',
    '            b = bpy.context.active_object; b.scale = (0.28, 0.28, h/2)',
    '            b.data.materials.append(m_amber if idx == len(vals)-1 else m_cyan)',
    '    bpy.ops.object.camera_add(location=(0, -7.2, 0.5), rotation=(math.pi/2 - 0.04, 0, 0))',
    '    cam = bpy.context.active_object; sc.camera = cam',
    '    cam.keyframe_insert(data_path="location", frame=1)',
    '    cam.location = (0.35, -5.8, 0.75); cam.keyframe_insert(data_path="location", frame=frames)',
    '    sc.render.image_settings.file_format = "PNG"',
    '    sc.render.filepath = str(Path(spec["output_dir"]) / "frame_")',
    '    bpy.ops.render.render(animation=True)',
'if __name__ == "__main__":',
    '    main()'
)
[System.IO.File]::AppendAllLines("$g\blender_studio\render_template.py", [string[]]$p2, [System.Text.UTF8Encoding]::new($false))
& $py -m py_compile "$g\blender_studio\render_template.py" "$g\app\studio\blender_templates.py" 2>&1
Write-Output ('PY_COMPILE=' + $LASTEXITCODE)
& $py -c "import sys; sys.path.insert(0,r'F:\code\gvideo-studio\app'); from pathlib import Path; from studio import blender_templates as bt; p=bt.render_beat({'template':'T_DataWall','title':'AI LIKENESS TEST','subtitle':'WORTH KNOWING 3D RUNG','width':540,'height':960,'fps':24,'duration_s':1.0}, Path(r'F:\code\gvideo-studio\smoke_blender_T_DataWall.mp4'), log=print); print('BLENDER_MP4:',p, p.stat().st_size if p and p.exists() else 0)" 2>&1
& git -C $g add blender_studio app/studio/blender_templates.py 2>&1
& git -C $g commit -m "Add Phase 2 Blender 5.2.3 3D templates (T_DataWall, T_ComparisonLadder, T_ProofScreen)" 2>&1
& git -C $g push origin main 2>&1
Write-Output ('HEAD=' + (& git -C $g rev-parse --short HEAD))

