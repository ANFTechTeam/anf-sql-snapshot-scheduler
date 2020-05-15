using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
Wait-Debugger
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$ResourceGroupName = $Request.Body.ResourceGroupName
$VMName = $Request.Body.VMName
# $force = $Request.Body.Force
$GenericError = @"
Please pass a valid vmname and resource group name in the request body. 
The VM hasn't been found or there is an error here : 
{0}
"@ 
if ($VMName -and $ResourceGroupName)
{
    try
    {
        Write-Host "Looking for VM"
        $vmParam = @{
            ResourceGroupName = $ResourceGroupName
            Name = $VMName
        }
        $vm = Get-AzVM @vmParam -Status
        $vmLocation = Get-AzVM @vmParam
        Write-Host "VM Found !"
        if($vm.Statuses[1].Code.Split("/")[1] -ne "running")
        {
            Write-Host "Vm is off, Starting ..."
            Start-AzVm @vmParam
            Write-Host "VM Started"
        }
        $keys = Get-AzStorageAccountKey -ResourceGroupName azuresqlbackupdev -Name azuresqlbackupdev
        Write-Debug ($vm | ConvertTo-Json) 
        $param = @{
            ResourceGroupName = $vm.ResourceGroupName 
            Location = $vmLocation.Location
            VMName = $vm.Name 
            Name = "NetApp_SQL_Additions" 
            TypeHandlerVersion = "1.1" 
            FileName = "Install-SqlAddition.ps1"
            StorageAccountName = "azuresqlbackupdev"
            StorageAccountKey = $($keys.Value[0])
            ContainerName = "addition"
            ForceReRun = $true
        }
        Write-Host "Launching Custom Script Extention"
        Set-AzVMCustomScriptExtension @param 

        $CustomScriptParam = @{
            ResourceGroupName = $vmParam.ResourceGroupName 
            Name = $param.Name 
            VMName = $vmParam.Name 
            Status = $true
        }
        $status = Get-AzVMCustomScriptExtension @CustomScriptParam
        while($status.Extensions[0].Statuses[0].code.split('/')[1] -ne "failed" -or $status.Extensions[0].Statuses[0].code.split('/')[1] -ne "success")
        {
            $status = Get-AzVMCustomScriptExtension @CustomScriptParam
        }
        Write-Host "Extension is installed, Status is $($status.Extensions[0].Statuses[0])"
        # Associate values to output bindings by calling 'Push-OutputBinding'.
        $response = [HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body = $($status.Extensions[0].Statuses[0])
        }
    } catch
    {
        $response = [HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::BadRequest
            Body = [String]::Format($GenericError,$($Error[0]))
        }
    }
} else
{
    $response = [HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Please pass a vmname and resource group name in the request body."
    }
           
}

Push-OutputBinding -Name Response -Value $response




# https://azuresqlbackupdev.blob.core.windows.net/addition/ScSqlApi.zip?sp=r&st=2020-05-15T07:05:32Z&se=2020-06-30T15:05:32Z&spr=https&sv=2019-10-10&sr=b&sig=cSOs9p%2FlUIkT4Um18HVchSS3su1eBFFjtYkdGqrAE%2Fc%3D