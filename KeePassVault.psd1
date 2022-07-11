@{
    RootModule           = 'KeePassVault.psm1'
    ModuleVersion        = '1.0.0'
    CompatiblePSEditions = @('Desktop','Core')
    Description          = 'This module allows a person to pull KeePass entries for use in scripts.'
    PowerShellVersion    = '5.1'
    RequiredAssemblies   = @('System.Net.Http')
    VariablesToExport    = '*'
    ScriptsToProcess     = @()
    CmdletsToExport      = @()
    AliasesToExport      = @()
    FunctionsToExport    = @(
    
		'Open-KeePass'
    )
}
