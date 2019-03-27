# These are the values you should get from your webform
#
$snapTime = Get-Date "24/02/18 11:00"
$snapName = 'Davids-Scheduled-Snapshot-Test'
$snapDescription = 'Scheduled snapshot'
$snapMemory = $true
$snapQuiesce = $false
$emailAddr = 'david.hesse@dnvgl.com'
$fileName = 'E:\Dropbox\PowerShell_Scripts\Inputs\scheduled_snapshot.csv'

###############

 

Import-Csv -Path $fileName -UseCulture | %{


    $vm = Get-VM -Name $_.VMName


    $si = get-view ServiceInstance

    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager

    

    $spec = New-Object VMware.Vim.ScheduledTaskSpec

    $spec.Name = "Snapshot",$vm.Name -join ' '

    $spec.Description = $_.Description

    $spec.Enabled = $true

    $spec.Notification = $emailAddr

    

    $spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

    $spec.Scheduler.runat = $snapTime

    

    $spec.Action = New-Object VMware.Vim.MethodAction

    $spec.Action.Name = "CreateSnapshot_Task"

    

    @($snapName,$snapDescription,$snapMemory,$snapQuiesce) | %{

        $arg = New-Object VMware.Vim.MethodActionArgument

        $arg.Value = $_

        $spec.Action.Argument += $arg

    }

    

    $scheduledTaskManager.CreateObjectScheduledTask($vm.ExtensionData.MoRef, $spec)

}