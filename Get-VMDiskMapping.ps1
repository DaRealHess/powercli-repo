# This script requires PowerCLI 4.0 U1
#
# Create VM Disk Mapping v2.1
# Created by Arnim van Lieshout
# Http://www.van-lieshout.com
#
# Did you ever got a request to extend a disk on a VM?
# Most probably you were asked to extend Windows disk number x
# Unfortunately this Windows disk number doesn't correspond to the virtual disk number of your VM.
# Finding out which virtual disk in the VM's settings corresponds to this Windows disk can be a cumbersome task. 
# Especially when you have multiple SCSI controllers and/or many disks attached to your VM
#
# This script matches Windows disks and their VMware virtual disk counterparts.
# It uses the Invoke-VMScript cmdlet to retrieve WMI information from the Windows guest, so there is no network connection needed to the VM
# This makes the script suitable for isolated guests too (Internal only network, DMZ, or otherwise seperated by firewall).
#
# Multiple vCenter- or ESX(i)-servers can be added to the $VCServerList array, so there's no need to know which host or vCenter manages your VM

# Initialize variables
# $VCServerList is a comma-separated list of vCenter- or ESX(i)-servers
$VCServerList = "glham1-isvc01.service.gl-group.internal"
$DiskInfo= @()

# Set Default Server Mode to Multiple
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false | Out-Null
# Connect to vCenter Server(s)
foreach ($VCServer in $VCServerList) {Connect-VIServer -Server "$VCServer" | Out-Null}
# Ask for VM to create diskmapping for
$Vm = Read-Host "Enter VMName to create disk mapping for"
if (($VmView = Get-View -ViewType VirtualMachine -Filter @{"Name" = $Vm})) {
	# Get the ESX host which the VM is currently running on
	$ESXHost = Get-VMHost -id $VmView.Summary.Runtime.Host
	# Get credentials for host and guest
	$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "root", "")
	$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials for $VM", "", "")

	#Get WMI info using Invoke-VMScript, so no network connection to the VM is needed
	$Error.Clear()
	$Out = Invoke-VMScript "wmic path win32_diskdrive get Index, SCSIPort, SCSITargetId /format:csv" -vm $VM -HostCredential $HostCred -GuestCredential $GuestCred -scripttype "bat"
	if (!$error) {
		#Export plaintext WMI disk info to temporary file and import it again using the Import-Csv CmdLet
		$FileName = [System.IO.Path]::GetTempFileName()
		$Out.Substring(2) > $FileName
		$WinDisks = Import-Csv $FileName
		Remove-Item $FileName
		#Create DiskMapping table
		foreach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
			foreach ($VirtualDiskDevice in ($VMView.Config.Hardware.Device | where {$_.ControllerKey -eq $VirtualSCSIController.Key})) {
				$VirtualDisk = "" | Select SCSIController, DiskName, SCSI_Id, DiskFile,  DiskSize, WindowsDisk
				$VirtualDisk.SCSIController = $VirtualSCSIController.DeviceInfo.Label
				$VirtualDisk.DiskName = $VirtualDiskDevice.DeviceInfo.Label
				$VirtualDisk.SCSI_Id = "$($VirtualSCSIController.BusNumber) : $($VirtualDiskDevice.UnitNumber)"
				$VirtualDisk.DiskFile = $VirtualDiskDevice.Backing.FileName
				$VirtualDisk.DiskSize = $VirtualDiskDevice.CapacityInKB * 1KB / 1GB
				# Match disks based on Controller and SCSI ID
				$DiskMatch = $WinDisks | ?{($_.SCSIPort – 1) -eq $VirtualSCSIController.BusNumber -and $_.SCSITargetID -eq $VirtualDiskDevice.UnitNumber}
				if ($DiskMatch){
					$VirtualDisk.WindowsDisk = "Disk $($DiskMatch.Index)"
				}
				else {Write-Host "No matching Windows disk found for SCSI id $($VirtualDisk.SCSI_Id)"}
				$DiskInfo += $VirtualDisk
			}
		}
		#Display DiskMapping table
		$DiskInfo | Out-GridView
	}
	else {Write-Host "Error Retrieving WMI info from guest"}
}
else {Write-Host "VM $Vm Not Found"}

Disconnect-VIServer * -Confirm:$false

