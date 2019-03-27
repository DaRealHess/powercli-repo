<#
.SYNOPSIS
   Script generates .csv file containing information about diskspace usage as seen from guest OS
.DESCRIPTION
   Script connects to vCenter server passed as parameter and enumerates virtual machines from datastore also passed as parameter.
   VM Templates and vms without Vmware Tools running are excluded cause it is impossible to retrieve disk usage from them.
   For remaining vms disk capacity, free space and percent of free space are retrieved and saved to .csv file, one vm per line.
.PARAMETER vCenterServer
   Mandatory parameter indicating vCenter server to connect to (FQDN or IP address)
.PARAMETER DatastoreName
   Mandatory parameter indicating datastore to generate report for
.EXAMPLE
   check-guestdiskspace.ps1 -vCenterServer vcenter.seba.local -DatastoreName Production-Datastore
.EXAMPLE
   check-guestdiskspace.ps1 -vcenter 10.10.10.1 -datastore development-datastore
.EXAMPLE
   check-guestdiskspace.ps1
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$vCenterServer,
	
   [Parameter(Mandatory=$True)]
   [string]$DatastoreName
)

#variables
$ScriptRoot = Split-Path $MyInvocation.MyCommand.Path
$csvfile = "$ScriptRoot\guest_diskspace_report_for_$($DatastoreName)_cluster.csv"
#array of objects containing disk information per vm
$all_guestOSdisks_info =@()

$vmsnapin = Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
$Error.Clear()
if ($vmsnapin -eq $null) 	
	{
	Add-PSSnapin VMware.VimAutomation.Core
	if ($error.Count -eq 0)
		{
		write-host "PowerCLI VimAutomation.Core Snap-in was successfully enabled." -ForegroundColor Green
		}
	else
		{
		write-host "ERROR: Could not enable PowerCLI VimAutomation.Core Snap-in, exiting script" -ForegroundColor Red
		Exit
		}
	}
else
	{
	Write-Host "PowerCLI VimAutomation.Core Snap-in is already enabled" -ForegroundColor Green
	}

$Error.Clear()
#connect vCenter from parameter
Connect-VIServer -Server $vCenterServer -ErrorAction SilentlyContinue | Out-Null

#execute only if connection successful
if ($error.Count -eq 0){
	write-host "Processing disk information for vms in datastore $DatastoreName" -ForegroundColor Yellow
	
	#get vm objects from datastore passed as parameter, exclude templates and machines where Vmware Tools are not running
	$vms_in_datastore = get-datastore -name $DatastoreName | get-vm | where-object { (-not $_.Config.Template) -and ($_.ExtensionData.Guest.ToolsRunningStatus -match ‘guestToolsRunning’) }

	#we need to sort vms so that vm with most number of disks is first, this is because information about disks will be displayed as columns 
	#and export-csv cmdlet formats the csv with the number of columns of the first object in the pipeline (if subsequent objects have more columns they are truncated (sic!))
	$vms_in_datastore_sorted = $vms_in_datastore | Select *, @{N="NumDisks";E={@($_.Guest.Disks.Length)}} | Sort-Object -Descending NumDisks

	foreach ($vm in $vms_in_datastore_sorted){
		#enumerate vms, create a PS Object with list of disk details for each vm	
		$single_guestOSdisk_info = New-Object PSObject
		$single_guestOSdisk_info | Add-Member -Name VmName -Value $vm.name -MemberType NoteProperty
		$index = 0
		
		$guest_disks = $vm.guest.disks | Sort-Object -Property path
		
		foreach ($disk in $guest_disks){
			$single_guestOSdisk_info | Add-Member -Name "Disk$($index) path" -MemberType NoteProperty -Value $disk.Path
			$single_guestOSdisk_info | Add-Member -Name "Disk$($index) Capacity(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.Capacity/ 1MB))
			$single_guestOSdisk_info | Add-Member -Name "Disk$($index) FreeSpace(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.FreeSpace / 1MB))
			$single_guestOSdisk_info | Add-Member -Name "Disk$($index) FreeSpace(%)" -MemberType NoteProperty -Value ([math]::Round(((100* ($disk.FreeSpace))/ ($disk.Capacity)),0))
			$index++
			
 		}
		#add object with disk information to general collection
		$all_guestOSdisks_info += $single_guestOSdisk_info
	}

	#export to CSV
	$all_guestOSdisks_info | Export-Csv -Path $csvfile -NoTypeInformation

	Write-Host "Report successfully created in $($csvfile)" -ForegroundColor Green

	#disconnect vCenter
	Disconnect-VIServer -Confirm:$false
}
else{
Write-Host "Error connecting vCenter server $vCenterServer, exiting" -ForegroundColor Red
}