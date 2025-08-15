# DocFX 的目录（TOC）生成器

此工具允许为 DocFX 生成 yaml 兼容的 `toc.yml` 文件。

## 用法

```text
TocGenerator -d <docs folder> [-o <output folder>] [-vsi]

-d, --docfolder       必需。包含文档的文件夹。
-o, --outputfolder    写入结果 toc.yml 的文件夹。
-v, --verbose         显示详细消息。
-s, --sequence        使用 .order 文件进行 TOC 序列。格式为：filename-without-extension
-r, --override        使用 .override 文件进行 TOC 文件名覆盖。格式为：filename-without-extension;您想要的标题
-i, --index           在每个文件夹中自动生成文件索引。
--help                显示此帮助屏幕。
--version             显示版本信息。
```

如果未提供 `-o 或 --outputfolder`，则输出文件夹设置为 docfolder。

如果工具的正常返回码为 0，但错误时返回 1。

## 警告、错误和详细输出

如果工具遇到可能需要采取行动的情况，则会向输出写入警告。目录仍然会创建。

如果工具遇到错误，则会向输出写入错误消息。目录将不会创建。工具将返回错误码 1。

如果您想跟踪工具在做什么，请使用 `-v 或 verbose` 标志来输出处理文件和文件夹以及创建目录的所有详细信息。

## 排序 TOC 条目

如果提供了 `-s 或 --sequence` 参数，工具将检查每个有内容的文件夹是否存在 .order 文件，并使用该文件来确定文件和目录的顺序。.order 文件只是一个文件和/或目录名称列表，区分大小写，没有文件扩展名。另请参阅[此文件的 Azure DevOps WIKI 文档](https://docs.microsoft.com/en-us/azure/devops/project/wiki/wiki-file-structure?view=azure-devops#order-file)。

示例 .order 文件可能如下所示：

```text
README
getting-started
working-agreements
developer
```

## 覆盖名称

如果提供了 `-r 或 --override` 参数，工具将检查每个有内容的文件夹是否存在 .override 文件。它将使用它来覆盖 TOC 中特定文件或目录显示的名称。
例如，如果文件夹名称是 `introduction`，默认行为将是创建名称 `Introduction`。如果您想称之为 `To start with`，您可以使用覆盖，如下例所示：

```text
introduction;To start with
working-agreements;All working agreements of all teams
```

只需使用不带扩展名的文件夹名称或 Markdown 文件名称，分号 `;` 作为分隔符以及要使用的所需名称。对于文件，没有此覆盖的默认行为是使用文件主标题中的描述。

如果有文件或目录不在 .order 文件中，它们将按标题字母顺序排序并添加到排序条目之后。MD 文件的标题取自文件中的 H1 标题。目录的标题是目录名称，但从特殊字符清理并首字母大写。

## 自动添加文件和目录索引

如果提供了 `-i 或 --index` 参数，对于每个没有 README.md 或 INDEX.md 的文件夹，将生成一个 INDEX.md，其中包含该文件夹的内容。该文件也会添加到该文件夹中文件和目录列表的顶部。

生成的 INDEX.md 包含一个带有文件夹名称的 H1 标题，后跟使用其标题和指向该项目的链接的文件和目录列表。