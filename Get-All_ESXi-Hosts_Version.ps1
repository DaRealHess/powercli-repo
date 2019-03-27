$List = @()
$VMHosts = Get-VMHost
foreach ($VMHost in $VMHosts) {
    $VMHostName = $VMhost.Name
    $esxcli = $VMHost | Get-EsxCli
    $List += $esxcli.system.version.get() | Select-Object @{N="VMHostName"; E={$VMHostName}}, *
}
$List | Sort VMHostName | FT -AutoSize