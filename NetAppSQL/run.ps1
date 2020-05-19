using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
Wait-Debugger
# Write to the Azure Functions log stream.

$ResourceGroupName = $Request.Get_Item("ResourceGroupName")
$VMName = $Request.Get_Item("VMName")
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

        $vmParam = @{
            ResourceGroupName = $ResourceGroupName
            Name = $VMName
        }
        $vmLocation = Get-AzVM @vmParam
     
        $keys = Get-AzStorageAccountKey -ResourceGroupName azuresqlbackupdev -Name azuresqlbackupdev
        
        $param = @{
            ResourceGroupName = $vmParam.ResourceGroupName 
            Location = $vmLocation.Location
            VMName = $vmParam.Name 
            Name = "NetApp_SQL_Additions" 
            TypeHandlerVersion = "1.1" 
            FileName = "Install-SqlAddition.ps1"
            StorageAccountName = "azuresqlbackupdev"
            StorageAccountKey = $($keys.Value[0])
            ContainerName = "addition"
            ForceReRun = $true
        }
        
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
            Push-OutputBinding -Name Queue -Value @{
                VMName = $VMName
                ResourceGroupName = $ResourceGroupName
                State = "Installing..."
            } -Clobber
        }
        Write-Information "Extension is installed, Status is $($status.Extensions[0].Statuses[0])"
        # Associate values to output bindings by calling 'Push-OutputBinding'.
        Push-OutputBinding -Name Queue -Value @{
            VMName = $vmParam.Name 
            ResourceGroupName = $ResourceGroupName
            state = $status.Extensions[0].Statuses[0]
            InProgress = $false
        } -Clobber

    } catch
    {
        Push-OutputBinding -Name Error -Value @{
            VMName = $vmParam.Name 
            ResourceGroupName = $ResourceGroupName
            "Extension status" = $([String]::Format($GenericError,$($Error[0])))
            InProgress = $false
        } -Clobber
    }
} else
{
    Push-OutputBinding -Name Error -Value @{
        VMName = $vmParam.Name 
        ResourceGroupName = $ResourceGroupName
        "Extension status" = "Error: Please pass a vmname and resource group name in the request body."
        InProgress = $false
    } -Clobber
}
