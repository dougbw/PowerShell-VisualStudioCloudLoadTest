Function New-CloudLoadTestDrop{
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
    $BaseUri

)

    $Uri = "$BaseUri/{0}" -f "_apis/clt/testdrops"
    $Body = @{
        Id = $null
        TestRunId = $null
        DropType = "TestServiceBlobDrop"
        AccessData = $null
        CreatedDate = (Get-Date -Format s)
        LoadTestDefinition = $null
    } | ConvertTo-Json
    $Response = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body
    Write-Verbose ("Test Drop Id = '{0}', drop container url = '{1}'" -f $Response.Id, $Response.accessData.dropContainerUrl)

    $DropContainerUrl = $Response.accessData.dropContainerUrl -split '/'
    Return [pscustomobject][ordered]@{
        ContainerName = $DropContainerUrl[3]
        Id = $DropContainerUrl[4]
        dropContainerUrl = $Response.accessData.dropContainerUrl
        StorageAccountName = $DropContainerUrl[2].Split('.')[0]
        SasToken = $Response.accessData.sasKey
    }

}