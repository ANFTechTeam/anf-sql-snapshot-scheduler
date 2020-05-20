# Input bindings are passed in via param block.
param( $QueueItem, $TriggerMetadata)
Write-Information "[Pre-SnapShot] Starting function"
Write-Warning $($QueueItem)
# Write out the queue message and insertion time to the information log.
Write-Host "PowerShell queue trigger function processed work item: $QueueItem"
Write-Host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
$ResourceGroupName = $QueueItem.Get_Item("ResourceGroupName")
$VMName = $QueueItem.Get_Item("VMName")

$script = @"
Set-Location 'C:\Program Files\NetApp\ScSqlApi\'
Import-Module .\ScSqlApiPS.dll
$password = ConvertTo-SecureString "N3t@pp123456" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("netapp", $password)
$Param = @{
    Database = "test"
    SQLInstance = 'MSSQLSERVER'
    Operation = 'Quiesce'
    Authentication = 'Windows'
    Credential = $cred
}
New-ScSqlBackup @Param
"@
Write-Information "[Pre-Snapshot] Creating Script"

Set-Content -Path .\pre-snapshot.ps1 -Value $script

$RunCommand = @{
    ResourceGroupName = $ResourceGroupName 
    VMName            = $VMName
    CommandId         = 'RunPowerShellScript' 
    ScriptPath        = ".\pre-snapshot.ps1"
}
Write-Information "[Pre-Snapshot] Invoke Script"

$result = Invoke-AzVMRunCommand @RunCommand

Write-Information "[Pre-Snapshot] Send Message in Queue"

Push-OutputBinding -Name Queue -Value @{
    VMName = $VMName
    ResourceGroupName = $ResourceGroupName
    State = $($result.Value[0].message)
}
Write-Information "[Pre-Snapshot] End of Function"
