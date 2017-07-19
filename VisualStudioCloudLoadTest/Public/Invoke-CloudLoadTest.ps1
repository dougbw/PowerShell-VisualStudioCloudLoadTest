Function Invoke-CloudLoadTest{
[cmdletbinding()]
Param(

    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [string]
    $LoadTestFileName,

    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [string]
    $LoadTestDescription = "LoadTest",

    [Parameter(Mandatory = $False)]
    [validatescript({
        if (Test-Path $_ -PathType Container){
            $True
        }
        else{
            Throw "Invalid folder path '$_'"
        }
    })]
    [string]
    $TestDirectoryPath,
    
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VisualStudioAccountName,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VisualStudioAccountPersonalAccessToken,

    [Parameter(Mandatory = $False)]
    [bool]
    $OutputTeamCityServiceMessages = $True
)

    try{

        # Get auth headers
        $Auth = Get-CloudLoadTestAuthHeaders -VisualStudioAccountName $VisualStudioAccountName -VisualStudioAccountPersonalAccessToken $VisualStudioAccountPersonalAccessToken -Verbose

        # Create new test drop
        $TestDrop = New-CloudLoadTestDrop -Headers $Auth.Headers -BaseUri $Auth.BaseUri -Verbose
    
        # Publish files to test drop container
        Set-CloudLoadTestDrop -Headers $Auth.Headers -BaseUri $Auth.BaseUri -TestDrop $TestDrop -TestDirectoryPath $TestDirectoryPath -LoadTestFileName $LoadTestFileName -Verbose

        # Create the test run
        $TestRun = New-CloudLoadTestRun -Headers $Auth.Headers -BaseUri $Auth.BaseUri -TestDrop $TestDrop -LoadTestFileName $LoadTestFileName -LoadTestDescription $LoadTestDescription -Verbose
    
        # Start test run
        Start-CloudLoadTestRun -Headers $Auth.Headers -BaseUri $Auth.BaseUri -TestRunId $TestRun.id -Verbose

        # Wait for run to complete
        Get-CloudLoadTestRun -Headers $Auth.Headers -BaseUri $Auth.BaseUri -TestRunId $TestRun.id -Verbose

        # Get counter samples
        $CounterSamples = Get-CloudLoadTestRunCounterSamples -Headers $Auth.Headers -BaseUri $Auth.BaseUri -TestRunId $Testrun.id -OutputTeamCityServiceMessages $True -Verbose

    }
    catch{
        throw $_
    }

}