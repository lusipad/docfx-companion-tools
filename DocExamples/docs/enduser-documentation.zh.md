# 最终用户文档指南

最终用户文档放置在 `userdocs` 目录中，并遵循语言目录模式。

## 优势

这种模式可以在大多数在线网站中找到，如 Microsoft 文档网站。这有多个优势，如具有每种语言的清晰结构和清晰的导航，并允许轻松链接到资源。

通过复制/粘贴包含所有文件的结构然后进行本地化，可以轻松创建新语言。

## 不便之处

这种选择的主要不便之处在于您需要确保每种语言的结构相同，否则应用程序端的深层链接可能会断开。

为了缓解这种不便，应该构建一个结构检查器，如果所有语言的结构不相同，则给出警告。

## 文件夹结构

这是从根文件夹开始的目录组织方式：

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

在此示例中，名称是随机的，您当然必须调整为您想要的名称。

## 附件情况

**所有**附件，包括图片、文档都需要放在 `.attachments` 文件夹中。它们**必须**从其中一个 markdown 文件链接。

请注意，此文件夹对所有语言都是通用的。这允许灵活地重用文档、图片而不复制它们。

如果您需要多种语言的图片，那么您应该为语言使用后缀。例如，您需要用英语和德语拍摄用户界面的屏幕截图。您可以将文件命名为英语的 `picture-en.jpg` 和德语的 `picture-de.jpg`。这将允许您在附件文件夹中轻松找到它们，同时也便于本地化。

## 新语言入职

要入职新语言，从主语言复制语言文件夹的内容。假设主语言是德语，您想添加法语。将主 `/userdocs/de` 中的所有内容复制到新文件夹 `/userdocs/fr`。然后您可以专注于本地化。

## 文件夹名称和特殊名称覆盖

您可以使用名为 .override 的文件来覆盖文件或目录的名称。示例：

```text
plant-production;Anlagenproduktion
```

在这种情况下，如果放在 `/userdocs/de` 文件夹中，它将覆盖名称 `plant-production` 为 `Anlagenproduktion`，因此文件夹名称将自动被覆盖。