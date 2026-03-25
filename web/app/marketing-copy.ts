import type { Locale } from "../i18n/routing";
import { siteConfig } from "./site-config";

export const marketingLocales = ["en", "ja", "zh-CN", "zh-TW", "ko", "de", "es", "fr", "it", "da", "pl", "ru", "bs", "ar", "no", "pt-BR", "th", "tr", "km"] as const;
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
  "ko": {
    metaTitle: "icc — AI macOS 명령 센터",
    metaDescription:
      "icc은 심각한 AI 작업을 위한 기본 macOS 명령 센터입니다. Ghostty급 터미널 렌더링, 로컬 및 원격 파일 탐색, 인앱 편집, 브라우저 실행, 소스 제어 가시성 및 감독자 레이어를 하나의 집중된 작업 공간에 결합합니다.",
    descriptor: "AI macOS 명령 센터",
    tagline: "터미널 우선 AI 실행을 위한 조종석 1개.",
    eyebrow: "공식 사이트",
    heroDescription:
      "icc은 심각한 AI 작업을 위한 기본 macOS 명령 센터입니다. 터미널 실행, 로컬 및 원격 파일, 소스 제어, 브라우저 작업, 감독자 중심의 다음 단계를 하나의 계획된 작업 공간 내에 유지하세요.",
    buttons: {
      download: "macOS용 다운로드",
      github: "GitHub에서 보기",
    },
    header: {
      capabilities: "기능",
      workflow: "작업 흐름",
      faq: "FAQ",
      github: "GitHub",
      language: "언어",
      toggleTheme: "테마 전환",
      openMenu: "메뉴 열기",
      closeMenu: "메뉴 닫기",
    },
    heroCards: [
      {
        label: "플랫폼",
        title: "네이티브 macOS",
        body: "Swift, AppKit, Ghostty급 렌더링.",
      },
      {
        label: "작업공간",
        title: "로컬 + 원격",
        body: "프로젝트, SSH 대상 및 파일을 위한 단일 모델입니다.",
      },
      {
        label: "운영 스타일",
        title: "제로 구성 우선",
        body: "컨텍스트를 조기에 추론하고 필요한 경우에만 컨트롤을 노출합니다.",
      },
    ],
    preview: {
      workspace: "작업 공간: /Users/operator/work/icc",
      rail: "철도",
      railItems: ["터미널/빌드", "저장소 / icc", "원격 / prod-ssh", "브라우저 / 리뷰"],
      terminal: "터미널 대화",
      ready: "준비",
      lines: [
        "$ icc connect prod-ssh",
        "연결되었습니다. 원격 작업공간 및 셸 상태를 읽습니다.",
        "$ git status --short",
        "남 Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "경로, 파일, 원격 트리 및 다음 작업이 함께 표시됩니다.",
      ],
      supervisor: "감독자",
      status: "상태",
      statusReady: "계속할 준비가 되었습니다",
      statusBody: "현재 저장소, 파일 및 최근 작업 기록에서 추론된 목표입니다.",
      files: "파일",
      filesBody: "작업 공간을 떠나지 않고도 열고, 검사하고, 편집하고, 저장할 수 있습니다.",
      remote: "원격",
      remoteBody: "SSH 지원 브라우징, 동일한 레이아웃, 동일한 경로 처리.",
    },
    capabilities: {
      eyebrow: "기능",
      title: "작업이 진행되는 동안 상황을 확인하려는 운영자를 위해 제작되었습니다.",
      body:
        "icc은(는) 터미널 위에 있는 또 다른 브라우저 대시보드가 아닙니다. 동일한 작업 영역 내에서 실행, 파일, 원격 상태 및 지침을 유지하는 명령 센터입니다.",
      items: [
        {
          title: "터미널 우선 실행",
          body:
            "래퍼와 분리된 브라우저 탭 사이를 오가는 대신 기본 macOS 셸 표면에서 심각한 AI 작업을 실행하세요.",
        },
        {
          title: "로컬 및 원격 탐색기",
          body:
            "동일한 멘탈 모델과 동일한 오른쪽 제어 플레인을 사용하여 동일한 작업 공간에서 로컬 프로젝트와 SSH에 연결된 호스트를 찾아보세요.",
        },
        {
          title: "인앱 파일 편집",
          body:
            "터미널 흐름을 중단하지 않고 파일을 열고, 검사하고, 편집하고, 저장할 수 있습니다. 필요한 경우 경로를 활성 대화로 직접 드래그하세요.",
        },
        {
          title: "감독자 모드",
          body:
            "몇 줄의 사용자 의도, 프로젝트 컨텍스트, 최근 작업을 제한된 다음 단계가 포함된 구체적인 실행 개요로 전환하세요.",
        },
        {
          title: "브라우저 및 자동화",
          body:
            "별도의 도구를 사용하는 대신 브라우저 지원 작업을 터미널 옆에 두고 동일한 운영자 작업 흐름에 노출하세요.",
        },
        {
          title: "소스 제어 가시성",
          body:
            "에이전트나 운영자가 실제 작업을 진행하는 동안 Git 상태, 저장소 컨텍스트 및 작업 디렉터리를 계속 표시하세요.",
        },
      ],
    },
    why: {
      eyebrow: "왜 다르게 착륙합니까?",
      title: "소수의 사용자가 실행하는 가장 빠른 경로가 실제 실행 표면으로 전환됩니다.",
      items: [
        "파일은 별도의 앱 뒤에 숨기지 않고 활성 터미널 옆에 유지됩니다.",
        "원격 호스트는 로컬 프로젝트와 동일한 탐색기 및 편집 작업 흐름을 사용합니다.",
        "변경이 진행되는 동안 소스 제어 및 프로젝트 컨텍스트는 계속 표시됩니다.",
        "감독자 모드는 헤비급 설정 의식을 강요하지 않고 다음 동작을 구성합니다.",
      ],
    },
    profile: {
      eyebrow: "제품 프로필",
      items: [
        {
          label: "렌더링",
          value: "기본 macOS 쉘 표면을 갖춘 Ghostty급 터미널 엔진.",
        },
        {
          label: "표면 모델",
          value: "파일, 브라우저 작업 및 원격 상태가 표시되는 작업 공간 중심 레이아웃입니다.",
        },
        {
          label: "자동화",
          value: "감독자, 브라우저 제어, CLI 호환성 및 작업 준비 컨텍스트 압축.",
        },
        {
          label: "릴리스 라인",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "작업 흐름",
      title: "있어야 할 곳에는 구성이 없습니다. 중요한 곳에서는 명시적인 제어가 가능합니다.",
      body:
        "제품 철학은 간단합니다. 먼저 추론하고 두 번째로 질문합니다. 설정 패널에 들어가기 전에 프로젝트를 열고 호스트를 연결하고 이동을 시작할 수 있어야 합니다.",
      items: [
        {
          step: "01",
          title: "작업공간 열기",
          body:
            "로컬 저장소에서 icc을 가리키거나 SSH 대상을 연결하세요. 제로 구성 흐름은 즉시 시작하기에 충분한 구조를 추론합니다.",
        },
        {
          step: "02",
          title: "작업 표면 읽기",
          body:
            "터미널 상태, 파일, Git 컨텍스트, 원격 경로 및 최근 상호 작용 메모는 동일한 명령 데크에 계속 표시됩니다.",
        },
        {
          step: "03",
          title: "감독관이 다음 조치를 취하도록 하세요.",
          body:
            "icc은 워크플로를 의식으로 바꾸지 않고도 현재 컨텍스트를 시작 계획, 실행 개요 또는 운영자 전달로 압축할 수 있습니다.",
        },
        {
          step: "04",
          title: "컨텍스트를 잃지 않고 실행",
          body:
            "대화가 고정된 상태에서 파일 탐색, 코드 편집, 출력 검사, 로컬 및 원격 대상 간 이동이 가능합니다.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "사람들이 먼저 묻는 것에 대한 직접적인 답변.",
      body: "이 제품은 워크플로우 품질에 대한 독선을 유지하는 동시에 채택하기에 실용적인 상태를 유지합니다.",
      items: [
        {
          q: "icc은(는) 단지 Ghostty 포크인가요?",
          a:
            "아니요. icc은 Ghostty급 터미널 렌더링을 기반으로 구축된 기본 macOS 명령 센터입니다. 이 제품은 탐색기, 편집, 브라우저 실행, 감독 및 작업 공간 조정을 통해 해당 기반을 확장합니다.",
        },
        {
          q: "icc은(는) 누구를 위한 것인가요?",
          a:
            "이미 여러 개의 AI 지원 워크플로를 실행하고 있으며 창을 더 많이 펼치는 대신 하나의 더 선명한 제어 표면을 원하는 운영자, 엔지니어, 창립자 및 고급 사용자.",
        },
        {
          q: "워크플로우가 다른 이유는 무엇입니까?",
          a:
            "icc은 파일, 원격 호스트, 소스 제어, 브라우저 컨텍스트 및 실행 중심 감독자와 같은 누락된 표면을 추가하면서 터미널을 최고 수준으로 유지합니다.",
        },
        {
          q: "원격 근무를 지원하나요?",
          a:
            "그렇습니다. icc은 SSH 구성을 읽고, 원격 대상에 연결하고, 로컬 작업에 사용되는 동일한 탐색기 모델에 원격 파일을 노출합니다.",
        },
      ],
    },
    cta: {
      eyebrow: "icc 실행",
      title: "작업의 형태를 잃지 않고 의도에서 실행으로 이동합니다.",
      body:
        "GitHub에서 현재 macOS 빌드를 다운로드하거나 릴리스 및 소스를 추적하세요. 이제 공개 사이트, 릴리스 라인 및 저장소가 하나의 ID(icc)로 정렬되었습니다.",
    },
    footer: {
      blurb:
        "네이티브 Swift 및 AppKit. Ghostty급 렌더링. 하나의 운영자 중심 작업 공간에서 로컬 및 원격 컨텍스트, 파일 작업, 브라우저 실행, 소스 제어 및 감독이 가능합니다.",
      explore: "탐색",
      release: "출시",
      capabilities: "기능",
      workflow: "작업 흐름",
      faq: "FAQ",
      download: "macOS용 다운로드",
      releases: "릴리스",
      repository: "GitHub 저장소",
      support: "지원/문제",
      copyright: "© {year} icc. 터미널 우선 AI 실행을 위한 조종석 1개.",
    },
  },
  "de": {
    metaTitle: "icc – AI Kommandozentrale für macOS",
    metaDescription:
      "icc ist eine native macOS-Kommandozentrale für ernsthafte AI-Arbeiten. Es kombiniert Terminal-Rendering auf Ghostty-Niveau, lokale und Remote-Dateiexploration, In-App-Bearbeitung, Browserausführung, Sichtbarkeit der Quellcodeverwaltung und eine Supervisor-Ebene in einem fokussierten Arbeitsbereich.",
    descriptor: "AI Kommandozentrale für macOS",
    tagline: "Ein Cockpit für die Terminal-First-Ausführung von AI.",
    eyebrow: "Offizielle Seite",
    heroDescription:
      "icc ist eine native macOS-Kommandozentrale für ernsthafte AI-Arbeiten. Behalten Sie die Terminalausführung, lokale und Remote-Dateien, Quellcodeverwaltung, Browseraufgaben und vom Supervisor gesteuerte nächste Schritte in einem übersichtlichen Arbeitsbereich bei.",
    buttons: {
      download: "Herunterladen für macOS",
      github: "Auf GitHub ansehen",
    },
    header: {
      capabilities: "Fähigkeiten",
      workflow: "Arbeitsablauf",
      faq: "FAQ",
      github: "GitHub",
      language: "Sprache",
      toggleTheme: "Thema umschalten",
      openMenu: "Menü öffnen",
      closeMenu: "Menü schließen",
    },
    heroCards: [
      {
        label: "Plattform",
        title: "Native macOS",
        body: "Swift, AppKit, Ghostty-Grade-Rendering.",
      },
      {
        label: "Arbeitsbereich",
        title: "Lokal + Remote",
        body: "Ein Modell für Projekte, SSH-Ziele und Dateien.",
      },
      {
        label: "Betriebsstil",
        title: "Zuerst Nullkonfiguration",
        body: "Erfassen Sie den Kontext frühzeitig und legen Sie Steuerelemente nur bei Bedarf offen.",
      },
    ],
    preview: {
      workspace: "Arbeitsbereich: /Users/operator/work/icc",
      rail: "Schiene",
      railItems: ["Terminal / Build", "Repo / icc", "Fernbedienung / prod-ssh", "Browser / Rezension"],
      terminal: "Endgespräch",
      ready: "fertig",
      lines: [
        "$ icc connect prod-ssh",
        "Verbunden. Lesen des Remote-Arbeitsbereichs und des Shell-Status.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Pfade, Dateien, Remote-Baum und nächste Aktion bleiben gemeinsam sichtbar.",
      ],
      supervisor: "Vorgesetzter",
      status: "Status",
      statusReady: "Bereit, weiterzumachen",
      statusBody: "Das Ziel wird aus dem aktuellen Repo, den Dateien und dem aktuellen Aufgabenverlauf abgeleitet.",
      files: "Dateien",
      filesBody: "Öffnen, prüfen, bearbeiten und speichern Sie, ohne den Arbeitsbereich zu verlassen.",
      remote: "Fernbedienung",
      remoteBody: "SSH-gestütztes Browsen, gleiches Layout, gleiche Pfadbehandlung.",
    },
    capabilities: {
      eyebrow: "Fähigkeiten",
      title: "Entwickelt für Bediener, die den Kontext während der Arbeit sichtbar haben möchten.",
      body:
        "icc ist kein weiteres Browser-Dashboard, das auf einem Terminal sitzt. Es handelt sich um eine Kommandozentrale, die Ausführung, Dateien, Remote-Status und Anleitung auf derselben Arbeitsoberfläche hält.",
      items: [
        {
          title: "Terminal-First-Ausführung",
          body:
            "Führen Sie ernsthafte AI-Arbeiten in einer nativen macOS-Shell-Oberfläche aus, anstatt zwischen Wrappern und getrennten Browser-Registerkarten zu wechseln.",
        },
        {
          title: "Lokale und entfernte Entdecker",
          body:
            "Durchsuchen Sie lokale Projekte und mit SSH verbundene Hosts vom selben Arbeitsbereich aus, unter Verwendung desselben mentalen Modells und derselben Steuerungsebene auf der rechten Seite.",
        },
        {
          title: "Bearbeitung von Dateien in der App",
          body:
            "Öffnen, prüfen, bearbeiten und speichern Sie Dateien, ohne den Terminalfluss zu unterbrechen. Ziehen Sie Pfade bei Bedarf direkt in die aktive Konversation.",
        },
        {
          title: "Supervisor-Modus",
          body:
            "Verwandeln Sie einige Zeilen der Benutzerabsicht, des Projektkontexts und der aktuellen Arbeit in eine konkrete Ausführungsbeschreibung mit begrenzten nächsten Schritten.",
        },
        {
          title: "Browser und Automatisierung",
          body:
            "Behalten Sie browsergestützte Aufgaben neben dem Terminal und überlassen Sie sie demselben Bediener-Workflow, anstatt mit separaten Tools zu jonglieren.",
        },
        {
          title: "Sichtbarkeit der Quellcodeverwaltung",
          body:
            "Halten Sie den Git-Status, den Repo-Kontext und die Arbeitsverzeichnisse sichtbar, während Agenten oder Operatoren die eigentliche Arbeit vorantreiben.",
        },
      ],
    },
    why: {
      eyebrow: "Warum es anders landet",
      title: "Der schnellste Weg von wenigen Benutzerrunden zu einer echten Ausführungsoberfläche.",
      items: [
        "Dateien bleiben neben dem aktiven Terminal, anstatt sich hinter einer separaten App zu verstecken.",
        "Remote-Hosts verwenden denselben Explorer- und Bearbeitungsworkflow wie lokale Projekte.",
        "Quellcodeverwaltung und Projektkontext bleiben sichtbar, während Änderungen vorgenommen werden.",
        "Der Supervisor-Modus gibt den Rahmen für den nächsten Zug vor, ohne ein schwergewichtiges Setup-Ritual zu erzwingen.",
      ],
    },
    profile: {
      eyebrow: "Produktprofil",
      items: [
        {
          label: "Rendern",
          value: "Terminal-Engine der Ghostty-Klasse mit einer nativen macOS-Shell-Oberfläche.",
        },
        {
          label: "Oberflächenmodell",
          value: "Arbeitsbereichsorientiertes Layout mit Dateien, Browser-Aufgaben und Remote-Status im Blick.",
        },
        {
          label: "Automatisierung",
          value: "Supervisor, Browsersteuerung, CLI-Kompatibilität und aufgabenbereite Kontextkomprimierung.",
        },
        {
          label: "Release-Linie",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Arbeitsablauf",
      title: "Zero-config, wo es sein sollte. Explizite Kontrolle dort, wo es darauf ankommt.",
      body:
        "Die Produktphilosophie ist einfach: Zuerst schließen, dann fragen. Sie sollten in der Lage sein, ein Projekt zu öffnen, einen Host anzuschließen und mit der Bewegung zu beginnen, bevor Sie in Setup-Panels versinken.",
      items: [
        {
          step: "01",
          title: "Öffnen Sie einen Arbeitsbereich",
          body:
            "Richten Sie icc auf ein lokales Repo oder verbinden Sie ein SSH-Ziel. Der konfigurationsfreie Ablauf sorgt für genügend Struktur, um sofort beginnen zu können.",
        },
        {
          step: "02",
          title: "Lesen Sie die Arbeitsfläche",
          body:
            "Terminalstatus, Dateien, Git-Kontext, Remote-Pfade und aktuelle Interaktionsnotizen bleiben im selben Befehlsdeck sichtbar.",
        },
        {
          step: "03",
          title: "Lassen Sie den Vorgesetzten den nächsten Schritt festlegen",
          body:
            "icc kann den aktuellen Kontext in einen Startplan, eine Ausführungsanweisung oder eine Bedienerübergabe komprimieren, ohne den Arbeitsablauf in eine Zeremonie zu verwandeln.",
        },
        {
          step: "04",
          title: "Ausführen, ohne den Kontext zu verlieren",
          body:
            "Durchsuchen Sie Dateien, bearbeiten Sie Code, überprüfen Sie die Ausgabe und wechseln Sie zwischen lokalen und Remote-Zielen, während die Konversation verankert bleibt.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Direkte Antworten auf die Fragen, die die Leute zuerst stellen.",
      body: "Das Produkt bleibt hinsichtlich der Arbeitsablaufqualität überzeugt und bleibt gleichzeitig praktisch in der Anwendung.",
      items: [
        {
          q: "Ist icc nur eine Ghostty-Gabel?",
          a:
            "Nein. icc ist eine native macOS-Kommandozentrale, die auf Terminal-Rendering der Ghostty-Klasse basiert. Das Produkt erweitert diese Grundlage um Explorer, Bearbeitung, Browserausführung, Überwachung und Arbeitsbereichsorchestrierung.",
        },
        {
          q: "Für wen ist icc?",
          a:
            "Bediener, Ingenieure, Gründer und Power-User, die bereits mehrere AI-unterstützte Arbeitsabläufe ausführen und sich eine schärfere Bedienoberfläche statt mehr Fensterwucher wünschen.",
        },
        {
          q: "Was macht den Workflow anders?",
          a:
            "icc hält das Terminal erstklassig und fügt gleichzeitig die fehlenden Oberflächen um es herum hinzu: Dateien, Remote-Hosts, Quellcodeverwaltung, Browserkontext und einen ausführungsorientierten Supervisor.",
        },
        {
          q: "Unterstützt es Remote-Arbeit?",
          a:
            "Ja. icc liest die SSH-Konfiguration, stellt eine Verbindung zu Remote-Zielen her und stellt Remote-Dateien im selben Explorer-Modell bereit, das für die lokale Arbeit verwendet wird.",
        },
      ],
    },
    cta: {
      eyebrow: "Starten Sie icc",
      title: "Gehen Sie von der Absicht zur Ausführung über, ohne die Form der Arbeit zu verlieren.",
      body:
        "Laden Sie den aktuellen macOS-Build herunter oder verfolgen Sie Releases und Quellen auf GitHub. Die öffentliche Site, die Release-Linie und das Repository sind jetzt auf eine Identität ausgerichtet: icc.",
    },
    footer: {
      blurb:
        "Native Swift und AppKit. Ghostty-Rendering. Lokaler und Remote-Kontext, Dateivorgänge, Browserausführung, Quellcodeverwaltung und Überwachung in einem bedienerorientierten Arbeitsbereich.",
      explore: "Entdecken",
      release: "Veröffentlichung",
      capabilities: "Fähigkeiten",
      workflow: "Arbeitsablauf",
      faq: "FAQ",
      download: "Herunterladen für macOS",
      releases: "Veröffentlichungen",
      repository: "GitHub-Repository",
      support: "Support / Probleme",
      copyright: "© {year} icc. Ein Cockpit für die Terminal-First-Ausführung von AI.",
    },
  },
  "es": {
    metaTitle: "icc — AI Centro de comando para macOS",
    metaDescription:
      "icc es un centro de comando nativo macOS para trabajos serios AI. Combina renderizado de terminal de grado Ghostty, exploración de archivos local y remota, edición en la aplicación, ejecución del navegador, visibilidad del control de fuente y una capa de supervisión en un espacio de trabajo enfocado.",
    descriptor: "AI Centro de comando para macOS",
    tagline: "Una cabina para la ejecución AI desde la terminal.",
    eyebrow: "Sitio oficial",
    heroDescription:
      "icc es un centro de comando nativo macOS para trabajos serios AI. Mantenga la ejecución del terminal, los archivos locales y remotos, el control de fuentes, las tareas del navegador y los siguientes pasos impulsados ​​por el supervisor dentro de un espacio de trabajo deliberado.",
    buttons: {
      download: "Descargar para macOS",
      github: "Ver en GitHub",
    },
    header: {
      capabilities: "Capacidades",
      workflow: "Flujo de trabajo",
      faq: "FAQ",
      github: "GitHub",
      language: "Idioma",
      toggleTheme: "Alternar tema",
      openMenu: "abrir menú",
      closeMenu: "Cerrar menú",
    },
    heroCards: [
      {
        label: "Plataforma",
        title: "Nativo macOS",
        body: "Representación de grado Swift, AppKit, Ghostty.",
      },
      {
        label: "Espacio de trabajo",
        title: "Local + remoto",
        body: "Un modelo para proyectos, objetivos SSH y archivos.",
      },
      {
        label: "Estilo de operación",
        title: "Configuración cero primero",
        body: "Deduzca el contexto con antelación y exponga los controles sólo cuando sea necesario.",
      },
    ],
    preview: {
      workspace: "espacio de trabajo: /Usuarios/operador/trabajo/icc",
      rail: "carril",
      railItems: ["terminal / construcción", "repositorio / icc", "remoto / prod-ssh", "navegador / revisión"],
      terminal: "conversación terminal",
      ready: "listo",
      lines: [
        "$ icc connect prod-ssh",
        "Conectado. Lectura del espacio de trabajo remoto y del estado del shell.",
        "$ git status --short",
        "MSources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Las rutas, los archivos, el árbol remoto y la siguiente acción permanecen visibles juntos.",
      ],
      supervisor: "Supervisora",
      status: "Estado",
      statusReady: "Listo para continuar",
      statusBody: "Objetivo inferido del repositorio actual, los archivos y el historial de tareas recientes.",
      files: "Archivos",
      filesBody: "Abra, inspeccione, edite y guarde sin salir del espacio de trabajo.",
      remote: "Remoto",
      remoteBody: "Navegación respaldada por SSH, mismo diseño, mismo manejo de ruta.",
    },
    capabilities: {
      eyebrow: "Capacidades",
      title: "Diseñado para operadores que desean que el contexto sea visible mientras se realiza el trabajo.",
      body:
        "icc no es otro panel de control del navegador ubicado encima de una terminal. Es un centro de comando que mantiene la ejecución, los archivos, el estado remoto y la guía dentro de la misma superficie de trabajo.",
      items: [
        {
          title: "Ejecución desde la terminal primero",
          body:
            "Ejecute un trabajo AI serio en una superficie de shell nativa macOS en lugar de rebotar entre contenedores y pestañas separadas del navegador.",
        },
        {
          title: "Exploradores locales y remotos",
          body:
            "Explore proyectos locales y hosts conectados a SSH desde el mismo espacio de trabajo, utilizando el mismo modelo mental y el mismo plano de control del lado derecho.",
        },
        {
          title: "Edición de archivos en la aplicación",
          body:
            "Abra, inspeccione, edite y guarde archivos sin interrumpir el flujo del terminal. Arrastre rutas directamente a la conversación activa cuando sea necesario.",
        },
        {
          title: "Modo supervisor",
          body:
            "Convierta algunas líneas de intención del usuario, contexto del proyecto y trabajo reciente en un resumen de ejecución concreto con próximos pasos delimitados.",
        },
        {
          title: "Navegador y automatización",
          body:
            "Mantenga las tareas respaldadas por el navegador al lado del terminal y expóngalas al mismo flujo de trabajo del operador en lugar de hacer malabarismos con herramientas separadas.",
        },
        {
          title: "Visibilidad del control de fuente",
          body:
            "Mantenga visibles el estado de Git, el contexto del repositorio y los directorios de trabajo mientras los agentes u operadores impulsan el trabajo real.",
        },
      ],
    },
    why: {
      eyebrow: "Por qué aterriza de manera diferente",
      title: "El camino más rápido desde unos pocos usuarios hasta una superficie de ejecución real.",
      items: [
        "Los archivos permanecen al lado del terminal activo en lugar de esconderse detrás de una aplicación separada.",
        "Los hosts remotos utilizan el mismo explorador y flujo de trabajo de edición que los proyectos locales.",
        "El control de código fuente y el contexto del proyecto permanecen visibles mientras se producen cambios.",
        "El modo Supervisor enmarca el siguiente movimiento sin forzar un ritual de preparación pesado.",
      ],
    },
    profile: {
      eyebrow: "Perfil del producto",
      items: [
        {
          label: "Representación",
          value: "Motor terminal de grado Ghostty con una superficie de carcasa nativa macOS.",
        },
        {
          label: "modelo de superficie",
          value: "Diseño que prioriza el espacio de trabajo con archivos, tareas del navegador y estado remoto a la vista.",
        },
        {
          label: "Automatización",
          value: "Supervisor, control del navegador, compatibilidad con CLI y compresión de contexto lista para tareas.",
        },
        {
          label: "línea de liberación",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Flujo de trabajo",
      title: "Configuración cero donde debería estar. Control explícito donde importa.",
      body:
        "La filosofía del producto es simple: inferir primero, preguntar después. Debería poder abrir un proyecto, conectar un host y comenzar a moverse antes de quedar enterrado en los paneles de configuración.",
      items: [
        {
          step: "01",
          title: "Abrir un espacio de trabajo",
          body:
            "Apunte icc a un repositorio local o conecte un destino SSH. El flujo de configuración cero infiere suficiente estructura para comenzar de inmediato.",
        },
        {
          step: "02",
          title: "Leer la superficie de trabajo",
          body:
            "El estado de la terminal, los archivos, el contexto de Git, las rutas remotas y las notas de interacción recientes permanecen visibles en la misma plataforma de comandos.",
        },
        {
          step: "03",
          title: "Deje que el supervisor formule el siguiente paso",
          body:
            "icc puede comprimir el contexto actual en un plan de inicio, un informe de ejecución o un traspaso de operador sin convertir el flujo de trabajo en una ceremonia.",
        },
        {
          step: "04",
          title: "Ejecutar sin perder contexto",
          body:
            "Explore archivos, edite código, inspeccione resultados y muévase entre objetivos locales y remotos mientras la conversación permanece anclada.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Respuestas directas a lo que la gente pregunta primero.",
      body: "El producto sigue siendo obstinado sobre la calidad del flujo de trabajo, sin dejar de ser práctico de adoptar.",
      items: [
        {
          q: "¿Es icc solo una bifurcación Ghostty?",
          a:
            "No. icc es un centro de comando nativo macOS construido en renderizado de terminal de grado Ghostty. El producto amplía esa base con exploradores, edición, ejecución del navegador, supervisión y orquestación del espacio de trabajo.",
        },
        {
          q: "¿Para quién es icc?",
          a:
            "Operadores, ingenieros, fundadores y usuarios avanzados que ya ejecutan múltiples flujos de trabajo asistidos por AI y desean una superficie de control más nítida en lugar de una mayor extensión de ventanas.",
        },
        {
          q: "¿Qué hace que el flujo de trabajo sea diferente?",
          a:
            "icc mantiene la terminal de primera clase al tiempo que agrega las superficies que faltan a su alrededor: archivos, hosts remotos, control de fuente, contexto del navegador y un supervisor centrado en la ejecución.",
        },
        {
          q: "¿Admite trabajo remoto?",
          a:
            "Sí. icc lee la configuración de SSH, se conecta a objetivos remotos y expone archivos remotos en el mismo modelo de explorador utilizado para el trabajo local.",
        },
      ],
    },
    cta: {
      eyebrow: "Lanzar icc",
      title: "Pasar de la intención a la ejecución sin perder la forma de la obra.",
      body:
        "Descargue la compilación actual de macOS o realice un seguimiento de las versiones y el código fuente en GitHub. El sitio público, la línea de lanzamiento y el repositorio ahora están alineados con una identidad: icc.",
    },
    footer: {
      blurb:
        "Nativo Swift y AppKit. Representación de grado Ghostty. Contexto local y remoto, operaciones de archivos, ejecución del navegador, control de fuente y supervisión en un espacio de trabajo centrado en el operador.",
      explore: "Explorar",
      release: "Lanzamiento",
      capabilities: "Capacidades",
      workflow: "Flujo de trabajo",
      faq: "FAQ",
      download: "Descargar para macOS",
      releases: "Lanzamientos",
      repository: "Repositorio GitHub",
      support: "Soporte / Problemas",
      copyright: "© {year} icc. Una cabina para la ejecución AI desde la terminal.",
    },
  },
  "fr": {
    metaTitle: "icc — Centre de commande AI pour macOS",
    metaDescription:
      "icc est un centre de commandement natif de macOS pour les travaux sérieux de AI. Il combine le rendu du terminal de niveau Ghostty, l'exploration de fichiers locaux et distants, l'édition dans l'application, l'exécution du navigateur, la visibilité du contrôle source et une couche de superviseur dans un seul espace de travail ciblé.",
    descriptor: "Centre de commande AI pour macOS",
    tagline: "Un cockpit pour l'exécution du AI en premier terminal.",
    eyebrow: "Site officiel",
    heroDescription:
      "icc est un centre de commandement natif de macOS pour les travaux sérieux de AI. Conservez l’exécution du terminal, les fichiers locaux et distants, le contrôle des sources, les tâches du navigateur et les prochaines étapes pilotées par le superviseur dans un seul espace de travail délibéré.",
    buttons: {
      download: "Télécharger pour macOS",
      github: "Voir sur GitHub",
    },
    header: {
      capabilities: "Capacités",
      workflow: "Flux de travail",
      faq: "FAQ",
      github: "GitHub",
      language: "Langue",
      toggleTheme: "Changer de thème",
      openMenu: "Ouvrir le menu",
      closeMenu: "Fermer le menu",
    },
    heroCards: [
      {
        label: "Plateforme",
        title: "Natif macOS",
        body: "Rendu de qualité Swift, AppKit, Ghostty.",
      },
      {
        label: "Espace de travail",
        title: "Local + distant",
        body: "Un modèle pour les projets, les cibles SSH et les fichiers.",
      },
      {
        label: "Style de fonctionnement",
        title: "Zéro configuration d'abord",
        body: "Déduisez le contexte dès le début, exposez les contrôles uniquement lorsque cela est nécessaire.",
      },
    ],
    preview: {
      workspace: "espace de travail : /Utilisateurs/opérateur/travail/icc",
      rail: "Rail",
      railItems: ["terminal / construction", "dépôt / icc", "à distance / prod-ssh", "navigateur / avis"],
      terminal: "Conversation terminale",
      ready: "prêt",
      lines: [
        "$ icc connect prod-ssh",
        "Connecté. Lecture de l'espace de travail distant et de l'état du shell.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Les chemins, les fichiers, l'arborescence distante et l'action suivante restent visibles ensemble.",
      ],
      supervisor: "Superviseur",
      status: "Statut",
      statusReady: "Prêt à continuer",
      statusBody: "Objectif déduit du dépôt actuel, des fichiers et de l'historique des tâches récentes.",
      files: "Fichiers",
      filesBody: "Ouvrez, inspectez, modifiez et enregistrez sans quitter l'espace de travail.",
      remote: "À distance",
      remoteBody: "Navigation sauvegardée par SSH, même mise en page, même gestion du chemin.",
    },
    capabilities: {
      eyebrow: "Capacités",
      title: "Conçu pour les opérateurs qui souhaitent que le contexte soit visible pendant le travail.",
      body:
        "icc n'est pas un autre tableau de bord de navigateur posé au-dessus d'un terminal. Il s'agit d'un centre de commande qui conserve l'exécution, les fichiers, l'état distant et le guidage au sein de la même surface de travail.",
      items: [
        {
          title: "Exécution en premier terminal",
          body:
            "Exécutez un travail AI sérieux dans une surface de shell macOS native au lieu de rebondir entre les wrappers et les onglets de navigateur détachés.",
        },
        {
          title: "Explorateurs locaux et distants",
          body:
            "Parcourez les projets locaux et les hôtes connectés à SSH à partir du même espace de travail, en utilisant le même modèle mental et le même plan de contrôle de droite.",
        },
        {
          title: "Modification de fichiers dans l'application",
          body:
            "Ouvrez, inspectez, modifiez et enregistrez des fichiers sans interrompre le flux du terminal. Faites glisser les chemins directement dans la conversation active si nécessaire.",
        },
        {
          title: "Mode superviseur",
          body:
            "Transformez quelques lignes d'intention de l'utilisateur, le contexte du projet et les travaux récents en un brief d'exécution concret avec les prochaines étapes délimitées.",
        },
        {
          title: "Navigateur et automatisation",
          body:
            "Conservez les tâches sauvegardées par navigateur à côté du terminal et exposez-les au même flux de travail de l'opérateur au lieu de jongler avec des outils distincts.",
        },
        {
          title: "Visibilité du contrôle de source",
          body:
            "Gardez l'état de Git, le contexte du dépôt et les répertoires de travail visibles pendant que les agents ou les opérateurs font avancer le vrai travail.",
        },
      ],
    },
    why: {
      eyebrow: "Pourquoi il atterrit différemment",
      title: "Le chemin le plus rapide entre quelques utilisateurs et une véritable surface d’exécution.",
      items: [
        "Les fichiers restent à côté du terminal actif au lieu de se cacher derrière une application distincte.",
        "Les hôtes distants utilisent le même workflow d'exploration et d'édition que les projets locaux.",
        "Le contrôle de code source et le contexte du projet restent visibles pendant que des modifications se produisent.",
        "Le mode superviseur encadre le prochain mouvement sans forcer un rituel de configuration lourd.",
      ],
    },
    profile: {
      eyebrow: "Profil de produit",
      items: [
        {
          label: "Rendu",
          value: "Moteur de terminal de qualité Ghostty avec une surface de coque native macOS.",
        },
        {
          label: "Modèle surfacique",
          value: "Disposition axée sur l'espace de travail avec affichage des fichiers, des tâches du navigateur et de l'état distant.",
        },
        {
          label: "Automatisation",
          value: "Superviseur, contrôle du navigateur, compatibilité CLI et compression de contexte prête pour les tâches.",
        },
        {
          label: "Ligne de sortie",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Flux de travail",
      title: "Zéro configuration là où il devrait être. Contrôle explicite là où cela compte.",
      body:
        "La philosophie du produit est simple : déduire d’abord, demander ensuite. Vous devriez pouvoir ouvrir un projet, connecter un hôte et commencer à vous déplacer avant de vous plonger dans les panneaux de configuration.",
      items: [
        {
          step: "01",
          title: "Ouvrir un espace de travail",
          body:
            "Pointez icc vers un dépôt local ou connectez une cible SSH. Le flux sans configuration déduit suffisamment de structure pour commencer immédiatement.",
        },
        {
          step: "02",
          title: "Lire la surface de travail",
          body:
            "L'état du terminal, les fichiers, le contexte Git, les chemins distants et les notes d'interaction récentes restent visibles dans le même jeu de commandes.",
        },
        {
          step: "03",
          title: "Laissez le superviseur définir la prochaine étape",
          body:
            "icc peut compresser le contexte actuel dans un plan de démarrage, un brief d'exécution ou un transfert entre opérateur sans transformer le flux de travail en cérémonie.",
        },
        {
          step: "04",
          title: "Exécuter sans perdre le contexte",
          body:
            "Parcourez les fichiers, modifiez le code, inspectez les résultats et déplacez-vous entre les cibles locales et distantes pendant que la conversation reste ancrée.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Des réponses directes à ce que les gens demandent en premier.",
      body: "Le produit reste convaincu de la qualité du flux de travail, tout en restant pratique à adopter.",
      items: [
        {
          q: "Est-ce que icc n'est qu'un fork Ghostty ?",
          a:
            "Non. icc est un centre de commande natif macOS construit sur un rendu de terminal de qualité Ghostty. Le produit étend cette base avec des explorateurs, l'édition, l'exécution du navigateur, la supervision et l'orchestration de l'espace de travail.",
        },
        {
          q: "À qui s’adresse icc ?",
          a:
            "Opérateurs, ingénieurs, fondateurs et utilisateurs expérimentés qui exécutent déjà plusieurs flux de travail assistés par AI et souhaitent une surface de contrôle plus précise au lieu d'une plus grande étendue de fenêtres.",
        },
        {
          q: "Qu’est-ce qui différencie le flux de travail ?",
          a:
            "icc maintient le terminal de première classe tout en ajoutant les surfaces manquantes autour de lui : fichiers, hôtes distants, contrôle de code source, contexte de navigateur et superviseur axé sur l'exécution.",
        },
        {
          q: "Est-il compatible avec le travail à distance ?",
          a:
            "Oui. icc lit la configuration SSH, se connecte aux cibles distantes et expose les fichiers distants dans le même modèle d'explorateur utilisé pour le travail local.",
        },
      ],
    },
    cta: {
      eyebrow: "Lancer icc",
      title: "Passez de l’intention à l’exécution sans perdre la forme de l’œuvre.",
      body:
        "Téléchargez la version actuelle de macOS ou suivez les versions et les sources sur GitHub. Le site public, la ligne de publication et le référentiel sont désormais alignés sur une seule identité : icc.",
    },
    footer: {
      blurb:
        "Natifs Swift et AppKit. Rendu de qualité Ghostty. Contexte local et distant, opérations sur les fichiers, exécution du navigateur, contrôle des sources et supervision dans un seul espace de travail axé sur l'opérateur.",
      explore: "Explorer",
      release: "Libération",
      capabilities: "Capacités",
      workflow: "Flux de travail",
      faq: "FAQ",
      download: "Télécharger pour macOS",
      releases: "Sorties",
      repository: "Dépôt GitHub",
      support: "Assistance / Problèmes",
      copyright: "© {year} icc. Un cockpit pour l'exécution du AI en premier terminal.",
    },
  },
  "it": {
    metaTitle: "icc — AI Centro di comando per macOS",
    metaDescription:
      "icc è un centro di comando nativo macOS per lavori seri AI. Combina rendering del terminale di livello Ghostty, esplorazione di file locali e remoti, modifica in-app, esecuzione del browser, visibilità del controllo del codice sorgente e un livello supervisore in un unico spazio di lavoro mirato.",
    descriptor: "AI Centro di comando per macOS",
    tagline: "Un abitacolo per l'esecuzione AI terminal-first.",
    eyebrow: "Sito ufficiale",
    heroDescription:
      "icc è un centro di comando nativo macOS per lavori seri AI. Mantieni l'esecuzione del terminale, i file locali e remoti, il controllo del codice sorgente, le attività del browser e i passaggi successivi gestiti dal supervisore all'interno di un unico spazio di lavoro deliberato.",
    buttons: {
      download: "Scarica per macOS",
      github: "Visualizza su GitHub",
    },
    header: {
      capabilities: "Capacità",
      workflow: "Flusso di lavoro",
      faq: "FAQ",
      github: "GitHub",
      language: "Lingua",
      toggleTheme: "Cambia tema",
      openMenu: "Apri il menu",
      closeMenu: "Chiudi menù",
    },
    heroCards: [
      {
        label: "Piattaforma",
        title: "Nativo macOS",
        body: "Rendering di qualità Swift, AppKit, Ghostty.",
      },
      {
        label: "Spazio di lavoro",
        title: "Locale + remoto",
        body: "Un modello per progetti, target SSH e file.",
      },
      {
        label: "Stile operativo",
        title: "Prima la configurazione zero",
        body: "Deduci il contesto in anticipo, esponi i controlli solo quando necessario.",
      },
    ],
    preview: {
      workspace: "area di lavoro: /Utenti/operatore/lavoro/icc",
      rail: "Ferrovia",
      railItems: ["terminale/costruisci", "repository / icc", "telecomando / prod-ssh", "browser/recensione"],
      terminal: "Conversazione terminale",
      ready: "pronto",
      lines: [
        "$ icc connect prod-ssh",
        "Connesso. Lettura dell'area di lavoro remota e dello stato della shell.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Percorsi, file, albero remoto e azione successiva rimangono visibili insieme.",
      ],
      supervisor: "Supervisore",
      status: "Stato",
      statusReady: "Pronto per continuare",
      statusBody: "Obiettivo dedotto dal repository corrente, dai file e dalla cronologia delle attività recenti.",
      files: "File",
      filesBody: "Apri, esamina, modifica e salva senza lasciare l'area di lavoro.",
      remote: "Remoto",
      remoteBody: "Navigazione supportata da SSH, stesso layout, stessa gestione del percorso.",
    },
    capabilities: {
      eyebrow: "Capacità",
      title: "Costruito per gli operatori che desiderano che il contesto sia visibile mentre si svolge il lavoro.",
      body:
        "icc non è un altro dashboard del browser posizionato su un terminale. È un centro di comando che mantiene l'esecuzione, i file, lo stato remoto e la guida all'interno della stessa superficie di lavoro.",
      items: [
        {
          title: "Esecuzione prima dal terminale",
          body:
            "Esegui un lavoro serio AI in una superficie nativa della shell macOS invece di rimbalzare tra wrapper e schede del browser staccate.",
        },
        {
          title: "Esploratori locali e remoti",
          body:
            "Esplora progetti locali e host connessi a SSH dallo stesso spazio di lavoro, utilizzando lo stesso modello mentale e lo stesso piano di controllo sul lato destro.",
        },
        {
          title: "Modifica dei file in-app",
          body:
            "Apri, esamina, modifica e salva file senza interrompere il flusso del terminale. Trascina i percorsi direttamente nella conversazione attiva quando necessario.",
        },
        {
          title: "Modalità supervisore",
          body:
            "Trasforma alcune righe relative alle intenzioni dell'utente, al contesto del progetto e al lavoro recente in un brief di esecuzione concreto con passaggi successivi delimitati.",
        },
        {
          title: "Browser e automazione",
          body:
            "Mantieni le attività supportate dal browser accanto al terminale ed esponile allo stesso flusso di lavoro dell'operatore invece di destreggiarti tra strumenti separati.",
        },
        {
          title: "Visibilità del controllo del codice sorgente",
          body:
            "Mantieni visibili lo stato Git, il contesto del repository e le directory di lavoro mentre gli agenti o gli operatori portano avanti il lavoro reale.",
        },
      ],
    },
    why: {
      eyebrow: "Perché atterra in modo diverso",
      title: "Il percorso più veloce da pochi utenti si trasforma in una vera e propria superficie di esecuzione.",
      items: [
        "I file rimangono accanto al terminale attivo invece di nascondersi dietro un'app separata.",
        "Gli host remoti utilizzano lo stesso flusso di lavoro di esplorazione e modifica dei progetti locali.",
        "Il controllo del codice sorgente e il contesto del progetto rimangono visibili mentre si verificano le modifiche.",
        "La modalità Supervisore inquadra la mossa successiva senza forzare un pesante rituale di configurazione.",
      ],
    },
    profile: {
      eyebrow: "Profilo del prodotto",
      items: [
        {
          label: "Rendering",
          value: "Motore terminale di livello Ghostty con una superficie shell nativa macOS.",
        },
        {
          label: "Modello di superficie",
          value: "Layout incentrato sull'area di lavoro con file, attività del browser e stato remoto in vista.",
        },
        {
          label: "Automazione",
          value: "Supervisore, controllo del browser, compatibilità CLI e compressione del contesto pronta per le attività.",
        },
        {
          label: "Linea di rilascio",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Flusso di lavoro",
      title: "Zero-config dove dovrebbe essere. Controllo esplicito dove conta.",
      body:
        "La filosofia del prodotto è semplice: prima dedurre, poi chiedere. Dovresti essere in grado di aprire un progetto, connettere un host e iniziare a muoverti prima di rimanere sepolto nei pannelli di configurazione.",
      items: [
        {
          step: "01",
          title: "Apri uno spazio di lavoro",
          body:
            "Punta icc a un repository locale o collega un target SSH. Il flusso a configurazione zero deduce una struttura sufficiente per iniziare immediatamente.",
        },
        {
          step: "02",
          title: "Leggere la superficie di lavoro",
          body:
            "Lo stato del terminale, i file, il contesto Git, i percorsi remoti e le note di interazione recenti rimangono visibili nello stesso mazzo di comandi.",
        },
        {
          step: "03",
          title: "Lascia che sia il supervisore a definire la mossa successiva",
          body:
            "icc può comprimere il contesto corrente in un piano di avvio, un brief di esecuzione o un passaggio di consegne da parte dell'operatore senza trasformare il flusso di lavoro in una cerimonia.",
        },
        {
          step: "04",
          title: "Esegui senza perdere il contesto",
          body:
            "Sfoglia file, modifica codice, esamina l'output e spostati tra destinazioni locali e remote mentre la conversazione rimane ancorata.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Risposte dirette a ciò che le persone chiedono per prime.",
      body: "Il prodotto rimane supponente sulla qualità del flusso di lavoro, pur rimanendo pratico da adottare.",
      items: [
        {
          q: "icc è solo una forchetta Ghostty?",
          a:
            "No. icc è un centro di comando nativo macOS basato sul rendering del terminale di livello Ghostty. Il prodotto espande queste basi con esplorazioni, modifica, esecuzione del browser, supervisione e orchestrazione dello spazio di lavoro.",
        },
        {
          q: "Per chi è icc?",
          a:
            "Operatori, ingegneri, fondatori e utenti esperti che già eseguono più flussi di lavoro assistiti da AI e desiderano una superficie di controllo più nitida invece di una maggiore espansione delle finestre.",
        },
        {
          q: "Cosa rende diverso il flusso di lavoro?",
          a:
            "icc mantiene il terminale di prima classe aggiungendo le superfici mancanti attorno ad esso: file, host remoti, controllo del codice sorgente, contesto del browser e un supervisore incentrato sull'esecuzione.",
        },
        {
          q: "Supporta il lavoro a distanza?",
          a:
            "Sì. icc legge la configurazione SSH, si connette a destinazioni remote ed espone file remoti nello stesso modello Explorer utilizzato per il lavoro locale.",
        },
      ],
    },
    cta: {
      eyebrow: "Avvia icc",
      title: "Passare dall'intento all'esecuzione senza perdere la forma dell'opera.",
      body:
        "Scarica la build corrente di macOS o monitora le versioni e il codice sorgente su GitHub. Il sito pubblico, la riga di rilascio e il repository sono ora allineati a un'unica identità: icc.",
    },
    footer: {
      blurb:
        "Nativo Swift e AppKit. Rendering di livello Ghostty. Contesto locale e remoto, operazioni sui file, esecuzione del browser, controllo del codice sorgente e supervisione in un unico spazio di lavoro a disposizione dell'operatore.",
      explore: "Esplora",
      release: "Rilascio",
      capabilities: "Capacità",
      workflow: "Flusso di lavoro",
      faq: "FAQ",
      download: "Scarica per macOS",
      releases: "Rilasci",
      repository: "GitHub Archivio",
      support: "Supporto/Problemi",
      copyright: "© {year} icc. Un abitacolo per l'esecuzione AI terminal-first.",
    },
  },
  "da": {
    metaTitle: "icc — AI Kommandocenter for macOS",
    metaDescription:
      "icc er et indfødt macOS kommandocenter til seriøst AI arbejde. Den kombinerer terminalgengivelse af Ghostty-grad, lokal og ekstern filudforskning, redigering i appen, browserudførelse, kildekontrolsynlighed og et supervisorlag i ét fokuseret arbejdsområde.",
    descriptor: "AI Kommandocenter for macOS",
    tagline: "Ét cockpit til terminal-first AI udførelse.",
    eyebrow: "Officiel side",
    heroDescription:
      "icc er et indfødt macOS kommandocenter til seriøst AI arbejde. Hold terminaludførelse, lokale og eksterne filer, kildekontrol, browseropgaver og supervisor-drevne næste trin i ét bevidst arbejdsområde.",
    buttons: {
      download: "Download til macOS",
      github: "Se på GitHub",
    },
    header: {
      capabilities: "Evner",
      workflow: "Arbejdsgang",
      faq: "FAQ",
      github: "GitHub",
      language: "Sprog",
      toggleTheme: "Skift tema",
      openMenu: "Åbn menuen",
      closeMenu: "Luk menuen",
    },
    heroCards: [
      {
        label: "Platform",
        title: "Native macOS",
        body: "Swift, AppKit, Ghostty-grad gengivelse.",
      },
      {
        label: "Arbejdsplads",
        title: "Lokal + fjernbetjening",
        body: "Én model for projekter, SSH-mål og filer.",
      },
      {
        label: "Driftsstil",
        title: "Zero-config først",
        body: "Udled konteksten tidligt, eksponer kun kontroller, når det er nødvendigt.",
      },
    ],
    preview: {
      workspace: "arbejdsområde: /Users/operator/work/icc",
      rail: "Jernbane",
      railItems: ["terminal / build", "repo / icc", "fjernbetjening / prod-ssh", "browser / anmeldelse"],
      terminal: "Terminal samtale",
      ready: "klar",
      lines: [
        "$ icc connect prod-ssh",
        "Forbundet. Læser eksternt arbejdsområde og skaltilstand.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Stier, filer, fjerntræ og næste handling forbliver synlige sammen.",
      ],
      supervisor: "Supervisor",
      status: "Status",
      statusReady: "Klar til at fortsætte",
      statusBody: "Mål udledt af aktuelle repo, filer og seneste opgavehistorik.",
      files: "Filer",
      filesBody: "Åbn, undersøg, rediger og gem uden at forlade arbejdsområdet.",
      remote: "Fjernbetjening",
      remoteBody: "SSH-understøttet browsing, samme layout, samme stihåndtering.",
    },
    capabilities: {
      eyebrow: "Evner",
      title: "Bygget til operatører, der ønsker konteksten synlig, mens arbejdet foregår.",
      body:
        "icc er ikke et andet browser-dashboard, der sidder oven på en terminal. Det er et kommandocenter, der holder udførelse, filer, fjerntilstand og vejledning inden for den samme arbejdsflade.",
      items: [
        {
          title: "Terminal-første udførelse",
          body:
            "Kør seriøst AI arbejde i en indbygget macOS shell-overflade i stedet for at hoppe mellem wrappers og løsrevne browserfaner.",
        },
        {
          title: "Lokale og fjerntliggende opdagelsesrejsende",
          body:
            "Gennemse lokale projekter og SSH-forbundne værter fra det samme arbejdsområde ved at bruge den samme mentale model og det samme kontrolplan til højre.",
        },
        {
          title: "Redigering af fil i appen",
          body:
            "Åbn, inspicér, rediger og gem filer uden at bryde terminalflowet. Træk stier direkte ind i den aktive samtale, når det er nødvendigt.",
        },
        {
          title: "Supervisor mode",
          body:
            "Gør et par linjer med brugerhensigt, projektkontekst og nyligt arbejde til en konkret udførelsesopgave med afgrænsede næste trin.",
        },
        {
          title: "Browser og automatisering",
          body:
            "Hold browserstøttede opgaver ved siden af terminalen, og udsæt dem for den samme operatørarbejdsgang i stedet for at jonglere med separate værktøjer.",
        },
        {
          title: "Kildekontrolsynlighed",
          body:
            "Hold Git-tilstand, repo-kontekst og arbejdsmapper synlige, mens agenter eller operatører skubber rigtigt arbejde fremad.",
        },
      ],
    },
    why: {
      eyebrow: "Hvorfor lander det anderledes",
      title: "Den hurtigste vej fra nogle få brugersvinger til en rigtig udførelsesflade.",
      items: [
        "Filer bliver ved siden af den aktive terminal i stedet for at gemme sig bag en separat app.",
        "Fjernværter bruger den samme stifinder og redigeringsarbejdsgang som lokale projekter.",
        "Kildekontrol og projektkontekst forbliver synlige, mens der sker ændringer.",
        "Supervisor-tilstand indrammer det næste træk uden at fremtvinge et tungt opsætningsritual.",
      ],
    },
    profile: {
      eyebrow: "Produktprofil",
      items: [
        {
          label: "Gengivelse",
          value: "Ghostty-terminalmotor med en indbygget macOS-skaloverflade.",
        },
        {
          label: "Overflade model",
          value: "Workspace-første layout med filer, browseropgaver og fjerntilstand i visning.",
        },
        {
          label: "Automatisering",
          value: "Supervisor, browserkontrol, CLI-kompatibilitet og opgaveklar kontekstkomprimering.",
        },
        {
          label: "Udløserlinje",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Arbejdsgang",
      title: "Zero-config hvor det skal være. Eksplicit kontrol, hvor det betyder noget.",
      body:
        "Produktfilosofien er enkel: udled først, spørg derefter. Du bør være i stand til at åbne et projekt, forbinde en vært og begynde at flytte, før du bliver begravet i opsætningspaneler.",
      items: [
        {
          step: "01",
          title: "Åbn et arbejdsområde",
          body:
            "Peg icc på en lokal repo eller tilslut et SSH mål. Zero-config flow udleder nok struktur til at begynde med det samme.",
        },
        {
          step: "02",
          title: "Læs arbejdsfladen",
          body:
            "Terminaltilstand, filer, Git-kontekst, eksterne stier og seneste interaktionsnoter forbliver synlige i det samme kommandodæk.",
        },
        {
          step: "03",
          title: "Lad supervisoren ramme det næste træk",
          body:
            "icc kan komprimere den aktuelle kontekst til en opstartsplan, udførelsesbrief eller operatøroverdragelse uden at omdanne arbejdsgangen til en ceremoni.",
        },
        {
          step: "04",
          title: "Udfør uden at miste kontekst",
          body:
            "Gennemse filer, rediger kode, inspicer output, og flyt mellem lokale og eksterne mål, mens samtalen forbliver forankret.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Direkte svar på det, folk spørger først.",
      body: "Produktet forbliver orienteret om workflow-kvalitet, mens det forbliver praktisk at adoptere.",
      items: [
        {
          q: "Er icc bare en Ghostty gaffel?",
          a:
            "Nej. icc er et indbygget macOS kommandocenter bygget på Ghostty-grade terminal rendering. Produktet udvider dette fundament med opdagelsesrejsende, redigering, browserudførelse, overvågning og orkestrering af arbejdsområde.",
        },
        {
          q: "Hvem er icc for?",
          a:
            "Operatører, ingeniører, grundlæggere og superbrugere, der allerede kører flere AI-støttede arbejdsgange og ønsker en skarpere kontrolflade i stedet for mere vinduespredning.",
        },
        {
          q: "Hvad gør arbejdsgangen anderledes?",
          a:
            "icc holder terminalen førsteklasses, mens den tilføjer de manglende overflader omkring den: filer, fjernværter, kildekontrol, browserkontekst og en eksekveringsfokuseret supervisor.",
        },
        {
          q: "Understøtter det fjernarbejde?",
          a:
            "Ja. icc læser SSH-konfigurationen, opretter forbindelse til fjernmål og afslører fjernfiler i den samme stifindermodel, der bruges til lokalt arbejde.",
        },
      ],
    },
    cta: {
      eyebrow: "Start icc",
      title: "Gå fra hensigt til udførelse uden at miste værkets form.",
      body:
        "Download den aktuelle macOS build eller spor udgivelser og kilde på GitHub. Det offentlige websted, udgivelseslinjen og lageret er nu justeret til én identitet: icc.",
    },
    footer: {
      blurb:
        "Native Swift og AppKit. Ghostty-grad gengivelse. Lokal og fjernkontekst, filhandlinger, browserudførelse, kildekontrol og overvågning i ét operatør-først-arbejdsområde.",
      explore: "Udforsk",
      release: "Slip",
      capabilities: "Evner",
      workflow: "Arbejdsgang",
      faq: "FAQ",
      download: "Download til macOS",
      releases: "Udgivelser",
      repository: "GitHub Repository",
      support: "Support / problemer",
      copyright: "© {year} icc. Ét cockpit til terminal-first AI udførelse.",
    },
  },
  "pl": {
    metaTitle: "icc — AI Centrum dowodzenia dla macOS",
    metaDescription:
      "icc to natywne centrum dowodzenia macOS do poważnych prac AI. Łączy w sobie renderowanie terminali klasy Ghostty, lokalną i zdalną eksplorację plików, edycję w aplikacji, wykonywanie w przeglądarce, widoczność kontroli źródła i warstwę nadzorczą w jednym skupionym obszarze roboczym.",
    descriptor: "AI Centrum dowodzenia dla macOS",
    tagline: "Jeden kokpit do wykonania AI w pierwszej kolejności na terminalu.",
    eyebrow: "Oficjalna strona",
    heroDescription:
      "icc to natywne centrum dowodzenia macOS do poważnych prac AI. Przechowuj wykonanie terminala, pliki lokalne i zdalne, kontrolę źródła, zadania przeglądarki i kolejne kroki kierowane przez nadzorcę w jednym przemyślanym obszarze roboczym.",
    buttons: {
      download: "Pobierz dla macOS",
      github: "Zobacz na GitHub",
    },
    header: {
      capabilities: "Możliwości",
      workflow: "Przebieg pracy",
      faq: "FAQ",
      github: "GitHub",
      language: "Język",
      toggleTheme: "Przełącz motyw",
      openMenu: "Otwórz menu",
      closeMenu: "Zamknij menu",
    },
    heroCards: [
      {
        label: "Platforma",
        title: "Natywny macOS",
        body: "Renderowanie klasy Swift, AppKit, Ghostty.",
      },
      {
        label: "Obszar roboczy",
        title: "Lokalny + zdalny",
        body: "Jeden model dla projektów, celów SSH i plików.",
      },
      {
        label: "Styl działania",
        title: "Najpierw zeruj konfigurację",
        body: "Wcześnie wyciągaj wnioski z kontekstu, udostępniaj elementy sterujące tylko wtedy, gdy jest to potrzebne.",
      },
    ],
    preview: {
      workspace: "obszar roboczy: /Użytkownicy/operator/praca/icc",
      rail: "Kolej",
      railItems: ["terminal / kompilacja", "repozytorium / icc", "pilot / prod-ssh", "przeglądarka/recenzja"],
      terminal: "Rozmowa terminalowa",
      ready: "gotowy",
      lines: [
        "$ icc connect prod-ssh",
        "Połączony. Odczytywanie zdalnego obszaru roboczego i stanu powłoki.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Ścieżki, pliki, zdalne drzewo i następna akcja pozostają widoczne razem.",
      ],
      supervisor: "Kierownik",
      status: "Status",
      statusReady: "Gotowy do kontynuacji",
      statusBody: "Cel wywnioskowany z bieżącego repozytorium, plików i historii ostatnich zadań.",
      files: "Akta",
      filesBody: "Otwieraj, sprawdzaj, edytuj i zapisuj bez opuszczania obszaru roboczego.",
      remote: "Zdalny",
      remoteBody: "Przeglądanie wspierane przez SSH, ten sam układ, ta sama obsługa ścieżek.",
    },
    capabilities: {
      eyebrow: "Możliwości",
      title: "Stworzony dla operatorów, którzy chcą, aby kontekst był widoczny podczas pracy.",
      body:
        "icc nie jest kolejnym panelem przeglądarki umieszczonym na terminalu. Jest to centrum dowodzenia, które utrzymuje wykonanie, pliki, stan zdalny i wskazówki w ramach tej samej powierzchni roboczej.",
      items: [
        {
          title: "Wykonanie w pierwszej kolejności na terminalu",
          body:
            "Wykonuj poważną pracę AI na natywnej powierzchni powłoki macOS zamiast przeskakiwać między opakowaniami i odłączonymi kartami przeglądarki.",
        },
        {
          title: "Lokalni i odlegli odkrywcy",
          body:
            "Przeglądaj lokalne projekty i hosty połączone z SSH z tego samego obszaru roboczego, używając tego samego modelu mentalnego i tej samej płaszczyzny sterowania po prawej stronie.",
        },
        {
          title: "Edycja plików w aplikacji",
          body:
            "Otwieraj, sprawdzaj, edytuj i zapisuj pliki bez przerywania przepływu terminala. W razie potrzeby przeciągnij ścieżki bezpośrednio do aktywnej konwersacji.",
        },
        {
          title: "Tryb nadzorcy",
          body:
            "Zamień kilka linijek intencji użytkownika, kontekstu projektu i ostatniej pracy w konkretny opis wykonania z ograniczonymi kolejnymi krokami.",
        },
        {
          title: "Przeglądarka i automatyzacja",
          body:
            "Trzymaj zadania obsługiwane przez przeglądarkę obok terminala i wystawiaj je na działanie tego samego operatora, zamiast żonglować oddzielnymi narzędziami.",
        },
        {
          title: "Widoczność kontroli źródła",
          body:
            "Utrzymuj stan Git, kontekst repo i katalogi robocze widoczne, podczas gdy agenci lub operatorzy wykonują prawdziwą pracę.",
        },
      ],
    },
    why: {
      eyebrow: "Dlaczego ląduje inaczej",
      title: "Najszybsza droga od kilku użytkowników prowadzi do prawdziwej powierzchni wykonawczej.",
      items: [
        "Pliki pozostają obok aktywnego terminala, zamiast chować się za osobną aplikacją.",
        "Hosty zdalne korzystają z tego samego procesu eksploracji i edycji, co projekty lokalne.",
        "Kontrola źródła i kontekst projektu pozostają widoczne podczas zachodzących zmian.",
        "Tryb nadzorcy wyznacza następny ruch bez wymuszania rytuału konfiguracyjnego wagi ciężkiej.",
      ],
    },
    profile: {
      eyebrow: "Profil produktu",
      items: [
        {
          label: "Wykonanie",
          value: "Silnik terminala klasy Ghostty z natywną powierzchnią powłoki macOS.",
        },
        {
          label: "Model powierzchniowy",
          value: "Układ skupiający się przede wszystkim na obszarze roboczym z podglądem plików, zadań przeglądarki i stanu zdalnego.",
        },
        {
          label: "Automatyzacja",
          value: "Nadzorca, kontrola przeglądarki, zgodność z CLI i kompresja kontekstu gotowa do wykonania zadania.",
        },
        {
          label: "Zwolnij linię",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Przebieg pracy",
      title: "Zero-konfiguracja tam, gdzie powinna być. Wyraźna kontrola tam, gdzie ma to znaczenie.",
      body:
        "Filozofia produktu jest prosta: najpierw wywnioskowaj, potem zapytaj. Powinieneś być w stanie otworzyć projekt, podłączyć hosta i zacząć działać, zanim zostaniesz pogrzebany w panelach konfiguracyjnych.",
      items: [
        {
          step: "01",
          title: "Otwórz obszar roboczy",
          body:
            "Wskaż icc lokalne repozytorium lub podłącz cel SSH. Przepływ konfiguracji zerowej sugeruje wystarczającą strukturę, aby rozpocząć natychmiast.",
        },
        {
          step: "02",
          title: "Przeczytaj powierzchnię roboczą",
          body:
            "Stan terminala, pliki, kontekst Git, ścieżki zdalne i notatki z ostatnich interakcji pozostają widoczne w tym samym panelu poleceń.",
        },
        {
          step: "03",
          title: "Pozwól przełożonemu ustalić następny ruch",
          body:
            "icc może skompresować bieżący kontekst w plan uruchomienia, wytyczne dotyczące wykonania lub przekazanie operatora bez przekształcania przepływu pracy w ceremonię.",
        },
        {
          step: "04",
          title: "Wykonuj bez utraty kontekstu",
          body:
            "Przeglądaj pliki, edytuj kod, sprawdzaj dane wyjściowe i poruszaj się między celami lokalnymi i zdalnymi, podczas gdy rozmowa pozostaje zakotwiczona.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Bezpośrednie odpowiedzi na to, o co ludzie pytają jako pierwsze.",
      body: "Produkt niezmiennie wyróżnia się jakością przepływu pracy, a jednocześnie jest praktyczny w zastosowaniu.",
      items: [
        {
          q: "Czy icc to tylko widelec Ghostty?",
          a:
            "Nie. icc to natywne centrum dowodzenia macOS zbudowane na renderowaniu terminali klasy Ghostty. Produkt rozszerza tę podstawę o eksploratory, edycję, uruchamianie przeglądarki, nadzór i orkiestrację przestrzeni roboczej.",
        },
        {
          q: "Dla kogo jest icc?",
          a:
            "Operatorzy, inżynierowie, założyciele i zaawansowani użytkownicy, którzy już realizują wiele przepływów pracy wspomaganych przez AI i chcą jednej, ostrzejszej powierzchni sterującej zamiast większej liczby okien.",
        },
        {
          q: "Co wyróżnia przepływ pracy?",
          a:
            "icc utrzymuje terminal na najwyższym poziomie, dodając jednocześnie brakujące elementy wokół niego: pliki, zdalne hosty, kontrolę źródła, kontekst przeglądarki i nadzorcę skupionego na wykonaniu.",
        },
        {
          q: "Czy wspiera pracę zdalną?",
          a:
            "Tak. icc odczytuje konfigurację SSH, łączy się ze zdalnymi celami i udostępnia zdalne pliki w tym samym modelu eksploratora, który jest używany do pracy lokalnej.",
        },
      ],
    },
    cta: {
      eyebrow: "Uruchom icc",
      title: "Przejdź od zamierzenia do wykonania, nie tracąc kształtu dzieła.",
      body:
        "Pobierz aktualne wersje kompilacji lub utworów macOS i źródła na GitHub. Witryna publiczna, wersja wydania i repozytorium są teraz powiązane z jedną tożsamością: icc.",
    },
    footer: {
      blurb:
        "Natywne Swift i AppKit. Renderowanie klasy Ghostty. Kontekst lokalny i zdalny, operacje na plikach, wykonywanie przeglądarki, kontrola źródła i nadzór w jednym obszarze roboczym przeznaczonym dla operatora.",
      explore: "Badać",
      release: "Uwolnienie",
      capabilities: "Możliwości",
      workflow: "Przebieg pracy",
      faq: "FAQ",
      download: "Pobierz dla macOS",
      releases: "Wydania",
      repository: "GitHub Repozytorium",
      support: "Wsparcie / problemy",
      copyright: "© {year} icc. Jeden kokpit do wykonania AI w pierwszej kolejności na terminalu.",
    },
  },
  "ru": {
    metaTitle: "icc — AI Командный центр для macOS",
    metaDescription:
      "icc — это собственный командный центр macOS для серьезной работы AI. Он сочетает в себе рендеринг терминала уровня Ghostty, локальное и удаленное исследование файлов, редактирование в приложении, выполнение в браузере, видимость системы управления версиями и уровень супервизора в одном сфокусированном рабочем пространстве.",
    descriptor: "AI Командный центр macOS",
    tagline: "Одна панель управления для выполнения AI сначала на терминале.",
    eyebrow: "Официальный сайт",
    heroDescription:
      "icc — это собственный командный центр macOS для серьезной работы AI. Храните выполнение терминала, локальные и удаленные файлы, систему контроля версий, задачи браузера и последующие шаги, управляемые руководителем, в одном специальном рабочем пространстве.",
    buttons: {
      download: "Скачать для macOS",
      github: "Посмотреть на GitHub",
    },
    header: {
      capabilities: "Возможности",
      workflow: "Рабочий процесс",
      faq: "FAQ",
      github: "GitHub",
      language: "Язык",
      toggleTheme: "Переключить тему",
      openMenu: "Открыть меню",
      closeMenu: "Закрыть меню",
    },
    heroCards: [
      {
        label: "Платформа",
        title: "Родной macOS",
        body: "Рендеринг уровня Swift, AppKit, Ghostty.",
      },
      {
        label: "Рабочая область",
        title: "Локальный + удаленный",
        body: "Одна модель для проектов, целей SSH и файлов.",
      },
      {
        label: "Стиль работы",
        title: "Сначала нулевая конфигурация",
        body: "Выявляйте контекст заранее, открывайте элементы управления только при необходимости.",
      },
    ],
    preview: {
      workspace: "рабочая область: /Users/operator/work/icc",
      rail: "Железнодорожный",
      railItems: ["терминал/сборка", "репо / icc", "удаленный / prod-ssh", "браузер/обзор"],
      terminal: "Терминальный разговор",
      ready: "готов",
      lines: [
        "$ icc connect prod-ssh",
        "Подключено. Чтение удаленного рабочего пространства и состояния оболочки.",
        "$ git status --short",
        "М Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Пути, файлы, удаленное дерево и следующее действие остаются видимыми вместе.",
      ],
      supervisor: "супервайзер",
      status: "Статус",
      statusReady: "Готов продолжить",
      statusBody: "Цель выводится из текущего репозитория, файлов и истории недавних задач.",
      files: "Файлы",
      filesBody: "Открывайте, проверяйте, редактируйте и сохраняйте, не выходя из рабочей области.",
      remote: "Удаленный",
      remoteBody: "Просмотр на основе SSH, тот же макет, та же обработка путей.",
    },
    capabilities: {
      eyebrow: "Возможности",
      title: "Создано для операторов, которым нужен видимый контекст во время работы.",
      body:
        "icc — это не еще одна панель управления браузером, расположенная поверх терминала. Это командный центр, который хранит выполнение, файлы, удаленное состояние и руководство в одной рабочей поверхности.",
      items: [
        {
          title: "Выполнение сначала через терминал",
          body:
            "Выполняйте серьезную работу AI в собственной оболочке macOS вместо того, чтобы метаться между оболочками и отдельными вкладками браузера.",
        },
        {
          title: "Локальные и удаленные исследователи",
          body:
            "Просматривайте локальные проекты и хосты, подключенные к SSH, из одной рабочей области, используя одну и ту же ментальную модель и одну и ту же правую плоскость управления.",
        },
        {
          title: "Редактирование файлов в приложении",
          body:
            "Открывайте, проверяйте, редактируйте и сохраняйте файлы, не нарушая работу терминала. При необходимости перетаскивайте пути прямо в активный разговор.",
        },
        {
          title: "Режим супервизора",
          body:
            "Превратите несколько строк о намерениях пользователя, контексте проекта и недавней работе в конкретное краткое описание выполнения с указанием следующих шагов.",
        },
        {
          title: "Браузер и автоматизация",
          body:
            "Храните задачи, поддерживаемые браузером, рядом с терминалом и предоставляйте их одному и тому же рабочему процессу оператора вместо манипулирования отдельными инструментами.",
        },
        {
          title: "Видимость системы управления версиями",
          body:
            "Сохраняйте состояние Git, контекст репозитория и рабочие каталоги видимыми, пока агенты или операторы выполняют реальную работу.",
        },
      ],
    },
    why: {
      eyebrow: "Почему он приземляется по-другому",
      title: "Самый быстрый путь от нескольких пользовательских поворотов к реальной поверхности исполнения.",
      items: [
        "Файлы остаются рядом с активным терминалом, а не прячутся за отдельным приложением.",
        "Удаленные хосты используют тот же рабочий процесс просмотра и редактирования, что и локальные проекты.",
        "Система контроля версий и контекст проекта остаются видимыми, пока происходят изменения.",
        "Режим супервизора определяет следующий шаг, не навязывая сложного ритуала настройки.",
      ],
    },
    profile: {
      eyebrow: "Профиль продукта",
      items: [
        {
          label: "Рендеринг",
          value: "Конечный двигатель класса Ghostty с собственной поверхностью корпуса macOS.",
        },
        {
          label: "Модель поверхности",
          value: "Макет рабочей области с отображением файлов, задач браузера и удаленного состояния.",
        },
        {
          label: "Автоматизация",
          value: "Супервизор, управление браузером, совместимость с CLI и сжатие контекста для выполнения задач.",
        },
        {
          label: "Линия выпуска",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Рабочий процесс",
      title: "Нулевая конфигурация там, где она должна быть. Явный контроль там, где это важно.",
      body:
        "Философия продукта проста: сначала сделайте вывод, потом спросите. Вы должны быть в состоянии открыть проект, подключить хост и начать двигаться, прежде чем погрузиться в панели настройки.",
      items: [
        {
          step: "01",
          title: "Открыть рабочую область",
          body:
            "Направьте icc на локальный репозиторий или подключите цель SSH. Поток с нулевой конфигурацией предполагает достаточную структуру, чтобы начать немедленно.",
        },
        {
          step: "02",
          title: "Прочтите рабочую поверхность",
          body:
            "Состояние терминала, файлы, контекст Git, удаленные пути и примечания к недавнему взаимодействию остаются видимыми в одной и той же командной панели.",
        },
        {
          step: "03",
          title: "Пусть руководитель определит следующий шаг",
          body:
            "icc может сжать текущий контекст в план запуска, краткое описание выполнения или передачу оператору, не превращая рабочий процесс в церемонию.",
        },
        {
          step: "04",
          title: "Выполнить, не теряя контекста",
          body:
            "Просматривайте файлы, редактируйте код, проверяйте выходные данные и перемещайтесь между локальными и удаленными объектами, сохраняя при этом диалог.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Прямые ответы на то, что люди спрашивают в первую очередь.",
      body: "Продукт остается самоуверенным в отношении качества рабочего процесса, оставаясь при этом практичным в использовании.",
      items: [
        {
          q: "Является ли icc просто форком Ghostty?",
          a:
            "Нет. icc — это собственный командный центр macOS, созданный на основе рендеринга терминала уровня Ghostty. Продукт расширяет эту основу за счет средств просмотра, редактирования, выполнения в браузере, контроля и оркестрации рабочей области.",
        },
        {
          q: "Для кого предназначен icc?",
          a:
            "Операторы, инженеры, основатели и опытные пользователи, которые уже используют несколько рабочих процессов с помощью AI и хотят иметь одну более четкую поверхность управления вместо большого количества окон.",
        },
        {
          q: "Чем отличается рабочий процесс?",
          a:
            "icc сохраняет терминал первоклассным, добавляя вокруг него недостающие поверхности: файлы, удаленные хосты, систему контроля версий, контекст браузера и супервизор, ориентированный на выполнение.",
        },
        {
          q: "Поддерживает ли он удаленную работу?",
          a:
            "Да. icc считывает конфигурацию SSH, подключается к удаленным целям и предоставляет удаленные файлы в той же модели проводника, которая используется для локальной работы.",
        },
      ],
    },
    cta: {
      eyebrow: "Запустить icc",
      title: "Двигайтесь от замысла к исполнению, не теряя формы работы.",
      body:
        "Загрузите текущую сборку macOS или отслеживайте выпуски и исходный код на GitHub. Публичный сайт, версия выпуска и репозиторий теперь привязаны к одному идентификатору: icc.",
    },
    footer: {
      blurb:
        "Собственные Swift и AppKit. Рендеринг уровня Ghostty. Локальный и удаленный контекст, файловые операции, выполнение браузера, контроль версий и контроль в одном рабочем пространстве, ориентированном на оператора.",
      explore: "Исследуйте",
      release: "Релиз",
      capabilities: "Возможности",
      workflow: "Рабочий процесс",
      faq: "FAQ",
      download: "Скачать для macOS",
      releases: "Релизы",
      repository: "GitHub Репозиторий",
      support: "Поддержка/Проблемы",
      copyright: "© {year} icc. Одна панель управления для выполнения AI сначала на терминале.",
    },
  },
  "bs": {
    metaTitle: "icc — AI Komandni centar za macOS",
    metaDescription:
      "icc je izvorni macOS komandni centar za ozbiljan AI posao. Kombinira renderiranje terminala Ghostty, lokalno i udaljeno istraživanje datoteka, uređivanje u aplikaciji, izvršavanje pretraživača, vidljivost izvorne kontrole i sloj supervizora u jednom fokusiranom radnom prostoru.",
    descriptor: "AI Komandni centar za macOS",
    tagline: "Jedan kokpit za terminal-prvo AI izvršenje.",
    eyebrow: "Službena stranica",
    heroDescription:
      "icc je izvorni macOS komandni centar za ozbiljan AI posao. Zadržite izvršavanje terminala, lokalne i udaljene datoteke, kontrolu izvora, zadatke pretraživača i sljedeće korake vođene supervizorom unutar jednog namjernog radnog prostora.",
    buttons: {
      download: "Preuzmite za macOS",
      github: "Pogledaj na GitHub",
    },
    header: {
      capabilities: "Mogućnosti",
      workflow: "Workflow",
      faq: "FAQ",
      github: "GitHub",
      language: "Jezik",
      toggleTheme: "Uključi/isključi temu",
      openMenu: "Otvorite meni",
      closeMenu: "Zatvori meni",
    },
    heroCards: [
      {
        label: "Platforma",
        title: "Izvorni macOS",
        body: "Swift, AppKit, Ghostty-grade rendering.",
      },
      {
        label: "Radni prostor",
        title: "Lokalno + daljinsko",
        body: "Jedan model za projekte, SSH ciljeve i datoteke.",
      },
      {
        label: "Stil rada",
        title: "Prvo nula konfiguracija",
        body: "Rano zaključiti kontekst, izložiti kontrole samo kada je to potrebno.",
      },
    ],
    preview: {
      workspace: "radni prostor: /Users/operator/work/icc",
      rail: "Rail",
      railItems: ["terminal / build", "repo / icc", "daljinski / prod-ssh", "pretraživač / recenzija"],
      terminal: "Završni razgovor",
      ready: "spreman",
      lines: [
        "$ icc connect prod-ssh",
        "Povezano. Čitanje udaljenog radnog prostora i stanja ljuske.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Staze, datoteke, udaljeno stablo i sljedeća akcija ostaju vidljivi zajedno.",
      ],
      supervisor: "Supervizor",
      status: "Status",
      statusReady: "Spremni za nastavak",
      statusBody: "Cilj se zaključuje iz trenutnog repo-a, fajlova i nedavne istorije zadataka.",
      files: "Fajlovi",
      filesBody: "Otvorite, pregledajte, uredite i sačuvajte bez napuštanja radnog prostora.",
      remote: "Daljinski",
      remoteBody: "SSH-pozadinsko pregledanje, isti raspored, ista rukovanja putanjom.",
    },
    capabilities: {
      eyebrow: "Mogućnosti",
      title: "Napravljen za operatere koji žele da kontekst bude vidljiv dok se posao odvija.",
      body:
        "icc nije još jedna kontrolna tabla pretraživača koja se nalazi na vrhu terminala. To je komandni centar koji drži izvršenje, datoteke, udaljeno stanje i navođenje unutar iste radne površine.",
      items: [
        {
          title: "Terminal-prvo izvršenje",
          body:
            "Pokrenite ozbiljan AI rad u izvornoj macOS površini ljuske umjesto da se krećete između omotača i odvojenih kartica pretraživača.",
        },
        {
          title: "Lokalni i udaljeni istraživači",
          body:
            "Pretražujte lokalne projekte i SSH-povezane hostove iz istog radnog prostora, koristeći isti mentalni model i istu desnu kontrolnu ravninu.",
        },
        {
          title: "Uređivanje fajlova u aplikaciji",
          body:
            "Otvorite, pregledajte, uredite i sačuvajte datoteke bez prekidanja protoka terminala. Prevucite putanje direktno u aktivni razgovor kada je to potrebno.",
        },
        {
          title: "Način nadzora",
          body:
            "Pretvorite nekoliko redova namjere korisnika, kontekst projekta i nedavni rad u konkretan sažetak izvršenja s ograničenim sljedećim koracima.",
        },
        {
          title: "Preglednik i automatizacija",
          body:
            "Zadatke podržane preglednikom držite pored terminala i izložite ih istom toku rada operatera umjesto žongliranja s odvojenim alatima.",
        },
        {
          title: "Vidljivost kontrole izvora",
          body:
            "Držite Git stanje, repo kontekst i radne direktorije vidljivima dok agenti ili operateri guraju pravi posao naprijed.",
        },
      ],
    },
    why: {
      eyebrow: "Zašto slijeće drugačije",
      title: "Najbrži put od nekoliko korisnika skreće do prave izvršne površine.",
      items: [
        "Datoteke ostaju pored aktivnog terminala umjesto da se skrivaju iza zasebne aplikacije.",
        "Udaljeni domaćini koriste isti istraživač i proces uređivanja kao i lokalni projekti.",
        "Kontrola izvora i kontekst projekta ostaju vidljivi dok se promjene dešavaju.",
        "Režim nadzora uokviruje sljedeći potez bez prisiljavanja na ritual postavljanja teške kategorije.",
      ],
    },
    profile: {
      eyebrow: "Profil proizvoda",
      items: [
        {
          label: "Rendering",
          value: "Terminalni motor Ghostty klase sa prirodnom površinom ljuske macOS.",
        },
        {
          label: "Model površine",
          value: "Izgled prvog radnog prostora sa datotekama, zadacima pretraživača i udaljenim stanjem u pregledu.",
        },
        {
          label: "Automatizacija",
          value: "Supervizor, kontrola pretraživača, CLI kompatibilnost i kompresija konteksta spremna za zadatak.",
        },
        {
          label: "Release line",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Workflow",
      title: "Zero-config tamo gde bi trebalo da bude. Eksplicitna kontrola tamo gde je to važno.",
      body:
        "Filozofija proizvoda je jednostavna: prvo zaključi, drugo pitaj. Trebalo bi da budete u mogućnosti da otvorite projekat, povežete host i počnete da se krećete pre nego što budete ukopani u panele za podešavanje.",
      items: [
        {
          step: "01",
          title: "Otvorite radni prostor",
          body:
            "Usmjerite icc na lokalni repo ili povežite SSH cilj. Tok nulte konfiguracije zaključuje dovoljnu strukturu da odmah počne.",
        },
        {
          step: "02",
          title: "Pročitajte radnu površinu",
          body:
            "Stanje terminala, datoteke, Git kontekst, udaljene staze i bilješke o nedavnim interakcijama ostaju vidljivi u istom komandnom špilu.",
        },
        {
          step: "03",
          title: "Neka supervizor osmisli sljedeći korak",
          body:
            "icc može komprimirati trenutni kontekst u plan pokretanja, sažetak izvršenja ili predaju operatera bez pretvaranja toka posla u ceremoniju.",
        },
        {
          step: "04",
          title: "Izvršite bez gubljenja konteksta",
          body:
            "Pretražujte datoteke, uređujte kod, pregledajte izlaz i kretajte se između lokalnih i udaljenih ciljeva dok razgovor ostaje usidren.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Direktni odgovori na ono što ljudi prvo pitaju.",
      body: "Proizvod ostaje uvjeren o kvaliteti toka rada, dok ostaje praktičan za usvajanje.",
      items: [
        {
          q: "Je li icc samo Ghostty viljuška?",
          a:
            "Ne. icc je izvorni macOS komandni centar izgrađen na terminalskom renderiranju Ghostty-grade. Proizvod proširuje tu osnovu pomoću istraživača, uređivanja, izvršavanja pretraživača, nadzora i orkestracije radnog prostora.",
        },
        {
          q: "Za koga je icc?",
          a:
            "Operateri, inženjeri, osnivači i napredni korisnici koji već pokreću više tokova rada uz pomoć AI i žele jednu oštriju kontrolnu površinu umjesto većeg širenja prozora.",
        },
        {
          q: "Šta čini tok rada drugačijim?",
          a:
            "icc održava terminal prvoklasnim dok dodaje nedostajuće površine oko njega: datoteke, udaljene hostove, kontrolu izvora, kontekst pretraživača i supervizor fokusiran na izvršenje.",
        },
        {
          q: "Da li podržava rad na daljinu?",
          a:
            "Da. icc čita SSH konfiguraciju, povezuje se na udaljene ciljeve i izlaže udaljene datoteke u istom modelu istraživača koji se koristi za lokalni rad.",
        },
      ],
    },
    cta: {
      eyebrow: "Pokreni icc",
      title: "Pređite od namjere do izvršenja bez gubljenja oblika djela.",
      body:
        "Preuzmite trenutna macOS build ili track izdanja i izvor na GitHub. Javna stranica, linija izdanja i spremište su sada usklađeni s jednim identitetom: icc.",
    },
    footer: {
      blurb:
        "Izvorni Swift i AppKit. Ghostty-grade rendering. Lokalni i udaljeni kontekst, operacije sa datotekama, izvršavanje pretraživača, kontrola izvora i nadzor u jednom radnom prostoru za operatera.",
      explore: "Istražite",
      release: "Pusti",
      capabilities: "Mogućnosti",
      workflow: "Workflow",
      faq: "FAQ",
      download: "Preuzmite za macOS",
      releases: "Izdanja",
      repository: "GitHub Spremište",
      support: "Podrška / Problemi",
      copyright: "© {year} icc. Jedan kokpit za terminal-prvo AI izvršenje.",
    },
  },
  "ar": {
    metaTitle: "icc — AI مركز القيادة لـ macOS",
    metaDescription:
      "icc هو مركز قيادة macOS أصلي للعمل الجاد AI. فهو يجمع بين عرض المحطة الطرفية من فئة Ghostty، واستكشاف الملفات المحلية والبعيدة، والتحرير داخل التطبيق، وتنفيذ المتصفح، ورؤية التحكم في المصدر، وطبقة المشرف في مساحة عمل مركزة واحدة.",
    descriptor: "AI مركز القيادة لـ macOS",
    tagline: "قمرة قيادة واحدة لتنفيذ المحطة الأولى AI.",
    eyebrow: "الموقع الرسمي",
    heroDescription:
      "icc هو مركز قيادة macOS أصلي للعمل الجاد AI. احتفظ بالتنفيذ الطرفي، والملفات المحلية والبعيدة، والتحكم في المصدر، ومهام المتصفح، والخطوات التالية التي يحركها المشرف داخل مساحة عمل واحدة متعمدة.",
    buttons: {
      download: "تنزيل لـ macOS",
      github: "عرض على GitHub",
    },
    header: {
      capabilities: "القدرات",
      workflow: "سير العمل",
      faq: "FAQ",
      github: "GitHub",
      language: "اللغة",
      toggleTheme: "تبديل الموضوع",
      openMenu: "فتح القائمة",
      closeMenu: "إغلاق القائمة",
    },
    heroCards: [
      {
        label: "منصة",
        title: "أصلي macOS",
        body: "Swift، AppKit، Ghostty تقديم الدرجة.",
      },
      {
        label: "مساحة العمل",
        title: "محلي + بعيد",
        body: "نموذج واحد للمشاريع وأهداف SSH والملفات.",
      },
      {
        label: "أسلوب التشغيل",
        title: "التكوين صفر أولاً",
        body: "استنتج السياق مبكرًا، واكشف عن عناصر التحكم فقط عند الحاجة.",
      },
    ],
    preview: {
      workspace: "مساحة العمل: /المستخدمون/المشغل/العمل/icc",
      rail: "السكك الحديدية",
      railItems: ["المحطة / البناء", "الريبو / icc", "البعيد / prod-ssh", "المتصفح / المراجعة"],
      terminal: "محادثة نهائية",
      ready: "جاهز",
      lines: [
        "$ icc connect prod-ssh",
        "متصل. قراءة مساحة العمل عن بعد وحالة الصدفة.",
        "$ git status --short",
        "م Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "تظل المسارات والملفات والشجرة البعيدة والإجراء التالي مرئية معًا.",
      ],
      supervisor: "المشرف",
      status: "الحالة",
      statusReady: "على استعداد للمتابعة",
      statusBody: "الهدف المستنتج من الريبو الحالي والملفات وسجل المهام الأخير.",
      files: "ملفات",
      filesBody: "قم بالفتح والفحص والتحرير والحفظ دون مغادرة مساحة العمل.",
      remote: "بعيد",
      remoteBody: "SSH التصفح المدعوم، نفس التخطيط، نفس التعامل مع المسار.",
    },
    capabilities: {
      eyebrow: "القدرات",
      title: "مصمم للمشغلين الذين يريدون أن يكون السياق مرئيًا أثناء تنفيذ العمل.",
      body:
        "icc ليست لوحة تحكم متصفح أخرى موجودة أعلى الوحدة الطرفية. إنه مركز قيادة يحافظ على التنفيذ والملفات والحالة البعيدة والتوجيه داخل نفس سطح العمل.",
      items: [
        {
          title: "التنفيذ النهائي للمحطة الأولى",
          body:
            "قم بتشغيل عمل AI الجاد في سطح shell macOS الأصلي بدلاً من الارتداد بين الأغلفة وعلامات تبويب المتصفح المنفصلة.",
        },
        {
          title: "المستكشفون المحليون والبعيدون",
          body:
            "تصفح المشاريع المحلية والمضيفين المتصلين بـ SSH من نفس مساحة العمل، باستخدام نفس النموذج العقلي ونفس مستوى التحكم في الجانب الأيمن.",
        },
        {
          title: "تحرير الملفات داخل التطبيق",
          body:
            "فتح الملفات وفحصها وتحريرها وحفظها دون انقطاع التدفق الطرفي. اسحب المسارات مباشرة إلى المحادثة النشطة عند الحاجة.",
        },
        {
          title: "وضع المشرف",
          body:
            "قم بتحويل بضعة أسطر من نية المستخدم وسياق المشروع والعمل الأخير إلى ملخص تنفيذ ملموس مع خطوات تالية محددة.",
        },
        {
          title: "المتصفح والأتمتة",
          body:
            "احتفظ بالمهام المدعومة بالمتصفح بجانب الجهاز وقم بتعريضها لنفس سير عمل المشغل بدلاً من استخدام أدوات منفصلة.",
        },
        {
          title: "رؤية التحكم في المصدر",
          body:
            "احتفظ بحالة Git وسياق الريبو وأدلة العمل مرئية بينما يقوم الوكلاء أو المشغلون بدفع العمل الحقيقي إلى الأمام.",
        },
      ],
    },
    why: {
      eyebrow: "لماذا يهبط بشكل مختلف",
      title: "أسرع مسار من عدد قليل من المستخدمين يتحول إلى سطح تنفيذ حقيقي.",
      items: [
        "تظل الملفات بجوار الجهاز النشط بدلاً من الاختباء خلف تطبيق منفصل.",
        "يستخدم المضيفون البعيدون نفس المستكشف وسير عمل التحرير مثل المشاريع المحلية.",
        "يظل التحكم بالمصدر وسياق المشروع مرئيين أثناء حدوث التغييرات.",
        "يضع وضع المشرف إطارًا للحركة التالية دون فرض طقوس إعداد ثقيلة الوزن.",
      ],
    },
    profile: {
      eyebrow: "الملف الشخصي للمنتج",
      items: [
        {
          label: "التقديم",
          value: "محرك طرفي من فئة Ghostty مع سطح غلاف أصلي macOS.",
        },
        {
          label: "نموذج السطح",
          value: "تخطيط مساحة العمل أولاً مع الملفات ومهام المتصفح وعرض الحالة البعيدة.",
        },
        {
          label: "الأتمتة",
          value: "المشرف، والتحكم في المتصفح، وتوافق CLI، وضغط السياق الجاهز للمهمة.",
        },
        {
          label: "خط الافراج",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "سير العمل",
      title: "التكوين صفر حيث ينبغي أن يكون. سيطرة صريحة حيث يهم.",
      body:
        "فلسفة المنتج بسيطة: استنتج أولاً، اسأل ثانياً. يجب أن تكون قادرًا على فتح مشروع، والاتصال بالمضيف، والبدء في التحرك قبل أن تدفن في لوحات الإعداد.",
      items: [
        {
          step: "01",
          title: "افتح مساحة عمل",
          body:
            "قم بتوجيه icc إلى الريبو المحلي أو قم بتوصيل هدف SSH. يوفر تدفق التكوين الصفري بنية كافية للبدء على الفور.",
        },
        {
          step: "02",
          title: "قراءة سطح العمل",
          body:
            "تظل الحالة الطرفية والملفات وسياق Git والمسارات البعيدة وملاحظات التفاعل الأخيرة مرئية في نفس مجموعة الأوامر.",
        },
        {
          step: "03",
          title: "دع المشرف يحدد الخطوة التالية",
          body:
            "يمكن لـ icc ضغط السياق الحالي في خطة بدء التشغيل، أو ملخص التنفيذ، أو تسليم المشغل دون تحويل سير العمل إلى حفل.",
        },
        {
          step: "04",
          title: "تنفيذ دون فقدان السياق",
          body:
            "تصفح الملفات، وقم بتحرير التعليمات البرمجية، وفحص المخرجات، والتنقل بين الأهداف المحلية والبعيدة بينما تظل المحادثة ثابتة.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "إجابات مباشرة على ما يسأل الناس أولا.",
      body: "يظل المنتج متمسكًا بآرائه بشأن جودة سير العمل، بينما يظل عمليًا للاعتماد.",
      items: [
        {
          q: "هل icc مجرد شوكة Ghostty؟",
          a:
            "رقم icc هو مركز قيادة macOS أصلي مبني على عرض طرفي من فئة Ghostty. يقوم المنتج بتوسيع هذا الأساس من خلال المستكشفين والتحرير وتنفيذ المتصفح والإشراف وتنسيق مساحة العمل.",
        },
        {
          q: "لمن icc؟",
          a:
            "المشغلون والمهندسون والمؤسسون ومستخدمو الطاقة الذين يقومون بالفعل بتشغيل العديد من عمليات سير العمل بمساعدة AI ويريدون سطح تحكم أكثر وضوحًا بدلاً من المزيد من امتداد النافذة.",
        },
        {
          q: "ما الذي يجعل سير العمل مختلفًا؟",
          a:
            "icc يحافظ على الجهاز من الدرجة الأولى مع إضافة الأسطح المفقودة حوله: الملفات، والمضيفون البعيدون، والتحكم في المصدر، وسياق المتصفح، والمشرف الذي يركز على التنفيذ.",
        },
        {
          q: "هل يدعم العمل عن بعد؟",
          a:
            "نعم. يقرأ icc تكوين SSH ويتصل بالأهداف البعيدة ويكشف عن الملفات البعيدة في نفس نموذج المستكشف المستخدم للعمل المحلي.",
        },
      ],
    },
    cta: {
      eyebrow: "إطلاق icc",
      title: "الانتقال من النية إلى التنفيذ دون أن يفقد شكل العمل.",
      body:
        "قم بتنزيل النسخة الحالية من macOS أو تتبع الإصدارات والمصدر على GitHub. أصبح الموقع العام وخط الإصدار والمستودع الآن متوافقين مع هوية واحدة: icc.",
    },
    footer: {
      blurb:
        "أصلي Swift وAppKit. Ghostty-تقديم الصف. السياق المحلي والبعيد، وعمليات الملفات، وتنفيذ المتصفح، والتحكم في المصدر، والإشراف في مساحة عمل واحدة للمشغل أولاً.",
      explore: "استكشاف",
      release: "الافراج",
      capabilities: "القدرات",
      workflow: "سير العمل",
      faq: "FAQ",
      download: "تنزيل لـ macOS",
      releases: "الإصدارات",
      repository: "GitHub المستودع",
      support: "الدعم / القضايا",
      copyright: "© {year} icc. قمرة قيادة واحدة لتنفيذ المحطة الأولى AI.",
    },
  },
  "no": {
    metaTitle: "icc — AI Kommandosenter for macOS",
    metaDescription:
      "icc er et innfødt macOS kommandosenter for seriøst AI arbeid. Den kombinerer terminalgjengivelse av Ghostty-grad, lokal og ekstern filutforskning, redigering i appen, nettleserkjøring, kildekontrollsynlighet og et supervisorlag i ett fokusert arbeidsområde.",
    descriptor: "AI Kommandosenter for macOS",
    tagline: "Én cockpit for terminal-first AI utførelse.",
    eyebrow: "Offisiell side",
    heroDescription:
      "icc er et innfødt macOS kommandosenter for seriøst AI arbeid. Hold terminalkjøring, lokale og eksterne filer, kildekontroll, nettleseroppgaver og veilederdrevne neste trinn i ett bevisst arbeidsområde.",
    buttons: {
      download: "Last ned for macOS",
      github: "Se på GitHub",
    },
    header: {
      capabilities: "Evner",
      workflow: "Arbeidsflyt",
      faq: "FAQ",
      github: "GitHub",
      language: "Språk",
      toggleTheme: "Bytt tema",
      openMenu: "Åpne menyen",
      closeMenu: "Lukk menyen",
    },
    heroCards: [
      {
        label: "Plattform",
        title: "Innebygd macOS",
        body: "Swift, AppKit, Ghostty-grad gjengivelse.",
      },
      {
        label: "Arbeidsområde",
        title: "Lokal + fjernkontroll",
        body: "Én modell for prosjekter, SSH-mål og filer.",
      },
      {
        label: "Driftsstil",
        title: "Null-konfigurasjon først",
        body: "Utlede konteksten tidlig, eksponer kontroller bare når det er nødvendig.",
      },
    ],
    preview: {
      workspace: "arbeidsområde: /Users/operator/work/icc",
      rail: "Jernbane",
      railItems: ["terminal / bygg", "repo / icc", "fjernkontroll / prod-ssh", "nettleser / anmeldelse"],
      terminal: "Terminal samtale",
      ready: "klar",
      lines: [
        "$ icc connect prod-ssh",
        "Tilkoblet. Leser eksternt arbeidsområde og skalltilstand.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Baner, filer, eksternt tre og neste handling forblir synlige sammen.",
      ],
      supervisor: "Veileder",
      status: "Status",
      statusReady: "Klar til å fortsette",
      statusBody: "Mål utledet fra gjeldende repo, filer og nylig oppgavehistorikk.",
      files: "Filer",
      filesBody: "Åpne, inspiser, rediger og lagre uten å forlate arbeidsområdet.",
      remote: "Fjernkontroll",
      remoteBody: "SSH-støttet surfing, samme layout, samme banehåndtering.",
    },
    capabilities: {
      eyebrow: "Evner",
      title: "Bygget for operatører som ønsker kontekst synlig mens arbeidet pågår.",
      body:
        "icc er ikke et annet nettleserdashbord som sitter på toppen av en terminal. Det er et kommandosenter som holder kjøring, filer, ekstern tilstand og veiledning innenfor samme arbeidsflate.",
      items: [
        {
          title: "Terminal-første utførelse",
          body:
            "Kjør seriøst AI-arbeid i en opprinnelig macOS-skalloverflate i stedet for å sprette mellom wrappers og løsrevne nettleserfaner.",
        },
        {
          title: "Lokale og eksterne oppdagere",
          body:
            "Bla gjennom lokale prosjekter og SSH-tilkoblede verter fra samme arbeidsområde, med samme mentale modell og samme kontrollplan på høyre side.",
        },
        {
          title: "Redigering av filer i appen",
          body:
            "Åpne, inspiser, rediger og lagre filer uten å bryte terminalflyten. Dra stier direkte inn i den aktive samtalen ved behov.",
        },
        {
          title: "Supervisor-modus",
          body:
            "Gjør noen få linjer med brukerintensjon, prosjektkontekst og nylig arbeid til en konkret utførelsesoppgave med avgrensede neste trinn.",
        },
        {
          title: "Nettleser og automatisering",
          body:
            "Hold nettleserstøttede oppgaver ved siden av terminalen og utsett dem for den samme operatørens arbeidsflyt i stedet for å sjonglere med separate verktøy.",
        },
        {
          title: "Synlighet for kildekontroll",
          body:
            "Hold Git-status, repo-kontekst og arbeidskataloger synlige mens agenter eller operatører driver virkelig arbeid fremover.",
        },
      ],
    },
    why: {
      eyebrow: "Hvorfor lander det annerledes",
      title: "Den raskeste veien fra noen få brukersvinger til en ekte utførelsesflate.",
      items: [
        "Filer forblir ved siden av den aktive terminalen i stedet for å gjemme seg bak en egen app.",
        "Eksterne verter bruker samme utforsker og redigeringsarbeidsflyt som lokale prosjekter.",
        "Kildekontroll og prosjektkontekst forblir synlige mens endringer skjer.",
        "Supervisor-modus rammer inn neste trekk uten å tvinge frem et tungvektsoppsettsritual.",
      ],
    },
    profile: {
      eyebrow: "Produktprofil",
      items: [
        {
          label: "Gjengivelse",
          value: "Ghostty-klasse terminalmotor med en naturlig macOS skalloverflate.",
        },
        {
          label: "Overflatemodell",
          value: "Arbeidsområde-første layout med filer, nettleseroppgaver og ekstern tilstand i visning.",
        },
        {
          label: "Automatisering",
          value: "Supervisor, nettleserkontroll, CLI-kompatibilitet og oppgaveklar kontekstkomprimering.",
        },
        {
          label: "Utløserlinje",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Arbeidsflyt",
      title: "Zero-config der den skal være. Eksplisitt kontroll der det betyr noe.",
      body:
        "Produktfilosofien er enkel: konkluder først, spør deretter. Du bør kunne åpne et prosjekt, koble til en vert og begynne å bevege deg før du blir begravet i oppsettpaneler.",
      items: [
        {
          step: "01",
          title: "Åpne et arbeidsområde",
          body:
            "Pek icc på en lokal repo eller koble til et SSH mål. Null-konfigurasjonsflyt antyder nok struktur til å begynne umiddelbart.",
        },
        {
          step: "02",
          title: "Les arbeidsflaten",
          body:
            "Terminaltilstand, filer, Git-kontekst, eksterne stier og nylige interaksjonsnotater forblir synlige i samme kommandostokk.",
        },
        {
          step: "03",
          title: "La veilederen ramme neste trekk",
          body:
            "icc kan komprimere gjeldende kontekst til en oppstartsplan, utførelsesanvisning eller operatøroverlevering uten å gjøre arbeidsflyten om til en seremoni.",
        },
        {
          step: "04",
          title: "Utfør uten å miste kontekst",
          body:
            "Bla gjennom filer, rediger kode, inspiser utdata og flytt mellom lokale og eksterne mål mens samtalen forblir forankret.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Direkte svar på det folk spør først.",
      body: "Produktet forblir oppfattet om arbeidsflytkvalitet, samtidig som det er praktisk å ta i bruk.",
      items: [
        {
          q: "Er icc bare en Ghostty gaffel?",
          a:
            "Nei. icc er et innfødt macOS kommandosenter bygget på Ghostty-grade terminalgjengivelse. Produktet utvider dette grunnlaget med utforskere, redigering, nettleserkjøring, tilsyn og orkestrering av arbeidsområde.",
        },
        {
          q: "Hvem er icc for?",
          a:
            "Operatører, ingeniører, grunnleggere og superbrukere som allerede kjører flere AI-assisterte arbeidsflyter og ønsker én skarpere kontrollflate i stedet for mer vindusspredning.",
        },
        {
          q: "Hva gjør arbeidsflyten annerledes?",
          a:
            "icc holder terminalen førsteklasses mens den legger til de manglende overflatene rundt den: filer, eksterne verter, kildekontroll, nettleserkontekst og en utførelsesfokusert veileder.",
        },
        {
          q: "Støtter den fjernarbeid?",
          a:
            "Ja. icc leser SSH-konfigurasjon, kobler til eksterne mål og viser eksterne filer i den samme utforskermodellen som brukes for lokalt arbeid.",
        },
      ],
    },
    cta: {
      eyebrow: "Start icc",
      title: "Gå fra hensikt til utførelse uten å miste formen på arbeidet.",
      body:
        "Last ned gjeldende macOS build eller spor utgivelser og kilde på GitHub. Det offentlige nettstedet, utgivelseslinjen og depotet er nå justert til én identitet: icc.",
    },
    footer: {
      blurb:
        "Innebygde Swift og AppKit. Ghostty-grad gjengivelse. Lokal og ekstern kontekst, filoperasjoner, nettleserkjøring, kildekontroll og overvåking i ett arbeidsområde først av operatøren.",
      explore: "Utforsk",
      release: "Slipp",
      capabilities: "Evner",
      workflow: "Arbeidsflyt",
      faq: "FAQ",
      download: "Last ned for macOS",
      releases: "Utgivelser",
      repository: "GitHub Repository",
      support: "Support / problemer",
      copyright: "© {year} icc. Én cockpit for terminal-first AI utførelse.",
    },
  },
  "pt-BR": {
    metaTitle: "icc — AI Centro de Comando para macOS",
    metaDescription:
      "icc é um centro de comando macOS nativo para trabalhos sérios de AI. Ele combina renderização de terminal de nível Ghostty, exploração de arquivos locais e remotos, edição no aplicativo, execução do navegador, visibilidade de controle de origem e uma camada de supervisor em um espaço de trabalho focado.",
    descriptor: "AI Centro de Comando para macOS",
    tagline: "Um cockpit para execução AI do terminal primeiro.",
    eyebrow: "Site oficial",
    heroDescription:
      "icc é um centro de comando macOS nativo para trabalhos sérios de AI. Mantenha a execução do terminal, os arquivos locais e remotos, o controle de origem, as tarefas do navegador e as próximas etapas orientadas pelo supervisor em um espaço de trabalho deliberado.",
    buttons: {
      download: "Baixar para macOS",
      github: "Ver em GitHub",
    },
    header: {
      capabilities: "Capacidades",
      workflow: "Fluxo de trabalho",
      faq: "FAQ",
      github: "GitHub",
      language: "Idioma",
      toggleTheme: "Alternar tema",
      openMenu: "Abrir menu",
      closeMenu: "Fechar menu",
    },
    heroCards: [
      {
        label: "Plataforma",
        title: "Nativo macOS",
        body: "Renderização de grau Swift, AppKit, Ghostty.",
      },
      {
        label: "Espaço de trabalho",
        title: "Local + remoto",
        body: "Um modelo para projetos, destinos SSH e arquivos.",
      },
      {
        label: "Estilo operacional",
        title: "Configuração zero primeiro",
        body: "Inferir o contexto antecipadamente, expor os controles somente quando necessário.",
      },
    ],
    preview: {
      workspace: "espaço de trabalho: /Usuários/operador/trabalho/icc",
      rail: "Trilho",
      railItems: ["terminal / construção", "repositório / icc", "remoto / prod-ssh", "navegador / revisão"],
      terminal: "Conversa terminal",
      ready: "pronto",
      lines: [
        "$ icc connect prod-ssh",
        "Conectado. Lendo o espaço de trabalho remoto e o estado do shell.",
        "$ git status --short",
        "MSources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Caminhos, arquivos, árvore remota e próxima ação permanecem visíveis juntos.",
      ],
      supervisor: "Supervisor",
      status: "Estado",
      statusReady: "Pronto para continuar",
      statusBody: "Meta inferida do repositório atual, arquivos e histórico de tarefas recentes.",
      files: "Arquivos",
      filesBody: "Abra, inspecione, edite e salve sem sair do espaço de trabalho.",
      remote: "Remoto",
      remoteBody: "Navegação apoiada por SSH, mesmo layout, mesmo tratamento de caminho.",
    },
    capabilities: {
      eyebrow: "Capacidades",
      title: "Criado para operadores que desejam que o contexto fique visível enquanto o trabalho está acontecendo.",
      body:
        "icc não é outro painel do navegador colocado em cima de um terminal. É um centro de comando que mantém execução, arquivos, estado remoto e orientação na mesma superfície de trabalho.",
      items: [
        {
          title: "Execução primeiro no terminal",
          body:
            "Execute um trabalho sério de AI em uma superfície de shell macOS nativa, em vez de alternar entre wrappers e guias de navegador desanexadas.",
        },
        {
          title: "Exploradores locais e remotos",
          body:
            "Navegue por projetos locais e hosts conectados ao SSH no mesmo espaço de trabalho, usando o mesmo modelo mental e o mesmo plano de controle do lado direito.",
        },
        {
          title: "Edição de arquivos no aplicativo",
          body:
            "Abra, inspecione, edite e salve arquivos sem interromper o fluxo do terminal. Arraste caminhos diretamente para a conversa ativa quando necessário.",
        },
        {
          title: "Modo supervisor",
          body:
            "Transforme algumas linhas de intenção do usuário, contexto do projeto e trabalho recente em um resumo de execução concreto com próximas etapas delimitadas.",
        },
        {
          title: "Navegador e automação",
          body:
            "Mantenha as tarefas baseadas no navegador ao lado do terminal e exponha-as ao mesmo fluxo de trabalho do operador, em vez de fazer malabarismos com ferramentas separadas.",
        },
        {
          title: "Visibilidade do controle de origem",
          body:
            "Mantenha o estado do Git, o contexto do repositório e os diretórios de trabalho visíveis enquanto os agentes ou operadores impulsionam o trabalho real.",
        },
      ],
    },
    why: {
      eyebrow: "Por que pousa de forma diferente",
      title: "O caminho mais rápido de alguns usuários se transforma em uma superfície de execução real.",
      items: [
        "Os arquivos ficam ao lado do terminal ativo em vez de ficarem escondidos atrás de um aplicativo separado.",
        "Os hosts remotos usam o mesmo explorador e fluxo de trabalho de edição que os projetos locais.",
        "O controle de origem e o contexto do projeto permanecem visíveis enquanto as mudanças acontecem.",
        "O modo Supervisor enquadra o próximo movimento sem forçar um ritual de configuração pesado.",
      ],
    },
    profile: {
      eyebrow: "Perfil do produto",
      items: [
        {
          label: "Renderização",
          value: "Mecanismo de terminal de grau Ghostty com uma superfície de shell macOS nativa.",
        },
        {
          label: "Modelo de superfície",
          value: "Layout que prioriza o espaço de trabalho com arquivos, tarefas do navegador e estado remoto à vista.",
        },
        {
          label: "Automação",
          value: "Supervisor, controle de navegador, compatibilidade CLI e compactação de contexto pronta para tarefas.",
        },
        {
          label: "Linha de lançamento",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "Fluxo de trabalho",
      title: "Configuração zero onde deveria estar. Controle explícito onde for importante.",
      body:
        "A filosofia do produto é simples: inferir primeiro, perguntar depois. Você deve ser capaz de abrir um projeto, conectar um host e começar a se mover antes de ficar enterrado nos painéis de configuração.",
      items: [
        {
          step: "01",
          title: "Abra um espaço de trabalho",
          body:
            "Aponte icc para um repositório local ou conecte um destino SSH. O fluxo de configuração zero infere estrutura suficiente para começar imediatamente.",
        },
        {
          step: "02",
          title: "Leia a superfície de trabalho",
          body:
            "O estado do terminal, os arquivos, o contexto do Git, os caminhos remotos e as notas de interação recentes permanecem visíveis no mesmo conjunto de comandos.",
        },
        {
          step: "03",
          title: "Deixe o supervisor definir o próximo passo",
          body:
            "icc pode compactar o contexto atual em um plano de inicialização, resumo de execução ou transferência do operador sem transformar o fluxo de trabalho em cerimônia.",
        },
        {
          step: "04",
          title: "Execute sem perder contexto",
          body:
            "Navegue por arquivos, edite código, inspecione a saída e mova-se entre destinos locais e remotos enquanto a conversa permanece ancorada.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "Respostas diretas para o que as pessoas perguntam primeiro.",
      body: "O produto permanece opinativo sobre a qualidade do fluxo de trabalho, ao mesmo tempo que permanece prático de adotar.",
      items: [
        {
          q: "icc é apenas um garfo Ghostty?",
          a:
            "Não. icc é um centro de comando macOS nativo construído em renderização de terminal de nível Ghostty. O produto expande essa base com exploradores, edição, execução de navegador, supervisão e orquestração de espaço de trabalho.",
        },
        {
          q: "Para quem é icc?",
          a:
            "Operadores, engenheiros, fundadores e usuários avançados que já executam vários fluxos de trabalho assistidos por AI e desejam uma superfície de controle mais nítida em vez de mais janelas espalhadas.",
        },
        {
          q: "O que torna o fluxo de trabalho diferente?",
          a:
            "icc mantém o terminal de primeira classe enquanto adiciona as superfícies que faltam ao seu redor: arquivos, hosts remotos, controle de origem, contexto do navegador e um supervisor focado na execução.",
        },
        {
          q: "Suporta trabalho remoto?",
          a:
            "Sim. icc lê a configuração de SSH, conecta-se a destinos remotos e expõe arquivos remotos no mesmo modelo de explorador usado para trabalho local.",
        },
      ],
    },
    cta: {
      eyebrow: "Lançar icc",
      title: "Passe da intenção à execução sem perder a forma do trabalho.",
      body:
        "Baixe a versão atual do macOS ou acompanhe os lançamentos e fontes em GitHub. O site público, a linha de lançamento e o repositório agora estão alinhados a uma identidade: icc.",
    },
    footer: {
      blurb:
        "Swift e AppKit nativos. Renderização de grau Ghostty. Contexto local e remoto, operações de arquivo, execução de navegador, controle de origem e supervisão em um espaço de trabalho onde o operador prioriza.",
      explore: "Explorar",
      release: "Liberar",
      capabilities: "Capacidades",
      workflow: "Fluxo de trabalho",
      faq: "FAQ",
      download: "Baixar para macOS",
      releases: "Lançamentos",
      repository: "GitHub Repositório",
      support: "Suporte/Problemas",
      copyright: "© {year} icc. Um cockpit para execução AI do terminal primeiro.",
    },
  },
  "th": {
    metaTitle: "icc — AI ศูนย์บัญชาการสำหรับ macOS",
    metaDescription:
      "icc เป็นศูนย์บัญชาการ macOS ดั้งเดิมสำหรับการทำงาน AI ที่จริงจัง โดยผสมผสานการเรนเดอร์เทอร์มินัลเกรด Ghostty การสำรวจไฟล์ในเครื่องและระยะไกล การแก้ไขในแอป การดำเนินการของเบราว์เซอร์ การมองเห็นการควบคุมแหล่งที่มา และเลเยอร์หัวหน้างานในพื้นที่ทำงานที่มุ่งเน้นที่เดียว",
    descriptor: "AI ศูนย์บัญชาการสำหรับ macOS",
    tagline: "ห้องนักบินหนึ่งห้องสำหรับการดำเนินการ AI ก่อนเทอร์มินัล",
    eyebrow: "เว็บไซต์อย่างเป็นทางการ",
    heroDescription:
      "icc เป็นศูนย์บัญชาการ macOS ดั้งเดิมสำหรับการทำงาน AI ที่จริงจัง เก็บการดำเนินการเทอร์มินัล ไฟล์ในเครื่องและระยะไกล การควบคุมแหล่งที่มา งานเบราว์เซอร์ และขั้นตอนถัดไปที่ขับเคลื่อนโดยหัวหน้างานไว้ในพื้นที่ทำงานที่ตั้งใจไว้แห่งเดียว",
    buttons: {
      download: "ดาวน์โหลดสำหรับ macOS",
      github: "ดูบน GitHub",
    },
    header: {
      capabilities: "ความสามารถ",
      workflow: "ขั้นตอนการทำงาน",
      faq: "FAQ",
      github: "GitHub",
      language: "ภาษา",
      toggleTheme: "สลับธีม",
      openMenu: "เปิดเมนู",
      closeMenu: "ปิดเมนู",
    },
    heroCards: [
      {
        label: "แพลตฟอร์ม",
        title: "พื้นเมือง macOS",
        body: "Swift, AppKit, Ghostty-การเรนเดอร์เกรด",
      },
      {
        label: "พื้นที่ทำงาน",
        title: "ท้องถิ่น + ระยะไกล",
        body: "หนึ่งโมเดลสำหรับโปรเจ็กต์ SSH เป้าหมาย และไฟล์",
      },
      {
        label: "รูปแบบการดำเนินงาน",
        title: "กำหนดค่าเป็นศูนย์ก่อน",
        body: "อนุมานบริบทตั้งแต่เนิ่นๆ เปิดเผยการควบคุมเมื่อจำเป็นเท่านั้น",
      },
    ],
    preview: {
      workspace: "พื้นที่ทำงาน: /Users/operator/work/icc",
      rail: "ราว",
      railItems: ["เทอร์มินัล / บิลด์", "ซื้อคืน / icc", "รีโมท / prod-ssh", "เบราว์เซอร์ / บทวิจารณ์"],
      terminal: "บทสนทนาเทอร์มินัล",
      ready: "พร้อม",
      lines: [
        "$ icc connect prod-ssh",
        "เชื่อมต่อแล้ว การอ่านพื้นที่ทำงานระยะไกลและสถานะเชลล์",
        "$ git status --short",
        "ม Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "เส้นทาง ไฟล์ แผนผังระยะไกล และการดำเนินการถัดไปจะยังคงมองเห็นร่วมกัน",
      ],
      supervisor: "หัวหน้างาน",
      status: "สถานะ",
      statusReady: "พร้อมลุยต่อ",
      statusBody: "เป้าหมายที่อนุมานจาก repo ปัจจุบัน ไฟล์ และประวัติงานล่าสุด",
      files: "ไฟล์",
      filesBody: "เปิด ตรวจสอบ แก้ไข และบันทึกโดยไม่ต้องออกจากพื้นที่ทำงาน",
      remote: "ระยะไกล",
      remoteBody: "SSH-การเรียกดูที่ได้รับการสนับสนุน รูปแบบเดียวกัน การจัดการเส้นทางเดียวกัน",
    },
    capabilities: {
      eyebrow: "ความสามารถ",
      title: "สร้างขึ้นสำหรับผู้ปฏิบัติงานที่ต้องการให้บริบทปรากฏในขณะที่งานกำลังดำเนินอยู่",
      body:
        "icc ไม่ใช่แดชบอร์ดของเบราว์เซอร์อื่นที่อยู่ด้านบนของเทอร์มินัล เป็นศูนย์สั่งการที่เก็บการดำเนินการ ไฟล์ สถานะระยะไกล และคำแนะนำไว้ในพื้นที่การทำงานเดียวกัน",
      items: [
        {
          title: "การดำเนินการเทอร์มินัลครั้งแรก",
          body:
            "รัน AI อย่างจริงจังในพื้นผิวเชลล์ macOS ดั้งเดิม แทนที่จะตีกลับระหว่าง wrappers และแท็บเบราว์เซอร์ที่แยกออกมา",
        },
        {
          title: "นักสำรวจในพื้นที่และระยะไกล",
          body:
            "เรียกดูโปรเจ็กต์ในพื้นที่และโฮสต์ที่เชื่อมต่อ SSH จากพื้นที่ทำงานเดียวกัน โดยใช้โมเดลทางจิตเดียวกันและระนาบควบคุมด้านขวาเดียวกัน",
        },
        {
          title: "การแก้ไขไฟล์ในแอป",
          body:
            "เปิด ตรวจสอบ แก้ไข และบันทึกไฟล์โดยไม่ทำให้โฟลว์ของเทอร์มินัลเสียหาย ลากเส้นทางเข้าสู่การสนทนาที่ใช้งานอยู่โดยตรงเมื่อจำเป็น",
        },
        {
          title: "โหมดหัวหน้างาน",
          body:
            "เปลี่ยนความตั้งใจของผู้ใช้ บริบทของโครงการ และงานล่าสุดเพียงไม่กี่บรรทัดให้เป็นบทสรุปการดำเนินการที่เป็นรูปธรรมโดยมีขอบเขตขั้นตอนถัดไป",
        },
        {
          title: "เบราว์เซอร์และระบบอัตโนมัติ",
          body:
            "เก็บงานที่ได้รับการสนับสนุนจากเบราว์เซอร์ไว้ข้างเทอร์มินัลและเปิดเผยงานเหล่านั้นในเวิร์กโฟลว์ของผู้ปฏิบัติงานเดียวกัน แทนที่จะต้องใช้เครื่องมือที่แยกจากกัน",
        },
        {
          title: "การมองเห็นการควบคุมแหล่งที่มา",
          body:
            "คงสถานะ Git บริบท repo และไดเร็กทอรีการทำงานให้มองเห็นได้ ในขณะที่ตัวแทนหรือผู้ปฏิบัติงานกำลังผลักดันงานจริงไปข้างหน้า",
        },
      ],
    },
    why: {
      eyebrow: "ทำไมมันถึงแตกต่างออกไป",
      title: "เส้นทางที่เร็วที่สุดจากผู้ใช้เพียงไม่กี่คนจะเปลี่ยนไปสู่พื้นที่ดำเนินการจริง",
      items: [
        "ไฟล์จะอยู่ข้างเทอร์มินัลที่ใช้งานอยู่แทนที่จะซ่อนอยู่หลังแอปแยกต่างหาก",
        "โฮสต์ระยะไกลใช้โปรแกรมสำรวจและเวิร์กโฟลว์การแก้ไขเดียวกันกับโปรเจ็กต์ในเครื่อง",
        "การควบคุมแหล่งที่มาและบริบทของโครงการยังคงมองเห็นได้ในขณะที่มีการเปลี่ยนแปลงเกิดขึ้น",
        "โหมดหัวหน้างานกำหนดกรอบการเคลื่อนไหวครั้งต่อไปโดยไม่ต้องบังคับให้ต้องตั้งค่าแบบเฮฟวี่เวท",
      ],
    },
    profile: {
      eyebrow: "รายละเอียดผลิตภัณฑ์",
      items: [
        {
          label: "กำลังแสดงผล",
          value: "เครื่องยนต์เทอร์มินัลเกรด Ghostty ที่มีพื้นผิวเปลือก macOS ดั้งเดิม",
        },
        {
          label: "แบบจำลองพื้นผิว",
          value: "เค้าโครงที่เน้นพื้นที่ทำงานเป็นหลักพร้อมไฟล์ งานเบราว์เซอร์ และสถานะระยะไกลในมุมมอง",
        },
        {
          label: "ระบบอัตโนมัติ",
          value: "หัวหน้างาน การควบคุมเบราว์เซอร์ ความเข้ากันได้ CLI และการบีบอัดบริบทที่พร้อมสำหรับงาน",
        },
        {
          label: "สายปล่อย",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "ขั้นตอนการทำงาน",
      title: "Zero-config ในจุดที่ควรจะเป็น การควบคุมที่ชัดเจนในจุดที่สำคัญ",
      body:
        "ปรัชญาผลิตภัณฑ์นั้นเรียบง่าย: อนุมานก่อน ถามเป็นอันดับสอง คุณควรจะสามารถเปิดโปรเจ็กต์ เชื่อมต่อโฮสต์ และเริ่มดำเนินการได้ก่อนที่คุณจะถูกฝังอยู่ในแผงการตั้งค่า",
      items: [
        {
          step: "01",
          title: "เปิดพื้นที่ทำงาน",
          body:
            "ชี้ icc ไปที่ repo ในพื้นที่หรือเชื่อมต่อเป้าหมาย SSH โฟลว์การกำหนดค่าเป็นศูนย์อนุมานโครงสร้างเพียงพอที่จะเริ่มต้นได้ทันที",
        },
        {
          step: "02",
          title: "อ่านพื้นผิวการทำงาน",
          body:
            "สถานะเทอร์มินัล ไฟล์ บริบท Git เส้นทางระยะไกล และบันทึกการโต้ตอบล่าสุดจะยังคงมองเห็นได้ในชุดคำสั่งเดียวกัน",
        },
        {
          step: "03",
          title: "ให้ผู้บังคับบัญชาวางกรอบการเคลื่อนไหวครั้งต่อไป",
          body:
            "icc สามารถบีบอัดบริบทปัจจุบันให้เป็นแผนเริ่มต้น สรุปการดำเนินการ หรือแฮนด์ออฟของผู้ปฏิบัติงาน โดยไม่ต้องเปลี่ยนเวิร์กโฟลว์เป็นพิธีการ",
        },
        {
          step: "04",
          title: "ดำเนินการโดยไม่สูญเสียบริบท",
          body:
            "เรียกดูไฟล์ แก้ไขโค้ด ตรวจสอบเอาต์พุต และย้ายระหว่างเป้าหมายภายในและระยะไกลในขณะที่การสนทนายังคงยึดอยู่",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "คำตอบโดยตรงสำหรับสิ่งที่ผู้คนถามก่อน",
      body: "ผลิตภัณฑ์ยังคงให้ความสำคัญกับคุณภาพของเวิร์กโฟลว์ ในขณะที่ยังคงนำไปใช้ได้จริง",
      items: [
        {
          q: "icc เป็นเพียงทางแยกของ Ghostty หรือไม่",
          a:
            "ไม่ icc เป็นศูนย์คำสั่งดั้งเดิม macOS ที่สร้างขึ้นบนการเรนเดอร์เทอร์มินัลระดับ Ghostty ผลิตภัณฑ์ขยายรากฐานดังกล่าวด้วยนักสำรวจ การแก้ไข การดำเนินการเบราว์เซอร์ การควบคุมดูแล และการจัดการพื้นที่ทำงาน",
        },
        {
          q: "icc เหมาะกับใคร?",
          a:
            "ผู้ปฏิบัติงาน วิศวกร ผู้ก่อตั้ง และผู้ใช้ระดับสูงที่ใช้งานเวิร์กโฟลว์ที่ได้รับความช่วยเหลือจาก AI หลายรายการอยู่แล้ว และต้องการพื้นผิวการควบคุมที่คมชัดยิ่งขึ้นแทนที่จะขยายหน้าต่างให้กว้างขึ้น",
        },
        {
          q: "อะไรทำให้ขั้นตอนการทำงานแตกต่าง?",
          a:
            "icc ช่วยให้เทอร์มินัลมีระดับเฟิร์สคลาสในขณะที่เพิ่มพื้นผิวที่ขาดหายไปรอบๆ เช่น ไฟล์ โฮสต์ระยะไกล การควบคุมแหล่งที่มา บริบทของเบราว์เซอร์ และผู้ดูแลที่มุ่งเน้นการดำเนินการ",
        },
        {
          q: "รองรับการทำงานระยะไกลหรือไม่?",
          a:
            "ใช่. icc อ่านการกำหนดค่า SSH เชื่อมต่อกับเป้าหมายระยะไกล และเปิดเผยไฟล์ระยะไกลในรูปแบบ explorer เดียวกันกับที่ใช้สำหรับงานในพื้นที่",
        },
      ],
    },
    cta: {
      eyebrow: "เปิดตัว icc",
      title: "ย้ายจากความตั้งใจไปสู่การปฏิบัติโดยไม่สูญเสียรูปทรงของงาน",
      body:
        "ดาวน์โหลด macOS บิลด์หรือติดตามการเผยแพร่และแหล่งที่มาปัจจุบันบน GitHub ขณะนี้ไซต์สาธารณะ บรรทัดเผยแพร่ และพื้นที่เก็บข้อมูลสอดคล้องกับข้อมูลประจำตัวเดียว: icc",
    },
    footer: {
      blurb:
        "พื้นเมือง Swift และ AppKit Ghostty-การเรนเดอร์เกรด บริบทภายในและระยะไกล การทำงานของไฟล์ การทำงานของเบราว์เซอร์ การควบคุมแหล่งที่มา และการควบคุมดูแลในพื้นที่ทำงานที่คำนึงถึงผู้ปฏิบัติงานเป็นหลัก",
      explore: "สำรวจ",
      release: "ปล่อย",
      capabilities: "ความสามารถ",
      workflow: "ขั้นตอนการทำงาน",
      faq: "FAQ",
      download: "ดาวน์โหลดสำหรับ macOS",
      releases: "ข่าวประชาสัมพันธ์",
      repository: "GitHub พื้นที่เก็บข้อมูล",
      support: "การสนับสนุน / ปัญหา",
      copyright: "© {year} icc. ห้องนักบินหนึ่งห้องสำหรับการดำเนินการ AI ก่อนเทอร์มินัล",
    },
  },
  "tr": {
    metaTitle: "icc — AI macOS için Komuta Merkezi",
    metaDescription:
      "icc, ciddi AI işlerine yönelik yerel bir macOS komuta merkezidir. Ghostty düzeyinde terminal oluşturmayı, yerel ve uzaktan dosya incelemeyi, uygulama içi düzenlemeyi, tarayıcı yürütmeyi, kaynak kontrolü görünürlüğünü ve bir denetleyici katmanını odaklanmış tek bir çalışma alanında birleştirir.",
    descriptor: "AI macOS için Komuta Merkezi",
    tagline: "Terminal öncelikli AI uygulaması için bir kokpit.",
    eyebrow: "Resmi site",
    heroDescription:
      "icc, ciddi AI işlerine yönelik yerel bir macOS komuta merkezidir. Terminal yürütmeyi, yerel ve uzak dosyaları, kaynak kontrolünü, tarayıcı görevlerini ve yönetici odaklı sonraki adımları tek bir kasıtlı çalışma alanında tutun.",
    buttons: {
      download: "macOS için indirin",
      github: "GitHub tarihinde görüntüle",
    },
    header: {
      capabilities: "Yetenekler",
      workflow: "İş akışı",
      faq: "FAQ",
      github: "GitHub",
      language: "Dil",
      toggleTheme: "Temayı değiştir",
      openMenu: "Menüyü aç",
      closeMenu: "Menüyü kapat",
    },
    heroCards: [
      {
        label: "platformu",
        title: "Yerel macOS",
        body: "Swift, AppKit, Ghostty dereceli oluşturma.",
      },
      {
        label: "Çalışma alanı",
        title: "Yerel + uzak",
        body: "Projeler, SSH hedefler ve dosyalar için tek model.",
      },
      {
        label: "Çalışma tarzı",
        title: "İlk önce sıfır yapılandırma",
        body: "Bağlamı erkenden çıkarın, kontrolleri yalnızca gerektiğinde ortaya çıkarın.",
      },
    ],
    preview: {
      workspace: "çalışma alanı: /Kullanıcılar/operatör/iş/icc",
      rail: "Demiryolu",
      railItems: ["terminal / yapı", "depo / icc", "uzak / prod-ssh", "tarayıcı / inceleme"],
      terminal: "Terminal görüşmesi",
      ready: "hazır",
      lines: [
        "$ icc connect prod-ssh",
        "Bağlı. Uzak çalışma alanı ve kabuk durumu okunuyor.",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "Yollar, dosyalar, uzak ağaç ve sonraki eylem birlikte görünür durumda kalır.",
      ],
      supervisor: "Süpervizör",
      status: "Durum",
      statusReady: "Devam etmeye hazır",
      statusBody: "Hedef, mevcut depodan, dosyalardan ve son görev geçmişinden çıkarılır.",
      files: "Dosyalar",
      filesBody: "Çalışma alanından ayrılmadan açın, inceleyin, düzenleyin ve kaydedin.",
      remote: "Uzaktan",
      remoteBody: "SSH destekli tarama, aynı düzen, aynı yol işleme.",
    },
    capabilities: {
      eyebrow: "Yetenekler",
      title: "Çalışma sırasında bağlamın görünür olmasını isteyen operatörler için tasarlandı.",
      body:
        "icc bir terminalin üstünde bulunan başka bir tarayıcı kontrol paneli değildir. Yürütme, dosyalar, uzak durum ve yönlendirmeyi aynı çalışma yüzeyinde tutan bir komuta merkezidir.",
      items: [
        {
          title: "Terminal-ilk yürütme",
          body:
            "Sarmalayıcılar ve ayrı tarayıcı sekmeleri arasında geçiş yapmak yerine, yerel bir macOS kabuk yüzeyinde ciddi AI çalışmaları çalıştırın.",
        },
        {
          title: "Yerel ve uzak kaşifler",
          body:
            "Aynı zihinsel modeli ve aynı sağ taraftaki kontrol düzlemini kullanarak, aynı çalışma alanından yerel projelere ve SSH bağlantılı ana bilgisayarlara göz atın.",
        },
        {
          title: "Uygulama içi dosya düzenleme",
          body:
            "Terminal akışını bozmadan dosyaları açın, inceleyin, düzenleyin ve kaydedin. Gerektiğinde yolları doğrudan etkin konuşmaya sürükleyin.",
        },
        {
          title: "Yönetici modu",
          body:
            "Birkaç satırlık kullanıcı amacını, proje içeriğini ve son çalışmayı sınırlı sonraki adımlarla somut bir uygulama özetine dönüştürün.",
        },
        {
          title: "Tarayıcı ve otomasyon",
          body:
            "Tarayıcı destekli görevleri terminalin yanında tutun ve ayrı araçlarla uğraşmak yerine bunları aynı operatör iş akışına maruz bırakın.",
        },
        {
          title: "Kaynak kontrolü görünürlüğü",
          body:
            "Aracılar veya operatörler gerçek işi ileriye taşırken Git durumunu, repo bağlamını ve çalışma dizinlerini görünür tutun.",
        },
      ],
    },
    why: {
      eyebrow: "Neden farklı iniyor?",
      title: "Birkaç kullanıcının en hızlı yolu gerçek bir uygulama yüzeyine dönüşür.",
      items: [
        "Dosyalar ayrı bir uygulamanın arkasına saklanmak yerine etkin terminalin yanında kalır.",
        "Uzak ana bilgisayarlar, yerel projelerle aynı gezgini ve düzenleme iş akışını kullanır.",
        "Değişiklikler olurken kaynak kontrolü ve proje içeriği görünür kalır.",
        "Yönetici modu, ağır bir kurulum ritüelini zorlamadan bir sonraki hareketi çerçeveler.",
      ],
    },
    profile: {
      eyebrow: "Ürün profili",
      items: [
        {
          label: "İşleme",
          value: "Yerel macOS kabuk yüzeyine sahip Ghostty dereceli terminal motoru.",
        },
        {
          label: "Yüzey modeli",
          value: "Dosyalar, tarayıcı görevleri ve uzak durum görünümüyle çalışma alanına öncelik veren düzen.",
        },
        {
          label: "Otomasyon",
          value: "Yönetici, tarayıcı kontrolü, CLI uyumluluğu ve göreve hazır içerik sıkıştırma.",
        },
        {
          label: "Yayın hattı",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "İş akışı",
      title: "Olması gerektiği yerde sıfır yapılandırma. Önemli olduğu yerde açık kontrol.",
      body:
        "Ürün felsefesi basittir: önce çıkarım yapın, sonra sorun. Kurulum panellerine gömülmeden önce bir proje açabilmeniz, bir ana bilgisayara bağlanabilmeniz ve hareket etmeye başlayabilmeniz gerekir.",
      items: [
        {
          step: "01",
          title: "Bir çalışma alanı açın",
          body:
            "icc öğesini yerel bir depoya yönlendirin veya bir SSH hedefi bağlayın. Sıfır yapılandırma akışı, hemen başlamak için yeterli yapı anlamına gelir.",
        },
        {
          step: "02",
          title: "Çalışma yüzeyini okuyun",
          body:
            "Terminal durumu, dosyalar, Git bağlamı, uzak yollar ve son etkileşim notları aynı komut kümesinde görünür kalır.",
        },
        {
          step: "03",
          title: "Denetçinin bir sonraki hamleyi çerçevelemesine izin verin",
          body:
            "icc, iş akışını törene dönüştürmeden mevcut bağlamı bir başlangıç planına, yürütme özetine veya operatör devrine sıkıştırabilir.",
        },
        {
          step: "04",
          title: "Bağlamı kaybetmeden yürütün",
          body:
            "Görüşme sabit kalırken dosyalara göz atın, kodu düzenleyin, çıktıyı inceleyin ve yerel ve uzak hedefler arasında geçiş yapın.",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "İnsanların ilk sordukları sorulara doğrudan yanıtlar.",
      body: "Ürün, benimsenmesi pratik kalırken iş akışı kalitesi konusunda sabit fikirli olmaya devam ediyor.",
      items: [
        {
          q: "icc yalnızca bir Ghostty çatalı mı?",
          a:
            "Hayır. icc, Ghostty düzeyinde terminal oluşturma temeline dayalı yerel bir macOS komuta merkezidir. Ürün, kaşifler, düzenleme, tarayıcı yürütme, denetim ve çalışma alanı düzenlemeyle bu temeli genişletiyor.",
        },
        {
          q: "icc kimin içindir?",
          a:
            "Halihazırda birden fazla AI destekli iş akışı çalıştıran ve daha fazla pencere yayılımı yerine daha keskin bir kontrol yüzeyi isteyen operatörler, mühendisler, kurucular ve uzman kullanıcılar.",
        },
        {
          q: "İş akışını farklı kılan nedir?",
          a:
            "icc, etrafındaki eksik yüzeyleri eklerken terminali birinci sınıf tutar: dosyalar, uzak ana bilgisayarlar, kaynak kontrolü, tarayıcı bağlamı ve yürütme odaklı bir denetleyici.",
        },
        {
          q: "Uzaktan çalışmayı destekliyor mu?",
          a:
            "Evet. icc, SSH yapılandırmasını okur, uzak hedeflere bağlanır ve uzak dosyaları, yerel çalışma için kullanılan aynı explorer modelinde açığa çıkarır.",
        },
      ],
    },
    cta: {
      eyebrow: "icc'ı başlat",
      title: "İşin şeklini kaybetmeden niyetten uygulamaya geçin.",
      body:
        "Geçerli macOS derlemesini indirin veya sürümleri ve kaynağı GitHub üzerinden izleyin. Genel site, sürüm satırı ve veri deposu artık tek bir kimliğe göre hizalanmıştır: icc.",
    },
    footer: {
      blurb:
        "Yerel Swift ve AppKit. Ghostty dereceli oluşturma. Operatörün öncelikli olduğu tek bir çalışma alanında yerel ve uzak bağlam, dosya işlemleri, tarayıcı yürütme, kaynak kontrolü ve denetim.",
      explore: "Keşfet",
      release: "Sürüm",
      capabilities: "Yetenekler",
      workflow: "İş akışı",
      faq: "FAQ",
      download: "macOS için indirin",
      releases: "Bültenler",
      repository: "GitHub Depo",
      support: "Destek / Sorunlar",
      copyright: "© {year} icc. Terminal öncelikli AI uygulaması için bir kokpit.",
    },
  },
  "km": {
    metaTitle: "icc — AI មជ្ឈមណ្ឌលបញ្ជាសម្រាប់ macOS",
    metaDescription:
      "icc គឺជាមជ្ឈមណ្ឌលបញ្ជាដើម macOS សម្រាប់ការងារធ្ងន់ធ្ងរ AI ។ វារួមបញ្ចូលគ្នានូវការបង្ហាញស្ថានីយកម្រិត Ghostty ការរុករកឯកសារក្នុងមូលដ្ឋាន និងពីចម្ងាយ ការកែសម្រួលក្នុងកម្មវិធី ការប្រតិបត្តិកម្មវិធីរុករកតាមអ៊ីនធឺណិត លទ្ធភាពមើលឃើញការគ្រប់គ្រងប្រភព និងស្រទាប់អ្នកគ្រប់គ្រងនៅក្នុងកន្លែងធ្វើការផ្តោតតែមួយ។",
    descriptor: "AI មជ្ឈមណ្ឌលបញ្ជាសម្រាប់ macOS",
    tagline: "កាប៊ីនយន្ដហោះមួយសម្រាប់ការប្រតិបត្តិស្ថានីយដំបូង AI ។",
    eyebrow: "គេហទំព័រផ្លូវការ",
    heroDescription:
      "icc គឺជាមជ្ឈមណ្ឌលបញ្ជាដើម macOS សម្រាប់ការងារធ្ងន់ធ្ងរ AI ។ រក្សាការប្រតិបត្តិស្ថានីយ ឯកសារមូលដ្ឋាន និងពីចម្ងាយ ការគ្រប់គ្រងប្រភព ភារកិច្ចកម្មវិធីរុករកតាមអ៊ីនធឺណិត និងជំហានបន្ទាប់ដែលដឹកនាំដោយអ្នកគ្រប់គ្រងនៅខាងក្នុងកន្លែងធ្វើការដោយចេតនាមួយ។",
    buttons: {
      download: "ទាញយកសម្រាប់ macOS",
      github: "មើលនៅលើ GitHub",
    },
    header: {
      capabilities: "សមត្ថភាព",
      workflow: "លំហូរការងារ",
      faq: "FAQ",
      github: "GitHub",
      language: "ភាសា",
      toggleTheme: "បិទបើកប្រធានបទ",
      openMenu: "បើកម៉ឺនុយ",
      closeMenu: "បិទម៉ឺនុយ",
    },
    heroCards: [
      {
        label: "វេទិកា",
        title: "ដើម macOS",
        body: "Swift, AppKit, Ghostty- ការបង្ហាញកម្រិត។",
      },
      {
        label: "កន្លែងធ្វើការ",
        title: "ក្នុងស្រុក + ពីចម្ងាយ",
        body: "គំរូមួយសម្រាប់គម្រោង SSH គោលដៅ និងឯកសារ។",
      },
      {
        label: "រចនាប័ទ្មប្រតិបត្តិការ",
        title: "Zero-config ជាមុនសិន",
        body: "បញ្ជូលបរិបទឱ្យបានឆាប់ បង្ហាញការគ្រប់គ្រងតែនៅពេលចាំបាច់។",
      },
    ],
    preview: {
      workspace: "កន្លែងធ្វើការ៖ /Users/operator/work/icc",
      rail: "ផ្លូវដែក",
      railItems: ["ស្ថានីយ / សាងសង់", "repo / icc", "ពីចម្ងាយ / prod-ssh", "កម្មវិធីរុករក / ពិនិត្យ"],
      terminal: "ការសន្ទនាស្ថានីយ",
      ready: "រួចរាល់",
      lines: [
        "$ icc connect prod-ssh",
        "បានភ្ជាប់។ ការអានកន្លែងធ្វើការពីចម្ងាយ និងស្ថានភាពសែល។",
        "$ git status --short",
        "M Sources/WorkspaceSupervisor.swift",
        "$ open file explorer",
        "ផ្លូវ ឯកសារ មែកធាងពីចម្ងាយ និងសកម្មភាពបន្ទាប់នៅតែអាចមើលឃើញជាមួយគ្នា។",
      ],
      supervisor: "អ្នកគ្រប់គ្រង",
      status: "ស្ថានភាព",
      statusReady: "រួចរាល់ដើម្បីបន្ត",
      statusBody: "គោលដៅ​ដែល​បាន​សន្និដ្ឋាន​ពី repo បច្ចុប្បន្ន ឯកសារ និង​ប្រវត្តិ​កិច្ចការ​ថ្មីៗ។",
      files: "ឯកសារ",
      filesBody: "បើក ពិនិត្យ កែសម្រួល និងរក្សាទុកដោយមិនចាកចេញពីកន្លែងធ្វើការ។",
      remote: "ពីចម្ងាយ",
      remoteBody: "SSH- ការរុករកដែលបានគាំទ្រ ប្លង់ដូចគ្នា ការគ្រប់គ្រងផ្លូវដូចគ្នា។",
    },
    capabilities: {
      eyebrow: "សមត្ថភាព",
      title: "បង្កើតឡើងសម្រាប់ប្រតិបត្តិករដែលចង់ឱ្យមើលឃើញបរិបទខណៈពេលដែលការងារកំពុងកើតឡើង។",
      body:
        "icc មិនមែនជាផ្ទាំងគ្រប់គ្រងកម្មវិធីរុករកផ្សេងទៀតដែលអង្គុយនៅលើកំពូលនៃស្ថានីយនោះទេ។ វាគឺជាមជ្ឈមណ្ឌលបញ្ជាដែលរក្សាការប្រតិបត្តិ ឯកសារ ស្ថានភាពពីចម្ងាយ និងការណែនាំក្នុងផ្ទៃការងារដូចគ្នា។",
      items: [
        {
          title: "ការប្រតិបត្តិដំបូងរបស់ស្ថានីយ",
          body:
            "ដំណើរការធ្ងន់ធ្ងរ AI ធ្វើការនៅក្នុងផ្ទៃសែល macOS ដើមជំនួសឱ្យការលោតរវាងរុំ និងផ្ទាំងកម្មវិធីរុករកដែលបានផ្ដាច់។",
        },
        {
          title: "អ្នករុករកក្នុងស្រុក និងពីចម្ងាយ",
          body:
            "រុករកគម្រោងក្នុងស្រុក និងម៉ាស៊ីនដែលបានភ្ជាប់ SSH ពីកន្លែងធ្វើការដូចគ្នា ដោយប្រើគំរូផ្លូវចិត្តដូចគ្នា និងយន្តហោះគ្រប់គ្រងផ្នែកខាងស្តាំដូចគ្នា។",
        },
        {
          title: "ការកែសម្រួលឯកសារក្នុងកម្មវិធី",
          body:
            "បើក ពិនិត្យ កែសម្រួល និងរក្សាទុកឯកសារដោយមិនបំបែកលំហូរស្ថានីយ។ អូសផ្លូវដោយផ្ទាល់ចូលទៅក្នុងការសន្ទនាសកម្មនៅពេលចាំបាច់។",
        },
        {
          title: "របៀបអ្នកគ្រប់គ្រង",
          body:
            "បង្វែរបន្ទាត់មួយចំនួននៃចេតនារបស់អ្នកប្រើ បរិបទគម្រោង និងការងារថ្មីៗទៅជាការសង្ខេបការប្រតិបត្តិជាក់ស្តែងជាមួយនឹងជំហានបន្ទាប់ដែលមានព្រំដែន។",
        },
        {
          title: "កម្មវិធីរុករកនិងស្វ័យប្រវត្តិកម្ម",
          body:
            "រក្សាកិច្ចការដែលគាំទ្រដោយកម្មវិធីរុករកតាមអ៊ីនធឺណិតនៅក្បែរស្ថានីយ ហើយបង្ហាញពួកវាទៅលំហូរការងាររបស់ប្រតិបត្តិករដូចគ្នា ជំនួសឱ្យការលេងឧបករណ៍ដាច់ដោយឡែក។",
        },
        {
          title: "ភាពមើលឃើញនៃការគ្រប់គ្រងប្រភព",
          body:
            "រក្សាស្ថានភាព Git បរិបទ repo និងថតការងារដែលអាចមើលឃើញខណៈពេលដែលភ្នាក់ងារ ឬប្រតិបត្តិករកំពុងជំរុញការងារពិតប្រាកដទៅមុខ។",
        },
      ],
    },
    why: {
      eyebrow: "ហេតុអ្វីបានជាវាខុសគ្នា",
      title: "ផ្លូវលឿនបំផុតពីអ្នកប្រើប្រាស់ពីរបីនាក់ប្រែទៅជាផ្ទៃប្រតិបត្តិពិតប្រាកដ។",
      items: [
        "ឯកសារស្ថិតនៅក្បែរស្ថានីយសកម្ម ជំនួសឱ្យការលាក់នៅពីក្រោយកម្មវិធីដាច់ដោយឡែក។",
        "ម៉ាស៊ីនពីចម្ងាយប្រើកម្មវិធីរុករកដូចគ្នា និងកែសម្រួលលំហូរការងារជាគម្រោងក្នុងស្រុក។",
        "ការគ្រប់គ្រងប្រភព និងបរិបទគម្រោងនៅតែអាចមើលឃើញ ខណៈពេលដែលការផ្លាស់ប្តូរកំពុងកើតឡើង។",
        "របៀប​អ្នក​ត្រួត​ពិនិត្យ​កំណត់​ការ​ផ្លាស់ទី​បន្ទាប់​ដោយ​មិន​បង្ខំ​ឱ្យ​មាន​ពិធី​រៀបចំ​ទម្ងន់​ធ្ងន់។",
      ],
    },
    profile: {
      eyebrow: "កម្រងព័ត៌មានផលិតផល",
      items: [
        {
          label: "ការបង្ហាញ",
          value: "ម៉ាស៊ីនស្ថានីយកម្រិត Ghostty ដែលមានផ្ទៃសែល macOS ដើម។",
        },
        {
          label: "ម៉ូដែលផ្ទៃ",
          value: "កន្លែងធ្វើការ - ប្លង់ដំបូងជាមួយឯកសារ ភារកិច្ចកម្មវិធីរុករក និងស្ថានភាពពីចម្ងាយក្នុងទិដ្ឋភាព។",
        },
        {
          label: "ស្វ័យប្រវត្តិកម្ម",
          value: "អ្នកគ្រប់គ្រង ការគ្រប់គ្រងកម្មវិធីរុករកតាមអ៊ីនធឺណិត ភាពឆបគ្នា CLI និងការបង្ហាប់បរិបទដែលត្រៀមរួចជាស្រេចក្នុងកិច្ចការ។",
        },
        {
          label: "បន្ទាត់ចេញផ្សាយ",
          value: releaseValue,
        },
      ],
    },
    workflow: {
      eyebrow: "លំហូរការងារ",
      title: "Zero-config កន្លែងដែលវាគួរតែនៅ។ ការត្រួតពិនិត្យច្បាស់លាស់កន្លែងដែលវាសំខាន់។",
      body:
        "ទស្សនវិជ្ជាផលិតផលគឺសាមញ្ញ៖ សន្និដ្ឋានដំបូងសួរទីពីរ។ អ្នក​គួរ​តែ​អាច​បើក​គម្រោង ភ្ជាប់​ម៉ាស៊ីន​មួយ និង​ចាប់​ផ្ដើម​ផ្លាស់ទី​មុន​ពេល​អ្នក​ត្រូវ​បាន​គេ​កប់​ក្នុង​ផ្ទាំង​រៀបចំ។",
      items: [
        {
          step: "០១",
          title: "បើកកន្លែងធ្វើការ",
          body:
            "ចំណុច icc នៅ repo មូលដ្ឋាន ឬភ្ជាប់គោលដៅ SSH ។ Zero-config flow បង្ហាញពីរចនាសម្ព័ន្ធគ្រប់គ្រាន់ដើម្បីចាប់ផ្តើមភ្លាមៗ។",
        },
        {
          step: "០២",
          title: "អានផ្ទៃការងារ",
          body:
            "ស្ថានភាពស្ថានីយ ឯកសារ បរិបទ Git ផ្លូវពីចម្ងាយ និងកំណត់ត្រាអន្តរកម្មថ្មីៗ នៅតែអាចមើលឃើញនៅក្នុងផ្ទាំងបញ្ជាដូចគ្នា។",
        },
        {
          step: "០៣",
          title: "ទុក​ឱ្យ​អ្នក​ត្រួត​ពិនិត្យ​ធ្វើ​ជា​ជំហាន​បន្ទាប់",
          body:
            "icc អាចបង្រួមបរិបទបច្ចុប្បន្នទៅក្នុងផែនការចាប់ផ្តើម ការសង្ខេបការប្រតិបត្តិ ឬការប្រគល់ប្រតិបត្តិករដោយមិនបង្វែរលំហូរការងារទៅជាពិធី។",
        },
        {
          step: "០៤",
          title: "ប្រតិបត្តិដោយមិនបាត់បង់បរិបទ",
          body:
            "រកមើលឯកសារ កែសម្រួលកូដ ពិនិត្យលទ្ធផល និងផ្លាស់ទីរវាងគោលដៅក្នុងស្រុក និងពីចម្ងាយ ខណៈពេលដែលការសន្ទនានៅតែបោះយុថ្កា។",
        },
      ],
    },
    faq: {
      eyebrow: "FAQ",
      title: "ចម្លើយផ្ទាល់សម្រាប់អ្វីដែលមនុស្សសួរមុន។",
      body: "ផលិតផលរក្សាការយល់ឃើញអំពីគុណភាពលំហូរការងារ ខណៈពេលដែលនៅសល់ការអនុវត្តជាក់ស្តែង។",
      items: [
        {
          q: "តើ icc គ្រាន់តែជាផ្លូវបំបែក Ghostty មែនទេ?",
          a:
            "លេខ icc គឺជាមជ្ឈមណ្ឌលបញ្ជាដើម macOS ដែលបានបង្កើតឡើងនៅលើការបង្ហាញស្ថានីយកម្រិត Ghostty។ ផលិតផលនេះពង្រីកមូលដ្ឋាននោះជាមួយអ្នករុករក ការកែសម្រួល ការប្រតិបត្តិកម្មវិធីរុករកតាមអ៊ីនធឺណិត ការគ្រប់គ្រង និងការរៀបចំកន្លែងធ្វើការ។",
        },
        {
          q: "តើ icc សម្រាប់អ្នកណា?",
          a:
            "ប្រតិបត្តិករ វិស្វករ ស្ថាបនិក និងអ្នកប្រើប្រាស់ថាមពលដែលដំណើរការដំណើរការការងារដែលមានជំនួយ AI រួចហើយ ហើយចង់បានផ្ទៃគ្រប់គ្រងដ៏មុតស្រួចមួយ ជំនួសឱ្យការពង្រីកបង្អួចបន្ថែមទៀត។",
        },
        {
          q: "តើអ្វីធ្វើឱ្យលំហូរការងារខុសគ្នា?",
          a:
            "icc រក្សាស្ថានីយលំដាប់ទីមួយ ខណៈពេលដែលបន្ថែមផ្ទៃដែលបាត់នៅជុំវិញវា៖ ឯកសារ ម៉ាស៊ីនពីចម្ងាយ ការគ្រប់គ្រងប្រភព បរិបទកម្មវិធីរុករក និងអ្នកគ្រប់គ្រងដែលផ្តោតលើការប្រតិបត្តិ។",
        },
        {
          q: "តើវាគាំទ្រការងារពីចម្ងាយទេ?",
          a:
            "បាទ។ icc អានការកំណត់ SSH ភ្ជាប់ទៅគោលដៅពីចម្ងាយ និងបង្ហាញឯកសារពីចម្ងាយនៅក្នុងគំរូកម្មវិធីរុករកដូចគ្នាដែលប្រើសម្រាប់ការងារក្នុងតំបន់។",
        },
      ],
    },
    cta: {
      eyebrow: "បើកដំណើរការ icc",
      title: "ផ្លាស់ទីពីចេតនាទៅការប្រតិបត្តិដោយមិនបាត់បង់រូបរាងការងារ។",
      body:
        "ទាញយក macOS បច្ចុប្បន្ន ឬតាមដានការចេញផ្សាយ និងប្រភពនៅលើ GitHub ។ គេហទំព័រសាធារណៈ បន្ទាត់ចេញផ្សាយ និងឃ្លាំងឥឡូវនេះត្រូវបានតម្រឹមទៅអត្តសញ្ញាណតែមួយ៖ icc ។",
    },
    footer: {
      blurb:
        "ដើម Swift និង AppKit ។ Ghostty- ការ​បង្ហាញ​ថ្នាក់។ បរិបទក្នុងស្រុក និងពីចម្ងាយ ប្រតិបត្តិការឯកសារ ការប្រតិបត្តិកម្មវិធីរុករកតាមអ៊ីនធឺណិត ការគ្រប់គ្រងប្រភព និងការត្រួតពិនិត្យនៅក្នុងកន្លែងធ្វើការដំបូងរបស់ប្រតិបត្តិករមួយ។",
      explore: "រុករក",
      release: "ចេញផ្សាយ",
      capabilities: "សមត្ថភាព",
      workflow: "លំហូរការងារ",
      faq: "FAQ",
      download: "ទាញយកសម្រាប់ macOS",
      releases: "ការចេញផ្សាយ",
      repository: "GitHub ឃ្លាំង",
      support: "ការគាំទ្រ / បញ្ហា",
      copyright: "© {year} icc ។ កាប៊ីនយន្ដហោះមួយសម្រាប់ការប្រតិបត្តិស្ថានីយដំបូង AI ។",
    },
  }
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
