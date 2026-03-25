import type { Locale } from "../i18n/routing";
import { siteConfig } from "./site-config";

export const marketingLocales = ["en", "zh-CN", "zh-TW", "ja"] as const;
export type MarketingLocale = (typeof marketingLocales)[number];

type SummaryCard = {
  label: string;
  title: string;
  body: string;
};

type SectionItem = {
  title: string;
  body: string;
};

type WorkflowItem = {
  step: string;
  title: string;
  body: string;
};

type FaqItem = {
  q: string;
  a: string;
};

export type MarketingCopy = {
  metaTitle: string;
  metaDescription: string;
  descriptor: string;
  tagline: string;
  eyebrow: string;
  heroDescription: string;
  buttons: {
    download: string;
    github: string;
  };
  header: {
    capabilities: string;
    workflow: string;
    faq: string;
    github: string;
    language: string;
    toggleTheme: string;
    openMenu: string;
    closeMenu: string;
  };
  heroCards: SummaryCard[];
  preview: {
    workspace: string;
    rail: string;
    railItems: string[];
    terminal: string;
    ready: string;
    lines: string[];
    supervisor: string;
    status: string;
    statusReady: string;
    statusBody: string;
    files: string;
    filesBody: string;
    remote: string;
    remoteBody: string;
  };
  capabilities: {
    eyebrow: string;
    title: string;
    body: string;
    items: SectionItem[];
  };
  why: {
    eyebrow: string;
    title: string;
    items: string[];
  };
  profile: {
    eyebrow: string;
    items: Array<{ label: string; value: string }>;
  };
  workflow: {
    eyebrow: string;
    title: string;
    body: string;
    items: WorkflowItem[];
  };
  faq: {
    eyebrow: string;
    title: string;
    body: string;
    items: FaqItem[];
  };
  cta: {
    eyebrow: string;
    title: string;
    body: string;
  };
  footer: {
    blurb: string;
    explore: string;
    release: string;
    capabilities: string;
    workflow: string;
    faq: string;
    download: string;
    releases: string;
    repository: string;
    support: string;
    copyright: string;
  };
};

const releaseValue = `${siteConfig.version} on ${siteConfig.domain}`;

const copy: Partial<Record<Locale, MarketingCopy>> = {
  en: {
    metaTitle: "icc — AI Command Center for macOS",
    metaDescription:
      "icc is a native macOS command center for serious AI work. It combines Ghostty-grade terminal rendering, local and remote file exploration, in-app editing, browser execution, source control visibility, and a supervisor layer in one focused workspace.",
    descriptor: "AI Command Center for macOS",
    tagline: "One cockpit for terminal-first AI execution.",
    eyebrow: "Official site",
    heroDescription:
      "icc is a native macOS command center for serious AI work. Keep terminal execution, local and remote files, source control, browser tasks, and supervisor-driven next steps inside one deliberate workspace.",
    buttons: {
      download: "Download for macOS",
      github: "View on GitHub",
    },
    header: {
      capabilities: "Capabilities",
      workflow: "Workflow",
      faq: "FAQ",
      github: "GitHub",
      language: "Language",
      toggleTheme: "Toggle theme",
      openMenu: "Open menu",
      closeMenu: "Close menu",
    },
    heroCards: [
      {
        label: "Platform",
        title: "Native macOS",
        body: "Swift, AppKit, Ghostty-grade rendering.",
      },
      {
        label: "Workspace",
        title: "Local + remote",
        body: "One model for projects, SSH targets, and files.",
      },
      {
        label: "Operating style",
        title: "Zero-config first",
        body: "Infer context early, expose controls only when needed.",
      },
    ],
    preview: {
      workspace: "workspace: /Users/operator/work/icc",
      rail: "Rail",
      railItems: ["terminal / build", "repo / icc", "remote / prod-ssh", "browser / review"],
      terminal: "Terminal conversation",
      ready: "ready",
      lines: [
        "$ icc connect prod-ssh",
        "Connected. Reading remote workspace and shell state.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Paths, files, remote tree, and next action remain visible together.",
      ],
      supervisor: "Supervisor",
      status: "Status",
      statusReady: "Ready to continue",
      statusBody: "Goal inferred from current repo, files, and recent task history.",
      files: "Files",
      filesBody: "Open, inspect, edit, and save without leaving the workspace.",
      remote: "Remote",
      remoteBody: "SSH-backed browsing, same layout, same path handling.",
    },
    capabilities: {
      eyebrow: "Capabilities",
      title: "Built for operators who want context visible while work is happening.",
      body:
        "icc is not another browser dashboard sitting on top of a terminal. It is a command center that keeps execution, files, remote state, and guidance within the same working surface.",
      items: [
        {
          title: "Terminal-first execution",
          body:
            "Run serious AI work in a native macOS shell surface instead of bouncing between wrappers and detached browser tabs.",
        },
        {
          title: "Local and remote explorers",
          body:
            "Browse local projects and SSH-connected hosts from the same workspace, using the same mental model and the same right-side control plane.",
        },
        {
          title: "In-app file editing",
          body:
            "Open, inspect, edit, and save files without breaking terminal flow. Drag paths directly into the active conversation when needed.",
        },
        {
          title: "Supervisor mode",
          body:
            "Turn a few lines of user intent, project context, and recent work into a concrete execution brief with bounded next steps.",
        },
        {
          title: "Browser and automation",
          body:
            "Keep browser-backed tasks beside the terminal and expose them to the same operator workflow instead of juggling separate tools.",
        },
        {
          title: "Source control visibility",
          body:
            "Keep Git state, repo context, and working directories visible while agents or operators are pushing real work forward.",
        },
      ],
    },
    why: {
      eyebrow: "Why it lands differently",
      title: "The fastest path from a few user turns to a real execution surface.",
      items: [
        "Files stay beside the active terminal instead of hiding behind a separate app.",
        "Remote hosts use the same explorer and editing workflow as local projects.",
        "Source control and project context remain visible while changes are happening.",
        "Supervisor mode frames the next move without forcing a heavyweight setup ritual.",
      ],
    },
    profile: {
      eyebrow: "Product profile",
      items: [
        {
          label: "Rendering",
          value: "Ghostty-grade terminal engine with a native macOS shell surface.",
        },
        {
          label: "Surface model",
          value: "Workspace-first layout with files, browser tasks, and remote state in-view.",
        },
        {
          label: "Automation",
          value: "Supervisor, browser control, CLI compatibility, and task-ready context compression.",
        },
        {
          label: "Release line",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Workflow",
      title: "Zero-config where it should be. Explicit control where it matters.",
      body:
        "The product philosophy is simple: infer first, ask second. You should be able to open a project, connect a host, and start moving before you get buried in setup panels.",
      items: [
        {
          step: "01",
          title: "Open a workspace",
          body:
            "Point icc at a local repo or connect an SSH target. Zero-config flow infers enough structure to begin immediately.",
        },
        {
          step: "02",
          title: "Read the working surface",
          body:
            "Terminal state, files, Git context, remote paths, and recent interaction notes stay visible in the same command deck.",
        },
        {
          step: "03",
          title: "Let the supervisor frame the next move",
          body:
            "icc can compress current context into a startup plan, execution brief, or operator handoff without turning the workflow into ceremony.",
        },
        {
          step: "04",
          title: "Execute without losing context",
          body:
            "Browse files, edit code, inspect output, and move between local and remote targets while the conversation stays anchored.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Direct answers for what people ask first.",
      body: "The product stays opinionated about workflow quality, while remaining practical to adopt.",
      items: [
        {
          q: "Is icc just a Ghostty fork?",
          a:
            "No. icc is a native macOS command center built on Ghostty-grade terminal rendering. The product expands that foundation with explorers, editing, browser execution, supervision, and workspace orchestration.",
        },
        {
          q: "Who is icc for?",
          a:
            "Operators, engineers, founders, and power users who already run multiple AI-assisted workflows and want one sharper control surface instead of more window sprawl.",
        },
        {
          q: "What makes the workflow different?",
          a:
            "icc keeps the terminal first-class while adding the missing surfaces around it: files, remote hosts, source control, browser context, and an execution-focused supervisor.",
        },
        {
          q: "Does it support remote work?",
          a:
            "Yes. icc reads SSH configuration, connects to remote targets, and exposes remote files in the same explorer model used for local work.",
        },
      ],
    },
    cta: {
      eyebrow: "Launch icc",
      title: "Move from intent to execution without losing the shape of the work.",
      body:
        "Download the current macOS build or track releases and source on GitHub. The public site, release line, and repository are now aligned to one identity: icc.",
    },
    footer: {
      blurb:
        "Native Swift and AppKit. Ghostty-grade rendering. Local and remote context, file operations, browser execution, source control, and supervision in one operator-first workspace.",
      explore: "Explore",
      release: "Release",
      capabilities: "Capabilities",
      workflow: "Workflow",
      faq: "FAQ",
      download: "Download for macOS",
      releases: "Releases",
      repository: "GitHub Repository",
      support: "Support / Issues",
      copyright: "© {year} icc. One cockpit for terminal-first AI execution.",
    },
  },
  "zh-CN": {
    metaTitle: "icc — macOS AI 指挥中心",
    metaDescription:
      "icc 是一个面向高强度 AI 工作流的原生 macOS 指挥中心。它将 Ghostty 级终端渲染、本地与远程文件浏览、内置编辑、浏览器执行、源码状态可见性以及监督器能力整合到同一工作界面中。",
    descriptor: "macOS AI 指挥中心",
    tagline: "一个座舱，承接以终端为核心的 AI 执行流。",
    eyebrow: "官方网站",
    heroDescription:
      "icc 是一个面向严肃 AI 工作的原生 macOS 指挥中心。终端执行、本地与远程文件、源码状态、浏览器任务以及监督器给出的下一步建议，都保留在同一个清晰工作区里。",
    buttons: {
      download: "下载 macOS 版本",
      github: "查看 GitHub",
    },
    header: {
      capabilities: "核心能力",
      workflow: "工作方式",
      faq: "常见问题",
      github: "GitHub",
      language: "语言",
      toggleTheme: "切换主题",
      openMenu: "打开菜单",
      closeMenu: "关闭菜单",
    },
    heroCards: [
      {
        label: "平台",
        title: "原生 macOS",
        body: "Swift、AppKit、Ghostty 级渲染。",
      },
      {
        label: "工作区",
        title: "本地 + 远程",
        body: "项目、SSH 主机与文件共用同一套模型。",
      },
      {
        label: "工作风格",
        title: "零配置优先",
        body: "优先推断上下文，只在必要时暴露控制项。",
      },
    ],
    preview: {
      workspace: "工作区: /Users/operator/work/icc",
      rail: "侧栏",
      railItems: ["终端 / 构建", "仓库 / icc", "远程 / prod-ssh", "浏览器 / review"],
      terminal: "终端对话",
      ready: "已就绪",
      lines: [
        "$ icc connect prod-ssh",
        "已连接，正在读取远端工作区和 shell 状态。",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ 打开文件资源管理器",
        "路径、文件、远程目录树和下一步动作保持同屏可见。",
      ],
      supervisor: "监督器",
      status: "状态",
      statusReady: "可以继续",
      statusBody: "目标已根据当前仓库、文件状态和最近任务记录自动推断。",
      files: "文件",
      filesBody: "无需离开工作区即可打开、查看、编辑并保存文件。",
      remote: "远程",
      remoteBody: "基于 SSH 的浏览体验，与本地项目保持同样的布局与路径模型。",
    },
    capabilities: {
      eyebrow: "核心能力",
      title: "给真正执行任务的人准备，让上下文在工作发生时始终可见。",
      body:
        "icc 不是套在终端外面的一层浏览器面板，它是一个把执行、文件、远程状态和行动建议收拢在同一工作面的指挥中心。",
      items: [
        {
          title: "终端优先执行",
          body: "在原生 macOS shell 里处理严肃 AI 工作，而不是在各种包装器和分离的浏览器标签之间来回切换。",
        },
        {
          title: "本地与远程资源管理器",
          body: "在同一工作区中浏览本地项目和 SSH 远端主机，使用相同的认知模型和相同的右侧控制平面。",
        },
        {
          title: "应用内文件编辑",
          body: "直接打开、查看、编辑并保存文件，不打断终端流程。需要时可将路径直接拖入当前对话。",
        },
        {
          title: "监督器模式",
          body: "把几句用户意图、项目上下文和最近进展压缩成可执行的简报与清晰下一步。",
        },
        {
          title: "浏览器与自动化",
          body: "让浏览器任务紧邻终端，并纳入同一套操作流程，而不是依赖分裂的外部工具。",
        },
        {
          title: "源码状态可见",
          body: "在代理或操作者推进工作时，持续看到 Git 状态、仓库上下文和工作目录变化。",
        },
      ],
    },
    why: {
      eyebrow: "为什么更顺手",
      title: "从两三轮目标沟通，到真正开始执行，中间几乎没有摩擦。",
      items: [
        "文件紧贴当前终端，不再藏在另一个应用里。",
        "远程主机与本地项目共享同一套资源管理与编辑逻辑。",
        "代码仓状态与项目上下文在修改发生时持续可见。",
        "监督器负责组织下一步，而不是强迫用户先填写一堆复杂配置。",
      ],
    },
    profile: {
      eyebrow: "产品画像",
      items: [
        {
          label: "渲染引擎",
          value: "Ghostty 级终端引擎，承载原生 macOS shell 工作面。",
        },
        {
          label: "界面模型",
          value: "以工作区为中心，让文件、浏览器任务和远程状态始终在视野内。",
        },
        {
          label: "自动化",
          value: "监督器、浏览器控制、CLI 兼容能力，以及可直接开工的上下文压缩。",
        },
        {
          label: "发布线",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "工作方式",
      title: "该零配置的地方零配置，该显式控制的地方给足控制。",
      body:
        "产品理念很直接：先推断，再追问。你应该能先打开项目、连接主机、开始推进，而不是先被设置面板埋住。",
      items: [
        {
          step: "01",
          title: "打开工作区",
          body: "让 icc 指向本地仓库，或连接一个 SSH 目标。零配置流程会先推断足够多的信息，让你立刻开始。",
        },
        {
          step: "02",
          title: "读取当前工作面",
          body: "终端状态、文件、Git 上下文、远程路径和最近交互记录会停留在同一个命令甲板里。",
        },
        {
          step: "03",
          title: "由监督器组织下一步",
          body: "icc 可以把当前上下文压缩成启动计划、执行简报或交接摘要，而不会把流程变得官僚。",
        },
        {
          step: "04",
          title: "执行时不丢上下文",
          body: "浏览文件、编辑代码、查看输出、切换本地和远程目标时，对话始终保持锚定。",
        },
      ],
    },
    faq: {
      eyebrow: "常见问题",
      title: "用户最先会问的问题，这里直接回答。",
      body: "保持清晰、强执行力和低摩擦，是这个网站信息架构的原则。",
      items: [
        {
          q: "icc 只是 Ghostty 的一个分支吗？",
          a: "不是。icc 是一个建立在 Ghostty 级渲染能力之上的原生 macOS 指挥中心，在其基础上进一步扩展了资源管理、编辑、浏览器执行、监督和工作区编排能力。",
        },
        {
          q: "icc 面向谁？",
          a: "面向操作者、工程师、创始人以及已经在同时运行多个 AI 工作流的高阶用户。他们需要的是一个更锋利的控制面，而不是更多窗口堆积。",
        },
        {
          q: "它的工作方式有什么不同？",
          a: "icc 让终端保持第一公民地位，同时把缺失的外围能力补齐：文件、远程主机、源码状态、浏览器上下文，以及面向执行的监督器。",
        },
        {
          q: "支持远程协作吗？",
          a: "支持。icc 会读取 SSH 配置、连接远程目标，并用与本地资源管理器一致的模型展示远程文件。",
        },
      ],
    },
    cta: {
      eyebrow: "开始使用 icc",
      title: "从目标到执行，不再丢失工作的整体形状。",
      body:
        "你可以直接下载当前 macOS 构建，也可以在 GitHub 上跟踪发布与源码。官网、发布线路和仓库现在已经统一到同一个品牌：icc。",
    },
    footer: {
      blurb:
        "原生 Swift 与 AppKit。Ghostty 级渲染。本地与远程上下文、文件操作、浏览器执行、源码状态和监督能力，全部收敛在同一个偏执行者的工作区里。",
      explore: "探索",
      release: "发布",
      capabilities: "核心能力",
      workflow: "工作方式",
      faq: "常见问题",
      download: "下载 macOS 版本",
      releases: "版本发布",
      repository: "GitHub 仓库",
      support: "支持 / 问题反馈",
      copyright: "© {year} icc。一个座舱，承接以终端为核心的 AI 执行流。",
    },
  },
  "zh-TW": {
    metaTitle: "icc — macOS AI 指揮中心",
    metaDescription:
      "icc 是面向高強度 AI 工作流的原生 macOS 指揮中心。它整合 Ghostty 級終端渲染、本地與遠端檔案瀏覽、內建編輯、瀏覽器執行、原始碼狀態可視化，以及監督器能力於同一工作介面。",
    descriptor: "macOS AI 指揮中心",
    tagline: "一個座艙，承接以終端為核心的 AI 執行流。",
    eyebrow: "官方網站",
    heroDescription:
      "icc 是面向嚴肅 AI 工作的原生 macOS 指揮中心。終端執行、本地與遠端檔案、原始碼狀態、瀏覽器任務以及監督器給出的下一步建議，都留在同一個清晰工作區裡。",
    buttons: {
      download: "下載 macOS 版本",
      github: "查看 GitHub",
    },
    header: {
      capabilities: "核心能力",
      workflow: "工作方式",
      faq: "常見問題",
      github: "GitHub",
      language: "語言",
      toggleTheme: "切換主題",
      openMenu: "開啟選單",
      closeMenu: "關閉選單",
    },
    heroCards: [
      {
        label: "平台",
        title: "原生 macOS",
        body: "Swift、AppKit、Ghostty 級渲染。",
      },
      {
        label: "工作區",
        title: "本地 + 遠端",
        body: "專案、SSH 主機與檔案共用同一套模型。",
      },
      {
        label: "工作風格",
        title: "零配置優先",
        body: "優先推斷上下文，只在必要時顯示控制項。",
      },
    ],
    preview: {
      workspace: "工作區: /Users/operator/work/icc",
      rail: "側欄",
      railItems: ["終端 / 建置", "倉庫 / icc", "遠端 / prod-ssh", "瀏覽器 / review"],
      terminal: "終端對話",
      ready: "已就緒",
      lines: [
        "$ icc connect prod-ssh",
        "已連線，正在讀取遠端工作區與 shell 狀態。",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ 開啟檔案總管",
        "路徑、檔案、遠端樹與下一步動作可維持同屏可見。",
      ],
      supervisor: "監督器",
      status: "狀態",
      statusReady: "可以繼續",
      statusBody: "目標已根據目前倉庫、檔案狀態與最近任務記錄自動推斷。",
      files: "檔案",
      filesBody: "不離開工作區即可開啟、檢視、編輯並儲存檔案。",
      remote: "遠端",
      remoteBody: "基於 SSH 的瀏覽體驗，與本地專案保持相同的版面與路徑模型。",
    },
    capabilities: {
      eyebrow: "核心能力",
      title: "為真正執行任務的人準備，讓上下文在工作發生時始終可見。",
      body:
        "icc 不是套在終端外的一層瀏覽器面板，它是把執行、檔案、遠端狀態與行動建議收斂在同一工作面的指揮中心。",
      items: [
        {
          title: "終端優先執行",
          body: "在原生 macOS shell 中處理嚴肅 AI 工作，而不是在各種包裝器與分離的瀏覽器分頁之間反覆切換。",
        },
        {
          title: "本地與遠端資源管理器",
          body: "在同一工作區瀏覽本地專案與 SSH 遠端主機，使用相同的認知模型與相同的右側控制平面。",
        },
        {
          title: "應用內檔案編輯",
          body: "直接開啟、檢視、編輯並儲存檔案，不打斷終端流程。需要時可將路徑直接拖入當前對話。",
        },
        {
          title: "監督器模式",
          body: "把幾句使用者意圖、專案上下文與最近進展壓縮成可執行的簡報與清晰下一步。",
        },
        {
          title: "瀏覽器與自動化",
          body: "讓瀏覽器任務緊鄰終端，並納入同一套操作流程，而不是依賴分裂的外部工具。",
        },
        {
          title: "原始碼狀態可見",
          body: "在代理或操作者推進工作時，持續看到 Git 狀態、倉庫上下文與工作目錄變化。",
        },
      ],
    },
    why: {
      eyebrow: "為什麼更順手",
      title: "從兩三輪目標溝通，到真正開始執行，中間幾乎沒有摩擦。",
      items: [
        "檔案緊貼目前終端，不再藏在另一個應用程式裡。",
        "遠端主機與本地專案共用同一套資源管理與編輯邏輯。",
        "原始碼狀態與專案上下文在修改發生時持續可見。",
        "監督器負責整理下一步，而不是逼使用者先填一堆繁瑣設定。",
      ],
    },
    profile: {
      eyebrow: "產品輪廓",
      items: [
        {
          label: "渲染引擎",
          value: "Ghostty 級終端引擎，承載原生 macOS shell 工作面。",
        },
        {
          label: "介面模型",
          value: "以工作區為中心，讓檔案、瀏覽器任務與遠端狀態始終在視野內。",
        },
        {
          label: "自動化",
          value: "監督器、瀏覽器控制、CLI 相容能力，以及可直接開工的上下文壓縮。",
        },
        {
          label: "發布線",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "工作方式",
      title: "該零配置的地方零配置，該明確控制的地方給足控制。",
      body:
        "產品理念很直接：先推斷，再追問。你應該能先開啟專案、連線主機、開始推進，而不是先被設定面板淹沒。",
      items: [
        {
          step: "01",
          title: "開啟工作區",
          body: "讓 icc 指向本地倉庫，或連線一個 SSH 目標。零配置流程會先推斷足夠多的資訊，讓你立即開始。",
        },
        {
          step: "02",
          title: "讀取目前工作面",
          body: "終端狀態、檔案、Git 上下文、遠端路徑與最近互動記錄會停留在同一命令甲板裡。",
        },
        {
          step: "03",
          title: "由監督器組織下一步",
          body: "icc 可以把目前上下文壓縮成啟動計畫、執行簡報或交接摘要，而不會讓流程變得官僚。",
        },
        {
          step: "04",
          title: "執行時不丟上下文",
          body: "瀏覽檔案、編輯程式碼、檢視輸出、切換本地與遠端目標時，對話始終保持錨定。",
        },
      ],
    },
    faq: {
      eyebrow: "常見問題",
      title: "使用者最先會問的問題，這裡直接回答。",
      body: "保持清晰、強執行力和低摩擦，是這個網站資訊架構的原則。",
      items: [
        {
          q: "icc 只是 Ghostty 的一個分支嗎？",
          a: "不是。icc 是建立在 Ghostty 級渲染能力之上的原生 macOS 指揮中心，在此基礎上進一步擴展了資源管理、編輯、瀏覽器執行、監督與工作區編排能力。",
        },
        {
          q: "icc 面向誰？",
          a: "面向操作者、工程師、創辦人以及已經同時執行多個 AI 工作流的高階使用者。他們需要的是一個更銳利的控制面，而不是更多視窗堆疊。",
        },
        {
          q: "它的工作方式有什麼不同？",
          a: "icc 讓終端保持第一公民地位，同時把缺失的周邊能力補齊：檔案、遠端主機、原始碼狀態、瀏覽器上下文，以及面向執行的監督器。",
        },
        {
          q: "支援遠端協作嗎？",
          a: "支援。icc 會讀取 SSH 設定、連線遠端目標，並以與本地資源管理器一致的模型展示遠端檔案。",
        },
      ],
    },
    cta: {
      eyebrow: "開始使用 icc",
      title: "從目標到執行，不再丟失工作的整體形狀。",
      body:
        "你可以直接下載目前 macOS 建置，也可以在 GitHub 上追蹤發布與原始碼。官網、發布線與倉庫現在已經統一到同一個品牌：icc。",
    },
    footer: {
      blurb:
        "原生 Swift 與 AppKit。Ghostty 級渲染。本地與遠端上下文、檔案操作、瀏覽器執行、原始碼狀態與監督能力，全部收斂在同一個偏執行者的工作區裡。",
      explore: "探索",
      release: "發布",
      capabilities: "核心能力",
      workflow: "工作方式",
      faq: "常見問題",
      download: "下載 macOS 版本",
      releases: "版本發布",
      repository: "GitHub 倉庫",
      support: "支援 / 問題回報",
      copyright: "© {year} icc。一個座艙，承接以終端為核心的 AI 執行流。",
    },
  },
  ja: {
    metaTitle: "icc — macOS向けAIコマンドセンター",
    metaDescription:
      "icc は本格的な AI ワークフローのためのネイティブ macOS コマンドセンターです。Ghostty級の端末描画、ローカル/リモートのファイル探索、アプリ内編集、ブラウザ実行、ソース管理の可視化、そしてスーパーバイザー機能を1つの作業面に統合します。",
    descriptor: "macOS向けAIコマンドセンター",
    tagline: "端末中心のAI実行を、一つのコックピットに。",
    eyebrow: "公式サイト",
    heroDescription:
      "icc は本気の AI 作業のためのネイティブ macOS コマンドセンターです。端末実行、ローカル/リモートのファイル、ソース管理、ブラウザ作業、スーパーバイザーが示す次の一手を、ひとつの明快なワークスペースに保持します。",
    buttons: {
      download: "macOS版をダウンロード",
      github: "GitHubを見る",
    },
    header: {
      capabilities: "機能",
      workflow: "ワークフロー",
      faq: "FAQ",
      github: "GitHub",
      language: "言語",
      toggleTheme: "テーマを切り替える",
      openMenu: "メニューを開く",
      closeMenu: "メニューを閉じる",
    },
    heroCards: [
      {
        label: "プラットフォーム",
        title: "ネイティブ macOS",
        body: "Swift、AppKit、Ghostty級レンダリング。",
      },
      {
        label: "ワークスペース",
        title: "ローカル + リモート",
        body: "プロジェクト、SSH先、ファイルを同じモデルで扱えます。",
      },
      {
        label: "操作思想",
        title: "ゼロ設定優先",
        body: "まず文脈を推定し、必要なときだけ操作を見せます。",
      },
    ],
    preview: {
      workspace: "workspace: /Users/operator/work/icc",
      rail: "レール",
      railItems: ["terminal / build", "repo / icc", "remote / prod-ssh", "browser / review"],
      terminal: "端末会話",
      ready: "ready",
      lines: [
        "$ icc connect prod-ssh",
        "接続完了。リモートワークスペースと shell 状態を読み込み中。",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ ファイルエクスプローラーを開く",
        "パス、ファイル、リモートツリー、次のアクションが同じ画面に残ります。",
      ],
      supervisor: "スーパーバイザー",
      status: "ステータス",
      statusReady: "続行可能",
      statusBody: "現在のリポジトリ、ファイル状態、直近の作業履歴からゴールを推定しました。",
      files: "ファイル",
      filesBody: "ワークスペースを離れずに、開く・確認する・編集する・保存するを行えます。",
      remote: "リモート",
      remoteBody: "SSH ベースのブラウズを、ローカルと同じレイアウトとパスモデルで扱えます。",
    },
    capabilities: {
      eyebrow: "機能",
      title: "作業中の文脈を見失いたくないオペレーターのために設計。",
      body:
        "icc は端末の上に載った単なるブラウザダッシュボードではありません。実行、ファイル、リモート状態、次の判断材料を同じ作業面に保つコマンドセンターです。",
      items: [
        {
          title: "端末優先の実行",
          body: "ラッパーや切り離されたブラウザタブを渡り歩くのではなく、ネイティブ macOS shell 上で本格的な AI 作業を進めます。",
        },
        {
          title: "ローカル/リモートのエクスプローラー",
          body: "ローカルのプロジェクトも SSH 接続先も、同じメンタルモデルと右側コントロール面で扱えます。",
        },
        {
          title: "アプリ内ファイル編集",
          body: "端末の流れを壊さずに、ファイルを開いて確認し、編集し、保存できます。必要ならパスを会話へ直接ドラッグできます。",
        },
        {
          title: "スーパーバイザーモード",
          body: "数行のユーザー意図、プロジェクト文脈、直近の進捗から、実行可能なブリーフと明確な次の一手を作ります。",
        },
        {
          title: "ブラウザと自動化",
          body: "ブラウザ作業を端末の隣に置き、別ツールに分断せず同じ運用フローで扱えます。",
        },
        {
          title: "ソース管理の可視化",
          body: "エージェントやオペレーターが作業を進める間も、Git 状態、リポジトリ文脈、作業ディレクトリを見失いません。",
        },
      ],
    },
    why: {
      eyebrow: "刺さる理由",
      title: "2〜3回のやり取りから、すぐに本番の実行面へ入れる。",
      items: [
        "ファイルは別アプリに隠れず、現在の端末の隣にあります。",
        "リモートホストもローカルプロジェクトも、同じ探索・編集フローで扱えます。",
        "変更が進む間も、ソース管理とプロジェクト文脈が見え続けます。",
        "スーパーバイザーが次の一手を整理し、重たい初期設定儀式を強いません。",
      ],
    },
    profile: {
      eyebrow: "プロダクト概要",
      items: [
        {
          label: "レンダリング",
          value: "Ghostty級の端末エンジンを、ネイティブ macOS shell 面で活用。",
        },
        {
          label: "サーフェスモデル",
          value: "ワークスペース中心のレイアウトで、ファイル、ブラウザ作業、リモート状態を見える位置に保持。",
        },
        {
          label: "自動化",
          value: "スーパーバイザー、ブラウザ制御、CLI 互換、すぐ動ける文脈圧縮を内蔵。",
        },
        {
          label: "リリースライン",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "ワークフロー",
      title: "ゼロ設定でよい場所はゼロ設定。制御が必要な場所は明示的に。",
      body:
        "設計思想はシンプルです。まず推定し、次に尋ねる。プロジェクトを開き、ホストへ接続し、設定画面に埋もれる前に動き始められるべきです。",
      items: [
        {
          step: "01",
          title: "ワークスペースを開く",
          body: "icc にローカルリポジトリを向けるか、SSH 先へ接続します。ゼロ設定フローが十分な構造を推定し、すぐ開始できます。",
        },
        {
          step: "02",
          title: "作業面を読む",
          body: "端末状態、ファイル、Git 文脈、リモートパス、最近のやり取りが同じコマンドデッキに残ります。",
        },
        {
          step: "03",
          title: "スーパーバイザーに次の一手をまとめさせる",
          body: "icc は現在の文脈を、開始プラン、実行ブリーフ、引き継ぎメモへ圧縮できます。しかも儀式的にはなりません。",
        },
        {
          step: "04",
          title: "文脈を失わずに実行する",
          body: "ファイルを見て、コードを編集し、出力を確認し、ローカル/リモートを行き来しても、会話はずっとアンカーされたままです。",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "最初に聞かれることへ、率直に答えます。",
      body: "導入しやすさを保ちながら、作業品質には厳しくある。それがこのサイトの前提です。",
      items: [
        {
          q: "icc は Ghostty の fork ですか？",
          a: "いいえ。icc は Ghostty級の端末描画を土台にしたネイティブ macOS コマンドセンターです。その上にエクスプローラー、編集、ブラウザ実行、監督、ワークスペースオーケストレーションを加えています。",
        },
        {
          q: "icc は誰のための製品ですか？",
          a: "オペレーター、エンジニア、創業者、そして複数の AI ワークフローをすでに回しているパワーユーザー向けです。必要なのは、より鋭い制御面であって、増え続けるウィンドウではありません。",
        },
        {
          q: "何が違うのですか？",
          a: "icc は端末を主役のまま保ちつつ、不足していた周辺面を埋めます。ファイル、リモートホスト、ソース管理、ブラウザ文脈、そして実行志向のスーパーバイザーです。",
        },
        {
          q: "リモート作業に対応していますか？",
          a: "はい。icc は SSH 設定を読み取り、リモート先へ接続し、ローカルと同じエクスプローラーモデルでリモートファイルを扱えます。",
        },
      ],
    },
    cta: {
      eyebrow: "icc を始める",
      title: "意図から実行へ。仕事の全体像を失わない。",
      body:
        "現在の macOS ビルドをすぐダウンロードするか、GitHub でリリースとソースを追跡できます。公開サイト、リリースライン、リポジトリはすべて icc という1つのブランドに揃いました。",
    },
    footer: {
      blurb:
        "ネイティブ Swift と AppKit。Ghostty級レンダリング。ローカル/リモート文脈、ファイル操作、ブラウザ実行、ソース管理、監督を、実行者中心のワークスペースに統合。",
      explore: "探索",
      release: "リリース",
      capabilities: "機能",
      workflow: "ワークフロー",
      faq: "FAQ",
      download: "macOS版をダウンロード",
      releases: "リリース一覧",
      repository: "GitHub リポジトリ",
      support: "サポート / Issues",
      copyright: "© {year} icc。端末中心のAI実行を、一つのコックピットに。",
    },
  },
};

export function getMarketingCopy(locale?: string): MarketingCopy {
  return copy[locale as Locale] ?? copy.en!;
}

export function getLocalizedHomePath(locale?: string): string {
  if (!locale || locale === "en") {
    return "/";
  }

  return `/${locale}`;
}
