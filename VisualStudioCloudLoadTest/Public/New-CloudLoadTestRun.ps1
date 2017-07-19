Function New-CloudLoadTestRun{
[cmdletbinding()]
Param(
    
    [Parameter(Mandatory=$True)]
    [hashtable]
    $Headers,

    [Parameter(Mandatory=$True)]
    [ValidateScript({
      # Check if valid Uri
        $IsValidUri = [system.uri]::IsWellFormedUriString($_,[System.UriKind]::Absolute)
        if ($IsVAlidUri -eq $True){
            return $True
        }
        else{
            throw "Parameter value is not valid '$_'"
        }
    })] 
    [string]
    $BaseUri,

    [Parameter(Mandatory=$True)]
    [Object[]]
    $TestDrop,

    [Parameter(Mandatory=$True)]
    [string]
    $LoadTestFileName,

    [Parameter(Mandatory=$True)]
    [string]
    $LoadTestDescription

)

    try{

        $Uri = "$BaseUri/{0}" -f "_apis/clt/testruns"
        $Body = @{
            Description = $LoadTestDescription
            Name = $LoadTestFileName
            State = 0
            SubState = 0
            TestDrop = @{
                Id = $TestDrop.Id
            }
            TestSettings = @{
                CleanupCommand = $null
                SetupCommand = $null

            }
        } | ConvertTo-Json
        $TestRunResponse = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body
        Write-Verbose ("Test Run Id = '{0}'" -f $TestRunResponse.Id)

        Return $TestRunResponse

    }
    catch{
        throw $_
    }

}