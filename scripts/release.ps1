# DocFX Companion Tools - Release Helper Script
# This script helps create and push version tags for automatic releases

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Colors for output
$colors = @{
    Red = "`e[0;31m"
    Green = "`e[0;32m"
    Yellow = "`e[1;33m"
    Blue = "`e[0;34m"
    NC = "`e[0m" # No Color
}

# Function to print colored output
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $colorCode = if ($colors.ContainsKey($Color)) { $colors[$Color] } else { "" }
    $resetCode = if ($colors.ContainsKey($Color)) { $colors["NC"] } else { "" }
    
    Write-Host "$colorCode$Message$resetCode"
}

function Write-Info {
    param([string]$Message)
    Write-ColoredOutput -Message "ℹ️  $Message" -Color "Blue"
}

function Write-Success {
    param([string]$Message)
    Write-ColoredOutput -Message "✅ $Message" -Color "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColoredOutput -Message "⚠️  $Message" -Color "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColoredOutput -Message "❌ $Message" -Color "Red"
}

# Function to show usage
function Show-Usage {
    Write-Host "Usage: .\release.ps1 <version> [options]"
    Write-Host ""
    Write-Host "Arguments:"
    Write-Host "  version     Version number (e.g., 1.0.0)"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help       Show this help message"
    Write-Host "  -DryRun     Show what would be done without actually doing it"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\release.ps1 1.0.0        # Create and push tag v1.0.0"
    Write-Host "  .\release.ps1 1.1.0 -DryRun # Show what would be done for v1.1.0"
    Write-Host ""
    Write-Host "This script will:"
    Write-Host "1. Validate the version format"
    Write-Host "2. Check if working directory is clean"
    Write-Host "3. Check if tag already exists"
    Write-Host "4. Create and push the tag"
    Write-Host ""
    Write-Host "After pushing the tag, GitHub Actions will automatically:"
    Write-Host "- Build all tools as Windows executables"
    Write-Host "- Create a ZIP package"
    Write-Host "- Create a GitHub Release"
    Write-Host "- Publish to NuGet"
}

# Function to validate version format
function Validate-Version {
    param([string]$Version)
    
    if ($Version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
        Write-Error "Invalid version format: $Version"
        Write-Error "Version must be in format: major.minor.patch (e.g., 1.0.0)"
        exit 1
    }
    
    Write-Success "Version format is valid: $Version"
}

# Function to check if working directory is clean
function Check-CleanWorkingDir {
    $status = git status --porcelain
    if ($status) {
        Write-Error "Working directory is not clean"
        Write-Error "Please commit or stash your changes first"
        git status
        exit 1
    }
    Write-Success "Working directory is clean"
}

# Function to check if tag already exists
function Check-TagExists {
    param([string]$Tag)
    
    $existingTags = git tag --list
    if ($existingTags -contains $Tag) {
        Write-Error "Tag $Tag already exists"
        Write-Error "Use a different version or delete the existing tag first"
        exit 1
    }
    Write-Success "Tag $Tag does not exist yet"
}

# Function to create and push tag
function Create-And-PushTag {
    param(
        [string]$Tag,
        [bool]$DryRun
    )
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create tag: $Tag"
        Write-Info "[DRY RUN] Would push tag to remote: $Tag"
        Write-Info "[DRY RUN] Would trigger GitHub Actions build"
    } else {
        Write-Info "Creating tag: $Tag"
        git tag -a "$Tag" -m "Release $Tag"
        
        Write-Info "Pushing tag to remote"
        git push origin "$Tag"
        
        Write-Success "Tag $Tag created and pushed successfully"
        Write-Info "GitHub Actions will now build and release version $Tag"
        Write-Info "Check the progress at: https://github.com/lusipad/docfx-companion-tools/actions"
    }
}

# Main script
function Main {
    if ($Help) {
        Show-Usage
        exit 0
    }
    
    # Add 'v' prefix to version
    $tag = "v$Version"
    
    Write-Info "DocFX Companion Tools Release Helper"
    Write-Info "===================================="
    Write-Info "Version: $Version"
    Write-Info "Tag: $tag"
    Write-Info "Dry run: $DryRun"
    Write-Host ""
    
    # Validate version format
    Validate-Version -Version $Version
    
    # Check working directory
    Check-CleanWorkingDir
    
    # Check if tag exists
    Check-TagExists -Tag $tag
    
    # Create and push tag
    Create-And-PushTag -Tag $tag -DryRun $DryRun
    
    Write-Host ""
    Write-Success "Release process completed successfully!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Info "1. Monitor the GitHub Actions build: https://github.com/lusipad/docfx-companion-tools/actions"
    Write-Info "2. Once complete, download the release from: https://github.com/lusipad/docfx-companion-tools/releases"
    Write-Info "3. Test the downloaded executables"
    Write-Host ""
    Write-Info "Thank you for using DocFX Companion Tools! 🚀"
}

# Run main function
Main