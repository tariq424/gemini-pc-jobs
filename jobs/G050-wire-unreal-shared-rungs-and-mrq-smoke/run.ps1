$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$py = 'F:\code\video-studio-test\app\env\Scripts\python.exe'
Write-Output '=== VERIFY UE 5.8.4 & UE_STUDIO ==='
$ue = Get-ChildItem 'D:\Epic Games' -Recurse -Filter 'UnrealEditor-Cmd.exe' -ErrorAction SilentlyContinue | Select-Object -First 5 -ExpandProperty FullName
Write-Output ('UE_CMD_GLOB=' + ($ue -join '; '))
if (Test-Path "$g\ue_studio") {
    Get-ChildItem "$g\ue_studio" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Output ('UE_STUDIO_FILE=' + $_.FullName.Replace("$g\", '')) }
} else { Write-Output 'UE_STUDIO_MISSING=True' }
$p = @(
    'import re',
    'from pathlib import Path',
    'S = Path(r"F:\code\gvideo-studio\app\studio")',
    '# 1. Add D:\Epic Games to SEARCH_ROOTS in unreal_mrq.py',
    'um_p = S / "unreal_mrq.py"; um = um_p.read_text(encoding="utf-8")',
    'if "D:\\\\Epic Games" not in um and r"D:\Epic Games" not in um:',
    '    if "SEARCH_ROOTS = [" in um:',
    '        um = um.replace("SEARCH_ROOTS = [", "SEARCH_ROOTS = [\n    Path(r\"D:\\Epic Games\"),", 1)'
    '    elif "SEARCH_ROOTS = (" in um:',
    '        um = um.replace("SEARCH_ROOTS = (", "SEARCH_ROOTS = (\n    Path(r\"D:\\Epic Games\"),", 1)'
    '    um_p.write_text(um, encoding="utf-8"); print("[OK] added D:\\Epic Games to unreal_mrq.SEARCH_ROOTS")',
    'else:',
    '    print("[SKIP] D:\\Epic Games already in unreal_mrq.py")',
    '# 2. Wire unreal into shared RUNGS registry (app/studio/rungs.py)',
    'rg_p = S / "rungs.py"; rg = rg_p.read_text(encoding="utf-8")',
    'if "\"unreal\"" not in rg:',
    '    rg = rg.replace("\"blender\",", "\"unreal\", \"blender\",", 1)',
    '    rg_p.write_text(rg, encoding="utf-8"); print("[OK] added unreal to app/studio/rungs.py SHARED_RUNG_NAMES")',
    '# 3. Wire _rung_unreal into qc_repair.py RUNGS',
    'qc_p = S / "qc_repair.py"; qc = qc_p.read_text(encoding="utf-8")',
    'if "def _rung_unreal(" not in qc:',
    '    u_fn = "\n".join([',
    '        "def _rung_unreal(ctx):",',
    '        "    \"\"\"Rung 3a: Unreal Engine 5 MRQ template render (falls back to Blender 5.2.3 if UE5 unavailable).\"\"\"",',
    '        "    from . import unreal_mrq",',
    '        "    w, h = (540, 960) if ctx.get(\"vert\") else (960, 540)",',
    '        "    spec = {\"template\": \"T_DataWall\", \"title\": (ctx.get(\"vo\") or \"\")[:40], \"subtitle\": ctx.get(\"key\", \"\"), \"width\": w, \"height\": h, \"fps\": 24, \"duration_s\": 2.5}",',
    '        "    out = _space(ctx, \"unreal\") / (ctx[\"key\"] + \"_ue.mp4\")",',
    '        "    clip = unreal_mrq.render_beat(spec, out, cfg=ctx.get(\"cfg\"), log=ctx.get(\"log\"))",',
    '        "    return _checked(ctx, clip, \"Unreal MRQ\") if clip else (None, None, \"no Unreal MRQ clip\")",',
    '        "",',
    '    ])',
    '    qc = qc.replace("def _rung_blender(ctx):", u_fn + "\ndef _rung_blender(ctx):", 1)',
    'if "(\"unreal\", _rung_unreal)" not in qc:',
    '    qc = qc.replace("(\"blender\", _rung_blender)", "(\"unreal\", _rung_unreal), (\"blender\", _rung_blender)", 1)',
    '    qc_p.write_text(qc, encoding="utf-8"); print("[OK] wired _rung_unreal into qc_repair.py RUNGS")',
    '# 4. Wire unreal rung ahead of blender in short.py using shared rungs',
    'sh_p = S / "short.py"; sh = sh_p.read_text(encoding="utf-8")',
    'anchor = "if v2 and cfg.get(\"blender_on\", True) and len(items) < n:"',
    'if anchor in sh and "unreal_mrq" not in sh:',
    '    u_blk = "\n".join([',
    '        "        if v2 and cfg.get(\"unreal_on\", True) and \"unreal\" in rungs.SHARED_RUNG_NAMES and len(items) < n:",',
    '        "            from . import unreal_mrq as _umrq",',
    '        "            _uspec = {\"template\": \"T_DataWall\", \"title\": (s.get(\"vo\") or \"\")[:40], \"subtitle\": s.get(\"id\", \"\"), \"width\": 540, \"height\": 960, \"fps\": 24, \"duration_s\": 2.5}",',
    '        "            _uclip = _safe(log, \"unreal\", lambda: _umrq.render_beat(_uspec, sd / \"unreal\" / (s[\"id\"] + \"_ue.mp4\"), cfg=cfg, log=log))",',
    '            if _uclip:',
    '                items.append({\"type\": \"video\", \"src\": _rel_sd(_uclip, sd), \"secs\": round(media.dur(_uclip), 2), \"rate\": 1.0, \"freeze\": True, \"tag\": \"GENERATED · UNREAL\", \"rung\": \"unreal\"})",',
    '            else:',
    '                log(\"  \" + s[\"id\"] + \": unreal rung skipped (no UE5 MRQ clip)\")",',
    '        " + anchor,',
    '    ])',
    '    sh = sh.replace("        " + anchor, u_blk, 1)',
    '    sh_p.write_text(sh, encoding="utf-8"); print("[OK] wired unreal rung into short.py")',
)
New-Item -ItemType Directory -Path "$g\tools" -Force | Out-Null
[System.IO.File]::WriteAllLines("$g\tools\patch_g050.py", [string[]]$p, [System.Text.UTF8Encoding]::new($false))
& $py "$g\tools\patch_g050.py" 2>&1
& $py -m py_compile "$g\app\studio\unreal_mrq.py" "$g\app\studio\rungs.py" "$g\app\studio\qc_repair.py" "$g\app\studio\short.py" 2>&1
Write-Output ('PY_COMPILE=' + $LASTEXITCODE)
if ($LASTEXITCODE -eq 0) {
    $t = @(
        'import sys',
        'from pathlib import Path',
        'sys.path.insert(0, r"F:\code\gvideo-studio\app")',
        'from studio import rungs, qc_repair, unreal_mrq',
        'assert "unreal" in rungs.SHARED_RUNG_NAMES',
        'assert rungs.SHARED_RUNG_NAMES.index("unreal") < rungs.SHARED_RUNG_NAMES.index("blender")',
        'assert any(n == "unreal" for n, _ in qc_repair.RUNGS)',
        'ue_exe = unreal_mrq.find_unreal()',
        'print("FIND_UNREAL:", ue_exe)',
        'assert ue_exe is not None and Path(ue_exe).exists(), "find_unreal() did not locate UnrealEditor-Cmd.exe"',
        'logs = []',
        'def cap(m): logs.append(str(m)); print("RUNG_LOG:", m)',
        'out = Path(r"F:\code\gvideo-studio\smoke_unreal_T_DataWall.mp4")',
        'spec = {"template": "T_DataWall", "title": "UE5 MRQ SMOKE", "subtitle": "SHARED RUNG TEST", "width": 540, "height": 960, "fps": 24, "duration_s": 1.0}',
        'res = unreal_mrq.render_beat(spec, out, cfg={}, log=cap, timeout_s=300)',
        'fired = "blender_fallback" if any("falling back to Blender" in x for x in logs) else ("unreal_mrq" if res and Path(res).exists() else "none")',
        'print("SMOKE_RESULT:", res, "SIZE:", Path(res).stat().st_size if res and Path(res).exists() else 0, "RUNG_FIRED:", fired)'
    )
    [System.IO.File]::WriteAllLines("$g\tools\test_g050.py", [string[]]$t, [System.Text.UTF8Encoding]::new($false))
& $py "$g\tools\test_g050.py" 2>&1
    Write-Output ('UNREAL_SMOKE_EXIT=' + $LASTEXITCODE)
    & git -C $g add app/studio/unreal_mrq.py app/studio/rungs.py app/studio/qc_repair.py app/studio/short.py tools/patch_g050.py tools/test_g050.py 2>&1
    & git -C $g commit -m "Wire UE 5.8.4 MRQ into shared RUNGS registry and add D:\Epic Games search root" 2>&1
    & git -C $g push origin main 2>&1
    Write-Output ('HEAD=' + (& git -C $g rev-parse --short HEAD))
}

