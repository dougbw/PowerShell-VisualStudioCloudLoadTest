Function Get-CloudLoadTestRunSummary{
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

    try{
        $Uri = "$BaseUri/{0}/{1}/ResultSummary" -f "_apis/clt/testruns", $TestRunId
        $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers


        Write-Verbose ("Overall Scenario Summary: minUserLoad = {0},  maxUserLoad = {1}" -f $Response.overallScenarioSummary.minUserLoad, $Response.overallScenarioSummary.maxUserLoad)

        Write-Verbose ("Overall Test Summary: totalTests = {0}, passedTests = {1}, failedTests = {2}, averageTestTime = {3}" -f $Response.overallTestSummary.totalTests, $Response.overallTestSummary.passedTests, $Response.overallTestSummary.failedTests, $Response.overallTestSummary.averageTestTime )

        Write-Verbose ("Overall Page Summary: totalPages = {0}, percentagePagesMeetingGoal = {1}, averagePageTime = {2}, averageTestTime = {3}" -f $Response.overallPageSummary.totalPages, $Response.overallPageSummary.percentagePagesMeetingGoal, $Response.overallPageSummary.failedTests, $Response.overallPageSummary.averagePageTime )

        Write-Verbose ("Overall Request Summary: totalRequests = {0}, passedRequests = {1}, failedRequests = {2}, averageResponseTime = {3}, requestsPerSec = {4}" -f $Response.overallRequestSummary.totalRequests, $Response.overallRequestSummary.passedRequests, $Response.overallRequestSummary.failedRequests, $Response.overallRequestSummary.averageResponseTime, $Response.overallRequestSummary.requestsPerSec )


        if ($OutputTeamCityServiceMessages -eq $True){

            # Output OverallRequestSummary
            Write-Host ("##teamcity[buildStatisticValue key='OverallRequestSummary-TotalRequests' value='{0}']" -f $Response.overallRequestSummary.totalRequests )
            Write-Host ("##teamcity[buildStatisticValue key='OverallRequestSummary-PassedRequests' value='{0}']" -f $Response.overallRequestSummary.passedRequests )
            Write-Host ("##teamcity[buildStatisticValue key='OverallRequestSummary-AverageResponseTime' value='{0}']" -f $Response.overallRequestSummary.averageResponseTime )
            Write-Host ("##teamcity[buildStatisticValue key='OverallRequestSummary-RequestsPerSec' value='{0}']" -f $Response.overallRequestSummary.requestsPerSec )

            # Output overallTestSummary
            Write-Host ("##teamcity[buildStatisticValue key='OverallTestSummary-TotalRequests' value='{0}']" -f $Response.overallTestSummary.totalTests )
            Write-Host ("##teamcity[buildStatisticValue key='OverallTestSummary-PassedRequests' value='{0}']" -f $Response.overallTestSummary.passedTests )
            Write-Host ("##teamcity[buildStatisticValue key='OverallTestSummary-AverageResponseTime' value='{0}']" -f $Response.overallTestSummary.failedTests )
            Write-Host ("##teamcity[buildStatisticValue key='OverallTestSummary-RequestsPerSec' value='{0}']" -f $Response.overallTestSummary.averageTestTime )


        }

        # Output top slow pages
        foreach ($SlowPage in $Response.topSlowPages){
            Write-Verbose ("Top Slow Pages: testName = {0}, pageUrl = '{1}', totalPages = {2}, percentagePagesMeetingGoal = {3}, averagePageTime = {4}" -f $SlowPage.testName, $SlowPage.pageUrl, $SlowPage.totalPages, $SlowPage.percentagePagesMeetingGoal, $SlowPage.averagePageTime)
            foreach ($PercentileData in $SlowPage.percentileData){
                Write-Verbose ("Top Slow Pages Percentile Data: testName = {0}, percentile = {1}, percentileValue = {2}" -f $SlowPage.testName, $PercentileData.percentile, $PercentileData.percentileValue)
                if ($OutputTeamCityServiceMessages -eq $True){
                    Write-Host ("##teamcity[buildStatisticValue key='TopSlowPages-{0}-{1}-percentile' value='{2}']" -f $SlowPage.testName, $PercentileData.percentile, $PercentileData.percentileValue)
                }
            }
        } 

        # Output top slow tests
        foreach ($SlowTest in $Response.topSlowTests){
            Write-Verbose ("Top Slow Tests: testName = {0}, totalTests = '{1}', passedTests = {2}, failedTests = {3}, averageTestTime = {4}" -f $SlowTest.testName, $SlowTest.totalTests, $SlowTest.passedTests, $SlowTest.failedTests, $SlowTest.averageTestTime)            
            foreach ($PercentileData in $SlowTest.percentileData){
                Write-Verbose ("Top Slow Tests Percentile Data: testName = {0}, percentile = {1}, percentileValue = {2}" -f $SlowTest.testName, $PercentileData.percentile, $PercentileData.percentileValue)
                if ($OutputTeamCityServiceMessages -eq $True){
                    Write-Host ("##teamcity[buildStatisticValue key='TopSlowTests-{0}-{1}-percentile' value='{2}']" -f $SlowTest.testName, $PercentileData.percentile, $PercentileData.percentileValue)
                }
            }
        }

        Return $Response

    }
    catch{
        throw $_
    }

}