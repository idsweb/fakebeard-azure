# Basic ARM template deployment

## Prerequisites
You should have Visual Studion Code set up to create ARM templates with the extension.

To create a basic arm template with the extension type 
`arm! and press return`.

This will give you the basic structure
``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [],
    "outputs": {},
    "functions": []
}
```
To connect to Azure run:
```
Connect-AzAccount
Select-AzSubscription -Subscription subscriptionid
```
To deploy this create a new PowerShell deployment create a resource group if needed.
``` PowerShell
# Connect-AzAccount
# Select-AzSubscription -Subscription 59c33456-2122-4779-82e0-b3022b7ed84b

$resourcegroupname = 'rg-name-ide'
$location = 'location'
$rg = Get-AzResourceGroup -Name $resourcegroupname -ErrorAction SilentlyContinue

if(-not $rg){
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}
```
To test your template run this command:
```
$templatePath = 'somepath.json'

Test-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Verbose
```
To run the actual template run this:
```
$deploymentId = New-Guid
New-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroupName `
-TemplateFile $templatePath `
-Name $deploymentId 
```
Its useful to have a name for your deployments so you can review them in the portal
without them overwriting each other.

Tip - if you are creating globally unique named resources then you can suffix them with unique string. The basic template below shows this.
``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {
        "resourceSuffix":"[uniqueString(subscription().subscriptionId)]"
    },
    "resources": [],
    "outputs": {
        "resourceSuffix":{
            "type":"string",
            "value":"hello"
        }
    },
    "functions": []
}
```