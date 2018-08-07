# Gettting started
## Download PowerShell cmdlets
First check your PowerShell verison 
```powershell
$PSVersionTable.PSVersion
```
This needs to be v5.0 

Download and install the cmdlets from [here](https://docs.microsoft.com/en-gb/powershell/azure/install-azurerm-ps?view=azurermps-6.6.0). Note  the pref is to use PowerShell to install it. Update NuGet and accept security warning (read it first!)

```powershell
Install-Module -Name AzureRM
```