$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
if (Test-Path 'F:\code\video-studio-test\assets') {
    New-Item -ItemType Directory -Path "$g\assets" -Force | Out-Null
    Copy-Item 'F:\code\video-studio-test\assets\*' "$g\assets\" -Recurse -Force
    Write-Output ('COPIED_ASSETS=' + (Get-ChildItem "$g\assets" -File | Measure-Object).Count)
}
try {
    $r = Invoke-RestMethod -Uri 'http://127.0.0.1:42021/api/jobs/20261126_125425/resume' -Method Post -TimeoutSec 15
    Write-Output ('RESUME_42021=' + ($r | ConvertTo-Json -Compress))
} catch { Write-Output ('RESUME_ERR=' + $_.Exception.Message) }
New-Item -ItemType Directory -Path "$g\blender_studio" -Force | Out-Null
$p1 = @(
    'import bpy, json, math, os',
    'from pathlib import Path',
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
    'def add_text(txt, loc, size=0.42, mat=None, extrude=0.04):',
    '    bpy.ops.object.text_add(location=loc, rotation=(math.pi/2, 0, 0))',
    '    obj = bpy.context.active_object',
    '    obj.data.body = str(txt)[:80]',
    '    obj.data.size = size',
    '    obj.data.align_x = "CENTER"',
    '    obj.data.extrude = extrude',
    '    if mat: obj.data.materials.append(mat)',
    '    return obj'
)
[System.IO.File]::WriteAllLines("$g\blender_studio\render_template.py", [string[]]$p1, [System.Text.UTF8Encoding]::new($false))
Write-Output ('WROTE_PART1_LINES=' + (Get-Content "$g\blender_studio\render_template.py").Count)

