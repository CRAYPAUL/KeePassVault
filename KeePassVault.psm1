$Public = Get-ChildItem -Path $PSScriptRoot\repo\*.ps1

@($Public).foreach{
    try {
        . $_.FullName
    } catch {
        throw $_
    }
}