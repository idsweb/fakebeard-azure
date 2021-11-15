# Connect-AzAccount
# Select-AzSubscription -Subscription xxxxx

$resourcegroupname = 'rg-applicationgatewaydemo-ide'
$templatePath = 'azuredeploy.appgatewayonly.json'

$resourceGroup = Get-AzResourceGroup -Name $resourcegroupname -ErrorAction SilentlyContinue

if($resourceGroup -eq $null){
    New-AzResourceGroup -Name $resourcegroupname -Location 'uksouth'
}

Test-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Verbose

$deploymentId = New-Guid
New-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Name $deploymentId -Mode Incremental