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

Get-EnvVarsFromFile

$buildSettings = Get-BuildSettings $args

# example: https://dev.azure.com/<YOUR-ORGANIZATION>
$azureDevOpsOrgURL = $Env:TGF_AZURE_DEVOPS_ORGURL
# generate at https://dev.azure.com/<YOUR-ORGANIZATION>/_usersSettings/tokens
$azureDevOpsPAT = $Env:TGF_AZURE_DEVOPS_PAT

# create value for Basic Auth
$basicAuth = ":$($azureDevOpsPAT)"
$base64Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($basicAuth))

# the full ID of the branch
$refName = "refs/heads/$($buildSettings.Branch)"

# now do the API request ...

$url = "$($azureDevOpsOrgURL)/" `
    + [System.Web.HttpUtility]::UrlEncode($buildSettings.Project) `
    + "/_apis/pipelines/" `
    + [System.Web.HttpUtility]::UrlEncode($buildSettings.Build) `
    + "/runs?api-version=6.1-preview.1"

$headers = @{
    "Authorization" = "Basic $($base64Auth)"
    "Content-Type" = "application/json"
}

$json = @{
    "resources" = @{
        "repositories" = @{
            "self" = @{
                "refName" = $refName
            }
        }
    }
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $url -Method POST -Headers $headers -Body $json

# output response
$response