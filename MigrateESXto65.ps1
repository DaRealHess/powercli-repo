<# 
.Synopsis 
   Write-Log writes a message to a specified log file with the current time stamp. 
.DESCRIPTION 
   The Write-Log function is designed to add logging capability to other scripts. 
   In addition to writing output and/or verbose you can write to a log file for 
   later debugging. 
.NOTES 
   Created by: Jason Wasser @wasserja 
   Modified: 11/24/2015 09:30:19 AM   
 
   Changelog: 
    * Code simplification and clarification - thanks to @juneb_get_help 
    * Added documentation. 
    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks 
    * Revised the Force switch to work as it should - thanks to @JeffHicks 
 
   To Do: 
    * Add error handling if trying to create a log file in a inaccessible location. 
    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate 
      duplicates. 
.PARAMETER Message 
   Message is the content that you wish to add to the log file.  
.PARAMETER Path 
   The path to the log file to which you would like to write. By default the function will  
   create the path and file if it does not exist.  
.PARAMETER Level 
   Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational) 
.PARAMETER NoClobber 
   Use NoClobber if you do not wish to overwrite an existing file. 
.EXAMPLE 
   Write-Log -Message 'Log message'  
   Writes the message to c:\Logs\PowerShellLog.log. 
.EXAMPLE 
   Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log 
   Writes the content to the specified log file and creates the path and file specified.  
.EXAMPLE 
   Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error 
   Writes the message to the specified log file as an error message, and writes the message to the error pipeline. 
.LINK 
   https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0 
#> 
function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path='C:\Logs\PowerShellLog.log', 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}

#region Set up credentials / connections
#Enter your variable values below
$LogFile = "C:\Temp\MigrationLogs\Migration-Log.txt"
$Old_vCenter = "osl1800.verit.dnv.com"
$New_vCenter = "osl3600.verit.dnv.com"

$AdmCredentials = Get-Credential -Message "Enter your VERIT\ADMxxxx Credentials"
$PAMCredentials = Get-Credential -Message "Enter your PAM\ADMxxxx Credentials"
$ESXCredentials = Get-Credential -Message "Enter the ESX root Credentials"

#Make sure no vCenters are connected
#Disconnect-VIServer * -Confirm:$false -ErrorAction SilentlyContinue
$global:DefaultVIServers

#Connect to source and destination vCenter
Connect-VIServer $Old_vCenter -Credential $AdmCredentials -Force
Connect-VIServer $New_vCenter -Credential $PAMCredentials -Force

$DestinationCluster = "MigrationV1"
$MigrationCluster = "V1 - Production 1"
$FinalCluster = "OSL_V1_GP_01"
$HostScope = Get-Cluster $MigrationCluster -Server $Old_vCenter | Get-VMHost osl9143.verit.dnv.com
$EnvironmentTag = "Production" #Either "Production" or "Dev_Test"
$Compute_vDS = "ACI-DVS-OSL"

#Edit the following to match the appropriate Datastores for the destination cluster$DestinationDisks = @{    S = "S_OSL_V1_GP_01_14"    G = "G_OSL_V1_GP_01_02"    }
#Edit the following to include all currently used vSwitch PGs and their correstponding ACI vDS EPGs$DestinationPortGroups = @{                         
    "Mig-VLAN112_Maritime" = "DC-OSL-V1|AppProf|0112-MaritimeNPS-EPG"
    "Mig-VLAN48_Non_Specific_Services" = "DC-OSL-V1|AppProf|0048-NonSpecific-Services-EPG"
    "Mig-VLAN80_HR_Finance_Team" = "DC-OSL-V1|AppProf|0080-HR-Finance-TEAM-EPG"  
    "Mig-VLAN64_Web_Tridion_Intranet" = "DC-OSL-V1|AppProf|0064-Web-Tridion-Intranet-EPG"
    "Mig-VLAN64_NLB_Web_Tridion_Intranet" = "DC-OSL-V1|AppProf|0064-Web-Tridion-Intranet-EPG"
    "Mig-VLAN17_Common_Services" = "DC-OSL-V1|AppProf|0017-Common-Services-EPG"
    "Mig-VLAN65_Security-Management-Y3D1" = "DC-OSL-V1V2|AppProf|0065-Security-Mgmt-EPG"
    "Mig-VLAN31_External_DMZ_Test" = "DMZ-OSL|AppProf|0031-External-DMZ-EPG"
    "Mig-VLAN128_Energy" = "DC-OSL-V1|AppProf|0128-Energy-EPG"
    "Mig-VLAN88_NGF_TEST_Private" = "DC-OSL-V1|AppProf|0088-NGF-Test-Prv-EPG"
    "Mig-VLAN89_NGF_TEST_Public" = "DC-OSL-V1|AppProf|0089-NGF-Test-Pub-EPG"
    "Mig-VLAN119_LegacyProd" = "DC-OSL-V1|AppProf|0119-V4NNG-NonStd-EPG"
    "Mig-VLAN144_Industry_ITGS" = "DC-OSL-V1|AppProf|0144-Industry-ITGS-EPG"
    "Mig-VLAN66_Network-Management-Y3D1" = "DC-OSL-V1V2|AppProf|0066-Network-Mgmt-EPG"
    "Mig-VLAN260_VM_Orchestration" = "VerIT-Mgmt|VerIT-Mgmt-AppProf|VerIT-VM-Deployment-EPG"
    "Mig-VLAN261_Database-OTV" = "DC-OSL-V1V2|AppProf|0261-Database1-EPG"
    "Mig-VLAN262_Database2-OTV" = "DC-OSL-V1V2|AppProf|0262-Database2-EPG"
    "Mig-VLAN255_OTV_NetBackup" = "DC-OSL-V1V2|AppProf|0255-NetBackup-EPG"
    "Mig-VLAN55_SAN_Management" = "DC-OSL-V1|AppProf|0055-SAN-Mgmt-EPG"
}

#Change to multi-mode vcenter management
#Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false


#endregion

#region Check VM preparations

#Check if there are snapshots
$Snapshots = $HostScope | get-vm | get-snapshot | Select VM, Name
If($Snapshots){
    Write-Host "The following snapshots must be handled before continuing migration!" -ForegroundColor Red
    $Snapshots
}
else{
    Write-Host "No snapshots - proceed..." -ForegroundColor Green
}

#Check if VMs have CD/DVD connected
$CDConnected = $HostScope | get-vm | where { $_ | get-cddrive | where { $_.ConnectionState.Connected -eq "true" } } 
If($CDConnected){
    Write-Host "The following VMs have CD/DVD connected. Make sure to have these disconnected before proceeding with migration:" -ForegroundColor Red
    Get-CDDrive -VM $CDConnected.Name | Select Parent, IsoPath, HostDevice, RemoteDevice
}
Else{
    Write-Host "No CD/DVDs connected, proceed..." -ForegroundColor Green
}

# If there are CD/DVDs connected, and you are sure they can be disconnected, you can disconnect all the following way (cmd-line has been commented out for caution as well as getting only one VM)
# Modify the command according to need if to be used
#Get-VM TESTMIGVM -Server $Old_vCenter | Get-CDDrive | Where {$_.ISOPath -ne $null} | Set-CDDrive -NoMedia -Confirm:$false


#endregion

#region Cluster / Host preparation

#Disable HA and DRS on migration cluster
Write-Log -Path $LogFile -Message "Disabling HA and DRS on migration cluster: $($MigrationCluster)"
Get-Cluster -Name $MigrationCluster -Server $Old_vCenter| Set-Cluster -HAEnabled:$false -DrsEnabled:$false -Confirm:$false

#Make sure no hosts are in lockdown mode
ForEach($55Host in $HostScope){
    
    If($55Host.ExtensionData.Config.AdminDisabled){
    (get-vmhost $55Host.Name | get-view).ExitLockdownMode() # To DISABLE Lockdown Mode
    Write-Log -Path $LogFile -Message "FYI: Lockdown Mode disabled for $($55Host.Name)"
    Write-Host "FYI: Lockdown Mode disabled for $($55Host.Name)" -ForegroundColor Yellow
    }
}

#Make sure EVC Mode is turned off on DestinationCluster

$DestinationLocation = Get-Cluster $DestinationCluster -Server $New_vCenter
#$DestinationLocation.EVCMode
If($DestinationLocation.EVCMode -ne $null){
    #EVC Mode is currently enabled and should be disabled
    Write-Log -Path $LogFile -Message "Disabling EVC Mode for cluster $($DestinationLocation.Name)"
    $DestinationLocation | Set-Cluster -EVCMode $Null -Confirm:$False
}
Else{
    Write-Log -Path $LogFile -Message "EVC Mode already disabled for $($DestinationLocation.Name)"
}

#intel-westmere

#endregion

#region Migration

#Disconnect all hosts in migration cluster

#Debug: Faking scope
#$HostScope = Get-VMHost osl9116.verit.dnv.com
#EndDebug

#Disconnect and remove hosts from Old vCenter
foreach ($VMHost in $HostScope) {
    Write-Log -Path $LogFile -Message "Disconnecting / Removing host $($VMHost.Name) from $($Old_vCenter)"
    Get-vmhost $VMHost.Name -Server $Old_vCenter | Set-VMHost -State "Disconnected" -Confirm:$false
    Get-VMHost $VMHost.Name -Server $Old_vCenter | Remove-VMHost -Confirm:$false
}
#add ESX hosts into new vCenter
foreach ($VMHost in $HostScope) {
    Write-Log -Path $LogFile -Message "Adding host $($VMHost.Name) to $($New_vCenter), location $($DestinationLocation)"
    Add-VMHost -Name $VMHost.name  -Location $DestinationLocation -Credential $ESXCredentials -Server $New_vCenter -Force
}

#Disconnect old vCenter

#$global:DefaultVIServers
Write-Log -Path $LogFile -Message "Disconnectin PS session from $($Old_vCenter)"
Disconnect-VIServer $Old_vCenter -Confirm:$false


#added by DavHe
#The following step (re-enabling EVC) can be skipped when migrating from the Production VMware Clusters.

#Before VM migrations start, enable EVC Mode
Write-Log -Path $LogFile -Message "Enabling EVC Mode on $($DestinationLocation.Name)"
$DestinationLocation | Set-Cluster -EVCMode "intel-westmere" -Confirm:$False

#Refresh HostScope since hosts are now moved to new vCenter
$MigrationHosts = $DestinationLocation | Get-VMHost | Where {$_.version -eq "5.5.0"}
$MigrationTempHost = $DestinationLocation | Get-VMHost | Where {$_.version -eq "6.5.0"}

#Migrate VMs to 6.5 Host

# Check that HA and DRS are enabled on final destination cluster
$FinalDestinationCluster = Get-Cluster $FinalCluster
If(($FinalDestinationCluster.DrsEnabled) -and ($FinalDestinationCluster.HAEnabled)){
    Foreach($MigHost in $MigrationHosts){
        #1. Step: Move VMs to Temp Host
        $MigHostVMs = $MigHost | Get-VM 
        Write-Log -Path $LogFile -Message "Migrating VMs to $($MigrationTempHost.Name):"
    
        Get-VM $MigHostVMs | %{
            Write-Log -Path $LogFile -Message "$($_.Name)"
            move-VM -VM $_ -Destination $MigrationTempHost
            }

        #2. Step: Move VM storage
        #$MigrationTempHost | Get-Datastore 
        #$MigrationDatastore = Get-Datastore "S_OSL_V1_GP_01_01"
        #Get-VM $MigHostVMs | move-VM -Datastore $MigrationDatastore 
        Write-Log -Path $LogFile -Message "Performing Storage migrations:"
        #2.1 Move Configuration Files only
        
        ForEach($VM in ($MigrationTempHost | Get-VM)){
            Write-Log -Path $LogFile -Message "Moving VM $($VM.Name) configfiles from $(($VM.ExtensionData.Config.Files.VmPathName.Split("]"))[0].Substring(1)) to $($DestinationDisks[($VM.ExtensionData.Config.Files.VmPathName.Split("]"))[0].Substring(1,1)])"
            $hds = Get-HardDisk -VM $VM
            $spec = New-Object VMware.Vim.VirtualMachineRelocateSpec 
            $spec.datastore = (Get-Datastore -Name $DestinationDisks[($VM.ExtensionData.Config.Files.VmPathName.Split("]"))[0].Substring(1,1)]).Extensiondata.MoRef
            $hds | %{
                $disk = New-Object VMware.Vim.VirtualMachineRelocateSpecDiskLocator
                $disk.diskId = $_.Extensiondata.Key
                $disk.datastore = $_.Extensiondata.Backing.Datastore
                $spec.disk += $disk
            }
            $VM.Extensiondata.RelocateVM_Task($spec, "defaultPriority")
        }
        
        #2.2 Move Hard-Disk Files 
        
        $MigrationTempHost | Get-VM | Get-HardDisk | % {
            Write-Log -Path $LogFile -Message "Moving VM $($_.Parent) disk $($_) from $($_.Filename) to $($DestinationDisks[$_.FileName.Substring(1,1)])"
            Move-HardDisk -HardDisk $_ -Datastore (get-datastore -Name $DestinationDisks[$_.FileName.Substring(1,1)]) -StorageFormat Thin -Confirm:$false
            }

        #End 2. Step

        #3. Step: Connect VM NICs to correct ACI vDS EPG
        #$VM = Get-VM TESTMIGVM
        $MigrationVMs = $MigrationTempHost | Get-VM
        
        ForEach($VM in $MigrationVMs){
            Get-NetworkAdapter -VM $VM | %{
                Write-Log -Path $LogFile -Message "Changing $($VM.Name) $($_.Name) PG from $($_.NetworkName) to $($DestinationPortGroups[$_.NetworkName])"
                Set-NetworkAdapter -NetworkAdapter $_ -PortGroup (Get-VirtualPortGroup -VirtualSwitch $Compute_vDS -Name $DestinationPortGroups[$_.NetworkName]) -Confirm:$false
            }
        }

        #End 3. Step
    
        #4. Step: Move VMs to final destination cluster
    
        Write-Log -Path $LogFile -Message "Moving the VMs to final cluster $($FinalDestinationCluster):"
        Get-VM $MigHostVMs | %{
            Write-Log -Path $LogFile -Message "$($_.Name)"
            move-VM -VM $_ -Destination $FinalDestinationCluster
            }
    
        #End 4. Step

        # 5. Step: Assign Environment Tag
        Get-VM $MigHostVMs | New-TagAssignment -Tag $EnvironmentTag -Server $New_vCenter

        #End 5. Step

    }
}
Else{
    Write-Log -Path $LogFile -Message "HA and DRS not enabled on cluster $($FinalDestinationCluster). Unable to start VM migration! "
}

#endregion



