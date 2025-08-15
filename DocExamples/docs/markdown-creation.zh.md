# 在仓库中创建 Markdown 的规则

本文档解释了我们在各种项目中用于创建适当 Markdown 文件的几个规则。这些规则有助于维护高质量的文件库和健全的文件结构。这也允许在 `Azure DevOps` 中使用 `Wiki as Code` 功能。

Markdown 文件是基于文本的。如果您想了解可能性（标题、列表、表格、代码等），这个速查表总是很有帮助：[Markdown Cheatsheet · adam-p/markdown-here Wiki · GitHub](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)。有很多这样的速查表。

## 图片和附件

**所有**存储在 `/docs` 中的图片和附件**必须**存储在 `/docs/.attachments` 中。

原因：我们使用 [DocFX](https://dotnet.github.io/docfx/) 来生成静态网站。我们只从 `/docs/.attachments` 移动附件和图片。其余的被忽略。

## 命名约定

请遵循这些简单的规则：

- 尽量只在名称中使用小写
- 不要使用空格，使用 `-`
- 只使用字母表和数字中的 ASCII 7 字符

## 链接

可以使用外部链接。

对于文档本身的链接，请使用文件的相对链接。例如，如果您在 `/docs/userdocs/en/plant-production` 中并想引用位于 `/docs/userdocs` 的文档 `index.md`，链接将是 `../../index.md`。

您也可以使用指向 DocFX 项目根目录的相对链接。例如，[此链接](~/userdocs/index.md) 使用相对于项目根目录的链接从此页面引用 `/docs/userdocs/index.md`。此场景的链接将是 `~/userdocs/index.md`。这仅在 Docfx 项目中有效。

## Markdown 代码检查

我们使用 Markdown 链接来确保 Markdown 正确编写。当您执行 PR 时运行，并会给您错误。查看更多详细信息[这里](markdownlint.md)。

## 实用技巧与窍门

### 在 VS Code 中预览

在 VS Code 中编辑 markdown 时，右上角有一个预览按钮，将在左侧打开实时预览窗口。因此您可以同时输入和查看结果。这通常是避免基本错误的好方法，例如确保您的图片正确显示。

![VS Code 预览](.attachments/VSCodeMdPreview.gif)

### Typora 作为替代工具

[Typora](https://typora.io/) 是一个在线编辑器，帮助您生成适当的 Markdown。它可以帮助您创建第一个 Markdown，习惯它。它还具有很棒的功能，例如能够从网页的复制/粘贴创建表格。请注意这是一个在线工具以及您可能放入此工具的信息的机密性。

### 推送前运行 markdownlint

为了确保在推送之前，在您的 md 文件上运行 markdownlint 工具并解决所有消息。此工具将在管道中运行以验证您的 Markdown 文件。查看更多详细信息[这里](markdownlint.md)。

**重要**：如果 Markdown 文件**没有**正确形成，将不可能进行任何合并。因此，在进行 PR 之前运行代码检查工具并修复所有问题非常重要。

### 使用拼写检查器

您有很多拼写检查器扩展，它们将减少错误数量。我们可以在 VS Code 中推荐您，`Spell Right` 或 `Code Spell Checker` 扩展。

### 枚举的模式

在处理 markdown 以及尝试使用枚举时，可能会有些令人沮丧。要记住的一个关键点是，markdown 和一般的枚举都是为了分组。一旦您需要大量的文本或代码块，枚举并不是最好的。所以这里有几个模式。

```markdown
# 这是唯一的主标题

## 您可以有任意数量的标题 2

1. 我的枚举从 1 开始
  - 我有子项目符号，也可以是枚举
  - 还有一个
1. 这个将是数字 2
1. 您可以猜到，这个是 3

1. 现在，这个又是 1，因为两个枚举之间有回车
1. 再次是 2

```

如果您尝试获取包含段落和代码块的大文本块，请使用 `Step #` 模式，如下所示：

```markdown

- 步骤 1：做某事

这里您可能有很多废话、一些文本代码块、图片等。

- 步骤 2：做下一步

同样，这里有很多东西。

- 步骤 3：您可以继续此模式

```

### 在 markdown 文件中添加表情符号

如果您在 markdown 内容中添加一些表情符号，这是将基本内容带到重点的好方法。要添加它们，请根据您的操作系统使用以下快捷方式：

- 在 Mac 上：CTRL + CMD + Space
- 在 Windows 上：Win + ;（分号）或 Win + .（句号）

![表情符号](.attachments/markdown-icons.png)

## 移动文件

一般来说，尽量**不要**移动文件。文件中有很多指向彼此的链接。

如果您想更改文件，这里有一个捕获断开链接的过程：

- 一旦您在自己的分支中移动文件，将您的分支推送到仓库中
- 推送后，运行[文档自动创建管道](TODO：放置管道样本的适当链接)
- 打开 DocFX 任务结果并检查日志，它将包含断开的链接
- 更正断开的文件
- 推回更改
- 进行您的 PR