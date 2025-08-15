#!/bin/bash

# DocFX Companion Tools - Release Helper Script
# This script helps create and push version tags for automatic releases

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <version> [options]"
    echo ""
    echo "Arguments:"
    echo "  version     Version number (e.g., 1.0.0)"
    echo ""
    echo "Options:"
    echo "  -h, --help  Show this help message"
    echo "  -d, --dry-run  Show what would be done without actually doing it"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0           # Create and push tag v1.0.0"
    echo "  $0 1.1.0 --dry-run # Show what would be done for v1.1.0"
    echo ""
    echo "This script will:"
    echo "1. Validate the version format"
    echo "2. Check if working directory is clean"
    echo "3. Check if tag already exists"
    echo "4. Create and push the tag"
    echo ""
    echo "After pushing the tag, GitHub Actions will automatically:"
    echo "- Build all tools as Windows executables"
    echo "- Create a ZIP package"
    echo "- Create a GitHub Release"
    echo "- Publish to NuGet"
}

# Function to validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $version"
        print_error "Version must be in format: major.minor.patch (e.g., 1.0.0)"
        exit 1
    fi
    print_success "Version format is valid: $version"
}

# Function to check if working directory is clean
check_clean_working_dir() {
    if [[ -n $(git status --porcelain) ]]; then
        print_error "Working directory is not clean"
        print_error "Please commit or stash your changes first"
        git status
        exit 1
    fi
    print_success "Working directory is clean"
}

# Function to check if tag already exists
check_tag_exists() {
    local tag=$1
    if git tag --list | grep -q "^$tag$"; then
        print_error "Tag $tag already exists"
        print_error "Use a different version or delete the existing tag first"
        exit 1
    fi
    print_success "Tag $tag does not exist yet"
}

# Function to create and push tag
create_and_push_tag() {
    local tag=$1
    local dry_run=$2
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "[DRY RUN] Would create tag: $tag"
        print_info "[DRY RUN] Would push tag to remote: $tag"
        print_info "[DRY RUN] Would trigger GitHub Actions build"
    else
        print_info "Creating tag: $tag"
        git tag -a "$tag" -m "Release $tag"
        
        print_info "Pushing tag to remote"
        git push origin "$tag"
        
        print_success "Tag $tag created and pushed successfully"
        print_info "GitHub Actions will now build and release version $tag"
        print_info "Check the progress at: https://github.com/lusipad/docfx-companion-tools/actions"
    fi
}

# Main script
main() {
    local version=""
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$version" ]]; then
                    version=$1
                else
                    print_error "Multiple version numbers provided"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if version is provided
    if [[ -z "$version" ]]; then
        print_error "Version number is required"
        show_usage
        exit 1
    fi
    
    # Add 'v' prefix to version
    local tag="v$version"
    
    print_info "DocFX Companion Tools Release Helper"
    print_info "===================================="
    print_info "Version: $version"
    print_info "Tag: $tag"
    print_info "Dry run: $dry_run"
    echo ""
    
    # Validate version format
    validate_version "$version"
    
    # Check working directory
    check_clean_working_dir
    
    # Check if tag exists
    check_tag_exists "$tag"
    
    # Create and push tag
    create_and_push_tag "$tag" "$dry_run"
    
    echo ""
    print_success "Release process completed successfully!"
    echo ""
    print_info "Next steps:"
    print_info "1. Monitor the GitHub Actions build: https://github.com/lusipad/docfx-companion-tools/actions"
    print_info "2. Once complete, download the release from: https://github.com/lusipad/docfx-companion-tools/releases"
    print_info "3. Test the downloaded executables"
    echo ""
    print_info "Thank you for using DocFX Companion Tools! 🚀"
}

# Run main function
main "$@"