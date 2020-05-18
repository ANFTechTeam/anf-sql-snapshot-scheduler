using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
Wait-Debugger
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$ResourceGroupName = $Request.Body.ResourceGroupName
$VMName = $Request.Body.VMName
$force = $Request.Body.Force
# Interact with query parameters or the body of the request.

$tags = (Get-AzResource -ResourceGroupName $ResourceGroupName -Name $VMName).Tags
Write-Verbose $($tags.GetType() | Convertto-Json) -Verbose
Write-Verbose $($tags| Convertto-Json) -Verbose

switch ($tags[0].NetApp_SQL_Additions)
{
    $true
    {
        if(!$force)
        { 
            Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                    StatusCode = 200
                    Body       = $true
                }) 
        }
    }
    Default
    { $tags[0].NetApp_SQL_Additions = "waiting"  
    }
}

$isVmPoweredOn = (Get-AzVm -ResourceGroupName $ResourceGroupName -Name $VMName -Status).Statuses[1].Code.Split("/")[1]

# change to queue to have a more efficent process
if($isVmPoweredOn -eq "deallocated")
{
    Write-Verbose ("Starting VM $($VMName)"| Convertto-Json) -Verbose
    Start-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName
    Write-Verbose ("Started VM $($VMName)"| Convertto-Json) -Verbose
}

# another function to test installation
$RunCommand = @{
    ResourceGroupName = $ResourceGroupName 
    VMName            = $VMName
    CommandId         = 'RunPowerShellScript' 
    ScriptPath        = "$($PSScriptRoot)\scripts.ps1"
}

Write-Verbose ("Invoke AzRunCommand on $($VMName) to retreive the status of NetApp SQL Additions"| Convertto-Json) -Verbose

$result = Invoke-AzVMRunCommand @RunCommand

Write-Verbose ($result.Value[0].message | ConvertTo-Json) -Verbose


$Taging = @{
    ResourceGroupName = $ResourceGroupName 
    Name              = $VMName
    ResourceType      = "Microsoft.Compute/VirtualMachines"
}

$tags[0].NetApp_SQL_Additions = $($result.Value[0].message)

Set-AzResource @Taging -Tag $tags[0] -Force 

if ($Request.Body.ResourceGroupName -and $Request.Body.VMName)
{
    $status = [HttpStatusCode]::OK
    $body = ConvertTo-Json $result.Value[0].message
} else
{
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a ResourceGroupName Name on the query string or in the request body."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $status
        Body       = $body
    })
