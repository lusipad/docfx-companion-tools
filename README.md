# DocFX Companion Tools

This repository contains a set of tools, templates, tips and tricks to make your [DocFX](https://dotnet.github.io/docfx/) experience even better.

[English](README.md) | [中文文档](README.zh.md)

## Tools

* [DocAssembler 🆕](./src/DocAssembler): Assemble documentation and resources from various locations on disk and bring them together in one place. Can restructure the structure, where the links are changed to the correct location.
* [DocFxTocGenerator](./src/DocFxTocGenerator): Generate YAML table of contents (TOC) for DocFX. Has functionality for configuration file order and documentation and folder names.
* [DocLinkChecker](./src/DocLinkChecker): Validate links in documentation and check for orphaned attachments in `.attachments` folders. The tool will indicate if there are errors or warnings, so it can be used in CI pipelines. It can also automatically clean up orphaned attachments. And can validate table syntax.
* [DocLanguageTranslator](./src/DocLanguageTranslator): Allows to automatically generate and translate missing files, or identify missing files in multi-language pattern directories.
* [DocFxOpenApi](./src/DocFxOpenApi): Convert existing [OpenAPI](https://www.openapis.org/) specification files to DocFX compatible format (OpenAPI v2 JSON files). It allows DocFX to generate HTML pages from OpenAPI specifications. OpenAPI is also known as [Swagger](https://swagger.io/).

## Creating PRs

The main branch is protected. Features and fixes can only be done through PRs. Make sure to use appropriate titles for PRs and keep them as small as possible in scope. If you want a PR to appear in the changelog, you must provide one or more labels for the PR. The list of labels used is as follows:

| Category | Description | Tags |
| --- | --- | --- |
| 🚀 Feature | New or modified functionality | feature, enhancement |
| 🐛 Fix | All (bug) fixes | fix, bug |
| 📄 Documentation | Documentation additions or changes | documentation |

## Building and Publishing

If you have this repository on your local machine, you can run the same scripts as in our workflows to build and package. To build the tools, use the **build** script. Run this command in PowerShell:

```PowerShell
.\build.ps1
```

The result of this script is an output folder containing all solution executables. They are all published as single exe, without framework. They depend on .NET 5 installed in the environment. The LICENSE file is also copied to the output folder. Then the contents of this folder are zipped into a zip file called 'tools.zip' in the root.

To package and publish the tools, you must first run the **build** script. Next you can run the **pack** script that we also use in our workflows. Run this command in PowerShell, where you provide the correct version:

```PowerShell
.\pack.ps1 -publish -version "1.0.0"
```

The script determines the hash of tools.zip, changes the Chocolatey nuspec and installation scripts to include the hash and the correct version. Then it creates the Chocolatey package. If the **CHOCO_TOKEN** environment variable is set, which contains the Chocolatey publish usage key, the script will also publish the package to Chocolatey. Otherwise a warning is given that the publish step is skipped.

If the -publish parameter is omitted, the script will run in development mode. It will not publish to Chocolatey and will output the Chocolatey file changes for inspection.

> [!NOTE]
> If you run the **pack** script locally, files are changed (*deploy\chocolatey\docfx-companion-tools.nuspec* and *deploy\chocolatey\tools\chocolateyinstall.ps1*). It's best not to commit these to the repository, although this is not secret information. The next run will still overwrite with the correct values.

## 🔄 GitHub Flow & Auto Publishing

### Auto EXE Publishing
We now support automatic Windows EXE publishing through GitHub Flow:

#### Method 1: Via Git Tag (Recommended)
```bash
# Create and push version tag
git tag v1.0.0
git push origin v1.0.0
```

#### Method 2: Manual Trigger
Visit the GitHub Actions page and run the "Release EXE on Tag" workflow.

### Automation Features
- ✅ Build all tools as Windows single-file EXEs
- ✅ Create ZIP package containing all tools
- ✅ Create Release on GitHub
- ✅ Publish to NuGet
- ✅ Auto-generate changelog

### Download EXE Version
After publishing is complete, you can download the `tools.zip` file from the [GitHub Releases](https://github.com/lusipad/docfx-companion-tools/releases) page, unzip it and use all tools.

For more details, see: [GitHub Flow Documentation](.github/GITHUB_FLOW.md)

## Traditional Publishing Flow

If you have one or more PRs and want to publish a new version, just make sure all PRs are tagged as needed (see above) and merged into the main branch. Manually run the manual **Release & Publish** workflow on the main branch. This will bump the version, create a release and publish a new package to Chocolatey.

## Installation

### Chocolatey

You can install the tools by downloading the zip file from the [release](https://github.com/Ellerbach/docfx-companion-tools/releases) or by using [Chocolatey](https://chocolatey.org/install) as follows:

```shell
choco install docfx-companion-tools
```

> [!NOTE]
> The tools expect .NET Framework 6 to be installed locally. If you need to run them on a higher framework,
> add `--roll-forward Major` as a parameter, like this:
> `~/.dotnet/tools/DocLinkChecker --roll-forward Major`

### dotnet tool

You can also install the tools via `dotnet tool`.

```shell
dotnet tool install DocAssembler -g
dotnet tool install DocFxTocGenerator -g
dotnet tool install DocLanguageTranslator -g
dotnet tool install DocLinkChecker -g
dotnet tool install DocFxOpenApi -g
```

### Usage

Once the tools are installed in this way, you can use them directly from the command line. For example:

```PowerShell
DocFxTocGenerator -d .\docs -vs --indexing NotExists
DocLanguageTranslator -d .\docs\en -k <key> -v
DocLinkChecker -d .\docs -va
```

## CI Pipeline Examples

* [Documentation build pipeline](./PipelineExamples/documentation-build.yml): Example pipeline that uses [DocFxTocGenerator](./src/DocFxTocGenerator) to generate table of contents and DocFx to generate the website. This example also publishes to Azure App Service.
* [Documentation validation pipeline](./PipelineExamples/documentation-validation.yml): Example pipeline that uses [markdownlint](https://github.com/markdownlint/markdownlint) to validate markdown style and [DocLinkChecker](./src/DocLinkChecker) to validate links and attachments.

## Docker

Build Docker image. The following example is based on `DocLinkChecker`, adjust `--tag` and `--build-arg` accordingly for other tools.

```shell
docker build --tag doclinkchecker:latest --build-arg tool=DocLinkChecker -f Dockerfile .
```

Run from `PowerShell`:

```PowerShell
docker run --rm -v ${PWD}:/workspace doclinkchecker:latest -d /workspace
```

Run from Linux/macOS `shell`:

```shell
docker run --rm -v $(pwd):/workspace doclinkchecker:latest -d /workspace
```

## Documentation

* [Guide for developers to use Markdownlint](./DocExamples/docs/markdownlint.md).
* [Guide for developers to create Markdown documentation](./DocExamples/docs/markdown-creation.md). This contains patterns as well as tips and tricks.
* [Guide for developers for end-user documentation](./DocExamples/docs/enduser-documentation.md).
* [Correct use and support of specific elements with Mermaid](./DocExamples/docs/ui-specific-elements.md).

## License

Please read the main [license file](LICENSE) and subfolder license files as well as the [third party notices](THIRD-PARTY-NOTICES.TXT). Most of these tools originate from work done in cooperation with [ZF](https://www.zf.com/).