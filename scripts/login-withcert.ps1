# Login using the previously created cert

$TenantID = "72325231-6924-49fe-9cb3-124d5649df9a"
$AppID = "687b91f8-3b3b-4b71-a0b6-a1bf2b2084c8"
$Thumbprint = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -match "CN=idsAzureScriptCert"}).Thumbprint
Login-AzureRmAccount -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $AppID -TenantId $TenantID