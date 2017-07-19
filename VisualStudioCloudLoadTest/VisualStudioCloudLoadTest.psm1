Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" -Recurse | Where {$_.Name -notlike "*tests*"} |
ForEach-Object {
    . $_.FullName
}