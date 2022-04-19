@{
    RootModule           = 'KeeDevVault.psm1'
    ModuleVersion        = '1.0.0'
    CompatiblePSEditions = @('Desktop','Core')
    Description          = 'KeePassVault testing module.'
    PowerShellVersion    = '5.1'
    RequiredAssemblies   = @('System.Net.Http')
    VariablesToExport    = '*'
    ScriptsToProcess     = @()
    CmdletsToExport      = @()
    AliasesToExport      = @()
    FunctionsToExport    = @(
		'Convert-SecureStringtoPlaintext',
		'Open-KeePass'
    )
    
}