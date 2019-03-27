#The following PowerShell code uses VMware vSphere’s CloneVM API to create a linked clone from a source VM’s current snapshot point. 
#The clone will be located on the same host, datastore, and folder as the source VM. 
#It requires a snapshot to exist on the source VM, and it requires vCenter Server.

connect-viserver "osl1800.verit.dnv.com"
$sourceVM = Get-VM "HHB1031" | Get-View
$cloneName = "Clone_of_HHB1031"
$cloneFolder = $sourceVM.parent
$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
$cloneSpec.Snapshot = $sourceVM.Snapshot.CurrentSnapshot
$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking
$sourceVM.CloneVM_Task( $cloneFolder, $cloneName, $cloneSpec )
