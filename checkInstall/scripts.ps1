$path = Test-Path "C:\Program Files\NetApp\ScSqlApi"
$service =  (Get-Service -Name ScSQLApi -ea SilentlyContinue ).Status
if($path -eq $true -and $service -eq "running" ){
    $true
}else{
    $false
}