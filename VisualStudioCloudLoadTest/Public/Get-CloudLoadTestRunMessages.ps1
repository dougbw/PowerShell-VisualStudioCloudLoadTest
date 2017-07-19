Function Get-CloudLoadTestRunMessages{
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
        $Uri = "$BaseUri/{0}/{1}/messages" -f "_apis/clt/testruns", $TestRunId
        $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
        $Messages = $Response.value | Sort-Object -Property loggedDate
        
        foreach ($Message in $Messages){

            switch ($Message.messageType){

                "info"{
                    Write-Output ("{0}" -f $Message.message)
                }
            
                "warning"{
                    Write-Warning ("{0}" -f $Message.message)
                }

                "critical"{
                    Write-Error ("{0}" -f $Message.message)
                }

                default{
                    Write-Output ("{0}" -f $Message.message)
                }
            } 
        }
    }
    catch{
        throw $_
    }

}