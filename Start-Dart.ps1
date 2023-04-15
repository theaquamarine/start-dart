$system32 = Join-Path $env:windir 'System32'

if (!(Test-Path (Join-Path $system32 'DartConfig8.dat'))) {
	Copy-Item (Join-Path $PSScriptRoot 'DartConfig8.dat') (Join-Path $system32 'DartConfig.dat')
}

. (Join-Path $PSScriptRoot 'RemoteRecovery.exe') -nomessage


$inv32 = Join-Path $PSScriptRoot 'inv32.xml'

# test if inv32 exists and exit if so? check running processes?
$count = 0
do {
	Start-Sleep -Seconds 5
    $count++
} while (-not(Test-Path $inv32) -and $count -lt 5)

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
