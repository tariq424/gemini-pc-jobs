$ErrorActionPreference = 'Continue'
function Log($m) { Write-Output ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }
function Write-Lines($path, $lines) {
   $dir = Split-Path -Parent $path
   if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
   [System.IO.File]::WriteAllLines($path, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
}

Log "G008 start"
$runner = 'F:\code\pc-helper\claude-runner\claude-run.ps1'
$inbox  = 'F:\code\pc-helper\claude-runner\inbox'
$inner  = Join-Path $inbox 'g008_form_setup.ps1'
$pyPath = 'F:\code\gemini-helper\setup_results_form.py'

Write-Lines $pyPath @(
   'import json, os, re, sys, time',
   'from pathlib import Path',
   'from urllib import parse, request',
   '',
   'WORK = Path(r"F:\code\gemini-helper")',
   'RES_DIR = WORK / "jobs-repo" / "results"',
   'CFG_OUT = WORK / "results-form.json"',
   '',
   'def find_profile():',
   '    candidates = [',
   '        os.environ.get("FLOW_PROFILE_DIR", ""),',
   '        r"F:\code\video-flow\.flow-profile",',
   '        r"F:\code\video-studio-test\.flow-profile",',
   '        r"F:\code\gvideo-studio\.flow-profile",',
   '        r"F:\code\video-studio-test\flow_profile",',
   '        str(Path(os.environ.get("LOCALAPPDATA", "")) / "Google" / "User Data"),',
   '    ]',
   '    for c in candidates:',
   '        if c and Path(c).exists():',
   '            print(f"[PROFILE] Found: {c}")',
   '            return c',
   '    return None',
   '',
   'def post_log(form_url, job_entry, log_entry, job_id, text):',
   '    data = parse.urlencode({job_entry: job_id, log_entry: text[:45000]}).encode("utf-8")',
   '    req = request.Request(form_url, data=data, method="POST")',
   '    with request.urlopen(req, timeout=30) as resp:',
   '        return resp.status',
   '',
   'def main():',
   '    try:',
   '        from playwright.sync_api import sync_playwright',
   '    except Exception as e:',
   '        print(f"[ERR] playwright import failed: {e}")',
   '        return 1',
   '    prof = find_profile()',
   '    if not prof:',
   '        print("[ERR] No signed-in Chrome/Flow profile found")',
   '        return 1',
   '    with sync_playwright() as p:',
   '        ctx = p.chromium.launch_persistent_context(prof, headless=False, viewport={"width": 1280, "height": 900})',
   '        page = ctx.new_page()',
   '        try:',
   '            page.goto("https://forms.new", wait_until="domcontentloaded", timeout=45000)',
   '            page.wait_for_timeout(5000)',
   '            print(f"[URL] {page.url}")',
   '            if "accounts.google.com" in page.url:',
   '                print("[ERR] Profile not signed into Google")',
   '                return 2',
   '            # Set title',
   '            title_box = page.locator("textarea[aria-label*=\"Form title\"], input[aria-label*=\"Document title\"]").first',
   '            title_box.click()',
   '            page.keyboard.press("Control+A")',
   '            page.keyboard.type("Gemini - Job Results")',
   '            page.wait_for_timeout(1000)',
   '            # Question 1: job_id',
   '            q1 = page.locator("textarea[aria-label*=\"Question\"], input[aria-label*=\"Question\"]").first',
   '            q1.click()',
   '            page.keyboard.press("Control+A")',
   '            page.keyboard.type("job_id")',
   '            page.wait_for_timeout(1000)',
   '            # Add Question 2: log_text',
   '            add_btn = page.locator("[aria-label=\"Add question\"]").first',
   '            add_btn.click()',
   '            page.wait_for_timeout(1200)',
   '            q2 = page.locator("textarea[aria-label*=\"Question\"], input[aria-label*=\"Question\"]").nth(1)',
   '            q2.click()',
   '            page.keyboard.press("Control+A")',
   '            page.keyboard.type("log_text")',
   '            page.wait_for_timeout(1500)',
   '            # Switch to Responses tab and link to Sheets',
   '            resp_tab = page.locator("div[role=\"tab\"]:has-text(\"Responses\")").first',
   '            resp_tab.click()',
   '            page.wait_for_timeout(2000)',
   '            link_btn = page.locator("button:has-text(\"Link to Sheets\"), [aria-label*=\"Link to Sheets\"]").first',
   '            if link_btn.count() > 0:',
   '                link_btn.click()',
   '                page.wait_for_timeout(1500)',
   '                create_btn = page.locator("button:has-text(\"Create\")").last',
   '                if create_btn.count() > 0:',
   '                    create_btn.click()',
   '                    page.wait_for_timeout(3000)',
   '            # Open preview to extract formResponse URL and entry IDs',
   '            prev_btn = page.locator("[aria-label=\"Preview\"]").first',
   '            with ctx.expect_page(timeout=15000) as new_p:',
   '                prev_btn.click()',
   '            vpage = new_p.value',
   '            vpage.wait_for_load_state("domcontentloaded", timeout=30000)',
   '            vpage.wait_for_timeout(2000)',
   '            vurl = vpage.url',
   '            html = vpage.content()',
   '            m_action = re.search(r"https://docs\\.google\\.com/forms/d/e/[^"'\\s]+/formResponse", html)',
   '            entries = re.findall(r"entry\\.(\\d+)", html)',
   '            entries = list(dict.fromkeys(entries))',
   '            print(f"[VIEW] {vurl}")',
   '            print(f"[ACTION] {m_action.group(0) if m_action else None} | [ENTRIES] {entries}")',
   '            if not m_action or len(entries) < 2:',
   '                print("[ERR] Could not extract formResponse or 2 entry IDs")',
   '                return 3',
   '            cfg = {"form_url": m_action.group(0), "job_entry": f"entry.{entries[0]}", "log_entry": f"entry.{entries[1]}"}',
   '            CFG_OUT.write_text(json.dumps(cfg, indent=2), encoding="utf-8")',
   '            print(f"[SAVED] {CFG_OUT}")',
   '            # Backfill existing logs',
   '            for lf in sorted(RES_DIR.glob("G*.log")):',
   '                st = post_log(cfg["form_url"], cfg["job_entry"], cfg["log_entry"], lf.stem, lf.read_text(encoding="utf-8", errors="ignore"))',
   '                print(f"[POST] {lf.stem} -> HTTP {st}")',
   '            return 0',
   '        finally:',
   '            ctx.close()',
   '',
   'if __name__ == "__main__":',
   '    sys.exit(main())'
)

Write-Lines $inner @(
   '$ErrorActionPreference = "Continue"',
   '& python "F:\code\gemini-helper\setup_results_form.py" 2>&1'
)

if (Test-Path $runner) {
   Log "Delegating to claude-run.ps1 ..."
   & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Script $inner -TimeoutSec 300 -Name 'G008-form-setup' 2>&1 | ForEach-Object { Log $_ }
} else {
   Log "Runner not found at $runner; running python directly"
   & python $pyPath 2>&1 | ForEach-Object { Log $_ }
}
Log "G008 done"

