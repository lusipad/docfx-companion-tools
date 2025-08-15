# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
```powershell
# Build all tools and create output directory
.\build.ps1

# Build for development (dotnet tool packages)
dotnet build src\DocFxCompanionTools.sln

# Run tests for a specific tool
dotnet test src\DocAssembler\DocAssembler.Test\DocAssembler.Test.csproj
dotnet test src\DocFxTocGenerator\DocFxTocGenerator.Test\DocFxTocGenerator.Test.csproj
dotnet test src\DocLanguageTranslator\DocLanguageTranslator.Test\DocLanguageTranslator.Test.csproj
dotnet test src\DocLinkChecker\DocLinkChecker.Test\DocLinkChecker.Test.csproj

# Run all tests
dotnet test src\DocFxCompanionTools.sln
```

### Packaging and Publishing
```powershell
# Package tools (development mode - shows changes without publishing)
.\pack.ps1 -version "1.0.0"

# Package and publish to Chocolatey (requires CHOCO_TOKEN environment variable)
.\pack.ps1 -publish -version "1.0.0"
```

### Individual Tool Development
```powershell
# Run individual tools during development
dotnet run --project src\DocAssembler\DocAssembler\DocAssembler.csproj
dotnet run --project src\DocFxTocGenerator\DocFxTocGenerator\DocFxTocGenerator.csproj
dotnet run --project src\DocLanguageTranslator\DocLanguageTranslator\DocLanguageTranslator.csproj
dotnet run --project src\DocLinkChecker\DocLinkChecker\DocLinkChecker.csproj
dotnet run --project src\DocFxOpenApi\DocFxOpenApi.csproj
```

## Architecture Overview

### Project Structure
This repository contains 5 independent .NET tools that work with DocFX documentation:

1. **DocAssembler** - Assembles documentation from multiple locations, restructuring and updating links
2. **DocFxTocGenerator** - Generates YAML table of contents for DocFX projects
3. **DocLanguageTranslator** - Translates and generates missing files for multi-language documentation
4. **DocLinkChecker** - Validates links and checks for orphaned attachments in documentation
5. **DocFxOpenApi** - Converts OpenAPI specifications to DocFX-compatible format

### Common Architecture Patterns
All tools follow similar architectural patterns:
- **Action-based design**: Each tool has an `Actions` folder containing business logic classes
- **File service abstraction**: `IFileService` interface for file operations (enables testing with mocks)
- **Configuration**: Each tool has its own configuration classes, typically in a `Configuration` or `Domain` folder
- **Return codes**: Standardized return codes in `ReturnCode.cs` files
- **Logging**: Custom logging utilities in `Utils\LogUtil.cs`

### Key Shared Components
- **File Service**: Abstraction layer for file operations used across all tools
- **Configuration Management**: Each tool manages its own configuration through command-line parsing
- **Error Handling**: Consistent error handling with custom exceptions and return codes
- **Testing Strategy**: All tools have separate test projects with mock file services for unit testing

### Build System
- **Main build**: `build.ps1` builds all projects as single executables and creates `tools.zip`
- **Packaging**: `pack.ps1` handles Chocolatey package creation and publishing
- **Output**: Built executables go to `output/` directory, packages to `artifacts/`
- **Dependencies**: All tools target .NET 8.0 with C# 12.0

### Code Quality Standards
- **Static Analysis**: StyleCop.Analyzers enabled with warnings as errors
- **Nullable Reference Types**: Enabled throughout codebase
- **Documentation**: XML documentation files generated for all projects
- **Testing**: Mock-based testing with comprehensive coverage of business logic

### Multi-language Support
The repository includes comprehensive multi-language documentation support:
- **User documentation**: Located in `DocExamples/userdocs/` with `en/`, `de/`, and `zh/` subdirectories
- **Tool translation**: DocLanguageTranslator specifically handles multi-language documentation generation
- **Default language**: Main README defaults to Chinese with English secondary option

### Chocolatey Integration
- **Package management**: Tools are published as Chocolatey packages
- **Automated publishing**: CI/CD pipeline handles version bumping and publishing
- **Hash validation**: SHA256 hashes used for package integrity verification