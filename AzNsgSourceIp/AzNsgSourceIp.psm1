#Required -Version 6.1
#required -Module Az
using namespace Microsoft.Azure.Commands.Network.Models
using namespace System.Collections.Generic

class AzureNSGSecurityGroupDetail{
    [PSNetworkSecurityGroup]$NetworkSecurityGroup
    [PSSecurityRule]$NetworkSecurityRule
    [string]$CurrentRuleName
    [string]$NewRuleName

    AzureNSGSecurityGroupDetail([PSNetworkSecurityGroup]$sg, [PSSecurityRule]$rule, [string]$name) {
        $this.NetworkSecurityGroup = $sg
        $this.NetworkSecurityRule = $rule
        $this.CurrentRuleName = $rule.Name
        $this.NewRuleName = $name
    }
}

class AzureNSGSecurityGroupRule{
    [string]$Name
    [PSNetworkSecurityGroup]$NetworkSecurityGroup
    [string]$Description
    [string]$Protocol
    [IList[string]]$SourcePortRange
    [IList[string]]$DestinationPortRange
    [IList[string]]$SourceAddressPrefix
    [IList[string]]$DestinationAddressPrefix
    [List[PSApplicationSecurityGroup]]$SourceApplicationSecurityGroup
    [List[PSApplicationSecurityGroup]]$DestinationApplicationSecurityGroups
    [string]$Access
    [int]$Priority
    [string]$Direction
    [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$DefaultProfile

    AzureNSGSecurityGroupRule([PSNetworkSecurityGroup]$sg, [PSSecurityRule]$rule, [string]$name, [System.Collections.Generic.IList[string]]$sourceAddressPrefix) {
        $this.NetworkSecurityGroup = $sg
        $this.Name = $name
        $this.Description = $rule.Description
        $this.Protocol = $rule.Protocol
        $this.SourcePortRange = $rule.SourcePortRange
        $this.DestinationPortRange = $rule.DestinationPortRange
        $this.SourceAddressPrefix = $sourceAddressPrefix
        $this.DestinationAddressPrefix = $rule.DestinationAddressPrefix
        $this.SourceApplicationSecurityGroup = $rule.SourceApplicationSecurityGroup
        $this.DestinationApplicationSecurityGroups = $rule.DestinationApplicationSecurityGroup
        $this.Access = $rule.Access
        $this.Priority = $rule.Priority
        $this.Direction = $rule.Direction
        $this.DefaultProfile = $rule.DefaultProfile
    }
}

function Get-AzureNSGSecurityGroupDetail {
    [OutputType([AzureNSGSecurityGroupDetail[]])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$CheckIp,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$IpMappingName
    )

    # {ACCESS}_MAPPING_{PORT_MAPPING}
    $ruleFormat = "{0}_${IpMappingName}_{1}"
    $portUsageMapping = @{
        "22" = "SSH"
        "443" = "HTTPS"
        "80" = "HTTP"
        "*" = "ALL"
    }

    Get-AzNetworkSecurityGroup -PipelineVariable sg | 
        Get-AzNetworkSecurityRuleConfig -PipelineVariable rule |
        Where-Object {($_.SourceAddressPrefix | Where-Object {$_.StartsWith($checkip)} | Measure-Object).Count -ne 0} |
        ForEach-Object {
            # get port name mapping (use mapping or fallover to PORT+PORTNUM)
            $map = $portUsageMapping[$rule.DestinationPortRange[0]]
            if ($null -eq $map) {
                $map = "PORT" + $rule.DestinationPortRange[0]
            }
            # gen new name
            $ruleName = [string]::Format($ruleFormat, $rule.Access, $map)
            # result
            $r = [AzureNSGSecurityGroupDetail]::new($sg, $rule, $ruleName)
            return $r
            
        }
}

function New-AzureNSGSecurityGroupRule {
    [OutputType([AzureNSGSecurityGroupRule])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$NewName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Collections.Generic.IList[string]]$NewSourceAddressPrefix,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AzureNSGSecurityGroupDetail]$Detail,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [int]$AdjustPriority
    )

    $rule = [AzureNSGSecurityGroupRule]::New($Detail.NetworkSecurityGroup, $Detail.NetworkSecurityRule, $NewName, $NewSourceAddressPrefix)
    $rule.Priority += $AdjustPriority
    Write-Output $rule
}