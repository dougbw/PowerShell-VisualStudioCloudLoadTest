$sut = $MyInvocation.MyCommand.Name -replace ".Tests", ""
. "$PSScriptRoot\$sut"

Describe "New-CloudLoadTestDrop" {

    $Headers = @{
        Authorization = "Basic IDp0ZXN0"
        'Content-Type' = "application/json; charset=utf-8"
        Accept = "application/json; api-version=1.0"
    }
    $BaseUri = "https://test.vsclt.visualstudio.com"

    Context "Parameter validation" {

        It "Should throw if parameter BaseUri value is not a valid uri" {
            {New-CloudLoadTestDrop -BaseUri "" -Headers $Headers} | Should throw "Cannot validate argument on parameter 'BaseUri'. Parameter value is not valid ''"
        }

        It "Should throw if parameter Headers value is not a hashtable" {
            {New-CloudLoadTestDrop -BaseUri $BaseUri -Headers ""} | Should throw "Cannot process argument transformation on parameter 'Headers'. Cannot convert the `"`" value of type `"System.String`" to type `"System.Collections.Hashtable`"."
        }

    }

    Context "Test drop" {

        Mock Invoke-RestMethod {
            return [ordered]@{
                id = "ed45ed32-dafb-4178-ba7e-ad25755348f8"
                dropType =  "TestServiceBlobDrop"
                createdDate = "2014-06-23T06:13:34.7232698Z"
                accessData = @{
                    sasKey = "?sv=2012-02-12&se=2014-06-23T08%3A13%3A34Z&sr=c&si=sas_tenant_policyb4e51292-6cd7-4631-a1eb-caeaf4031abb&sig=zigGSss1xVwz6qDJzmwiR8KzWF%2Bq%2FTiyNegCV%2FCKfrg%3D"
                    dropContainerUrl = "https://myaccount.blob.core.windows.net/ets-containerfor-b4e51292-6cd7-4631-a1eb-caeaf4031abb/ed45ed32-dafb-4178-ba7e-ad25755348f8"
                }
              testRunId =  "null"
              loadTestDefinition=  "null"
            }
        }

        $ExpectedOutput = [ordered]@{
            ContainerName = "ets-containerfor-b4e51292-6cd7-4631-a1eb-caeaf4031abb"
            Id = "ed45ed32-dafb-4178-ba7e-ad25755348f8"
            dropContainerUrl = "https://myaccount.blob.core.windows.net/ets-containerfor-b4e51292-6cd7-4631-a1eb-caeaf4031abb/ed45ed32-dafb-4178-ba7e-ad25755348f8"
            StorageAccountName = "myaccount"
            SasToken = "?sv=2012-02-12&se=2014-06-23T08%3A13%3A34Z&sr=c&si=sas_tenant_policyb4e51292-6cd7-4631-a1eb-caeaf4031abb&sig=zigGSss1xVwz6qDJzmwiR8KzWF%2Bq%2FTiyNegCV%2FCKfrg%3D"
        } | ConvertTo-Json

        It "Should return the test drop details" {
            (New-CloudLoadTestDrop -BaseUri $BaseUri -Headers $Headers | ConvertTo-Json) | Should be $ExpectedOutput
            Assert-MockCalled -CommandName Invoke-RestMethod -Times 1
        }

    }

}