$ErrorActionPreference = 'Continue'
Write-Output ("G001-bootstrap-check OK at " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Write-Output ("Host: " + $env:COMPUTERNAME + " | User: " + $env:USERNAME + " | PS: " + $PSVersionTable.PSVersion)
Write-Output ("WorkDir exists: " + (Test-Path 'F:\code\gemini-helper'))
Write-Output ("video-studio-test exists: " + (Test-Path 'F:\code\video-studio-test'))

