$ErrorActionPreference = 'Continue'
function Log($m) { Write-Output ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }

Log "G002 start"

# 1. Check gh CLI
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh -and (Test-Path 'C:\Program Files\GitHub CLI\gh.exe')) {
   $env:Path += ';C:\Program Files\GitHub CLI'
   $gh = Get-Command gh -ErrorAction SilentlyContinue
}
Log ("gh found: " + [bool]$gh)

# 2. Setup F:\code\gvideo-studio fork from video-studio-test (without touching live F:\code\video-studio-test)
$forkDir = 'F:\code\gvideo-studio'
$upstreamUrl = 'https://github.com/tariq424/video-studio-test.git'
$forkUrl = 'https://github.com/tariq424/gvideo-studio.git'

if (-not (Test-Path $forkDir)) {
   Log "Cloning video-studio-test into $forkDir ..."
   & git clone $upstreamUrl $forkDir 2>&1 | ForEach-Object { Log $_ }
} else {
   Log "$forkDir already exists; skipping clone"
}

if (Test-Path (Join-Path $forkDir '.git')) {
   if ($gh) {
       & gh repo view tariq424/gvideo-studio 2>&1 | Out-Null
       if ($LASTEXITCODE -ne 0) {
           Log "Creating public repo tariq424/gvideo-studio ..."
           & gh repo create tariq424/gvideo-studio --public --description "Gemini isolated fork of video-studio-test" 2>&1 | ForEach-Object { Log $_ }
       } else {
           Log "Repo tariq424/gvideo-studio already exists on GitHub"
       }
   } else {
       Log "WARNING: gh CLI not found; cannot auto-create GitHub repo"
   }

   & git -C $forkDir remote remove upstream 2>&1 | Out-Null
   & git -C $forkDir remote add upstream $upstreamUrl 2>&1 | Out-Null
   & git -C $forkDir remote set-url origin $forkUrl 2>&1 | Out-Null
   Log "Remotes configured:"
   & git -C $forkDir remote -v 2>&1 | ForEach-Object { Log $_ }

   Log "Pushing main to origin ($forkUrl) ..."
   & git -C $forkDir push -u origin main 2>&1 | ForEach-Object { Log $_ }
   Log ("git push exit code: " + $LASTEXITCODE)
   Log ("HEAD commit: " + (& git -C $forkDir rev-parse --short HEAD))
} else {
   Log "ERROR: $forkDir is not a valid git repo"
}

# 3. Check & update Antigravity CLI (agy)
$agy = Get-Command agy -ErrorAction SilentlyContinue
if ($agy) {
   Log ("Antigravity before: " + $agy.Source)
   & agy --version 2>&1 | ForEach-Object { Log ("agy --version (before): " + $_) }
} else {
   Log "agy not currently on PATH; checking install"
}

try {
   Log "Running official Antigravity CLI installer/updater..."
   $installScript = Invoke-RestMethod -Uri 'https://antigravity.google/cli/install.ps1' -TimeoutSec 60
   if ($installScript) {
       Invoke-Expression $installScript 2>&1 | ForEach-Object { Log ("agy-install: " + $_) }
   }
} catch {
   Log ("Antigravity update error: " + $_.Exception.Message)
}

$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
$agyAfter = Get-Command agy -ErrorAction SilentlyContinue
if ($agyAfter) {
   Log ("Antigravity after: " + $agyAfter.Source)
   & agy --version 2>&1 | ForEach-Object { Log ("agy --version (after): " + $_) }
} else {
   Log "agy still not found on PATH after update attempt"
}

# 4. Probe installed render tools (read-only)
Log "--- Tooling Probe ---"
foreach ($cmd in @('python', 'node', 'npm', 'blender', 'ffmpeg')) {
   $c = Get-Command $cmd -ErrorAction SilentlyContinue
   if ($c) { Log ("$cmd : " + $c.Source) } else { Log ("$cmd : not on PATH") }
}
$uePaths = @(
   'C:\Program Files\Epic Games',
   'D:\Program Files\Epic Games',
   'F:\Epic Games',
   'E:\Epic Games'
)
$ueFound = $false
foreach ($p in $uePaths) {
   if (Test-Path $p) {
       $dirs = Get-ChildItem -Path $p -Directory -Filter 'UE_*' -ErrorAction SilentlyContinue
       foreach ($d in $dirs) {
           Log ("UE found: " + $d.FullName)
           $ueFound = $true
       }
   }
}
if (-not $ueFound) { Log "UE5: not found in standard Epic Games folders" }

Log "G002 done"

