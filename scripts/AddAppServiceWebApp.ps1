<#
.Synopsis
   Create a service app web app using a config file
.DESCRIPTION
   Uses a configuration file in json format to create a resource group, app service plan and web app if any
   of those do not exist.
.EXAMPLE
   . .\AddAppServiceWebApp.ps1
    Get-Content .\config.json | Out-String | ConvertFrom-Json | Add-AzureAppServiceWebApp
#>
function Add-AzureAppServiceWebApp()
{
    [CmdletBinding()]
    Param(
        # Param1 help description
        [Parameter(ValueFromPipeline)]
        $config
    )

    Process{
        
        # Create a service plan in a resource group
        if(-not $config){
            Write-Host Please run get configuration script
            return
        }

        Write-Host Creating resource group if needed

        if(Get-AzureRmResourceGroup -Name $config.resourceGroup.resourceGroupName -Location $config.resourceGroup.location -ErrorAction SilentlyContinue){
            Write-Host $config.resourceGroup.resourceGroupName already exists
        }
        else{
            Write-Host $config.resourceGroup.resourceGroupName does not exist creating
            New-AzureRmResourceGroup -Name $config.resourceGroup.resourceGroupName -Location $config.resourceGroup.location
        }

        Write-Host Create an app service plan

        if(Get-AzureRmAppServicePlan -Name $config.servicePlan.appServicePlanName -ResourceGroupName $config.resourceGroup.resourceGroupName){
            Write-Host App service plan already exists
        }
        else{
            New-AzureRMAppServicePlan -Name $config.servicePlan.appServicePlanName -ResourceGroupName $config.resourceGroup.resourceGroupName -location $config.resourceGroup.location -Tier $config.servicePlan.tier -WorkerSize $config.servicePlan.workerSize
        }

        if(Get-AzureRmWebApp -ResourceGroupName $config.resourceGroup.resourceGroupName -Name $config.webApp.webAppName -ErrorAction SilentlyContinue){
            Write-Host Web App exists already
        }
        else{
            Write-Host Creating web app
            New-AzureRmWebApp -ResourceGroupName $config.resourceGroup.resourceGroupName -Name $config.webApp.webAppName -AppServicePlan $config.servicePlan.appServicePlanName
        }
    }
}
