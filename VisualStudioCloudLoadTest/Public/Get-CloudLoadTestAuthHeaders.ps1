Function Get-CloudLoadTestAuthHeaders{
[cmdletbinding()]
Param(

    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VisualStudioAccountName,
        
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VisualStudioAccountPersonalAccessToken,

    [Parameter(Mandatory=$False)]
    [ValidateSet("1.0")]
    [string]
    $ApiVersion = "1.0"

)

    $BaseUri = "https://{0}.vsclt.visualstudio.com" -f $VisualStudioAccountName
    $AuthBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(" :$VisualStudioAccountPersonalAccessToken"))
    $Headers = @{
        Authorization = "Basic $AuthBase64"
        "Content-Type" = "application/json; charset=utf-8"
        Accept = "application/json; api-version=$ApiVersion"
    }
    Return [pscustomobject]@{
        BaseUri = $BaseUri
        Headers = $Headers

    }

}