$ErrorActionPreference = 'Continue'
$files = Get-ChildItem 'F:\code\gemini-helper' -File | Where-Object { $_.Name -match 'poster|form' }
$url = $null
foreach ($f in $files) {
   $m = [regex]::Match((Get-Content $f.FullName -Raw), 'https://docs\.google\.com/forms/d/e/[A-Za-z0-9_-]+/formResponse')
   if ($m.Success) { $url = $m.Value; break }
}
$log = 'F:\code\gemini-helper\jobs-repo\results\G016-inspect-anchors-and-jobs.log'
if ($url -and (Test-Path $log)) {
   $txt = Get-Content $log -Raw
   if ($txt.Length -gt 12000) { $txt = $txt.Substring(0, 12000) }
   $body = @{ 'entry.490326550' = 'G016-inspect-anchors-and-jobs'; 'entry.599161689' = $txt }
   Invoke-WebRequest -UseBasicParsing -Uri $url -Method Post -Body $body -TimeoutSec 30 | Out-Null
   Write-Output 'SELF-POST OK'
} else {
   Write-Output ('MISSING url=' + [bool]$url + ' log=' + (Test-Path $log))
}

