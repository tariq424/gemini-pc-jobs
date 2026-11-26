$ErrorActionPreference = 'Continue'
function Log($m) { Write-Output ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }

Log "G003 start"

# 1. Check Google Drive for Desktop process & drive letters
$gdProc = Get-Process -Name 'GoogleDriveFS' -ErrorAction SilentlyContinue
Log ("GoogleDriveFS running: " + [bool]$gdProc)

$candidates = @(
   'G:\My Drive',
   'H:\My Drive',
   'I:\My Drive',
   (Join-Path $env:USERPROFILE 'Google Drive'),
   (Join-Path $env:USERPROFILE 'My Drive')
)
foreach ($d in (Get-PSDrive -PSProvider FileSystem)) {
   $md = Join-Path $d.Root 'My Drive'
   if ($candidates -notcontains $md) { $candidates += $md }
}

$driveRoot = $null
foreach ($c in $candidates) {
   if (Test-Path $c) {
       Log ("Found synced Google Drive path: " + $c)
       if (-not $driveRoot) { $driveRoot = $c }
   }
}

if ($driveRoot) {
   $outDir = Join-Path $driveRoot 'Gemini-Helper-Results'
   if (-not (Test-Path $outDir)) {
       New-Item -ItemType Directory -Path $outDir -Force | Out-Null
   }
   $resDir = 'F:\code\gemini-helper\jobs-repo\results'
   if (Test-Path $resDir) {
       $logs = Get-ChildItem -Path $resDir -Filter '*.log' -ErrorAction SilentlyContinue
       foreach ($f in $logs) {
           Copy-Item -Path $f.FullName -Destination (Join-Path $outDir ($f.BaseName + '.txt')) -Force
           Log ("Mirrored to Drive: " + $f.Name)
       }
       Log ("Total mirrored: " + $logs.Count)
   } else {
       Log ("Results folder not found: " + $resDir)
   }
} else {
   Log "No local Google Drive My Drive folder found on this PC."
}

Log "G003 done"

