# Get-AzureRmResourceGroup | select ResourceGroupName
# Remove-AzureRmResourceGroup -Name binit -Force
# New-AzureRmResourceGroup -Name ids-strg -Location 'West Europe'

<# Set the name of the storage account and the SKU name. 
$storageAccountName = "idsstg"
$skuName = "Standard_LRS"

# Create the storage account.
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName ids-strg `
  -Name $storageAccountName `
  -Location 'West Europe' `
  -SkuName $skuName #>

$stacc = Get-AzureRmStorageAccount -Name 'idsstg' -ResourceGroupName ids-strg

Get-AzureRmStorageAccountKey -ResourceGroupName ids-strg -Name 'idsstg'