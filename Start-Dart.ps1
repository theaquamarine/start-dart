# Start Microsoft DaRT Remote Recovery and store connection details to task sequence variables, if used in a task sequence. Useful as a boot image pre-start command, or running in a task sequence step.

# Usage:
# - Extract DaRT Toolsx64.cab from the DaRT install location to a folder
# - Add this script and a DaRT config file (DartConfig8.dat) to the folder
# - Set this script as a boot image's pre-start command with the folder as content
#     powershell.exe -NoProfile -NonInteractive -WindowStyle Minimized -File Start-Dart.ps1
# - Remote Recovery will be automatically started when the image boots

$system32 = Join-Path $env:windir 'System32'

if (!(Test-Path (Join-Path $system32 'DartConfig8.dat'))) {
	Copy-Item (Join-Path $PSScriptRoot 'DartConfig8.dat') (Join-Path $system32 'DartConfig.dat')
}

Start-Process (Join-Path $PSScriptRoot 'RemoteRecovery.exe') -ArgumentList '-nomessage' -WindowStyle Minimized

$inv32 = Join-Path $PSScriptRoot 'inv32.xml'

# test if inv32 exists and exit if so? check running processes?
$count = 0
while (-not(Test-Path $inv32) -and $count -lt 30) {
	Start-Sleep -Seconds 1
    $count++
}

[xml]$xml = Get-Content $inv32
$ticket = $xml.E.A.ID #DartTicket
Write-Host "DartTicket = $ticket"
$ips = $xml.E.C.T.L.N
Write-Host "DartIP = $ips"
$ports = $xml.E.C.T.L.P
Write-Host "DartPort = $ports"

try {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsenv.Value('DartTicket') = $ticket
} catch {}

for ($i = 0; $i -lt $ips.Count; $i++) {
    if ($tsenv) {$tsenv.Value(('DartIP{0:D3}' -f $i)) = $ips[$i]}
}

for ($i = 0; $i -lt $ports.Count; $i++) {
    if ($tsenv) {$tsenv.Value(('DartPort{0:D3}' -f $i)) = $ports[$i]}
}
