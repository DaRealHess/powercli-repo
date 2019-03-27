$ESXCLI = Get-EsxCli -VMHost osl9502.verit.dnv.com -V2
$ESXCLI.storage.filesystem.list.Invoke()| Where {$_.Type -eq "VMFS-5"}