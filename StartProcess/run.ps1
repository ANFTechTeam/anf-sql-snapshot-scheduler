using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Information "[StartProcess] Starting StartProcess"

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

if (-not $ResourceGroupName)
{
    $ResourceGroupName = $Request.Body.ResourceGroupName 
}
if (-not $VMName)
{
    $VMName = $Request.Body.VMName 
}

Write-Information "[StartProcess] Send Message in Queue"

Push-OutputBinding -Name Queue -Value @{
    ResourceGroupName = $ResourceGroupName
    VMName = $VMName
}

Write-Information "[StartProcess] Send Message in HTTP"

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = '202'
        Body = 'Accepted'
    })