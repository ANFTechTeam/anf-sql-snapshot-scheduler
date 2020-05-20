Set-Location 'C:\Program Files\NetApp\ScSqlApi\'
Import-Module .\ScSqlApiPS.dll
 = ConvertTo-SecureString "N3t@pp123456" -AsPlainText -Force
 = New-Object System.Management.Automation.PSCredential ("netapp", )
 = @{
    Database = "test"
    SQLInstance = 'MSSQLSERVER'
    Operation = 'Quiesce'
    Authentication = 'Windows'
    Credential = 
}
New-ScSqlBackup @Param
