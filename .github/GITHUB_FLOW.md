# GitHub Flow & Release Process

本文档描述了如何使用 GitHub Flow 自动生成和发布 DocFX 伴侣工具的 EXE 版本。

## 🔄 GitHub Flow

### 1. 开发流程
- 在 `main` 分支上进行开发
- 所有更改都会触发自动构建和测试
- 创建 Pull Request 进行代码审查
- 合并到 `main` 分支后自动部署

### 2. 发布流程
有两种方式可以发布新版本：

#### 方式一：通过 Git 标签（推荐）
```bash
# 创建版本标签并推送到远程仓库
git tag v1.0.0
git push origin v1.0.0
```

#### 方式二：手动触发
1. 访问仓库的 Actions 页面
2. 选择 "Release EXE on Tag" 工作流
3. 点击 "Run workflow"
4. 输入标签名称（如 `v1.0.0`）
5. 点击 "Run workflow"

## 🚀 自动化功能

### 触发条件
- **自动触发**: 推送符合 `v*.*.*` 格式的标签时
- **手动触发**: 通过 GitHub Actions 界面手动运行

### 自动执行的任务
1. **构建所有工具** - 编译为 Windows 单文件可执行文件
2. **创建 ZIP 包** - 将所有 EXE 文件打包
3. **生成 Release** - 在 GitHub 上创建带描述的 Release
4. **发布 NuGet 包** - 发布到 NuGet.org
5. **生成变更日志** - 自动生成版本变更说明

## 📦 发布产物

### GitHub Release
- **tools.zip**: 包含所有 Windows 可执行文件
- **Release 描述**: 包含工具列表、安装说明和变更日志

### NuGet 包
- `DocAssembler`
- `DocFxTocGenerator` 
- `DocLanguageTranslator`
- `DocLinkChecker`
- `DocFxOpenApi`

## 🔧 版本管理

### 版本格式
使用语义化版本控制：`v主版本.次版本.修订版本`

例如：
- `v1.0.0` - 初始版本
- `v1.1.0` - 功能更新
- `v1.0.1` - 错误修复

### GitVersion 配置
项目使用 GitVersion 自动确定版本号，配置文件为 `GitVersion.yml`。

## 📋 发布检查清单

发布新版本前请确保：
- [ ] 所有测试通过
- [ ] 文档已更新
- [ ] 变更日志已更新
- [ ] 版本号符合语义化版本控制
- [ ] 构建脚本正常工作

## 🎯 使用说明

### 下载 EXE 版本
1. 访问仓库的 [Releases](https://github.com/lusipad/docfx-companion-tools/releases) 页面
2. 选择要下载的版本
3. 下载 `tools.zip` 文件
4. 解压到任意目录即可使用

### 使用工具
解压后，所有工具都可以直接在命令行使用：
```bash
# 查看帮助
DocAssembler --help
DocFxTocGenerator --help
DocLanguageTranslator --help
DocLinkChecker --help
DocFxOpenApi --help

# 实际使用示例
DocFxTocGenerator -d ./docs -o ./output
DocLinkChecker -d ./docs -v
```

## 🔒 权限要求

### GitHub Secrets
确保以下 secrets 已配置：
- `NUGET_TOOLS`: NuGet API 密钥
- `GITHUB_TOKEN`: GitHub 令牌（自动提供）

### Chocolatey 发布（可选）
如果需要发布到 Chocolatey，还需要：
- `CHOCO_TOKEN`: Chocolatey API 密钥

## 🐛 故障排除

### 常见问题
1. **标签推送后没有触发构建**
   - 检查标签格式是否符合 `v*.*.*`
   - 确认标签已推送到远程仓库

2. **构建失败**
   - 检查代码是否能正常编译
   - 查看构建日志了解具体错误

3. **Release 创建失败**
   - 检查 GitHub Token 权限
   - 确认标签名称格式正确

### 调试技巧
- 使用 GitHub Actions 的 "Re-run workflow" 功能
- 查看详细的构建日志
- 在本地运行 `.\build.ps1` 测试构建过程

## 📊 监控

### 构建状态
- [![Build & Test](https://github.com/lusipad/docfx-companion-tools/actions/workflows/build.yml/badge.svg)](https://github.com/lusipad/docfx-companion-tools/actions/workflows/build.yml)
- [![Release EXE on Tag](https://github.com/lusipad/docfx-companion-tools/actions/workflows/release-exe.yml/badge.svg)](https://github.com/lusipad/docfx-companion-tools/actions/workflows/release-exe.yml)

### 发布状态
- [GitHub Releases](https://github.com/lusipad/docfx-companion-tools/releases)
- [NuGet Packages](https://www.nuget.org/profiles/lusipad)