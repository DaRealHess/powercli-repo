## Disclaimer:
## - This is an generic script provided and can be customized as ## per your requirement. 
## - This script is provided for educational purposes only , ## ## please use at your own risk
## Add-PSSnapin VMware.VimAutomation.Core
## connect-viserver 127.0.0.1 -User Administrator

write-host ""
$diskCount = 0
do {
  $diskCount = [int](read-host "How Many Shared Disks shall I create for you? [1-55]")
} until ($diskCount -le 55 -and $diskCount -gt 0)

do {
  $hostCount = [int](read-host "How Many Hosts? [1-32]")
} until ($hostCount -le 20 -and $hostCount -gt 0)

$vm = New-Object VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl[] ($hostCount)
$view = New-Object VMware.Vim.VirtualMachine[] ($hostCount)
$vmspec = New-Object VMware.Vim.VirtualMachineCloneSpec[] ($hostCount)
$vmtaskMoRef = New-Object VMware.Vim.ManagedObjectReference[] ($hostCount)
$nodeNames = New-Object String[] ($hostCount)

$clonespec = New-Object VMware.Vim.VirtualMachineCloneSpec
$clonespec.location = New-Object VMware.Vim.VirtualMachineRelocateSpec
$clonespec.location.datastore = New-Object VMware.Vim.ManagedObjectReference
$clonespec.location.datastore.type = "Datastore"
$clonespec.location.datastore.Value = "DS_xxxx"
$clonespec.location.pool = New-Object VMware.Vim.ManagedObjectReference
$clonespec.location.pool.type = "ResourcePool"
$clonespec.location.pool.Value = "ResPool_xxxx"
$clonespec.location.disk = New-Object VMware.Vim.VirtualMachineRelocateSpecDiskLocator[] (2)
$clonespec.location.disk[0] = New-Object VMware.Vim.VirtualMachineRelocateSpecDiskLocator
$clonespec.location.disk[0].diskId = 2000
$clonespec.location.disk[0].datastore = New-Object VMware.Vim.ManagedObjectReference
$clonespec.location.disk[0].datastore.type = "Datastore"
$clonespec.location.disk[0].datastore.Value = "DS_xxxx"
$clonespec.location.disk[1] = New-Object VMware.Vim.VirtualMachineRelocateSpecDiskLocator
$clonespec.location.disk[1].diskId = 2001
$clonespec.location.disk[1].datastore = New-Object VMware.Vim.ManagedObjectReference
$clonespec.location.disk[1].datastore.type = "Datastore"
$clonespec.location.disk[1].datastore.Value = "DS_xxxx"
$clonespec.template = $false
$clonespec.customization = New-Object VMware.Vim.CustomizationSpec
$clonespec.customization.options = New-Object VMware.Vim.CustomizationLinuxOptions
$clonespec.customization.identity = New-Object VMware.Vim.CustomizationLinuxPrep
$clonespec.customization.identity.hostName = New-Object VMware.Vim.CustomizationVirtualMachineName
$clonespec.customization.identity.domain = "mydomain.com"
$clonespec.customization.identity.timeZone = "America/Los_Angeles"
$clonespec.customization.identity.hwClockUTC = $true
$clonespec.customization.globalIPSettings = New-Object VMware.Vim.CustomizationGlobalIPSettings
$clonespec.customization.globalIPSettings.dnsSuffixList = New-Object System.String[] (1)
$clonespec.customization.globalIPSettings.dnsSuffixList[0] = "mydomain.com"
$clonespec.customization.globalIPSettings.dnsServerList = New-Object System.String[] (2)
$clonespec.customization.globalIPSettings.dnsServerList[0] = "a.b.c.d"
$clonespec.customization.globalIPSettings.dnsServerList[1] = "e.f.g.h"
$clonespec.customization.nicSettingMap = New-Object VMware.Vim.CustomizationAdapterMapping[] (3)
$clonespec.customization.nicSettingMap[0] = New-Object VMware.Vim.CustomizationAdapterMapping
$clonespec.customization.nicSettingMap[0].adapter = New-Object VMware.Vim.CustomizationIPSettings
$clonespec.customization.nicSettingMap[0].adapter.ip = New-Object VMware.Vim.CustomizationFixedIp
# $clonespec.customization.nicSettingMap[0].adapter.ip.ipAddress = "x.x.x.x"
$clonespec.customization.nicSettingMap[0].adapter.subnetMask = "255.255.255.0"
$clonespec.customization.nicSettingMap[0].adapter.gateway = New-Object System.String[] (2)
$clonespec.customization.nicSettingMap[0].adapter.gateway[0] = "x.x.x.x"
$clonespec.customization.nicSettingMap[0].adapter.gateway[1] = ""
$clonespec.customization.nicSettingMap[0].adapter.primaryWINS = ""
$clonespec.customization.nicSettingMap[0].adapter.secondaryWINS = ""
$clonespec.customization.nicSettingMap[1] = New-Object VMware.Vim.CustomizationAdapterMapping
$clonespec.customization.nicSettingMap[1].adapter = New-Object VMware.Vim.CustomizationIPSettings
$clonespec.customization.nicSettingMap[1].adapter.ip = New-Object VMware.Vim.CustomizationFixedIp
# $clonespec.customization.nicSettingMap[1].adapter.ip.ipAddress = "y.y.y.y"
$clonespec.customization.nicSettingMap[1].adapter.subnetMask = "255.255.255.0"
$clonespec.customization.nicSettingMap[1].adapter.gateway = New-Object System.String[] (2)
$clonespec.customization.nicSettingMap[1].adapter.gateway[0] = ""
$clonespec.customization.nicSettingMap[1].adapter.gateway[1] = ""
$clonespec.customization.nicSettingMap[1].adapter.primaryWINS = ""
$clonespec.customization.nicSettingMap[1].adapter.secondaryWINS = ""
$clonespec.customization.nicSettingMap[2] = New-Object VMware.Vim.CustomizationAdapterMapping
$clonespec.customization.nicSettingMap[2].adapter = New-Object VMware.Vim.CustomizationIPSettings
$clonespec.customization.nicSettingMap[2].adapter.ip = New-Object VMware.Vim.CustomizationFixedIp
# $clonespec.customization.nicSettingMap[2].adapter.ip.ipAddress = "z.z.z.z"
$clonespec.customization.nicSettingMap[2].adapter.subnetMask = "255.255.255.0"
$clonespec.customization.nicSettingMap[2].adapter.gateway = New-Object System.String[] (2)
$clonespec.customization.nicSettingMap[2].adapter.gateway[0] = ""
$clonespec.customization.nicSettingMap[2].adapter.gateway[1] = ""
$clonespec.customization.nicSettingMap[2].adapter.primaryWINS = ""
$clonespec.customization.nicSettingMap[2].adapter.secondaryWINS = ""
$clonespec.powerOn = $false

$folder = New-Object VMware.Vim.ManagedObjectReference
$folder.type = "Folder"
$folder.Value = "Group_xxx"

for($i=0;$i -lt $hostCount; $i++){
  do {
      $hostStr = read-host "VM " (1+$i) " name"
    if ([System.Net.Dns]::GetHostAddresses($hostStr) -eq "") {
      write-host $hostStr " is not in DNS, please enter a valid hostname."
      $hostStr = ""
    } elseif ([System.Net.Dns]::GetHostAddresses($hostStr + "-priv1") -eq "") {
      write-host $hostStr "-priv1 is not in DNS, please enter a hostname with valid -priv1 alias."
      $hostStr = ""
    } elseif ([System.Net.Dns]::GetHostAddresses($hostStr + "-priv2") -eq "") {
      write-host $hostStr "-priv2 is not in DNS, please enter a hostname with valid -priv2 alias."
      $hostStr = ""
    } else {
	  $nodeNames[$i] = $hostStr;
      $vmspec[$i] = $clonespec
      $vmspec[$i].customization.nicSettingMap[0].adapter.ip.ipAddress = [System.Net.Dns]::GetHostAddresses($hostStr)
      $vmspec[$i].customization.nicSettingMap[1].adapter.ip.ipAddress = [System.Net.Dns]::GetHostAddresses($hostStr + "-priv1")
      $vmspec[$i].customization.nicSettingMap[2].adapter.ip.ipAddress = [System.Net.Dns]::GetHostAddresses($hostStr + "-priv2")
      $_this = Get-View -Id 'VirtualMachine-vm-308'
	  $vmtaskMoRef[$i] = $_this.CloneVM_Task($folder, $hostStr, $vmspec[$i])
	}
  } until ($hostStr -ne "")
}

write-host ""
write-host "Waiting for tasks to complete before proceeding..."
for($i=0;$i -lt $hostCount; $i++){
  $task = Get-View $vmtaskMoRef[$i]
    while("running","queued" -contains $task.Info.State){
    $task.UpdateViewData("Info.State")
  }
  if($task.Info.State -eq "error"){
    $task.UpdateViewData("Info.Error")
    $task.Info.Error.Fault.faultMessage | % {
      $_.Message
    }
    exit
  }
}
for($i=0;$i -lt $hostCount; $i++){
  $vm[$i] = Get-VM -Name $nodeNames[$i]
  $view[$i] = Get-View -Id $vm[$i].Id
}

$CreateSpecNewController = New-Object VMware.Vim.VirtualMachineConfigSpec
$CreateSpecNewController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (2)
$CreateSpecNewController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$CreateSpecNewController.deviceChange[0].operation = "add"
$CreateSpecNewController.deviceChange[0].fileOperation = "create"
$CreateSpecNewController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$CreateSpecNewController.deviceChange[0].device.key = -100
$CreateSpecNewController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$CreateSpecNewController.deviceChange[0].device.backing.fileName = ""
$CreateSpecNewController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$CreateSpecNewController.deviceChange[0].device.backing.thinProvisioned = $false
$CreateSpecNewController.deviceChange[0].device.backing.split = $false
$CreateSpecNewController.deviceChange[0].device.backing.writeThrough = $false
$CreateSpecNewController.deviceChange[0].device.backing.eagerlyScrub = $true
$CreateSpecNewController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$CreateSpecNewController.deviceChange[0].device.connectable.startConnected = $true
$CreateSpecNewController.deviceChange[0].device.connectable.allowGuestControl = $false
$CreateSpecNewController.deviceChange[0].device.connectable.connected = $true
$CreateSpecNewController.deviceChange[0].device.controllerKey = -101
$CreateSpecNewController.deviceChange[0].device.capacityInKB = 1048576
$CreateSpecNewController.deviceChange[1] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$CreateSpecNewController.deviceChange[1].operation = "add"
$CreateSpecNewController.deviceChange[1].device = New-Object VMware.Vim.ParaVirtualSCSIController
$CreateSpecNewController.deviceChange[1].device.key = -101
$CreateSpecNewController.deviceChange[1].device.controllerKey = 100
$CreateSpecNewController.deviceChange[1].device.busNumber = 1
$CreateSpecNewController.deviceChange[1].device.sharedBus = "noSharing"
$CreateSpecNewController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$CreateSpecNewController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$CreateSpecNewController.extraConfig[0].key = "scsi1:0.sharing"
$CreateSpecNewController.extraConfig[0].value = "multi-writer"

$CreateSpecExistingController = New-Object VMware.Vim.VirtualMachineConfigSpec
$CreateSpecExistingController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
$CreateSpecExistingController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$CreateSpecExistingController.deviceChange[0].operation = "add"
$CreateSpecExistingController.deviceChange[0].fileOperation = "create"
$CreateSpecExistingController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$CreateSpecExistingController.deviceChange[0].device.key = -100
$CreateSpecExistingController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$CreateSpecExistingController.deviceChange[0].device.backing.fileName = ""
$CreateSpecExistingController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$CreateSpecExistingController.deviceChange[0].device.backing.thinProvisioned = $false
$CreateSpecExistingController.deviceChange[0].device.backing.split = $false
$CreateSpecExistingController.deviceChange[0].device.backing.writeThrough = $false
$CreateSpecExistingController.deviceChange[0].device.backing.eagerlyScrub = $true
$CreateSpecExistingController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$CreateSpecExistingController.deviceChange[0].device.connectable.startConnected = $true
$CreateSpecExistingController.deviceChange[0].device.connectable.allowGuestControl = $false
$CreateSpecExistingController.deviceChange[0].device.connectable.connected = $true
$CreateSpecExistingController.deviceChange[0].device.controllerKey = -101
$CreateSpecExistingController.deviceChange[0].device.capacityInKB = 1048576
$CreateSpecExistingController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$CreateSpecExistingController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$CreateSpecExistingController.extraConfig[0].key = "scsi1:0.sharing"
$CreateSpecExistingController.extraConfig[0].value = "multi-writer"

$specNewController = New-Object VMware.Vim.VirtualMachineConfigSpec
$specNewController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (2)
$specNewController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$specNewController.deviceChange[0].operation = "add"
$specNewController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$specNewController.deviceChange[0].device.key = -100
$specNewController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$specNewController.deviceChange[0].device.backing.fileName = ""
$specNewController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$specNewController.deviceChange[0].device.backing.thinProvisioned = $false
$specNewController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$specNewController.deviceChange[0].device.connectable.startConnected = $true
$specNewController.deviceChange[0].device.connectable.allowGuestControl = $false
$specNewController.deviceChange[0].device.connectable.connected = $true
$specNewController.deviceChange[0].device.controllerKey = -101
$specNewController.deviceChange[0].device.capacityInKB = 1048576
$specNewController.deviceChange[1] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$specNewController.deviceChange[1].operation = "add"
$specNewController.deviceChange[1].device = New-Object VMware.Vim.ParaVirtualSCSIController
$specNewController.deviceChange[1].device.key = -101
$specNewController.deviceChange[1].device.controllerKey = 100
$specNewController.deviceChange[1].device.busNumber = 1
$specNewController.deviceChange[1].device.sharedBus = "noSharing"
$specNewController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$specNewController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$specNewController.extraConfig[0].key = "scsi1:0.sharing"
$specNewController.extraConfig[0].value = "multi-writer"

$specExistingController = New-Object VMware.Vim.VirtualMachineConfigSpec
$specExistingController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
$specExistingController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$specExistingController.deviceChange[0].operation = "add"
$specExistingController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$specExistingController.deviceChange[0].device.key = -100
$specExistingController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$specExistingController.deviceChange[0].device.backing.fileName = ""
$specExistingController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$specExistingController.deviceChange[0].device.backing.thinProvisioned = $false
$specExistingController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$specExistingController.deviceChange[0].device.connectable.startConnected = $true
$specExistingController.deviceChange[0].device.connectable.allowGuestControl = $false
$specExistingController.deviceChange[0].device.connectable.connected = $true
$specExistingController.deviceChange[0].device.controllerKey = -101
$specExistingController.deviceChange[0].device.capacityInKB = 1048576
$specExistingController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$specExistingController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$specExistingController.extraConfig[0].key = "scsi1:0.sharing"
$specExistingController.extraConfig[0].value = "multi-writer"

## two private disks exist on bus[0] already: boot disk, /u01 application binaries
$bus = 1,-1,-1,-1;

for($j=0;$j -lt $diskCount; $j++){

  $busID = [int]((1 + $j) % 4)
  $bus[$busID] += 1
  if ($bus[$busID] -eq 7) { $bus[$busID] += 1 }
  $deviceString = "scsi" + [string]($busID) + ":" + [string]$bus[$busID] + ".sharing"
  # write-host "modulus of diskCount " $j " is scsi" $busID ":" $deviceString

  $CreateSpec = $CreateSpecNewController
  $CreateSpec.deviceChange[1].device.busNumber = $busID
  foreach ($VirtualSCSIController in ($view[0].Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
    if ($VirtualSCSIController.BusNumber -eq $busID) {
      $CreateSpec = $CreateSpecExistingController
      $CreateSpec.deviceChange[0].device.controllerKey = $VirtualSCSIController.Key

    }
  }
  $CreateSpec.extraConfig[0].key = $deviceString
  $Createspec.deviceChange[0].device.unitNumber = $bus[$busID]

  # first VM creates the disks:
  write-host "create " $deviceString " on " $vm[0].Name " controllerKey = " $CreateSpec.deviceChange[0].device.controllerKey

  $taskMoRef = $view[0].ReconfigVM_Task($CreateSpec) 
  $task = Get-View $taskMoRef

  while("running","queued" -contains $task.Info.State){
    $task.UpdateViewData("Info.State")
  }
  if($task.Info.State -eq "error"){
    $task.UpdateViewData("Info.Error")
    $task.Info.Error.Fault.faultMessage | % {
      $_.Message
    }
    exit
  }
  # refresh the view, to pickup any new device(s)
  $view[0] = Get-View -Id $vm[0].Id

  $backingFileName = ""
  foreach ($VirtualSCSIController in ($view[0].Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
    if ($VirtualSCSIController.BusNumber -eq $busID) {
      foreach ($VirtualDiskDevice in ($view[0].Config.Hardware.Device | where {$_.ControllerKey -eq $VirtualSCSIController.Key})) {
        if ($VirtualDiskDevice.UnitNumber -eq $bus[$busID]){
          $backingFileName = $VirtualDiskDevice.Backing.FileName
          write-host "filename = " $backingFileName

          # subsequent VMs attach to existing disks:
          for ($node = 1; $node -lt $hostCount; $node++){
            $spec = $SpecNewController
            $spec.deviceChange[1].device.busNumber = $busID
            foreach ($VirtualSCSIController in ($view[$node].Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
              if ($VirtualSCSIController.BusNumber -eq $busID) {
                $spec = $SpecExistingController
                $spec.deviceChange[0].device.controllerKey = $VirtualSCSIController.Key

              }
            }
            $spec.extraConfig[0].key = $deviceString
            $spec.deviceChange[0].device.unitNumber = $bus[$busID]
            $spec.deviceChange[0].device.backing.FileName = $VirtualDiskDevice.Backing.FileName

            write-host "attach " $deviceString " to " $vm[$node].Name " backingFilename = " $spec.deviceChange[0].device.backing.FileName " controllerKey = " $spec.deviceChange[0].device.controllerKey

            $taskMoRef = $view[$node].ReconfigVM_Task($spec) 
            $task = Get-View $taskMoRef

            while("running","queued" -contains $task.Info.State){
              $task.UpdateViewData("Info.State")
            }
            if($task.Info.State -eq "error"){
              $task.UpdateViewData("Info.Error")
              $task.Info.Error.Fault.faultMessage | % {
                $_.Message
              }
              exit
            }
            # refresh the view, to pickup any new device(s)
            $view[$node] = Get-View -Id $vm[$node].Id
          }
        }
      }
    }
  }
}
# if we made it here without error, power up all VMs in $view[] array
Start-VM -VM $vm -Confirm -RunAsync
#Start-VM -VM $vm

exit;
# end of script