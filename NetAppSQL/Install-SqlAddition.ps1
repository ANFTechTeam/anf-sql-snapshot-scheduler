 
try
{
    if(!$(Test-Path -Path 'C:\temp')){
        New-Item -ItemType Directory -Name "c:\temp"
    }
    $param = @{
        UseBasicParsing = $true
        Uri = "https://azuresqlbackupdev.blob.core.windows.net/addition/ScSqlApi.zip?sp=r&st=2020-05-15T07:05:32Z&se=2020-06-30T15:05:32Z&spr=https&sv=2019-10-10&sr=b&sig=cSOs9p%2FlUIkT4Um18HVchSS3su1eBFFjtYkdGqrAE%2Fc%3D"
        OutFile = "c:\temp\ScSqlApi.zip"
    }
    Invoke-WebRequest @param
    Expand-Archive $param.OutFile -DestinationPath "C:\Program Files\NetApp\ScSqlApi" -Force
    
    $ServiceData = @{
        service = 'ScSqlApi'
        path = 'C:\Program Files\NetApp\ScSqlApi\' 
    }
    
    Set-Location $ServiceData.path
    
    New-Service -Name $ServiceData.service -BinaryPathName 'C:\Program Files\NetApp\ScSqlApi\ScSqlApiServiceHost.exe'
    Set-Service -Name $ServiceData.service -StartupType Automatic 
    Start-Service -Name $ServiceData.service
    Get-Service -Name $ServiceData.service
    return 0
} catch
{
    return $error
} 
    