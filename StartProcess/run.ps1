using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
Write-Information $($TriggerMetadata | ConvertTo-JSon)
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

Push-OutputBinding -Name Queue -Value @{
    ResourceGroupName = $ResourceGroupName
    VMName = $VMName
}


Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = '202'
        Body = 'Accepted'
    })