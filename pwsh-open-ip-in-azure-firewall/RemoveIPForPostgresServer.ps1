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

# include utilities
. ./Utils.ps1

# ensure all 
Get-EnvVarsFromFile
$postgresSettings = Get-PostgresSettings $args

# get access token for Azure API
Write-Host "Getting Access Token ..."
$accessToken = Get-AzureAccessToken

$url = "https://management.azure.com/subscriptions/" + [System.Web.HttpUtility]::UrlEncode($postgresSettings.Subscription) `
    + "/resourceGroups/"+ [System.Web.HttpUtility]::UrlEncode($postgresSettings.ResourceGroup) `
    + "/providers/Microsoft.DBforPostgreSQL/flexibleServers/"+ [System.Web.HttpUtility]::UrlEncode($postgresSettings.Server) `
    + "/firewallRules/"+[System.Web.HttpUtility]::UrlEncode($postgresSettings.Rule)+"?api-version=2022-12-01"

$headers = @{
    "Authorization" = "Bearer $($accessToken)"
    "Content-Type" = "application/json"
}

Write-Host "Removing rule $($postgresSettings.Rule) for server $($postgresSettings.Server) of group $($postgresSettings.ResourceGroup) ..."

$response = Invoke-RestMethod -Uri $url -Method DELETE -Headers $headers

# output response
$response
