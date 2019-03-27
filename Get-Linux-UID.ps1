if(-not (Get-PSSnapin VMware.VimAutomation.Core))

{

   Add-PSSnapin "VMware.VimAutomation.Core" | Out-Null

}




function getDiskUUIDs ([string]$vmname) {




 $vm=get-vm -name $vmname

 $wiseriver_old

 $vdm = get-view -id (get-view serviceinstance).content.virtualdiskmanager



 ForEach ($HardDisk in ($vm | Get-HardDisk | Sort-Object -Property Name)) {




 Write-Host "Hard Disk:  " $HardDisk

    

    $filepath=$HardDisk.FileName

    Write-Host "File Path : " $filepath




    $tmp1=$vdm.queryvirtualdiskuuid($filePath, $dc.id)
    $tmp1=$vdm.queryvirtualdiskuuid($filePath, $dc.id)

    $tmp2=$tmp1 -replace '\s+', ''

    $UUID=$tmp2 -replace '-', ''




    Write-Host ""

    Write-Host "oldUUID : " $tmp1

    Write-Host "UUID : " $UUID

 }



}




$vc="glham1-isvc01.service.gl-group.internal"

$vm="wiseriver_old"




Write-Host "vcenter: " $vc

Write-Host "VM:      " $vm

Connect-VIServer "$vc"




$dc=get-datacenter

write-Host "Datacenter: " $dc

write-Host "HHB_Legacy_VMware:  "   $dc.Name



getDiskUUIDs $vm







# --- ps code end ---  #