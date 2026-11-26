$ErrorActionPreference = 'Continue'
$s = 'F:\code\gvideo-studio\app\studio'
Write-Output '=== LADDER FILES ==='
Get-ChildItem $s -Filter '*.py' | Select-Object -ExpandProperty Name | Sort-Object
Write-Output '=== LADDER REFERENCES (illustration/silhouette/cloudflare/unreal_mrq/own_footage) ==='
Select-String -Path "$s\*.py" -Pattern 'silhouette|illustration|cloudflare|unreal_mrq|own_footage|names a real person|an illustration fits' | ForEach-Object { Write-Output ($_.Filename + ':' + $_.LineNumber + ': ' + $_.Line.Trim()) } | Select-Object -First 80

