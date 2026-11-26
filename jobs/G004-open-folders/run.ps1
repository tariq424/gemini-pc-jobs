$ErrorActionPreference = 'Continue'
function Log($m) { Write-Output ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }

Log "G004 start"
foreach ($p in @('F:\code\gemini-helper\jobs-repo\results', 'F:\code\gvideo-studio')) {
   if (Test-Path $p) {
       Start-Process explorer.exe -ArgumentList $p
       Log ("Opened in Explorer: " + $p)
   } else {
       Log ("Path not found: " + $p)
   }
}
Log "G004 done"

