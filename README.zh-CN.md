# icc

> 面向 macOS 的 AI 指挥中心

`icc` 是一个面向高强度 AI 工作流的原生 macOS 指挥台。它把 Ghostty 级别的终端渲染、本地与远程资源管理器、文件查看编辑、浏览器执行面板，以及可由 LLM 驱动的监督器整合到同一个工作界面里，让用户从意图到执行几乎不丢上下文。

仓库地址：<https://github.com/miounet11/icc>

语言文档：[English](README.md) | 简体中文 | [繁體中文](README.zh-TW.md)

品牌指南：[docs/brand-guidelines.md](docs/brand-guidelines.md)

## 为什么 `icc` 看起来不一样

- 把终端执行、文件、远程主机、浏览器流程和监督器放进同一个原生 macOS 工作面。
- 保留低延迟终端体验，不把产品做成一个套壳网页工具。
- 目标不是“功能更杂”，而是让用户在几轮交流后立刻进入可执行状态。
- 相比单纯的终端，`icc` 提供更强的上下文可见性和调度能力。

## 用户第一眼会感受到什么

- 终端仍然是主角。
- 文件和远程资源始终在当前对话旁边，不再来回切窗口。
- 监督器能把零散上下文整理成明确的下一步建议。
- 本地工作与远程工作使用同一套操作心智。

## 产品定位

`icc` 面向的是已经在用多个工具处理 AI 协作、自动化执行和远程任务的用户。它不是再加一个窗口，而是试图把原本分散的控制面收束成一个更强、更快、更稳的工作台。

## 当前版本的核心能力

- 基于 `libghostty` 的 Swift/AppKit 原生 macOS 应用，启动快、渲染流畅。
- 紧凑左侧工作区导航，主区域聚焦终端对话、分屏和工作区切换。
- 右侧本地文件资源管理器，可树形浏览、拖拽路径到终端，并直接查看、编辑、保存文件。
- 右侧远程 SSH 资源管理器，会读取 `~/.ssh/config`，支持登录后浏览远端目录，并直接打开、编辑、保存远端文件。
- 内置浏览器面板，方便代理直接配合本地或远程服务完成操作。
- 监督器面板可以根据当前工作区目标、最近交流内容、访问目录、远程状态和窗口历史，快速生成开工建议。
- 支持配置 LLM 接口地址、模型和 API Key，生成开工计划、执行简报、窗口交接和循环评估。
- 面向 Claude Code、Codex、OpenCode 等工作流的通知与自动化集成。
- 支持把微信对话绑定到指定窗口或工作区。

## 安装

### Release 包

正式发布包会放在 GitHub Releases 页面：

<https://github.com/miounet11/icc/releases>

如果当前还处于发布前验证阶段，建议直接从源码构建。

### 从源码构建

环境要求：

- macOS 14+
- Xcode 15+
- Zig（`brew install zig`）

克隆并初始化：

```bash
git clone --recursive https://github.com/miounet11/icc.git
cd icc
./scripts/setup.sh
```

构建并启动带标签的调试版本：

```bash
./scripts/reload.sh --tag local-dev
```

构建并启动发布版本：

```bash
./scripts/reloadp.sh
```

## 快速开始

1. 启动 `icc`。
2. 打开本地项目目录。
3. 在远程资源管理器中读取 `~/.ssh/config` 并连接目标主机。
4. 在右侧面板查看、编辑本地或远程文件。
5. 如需监督器和自动化能力，进入“设置 → 自动化”配置 LLM。
6. 如需在终端中使用命令行，可通过应用内入口把 `icc` CLI 安装到 `PATH`。

## 为什么值得评估 `icc`

- 用一个工作区取代“终端 + SFTP + 记事本 + 远程助手”这类分裂工具链。
- 在代理或操作者执行过程中，持续保留项目上下文和状态可见性。
- 在本地仓库、远程主机、浏览器辅助流程之间切换时明显更顺。
- 给每一个工作区增加一层能总结进度、提出下一步建议的控制能力。

## CLI 说明

当前打包的可执行文件名称是 `icc`。

常用示例：

```bash
icc --help
icc notify --title "构建完成" --body "测试已通过"
icc list-notifications
icc clear-notifications
```

兼容性说明：

- 当前仓库内部仍保留部分历史 `cmux` / `CMUX_*` 命名，例如协议字段、环境变量和远程守护进程名。
- 面向用户展示和发布的产品名称、CLI 名称均为 `icc`。

## 远程工作流

`icc` 同时支持两类远程方式：

- 图形化远程资源管理器：直接读取 OpenSSH / VS Code 风格的 SSH 配置，交互式登录，并在连接后展示远端文件树。
- 受管远程工作区：通过 `icc ssh ...` 创建可重连的远程工作区，并接入应用内部的浏览器、通知和会话管理。

补充说明：

- 远程密码保存在当前 Mac 的本地钥匙串中，不会明文写入仓库。
- 受管 SSH 会话可选择“兼容优先”的 `TERM=xterm-256color`，也可保留 Ghostty 默认 TERM。

## 监督器工作流

监督器的目标，是在用户仅交流了 2-3 轮之后，就能快速判断是否可以开工：

- 提炼目标、完成标准、约束和执行范围
- 记录当前目录和访问过的目录
- 基于最近交流生成开工建议
- 给当前终端窗口生成执行简报
- 在开启 LLM 后做更深一层的状态评估与循环调度

可在“设置 → 自动化”中配置：

- LLM 接口地址
- 模型名称
- API Key
- Socket 控制模式
- Claude Code 集成

## 文档索引

- [README.md](README.md)：英文主文档
- [CONTRIBUTING.md](CONTRIBUTING.md)：开发与提交说明
- [CHANGELOG.md](CHANGELOG.md)：版本历史
- [docs/brand-guidelines.md](docs/brand-guidelines.md)：ICC 品牌命名与文案规则
- [docs/notifications.md](docs/notifications.md)：通知与 Hook 集成
- [docs/remote-daemon-spec.md](docs/remote-daemon-spec.md)：受管 SSH 架构
- [docs/agent-browser-port-spec.md](docs/agent-browser-port-spec.md)：浏览器自动化接口说明
- [docs/v2-api-migration.md](docs/v2-api-migration.md)：v2 Socket API 迁移说明
- [docs/ghostty-fork.md](docs/ghostty-fork.md)：Ghostty 分叉说明

## 开发说明

- 当前仓库名为 `icc`，本次发布的产品名也为 `icc`。
- 部分 Xcode target、脚本、辅助二进制和协议层仍保留 `cmux` 历史命名，这是兼容迁移的一部分，不建议直接全量替换。
- Homebrew 子模块目前仍是历史命名，首个公开版本建议以 GitHub Releases 和源码构建为主。

## 许可证

项目采用 `AGPL-3.0-or-later` 许可证，详见 [LICENSE](LICENSE)。
