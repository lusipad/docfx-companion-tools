# 翻译 DocFX 的文档页面

此工具允许自动生成和翻译缺失文件或识别多语言模式目录中的缺失文件。最终用户文档应遵循的模式如下：

```text
/userdocs
  /.attachments
    picture-en.jpg
    picture-de.jpg
    photo.pgn
    otherdoc.pptx
  /en
    index.md
    /plant-production
      morefiles.md
      and-more.md
  /de
    .override
    index.md
    /plant-production
      morefiles.md
      and-more.md
  index.md
  toc.yml
```

至于其余文档，所有附件都应放在 `.attachments` 文件夹中，所有子目录目录都应为 2 个字符长度，匹配语言国际代码。在前面的示例中，`en` 代表英语，`de` 代表德语。

所有 Markdown 文件名**必须**在所有子目录中相同。此工具可以检查完整性，同时自动创建缺失文件并同时翻译它们。

## 用法

```text
DocLanguageTranslator -d <docs folder> [-k <key>] [-l <location>] [-cv]

-d, --docfolder       必需。包含文档的文件夹。
-v, --verbose         显示详细消息。
-k, --key             要使用的 Azure 认知服务密钥。
-l, --location        要使用的 Azure 认知服务位置。如果未提供任何内容，默认位置是 westeurope。
-c, --check           检查文件结构的完整性。
--help                显示此帮助屏幕。
--version             显示版本信息。
```

如果未提供 `-c 或 --check`，则必须拥有密钥。

如果工具的正常返回码为 0，但错误时返回 1。

## 警告、错误和详细输出

如果工具遇到可能需要采取行动的情况，则会向输出写入警告。目录仍然会创建。

如果工具遇到错误，则会向输出写入错误消息。目录将不会创建。工具将返回错误码 1。

如果您想跟踪工具在做什么，请使用 `-v 或 verbose` 标志来输出处理文件和文件夹以及创建目录的所有详细信息。

## 检查文件结构完整性

如果提供了 `-c 或 --check` 参数，工具将检查每个包含 Markdown 文件的文件夹，并检查这些文件是否存在于所有其他语言文件夹中。

如果没有完全相同的 Markdown 文件（扩展名必须为 `.md`），则会引发错误，缺失的文件将显示在输出中。

## 为所有语言目录创建缺失文件

如果 `-k 或 --key` 参数是工具创建缺失页面所必需的。让我们采用以下结构示例：

```text
/userdocs
  /.attachments
    picture-en.jpg
    picture-de.jpg
    photo.pgn
    otherdoc.pptx
  /en
    index.md
    /plant-production
      morefiles.md
  /de
    .override
    index.md
    one-more.md
    /plant-production
      morefiles.md
      and-more.md
  /fr
  index.md
  toc.yml
```

您必须使用如下命令行运行工具：`DocLanguageTranslator -d c:\path\userdocs -k abcdef0123456789abcdef0123456789`

*注意*：

* 您的密钥必须是有效的密钥。这是一个示例密钥。
* 目录可以是绝对的（例如 `c:\path\userdocs`）或相对的（例如 `.\userdocs`），并且必须是语言文件夹所在的根目录，因此在这种情况下是 `en`、`de` 和 `fr`（例如，文件夹将是 `\usersdocs\en`、`userdocs\de`、`userdocs\fr`）。

一旦您运行命令，程序将查看每个目录中的现有文件，并将它们翻译并放置在正确的目标文件夹中。因此在工具运行后，您将找到：

```text
/userdocs
  /.attachments
    picture-en.jpg
    picture-de.jpg
    photo.pgn
    otherdoc.pptx
  /en
    index.md
    one-more.md
    /plant-production
      morefiles.md
      and-more.md
  /de
    .override
    index.md
    one-more.md
    /plant-production
      morefiles.md
      and-more.md
  /fr
    index.md
    one-more.md
    /plant-production
      morefiles.md
      and-more.md
  index.md
  toc.yml
```

完整的文件结构和所有 Markdown 文件将在 `fr` 目录中创建，并从不同的来源翻译成法语。

仅存在于 `de` 语言中的 `and-more.md` 文件将被翻译成英语和法语。

### 限制

* 翻译过程并不完美！强烈建议有母语人士帮助以更好的方式进行翻译。
* 请检查所有相对链接，包括图像，有时它们被翻译了，但不应该被翻译。使用 VS Code 预览确保所有图像正确显示。
* 翻译需要一些时间，因为它是按段落完成的，每个段落都会发出请求。这允许顺利的过程并降低快速翻译的成本。
* 请确保在任何翻译后运行代码检查工具，翻译可能创建了额外的行结束，更改了一些表格等。
* 如果您达到限制，工具将等待并再次尝试。