# DocFX 的 UI 特定元素

## 提供特定文件

如果您开始自定义 DocFX 模板，您很可能最终需要支持搜索和字体的特定文件。根据您部署它们的位置，这可能需要调整您的 Web 服务器。如果在 Azure Web 应用程序中部署，您将需要调整 [web.config](../ui-specific/web.config) 文件。

您还必须将其添加到您在根目录中部署的文件中。请参阅 [docfx.json](../docfx.json) 文件中此示例的完成方式。

## 添加对 mermaid 架构的支持

[Mermaid](https://github.com/mermaid-js/mermaid) 是获得关系图、流程图和图表文本支持的好方法。DocFX 开箱即用不支持它，您需要添加此支持。最好的方法之一是自定义 UI 模板并调整 `partials/scripts.tmpl.partial` 中的文件，如下所示：

```js
{{!Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See LICENSE file in the project root for full license information.}}

<script type="text/javascript" src="{{_rel}}styles/docfx.vendor.js"></script>
<script type="text/javascript" src="{{_rel}}styles/docfx.js"></script>
<script type="text/javascript" src="{{_rel}}styles/main.js"></script>

<!-- mermaid support -->
<script src="https://unpkg.com/mermaid@8.4/dist/mermaid.min.js"></script>
<script>
    mermaid.initialize({
        startOnLoad: false
    });

    window.onload = function () {
        const elements = document.getElementsByClassName("lang-mermaid");
        let index = 0;

        while (elements.length != 0) {
            let element = elements[0];
            mermaid.render('graph'+index, element.innerText, (svgGraph) => {                    
                element.parentElement.outerHTML = "<div class='mermaid'>" + svgGraph + "</div>";
            });
            ++index;
        }
    }
</script>
```

*注意*：像任何其他脚本一样，请不要忘记定期更新版本。

这是一个非常简单的 mermaid 示例：

```mermaid
requests
| where name == "POST Idoc/Send"
| where resultCode == 200
| where customDimensions contains "ResponseBody"
| order by timestamp desc
```