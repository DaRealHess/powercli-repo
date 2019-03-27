$my_vm           = get-vm("glham1-isadmu3")
$VMView = $my_vm | get-view
$VMSummaries = @()

# Now loop thru all the SCSI controllers on the system and find those that match the Controller and Target

ForEach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | Where {$_.DeviceInfo.Label -match "SCSI Controller"}))
      {
      ForEach ($VirtualDiskDevice  in ($VMView.Config.Hardware.Device | Where {$_.ControllerKey -eq $VirtualSCSIController.Key}))
         {
         $VMSummary = "" | Select VM, HostName, PowerState, DiskFile, DiskName, DiskSize, SCSIController, SCSITarget
         $VMSummary.VM = $VM.Name
         $VMSummary.HostName = $VMView.Guest.HostName
         $VMSummary.PowerState = $VM.PowerState
         $VMSummary.DiskFile = $VirtualDiskDevice.Backing.FileName
         $VMSummary.DiskName = $VirtualDiskDevice.DeviceInfo.Label
         $VMSummary.DiskSize = $VirtualDiskDevice.CapacityInKB * 1KB
         $VMSummary.SCSIController = $VirtualSCSIController.BusNumber
         $VMSummary.SCSITarget = $VirtualDiskDevice.UnitNumber
         $VMSummaries += $VMSummary
         }
      }