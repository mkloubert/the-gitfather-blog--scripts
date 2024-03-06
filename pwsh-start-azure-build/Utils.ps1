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

function Get-BuildSettings {
    <#
        .SYNOPSIS
            Scans for current public IP.

        .PARAMETER CMDArgs
            List of command line arguments

        .EXAMPLE
            $settings = Get-BuildSettings $args

            Extracts build settings and returns them as object.
    #>

    param (
        $CMDArgs
    )

    if ($CMDArgs.Count -lt 3) {
        Write-Error "Not enough arguments. Please specify at least 3 arguments."
        exit 1
    }

    $projectId = $CMDArgs[0].ToString().Trim()
    if ($subscriptionId -eq "") {
        Write-Error "Incorrect argument. Please provide project ID as the first argument."
        exit 2
    }

    $buildId = $CMDArgs[1].ToString().Trim()
    if ($resourceGroup -eq "") {
        Write-Error "Incorrect argument. Please provide build ID as the second argument."
        exit 2
    }

    $branchName = $CMDArgs[2].ToString().Trim()
    if ($serverName -eq "") {
        Write-Error "Incorrect argument. Please provide branch name as the third argument."
        exit 2
    }

    return @{
        Branch = $branchName
        Build = $buildId
        Project = $projectId
    }
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