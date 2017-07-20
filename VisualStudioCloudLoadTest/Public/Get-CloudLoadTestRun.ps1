Function Get-CloudLoadTestRun{
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

    $FinishedStates = @(
        "completed"
        "aborted"
    )

    try{
        $Uri = "$BaseUri/{0}/{1}" -f "_apis/clt/testruns", $TestRunId
        $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
        Write-Output ("Test Run: State = '{0}', Name ='{1}', Number = '{2}', id = '{3}', Web Url = '{4}'" -f $Response.state, $Response.name, $Response.runNumber, $Response.id, $Response.webResultUrl)
        
        # Wait for test to complete
        $Timer = [System.Diagnostics.Stopwatch]::StartNew()
        do{
            $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

            if ($Response.state -in $FinishedStates){
                Break
            }

            $DurationSeconds = [math]::min([int]$Timer.Elapsed.TotalSeconds,[int]$Response.runSpecificDetails.duration)
            Write-Output ("Test Run: State = '{0}', duration = {1}/{2}" -f $Response.state, $DurationSeconds, [int]$Response.runSpecificDetails.duration)
            Start-Sleep -Seconds $PollingIntervalSeconds
        }
        Until(
            ($Response.state -in $FinishedStates) -or
            ($Timer.Elapsed.TotalMinutes -gt $TimeoutMinutes)
        )

        Get-CloudLoadTestRunMessages -Headers $Headers -BaseUri $BaseUri -TestRunId $TestRunId
        Get-CloudLoadTestRunErrors -Headers $Headers -BaseUri $BaseUri -TestRunId $TestRunId

        switch ($Response.state){
            "aborted"{
                $Response.abortMessage.cause | Write-Warning
                $Response.abortMessage.action | Write-Warning
                throw ("Test Run: Number = '{0}', id = '{1}' completed with state '{2}'" -f $Response.runNumber, $Response.id, $Response.state)
            }

            default{
                Write-Output ("Test Run: Number = '{0}', id = '{1}' completed with state '{2}'" -f $Response.runNumber, $Response.id, $Response.state)                
            }

        }

    }
    catch{
        throw $_
    }

}