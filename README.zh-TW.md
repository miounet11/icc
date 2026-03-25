# icc

> 面向 macOS 的 AI 指揮中心

`icc` 是面向高強度 AI 工作流的原生 macOS 指揮台。它把 Ghostty 等級的終端渲染、本機與遠端資源管理器、檔案檢視與編輯、瀏覽器執行面板，以及可由 LLM 驅動的監督器整合到同一個工作介面中，讓使用者從意圖到執行幾乎不失去上下文。

儲存庫位址：<https://github.com/miounet11/icc>

語言文件：[English](README.md) | [简体中文](README.zh-CN.md) | 繁體中文

品牌指南：[docs/brand-guidelines.md](docs/brand-guidelines.md)

## 為什麼 `icc` 看起來不一樣

- 把終端執行、檔案、遠端主機、瀏覽器流程與監督器放進同一個原生 macOS 工作面。
- 保留低延遲終端體驗，而不是把產品做成另一個網頁殼工具。
- 目標不是「功能更多」，而是讓使用者在幾輪交流後立刻進入可執行狀態。
- 相比單純的終端，`icc` 提供更強的上下文可見性與調度能力。

## 使用者第一眼會感受到什麼

- 終端仍然是主角。
- 檔案與遠端資源一直都在目前對話旁邊，不必來回切換視窗。
- 監督器能把零散上下文整理成明確的下一步建議。
- 本機工作與遠端工作共用同一套操作心智。

## 產品定位

`icc` 面向的是已經在使用多個工具處理 AI 協作、自動化執行與遠端任務的使用者。它不是再增加一個視窗，而是試圖把原本分散的控制面收斂成一個更強、更快、更穩的工作台。

## 目前版本的核心能力

- 基於 `libghostty` 的 Swift/AppKit 原生 macOS 應用程式，啟動快、渲染流暢。
- 緊湊左側工作區導覽，主區域聚焦終端對話、分割畫面與工作區切換。
- 右側本機檔案資源管理器，可樹狀瀏覽、將路徑拖曳到終端，並直接檢視、編輯、儲存檔案。
- 右側遠端 SSH 資源管理器，會讀取 `~/.ssh/config`，支援登入後瀏覽遠端目錄，並直接開啟、編輯、儲存遠端檔案。
- 內建瀏覽器面板，方便代理直接搭配本機或遠端服務完成操作。
- 監督器面板可根據目前工作區目標、最近交流內容、已訪問目錄、遠端狀態與視窗歷史，快速產生開工建議。
- 支援設定 LLM 介面位址、模型與 API Key，產生開工計畫、執行簡報、視窗交接與循環評估。
- 面向 Claude Code、Codex、OpenCode 等工作流的通知與自動化整合。
- 支援將微信對話綁定到指定視窗或工作區。

## 安裝

### Release 套件

正式發布包會放在 GitHub Releases 頁面：

<https://github.com/miounet11/icc/releases>

如果目前仍在發布前驗證階段，建議直接從原始碼建構。

### 從原始碼建構

環境需求：

- macOS 14+
- Xcode 15+
- Zig（`brew install zig`）

複製並初始化：

```bash
git clone --recursive https://github.com/miounet11/icc.git
cd icc
./scripts/setup.sh
```

建構並啟動帶標籤的除錯版本：

```bash
./scripts/reload.sh --tag local-dev
```

建構並啟動發布版本：

```bash
./scripts/reloadp.sh
```

## 快速開始

1. 啟動 `icc`。
2. 開啟本機專案目錄。
3. 在遠端資源管理器中讀取 `~/.ssh/config` 並連線目標主機。
4. 在右側面板檢視、編輯本機或遠端檔案。
5. 如需監督器與自動化能力，進入「設定 → 自動化」設定 LLM。
6. 如需在終端中使用命令列，可透過應用程式內入口把 `icc` CLI 安裝到 `PATH`。

## 為什麼值得評估 `icc`

- 用一個工作區取代「終端 + SFTP + 筆記 + 遠端助手」這類分裂工具鏈。
- 在代理或操作者執行過程中，持續保留專案上下文與狀態可見性。
- 在本機倉庫、遠端主機、瀏覽器輔助流程之間切換時明顯更順。
- 為每一個工作區增加一層能總結進度、提出下一步建議的控制能力。

## CLI 說明

目前打包的可執行檔名稱是 `icc`。

常用範例：

```bash
icc --help
icc notify --title "建構完成" --body "測試已通過"
icc list-notifications
icc clear-notifications
```

相容性說明：

- 目前儲存庫內仍保留部分歷史 `cmux` / `CMUX_*` 命名，例如協定欄位、環境變數與遠端守護程式名稱。
- 對外發布與使用者介面中的產品名稱、CLI 名稱都以 `icc` 為準。

## 遠端工作流

`icc` 同時支援兩類遠端方式：

- 圖形化遠端資源管理器：直接讀取 OpenSSH / VS Code 風格的 SSH 設定，互動式登入，並在連線後顯示遠端檔案樹。
- 受管遠端工作區：透過 `icc ssh ...` 建立可重連的遠端工作區，並接入應用程式內的瀏覽器、通知與工作階段管理。

補充說明：

- 遠端密碼會儲存在目前 Mac 的本機鑰匙圈中，不會以明文寫入儲存庫。
- 受管 SSH 工作階段可選擇「相容優先」的 `TERM=xterm-256color`，也可保留 Ghostty 預設 TERM。

## 監督器工作流

監督器的目標，是在使用者只交流了 2-3 輪後，就能快速判斷是否可以開工：

- 提煉目標、完成標準、約束與執行範圍
- 記錄目前目錄與已訪問目錄
- 根據最近交流產生開工建議
- 對目前終端視窗產生執行簡報
- 在啟用 LLM 後進行更深入的狀態評估與循環調度

可在「設定 → 自動化」中設定：

- LLM 介面位址
- 模型名稱
- API Key
- Socket 控制模式
- Claude Code 整合

## 文件索引

- [README.md](README.md)：英文主文件
- [CONTRIBUTING.md](CONTRIBUTING.md)：開發與提交說明
- [CHANGELOG.md](CHANGELOG.md)：版本歷史
- [docs/brand-guidelines.md](docs/brand-guidelines.md)：ICC 品牌命名與文案規則
- [docs/notifications.md](docs/notifications.md)：通知與 Hook 整合
- [docs/remote-daemon-spec.md](docs/remote-daemon-spec.md)：受管 SSH 架構
- [docs/agent-browser-port-spec.md](docs/agent-browser-port-spec.md)：瀏覽器自動化介面說明
- [docs/v2-api-migration.md](docs/v2-api-migration.md)：v2 Socket API 遷移說明
- [docs/ghostty-fork.md](docs/ghostty-fork.md)：Ghostty 分叉說明

## 開發說明

- 目前儲存庫名稱為 `icc`，本次發布的產品名稱也為 `icc`。
- 部分 Xcode target、腳本、輔助二進位與協定層仍保留 `cmux` 歷史命名，這是相容性遷移的一部分，不建議直接全部替換。
- Homebrew 子模組目前仍是歷史命名，首個公開版本建議以 GitHub Releases 與原始碼建構為主。

## 授權

專案採用 `AGPL-3.0-or-later` 授權，詳見 [LICENSE](LICENSE)。
