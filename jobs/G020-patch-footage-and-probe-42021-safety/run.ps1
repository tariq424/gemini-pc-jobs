$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
$fp = "$g\app\studio\footage.py"
$txt = [System.IO.File]::ReadAllText($fp)
$old1 = 'log(f"  vision check unavailable ({str(e)[:80]}); accepting {c[''id'']}"); return True, "", c["desc"]'
$new1 = 'if cfg.get("stock_fail_closed", True): return False, f"vision check unavailable ({str(e)[:60]}); failing closed", c["desc"]'
if ($txt.Contains($old1)) { $txt = $txt.Replace($old1, $new1); Write-Output '[OK] footage fail-closed' } else { Write-Output '[SKIP] fail-closed' }
$old2 = '    seen = str(j.get("seen") or c["desc"])[:160]'
$ban = '    if not subject and cfg.get("stock_ban_people", True) and re.search(r"\b(person|people|man|woman|men|women|face|faces|portrait|worker|workers|employee|businessman|businesswoman|smiling|talking|interview|presenter|human|crowd|colleague|meeting)\b", seen + " " + str(c.get("desc", "")), re.I): return False, "stock footage with people/faces banned", seen'
if ($txt.Contains($old2) -and -not $txt.Contains('stock_ban_people')) { $txt = $txt.Replace($old2, $old2 + "`n" + $ban); Write-Output '[OK] footage ban-people' } else { Write-Output '[SKIP] ban-people' }
[System.IO.File]::WriteAllText($fp, $txt, [System.Text.UTF8Encoding]::new($false))
& python -m py_compile $fp 2>&1
Write-Output ("PY_COMPILE=" + $LASTEXITCODE)
if ($LASTEXITCODE -eq 0) {
   & git -C $g add app/studio/footage.py 2>&1
   & git -C $g commit -m "Fail closed on stock vision errors and ban stock footage with people/faces" 2>&1
   & git -C $g push origin main 2>&1
   Write-Output ("HEAD=" + (& git -C $g rev-parse --short HEAD))
}
Write-Output '=== SV 190-216 ==='
(Get-Content "$g\app\studio\source_visuals.py")[189..215] | ForEach-Object -Begin {$n=190} -Process { Write-Output ("$n`: $_"); $n++ }
Write-Output '=== SERVER 735-772 ==='
(Get-Content "$g\app\server.py")[734..771] | ForEach-Object -Begin {$n=735} -Process { Write-Output ("$n`: $_"); $n++ }
Write-Output '=== TRUMP JOBS ==='
Get-ChildItem 'F:\videos\video_studio\jobs' -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 25 | ForEach-Object {
   $m = Join-Path $_.FullName 'src\meta.json'
   if (Test-Path $m) {
       $raw = Get-Content $m -Raw
       if ($raw -match 'trump|cheating|likeness') { Write-Output ("HIT: " + $_.FullName + " | " + $raw.Substring(0, [math]::Min(260, $raw.Length)).Replace("`r"," ").Replace("`n"," ")) }
   }
}

