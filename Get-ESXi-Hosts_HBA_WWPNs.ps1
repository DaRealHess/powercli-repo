function Get-WWN {
#Set mandatory parameters for cluster and csvnameparam
([CmdletBinding()]
[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelinebyPropertyName=$True)]
$VMObject,
[Parameter(Mandatory=$true)]
[string]$csv
)

#Get cluster and all host HBA information and change format from Binary to hex
$list = $VMObject | Get-VMhost | Get-VMHostHBA -Type FibreChannel | Select @{N=”Datacenter”;E={get-datacenter -vmhost $_.vmhost[0]}}, @{N=”Cluster”;E={(get-vmhost $_.vmhost[0]).parent.name}},VMHost,Device,@{N=”WWN”;E={“{0:X}” -f $_.PortWorldWideName}} | Sort VMhost,Device

#Go through each row and put : between every 2 digits
foreach ($item in $list){
$item.wwn = (}) -join’:’
}

#Output CSV to current directory.
$list | export-csv -NoTypeInformation $csv.csv

}