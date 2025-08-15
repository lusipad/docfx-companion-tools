# 文档链接检查器

此工具可用于检查 markdown 文件中的引用。

## 用法

```text
DocLinkChecker -d <docs folder> [-vac] [-f <config file>]

这些选项中需要一个。另一个可以添加以覆盖设置。
-d, --docfolder        包含文档的文件夹。
-f, --config           配置文件。

其他选项：
-v, --verbose          显示详细消息。
-a, --attachments      检查 docfolder 根目录中的 .attachments 文件夹是否有未引用的文件。
-c, --cleanup          从 docfolder 根目录中的 .attachments 文件夹中删除所有未引用的文件。必须与 -a 标志一起使用。
-t, --table            检查表格是否格式正确。
--help                 显示此帮助屏幕。
--version              显示版本信息。
```

如果工具的正常返回码为 0，但错误时返回 1。

## 警告、错误和详细输出

工具将首先读取配置的文档根目录中的所有 markdown 文件，并解析它们以提取链接、标题和表格。然后它将验证表格和链接。完成后，输出将写入控制台。当有错误或警告时，它们将按文件路径、行号然后列号排序写入输出。

工具始终输出所用工具的版本和结果摘要，包括退出码。

工具的退出码在下表中定义。退出码可用于确定是否采取其他可能的操作。

| 退出码 | 描述 |
| :--- | :--- |
| 0 | 执行已成功完成 |
| 1 | 命令行错误 |
| 3 | 配置文件错误 |
| 1000 (Linux 上为 232) | 执行仅以警告完成 |
| 1001 (Linux 上为 233) | 执行以错误完成 |

如果您想详细跟踪工具在做什么，请使用 `-v 或 verbose` 标志来输出处理文件和文件夹的所有详细信息。

> [!NOTE]
>
> Linux 上的返回码（大部分）被截断为字节，这使得 1000 和 1001 的返回码被报告为 232 和 233。

## 配置文件

配置文件可用于工具使用的（更多）设置。如果提供了命令行参数，它们将覆盖这些设置。

可以使用以下命令在工作目录中生成一个名为 `docfx-companion-tools.json` 的初始化配置文件：

```shell
DocLinkChecker INIT
```

如果工作目录中已存在 `docfx-companion-tools.json` 文件，则会给出错误，不会覆盖它。主要结构如下所示：

```json
{
  "DocumentationFiles": {
    "src": "",
    "Files": [
      "**/*.md"
    ],
    "Exclude": []
  },
  "ResourceFolderNames": [
    ".attachments"
  ],
  "DocLinkChecker": {
    "RelativeLinkStrategy": "All",
    "CheckForOrphanedResources": false,
    "CleanupOrphanedResources": false,
    "ValidatePipeTableFormatting": false,
    "ValidateExternalLinks": false,
    "ConcurrencyLevel": 5,
    "MaxHttpRedirects": 20,
    "ExternalLinkDurationWarning": 3000,
    "WhitelistUrls": [
      "http://localhost"
    ]
  }
}
```

### 要包含或排除的文件

配置文件有一个 `DocumentationFiles` 条目，可以部分填写或可以以其完整形式使用。完整形式如下所示：

```json
  "DocumentationFiles": {
    "src": "",
    "Files": [
      "**/*.md"
    ],
    "Exclude": []
  }
```

这些属性与 [.NET 中的文件通配符](https://learn.microsoft.com/en-us/dotnet/core/extensions/file-globbing) 模式结合使用。

`src` 属性指示文档层次结构所在的文件夹。此值可以被 `-d <folder>` 命令行参数覆盖。

`Files` 属性是要包含在检查中的文件[模式](https://learn.microsoft.com/en-us/dotnet/core/extensions/file-globbing#pattern-formats)列表。如果未提供任何内容，则自动添加 `**/*.md` 以包含所有 markdown 文件。

`Exclude` 属性也是要排除在检查中的文件[模式](https://learn.microsoft.com/en-us/dotnet/core/extensions/file-globbing#pattern-formats)列表。

### 资源文件夹名称

资源是在 markdown 文件中引用的但本身不是 markdown 文件的文件。想想图像等。

`ResourceFolderNames` 属性是可以用作资源文件夹的名称列表。当验证资源时，它们应该存储在具有此列表中定义的名称的文件夹（或文件夹的子文件夹）中。默认情况下，此处定义了 ".attachments"，这意味着资源必须是类似 "....../.attachments/my-image.png" 或 "....../.attachments/my-topic/my-image.png" 的东西。

当检测到或删除孤立资源时，也会检查这些文件夹。有关更多详细信息，请参阅下文。

### DocLinkChecker 设置

可以在配置文件中提供各种设置，特定于 DocLinkChecker。我们在下表中列出它们。

| 设置                        | 目的                                                      | 默认值        |
| -------------------------- | --------------------------------------------------------- | ------------- |
| RelativeLinkStrategy | "All" 允许链接到所有现有文件，"SameDocsHierarchyOnly" 仅允许链接到同一 /docs 层次结构中的文件，"AnyDocsHierarchy" 仅允许链接到任何 /docs 层次结构中的文件。  | *All* |
| CheckForOrphanedResources      | 如果此值设置为 **true**，工具将检查具有 `ResourceFolderNames` 列表中名称的文件夹中的文件是否未被任何扫描的 markdown 文件使用。这些文件将以错误报告。 | *false*       |
| CleanupOrphanedResources       | 如果此值设置为 **true** 且未报告错误，工具将从所有具有 `ResourceFolderNames` 列表中名称的文件夹中删除孤立资源。 | *false*       |
| ValidatePipeTableFormatting    | 如果此值设置为 **true**，工具将验证所有管道表定义是否正确定义。有关验证内容的更多信息，请参阅[表验证](#表验证)。 | *false*       |
| ValidateExternalLinks          | 如果此值设置为 **true**，工具将验证所有网页链接是否仍然有效。有关详细信息，请参阅[网页链接](#网页链接)。 | *false*       |
| ConcurrencyLevel               | 此值定义用于验证链接的并发线程数，包括本地和网页链接。您可以使用它来提高工具的性能，在验证网页链接时影响最大。 | *5*           |
| ExternalLinkDurationWarning    | 当外部链接的验证时间超过此值时，工具将报告警告。值以毫秒为单位。此值仅在验证外部链接时使用。 | *3000*        |
| WhitelistUrls                  | 这是将跳过外部链接验证的 URL 列表。有关更多详细信息，请参阅[将网页链接列入白名单](#将网页链接列入白名单)。 | *"http://localhost"* |

## 验证什么

工具使用 [markdig](https://github.com/xoofx/markdig) 从 markdown 文件中提取链接、表格和标题。

### 本地引用

验证对同一层次结构中其他 markdown 文件的链接是否存在。当引用文档根目录之外的文件时，根据 `AllowLinksOutsideDocumentsRoot` 设置报告错误或警告。当使用完整根路径（如 `d:\\git\\project\\docs\\some-file.md`）引用本地文件时，报告错误，不允许这样做。这样的引用在其他机器上会有所不同。

验证对标题的链接（如 `#some-heading` 或 `./another-file.md#another-heading`）。如果找不到它们，但可以找到文件，则报告警告。链接将可以打开文档（或页面），但不会将您定位到该文档中的某个位置。

### 忽略的链接

像 `mailto:`（电子邮件地址）或 `xref:`（[按 id 引用链接](https://dotnet.github.io/docfx/tutorial/links_and_cross_references.html)）这样的链接被忽略，根本不验证。

### 网页链接

Markdown 链接可用于引用网页链接。当链接以以下开头时，工具将链接验证为网页链接：

* *http* 或 *https*
* *ftp* 或 *ftps*

当 `ValidateExternalLinks` 设置为 **true** 且链接未被 `WhitelistUrls` 排除时，将验证 URL 是否存在。当出现以下情况时，工具将报告 URL 的错误：

* 未找到 URL (404)
* URL 报告为消失 (410)
* 请求 URI 太长 (414)

重定向 (300-399) 被视为存在的 URL。其他状态码（如 401 未经授权、403 禁止、500 内部服务器错误或 503 服务不可用等）被视为现有资源，但具有这些状态码的 URL 将报告为警告。

#### 将网页链接列入白名单

可以从验证中排除某些网页链接。这可以使用 `WhitelistUrls` 列表来完成。可以使用通配符（* 和 ?）来定义要跳过的 URL 模式。

有效模式的示例有：

| 模式                      | 含义                                                      |
| ------------------------- | --------------------------------------------------------- |
| http://localhost          | 排除所有以 http://localhost 开头的 URL。                   |
| http://localhost:?000/*   | 排除所有以 http://localhost**:5000**/ 开头的 URL，但以 http://localhost**:8080**/ 开头的 URL 不排除。字符通配符 (?) 仅用于 1 个字符。 |
| https://\*.contoso.com/\* | 排除 contoso.com 的所有**安全**网站 (https)。例如 **https**://documents.contoso.com 或 **https**://reports.contoso.com。 |
| http*://\*.contoso.com/\* | 排除 contoso.com 的所有网站（http 或 https）。例如 **http**://demo.contoso.com 或 **https**://reports.contoso.com。 |

如果未使用通配符，* 通配符会自动附加到 URL。但如果使用了一个或多个通配符，则不会这样做。

如果链接是网页 URL、内部引用（以 '#' 开头）、电子邮件地址或对文件夹的引用，则不会检查。其他链接会检查它们是否存在于现有的文档层次结构或本地磁盘上（用于代码引用）。错误将写入输出，提及文件名、行号和行中的位置。在检查中，我们还解码引用以确保我们也正确检查 HTML 编码的字符串（例如使用 %20）。

所有引用都存储在一个表中，用于检查 .attachments 文件夹（使用 -a 标志）。此文件夹中所有未被引用的文件都被标记为"未引用"。如果还提供了 -c 标志，则文件将从 .attachments 文件夹中删除。

### 表验证

[表（也称为管道表）](https://www.markdownguide.org/extended-syntax/#tables) 可以在 markdown 中使用。然而，并非所有渲染器都以相同的方式处理定义。为确保所有渲染器正确渲染表格，表验证将检查这些内容：

1. 所有行是否具有相同数量的列？第一行定义宽度。
2. 所有行是否以管道字符 '|' 开始和结束？
3. 第二行（分隔线）中的所有列是否每列至少有三个破折号？

当 `ValidatePipeTableFormatting` 设置为 **true** 时，工具将报告表格的每个这些错误。

### 资源

资源是在 markdown 文件中引用的但本身不是 markdown 文件的文件。想想图像等。工具仅允许将资源存储在 `ResourceFolderNames` 设置中列出的文件夹中。它也可以存储在该文件夹的子文件夹中。

默认情况下，配置中定义了 ".attachments"，这意味着资源必须是类似 "....../.attachments/my-image.png" 或 "....../.attachments/my-topic/my-image.png" 的东西。`....` 表示它可以位于文档层次结构中的任何位置。

当检查孤立资源时，我们检查所有文件夹（及其子文件夹）中的资源文件是否被文档层次结构中的某个 markdown 文件引用。如果不是这种情况，工具将报告该文件为孤立文件。这仅在 `CheckForOrphanedResources` 设置为 **true** 时完成。当 `CleanupOrphanedResources` 也设置为 **true** 时，如果扫描未报告其他错误，工具还将删除孤立资源。