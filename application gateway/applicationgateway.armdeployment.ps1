# [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials 
# Connect-AzAccount
# Select-AzSubscription -Subscription xxxxx


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
-Name $deploymentId
