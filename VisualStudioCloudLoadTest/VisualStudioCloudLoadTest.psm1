$Public  = Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 | Where {$_.Name -notlike "*tests*"}
$Private = Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 | Where {$_.Name -notlike "*tests*"}

foreach($file in ($Public + $Private)){
    try{
        . $file.fullname
    }
    catch{
        throw $_
    }
}

Export-ModuleMember -Function $Public.Basename