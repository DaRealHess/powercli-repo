$vms = Get-VM jordan-0*

foreach ($vm in $vms) {

New-AdvancedSetting -Entity $vm -Name  scsi1:0.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:1.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:2.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:3.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:4.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:5.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:6.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:7.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:8.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:9.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:10.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:11.sharing -Value multi-writer -Confirm:$false -Force:$true
New-AdvancedSetting -Entity $vm -Name  scsi1:12.sharing -Value multi-writer -Confirm:$false -Force:$true

}
