$ErrorActionPreference = 'Continue'
function Log($m) { Write-Output ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }

Log "G009 start"
$b64 = @(
   'aW1wb3J0IGpzb24sIG9zLCByZSwgc3lzCmZyb20gcGF0aGxpYiBpbXBvcnQgUGF0aApmcm9tIHVy',
   'bGxpYiBpbXBvcnQgcGFyc2UsIHJlcXVlc3QKCldPUksgPSBQYXRoKHIiRjpcY29kZVxnZW1pbmkt',
   'aGVscGVyIikKUkVTX0RJUiA9IFdPUksgLyAiam9icy1yZXBvIiAvICJyZXN1bHRzIgpDRkdfT1VU',
   'ID0gV09SSyAvICJyZXN1bHRzLWZvcm0uanNvbiIKCmRlZiBmaW5kX3Byb2ZpbGUoKToKICAgIGxh',
   'ID0gb3MuZW52aXJvbi5nZXQoIkxPQ0FMQVBQREFUQSIsICIiKQogICAgY2FuZGlkYXRlcyA9IFsK',
   'ICAgICAgICBvcy5lbnZpcm9uLmdldCgiRkxPV19QUk9GSUxFX0RJUiIsICIiKSwKICAgICAgICBy',
   'IkY6XGNvZGVcdmlkZW8tZmxvd1wuZmxvdy1wcm9maWxlIiwKICAgICAgICByIkY6XGNvZGVcdmlk',
   'ZW8tc3R1ZGlvLXRlc3RcLmZsb3ctcHJvZmlsZSIsCiAgICAgICAgciJGOlxjb2RlXGd2aWRlby1z',
   'dHVkaW9cLmZsb3ctcHJvZmlsZSIsCiAgICAgICAgciJGOlxjb2RlXHZpZGVvLXN0dWRpby10ZXN0',
   'XGZsb3dfcHJvZmlsZSIsCiAgICAgICAgc3RyKFBhdGgobGEpIC8gIkdvb2dsZSIgLyAiQ2hyb21l',
   'IiAvICJVc2VyIERhdGEiKSwKICAgIF0KICAgIGZvciBjIGluIGNhbmRpZGF0ZXM6CiAgICAgICAg',
   'aWYgYyBhbmQgUGF0aChjKS5leGlzdHMoKToKICAgICAgICAgICAgcHJpbnQoZiJbUFJPRklMRV0g',
   'Rm91bmQ6IHtjfSIpCiAgICAgICAgICAgIHJldHVybiBjCiAgICByZXR1cm4gTm9uZQoKZGVmIHBv',
   'c3RfbG9nKGZvcm1fdXJsLCBqb2JfZW50cnksIGxvZ19lbnRyeSwgam9iX2lkLCB0ZXh0KToKICAg',
   'IGRhdGEgPSBwYXJzZS51cmxlbmNvZGUoe2pvYl9lbnRyeTogam9iX2lkLCBsb2dfZW50cnk6IHRl',
   'eHRbOjQ1MDAwXX0pLmVuY29kZSgidXRmLTgiKQogICAgcmVxID0gcmVxdWVzdC5SZXF1ZXN0KGZv',
   'cm1fdXJsLCBkYXRhPWRhdGEsIG1ldGhvZD0iUE9TVCIpCiAgICB3aXRoIHJlcXVlc3QudXJsb3Bl',
   'bihyZXEsIHRpbWVvdXQ9MzApIGFzIHJlc3A6CiAgICAgICAgcmV0dXJuIHJlc3Auc3RhdHVzCgpk',
   'ZWYgbWFpbigpOgogICAgdHJ5OgogICAgICAgIGZyb20gcGxheXdyaWdodC5zeW5jX2FwaSBpbXBv',
   'cnQgc3luY19wbGF5d3JpZ2h0CiAgICBleGNlcHQgRXhjZXB0aW9uIGFzIGU6CiAgICAgICAgcHJp',
   'bnQoZiJbRVJSXSBwbGF5d3JpZ2h0IGltcG9ydCBmYWlsZWQ6IHtlfSIpCiAgICAgICAgcmV0dXJu',
   'IDEKICAgIHByb2YgPSBmaW5kX3Byb2ZpbGUoKQogICAgaWYgbm90IHByb2Y6CiAgICAgICAgcHJp',
   'bnQoIltFUlJdIE5vIENocm9taXVtL0Zsb3cgcHJvZmlsZSBmb3VuZCIpCiAgICAgICAgcmV0dXJu',
   'IDEKICAgIHdpdGggc3luY19wbGF5d3JpZ2h0KCkgYXMgcDoKICAgICAgICBjdHggPSBwLmNocm9t',
   'aXVtLmxhdW5jaF9wZXJzaXN0ZW50X2NvbnRleHQocHJvZiwgaGVhZGxlc3M9RmFsc2UsIHZpZXdw',
   'b3J0PXsid2lkdGgiOiAxMjgwLCAiaGVpZ2h0IjogOTAwfSkKICAgICAgICBwYWdlID0gY3R4Lm5l',
   'd19wYWdlKCkKICAgICAgICB0cnk6CiAgICAgICAgICAgIHBhZ2UuZ290bygiaHR0cHM6Ly9mb3Jt',
   'cy5uZXciLCB3YWl0X3VudGlsPSJkb21jb250ZW50bG9hZGVkIiwgdGltZW91dD00NTAwMCkKICAg',
   'ICAgICAgICAgcGFnZS53YWl0X2Zvcl90aW1lb3V0KDUwMDApCiAgICAgICAgICAgIHByaW50KGYi',
   'W1VSTF0ge3BhZ2UudXJsfSIpCiAgICAgICAgICAgIGlmICJhY2NvdW50cy5nb29nbGUuY29tIiBp',
   'biBwYWdlLnVybDoKICAgICAgICAgICAgICAgIHByaW50KCJbRVJSXSBQcm9maWxlIG5vdCBzaWdu',
   'ZWQgaW50byBHb29nbGUiKQogICAgICAgICAgICAgICAgcmV0dXJuIDIKICAgICAgICAgICAgdGl0',
   'bGVfYm94ID0gcGFnZS5sb2NhdG9yKCd0ZXh0YXJlYVthcmlhLWxhYmVsKj0iRm9ybSB0aXRsZSJd',
   'LCBpbnB1dFthcmlhLWxhYmVsKj0iRG9jdW1lbnQgdGl0bGUiXScpLmZpcnN0CiAgICAgICAgICAg',
   'IHRpdGxlX2JveC5jbGljaygpCiAgICAgICAgICAgIHBhZ2Uua2V5Ym9hcmQucHJlc3MoIkNvbnRy',
   'b2wrQSIpCiAgICAgICAgICAgIHBhZ2Uua2V5Ym9hcmQudHlwZSgiR2VtaW5pIC0gSm9iIFJlc3Vs',
   'dHMiKQogICAgICAgICAgICBwYWdlLndhaXRfZm9yX3RpbWVvdXQoMTAwMCkKICAgICAgICAgICAg',
   'cTEgPSBwYWdlLmxvY2F0b3IoJ3RleHRhcmVhW2FyaWEtbGFiZWwqPSJRdWVzdGlvbiJdLCBpbnB1',
   'dFthcmlhLWxhYmVsKj0iUXVlc3Rpb24iXScpLmZpcnN0CiAgICAgICAgICAgIHExLmNsaWNrKCkK',
   'ICAgICAgICAgICAgcGFnZS5rZXlib2FyZC5wcmVzcygiQ29udHJvbCtBIikKICAgICAgICAgICAg',
   'cGFnZS5rZXlib2FyZC50eXBlKCJqb2JfaWQiKQogICAgICAgICAgICBwYWdlLndhaXRfZm9yX3Rp',
   'bWVvdXQoMTAwMCkKICAgICAgICAgICAgcGFnZS5sb2NhdG9yKCdbYXJpYS1sYWJlbD0iQWRkIHF1',
   'ZXN0aW9uIl0nKS5maXJzdC5jbGljaygpCiAgICAgICAgICAgIHBhZ2Uud2FpdF9mb3JfdGltZW91',
   'dCgxMjAwKQogICAgICAgICAgICBxMiA9IHBhZ2UubG9jYXRvcigndGV4dGFyZWFbYXJpYS1sYWJl',
   'bCo9IlF1ZXN0aW9uIl0sIGlucHV0W2FyaWEtbGFiZWwqPSJRdWVzdGlvbiJdJykubnRoKDEpCiAg',
   'ICAgICAgICAgIHEyLmNsaWNrKCkKICAgICAgICAgICAgcGFnZS5rZXlib2FyZC5wcmVzcygiQ29u',
   'dHJvbCtBIikKICAgICAgICAgICAgcGFnZS5rZXlib2FyZC50eXBlKCJsb2dfdGV4dCIpCiAgICAg',
   'ICAgICAgIHBhZ2Uud2FpdF9mb3JfdGltZW91dCgxNTAwKQogICAgICAgICAgICBwYWdlLmxvY2F0',
   'b3IoJ2Rpdltyb2xlPSJ0YWIiXTpoYXMtdGV4dCgiUmVzcG9uc2VzIiknKS5maXJzdC5jbGljaygp',
   'CiAgICAgICAgICAgIHBhZ2Uud2FpdF9mb3JfdGltZW91dCgyMDAwKQogICAgICAgICAgICBsaW5r',
   'X2J0biA9IHBhZ2UubG9jYXRvcignYnV0dG9uOmhhcy10ZXh0KCJMaW5rIHRvIFNoZWV0cyIpLCBb',
   'YXJpYS1sYWJlbCo9IkxpbmsgdG8gU2hlZXRzIl0nKS5maXJzdAogICAgICAgICAgICBpZiBsaW5r',
   'X2J0bi5jb3VudCgpID4gMDoKICAgICAgICAgICAgICAgIGxpbmtfYnRuLmNsaWNrKCkKICAgICAg',
   'ICAgICAgICBwYWdlLndhaXRfZm9yX3RpbWVvdXQoMTUwMCkKICAgICAgICAgICAgICAgIGNyZWF0',
   'ZV9idG4gPSBwYWdlLmxvY2F0b3IoJ2J1dHRvbjpoYXMtdGV4dCgiQ3JlYXRlIiknKS5sYXN0CiAg',
   'ICAgICAgICAgICAgICBpZiBjcmVhdGVfYnRuLmNvdW50KCkgPiAwOgogICAgICAgICAgICAgICAg',
   'ICAgIGNyZWF0ZV9idG4uY2xpY2soKQogICAgICAgICAgICAgICAgICAgIHBhZ2Uud2FpdF9mb3Jf',
   'dGltZW91dCgzMDAwKQogICAgICAgICAgICBwcmV2X2J0biA9IHBhZ2UubG9jYXRvcigdbGFyaWEt',
   'bGFiZWw9IlByZXZpZXciXScpLmZpcnN0CiAgICAgICAgICAgIHdpdGggY3R4LmV4cGVjdF9wYWdl',
   'KHRpbWVvdXQ9MTUwMDApIGFzIG5ld19wOgogICAgICAgICAgICAgICAgcHJldl9idG4uY2xpY2so',
   'KQogICAgICAgICAgICB2cGFnZSA9IG5ld19wLnZhbHVlCiAgICAgICAgICAgIHZwYWdlLndhaXRf',
   'Zm9yX2xvYWRfc3RhdGUoImRvbWNvbnRlbnRsb2FkZWQiLCB0aW1lb3V0PTMwMDAwKQogICAgICAg',
   'ICAgICB2cGFnZS53YWl0X2Zvcl90aW1lb3V0KDIwMDApCiAgICAgICAgICAgIGh0bWwgPSB2cGFn',
   'ZS5jb250ZW50KCkKICAgICAgICAgICAgbV9hY3Rpb24gPSByZS5zZWFyY2gocidodHRwczovL2Rv',
   'Y3NcLmdvb2dsZVwuY29tL2Zvcm1zL2QvZS9bXlx4MjJceDI3XHNdKy9mb3JtUmVzcG9uc2UnLCBo',
   'dG1sKQogICAgICAgICAgICBlbnRyaWVzID0gbGlzdChkaWN0LmZyb21rZXlzKHJlLmZpbmRhbGwo',
   'ciddedbnRyeVwuKFxkKykiLCBodG1sKSkpCiAgICAgICAgICAgIHByaW50KGYiW1ZJRVddIHt2',
   'cGFnZS51cmx9IikKICAgICAgICAgICAgcHJpbnQoZiJbQUNUSU9OXSB7bV9hY3Rpb24uZ3JvdXAo',
   'MCkgaWYgbV9hY3Rpb24gZWxzZSBOb25lfSB8IFtFTlRSSUVTXSB7ZW50cmllc30iKQogICAgICAg',
   'ICAgICBpZiBub3QgbV9hY3Rpb24gb3IgbGVuKGVudHJpZXMpIDwgMjoKICAgICAgICAgICAgICAg',
   'IHByaW50KCJbRVJSXSBDb3VsZCBub3QgZXh0cmFjdCBmb3JtUmVzcG9uc2Ugb3IgMiBlbnRyeSBJ',
   'RHMiKQogICAgICAgICAgICAgICAgcmV0dXJuIDMKICAgICAgICAgICAgY2ZnID0geyJmb3JtX3Vy',
   'bCI6IG1fYWN0aW9uLmdyb3VwKDApLCAiam9iX2VudHJ5IjogZiJlbnRyeS57ZW50cmllc30wIiwg',
   'ImxvZ19lbnRyeSI6IGYiZW50cnkue2VudHJpZXNbMV19In0KICAgICAgICAgICAgQ0ZHX09VVC53',
   'cml0ZV90ZXh0KGpzb24uZHVtcHMoY2ZnLCBpbmRlbnQ9MiksIGVuY29kaW5nPSJ1dGYtOCIpCiAg',
   'ICAgICAgICAgICBwcmludChmIltTQVZFRF0ge0NGR19PVVR9IikKICAgICAgICAgICAgZm9yIGxm',
   'IGluIHNvcnRlZChSRVNfRElSLmdsb2IoIkcqLmxvZyIpKToKICAgICAgICAgICAgICAgIHN0ID0g',
   'cG9zdF9sb2coY2ZnWyJmb3JtX3VybCJdLCBjZmdbImpvYl9lbnRyeSJdLCBjZmdbImxvZ19lbnRy',
   'eSJdLCBsZi5zdGVtLCBsZi5yZWFkX3RleHQoZW5jb2Rpbmc9InV0Zi04IiwgZXJyb3JzPSJpZ25v',
   'cmUiKSkKICAgICAgICAgICAgICAgIHByaW50KGYiW1BPU1RdIHtsZi5zdGVtfSAtPiBIVFRQIHtz',
   'dH0iKQogICAgICAgICAgICByZXR1cm4gMAogICAgICAgIGZpbmFsbHk6CiAgICAgICAgICAgIGN0',
   'eC5jbG9zZSgpCgppZiBfX25hbWVfXyA9PSAiX19tYWluX18iOgogICAgc3lzLmV4aXQobWFpbigp',
   'KQo='
) -join ''

$pyPath = 'F:\code\gemini-helper\setup_results_form.py'
[System.IO.File]::WriteAllBytes($pyPath, [System.Convert]::FromBase64String($b64))
Log ("Decoded " + $pyPath)

$runner = 'F:\code\pc-helper\claude-runner\claude-run.ps1'
$inner  = 'F:\code\pc-helper\claude-runner\inbox\g009_form_setup.ps1'
[System.IO.File]::WriteAllLines($inner, [string[]]@('$ErrorActionPreference = "Continue"', '& python "F:\code\gemini-helper\setup_results_form.py" 2>&1'), [System.Text.UTF8Encoding]::new($false))

if (Test-Path $runner) {
   Log "Running via claude-run.ps1 ..."
   & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Script $inner -TimeoutSec 300 -Name 'G009-form-setup' 2>&1 | ForEach-Object { Log $_ }
} else {
   & python $pyPath 2>&1 | ForEach-Object { Log $_ }
}
Log "G009 done"

