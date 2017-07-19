Function Get-CloudLoadTestRunErrors{
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
    $TestRunId

)

    try{
        $Uri = "$BaseUri/{0}/{1}/errors?detailed=True" -f "_apis/clt/testruns", $TestRunId
        $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

        foreach ($Type in $Response.types){
            foreach ($SubType in $Type.subTypes){
                foreach ($ErrorDetailList in $SubType.errorDetailList){
                    Write-Error ("Occurrences = {0}, Message = {1}" -f $ErrorDetailList.occurrences, $ErrorDetailList.messageText)
                }
            }
        }
    }
    catch{
        throw $_
    }
}