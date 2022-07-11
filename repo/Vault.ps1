#Loads and runs search of KeePass, returns creds as PSCredential object 
Function Open-KeePass {   
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)] [String] $EntryTitle
	)   
    try {
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
        $Credentials = Search-KeePass -DBVault $Vault -Group General -Title $EntryTitle
    }
    catch {
        $Vault.Close()
        throw $_.Exception.Message
    }
    $Vault.Close()
    Remove-Variable -Name "Vault*"
    return $Credentials
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
        throw "ERROR: Entry '$Title' was not found." 
    }
    elseif ($DBEntryCount -gt 1) {
        throw "`nERROR: Multiple entries named '$Title'."
    }
    [string] $DBUsername = $DBEntry[0].Strings.ReadSafe("UserName")
    $DBSecureString = ConvertTo-SecureString -String ($DBEntry[0].Strings.ReadSafe("Password")) -AsPlainText -Force
	$DBPassword = Convert-SecureStringToPlaintext $DBSecureString
    $Entry = [PSCustomObject]@{
		Username = $DBUsername 
		Password = $DBPassword
	}
    Remove-Variable -Name "DB*"
    return $Entry
}


#Converts SecureString to cleartext
Function Convert-SecureStringToPlaintext ($SecureString) {
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))
}
