using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
Write-Information "[CheckInstall] Starting CheckInstall"

Wait-Debugger
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
$ResourceGroupName = $Request.Get_Item("ResourceGroupName")
$VMName = $Request.Get_Item("VMName")
$State = $Request.Get_Item("State")
if ($State -eq "Error") {
    Write-Information "[CheckInstall] Error VM is off"
    Write-Error "VM Not Started";
}

# Interact with query parameters or the body of the request.

$tags = (Get-AzResource -ResourceGroupName $ResourceGroupName -Name $VMName).Tags

switch ($tags[0].NetApp_SQL_Additions) {
    $true {
        if (!$force) {
            Write-Information "[CheckInstall] Already Installed"

            Push-OutputBinding -Name installed -Value @{
                VMName            = $VMName
                ResourceGroupName = $ResourceGroupName
                State             = "Installed"
            }
        }
    }
    Default { 
        Write-Information "[CheckInstall] Already Installed"
        $tags[0].NetApp_SQL_Additions = "waiting"
        # another function to test installation
$RunCommand = @{
    ResourceGroupName = $ResourceGroupName 
    VMName            = $VMName
    CommandId         = 'RunPowerShellScript' 
    ScriptPath        = "$($PSScriptRoot)\scripts.ps1"
}
Write-Information "[CheckInstall] Invoke Script to check install"

$result = Invoke-AzVMRunCommand @RunCommand

$Taging = @{
    ResourceGroupName = $ResourceGroupName 
    Name              = $VMName
    ResourceType      = "Microsoft.Compute/VirtualMachines"
}
Write-Information "[CheckInstall] script result is $($result.Value[0].message)"

$tags[0].NetApp_SQL_Additions = $($result.Value[0].message)

Write-Information "[CheckInstall] Tag VM"

Set-AzResource @Taging -Tag $tags[0] -Force 

Write-Information "[CheckInstall] send message to queue"

Push-OutputBinding -Name installation -Value @{
    VMName            = $VMName
    ResourceGroupName = $ResourceGroupName
    State             = "Installation"
}
    }
}


