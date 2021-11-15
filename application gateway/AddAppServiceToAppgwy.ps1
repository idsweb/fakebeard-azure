<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    Param
    (
        # Param1 the application gateway name
        [Parameter(Mandatory=$true)]
        $appGatewayName,

        # Param2 help description
        $appGwPublicFrontendIp
    )

#$sslCertName = "wilcardCertificate"
$appGateway = Get-AzApplicationGateway -Name $appGatewayName
if(-not($appGateway)){
    Write-Host "Cannot find the Application Gateway"
    return
}
$appGwPublicFrontendIp = Get-AzApplicationGatewayFrontendIPConfig -ApplicationGateway $appGateway -Name $appGwPublicFrontendIp
$port_443 =  Get-AzApplicationGatewayFrontendPort -ApplicationGateway $appGateway -Name 'port_443'
#$sslCert = Get-AzApplicationGatewaySslCertificate -ApplicationGateway $appGateway -Name $sslCertName

if(-not($appGateway)){
    Write-Host "Cannot find the Application Gateway"
    return
}

function AddAppServiceHttpsListener {
    param (
        $listenerName,
        $hostName
    )
    $listener = Get-AzApplicationGatewayHttpListener -ApplicationGateway $appGateway -Name $listenerName -ErrorAction SilentlyContinue
    if(-not($listener)){
        Add-AzApplicationGatewayHttpListener -ApplicationGateway $appGateway `
            -Name $listenerName `
            -FrontendIPConfiguration $appGwPublicFrontendIp `
            -FrontendPort $port_443 `
            -Protocol "Https" `
            -SslCertificate $sslCert `
            -HostName $hostName
            Set-AzApplicationGateway -ApplicationGateway $appGateway            
    }
    else{
        Write-Host "The HttpListener $listenerName already exists"
    }
}

function AddBackendPool {
    param (
        $backendPoolName,
        $backendFqdns
    )
    # Create the back end pool
    $pool = Get-AzApplicationGatewayBackendAddressPool -Name $backendPoolName -ApplicationGateway $appGateway -ErrorAction SilentlyContinue
    if(-not $pool){
        $appGateway = Add-AzApplicationGatewayBackendAddressPool `
        -ApplicationGateway $appGateway `
        -BackendFqdns $backendFqdns `
        -Name $backendPoolName

        Set-AzApplicationGateway -ApplicationGateway $appGateway        
    }
    else{
        Write-Host "Back end pool with name $backendPoolName already exists"
    }
}

function AddRoutingRule {
    param (
        $ruleName,
        $httpListenerName,
        $backendAddressPoolName,
        $httpSettingsName
    )

    $rule = Get-AzApplicationGatewayRequestRoutingRule -ApplicationGateway $appGateway -Name $ruleName -ErrorAction SilentlyContinue

    if(-not $rule){

        $listener = Get-AzApplicationGatewayHttpListener -Name $httpListenerName -ApplicationGateway $appGateway | select Id
        $pool = Get-AzApplicationGatewayBackendAddressPool -Name $backendAddressPoolName -ApplicationGateway $appGateway | select Id
        $backendHttpSetting = Get-AzApplicationGatewayBackendHttpSetting -Name $httpSettingsName -ApplicationGateway $appGateway | select Id

        $appGateway = Add-AzApplicationGatewayRequestRoutingRule `
        -ApplicationGateway $appGateway `
        -Name $ruleName `
        -RuleType 'Basic' `
        -BackendHttpSettingsId $backendHttpSetting.Id `
        -HttpListenerId $listener.Id `
        -BackendAddressPoolId $pool.Id

        Set-AzApplicationGateway -ApplicationGateway $appGateway        
    }
    else{
        Write-Host "Request routing rule $ruleName already exists"
    }
}

function AddProbe {
    param (
        $probeName,
        $path,
        $matchBody,
        $statusCodes
    )
    $probe = Get-AzApplicationGatewayProbeConfig -ApplicationGateway $appGateway -Name $probeName -ErrorAction SilentlyContinue 
    if(-not($probe)){
        # Create the match object
        $match = New-Object -TypeName 'Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayProbeHealthResponseMatch'
        $match.Body = $matchBody
        $match.StatusCodes = $statusCodes

        $appGateway = Add-AzApplicationGatewayProbeConfig -ApplicationGateway $appGateway `
        -Name $probeName `
        -Protocol 'https' `
        -Path $path `
        -Interval 30 `
        -Timeout 30 `
        -UnhealthyThreshold 3 `
        -PickHostNameFromBackendHttpSettings `
        -Match $match
        
        Set-AzApplicationGateway -ApplicationGateway $appGateway
    }
    else{
        Write-Host "The probe $probeName already exists"
    }
}

function AddBackendHttpsSetting {
    param (
        $settingName,
        $probeName
    )
    $setting = Get-AzApplicationGatewayBackendHttpSetting -Name $settingName -ApplicationGateway $appGateway -ErrorAction SilentlyContinue
    $probe = Get-AzApplicationGatewayProbeConfig -ApplicationGateway $appGateway -Name $probeName | select Id
    if(-not($setting)){
        $appGateway = Add-AzApplicationGatewayBackendHttpSetting -ApplicationGateway $appGateway `
            -Name $settingName `
            -Protocol 'Https' `
            -Port 443 `
            -CookieBasedAffinity "Disabled" `
            -Probe $probe `
            -PickHostNameFromBackendAddress
        Set-AzApplicationGateway -ApplicationGateway $appGateway
    }
    else{
        Write-Host "Setting $settingName already exists"
    }
}

function ConfigureAppGatewayForSubdomain {
    param (
        $probeName,
        $path,
        $statusCodes,
        $matchBody,
        $settingName,
        $backendFqdns,
        $backendPoolName,
        $listenerName,
        $hostName,
        $ruleName
    )

    # 1. Create the backend probe
    AddProbe -probeName $probeName -path $path -statusCodes $statusCodes -matchBody $matchBody

    # 2. Create the Https settings - this uses the probe above
    AddBackendHttpsSetting -settingName $settingName -probeName $probeName

    # 3. Create the backend pool
    AddBackendPool -backendFqdns $backendFqdns -backendPoolName $backendPoolName

    # 4. Add a HttpListener
    AddAppServiceHttpsListener -listenerName $listenerName -hostName $hostName    

    # 5. Add a request routing rule
    AddRoutingRule -ruleName $ruleName `
    -httpListenerName $listenerName `
    -backendAddressPoolName $backendPoolName `
    -httpSettingsName $settingName
}



<#
# Create the Httplisteners and BackendPool for services
# =====================================================
$subdomain = 'services'
$environments = 'int', 'act', 'prod' #@('dev')
$environments | ForEach-Object { 

    $listenerName = 
    if($_ -like 'prod'){
        $hostName = "$subdomain.leeds.gov.uk"
    }
    else{
        $hostName = "$subdomain-$_.leeds.gov.uk"
    }

    ConfigureAppGatewayForSubdomain  `
        -path '/' `
        -statusCodes '200' `
        -matchBody '' `
        -settingName "$subdomain-$_-httpsettings" `
        -probeName "$subdomain-$_-probe" `
        -backendFqdns "azapp-cats-$_-001.azurewebsites.net" `
        -backendPoolName "$subdomain-$_-backendpool" `
        -listenerName "$subdomain-$_-listener" `
        -hostName $hostName `
        -ruleName "$subdomain-$_-rule" `
        -httpListenerName $listenerName `
        -backendAddressPoolName "$subdomain-$_-backendpool" `
        -httpSettingsName "$subdomain-$_-httpsettings"
}
#>
