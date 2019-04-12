#add an AdvancedSettings parameter to a Virtual Machine without the need to shut down the VM.
#DavHe, 11.April 2019.

# Example for importing VMs from a list and adding a new AdvancedSetting parameter for those VMs

$VMList = Import-Csv -Path C:\Users\davhe\Dropbox\PowerCLI_Scripts\Outputs\for_HAML\List-of-VMs| Select-Object -ExpandProperty VM-Name
New-AdvancedSetting -Entity $VMList -Name devices.hotplug -Value false -Confirm:$false -Force:$true
