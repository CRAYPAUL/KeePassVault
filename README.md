# KeePassVault
PowerShell module for pulling creds or data stored in KeePass DB entries. KeePassVault uses it's own portable KeePass application (stored in bin/, currently version 2.50). Currently able to pull entries from password-protected only KeePass dbs. Here is it's current usage: 

Make sure this module is placed in one of the PowerShell module paths. These locations can be found in the $env:PSModulePath environment variable.

```
#Import the module into your current PowerShell session
Import-Module KeePassVault

```

Once imported, you can access an entry with the following command:

```
Open-KeePass -VaultTitle Venmo

```
