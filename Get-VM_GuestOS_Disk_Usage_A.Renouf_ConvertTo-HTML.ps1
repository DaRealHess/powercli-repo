Connect-VIServer glham1-isvc01.service.gl-group.internal
$MyCollection = @()
$AllVMs = Get-View -ViewType VirtualMachine | Where {-not $_.Config.Template}
$SortedVMs = $AllVMs | Select *, @{N="NumDisks";E={@($_.Guest.Disk.Length)}} | Sort-Object -Descending NumDisks
ForEach ($VM in $SortedVMs){
 $Details = New-object PSObject
 $Details | Add-Member -Name Name -Value $VM.name -Membertype NoteProperty
 $DiskNum = 0
 Foreach ($disk in $VM.Guest.Disk){
 $Details | Add-Member -Name "Disk$($DiskNum)path" -MemberType NoteProperty -Value $Disk.DiskPath
 $Details | Add-Member -Name "Disk$($DiskNum)Capacity(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.Capacity/ 1MB))
 $Details | Add-Member -Name "Disk$($DiskNum)FreeSpace(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.FreeSpace / 1MB))
 $DiskNum++
 }
 $MyCollection += $Details
}
$MyCollection | ConvertTo-Html > C:\PowerShell_Scripts\Outputs\HHB_All-VMs_Disk_Usage.htm
# Export-Csv, ConvertTo-Html or ConvertTo-Xml can be used