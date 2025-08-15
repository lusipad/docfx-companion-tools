# Markdownlint：使用 Markdown 代码检查工具

## 什么是 Markdown

Markdown 是一种轻量级标记语言，您可以用来为纯文本文档添加格式化元素。由 John Gruber 于 2004 年创建，Markdown 现在是世界上最流行的标记语言之一。

使用 Markdown 与使用所见即所得编辑器不同。在 Microsoft Word 这样的应用程序中，您点击按钮来格式化单词和短语，更改会立即显示。Markdown 不是这样的。当您创建 Markdown 格式的文件时，您向文本添加 Markdown 语法来指示哪些单词和短语应该看起来不同。

您可以找到更多信息、完整的文档[这里](https://www.markdownguide.org/)。

## 为什么使用代码检查工具

Markdown 有特定的格式化方式。尊重这种格式很重要，否则一些严格的解释器将无法正确显示文档。Azure DevOps 解释器会原谅很多错误，并始终尝试正确显示文档。但远非所有解释器都是这样。代码检查工具通常用于帮助开发人员以任何语言或标记语言正确创建文档。

为了帮助开发人员和任何需要创建 Markdown 的人，我们建议使用 [Markedownlint](https://github.com/DavidAnson/markdownlint)，这是一个简单且最常用的 Markdown 文档代码检查工具。[Markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) 是一个基于 Markdownlint 的易于使用的命令行工具。

## 规则

全面的规则列表可在[这里](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)找到。我们将采用相当严格的方法，除了行长度规则 MD013，我们将不应用。

项目根目录中有一个配置文件供您方便使用。文件是 `.markdownlint.json`，包含：

```json
{
    "MD013": false
}
```

然后只需运行以下命令：

```bash
markdownlint -f path_to_your_file.md
```

请注意，-f 参数将修复所有基本错误并节省您的时间。

## 使用 VS Code 扩展

有几个 VS Code 扩展也可以帮助您完成此任务。我们可以推荐 [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)，它也会捕获所有这些错误。

## Azure DevOps 管道

Markdownlinter 也是 Azure DevOps 代码质量管道的一部分，它会在 PR 到 dev 时自动运行。

TODO：添加管道链接。