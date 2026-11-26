$ErrorActionPreference = 'Continue'
$g = 'F:\code\gvideo-studio'
Write-Output '=== ROUTES ==='
Select-String -Path "$g\app\server.py" -Pattern '@app\.(post|route)\(' -Context 0,3 | ForEach-Object {
   Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim() + ' | ' + ($_.Context.PostContext[0].Trim()))
}
Write-Output '=== BPY HEADLESS ==='
$bl = 'C:\Users\Tarri\AppData\Local\Programs\Blender Foundation\blender-5.2.3-windows-x64\blender.exe'
& $bl --background --python-expr "import bpy; print('BPY_OK', bpy.app.version_string)" 2>&1 | Select-String 'BPY_OK|Error'

