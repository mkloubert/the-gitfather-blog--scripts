<#

MIT License

Copyright (c) 2024 Marcel Joachim Kloubert (https://marcel.coffee)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>

function Get-AzureAccessToken {
    <#
        .SYNOPSIS
            Returns the access token for an Azure operation.

        .EXAMPLE
            $accessToken = Get-AzureAccessToken

            Load and write access token to variable.
    #>

    # collect data for request
    $clientId = $Env:TGF_AZURE_AD_CLIENT_ID
    $clientSecret = $Env:TGF_AZURE_AD_CLIENT_SECRET
    $tenantId = $Env:TGF_AZURE_AD_TENANT_ID

    # request URL
    $url = "https://login.microsoftonline.com/" `
        + [System.Web.HttpUtility]::UrlEncode($tenantId) `
        + "/oauth2/token"

    # HTTP request headers
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }

    # build body
    $formData = "grant_type="+[System.Web.HttpUtility]::UrlEncode("client_credentials") `
        + "&client_id="+[System.Web.HttpUtility]::UrlEncode($clientId) `
        + "&client_secret="+[System.Web.HttpUtility]::UrlEncode($clientSecret) `
        + "&resource="+[System.Web.HttpUtility]::UrlEncode("https://management.azure.com/")

    $response = Invoke-RestMethod -Uri $url -Method POST -Headers $headers -Body $formData

    # as a common OAuth2 response, the access token
    # is in `access_token` of $response
    return $response.access_token
}

function Get-EnvVarsFromFile {
    <#
        .SYNOPSIS
            Loads and parses an .env.local file, if exists, and updates the environment variables from the current process.

        .EXAMPLE
            Get-EnvVarsFromFile

            Loads and updates environment variables from .env.local file.
    #>

    $envFile = ".\.env.local"
    
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            $line = $_.Trim()
            if (-not [string]::IsNullOrEmpty($line) -and -not $line.StartsWith("#")) {
                $envVar = $line.Split("=")
                
                if ($envVar.Length -eq 2) {
                    $name = $envVar[0].Trim()

                    $value = $envVar[1].Trim()
                    if ($value.StartsWith("""")) {
                        $value = $value.Substring(1)
                    }
                    if ($value.EndsWith("""")) {
                        $value.Substring(0, $value.Length - 1)
                    }

                    [Environment]::SetEnvironmentVariable($name, $value, "Process")
                }
            }
        }
    }
}

function Get-MyIP {
    <#
        .SYNOPSIS
            Scans for current public IP.

        .EXAMPLE
            $myIP = Get-MyIP

            Load and write IP to variable.
    #>

    $url = "https://api.ipify.org"

    $response = Invoke-RestMethod -Uri $url -Method GET

    return $response.ToString()
}

function Get-PostgresSettings {
    <#
        .SYNOPSIS
            Returns PostgreSQL settings.

        .PARAMETER CMDArgs
            List of command line arguments

        .EXAMPLE
            $settings = Get-PostgresSettings $args

            Extracts PostgreSQL server settings and returns them as object.
    #>

    param (
        $CMDArgs
    )

    if ($CMDArgs.Count -lt 4) {
        Write-Error "Not enough arguments. Please specify at least 4 arguments."
        exit 1
    }

    $subscriptionId = $CMDArgs[0].ToString().Trim()
    if ($subscriptionId -eq "") {
        Write-Error "Incorrect argument. Please provide subscription ID as the first argument."
        exit 2
    }

    $resourceGroup = $CMDArgs[1].ToString().Trim()
    if ($resourceGroup -eq "") {
        Write-Error "Incorrect argument. Please provide resource group as the second argument."
        exit 2
    }

    $serverName = $CMDArgs[2].ToString().Trim()
    if ($serverName -eq "") {
        Write-Error "Incorrect argument. Please provide server name as the third argument."
        exit 2
    }

    $ruleName = $CMDArgs[3].ToString().Trim()
    if ($ruleName -eq "") {
        Write-Error "Incorrect argument. Please provide firewall rule name as the fourth argument."
        exit 2
    }

    return @{
        ResourceGroup = $resourceGroup
        Rule = $ruleName
        Server = $serverName
        Subscription = $subscriptionId
    }
}
