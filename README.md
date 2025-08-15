# DocFX 伴侣工具

这个仓库包含一系列工具、模板、技巧和方法，让您的 [DocFX](https://dotnet.github.io/docfx/) 体验更加美好。

[English](README.md) | [中文文档](README.zh.md)

## 工具

* [DocAssembler 🆕](./src/DocAssembler)：从磁盘各个位置组装文档和资源，并将它们汇集到一个地方。可以重构结构，其中的链接会更改为正确的位置。
* [DocFxTocGenerator](./src/DocFxTocGenerator)：为 DocFX 生成 YAML 格式的目录（TOC）。具有配置文件顺序和文档及文件夹名称的功能。
* [DocLinkChecker](./src/DocLinkChecker)：验证文档中的链接并检查 `.attachments` 文件夹中的孤立附件。该工具会指示是否存在错误或警告，因此可以在 CI 管道中使用。它还可以自动清理孤立附件。并且可以验证表格语法。
* [DocLanguageTranslator](./src/DocLanguageTranslator)：允许自动生成和翻译缺失文件，或识别多语言模式目录中的缺失文件。
* [DocFxOpenApi](./src/DocFxOpenApi)：将现有的 [OpenAPI](https://www.openapis.org/) 规范文件转换为与 DocFX 兼容的格式（OpenAPI v2 JSON 文件）。它允许 DocFX 从 OpenAPI 规范生成 HTML 页面。OpenAPI 也被称为 [Swagger](https://swagger.io/)。

## 创建 PR

主分支是受保护的。功能和修复只能通过 PR 来完成。确保为 PR 使用适当的标题，并保持尽可能小的范围。如果您希望 PR 出现在变更日志中，您必须为 PR 提供一个或多个标签。使用的标签列表如下：

| 类别 | 描述 | 标签 |
| --- | --- | --- |
| 🚀 功能 | 新功能或修改的功能 | feature, enhancement |
| 🐛 修复 | 所有（错误）修复 | fix, bug |
| 📄 文档 | 文档添加或更改 | documentation |

## 构建和发布

如果您在本地机器上有这个仓库，您可以运行与我们工作流中相同的脚本来构建和打包。要构建工具，请使用 **build** 脚本。在 PowerShell 中运行此命令：

```PowerShell
.\build.ps1
```

此脚本的结果是一个包含所有解决方案可执行文件的输出文件夹。它们都作为单个 exe 发布，没有框架。它们依赖于环境中安装的 .NET 5。LICENSE 文件也被复制到输出文件夹。然后此文件夹的内容被压缩到根目录中名为 'tools.zip' 的 zip 文件中。

要打包和发布工具，您必须首先运行 **build** 脚本。接下来您可以运行我们也在工作流中使用的 **pack** 脚本。在 PowerShell 中运行此命令，其中您提供正确的版本：

```PowerShell
.\pack.ps1 -publish -version "1.0.0"
```

该脚本确定 tools.zip 的哈希值，更改 Chocolatey nuspec 和安装脚本以包含哈希值和正确的版本。然后创建 Chocolatey 包。如果设置了包含 Chocolatey 发布使用密钥的 **CHOCO_TOKEN** 环境变量，脚本还将发布包到 Chocolatey。否则会给出跳过发布步骤的警告。

如果省略 -publish 参数，脚本将以开发模式运行。它不会发布到 Chocolatey，并会输出 Chocolatey 文件的更改以供检查。

> [!NOTE]
> 如果您在本地运行 **pack** 脚本，文件会被更改（*deploy\chocolatey\docfx-companion-tools.nuspec* 和 *deploy\chocolatey\tools\chocolateyinstall.ps1*）。最好不要将这些提交到仓库中，尽管这不是秘密信息。下次运行仍会覆盖正确的值。

## 版本发布和发布到 Chocolatey

如果您有一个或多个 PR 并想发布新版本，只需确保所有 PR 都根据需要标记（见上文）并合并到主分支中。在主分支上手动运行手动 **Release & Publish** 工作流。这将提升版本，创建发布并向 Chocolatey 发布新包。

## 安装

### Chocolatey

可以通过下载 [release](https://github.com/Ellerbach/docfx-companion-tools/releases) 的 zip 文件或使用 [Chocolatey](https://chocolatey.org/install) 来安装工具，如下所示：

```shell
choco install docfx-companion-tools
```

> [!NOTE]
> 工具期望在本地安装 .NET Framework 6。如果您需要在更高的框架中运行它们，
> 添加 `--roll-forward Major` 作为参数，如下所示：
> `~/.dotnet/tools/DocLinkChecker --roll-forward Major`

### dotnet tool

您也可以通过 `dotnet tool` 安装工具。

```shell
dotnet tool install DocAssembler -g
dotnet tool install DocFxTocGenerator -g
dotnet tool install DocLanguageTranslator -g
dotnet tool install DocLinkChecker -g
dotnet tool install DocFxOpenApi -g
```

### 使用

一旦以这种方式安装了工具，您就可以直接从命令行使用它们。例如：

```PowerShell
DocFxTocGenerator -d .\docs -vs --indexing NotExists
DocLanguageTranslator -d .\docs\en -k <key> -v
DocLinkChecker -d .\docs -va
```

## CI 管道示例

* [文档构建管道](./PipelineExamples/documentation-build.yml)：使用 [DocFxTocGenerator](./src/DocFxTocGenerator) 生成目录和使用 DocFx 生成网站的示例管道。此示例还将发布到 Azure App Service。
* [文档验证管道](./PipelineExamples/documentation-validation.yml)：使用 [markdownlint](https://github.com/markdownlint/markdownlint) 验证 markdown 样式和使用 [DocLinkChecker](./src/DocLinkChecker) 验证链接和附件的示例管道。

## Docker

构建 Docker 镜像。以下示例基于 `DocLinkChecker`，为其他工具相应调整 `--tag` 和 `--build-arg`。

```shell
docker build --tag doclinkchecker:latest --build-arg tool=DocLinkChecker -f Dockerfile .
```

从 `PowerShell` 运行：

```PowerShell
docker run --rm -v ${PWD}:/workspace doclinkchecker:latest -d /workspace
```

从 Linux/macOS `shell` 运行：

```shell
docker run --rm -v $(pwd):/workspace doclinkchecker:latest -d /workspace
```

## 文档

* [为开发人员使用 Markdownlint 的指南](./DocExamples/docs/markdownlint.md)。
* [为开发人员创建 Markdown 文档的指南](./DocExamples/docs/markdown-creation.md)。这包含模式以及技巧和方法。
* [为开发人员提供最终用户文档的指南](./DocExamples/docs/enduser-documentation.md)。
* [正确使用和支持 Mermaid 的特定元素](./DocExamples/docs/ui-specific-elements.md)。

## 许可证

请阅读主要的 [许可证文件](LICENSE) 和子文件夹许可证文件以及 [第三方通知](THIRD-PARTY-NOTICES.TXT)。这些工具大部分来自与 [ZF](https://www.zf.com/) 合作完成的工作。