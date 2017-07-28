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
    $PollingIntervalSeconds = 30,

    [Parameter(Mandatory = $False)]
    [bool]
    $OutputTeamCityServiceMessages = $True

)

    $FinishedStates = @(
        "completed"
        "aborted"
        "error"
    )

    try{
        $Uri = "$BaseUri/{0}/{1}" -f "_apis/clt/testruns", $TestRunId
        $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
        Write-Output ("Test Run: State = '{0}', Name ='{1}', Number = '{2}', id = '{3}', Web Url = '{4}'" -f $Response.state, $Response.name, $Response.runNumber, $Response.id, $Response.webResultUrl)

        if ($OutputTeamCityServiceMessages -eq $True){
                Write-Host ("##teamcity[testStarted name='{0}']" -f $Response.name)
        }
        
        # Wait for test to complete
        $Timer = [System.Diagnostics.Stopwatch]::StartNew()
        do{
            $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

            if ($Response.state -in $FinishedStates){
                Break
            }

            $DurationSeconds = [math]::min([int]$Timer.Elapsed.TotalSeconds,[int]$Response.runSpecificDetails.duration)
            Write-Output ("Test Run: State = '{0}', duration = {1}/{2}" -f $Response.state, $DurationSeconds, [int]$Response.runSpecificDetails.duration)
            if ($OutputTeamCityServiceMessages -eq $True){
                Write-Host ("##teamcity[progressMessage 'Test Run: State = {0}, duration = {1}/{2}']" -f $Response.state, $DurationSeconds, [int]$Response.runSpecificDetails.duration)
            }
            Start-Sleep -Seconds $PollingIntervalSeconds
        }
        Until(
            ($Response.state -in $FinishedStates) -or
            ($Timer.Elapsed.TotalMinutes -gt $TimeoutMinutes)
        )

        $TestRunMessages = Get-CloudLoadTestRunMessages -Headers $Headers -BaseUri $BaseUri -TestRunId $TestRunId -OutputTeamCityServiceMessages $OutputTeamCityServiceMessages
        $TestRunErrors = Get-CloudLoadTestRunErrors -Headers $Headers -BaseUri $BaseUri -TestRunId $TestRunId -OutputTeamCityServiceMessages $OutputTeamCityServiceMessages

        switch ($Response.state){
            "aborted"{
                $Response.abortMessage.cause | Write-Error
                $Response.abortMessage.action | Write-Error
                if ($OutputTeamCityServiceMessages -eq $True){
                    $Cause = Escape-TeamCityServiceMessageString -InputString $Response.abortMessage.cause
                    $Action = Escape-TeamCityServiceMessageString -InputString $Response.abortMessage.action
                    Write-Host ("##teamcity[buildProblem description='{0}: {1} - {2}' identity='abortMessage']" -f $Response.abortMessage.source, $Cause ,$Action )
                    Write-Host ("##teamcity[testFailed name='{0}' message='{1}' details='{2}']" -f $Response.Name, $Cause, $Action)
                    Write-Host ("##teamcity[testFinished name='{0}']" -f $Response.name)
                }
                throw ("Test Run: Number = '{0}', id = '{1}' completed with state '{2}'" -f $Response.runNumber, $Response.id, $Response.state)
            }

            default{
                Write-Output ("Test Run: Number = '{0}', id = '{1}' completed with state '{2}'" -f $Response.runNumber, $Response.id, $Response.state)
                if ($OutputTeamCityServiceMessages -eq $True){
                    Write-Host ("##teamcity[progressMessage 'Test Run: State = {0}, duration = {1}/{2}']" -f $Response.state, [int]$DurationSeconds, [int]$Response.runSpecificDetails.duration)
                    Write-Host ("##teamcity[testFinished name='{0}']" -f $Response.name)
                }                
            }

        }

    }
    catch{
        throw $_
    }

}