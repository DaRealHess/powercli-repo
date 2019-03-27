#========================================================================
# Collect ESXi Host Information
# Version 2.0 12/28/2014
# Created by:   Matt Bradford
#========================================================================
# Edit the following section. Enter your vCenter server and the desired location of the output CSV.
$vcenter = "glham1-isvc01.service.gl-group.internal"
$csvfile = ".\hostinfo.csv"
#========================================================================
# Load the VMware Snapin (for PowerShell only)
Add-PSsnapin VMware.VimAutomation.Core

# Test to make sure plink.exe is present in the same directory as the script. If not, throw an error.
if (!(Test-Path ".\plink.exe")) {Throw "Plink.exe is not available in the script folder. Please download from http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html"}

# Create the array that will be used to display information. This makes it easier to assemble each line of the CSV.
$output = New-Object System.Collections.ArrayList

# Check to see if the CSV file exists, if it does then overwrite it.
if (Test-Path $csvfile) {
Write-Host "Overwriting $csvfile"
del $csvfile
}

# Create the CSV title header
Add-Content $csvfile "Host Name,Host Model,Bios Version,Bios Date,OS Version,OS Friendly Name,HBA Adapter,HBA Driver Version,HBA Firmware Version,NIC Adapter,NIC Driver Version,NIC Firmware Version,HPSA Adapter,HPSA Driver Version,HPSA Firmware Version"

# Connect to vCenter
Write-Host "Connecting to vCenter..."
Connect-VIServer $vcenter -wa 0 | Out-Null
Write-Host "Connected"
Write-Host " "

# Collect login information to SSH to each host. The last two lines just convert the string from secure to plain text for plink.exe to use
$user = Read-Host "ESXi Host SSH User"
$rootpword = Read-Host "ESXi Host SSH Password" -AsSecureString
$rootbstr = [System.Runtime.InteropServices.marshal]::SecureStringToBSTR($rootpword)
$rootpword = [System.Runtime.InteropServices.marshal]::PtrToStringAuto($rootbstr)

# Get the host inventory from vCenter
$vmhosts = Get-VMHost | Sort Name

foreach ($vmhost in $vmhosts){

# Check to see if the SSH service is running on the host, if it isn't, start it
$sshservice = Get-VMHost $vmhost | Get-VMHostService | Where-Object {$_.Key -eq "TSM-SSH"}
if (!$sshservice.Running) {Start-VMHostService -HostService $sshservice -Confirm:$false | Out-Null}

# Often times plink will throw a message that the server's key is not cached in the registry when connecting to a host for the first time. The echo y command automatically accepts the key.
echo y | .\plink.exe -ssh $vmhost -l $user -pw $rootpword exit | Out-Null

# smbiosDump is full of great information, here we're using it to collect model and bios information
$hostmodel = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "smbiosDump | grep -i Product:"
$biosfwv = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "smbiosDump | grep -i Version:"
$biosfwd = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "smbiosDump | grep -i Date:"

# vmware -vl displays OS version information
$esxiversion = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "vmware -vl"

# esxcfg-scsidevs -a displays all the scsi/hba interfaces. First we look for interfaces using lpfc drivers. If none are returned then look for qlnativefc drivers.
# For model information you could just pull information for one hba. For example ...grep -i vmhba2. Howerver there is no guarantee that vmhba2 will always be your fibre controller.
$hbamodel = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "esxcfg-scsidevs -a | grep -i lpfc"
if (!$hbamodel){$hbamodel = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "esxcfg-scsidevs -a | grep -i qlnativefc"}
# Pull driver information. This requires a driver type. Again we look for lpfc and if none are found look for qlnativefc.
$hbadrv = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "vmkload_mod -s lpfc |grep -i Version"
if (!$hbadrv){$hbadrv = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "vmkload_mod -s qlnativefc | grep -i Version"}
# Many times publishers will included commas in the driver information. We strip them out for the sake of our CSV file.
$hbadrv = $hbadrv -replace ",", ""
# /usr/lib/vmware/vmkmgmt_keyval/vmkmgmt_keyval -a is a goldmine of hba information. We're just using it to pull the hba firmware version.
$hbafw = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "/usr/lib/vmware/vmkmgmt_keyval/vmkmgmt_keyval -a | grep -i 'FW Version'"

# The output of esxcfg-scsidevs -a isn't delimited in any particular way. However, it always displays information in the same order.
# Vmhba name, driver type, link status, WWN, PCI Address, & model infromation. So we split this string by spaces, removing any empty lines.
# Since the model information is always the 5'th item (we start counting at 0) we strip out everything before then and stop at the 30'th item (arbitrary high number)
$hbamodel = $hbamodel[0].split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[5..30]
# Now that we've stripped out the other information, re-assemble the information to one line
$hbamodel = [string]::join(" ", $hbamodel)
# Remove any commas from the model information for the sake of the CSV
$hbamodel = $hbamodel -replace ",", ""

# esxcli network nic list | grep -i vmnic0 returns information on the first NIC. Assuming all NICs in the host are the same.
$nicadapter= .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "esxcli network nic list | grep -i vmnic0"
# esxcli network nic get -n vmnic0 | grep -i Version: returns Firmware and Driver versions.
$nicver = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "esxcli network nic get -n vmnic0 | grep -i Version:"

# The output of esxcli network nic list | grep -i vmnic0 isn't delimited in any particular way. However, it always displays information in the same order.
# NIC name, PCI address, driver type, link status, link speed, link duplex, MAC address, MTU, & model
# Since the model information is always the 8'th item (we start counting at 0) we strip out everything before then and stop at the 30'th item (arbitrary high number)
$nicadapter = $NICAdapter.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[8..30]
# Now that we've stripped out the other information, re-assemble the information to one line
$nicadapter = [string]::join(" ", $nicadapter)

# Pull information on the first HPSA HP Raid controller. cat /proc/driver/hpsa/hpsa0 | grep -i hpsa0: returns model information
$hpsamodel = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "cat /proc/driver/hpsa/hpsa0 | grep -i hpsa0:"
# Pull driver and firmware version from cat /proc/driver/hpsa/hpsa0
$hpsaver = .\plink.exe -ssh $vmhost -l $user -pw $rootpword -batch "cat /proc/driver/hpsa/hpsa0 | grep -i Version:"

# If this script enabled SSH on the host, then stop the serivce. Otherwise leave it running.
if (!$SSHService.Running) {Stop-VMHostService -HostService $SSHService -Confirm:$false | Out-Null}

# Build the array with all the information we collected
$output.Add($vmhost.Name) | Out-Null
$output.Add($hostmodel.split(":", 2)[1].split('"',3)[1].trim()) | Out-Null
$output.Add($biosfwv[0].split(":",2)[1].split('"',3)[1].trim()) | Out-Null
$output.Add($biosfwd.split(":",2)[1].split('"',3)[1].trim()) | Out-Null
$output.Add($esxiversion[0].trim()) | Out-Null
$output.Add($esxiversion[1].trim()) | Out-Null
$output.Add($hbamodel) | Out-Null
$output.Add($hbadrv.trim()) | Out-Null

# Qlogic firmware versions don't include a semicolon. Output is "Flash FW version x.xx.xx" and must be handled differently.
if($hbafw[0].split(":",2)[1]){$output.Add($hbafw[0].split(":",2)[1].trim()) | Out-Null}
else {
$hbafw = $hbafw[0].split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
$output.Add($hbafw[3]) | Out-Null
}

$output.Add($nicadapter) | Out-Null
$output.Add($nicver[1].split(":")[1].trim()) | Out-Null
$output.Add($nicver[0].split(":")[1].trim()) | Out-Null
$output.Add($hpsamodel.split(":")[1].trim()) | Out-Null
$output.Add($hpsaver[1].split(":")[1].trim()) | Out-Null
$output.Add($hpsaver[0].split(":",2)[1].trim()) | Out-Null

# Assemble the information into CSV format and append it to the CSV file. There's probably an easier way to do this, but it works!
$csvline = $output[0] + "," + $output[1] + "," + $output[2] + "," + $output[3] + "," + $output[4] + "," + $output[5] + "," + $output[6] + "," + $output[7] + "," + $output[8] + "," + $output[9] + "," + $output[10] + "," + $output[11] + "," + $output[12] + "," + $output[13] + "," + $output[14]
Add-Content $csvfile $csvline

# Display all the information we collected in a readable format
Write-Host ""
Write-Host "Hostname:" $output[0] -ForegroundColor "Green"
Write-Host "Host Model:" $output[1]
Write-Host "BIOS Firmware:" $output[2] $output[3]
Write-Host ""
Write-Host "OS Version:"$output[4]
Write-Host "OS Version Friendly Name:" $output[5]
Write-Host ""
Write-Host "HBA Adapter:" $output[6]
Write-Host "HBA Driver Version:" $output[7]
Write-Host "HBA Firmware Version:" $output[8]
Write-Host ""
Write-Host "NIC Adapter:" $output[9]
Write-Host "NIC Driver Version:" $output[10]
Write-Host "NIC FW Version:" $output[11]
Write-Host ""
Write-Host "HPSA Adapter:" $output[12]
Write-Host "HPSA Driver:" $output[13]
Write-Host "HPSA Firmware Version:" $output[14]
Write-Host ""
Write-Host "----------------------------------"

# Clean up the array for the next host
$output.Clear()
}