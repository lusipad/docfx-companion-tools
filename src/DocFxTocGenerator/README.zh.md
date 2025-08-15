# DocFX 的目录（TOC）生成器

此工具允许为 DocFX 生成 yaml 兼容的 `toc.yml` 文件。

## 用法

```text
DocFxTocGenerator [options]

Options:
  -d, --docfolder <docfolder> (必需)                      文档的根文件夹。
  -o, --outfolder <outfolder>                                 生成的目录文件的输出文件夹
                                                              文件。默认是文档文件夹。
  -v, --verbose                                               显示过程的详细消息。
  -s, --sequence                                              使用每个文件夹的 .order 文件定义文件和目录的序列。
                                                              文件的格式是每行不带扩展名的文件名。
  -r, --override                                              使用每个文件夹的 .override 文件定义文件和文件夹的标题覆盖。
                                                              文件的格式是每行不带扩展名的文件名或目录名，
                                                              后跟一个分号，后跟自定义标题。
  -g, --ignore                                                使用每个文件夹的 .ignore 文件忽略目录。
                                                              文件的格式是每行的目录名。
  --indexing                                                  何时为文件夹生成 index.md。
  <EmptyFolders|Never|NoDefault|NoDefaultMulti|NotExistMulti  Never          - 不要生成。
  |NotExists>                                                 NoDefault      - 当找不到 index.md 或 readme.md 时生成。
                                                              NoDefaultMulti - 当找不到 index.md 或 readme.md 且有多个文件时生成。
                                                              EmptyFolders   - 为空文件夹生成。
                                                              NotExists      - 当找不到索引时生成。
                                                              NotExistMulti  - 当没有索引且有多个文件时生成。
                                                              [默认: Never]
  --folderRef <First|Index|IndexReadme|None>                  文件夹条目引用的策略。
                                                              None        - 从不引用任何内容。
                                                              Index       - 仅当存在时引用 Index.md。
                                                              IndexReadme - 如果存在，引用 Index.md 或 readme.md。
                                                              First       - 如果存在，引用文件夹中的第一个文件。
                                                              [默认: First]
  --ordering <All|FilesFirst|FoldersFirst>                    如何在文件夹中排序项目。
                                                              All          - 文件夹和文件组合。
                                                              FoldersFirst - 文件夹在前，然后是文件。
                                                              FilesFirst   - 文件在前，然后是文件夹。[默认: All]
  -m, --multitoc <multitoc>                                   指示在树中多深为这些文件夹生成 toc 文件。
                                                              深度 0 仅是根（默认行为）。
  --camelCase                                                 使用驼峰命名法作为标题。
  --version                                                   显示版本信息
  -?, -h, --help                                              显示帮助和使用信息
```

返回值：
  0 - 成功。
  1 - 一些警告，但过程可以完成。
  2 - 发生致命错误。

## 警告、错误和详细输出

如果工具遇到可能需要采取行动的情况，则会向输出写入警告。目录仍然会创建。如果工具遇到错误，则会向输出写入错误消息。目录将不会创建。

如果您想跟踪工具在做什么，请使用 `-v 或 --verbose` 标志来输出处理文件和文件夹以及创建目录的所有详细信息。

## 整体过程

此工具的整体过程是：

1. 内容清单 - 检索给定文档文件夹中的所有文件夹和文件（`*.md` 和 `*swagger.json`）。标志 `-s | --sequence`、`-r | --override` 和 `-g | --ignore` 在此处处理以读取层次结构中的设置文件。
2. 确保索引 - 使用给定设置验证结构。根据 `--indexing` 标志，在必要时自动添加 `index.md` 文件。
3. 生成目录 - 生成 `toc.yml` 文件。对于文件夹，可以指示它们是否应该使用 `--folderRef` 标志具有对子文件的引用。使用 `--ordering` 标志可以定义目录和文件的排序。在此步骤中，评估和处理生成时的 `-m | --multitoc <multitoc>` 标志。

### 目录和文件的标题

对于目录，默认使用目录名称，其中第一个字符大写，特殊字符（`[`, `]`, `:`, \`,`\`, `{`, `}`, `(`, `)`, `*`, `/`）被删除，`-`、`_` 和多个空格被替换为单个空格。

对于 markdown 文件，第一级 1 标题作为标题。对于 swagger 文件，标题和版本作为标题。出错时，使用不带扩展名的文件名并以与目录名称相同的方式处理。

`.override` 设置文件可用于覆盖此行为。请参阅[使用 `.override` 定义标题覆盖](#使用-override-定义标题覆盖)。

## 文件夹设置

文件夹设置可以用于排序目录和文件、忽略目录和覆盖文件标题。标志 `-s | --sequence`、`-r | --override` 和 `-g | --ignore` 在此处处理以读取层次结构中的设置文件。

### 使用 `.order` 定义顺序

如果提供了 `-s | --sequence` 参数，工具将检查文件夹是否存在 `.order` 文件，并使用它来确定文件和目录的顺序。`.order` 文件只是一个文件和/或目录名称列表，*区分大小写*，不带文件扩展名。另请参阅[此文件的 Azure DevOps WIKI 文档](https://docs.microsoft.com/en-us/azure/devops/project/wiki/wiki-file-structure?view=azure-devops#order-file)。

示例 `.order` 文件如下所示：

```text
getting-started
working-agreements
developer
```

文件夹和文件在文件夹中的排序受 `-s | --sequence` 标志与该目录中的 `.order` 文件以及（可选的）`--ordering` 标志的组合影响。另请参阅[排序](#排序)。

### 使用 `.ignore` 定义要忽略的目录

如果提供了 `-g | --ignore` 参数，工具将检查文件夹是否存在 `.ignore` 文件，并使用它来忽略目录。`.ignore` 文件只是一个文件和/或目录名称列表，*区分大小写*，不带文件扩展名。

示例 `.ignore` 文件如下所示：

```text
node_modules
bin
```

它仅适用于它所在的文件夹，不适用于该文件夹下的其他子文件夹。

### 使用 `.override` 定义标题覆盖

如果提供了 `-r | --override` 参数，工具将检查文件夹是否存在 `.override` 文件，并使用它来覆盖文件或目录标题，因为它们将显示在生成的 `toc.yml` 中。`.override` 文件是一个文件和/或目录名称列表，*区分大小写*，不带文件扩展名，后跟一个分号，后跟要使用的标题。

例如，如果文件夹名称是 `introduction`，默认行为将是创建名称 `Introduction`。如果您想称之为 `To start with`，您可以使用覆盖，如下例所示：

```text
introduction;To start with
working-agreements;All working agreements of all teams
```

MD 文件的标题取自文件中的 H1 标题。目录的标题是目录名称，但从特殊字符清理，首字母大写。

## 自动生成 `index.md` 文件

如果提供了 `-indexing <method>` 参数，`method` 定义生成 `index.md` 文件的条件。选项是：

* `Never` - 从不生成 `index.md`。这是默认值。
* `NoDefault` - 当文件夹中找不到 `index.md` 或 `readme.md` 时生成 `index.md`。
* `NoDefaultMulti` - 当文件夹中找不到 `index.md` 或 `readme.md` 且有 2 个或更多文件时生成 `index.md`。
* `NotExists` - 当文件夹中找不到 `index.md` 文件时生成 `index.md`。
* `NotExistsMulti` - 当文件夹中找不到 `index.md` 文件且有 2 个或更多文件时生成 `index.md`。
* `EmptyFolders` - 当文件夹不包含任何文件时生成 `index.md`。

### 生成 `index.md` 的模板

当生成 `index.md` 文件时，这是通过使用 [Liquid 模板](https://shopify.github.io/liquid/) 完成的。该工具包含一个*默认模板*：

```liquid
# {{ current.DisplayName }}

{% comment -%}循环遍历所有文件并显示显示名称。{%- endcomment -%}
{% for file in current.Files -%}
{%- if file.IsMarkdown -%}
* [{{ file.DisplayName }}]({{ file.Name }})
{% endif -%}
{%- endfor %}
```

这将生成如下所示的 markdown 文件：

```markdown
# Brasil

* [Nova Friburgo](nova-friburgo.md)
* [Rio de Janeiro](rio-de-janeiro.md)
* [Sao Paulo](sao-paulo.md)
```

您也可以提供要使用的自定义模板。确保索引过程将在需要生成 `index.md` 的文件夹中查找名为 `.index.liquid` 的文件。如果该文件夹中不存在，它将遍历所有父文件夹直到根目录，直到找到 `.index.liquid` 文件。

在模板中提供对此信息的访问：

* `current` - 这是需要 `index.md` 文件的当前文件夹，类型为 `FolderData`。
* `root` - 这是文档完整层次结构的根文件夹，类型为 `FolderData`。

#### `FolderData` 类

| 属性          | 描述                                                  |
| ------------- | ----------------------------------------------------- |
| `Name`        | 磁盘上的文件夹名称                                     |
| `DisplayName` | 文件夹的标题                                          |
| `Path`        | 文件夹的完整路径                                      |
| `Sequence`    | 来自 `.order` 文件的序列号，如果未定义则为 `int.MaxValue`。 |
| `RelativePath` | 从文档根目录的文件夹相对路径。                         |
| `Parent`      | 父文件夹。当为 `null` 时，它是根文件夹。               |
| `Folders`     | 此文件夹中子文件夹的 `FolderData` 对象列表。          |
| `Files`       | 此文件夹中文件的 `FileData` 对象列表。                 |
| `HasIndex`    | 一个 `boolean`，指示此文件夹是否包含 `index.md`       |
| `Index`       | 如果存在，此文件夹中 `index.md` 的 `FileData` 对象。如果不存在，这将为 `null`。 |
| `HasReadme`   | 一个 `boolean`，指示此文件夹是否包含 `README.md`       |
| `Readme`      | 如果存在，此文件夹中 `README.md` 的 `FileData` 对象。如果不存在，这将为 `null`。 |

#### `FileData` 类

| 属性          | 描述                                                  |
| ------------- | ----------------------------------------------------- |
| `Name`        | 包含扩展名的文件名                                     |
| `DisplayName` | 文件的标题。                                           |
| `Path`        | 文件的完整路径                                         |
| `Sequence`    | 来自 `.order` 文件的序列号，如果未定义则为 `int.MaxValue`。 |
| `RelativePath` | 从文档根目录的文件相对路径。                           |
| `Parent`      | 父文件夹。                                             |
| `IsMarkdown`  | 一个 `boolean`，指示此文件是否是 markdown 文件。      |
| `IsSwagger`   | 一个 `boolean`，指示此文件是否是 Swagger JSON 文件。   |
| `IsIndex`     | 一个 `boolean`，指示此文件是否是 `index.md` 文件。     |
| `IsReadme`    | 一个 `boolean`，指示此文件是否是 `README.md` 文件。    |

有关如何使用 Liquid 逻辑的更多信息，请参阅文章[Using Liquid for text-based templates with .NET | by Martin Tirion | Medium](https://mtirion.medium.com/using-liquid-for-text-base-templates-with-net-80ae503fa635) 和 [Liquid 参考](https://shopify.github.io/liquid/basics/introduction/)。

Liquid 在设计上非常宽容。如果您引用不存在的对象或属性，它将呈现为空字符串。但如果您引入语言错误（例如缺少 `{{`），则会抛出错误，错误在工具的输出中，但不会使工具崩溃，但将导致错误代码 1（警告）。在这种情况下，不会生成 `index.md`。

## 排序

目录和文件夹的排序有以下选项：

* `All` - 按序列，然后按标题排序所有目录和文件。
* `FoldersFirst` - 首先排序所有目录，然后是文件。每个的排序都是按序列，然后按标题完成。
* `FilesFirst` - 首先排序所有文件，然后是文件夹。每个的排序都是按序列，然后按标题完成。

对于所有这些选项，当存在 `.order` 文件并使用 `-s | --sequence` 标志时，可以使用 `.order` 文件。`.order` 文件中的行确定文件或目录的序列。因此，第一个条目导致序列 1。在所有其他情况下，文件夹或文件具有相等的序列 `int.MaxValue`。

默认情况下，文件的排序是应用的，其中 `index.md` 是第一个，`README.md` 是第二个，可选地后跟 `.order` 文件中的设置。此行为只能通过将 `index` 和/或 `readme` 添加到 `.order` 文件并使用 `-s | --sequence` 标志来覆盖。

> [!NOTE]
>
> `README` 和 `index` 始终**区分大小写**验证，以确保它们正确排序。所有其他文件名和目录名都**不区分大小写**匹配。

## 文件夹引用

目录由文件夹和文件构建。对于文件夹，有各种策略来确定它是否具有引用：

* `None` - 所有文件夹都没有引用。
* `Index` - 引用文件夹中的 `index.md`（如果存在）。
* `IndexReadme` - 如果存在，引用 `index.md`，否则引用 `README.md`（如果存在）。
* `First` - 在应用[排序](#排序)后引用文件夹中的第一个文件。

使用 DocFx 生成网站时，没有引用的文件夹将只是可以打开和关闭的层次结构中的条目。UI 将确定显示什么内容。

## 多个目录文件

此工具的默认值是在输出目录的根目录中仅生成一个 `toc.yml` 文件。但是对于大型层次结构，此文件可能会变得相当大。在这种情况下，每个级别有几个 `toc.yml` 文件可能会有多个、较小的 `toc.yml` 文件。

`-m | --multitoc` 选项将控制在层次结构中向下多深生成 `toc.yml` 文件。让我们通过一个示例层次结构来解释此功能：

```text
📂docs
  📄README.md
  📂continents
    📄index.md
  	📂americas
  	  📄README.md
  	  📄extra-facts.md
  	  📂brasil
  	    📄README.md
  	    📄nova-friburgo.md
  	    📄rio-de-janeiro.md
  	  📂united-states
        📄los-angeles.md
        📄new-york.md
        📄washington.md
    📂europe
  	  📄README.md
  	  📂germany
  	    📄berlin.md
  	    📄munich.md
      📂netherlands
        📄amsterdam.md
        📄rotterdam.md
  📂vehicles
    📄index.md
  	📂cars
  	  📄README.md
  	  📄audi.md
  	  📄bmw.md  			
```

### 默认行为或 depth=0

默认情况下，当 `depth` 为 `0`（或省略选项）时，仅在输出文件夹的根目录中生成一个 `toc.yml` 文件，包含文件夹和文件的完整层次结构。对于示例层次结构，它将如下所示：

```yaml
# This is an automatically generated file
- name: Multi toc example
  href: README.md
- name: Continents
  href: continents/index.md
  items:
  - name: Americas
    href: continents/americas/README.md
    items:
    - name: Americas Extra Facts
      href: continents/americas/extra-facts.md
    - name: Brasil
      href: continents/americas/brasil/README.md
      items:
      - name: Nova Friburgo
        href: continents/americas/brasil/nova-friburgo.md
      - name: Rio de Janeiro
        href: continents/americas/brasil/rio-de-janeiro.md
    - name: Los Angeles
      href: continents/americas/united-states/los-angeles.md
      items:
      - name: New York
        href: continents/americas/united-states/new-york.md
      - name: Washington
        href: continents/americas/united-states/washington.md
  - name: Europe
    href: continents/europe/README.md
    items:
    - name: Amsterdam
      href: continents/europe/netherlands/amsterdam.md
      items:
      - name: Rotterdam
        href: continents/europe/netherlands/rotterdam.md
    - name: Berlin
      href: continents/europe/germany/berlin.md
      items:
      - name: Munich
        href: continents/europe/germany/munich.md
- name: Vehicles
  href: vehicles/index.md
  items:
  - name: Cars
    href: vehicles/cars/README.md
    items:
    - name: Audi
      href: vehicles/cars/audi.md
    - name: BMW
      href: vehicles/cars/bmw.md

```

### depth=1 或更多的行为

当给出 `1` 的 `depth` 时，将在输出文件夹的根目录和文档根目录的每个子文件夹中生成 `toc.yml`。根目录中的 `toc.yml` 将仅包含文件夹本身的文档和对子文件夹中 `toc.yml` 文件的引用。在我们的示例中，根目录将如下所示：

```yaml
# This is an automatically generated file
- name: Multi toc example
  href: README.md
- name: Continents
  href: continents/toc.yml
- name: Vehicles
  href: vehicles/toc.yml
```

子文件夹 `continents` 和 `vehicles` 中的 `toc.yml` 文件将从该点开始包含完整的层次结构。例如，对于 `vehicles`，它将如下所示：

```yaml
# This is an automatically generated file
- name: Cars
  href: cars/README.md
  items:
  - name: Audi
    href: cars/audi.md
  - name: BMW
    href: cars/bmw.md
```

## 驼峰命名法标题

默认情况下，标题更改为帕斯卡命名法，即第一个字符大写。使用选项 `--camelCase`，所有标题将更改为驼峰命名法，即第一个字符小写。唯一的例外是来自 `.override` 文件的覆盖。

> [!NOTE]
>
> 由于此规则应用于所有内容，因此也应用于来自 Swagger 文件的标题。如果这是一个问题，可以使用该文件夹中的 `.override` 文件为该文件进行更正。