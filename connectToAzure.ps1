<#
.Synopsis
   Azure login helper
.DESCRIPTION
   Helper function to use when interactively logging you into Azure
.EXAMPLE
   ./loginToAzure
#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 your Azure tenantId
        [Parameter(Mandatory=$true)]
        $tenanid,

        # Param1 your Azure subscription
        [Parameter(Mandatory=$true)]
        $subscription,

        # Param2 set when behind a proxy
        [switch]
        $useProxy
    )

    if($useProxy){
        [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    }

    Connect-AzAccount -Tenant $tenanid -Subscription $subscription

