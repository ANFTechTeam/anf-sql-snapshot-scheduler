# ANF SQL Server Snapshot scheduler

to work on this project you need Powershell 6 Core as 7 isn't ready yet in Azure Function.
to install it :

``` shell
brew install powershell@6.2.4
brew 
```

## Functions

### checkInstall

[![](https://mermaid.ink/img/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG5cdEhUVFAgVHJpZ2dlciAtPj4rIEF6dXJlIEZ1bmN0aW9uIDogUE9TVCAvYXBpL2NoZWNrSW5zdGFsbCB7IFJlc291cmNlR3JvdXBOYW1lLCBWTU5hbWUgfVxuICBhY3RpdmF0ZSBBenVyZSBGdW5jdGlvblxuICBsb29wIEdldCBWTSBUYWdzXG4gICAgICBBenVyZSBGdW5jdGlvbiAtPj4rIEF6dXJlIFN1YnNjcmlwdGlvbjogZ2V0IHRhZyBsaXN0IG9mIFZNXG4gICAgQXp1cmUgU3Vic2NyaXB0aW9uIC0-PisgIEF6dXJlIEZ1bmN0aW9uOiBHaXZlIGxpc3Qgb2YgVGFnc1xuICAgIG9wdCBUYWcgdmFsdWUgaXMgXCJ0cnVlXCJcbiAgICAgQXp1cmUgRnVuY3Rpb24gLS0-PiAgSFRUUCBUcmlnZ2VyOiBpZiBOZXRBcHAgVGFnIGlzIFwiVHJ1ZVwiXG4gICAgZW5kXG4gICAgbG9vcCBUYWcgaXMgTWlzc2luZyBvciBGYWxzZVxuICAgICAgQXp1cmUgRnVuY3Rpb24gLT4-KyBBenVyZSBTdWJzY3JpcHRpb246IFZNIFN0YXRlP1xuICAgICAgQXp1cmUgU3Vic2NyaXB0aW9uIC0-PisgQXp1cmUgRnVuY3Rpb24gOiBWTSBTdGF0ZVxuICAgICAgYWx0IHZtIGlzIE9mZlxuICAgICAgICBBenVyZSBGdW5jdGlvbiAtPj4rIEF6dXJlIFN1YnNjcmlwdGlvbjogU3RhcnQgVk1cbiAgICAgIGVuZFxuICAgICAgQXp1cmUgRnVuY3Rpb24gLT4-KyBWTSA6IEV4ZWN1dGUgcnVuY29tbWFuZFxuICAgICAgVk0gLT4-KyBBenVyZSBGdW5jdGlvbjogUmVzdWx0XG4gICAgICBBenVyZSBGdW5jdGlvbiAtPj4rIEF6dXJlIFN1YnNjcmlwdGlvbjogU2V0IFRhZyB3aXRoIFJlc3VsdFxuICAgIGVuZFxuICBlbmRcbiAgICAgICAgQXp1cmUgRnVuY3Rpb24gLT4-KyBIVFRQIFRyaWdnZXI6IFJlc3VsdFxuIiwibWVybWFpZCI6eyJ0aGVtZSI6ImRlZmF1bHQifSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG5cdEhUVFAgVHJpZ2dlciAtPj4rIEF6dXJlIEZ1bmN0aW9uIDogUE9TVCAvYXBpL2NoZWNrSW5zdGFsbCB7IFJlc291cmNlR3JvdXBOYW1lLCBWTU5hbWUgfVxuICBhY3RpdmF0ZSBBenVyZSBGdW5jdGlvblxuICBsb29wIEdldCBWTSBUYWdzXG4gICAgICBBenVyZSBGdW5jdGlvbiAtPj4rIEF6dXJlIFN1YnNjcmlwdGlvbjogZ2V0IHRhZyBsaXN0IG9mIFZNXG4gICAgQXp1cmUgU3Vic2NyaXB0aW9uIC0-PisgIEF6dXJlIEZ1bmN0aW9uOiBHaXZlIGxpc3Qgb2YgVGFnc1xuICAgIG9wdCBUYWcgdmFsdWUgaXMgXCJ0cnVlXCJcbiAgICAgQXp1cmUgRnVuY3Rpb24gLS0-PiAgSFRUUCBUcmlnZ2VyOiBpZiBOZXRBcHAgVGFnIGlzIFwiVHJ1ZVwiXG4gICAgZW5kXG4gICAgbG9vcCBUYWcgaXMgTWlzc2luZyBvciBGYWxzZVxuICAgICAgQXp1cmUgRnVuY3Rpb24gLT4-KyBBenVyZSBTdWJzY3JpcHRpb246IFZNIFN0YXRlP1xuICAgICAgQXp1cmUgU3Vic2NyaXB0aW9uIC0-PisgQXp1cmUgRnVuY3Rpb24gOiBWTSBTdGF0ZVxuICAgICAgYWx0IHZtIGlzIE9mZlxuICAgICAgICBBenVyZSBGdW5jdGlvbiAtPj4rIEF6dXJlIFN1YnNjcmlwdGlvbjogU3RhcnQgVk1cbiAgICAgIGVuZFxuICAgICAgQXp1cmUgRnVuY3Rpb24gLT4-KyBWTSA6IEV4ZWN1dGUgcnVuY29tbWFuZFxuICAgICAgVk0gLT4-KyBBenVyZSBGdW5jdGlvbjogUmVzdWx0XG4gICAgICBBenVyZSBGdW5jdGlvbiAtPj4rIEF6dXJlIFN1YnNjcmlwdGlvbjogU2V0IFRhZyB3aXRoIFJlc3VsdFxuICAgIGVuZFxuICBlbmRcbiAgICAgICAgQXp1cmUgRnVuY3Rpb24gLT4-KyBIVFRQIFRyaWdnZXI6IFJlc3VsdFxuIiwibWVybWFpZCI6eyJ0aGVtZSI6ImRlZmF1bHQifSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)

```mermaid
sequenceDiagram
	HTTP Trigger ->>+ Azure Function : POST /api/checkInstall { ResourceGroupName, VMName }
  activate Azure Function
  loop Get VM Tags
      Azure Function ->>+ Azure Subscription: get tag list of VM
    Azure Subscription ->>+  Azure Function: Give list of Tags
    opt Tag value is "true"
     Azure Function -->>  HTTP Trigger: if NetApp Tag is "True"
    end
    loop Tag is Missing or False
      Azure Function ->>+ Azure Subscription: VM State?
      Azure Subscription ->>+ Azure Function : VM State
      alt vm is Off
        Azure Function ->>+ Azure Subscription: Start VM
      end
      Azure Function ->>+ VM : Execute runcommand
      VM ->>+ Azure Function: Result
      Azure Function ->>+ Azure Subscription: Set Tag with Result
    end
  end
        Azure Function ->>+ HTTP Trigger: Result
```

this function need a POST request on 