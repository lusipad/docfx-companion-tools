# 文档组装工具

此工具可用于从磁盘上的各个位置组装文档，并确保所有链接仍然有效。

## 用法

```text
DocAssembler [command] [options]

Options:
  --workingfolder <workingfolder>  工作文件夹。默认是当前文件夹。
  --config <config> (必需)        组装文档的配置文件。
  --outfolder <outfolder>          覆盖配置文件中组装文档的输出文件夹。
  --cleanup-output                 在生成前清理输出文件夹。注意：这将删除所有文件夹和文件！
  -v, --verbose                    显示过程的详细消息。
  --version                        显示版本信息
  -?, -h, --help                   显示帮助和使用信息

Commands:
  init  如果当前目录中尚不存在配置文件，则初始化一个配置文件。
```

如果工具的正常返回码为 0，但错误时返回 1。

返回值：
  0 - 成功。
  1 - 一些警告，但过程可以完成。
  2 - 发生致命错误。

## 警告、错误和详细输出

如果工具遇到可能需要采取行动的情况，则会向输出写入警告。文档仍然会组装。如果工具遇到错误，则会向输出写入错误消息。文档可能不会组装或完成。

如果您想跟踪工具在做什么，请使用 `-v 或 --verbose` 标志来输出处理文件和文件夹以及组装内容的所有详细信息。

## 整体过程

此工具的整体过程是：

1. 内容清单 - 检索所有可以在配置的内容集中找到的文件夹和文件。在此阶段，我们已经在配置的输出文件夹中计算了新路径。如果配置了 URL 替换，则在此处执行（有关更多详细信息，请参阅[`Replacement`](#replacement)）。
2. 如果配置了，则删除现有的输出文件夹。
3. 将所有找到的文件复制到新计算的位置。如果配置了内容替换，则在此处执行。我们还更改 markdown 文件中的链接到引用文件的新位置，除非它是"原始复制"。未在内容集中找到的引用文件将使用配置的前缀作为前缀。

基本思想是定义一个内容集，该内容集将被复制到目标文件夹。这样做的原因是，我们现在可以完全重构文档，但也应用内容中的更改。在 CI/CD 过程中，这可以用于组装所有文档，以准备使用 [DocFxTocGenerator](https://github.com/Ellerbach/docfx-companion-tools/blob/main/src/DocFxTocGenerator) 生成目录，然后使用 [DocFx](https://dotnet.github.io/docfx/) 等工具生成文档网站。该工具期望内容集经过有效链接验证。这可以使用 [DocLinkChecker](https://github.com/Ellerbach/docfx-companion-tools/blob/main/src/DocLinkChecker) 来完成。

## 配置文件

使用配置文件进行设置。如果提供了命令行参数，它们将覆盖这些设置。

可以使用以下命令在工作目录中生成一个名为 `.docassembler.json` 的初始化配置文件：

```shell
DocAssembler init
```

如果工作目录中已存在 `.docassembler.json` 文件，则会给出错误，不会覆盖它。生成的结构将如下所示：

```json
{
  "dest": "out",
  "externalFilePrefix": "https://github.com/example/blob/main/",
  "content": [
    {
      "src": ".docfx",
      "files": [
        "**"
      ],
      "rawCopy": true
    },
    {
      "src": "docs",
      "files": [
        "**"
      ]
    },
    {
      "src": "backend",
      "dest": "services",
      "files": [
        "**/docs/**"
      ],
      "urlReplacements": [
        {
          "expression": "/[Dd]ocs/",
          "value": "/"
        }
      ]
    }
  ]
}
```

### 通用设置

在通用设置中可以设置这些属性：

| 属性              | 描述                                                  |
| ----------------- | ----------------------------------------------------- |
| `dest` (必需)     | 工作文件夹中的目标子文件夹，用于将组装的文档复制到。此值可以被 `--outfolder` 命令行参数覆盖。 |
| `urlReplacements` | 用于跨内容集 URL 路径的 [`Replacement`](#replacement) 对象的全局集合。这些替换应用于内容集中文件的计算目标路径。这可用于修改路径。生成的模板从路径中删除 /docs/ 并替换为 /。如果内容集配置了 `urlReplacements`，它将覆盖这些全局替换。更多信息可以在 [`Replacement`](#replacement) 下找到。 |
| `contentReplacements` | 用于跨内容集文件内容的 [`Replacement`](#replacement) 对象的全局集合。这些替换应用于内容集中所有 markdown 文件的内容。这可用于修改例如 URL 或其他内容项。如果内容集配置了 `contentReplacements`，它将覆盖这些全局替换。更多信息可以在 [`Replacement`](#replacement) 下找到。 |
| `externalFilePrefix`  | 用于所有内容集中不属于文档的引用文件（如源文件）的全局前缀。此前缀与工作文件夹的子路径一起使用。如果内容集配置了 `externalFilePrefix`，它将覆盖此全局前缀。 |
| `content` (必需)  | 用于定义要组装的所有内容集的 [`Content`](#content) 对象集合。 |

### `Replacement`

替换定义具有这些属性：

| 属性         | 描述                                                  |
| ------------ | ----------------------------------------------------- |
| `expression` | 用于查找特定文本的正则表达式。                         |
| `value`      | 替换找到的文本的值。也可以使用命名的匹配子表达式，如下所述。 |

此类型用于 URL 替换或内容替换的集合。它们一个接一个地应用，从第一个条目开始。正则表达式用于查找将被值替换的文本。表达式是 [.NET 正则表达式 - .NET Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/standard/base-types/regular-expressions) 中描述的正则表达式。那里也可以找到示例。有像 [regex101: build, test, and debug regex](https://regex101.com/) 这样的网站来构建、调试和验证您需要的表达式。

#### 使用命名的匹配子表达式

有时您想找到特定的内容，但也想在值替换中重用它的一部分。一个例子是找到所有 `AB#1234` 表示法，并用对引用的 Azure Boards 工作项或 GitHub 项目的 URL 替换它。但在这种情况下，我们想在值中使用 ID (1234)。为此，您可以使用[命名的匹配子表达式](https://learn.microsoft.com/en-us/dotnet/standard/base-types/grouping-constructs-in-regular-expressions#named-matched-subexpressions)。

可以使用此表达式来查找所有这些引用：

```regex
(?<pre>[$\\s])AB#(?<id>[0-9]{3,6})
```

由于我们不想找到像 `[AB#1234](https://...)` 这样的链接，我们查找所有在行首（使用 `$` 标签）或以空格（使用 `\s` 标签）为前缀的 AB# 引用。由于我们需要保持该前缀不变，我们将其捕获为名为 `pre` 的命名子表达式。

> [!NOTE]
>
> 由于表达式在 JSON 文件的字符串中配置，像反斜杠这样的特殊字符需要被（额外的）反斜杠转义，如您在上面的示例中所见，其中 `\s` 被额外的 `\` 转义。

第二部分是获取 AB# 文本之后的数字。这里配置为 3 到 6 个字符之间。我们也想在值中重用此 ID，所以我们将其捕获为名为 `id` 的命名子表达式。

在值中，我们可以像这样重用这些命名的子表达式：

```text
${pre}[AB#${id}](https://dev.azure.com/[your organization]/_workitems/edit/${id})
```

我们从 `pre` 值开始，之后我们构建一个 markdown 链接，AB# 与 `id` 作为文本，`id` 作为 URL 的参数组合。我们在这里引用 Azure Board 工作项。当然，您需要在此处将 `[your organization]` 替换为您的 ADO 环境的正确值。使用上面的示例，文本 *AB#1234* 将被翻译为 *[AB#1234](https://dev.azure.com/[your organization]/_workitems/edit/1234)*。

### `Content`

内容定义具有这些属性：

| 属性         | 描述                                                  |
| ------------ | ----------------------------------------------------- |
| `src` (必需) | 相对于工作文件夹的源子文件夹。                         |
| `dest`       | 输出文件夹中的可选目标子文件夹路径。如果未提供，则使用源文件夹的相对路径。 |
| `files`      | 这是 [.NET 中的文件通配符](https://learn.microsoft.com/en-us/dotnet/core/extensions/file-globbing) 模式。确保还包括文档所需的所有文件，如图像和资源。 |
| `exclude`    | 这是 [.NET 中的文件通配符](https://learn.microsoft.com/en-us/dotnet/core/extensions/file-globbing) 模式。这可用于从内容集中排除特定的文件夹或文件。 |
| `rawCopy`    | 如果此值为 `true`，则我们不查看 markdown 文件中的任何链接，因此也不修复它们。这可用于要包含在文档集中的原始内容，如 `.docfx.json`、模板等。 |
| `urlReplacements`     | 用于此内容集中 URL 路径的 [`Replacement`](#replacement) 对象集合，覆盖任何全局设置。这些替换应用于内容集中文件的计算目标路径。这可用于修改路径。生成的模板从路径中删除 /docs/ 并替换为 /。更多信息可以在 [`Replacement`](#replacement) 下找到。 |
| `contentReplacements` | 用于此内容集中文件内容的 [`Replacement`](#replacement) 对象集合，覆盖任何全局设置。这些替换应用于内容集中所有 markdown 文件的内容。这可用于修改例如 URL 或其他内容项。更多信息可以在 [`Replacement`](#replacement) 下找到。 |
| `externalFilePrefix`  | 用于此内容集中不属于完整文档集的所有引用文件（如源文件）的前缀。它覆盖任何全局前缀。此前缀与工作文件夹的子路径一起使用。 |