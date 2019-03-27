function Get-VMAdvancedConfiguration {   
<#  
.SYNOPSIS  
  Lists advanced configuration setting (VMX Setting) for a VM  
  or multiple VMs  
.DESCRIPTION  
  The function will list a VMX setting for a VM  
  or multiple VMs  
.PARAMETER VM  
  A virtual machine or multiple virtual machines  
.EXAMPLE 1  
  PS> Get-VM w2k8r2-master | Get-VMAdvancedConfiguration  
#>  
  param(  
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]  
      $vm,  
      [String]$key  
  )  
  process{   
    if ($key) {  
        $VM | Foreach {  
            $_.ExtensionData.Config.ExtraConfig | Select * -ExcludeProperty DynamicType, DynamicProperty | Where { $_.Key -eq $key }  
        }  
    } Else {  
        $VM | Foreach {  
                $_.ExtensionData.Config.ExtraConfig | Select * -ExcludeProperty DynamicType, DynamicProperty  
            }  
    }  
  }   
}  