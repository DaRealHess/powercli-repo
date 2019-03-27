#Change IOPS per cluster for every LUN that has "RoundRobin" multipathing policy:

# Get list of all hosts in specific cluster:
$AllHosts = Get-Cluster "HHB-VerIT-Production" | Get-VMHost | where {($_.ConnectionState -like "Connected")}

# Check the list:
$AllHosts

Name                 ConnectionState PowerState NumCpu CpuUsageMhz CpuTotalMhz   MemoryUsageGB   MemoryTotalGB Version
----                 --------------- ---------- ------ ----------- -----------   -------------   ------------- -------
esxi01               Connected       PoweredOn       4         386        9596           7.975          16.000   6.0.0
esxi02               Connected       PoweredOn       6        1694       14394          26.690          32.000   6.0.0
esxi03               Connected       PoweredOn       6         503       14394           8.893          16.000   6.0.0
esxi04               Connected       PoweredOn       4         405        9596           8.429          16.000   6.0.0


# Change IOPS (CommandsToSwitchPath) on every host in the list that has Multipathing policy set to "RoundRobin":

foreach ($esxhost in $AllHosts) {Get-VMHost $esxhost | Get-ScsiLun -LunType disk | Where-Object {$_.Multipathpolicy -like "RoundRobin"} | Set-ScsiLun -CommandsToSwitchPath 1 | Select-Object CanonicalName, MultipathPolicy, CommandsToSwitchPath}

Output like:

CanonicalName                                                                              MultipathPolicy                                 CommandsToSwitchPath
-------------                                                                              ---------------                                 --------------------
naa.6000d77a0000e7ed6a782ce76300726b                                                            RoundRobin                                                    1
naa.6000d77a0000e7c06a782ce7645d40a9                                                            RoundRobin                                                    1

#Check only:
PowerCLI C:\> foreach ($esxhost in $AllHosts) {Get-VMHost $esxhost | Get-ScsiLun -LunType disk | Where-Object {$_.Multipathpolicy -like "RoundRobin"} | Select-Object CanonicalName, MultipathPolicy, CommandsToSwitchPath}

Output like:

CanonicalName                                                                              MultipathPolicy                                 CommandsToSwitchPath
-------------                                                                              ---------------                                 --------------------
naa.6000d77a0000e7ed6a782ce76300726b                                                            RoundRobin                                                    1
naa.6000d77a0000e7c06a782ce7645d40a9                                                            RoundRobin                                                    1

#