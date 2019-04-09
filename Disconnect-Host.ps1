V1 Test&Dev Migration-Host:

Get-vmhost osl9062.verit.dnv.com | Set-VMHost -State "Disconnected" -Confirm:$false
Get-VMHost osl9062.verit.dnv.com | Remove-VMHost -Confirm:$false


V1 Production Migration-Host:

Get-vmhost osl9143.verit.dnv.com | Set-VMHost -State "Disconnected" -Confirm:$false
Get-VMHost osl9143.verit.dnv.com | Remove-VMHost -Confirm:$false