function Escape-TeamCityServiceMessageString {
[cmdletbinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]
    $InputString,

    [Parameter(Mandatory = $False)]
    [array]
    $CharacterShouldBeEscaped = @(
        "|"
        "'"
        "["
        "]"
    )
)

    $OutputString = $InputString

    foreach ($Character in $CharacterShouldBeEscaped){
        $OutputString = $OutputString.Replace($Character, "|$Character")
    }

    Return $OutputString

}