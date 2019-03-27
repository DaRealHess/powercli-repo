$ESXCLI = Get-EsxCli -VMHost OSL9508.verit.dnv.com -V2
$ESXCLI.software.vib.get.Invoke() | Where {$_.Name -eq "qlnativefc"}