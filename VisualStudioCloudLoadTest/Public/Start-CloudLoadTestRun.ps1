Function Start-CloudLoadTestRun{
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
    [guid]
    $TestRunId,

    [Parameter(Mandatory=$False)]
    [validaterange(1,600)]
    [int]
    $TimeoutMinutes = 60,

    [Parameter(Mandatory=$False)]
    [validaterange(10,600)]
    [int]
    $PollingIntervalSeconds = 30

)

    try{

        $Uri = "$BaseUri/{0}/{1}" -f "_apis/clt/testruns", $TestRunId
        $Body = @{
            SubState = 0
            State = 1
        } | ConvertTo-Json
        $StartTestRunResponse = Invoke-RestMethod -Uri $Uri -Method Patch -Headers $Headers -Body $Body

        # Wait for test run to start
        $Timer = [System.Diagnostics.Stopwatch]::StartNew()
        do{
            Start-Sleep -Seconds $PollingIntervalSeconds            
            $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
            Write-Output ("Test Run: State = '{0}'" -f $Response.state)
        }
        Until(
            ($Response.state -ne "queued") -or
            ($Timer.Elapsed.TotalMinutes -gt $TimeoutMinutes)
        )

    }
    catch{
        throw $_
    }

}