# KeePassVault
KeePassVault is a PowerShell module for pulling creds or data stored in KeePass DB entries. KeePassVault uses it's own portable KeePass application (stored in bin/, currently version 2.50). Currently able to pull entries only from password protected KeePass dbs. Here is it's current usage: 

Make sure this module is placed in one of the PowerShell module paths. These locations can be found in the $env:PSModulePath environment variable.

```
#Import the module into your current PowerShell session
Import-Module KeePassVault


#You may need to enable script execution for the session; If so, use the following command:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

```

Once imported, you can access an entry with the following command:

```
Open-KeePass -VaultTitle <Title>

```
