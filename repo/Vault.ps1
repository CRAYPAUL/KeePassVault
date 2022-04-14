#Converts SecureString to cleartext
Function Convert-SecureStringToPlaintext ($SecureString) {
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))
}


#Pulls creds from KeePass DB entry as PSCredential object
Function Search-KeePass {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)] [KeePassLib.PwDatabase] $DBVault,
        [Parameter(Mandatory=$true)] [String] $Group,
        [Parameter(Mandatory=$true)] [String] $Title
    )
    $DBGroup = @( $DBVault.RootGroup.Groups | where { $_.name -eq $Group } )
    $DBEntry = @( $DBGroup[0].GetEntries($True) | Where { $_.Strings.ReadSafe("Title") -eq $Title } )
    [int]$DBEntryCount = $DBEntry.Count
    if ($DBEntryCount -eq 0) { 
        throw "ERROR: Entry '$DBTitle' was not found." 
    }
    elseif ($DBEntryCount -gt 1) {
        throw "`nERROR: Multiple entries named '$DBTitle'."
    }
    [string] $DBUsername = $DBEntry[0].Strings.ReadSafe("UserName")
    $DBPassword = ConvertTo-SecureString -String ($DBEntry[0].Strings.ReadSafe("Password")) -AsPlainText -Force
    $Entry = New-Object System.Management.Automation.PSCredential($DBUsername, $DBPassword)
    Remove-Variable -Name "DB*"
    return $Entry
}


#Loads and runs search of KeePass, returns creds as PSCredential object 
Function Open-KeePass {   
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)] [String] $VaultTitle
	)

    try {
        #Tries to locate a KeePass DB in Documents\. If none exist, it then checks Program Files\
        $DBPath = [environment]::getfolderpath("mydocuments")
        $VaultDB = Get-ChildItem -Path "$DBPath\*" -Include *.kdbx -Recurse -ErrorAction SilentlyContinue
        $DBCount = $VaultDB.Count

        if ($DBCount -eq "1") {
            $VaultDB = "$VaultDB"
        }
        elseif ($DBCount -eq "0") {
            $DBPath = $env:ProgramFiles
            $VaultDB = Get-ChildItem -Path "$DBPath\*" -Include *.kdbx -Recurse -ErrorAction SilentlyContinue
            $DBCount = $VaultDB.Count

            if ($DBCount -eq "1") {
                $VaultDB = "$VaultDB"
            }
        }

        #Locates a KeePass.exe instance in either Program Files\ or Program Files(x86)\
        #NOTE: $env:ProgramFiles shows as 'Program Files (x86)\' when using 32-bit PowerShell; this will cause issues if it's run on 64-bit Windows & KeePass is installed under 'Program Files\'
        $EXEPath = $env:ProgramFiles
        $VaultEXE = Get-ChildItem -Path "$EXEPath\*" -Include KeePass.exe -Recurse -ErrorAction SilentlyContinue
        $EXECount = $VaultEXE.Count

        if ($EXECount -eq "1") {
            $VaultEXE = "$VaultEXE"
        }
        elseif ($EXECount -eq "0") {
            $EXEPath = ${env:ProgramFiles(x86)}
            $VaultEXE = Get-ChildItem -Path "$EXEPath\*" -Include KeePass.exe -Recurse -ErrorAction SilentlyContinue
            $EXECount = $VaultEXE.Count

            if ($EXECount -eq "1") {
                $VaultEXE = "$VaultEXE"
            }
        }
    }
    catch {
        throw $_.Exception.Message
    }
    [Reflection.Assembly]::LoadFile($VaultEXE) | Out-Null
    $Vault = New-Object -TypeName KeePassLib.PwDatabase
    $VaultStatus = New-Object KeePassLib.Interfaces.NullStatusLogger
    $VaultIOConnection = New-Object KeePassLib.Serialization.IOConnectionInfo
    $VaultIOConnection.Path = $VaultDB    

    $VaultPassword = Read-Host -Prompt "Please enter your passphrase:" -AsSecureString
    $VaultPassword = Convert-SecureStringToPlaintext -SecureString $VaultPassword
    $KcpPassword = New-Object -TypeName KeePassLib.Keys.KcpPassword($VaultPassword)
    $VaultKey = New-Object -TypeName KeePassLib.Keys.CompositeKey
    $VaultKey.AddUserKey($KcpPassword) | Remove-Variable -Name "*Password"
    $Vault.Open($VaultIOConnection, $VaultKey, $VaultStatus)
    try {
        $Credentials = Search-KeePass -DBVault $Vault -Group General -Title $VaultTitle
    }
    catch {
        $Vault.Close()
        throw $_.Exception.Message
    }
    $Vault.Close()
    Remove-Variable -Name "Vault*"
    return $Credentials
}
