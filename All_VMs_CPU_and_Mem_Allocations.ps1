Get-VM | `
  ForEach-Object {
    $Report = "" | Select-Object -property Name,NumCpu,MemoryMB,Host,IPAddress
    $Report.Name = $_.Name
    $Report.NumCpu = $_.NumCpu
    $Report.MemoryMB = $_.MemoryMB
    $Report.Host = $_.Host
    $Report.IPAddress = $_.Guest.IPAddress
  Write-Output $Report
  } | Export-Csv "C:\PowerShell_Scripts\Outputs\All_VMs_CPU_and_Mem.csv"