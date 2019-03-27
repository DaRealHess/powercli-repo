$vm=v-man
$vmview = Get-View -ViewType VirtualMachine -Filter @{"Name" = $vm}

foreach ($VirtualSCSIController in ($vmview.Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
 foreach ($VirtualDiskDevice in ($vmview.Config.Hardware.Device | where {$_.ControllerKey -eq $VirtualSCSIController.Key})) {
 Write-Host SCSI" ("$($VirtualSCSIController.BusNumber):$($VirtualDiskDevice.UnitNumber)")" $VirtualDiskDevice.DeviceInfo.Label
 }
}