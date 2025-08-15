# DocFX 的 OpenAPI 规范转换器

此工具将现有的 [OpenAPI](https://www.openapis.org/) 规范文件转换为与 DocFX 兼容的格式（OpenAPI v2 JSON 文件）。它允许 DocFX 从 OpenAPI 规范生成 HTML 页面。OpenAPI 也被称为 [Swagger](https://swagger.io/)。

## 用法

```text
DocFxOpenApi -s <specs folder> [-o <output folder>] [-v]
  -s, --specsource      必需。包含 OpenAPI 规范的文件夹或文件。
  -o, --outputfolder	写入结果规范的文件夹。
  -v, --verbose         显示详细消息。
  --help                显示此帮助屏幕。
  --version             显示版本信息。
```

当向 `specsource` 参数提供文件夹时，工具转换文件夹及其子文件夹中的所有 `*.json`、`*.yaml`、`*.yml` 文件。当提供文件时，工具仅转换该文件。
它支持 JSON 或 YAML 格式、OpenAPI v2 或 v3（包括 3.0.1）格式文件。

如果未提供 `-o 或 --outputfolder`，则输出文件夹设置为输入规范文件夹。

如果工具的正常返回码为 0，但错误时返回 1。

## 警告、错误和详细输出

如果工具遇到可能需要采取行动的情况，则会向输出写入警告。目录仍然会创建。

如果工具遇到错误，则会向输出写入错误消息。目录将不会创建。工具将返回错误码 1。

如果您想跟踪工具在做什么，请使用 `-v 或 verbose` 标志来输出处理文件和文件夹以及创建目录的所有详细信息。

## 限制和解决方法

- 截至 2021 年 5 月，DocFX 仅支持从 [OpenAPI v2 JSON 文件](https://dotnet.github.io/docfx/tutorial/intro_rest_api_documentation.html) 生成文档。因此，该实用程序将输入文件转换为该格式。
- 截至 2021 年 5 月，DocFX [不包括类型定义](https://github.com/dotnet/docfx/issues/2072)。
- OpenAPI v2 格式不允许为结果负载提供多个示例。OpenAPI v3 允许提供单个示例或示例集合。如果提供了示例集合，该实用程序将使用第一个示例作为输出文件中的示例。