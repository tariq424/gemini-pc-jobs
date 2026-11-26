$p = 'F:\code\gemini-helper\jobs-repo\results\G013-probe-42021-and-trump-ps.log'
if (Test-Path $p) { Get-Content $p } else { Write-Output 'G013 log missing' }

