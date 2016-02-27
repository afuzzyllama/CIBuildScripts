<#
    This script will take all the files located in a directory named "ReleaseContents" in the build staging directory and place them in a zip file in the
    staging directory with a name  in the following format:

        RepoName.Major.Minor.BuildId.SourceVersion.zip

    This script will only run in a TFS build process because it relies on environment variables defined by TFS.
    
    Requires the following custom environment variables to be set in TFS:
    
        BuildScriptDir              - Absolute path to where all powershell scripts for this agent are stored
        AssemblyInfoRelativePaths  - Relative paths to the AssemblyInfo.cs files in the git repository.  The paths should be comma delimited and the 
                                      assembilies need to have the identical major and minor versions set.
#>

. "$env:BUILDSCRIPTDIR\sharedFunctions.ps1"

Add-Type -Assembly System.IO.Compression.FileSystem
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

$assemblyInfoRelativePaths = $env:ASSEMBLYINFORELATIVEPATHS.Split(",")


$assemblyInfoFile = Join-Path  $env:BUILD_SOURCESDIRECTORY $assemblyInfoRelativePaths[0]
$assemblyInfoFile = Join-Path  $assemblyInfoFile "AssemblyInfo.cs"

$assemblyVersion = getAssemblyVersion $assemblyInfoFile
$assemblyName = ($env:BUILD_REPOSITORY_NAME).Split("/")
$assemblyName = $assemblyName[1]

[System.IO.Compression.ZipFile]::CreateFromDirectory("$env:BUILD_STAGINGDIRECTORY\ReleaseContents", ([string]::Format("{0}\{1}.{2}.zip", $env:BUILD_STAGINGDIRECTORY, $assemblyName, $assemblyVersion.AssemblyInformationalVersion)), $compressionLevel, $false <# include base directory? #>)
