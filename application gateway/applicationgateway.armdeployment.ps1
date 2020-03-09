# Connect-AzAccount
# Select-AzSubscription -Subscription 59c33456-2122-4779-82e0-b3022b7ed84b

$resourcegroupname = 'rg-applicationgatewaydemo-ide'
$location = 'uksouth'
$rgappgwy = Get-AzResourceGroup -Name $resourcegroupname -ErrorAction SilentlyContinue
$templatePath = 'azuredeploy.appgateway.json'

if(-not $rgappgwy){
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}

Test-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Verbose

$deploymentId = New-Guid
New-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Name $deploymentId -Mode Complete