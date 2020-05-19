# Input bindings are passed in via param block.
param($QueueItem, $TriggerMetadata)
try{
# Write out the queue message and insertion time to the information log.
Write-Host "PowerShell queue trigger function processed work item: $QueueItem"
Write-Host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
$ResourceGroupName = $QueueItem.Get_Item("ResourceGroupName")
$VMName = $QueueItem.Get_Item("VMName")

$vmParam = @{
    ResourceGroupName = $ResourceGroupName
    Name = $VMName
}

$vm = Get-AzVM @vmParam -Status
if($vm.Statuses[1].Code.Split("/")[1] -ne "running")
{
    Start-AzVm @vmParam
    Push-OutputBinding -Name Queue -Value @{
        VMName = $VMName
        ResourceGroupName = $ResourceGroupName
        State = "Started"
    } -Clobber
}else{
    Push-OutputBinding -Name Queue -Value @{
        VMName = $VMName
        ResourceGroupName = $ResourceGroupName
        State = "Started"
    } -Clobber
}
} catch {
    Push-OutputBinding -Name Error -Value @{
        VMName = $VMName
        ResourceGroupName = $ResourceGroupName
        State = "Error: in StartVM"
    } -Clobber
}