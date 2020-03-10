# Connect-AzAccount
# Select-AzSubscription -Subscription xxxxx

$resourcegroupname = 'rg-applicationgatewaydemo-ide'
$templatePath = 'azuredeploy.appgatewayonly.json'

Test-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Verbose

$deploymentId = New-Guid
New-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Name $deploymentId -Mode Incremental