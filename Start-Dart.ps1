$system32 = Join-Path $env:windir 'System32'

if (!(Test-Path (Join-Path $system32 'DartConfig8.dat'))) {
	Copy-Item (Join-Path $PSScriptRoot 'DartConfig8.dat') (Join-Path $system32 'DartConfig.dat')
}

. (Join-Path $PSScriptRoot 'RemoteRecovery.exe') -nomessage


$inv32 = Join-Path $PSScriptRoot 'inv32.xml'

# test if inv32 exists and exit if so? check running processes?
do {
	Start-Sleep -Seconds 5
} while (-not(Test-Path $inv32))

# TODO: parse & set env variables
Get-Content $inv32