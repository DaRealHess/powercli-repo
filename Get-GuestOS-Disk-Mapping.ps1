$vmName = "glham1-isvc01"
## modification below here not necessary to run ##


#get windows disks via wmi
$cred = if ($cred){$cred}else{Get-Credential}
$win32DiskDrive  = Get-WmiObject -Class Win32_DiskDrive -ComputerName $vmName -Credential $cred

#get vm hard disks and vm datacenter and virtual disk manager via PowerCLI
#does not connect to a vi server for you!  you should already be connected to the appropraite vi server.
$vmHardDisks = Get-VM -Name $vmName | Get-HardDisk
$vmDatacenterView = Get-VM -Name $vmName | Get-Datacenter | Get-View
$virtualDiskManager = Get-View -Id VirtualDiskManager-virtualDiskManager

#iterates through each windows disk and assign an alternate disk serial number value if not a vmware disk model
#required to handle physical mode RDMs, otherwise this should not be needed
foreach ($disk in $win32DiskDrive)
{
  #add a AltSerialNumber NoteProperty and grab the disk serial number
  $disk | Add-Member -MemberType NoteProperty -Name AltSerialNumber -Value $null
  $diskSerialNumber = $disk.SerialNumber
  
  #if disk is not a VMware disk set the AltSerialNumber property
  if ($disk.Model -notmatch 'VMware Virtual disk SCSI Disk Device')
  {
    #if disk serial number is 12 characters convert it to hex
    if ($diskSerialNumber -match '^\S{12}$')
    {
      $diskSerialNumber = ($diskSerialNumber | foreach {[byte[]]$bytes = $_.ToCharArray(); $bytes | foreach {$_.ToString('x2')} }  ) -join ''
    }
    $disk.AltSerialNumber = $diskSerialNumber
  }
}

#iterate through each vm hard disk and try to correlate it to a windows disk
#and generate some results!
$results = @()
foreach ($vmHardDisk in $vmHardDisks)
{
  #get uuid of vm hard disk / and remove spaces and dashes
  $vmHardDiskUuid = $virtualDiskManager.queryvirtualdiskuuid($vmHardDisk.Filename, $vmDatacenterView.MoRef) | foreach {$_.replace(' ','').replace('-','')}
  
  #match vm hard disk uuid to windows disk serial number
  $windowsDisk = $win32DiskDrive | where {$_.SerialNumber -eq $vmHardDiskUuid}
  
  #if windowsDisk not found then try to match the vm hard disk ScsiCanonicalName to the AltSerialNumber set previously
  if (-not $windowsDisk)
  {
    $windowsDisk = $win32DiskDrive | where {$_.AltSerialNumber -eq $vmHardDisk.ScsiCanonicalName.substring(12,24)}
  }
  
  #generate a result
  $result = "" | select vmName,vmHardDiskDatastore,vmHardDiskVmdk,vmHardDiskName,windowsDiskIndex,windowsDiskSerialNumber,vmHardDiskUuid,windowsDiskAltSerialNumber,vmHardDiskScsiCanonicalName
  $result.vmName = $vmName.toupper()
  $result.vmHardDiskDatastore = $vmHardDisk.filename.split(']')[0].split('[')[1]
  $result.vmHardDiskVmdk = $vmHardDisk.filename.split(']')[1].trim()
  $result.vmHardDiskName = $vmHardDisk.Name
  $result.windowsDiskIndex = if ($windowsDisk){$windowsDisk.Index}else{"FAILED TO MATCH"}
  $result.windowsDiskSerialNumber = if ($windowsDisk){$windowsDisk.SerialNumber}else{"FAILED TO MATCH"}
  $result.vmHardDiskUuid = $vmHardDiskUuid
  $result.windowsDiskAltSerialNumber = if ($windowsDisk){$windowsDisk.AltSerialNumber}else{"FAILED TO MATCH"}
  $result.vmHardDiskScsiCanonicalName = $vmHardDisk.ScsiCanonicalName
  $results += $result
}

#sort and then output the results
$results = $results | sort {[int]$_.vmHardDiskName.split(' ')[2]}
$results | ft -AutoSize
