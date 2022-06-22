#Defines KeePass.exe + local DB path
Function Import-VaultLocation {
    $DBPaths = "$env:USERPROFILE\", "$env:OneDrive\", "$env:ProgramW6432\", "${env:ProgramFiles(x86)}\"
    foreach ($DBPath in $DBPaths) {
	    $FindDB = Get-ChildItem -Path "$DBPath*" -Include *.kdbx -Recurse -ErrorAction SilentlyContinue
	    $DBCount = $FindDB.Count

	    if ($DBCount -eq "1") {
		    $global:VaultDB = $FindDB.FullName
		    break
	    }
    }
}