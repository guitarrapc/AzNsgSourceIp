## Prerequisites

* install pwsh.
* open pwsh
* install az module

```ps1
Install-Module Az -Scope CurrentUser -AllowClobber
```

## signin

```ps1
Connect-AzAccount
```

## Sample

```powershell
Import-Module Az
Import-Module .\AzNsgSourceIp.psm1

$checkip = "8.8.8.8" # YOUR IP
[string[]]$newip = @("4.4.4.4") # YOUR NEW IP
$adjustPriority = -1 # Relative priority from current

# get current and prepare new
$details = Get-AzureNSGSecurityGroupDetail -CheckIp $checkip -IpMappingName NEWRULE
# sampling
$detail = $details | select -First 1
# add new rule 
$newRule = New-AzureNSGSecurityGroupRule -NewName $detail.NewRuleName -NewSourceAddressPrefix $newip -Detail $detail -AdjustPriority -1
$param = @{
    Name = $newRule.Name
    NetworkSecurityGroup = $newRule.NetworkSecurityGroup
    Protocol = $newRule.Protocol
    SourcePortRange = $newRule.SourcePortRange
    DestinationPortRange = $newrule.DestinationPortRange
    SourceAddressPrefix = $newrule.SourceAddressPrefix
    DestinationAddressPrefix = $newrule.DestinationAddressPrefix
    SourceApplicationSecurityGroup = $newRule.SourceApplicationSecurityGroup
    DestinationApplicationSecurityGroup = $newRule.DestinationApplicationSecurityGroups
    Access = $newRule.Access
    Priority = $newrule.Priority
    Direction = $newRule.Direction
    DefaultProfile = $newRule.DefaultProfile
}
Add-AzNetworkSecurityRuleConfig @param
# commit change
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newrule.NetworkSecurityGroup
```

# run

```powershell
Import-Module Az
Import-Module .\AzNsgSourceIp.psm1

$checkip = "8.8.8.8"
[string[]]$newip = @("4.4.4.4")
$adjustPriority = -1

$details = Get-AzureNSGSecurityGroupDetail -CheckIp $checkip -IpMappingName NEWRULE
foreach ($detail in $details) {
    $newRule = New-AzureNSGSecurityGroupRule -NewName $detail.NewRuleName -NewSourceAddressPrefix $newip -Detail $detail -AdjustPriority -1
    $param = @{
        Name = $newRule.Name
        NetworkSecurityGroup = $newRule.NetworkSecurityGroup
        Protocol = $newRule.Protocol
        SourcePortRange = $newRule.SourcePortRange
        DestinationPortRange = $newrule.DestinationPortRange
        SourceAddressPrefix = $newrule.SourceAddressPrefix
        DestinationAddressPrefix = $newrule.DestinationAddressPrefix
        SourceApplicationSecurityGroup = $newRule.SourceApplicationSecurityGroup
        DestinationApplicationSecurityGroup = $newRule.DestinationApplicationSecurityGroups
        Access = $newRule.Access
        Priority = $newrule.Priority
        Direction = $newRule.Direction
        DefaultProfile = $newRule.DefaultProfile
    }
    # check
    #New-AzNetworkSecurityRuleConfig @param
    # Add
    Add-AzNetworkSecurityRuleConfig @param
    # Commit
    Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newrule.NetworkSecurityGroup
}
```

## Ref

> https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-1.2.0