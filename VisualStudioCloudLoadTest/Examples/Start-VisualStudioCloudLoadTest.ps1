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

    Import-Module -Name VisualStudioCloudLoadTest -Force -ErrorAction Stop -Verbose:$false

    Invoke-CloudLoadTest -LoadTestFileName $LoadTestFileName -LoadTestDescription $LoadTestDescription -TestDirectoryPath $TestDirectoryPath -VisualStudioAccountName $VisualStudioAccountName -VisualStudioAccountPersonalAccessToken $VisualStudioAccountPersonalAccessToken -OutputTeamCityServiceMessages $OutputTeamCityServiceMessages

}
catch{
    throw $_
}