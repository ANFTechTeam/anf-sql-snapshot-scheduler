# ANF SQL Server Snapshot scheduler

to work on this project you need Powershell 6 Core as 7 isn't ready yet in Azure Function.
to install it :

``` shell
brew install powershell@6.2.4
brew 
```

## Functions

### checkInstall

```mermaid
sequenceDiagram
	HTTP Trigger ->>+ Azure Function : POST /api/checkInstall { ResourceGroupName, VMName }
	Azure Function ->>+ Azure Subscription: get tag list of VM
	Azure Subscription ->>+  Azure Function: Give list of Tags
	Azure Function ->>+  Azure Function: Check if Netapp Tags exist
	Azure Function ->>+  HTTP Trigger: if NetApp Tag is "True"
	Azure Function ->>+ Azure Subscription: is the VM On?
					
```

this function need a POST request on 