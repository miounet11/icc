import { marketingLocales } from "./marketing-copy";
import { siteConfig } from "./site-config";

type ResourceCard = {
  title: string;
  body: string;
  cta: string;
};

type GuideSection = {
  title: string;
  body: string;
  points: string[];
};

type ChangelogEntry = {
  date: string;
  version: string;
  title: string;
  body: string;
  bullets: string[];
};

type ProductPageCopy = {
  nav: {
    home: string;
    guide: string;
    changelog: string;
    github: string;
  };
  resources: {
    eyebrow: string;
    title: string;
    body: string;
    guide: ResourceCard;
    changelog: ResourceCard;
  };
  guide: {
    section: string;
    metaTitle: string;
    metaDescription: string;
    eyebrow: string;
    title: string;
    intro: string;
    quickStartTitle: string;
    quickStartSteps: string[];
    sections: GuideSection[];
    updateTitle: string;
    updateSteps: string[];
    secondaryCta: string;
  };
  changelog: {
    section: string;
    metaTitle: string;
    metaDescription: string;
    eyebrow: string;
    title: string;
    intro: string;
    currentReleaseLabel: string;
    currentReleaseBody: string;
    entriesTitle: string;
    entries: ChangelogEntry[];
    upgradeTitle: string;
    upgradeSteps: string[];
    secondaryCta: string;
  };
  shared: {
    viewReleases: string;
    backHome: string;
  };
};

const englishCopy: ProductPageCopy = {
  nav: {
    home: "Home",
    guide: "Guide",
    changelog: "Changelog",
    github: "GitHub",
  },
  resources: {
    eyebrow: "Resources",
    title: "Use ICC with less guesswork and track what changes release by release.",
    body:
      "The site now includes a practical product guide plus a changelog that records what shipped, when it shipped, and how to upgrade without losing context.",
    guide: {
      title: "Usage Guide",
      body:
        "A complete operating guide for local workspaces, remote hosts, file editing, supervisor flow, source control visibility, and safe upgrades.",
      cta: "Open guide",
    },
    changelog: {
      title: "Upgrade Log",
      body:
        "A structured release history for ICC, including the first public line, website rollout, localization updates, and upgrade notes.",
      cta: "View changelog",
    },
  },
  guide: {
    section: "Guide",
    metaTitle: "ICC Guide — How to Use ICC",
    metaDescription:
      "A practical ICC usage guide covering setup, local and remote workspaces, file editing, supervisor flow, source control, and upgrade steps.",
    eyebrow: "Usage Guide",
    title: "How to use ICC from first launch to daily execution.",
    intro:
      "ICC is designed to get you from intent to execution fast, without scattering the workflow across multiple apps. Use this guide as the baseline operating manual for local projects, remote hosts, file editing, source visibility, and supervisor-driven work.",
    quickStartTitle: "Quick start",
    quickStartSteps: [
      "Download the current macOS build from the ICC releases page and install the app.",
      "Open ICC and create a workspace from a local folder, or start from a configured SSH target.",
      "Set your LLM provider and model in Settings before you hand a task to the supervisor.",
      "Use the right-side explorer and editor to keep files, paths, and task context visible while the terminal remains primary.",
    ],
    sections: [
      {
        title: "1. Start with a workspace, not a loose terminal",
        body:
          "ICC is optimized around a workspace model. The workspace should represent one concrete project or one concrete remote host so the terminal, files, browser tasks, and supervisor all reference the same operating context.",
        points: [
          "Create a local workspace from the repo or folder you actually want to work on.",
          "Use a dedicated remote workspace for each SSH target instead of mixing unrelated hosts together.",
          "Keep one goal per workspace when possible. That keeps supervisor plans and file context cleaner.",
        ],
      },
      {
        title: "2. Use the local and remote explorers as your control plane",
        body:
          "The explorer is not decorative. It is the fastest way to inspect project shape, open files, confirm paths, and stay oriented while the terminal conversation is active.",
        points: [
          "Use the local explorer to inspect repo structure before editing or delegating work.",
          "Use the remote explorer only after the SSH session is actually connected and authenticated.",
          "Drag file paths into the active terminal conversation when you want the path to become part of the task context.",
        ],
      },
      {
        title: "3. Read, edit, and save files without breaking flow",
        body:
          "ICC includes in-workspace file viewing and editing so you do not have to keep bouncing out to a second editor for every small change or inspection pass.",
        points: [
          "Click a file to preview or edit it directly inside the workspace.",
          "Save edits in place and return to the active terminal thread without losing context.",
          "Use the file view for verification too: confirm the exact contents before you ask the supervisor or terminal to continue.",
        ],
      },
      {
        title: "4. Treat the supervisor as an execution layer, not a chat toy",
        body:
          "The supervisor works best when you give it a concrete target, enough repo context, and a bounded objective. It should reduce ambiguity and compress the next move into a plan that can actually be executed.",
        points: [
          "Give each workspace a clear objective before asking the supervisor to take over.",
          "Review the proposed next steps instead of accepting vague plans blindly.",
          "Use the supervisor to frame work, track progress, and keep multiple active tasks from drifting.",
        ],
      },
      {
        title: "5. Keep source control visible while changes are happening",
        body:
          "ICC is most useful when Git state stays visible during execution rather than becoming an afterthought at the end of the task.",
        points: [
          "Check branch and working tree state before you start editing.",
          "Use visible file paths and repo context to avoid accidental edits in the wrong place.",
          "Review current changes before packaging or publishing any result.",
        ],
      },
      {
        title: "6. Upgrade with a release-first habit",
        body:
          "Do not treat upgrades as a blind overwrite. ICC should be updated with the same discipline you apply to any other developer tool that controls project context, remote access, or model settings.",
        points: [
          "Read the changelog before replacing the app build.",
          "Reconfirm model settings, SSH behavior, and any saved connection preferences after updating.",
          "Use one clean workspace to validate the new build before you move all active work onto it.",
        ],
      },
    ],
    updateTitle: "Safe update checklist",
    updateSteps: [
      "Download the latest DMG from the ICC releases page.",
      "Quit the current app cleanly so open writes or active sessions are not interrupted mid-task.",
      "Install the new build, reopen ICC, and verify LLM settings plus SSH connections before resuming important work.",
      "Check the changelog for behavior changes in explorers, supervisor flow, file editing, or routing.",
    ],
    secondaryCta: "View changelog",
  },
  changelog: {
    section: "Changelog",
    metaTitle: "ICC Changelog — Release History",
    metaDescription:
      "Track ICC release history, launch milestones, website updates, multilingual rollout, and upgrade guidance.",
    eyebrow: "Upgrade Log",
    title: "What changed, when it changed, and what to verify after upgrading.",
    intro:
      "This log is the public release record for ICC. It tracks the current product line, the official website rollout, documentation changes, and the operating notes you should check before replacing your current build.",
    currentReleaseLabel: "Current release line",
    currentReleaseBody:
      "ICC is currently published as v0.0.1. The desktop product, official website, multilingual marketing layer, and product guide are all aligned to that first public line.",
    entriesTitle: "Release history",
    entries: [
      {
        date: "March 26, 2026",
        version: "v0.0.1",
        title: "Documentation and multilingual website expansion",
        body:
          "The official website gained a full usage guide, a dedicated changelog page, and broader locale coverage across the public marketing surface.",
        bullets: [
          "Added dedicated /guide and /changelog routes.",
          "Expanded website language coverage across all routed marketing locales.",
          "Published practical setup, workflow, and upgrade instructions for ICC users.",
        ],
      },
      {
        date: "March 25, 2026",
        version: "v0.0.1",
        title: "Official ICC website launch",
        body:
          "The public site moved onto the ICC brand and domain, with aligned downloads, repository links, metadata, and production hosting.",
        bullets: [
          "Launched https://www.iccjk.com as the official public domain.",
          "Aligned branding to ICC across title, metadata, footer, download links, and repository links.",
          "Connected the website to the public GitHub release path for the macOS build.",
        ],
      },
      {
        date: "March 25, 2026",
        version: "v0.0.1",
        title: "First public ICC product baseline",
        body:
          "The initial public line centered the workflow around a native macOS command center with terminal-first execution and surrounding control surfaces.",
        bullets: [
          "Terminal-first workspace model.",
          "Local and remote explorers with SSH-backed remote browsing.",
          "In-workspace file viewing and editing plus source control visibility.",
          "Supervisor-oriented execution flow for task framing and multi-step work.",
        ],
      },
    ],
    upgradeTitle: "Upgrade guidance",
    upgradeSteps: [
      "Read the latest changelog entry before installing a new build.",
      "Replace the app from the latest DMG instead of mixing partial app copies.",
      "Recheck LLM settings, saved SSH behavior, and workspace assumptions after upgrading.",
      "Validate one local workspace and one remote workspace before moving critical work onto the updated build.",
    ],
    secondaryCta: "Open guide",
  },
  shared: {
    viewReleases: "View releases",
    backHome: "Back home",
  },
};

const zhCnCopy: ProductPageCopy = {
  nav: {
    home: "首页",
    guide: "使用说明",
    changelog: "升级日志",
    github: "GitHub",
  },
  resources: {
    eyebrow: "资源",
    title: "降低上手成本，并按版本追踪 ICC 的变化。",
    body:
      "官网现在包含一套实用的产品使用说明，以及一份结构化升级日志，记录每次发布内容、发布时间和升级时需要核对的事项。",
    guide: {
      title: "完整使用说明",
      body:
        "覆盖本地工作区、远程主机、文件编辑、监督器流程、源码状态可见性以及安全升级步骤的完整操作指南。",
      cta: "查看说明",
    },
    changelog: {
      title: "升级日志",
      body:
        "按时间记录 ICC 的发布历史，包括首个公开版本、官网上线、多语言扩展以及升级注意事项。",
      cta: "查看日志",
    },
  },
  guide: {
    section: "使用说明",
    metaTitle: "ICC 使用说明",
    metaDescription:
      "ICC 的完整使用说明，覆盖设置、本地与远程工作区、文件编辑、监督器流程、源码状态以及升级步骤。",
    eyebrow: "完整使用说明",
    title: "从第一次启动到日常执行，ICC 应该这样用。",
    intro:
      "ICC 的目标不是多一个聊天窗口，而是把意图快速压到可执行工作面上。下面这份说明可以作为 ICC 的基准操作手册，帮助你在本地项目、远程主机、文件编辑、源码状态和监督器工作流之间保持一致。",
    quickStartTitle: "快速开始",
    quickStartSteps: [
      "从 ICC Releases 页面下载当前 macOS 安装包并完成安装。",
      "打开 ICC，从本地目录创建工作区，或者从已配置的 SSH 目标开始。",
      "在交给监督器执行前，先在 Settings 中设置好你的 LLM 提供商与模型。",
      "让右侧资源管理器和编辑器承担文件、路径、任务上下文的展示，保持终端始终是主工作面。",
    ],
    sections: [
      {
        title: "1. 先建立工作区，而不是先堆终端",
        body:
          "ICC 的核心不是孤立终端，而是工作区。一个工作区最好只对应一个明确项目或一个明确远程主机，这样终端、文件、浏览器任务和监督器都基于同一上下文运行。",
        points: [
          "本地工作区应该直接指向你真正要处理的仓库或目录。",
          "远程工作区最好一台主机一个，不要把不相关的远端任务混在一起。",
          "尽量一项目标对应一个工作区，这样监督器生成的计划更清晰。",
        ],
      },
      {
        title: "2. 把本地和远程资源管理器当作控制平面来用",
        body:
          "资源管理器不是装饰，而是你快速确认项目结构、打开文件、核对路径、保持方向感的主要界面。",
        points: [
          "在开始编辑或交给监督器前，先用本地资源管理器读一遍仓库结构。",
          "只有在 SSH 会话真正连接并认证完成后，再依赖远程资源管理器执行远端文件操作。",
          "需要让终端上下文明确指向某个文件时，直接把路径拖进当前终端对话。",
        ],
      },
      {
        title: "3. 在工作区内直接阅读、编辑和保存文件",
        body:
          "ICC 提供工作区内文件查看与编辑能力，避免你为了每一次小改动或核对都跳到第二个编辑器里。",
        points: [
          "点击文件即可在工作区内部查看或编辑。",
          "保存后可以立刻回到当前终端线程，不丢上下文。",
          "文件视图也适合做核对：在让监督器继续前，先确认实际内容。",
        ],
      },
      {
        title: "4. 把监督器当成执行层，而不是聊天玩具",
        body:
          "监督器只有在目标具体、上下文充分、边界明确时才真正高效。它的价值在于压缩歧义、组织下一步，而不是输出一堆空泛话术。",
        points: [
          "给每个工作区先设定一个明确目标，再让监督器接手。",
          "先看监督器给出的下一步是否可执行，不要盲目接受模糊计划。",
          "监督器适合用来组织推进、追踪进度，以及约束多任务漂移。",
        ],
      },
      {
        title: "5. 让源码状态在执行过程中始终可见",
        body:
          "ICC 最大的价值之一，是让 Git 状态在执行过程中始终可见，而不是到最后才想起来核对改动。",
        points: [
          "开始编辑前先确认当前分支和工作树状态。",
          "利用可见路径和仓库上下文，避免误改到错误目录。",
          "在准备发布或交付结果前，再检查一遍当前变更。",
        ],
      },
      {
        title: "6. 用发布优先的习惯来升级 ICC",
        body:
          "不要把升级当成盲覆盖。ICC 控制的是项目上下文、远程访问和模型设置，升级动作本身也应该有工程纪律。",
        points: [
          "先读升级日志，再替换应用构建。",
          "升级后重新确认模型设置、SSH 行为和保存的连接偏好。",
          "先用一个干净工作区验证新构建，再把全部重要任务迁移过去。",
        ],
      },
    ],
    updateTitle: "安全升级检查表",
    updateSteps: [
      "从 ICC Releases 页面下载最新 DMG。",
      "先正常退出当前应用，避免中途打断写入或活动会话。",
      "安装新构建后重新打开 ICC，并在继续重要工作前核对 LLM 设置与 SSH 连接。",
      "如果资源管理器、监督器、文件编辑或路由行为有变化，先读升级日志再继续。",
    ],
    secondaryCta: "查看升级日志",
  },
  changelog: {
    section: "升级日志",
    metaTitle: "ICC 升级日志",
    metaDescription:
      "查看 ICC 的发布历史、官网更新、多语言扩展以及升级时需要核对的关键事项。",
    eyebrow: "升级日志",
    title: "记录每次变化、发布时间，以及升级后该核对什么。",
    intro:
      "这份页面是 ICC 的公开发布记录。它追踪当前产品线、官网上线、多语言站点扩展，以及替换当前构建前应该检查的操作说明。",
    currentReleaseLabel: "当前发布线",
    currentReleaseBody:
      "ICC 当前对外发布版本为 v0.0.1。桌面产品、官方网站、多语言营销层和产品使用说明目前都对齐在这一条首个公开版本线上。",
    entriesTitle: "发布历史",
    entries: [
      {
        date: "2026年3月26日",
        version: "v0.0.1",
        title: "文档与多语言官网扩展",
        body:
          "官方网站新增了完整使用说明、独立升级日志页面，并把公开营销层扩展到全部已路由语言。",
        bullets: [
          "新增 /guide 与 /changelog 独立页面。",
          "将官网语言覆盖扩展到全部营销路由语言。",
          "上线 ICC 的实用设置说明、工作流说明与升级说明。",
        ],
      },
      {
        date: "2026年3月25日",
        version: "v0.0.1",
        title: "ICC 官网正式上线",
        body:
          "公共站点切换到 ICC 品牌与官方域名，并对齐下载地址、仓库地址、元信息和生产环境托管。",
        bullets: [
          "将 https://www.iccjk.com 上线为 ICC 官方域名。",
          "标题、元信息、页脚、下载地址与仓库地址全部统一到 ICC 品牌。",
          "将网站下载入口对接到 GitHub 上的 macOS 发布路径。",
        ],
      },
      {
        date: "2026年3月25日",
        version: "v0.0.1",
        title: "ICC 首个公开产品基线",
        body:
          "首个公开版本围绕原生 macOS 指挥中心展开，核心是终端优先执行，以及围绕终端建立的一整套控制平面。",
        bullets: [
          "终端优先的工作区模型。",
          "本地与远程资源管理器，以及基于 SSH 的远程浏览能力。",
          "工作区内文件查看与编辑，以及源码状态可见性。",
          "面向多步骤任务组织的监督器执行流。",
        ],
      },
    ],
    upgradeTitle: "升级建议",
    upgradeSteps: [
      "安装新构建前，先看最新升级日志。",
      "尽量用最新 DMG 替换应用，不要混用多个不一致的应用副本。",
      "升级后重新检查 LLM 设置、SSH 行为和工作区假设。",
      "至少验证一个本地工作区和一个远程工作区，再迁移关键任务。",
    ],
    secondaryCta: "查看使用说明",
  },
  shared: {
    viewReleases: "查看版本发布",
    backHome: "返回首页",
  },
};

const copy: Record<string, ProductPageCopy> = {
  en: englishCopy,
  "zh-CN": zhCnCopy,
};

export function getProductPagesCopy(locale?: string): ProductPageCopy {
  return copy[locale ?? "en"] ?? englishCopy;
}

export function getLocalizedProductPath(locale: string | undefined, slug: "guide" | "changelog") {
  if (!locale || locale === "en") {
    return `/${slug}`;
  }

  return `/${locale}/${slug}`;
}

export function buildLocalizedAlternates(locale: string | undefined, slug: "guide" | "changelog") {
  const languages = Object.fromEntries(
    marketingLocales.map((locale) => [
      locale,
      locale === "en" ? `${siteConfig.canonicalUrl}/${slug}` : `${siteConfig.canonicalUrl}/${locale}/${slug}`,
    ]),
  );
  const canonicalPath = getLocalizedProductPath(locale, slug);

  return {
    canonical: `${siteConfig.canonicalUrl}${canonicalPath}`,
    languages: {
      ...languages,
      "x-default": `${siteConfig.canonicalUrl}/${slug}`,
    },
  };
}
