$ESXCLI = Get-EsxCli -VMHost osl9508.verit.dnv.com -V2
$ESXCLI.storage.core.adapter.list.Invoke() | Where {$_.Driver -eq "qlnativefc"}