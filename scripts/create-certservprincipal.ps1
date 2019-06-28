# Use certificate authentication and a service principal

# First login
Login-AzAccount

# Create a certificate and create a service principal
$cert = New-SelfSignedCertificate -CertStoreLocation "cert:\CurrentUser\My" `
    -Subject "CN=idsAzureScriptCert" -KeySpec KeyExchange

$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

$sp = New-AzureRmADServicePrincipal -DisplayName idsApp -CertValue $keyValue `
-EndDate $cert.NotAfter -StartDate $cert.NotBefore

Sleep 30

New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $sp.ApplicationId