Function Set-CloudLoadTestDrop{
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
    [hashtable]
    $TestDrop,

    [Parameter(Mandatory=$True)]
    [ValidateScript({
        if (Test-Path $_ -PathType Container){
            $True
        }
        else{
            Throw "Invalid file path '$_'"
        }
    })]
    [string]
    $TestDirectoryPath,

    [Parameter(Mandatory=$True)]
    [string]
    $LoadTestFileName

)


    $Files = Get-ChildItem -Path $TestDirectoryPath -Recurse -File
    if ($Files.Name -notcontains $LoadTestFileName){
        throw "Load test file '{0}' not found in directory '{1}'" -f $LoadTestFileName, $TestDirectoryPath
    }

    $Context = New-AzureStorageContext -StorageAccountName $TestDrop.StorageAccountName -SasToken $TestDrop.SasToken

    foreach ($File in $Files){

        $RelativePath = $File.FullName.Replace($TestDirectoryPath,'')
        $BlobName = Join-Path -Path $TestDrop.Id -ChildPath $RelativePath
        Set-AzureStorageBlobContent -Context $Context -Container $TestDrop.ContainerName -File $File.FullName -Blob $BlobName -Force  -Verbose:$false | Out-Null
        
        # Upload .loadtest file to root test drop location
        if ($File.Name -eq $LoadTestFileName){
            $BlobName = Join-Path -Path $TestDrop.Id -ChildPath $File.Name
            Set-AzureStorageBlobContent -Context $Context -Container $TestDrop.ContainerName -File $File.FullName -Blob $BlobName -Force  -Verbose:$false | Out-Null
        }

    }

}