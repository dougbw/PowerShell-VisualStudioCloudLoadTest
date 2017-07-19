$sut = $MyInvocation.MyCommand.Name -replace ".Tests", ""
. "$PSScriptRoot\$sut"

Describe "Get-CloudLoadTestAuthHeaders" {

    $VisualStudioAccountName = "test"
    $VisualStudioAccountPersonalAccessToken = "test"

    Context "Parameter validation" {

        It "Should throw if parameter VisualStudioAccountName value is null or empty" {
            {Get-CloudLoadTestAuthHeaders -VisualStudioAccountName "" -VisualStudioAccountPersonalAccessToken $VisualStudioAccountPersonalAccessToken} | Should throw "Cannot validate argument on parameter 'VisualStudioAccountName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Should throw if parameter VisualStudioAccountPersonalAccessToken value is null or empty" {
            {Get-CloudLoadTestAuthHeaders -VisualStudioAccountName $VisualStudioAccountName -VisualStudioAccountPersonalAccessToken ""} | Should throw "Cannot validate argument on parameter 'VisualStudioAccountPersonalAccessToken'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Should throw if parameter ApiVersion value is not an allowed value" {
            {Get-CloudLoadTestAuthHeaders -VisualStudioAccountName $VisualStudioAccountName -VisualStudioAccountPersonalAccessToken $VisualStudioAccountPersonalAccessToken -ApiVersion 0.1 } | Should throw "Cannot validate argument on parameter 'ApiVersion'. The argument `"0.1`" does not belong to the set `"1.0`" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again."
        } 
    }

    Context "Auth header generation" {

        $ExpectedOutput = @{
            BaseUri = "https://test.vsclt.visualstudio.com"
            Headers = @{
                Authorization = "Basic IDp0ZXN0"
                'Content-Type' = "application/json; charset=utf-8"
                Accept = "application/json; api-version=1.0"
            }
        } | ConvertTo-Json

        It "Should return the expected auth header" {
            (Get-CloudLoadTestAuthHeaders -VisualStudioAccountName $VisualStudioAccountName -VisualStudioAccountPersonalAccessToken $VisualStudioAccountPersonalAccessToken | ConvertTo-Json) | Should be $ExpectedOutput
        }

    }

}