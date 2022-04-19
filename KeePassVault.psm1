$Private = Get-ChildItem -Path $PSScriptRoot\private\*.ps1
@($Private).foreach{
    try {
        . $_.FullName
    } catch {
        throw $_
    }
}

$Public = Get-ChildItem -Path $PSScriptRoot\repo\*.ps1
@($Public).foreach{
    try {
        . $_.FullName
    } catch {
        throw $_
    }
}

$global:VaultEXE = Get-ChildItem -Path $PSScriptRoot\bin\KeePassPackage2.50\KeePass.exe
[Reflection.Assembly]::LoadFile($VaultEXE) | Out-Null
Import-VaultLocation
