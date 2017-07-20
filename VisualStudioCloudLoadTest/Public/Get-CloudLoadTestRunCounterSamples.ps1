Function Get-CloudLoadTestRunCounterSamples{
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
    [bool]
    $OutputTeamCityServiceMessages = $False

)

    $CounterSampleValuesAreInMilliseconds = @(
         "Avg. Test Time"
         "Avg. Page Time"
         "Avg. Response Time"
    )
    $Results = @()

    try{

        # Get counter instances
        $QueryString = "groupNames=Performance%2CThroughput%2CApplication"
        $Uri = "$BaseUri/{0}/{1}/counterinstances?{2}" -f "_apis/clt/testruns", $TestRunId, $QueryString
        $CounterInstances = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

        # Get counter samples
        foreach ($CounterInstance in  $CounterInstances.value){

            $Uri = "$BaseUri/{0}/{1}/countersamples" -f "_apis/clt/testruns", $TestRunId
            $Body = @{
                Count = 1
                Value = @(
                    @{
                        CounterInstanceId = $CounterInstance.counterInstanceId
                        FromInterval = 0
                        ToInterval = -1
                    }
                )

            } | ConvertTo-Json            
            $CounterSamples = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body

            $Measure = $CounterSamples.values.values.computedValue | Measure-Object -Minimum -Maximum -Average -Sum
            $Result = [ordered]@{
                CounterName = $CounterInstance.counterName
                Minimum = [math]::Round($Measure.Minimum,3)
                Maximum = [math]::Round($Measure.Maximum,3)
                Average = [math]::Round($Measure.Average,3)
                Sum = [math]::Round($Measure.Sum,3)
                Values = $CounterSamples.values.values.computedValue
            }

            # Some counter values are timings, so these should be outputted as milliseconds rather than seconds
            if ($CounterInstance.counterName -in $CounterSampleValuesAreInMilliseconds){
                $Result.Minimum = $Result.Minimum * 1000
                $Result.Maximum = $Result.Maximum * 1000
                $Result.Average = $Result.Average * 1000
                $Result.Sum = $Result.Sum * 1000
            }

            $Results += [pscustomobject]$Result



        }

        if ($OutputTeamCityServiceMessages -eq $True){
            foreach ($Result in $Results){
                Write-Host ("##teamcity[buildStatisticValue key='{0}-Average' value='{1}']" -f $Result.counterName, $Result.Average )
                Write-Host ("##teamcity[buildStatisticValue key='{0}-Minimum' value='{1}']" -f $Result.counterName, $Result.Minimum )
                Write-Host ("##teamcity[buildStatisticValue key='{0}-Maximum' value='{1}']" -f $Result.counterName, $Result.Maximum )
                Write-Host ("##teamcity[buildStatisticValue key='{0}-Sum' value='{1}']" -f $Result.counterName, $Result.Sum )
            }
        }

        $Results | Format-Table -Property CounterName, Average, Minimum, Maximum, Sum | Out-String | Write-Verbose
        Return $Results

    }
    catch{
        throw $_
    }

}