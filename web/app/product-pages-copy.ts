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
    workflowsTitle: string;
    workflowsIntro: string;
    workflows: GuideSection[];
    sections: GuideSection[];
    bestPracticesTitle: string;
    bestPracticesIntro: string;
    bestPractices: string[];
    briefingTitle: string;
    briefingIntro: string;
    briefingChecklist: string[];
    troubleshootingTitle: string;
    troubleshootingIntro: string;
    troubleshooting: GuideSection[];
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
    releaseModelTitle: string;
    releaseModelIntro: string;
    releaseModel: GuideSection[];
    entriesTitle: string;
    entries: ChangelogEntry[];
    upgradeTitle: string;
    upgradeSteps: string[];
    supportTitle: string;
    supportBody: string;
    supportChecklistTitle: string;
    supportChecklist: string[];
    supportDownloadLabel: string;
    supportAppcastLabel: string;
    supportManifestLabel: string;
    supportRemoteManifestLabel: string;
    platformStatusTitle: string;
    platformStatusBody: string;
    secondaryCta: string;
  };
  shared: {
    viewReleases: string;
    backHome: string;
    reportIssue: string;
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
      "Download the current macOS build from the ICC website and install the app.",
      "Open ICC and create a workspace from a local folder, or start from a configured SSH target.",
      "Set your LLM provider and model in Settings before you hand a task to the supervisor.",
      "Use the right-side explorer and editor to keep files, paths, and task context visible while the terminal remains primary.",
    ],
    workflowsTitle: "Recommended operating methods",
    workflowsIntro:
      "Most teams do better when ICC is used as a repeatable operating surface rather than a one-off prompt box. These patterns keep the terminal primary while reducing drift.",
    workflows: [
      {
        title: "1. Local coding loop",
        body:
          "Use one workspace per repo, keep Git visible, and let the terminal drive the task while files stay open beside it for verification.",
        points: [
          "Open the target repo as its own workspace.",
          "Inspect the file tree before changing anything substantial.",
          "Keep edits small, verify them in the editor, then return to the active thread.",
        ],
      },
      {
        title: "2. Remote operations loop",
        body:
          "Treat each SSH host like a first-class workspace with the same discipline you would apply locally. Remote work gets safer when path awareness and authentication state are visible.",
        points: [
          "Connect only after confirming the correct SSH target.",
          "Wait for authentication and directory discovery before browsing files.",
          "Use a separate workspace per host so logs, paths, and objectives do not mix.",
        ],
      },
      {
        title: "3. Review and verification loop",
        body:
          "Do not rely on generated output alone. ICC works best when the operator quickly checks files, paths, Git state, and command results before the next step is approved.",
        points: [
          "Open changed files immediately after each meaningful step.",
          "Confirm the exact path and branch before packaging or publishing.",
          "Use the right-side surfaces for evidence, not just for navigation.",
        ],
      },
      {
        title: "4. Multi-task supervisor loop",
        body:
          "When several tasks are moving at once, the supervisor should be used to keep goals bounded and progress interpretable rather than to produce abstract commentary.",
        points: [
          "Give every workspace a short, concrete objective.",
          "Revisit the supervisor only when context has materially changed.",
          "Prefer several clean workspaces over one overloaded universal session.",
        ],
      },
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
    bestPracticesTitle: "Best practices that improve the experience fast",
    bestPracticesIntro:
      "A few habits change ICC from a promising shell wrapper into a much more reliable command center.",
    bestPractices: [
      "Keep one repo or one remote host per workspace whenever possible.",
      "Set the workspace objective before handing control to the supervisor.",
      "Drag precise file paths into the active thread instead of describing files vaguely.",
      "Check Git state early, not only at the end of the task.",
      "Use the editor for confirmation after every non-trivial generated change.",
      "Validate one clean local path and one clean remote path after every upgrade.",
    ],
    briefingTitle: "How to brief ICC so execution starts in 2 to 3 turns",
    briefingIntro:
      "Most slow starts come from vague goals, not from missing features. A short, concrete brief usually gets ICC into execution mode fast.",
    briefingChecklist: [
      "Name the exact repo, folder, or SSH target first.",
      "State one outcome you need now instead of bundling several unrelated goals together.",
      "Mention the most relevant files, commands, or URLs if you already know them.",
      "Define what done looks like in one measurable sentence.",
      "Use the next reply to tighten scope or priorities instead of rewriting the full request.",
    ],
    troubleshootingTitle: "Troubleshooting and recovery",
    troubleshootingIntro:
      "When ICC feels slow, noisy, or unreliable, the fix is usually operational rather than magical. These are the first checks worth making.",
    troubleshooting: [
      {
        title: "SSH connection looks stuck",
        body:
          "Most remote failures are caused by incomplete authentication, mismatched SSH config, or trying to browse files before the connection has fully settled.",
        points: [
          "Reconfirm the target in your SSH config and reconnect cleanly.",
          "Wait for the terminal to show the connected shell state before using the remote explorer.",
          "Test the target in a normal SSH session if the explorer still cannot populate.",
        ],
      },
      {
        title: "The workspace feels noisy or unfocused",
        body:
          "This usually means the workspace goal is too broad or too many unrelated paths and tasks are sharing the same surface.",
        points: [
          "Split unrelated efforts into separate workspaces.",
          "Narrow the active objective to one concrete outcome.",
          "Close files and panes that are no longer part of the current decision path.",
        ],
      },
      {
        title: "The supervisor is suggesting vague next steps",
        body:
          "That usually means it is missing a bounded objective, fresh file evidence, or a clear signal about what counts as done.",
        points: [
          "Restate the objective in one sentence with a measurable end condition.",
          "Open the most relevant files before asking it to continue.",
          "Point it at the current repo state instead of relying on old chat context.",
        ],
      },
    ],
    updateTitle: "Safe update checklist",
    updateSteps: [
      "Download the latest DMG from the ICC website download endpoint.",
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
      "ICC is currently published as v0.1.0. The desktop product, official website, multilingual marketing layer, and release assets now align to the first post-launch refinement line.",
    releaseModelTitle: "How to read ICC releases",
    releaseModelIntro:
      "Use the changelog as an operating document, not just a marketing page. A good release note helps you decide whether to adopt immediately, validate first, or hold until an active workflow is done.",
    releaseModel: [
      {
        title: "1. Stable line first",
        body:
          "Treat the public version as the stable line you can standardize on for real work. Upgrade deliberately, not because a build happens to exist.",
        points: [
          "Check the current version label before replacing the app.",
          "Prefer one approved build across a team or project cluster.",
          "Use the changelog to decide when timing is safe for important work.",
        ],
      },
      {
        title: "2. Read for impact, not for headlines",
        body:
          "Focus on what changes your operating surface: file handling, SSH behavior, supervisor flow, model settings, or packaging.",
        points: [
          "Look for workflow changes before cosmetic changes.",
          "Verify whether remote behavior, routing, or settings persistence changed.",
          "Map release notes to your current active tasks before updating.",
        ],
      },
      {
        title: "3. Validate with one clean path",
        body:
          "Every upgrade should be checked in at least one controlled local workspace and one controlled remote workspace before it becomes your default daily build.",
        points: [
          "Open a local repo and confirm editing plus save behavior.",
          "Connect one SSH host and confirm remote browsing still matches expectation.",
          "Only then move critical tasks to the new version.",
        ],
      },
    ],
    entriesTitle: "Release history",
    entries: [
      {
        date: "March 30, 2026",
        version: "v0.1.0",
        title: "Brand refinement, migration shortcuts, and collaboration upgrades",
        body:
          "The first post-launch ICC release sharpens the product identity, smooths migration from other AI coding clients, and adds better in-workspace control for source management and multi-agent layouts.",
        bullets: [
          "Replaced release-facing iconography, welcome copy, and visible product labels so ICC is distinct across app and website surfaces.",
          "Added quick import actions for VS Code, Cursor, Claude Code, and Codex preferences.",
          "Upgraded the source-control area and collaboration tools so fast pull, fast push, and multi-model pane creation happen inside live ICC terminals.",
        ],
      },
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
    supportTitle: "If an upgrade changes expected behavior",
    supportBody:
      "When something feels off after updating, use the guide to re-check the intended workflow, compare against the releases feed, and report a concrete issue with paths, settings, and reproduction steps.",
    supportChecklistTitle: "What to include in a useful issue report",
    supportChecklist: [
      "The ICC version and whether the issue is local, remote, or supervisor-related.",
      "The workspace path or SSH target involved.",
      "Expected behavior versus actual behavior.",
      "A short sequence of clicks, commands, or prompts that reproduces it.",
      "A screenshot or terminal output when the problem is visual, remote, or stateful.",
    ],
    supportDownloadLabel: "Stable macOS download",
    supportAppcastLabel: "Sparkle appcast",
    supportManifestLabel: "Release manifest",
    supportRemoteManifestLabel: "Remote helper manifest",
    platformStatusTitle: "Platform status",
    platformStatusBody:
      "macOS is the only production desktop build today. ICC currently ships as a native AppKit/SwiftUI client, so a Windows installer is not published yet.",
    secondaryCta: "Open guide",
  },
  shared: {
    viewReleases: "View releases",
    backHome: "Back home",
    reportIssue: "Report issue",
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
      "从 ICC 官方网站下载当前 macOS 安装包并完成安装。",
      "打开 ICC，从本地目录创建工作区，或者从已配置的 SSH 目标开始。",
      "在交给监督器执行前，先在 Settings 中设置好你的 LLM 提供商与模型。",
      "让右侧资源管理器和编辑器承担文件、路径、任务上下文的展示，保持终端始终是主工作面。",
    ],
    workflowsTitle: "推荐的使用方式",
    workflowsIntro:
      "ICC 最适合被当作一套可重复执行的操作面，而不是一次性提示框。下面这些方式可以在保持终端优先的同时，减少上下文漂移。",
    workflows: [
      {
        title: "1. 本地开发循环",
        body:
          "一个仓库对应一个工作区，Git 状态持续可见，终端驱动任务推进，文件视图承担核对与确认职责。",
        points: [
          "把目标仓库作为独立工作区打开。",
          "开始大改前先浏览一次文件树。",
          "每次重要修改后先在编辑器里确认，再回到主线程继续。",
        ],
      },
      {
        title: "2. 远程运维循环",
        body:
          "把每台 SSH 主机都当成一等工作区，使用和本地一致的纪律。远程任务只有在路径与认证状态清晰时才真正安全。",
        points: [
          "先确认 SSH 目标，再建立连接。",
          "等终端明确显示远端 shell 状态后再使用远程资源管理器。",
          "尽量一台主机一个工作区，避免日志、路径和目标混杂。",
        ],
      },
      {
        title: "3. 审核与验证循环",
        body:
          "不要只相信生成结果。ICC 最强的地方，是你可以快速把文件、路径、Git 状态和命令结果放到同一视图里核对。",
        points: [
          "每次关键步骤完成后立刻打开相关文件。",
          "发布前确认准确路径和分支状态。",
          "把右侧面板当作证据面，而不仅仅是导航面。",
        ],
      },
      {
        title: "4. 多任务监督循环",
        body:
          "当多个任务并行时，监督器最适合做的是维持目标边界和进度可解释性，而不是输出空泛总结。",
        points: [
          "给每个工作区一个简短且具体的目标。",
          "只有在上下文发生明显变化时再重新调用监督器。",
          "优先使用多个干净工作区，而不是一个超载会话。",
        ],
      },
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
    bestPracticesTitle: "能立刻改善体验的习惯",
    bestPracticesIntro:
      "只要建立几条简单习惯，ICC 就会从一个看起来不错的工具，变成真正稳定的指挥中心。",
    bestPractices: [
      "尽量保持一个工作区只对应一个仓库或一台远程主机。",
      "把工作区目标先写清楚，再交给监督器推进。",
      "把精确文件路径拖进线程，而不是用模糊描述代替。",
      "尽早看 Git 状态，不要到最后才检查。",
      "每次非小型改动后，都用编辑器做一次人工确认。",
      "每次升级后至少验证一个本地路径和一个远程路径。",
    ],
    briefingTitle: "怎样给 ICC 下达任务，才能在 2 到 3 轮内进入执行",
    briefingIntro:
      "大多数启动缓慢的问题，并不是功能不够，而是目标太模糊。一个短而具体的任务简报，通常就足够让 ICC 快速开工。",
    briefingChecklist: [
      "先说清楚具体仓库、目录或 SSH 目标。",
      "一次只讲当前最重要的一个结果，不要把多个无关目标塞在一起。",
      "如果你已经知道关键文件、命令或 URL，就直接指出来。",
      "用一句可衡量的话说明什么叫完成。",
      "下一轮只需要收紧范围或优先级，不需要把全部需求重新讲一遍。",
    ],
    troubleshootingTitle: "常见问题与恢复方式",
    troubleshootingIntro:
      "ICC 出现卡顿、混乱或不可靠时，通常原因都在操作方式本身，而不是神秘错误。优先检查下面这些点。",
    troubleshooting: [
      {
        title: "SSH 连接像是卡住了",
        body:
          "大多数远程问题都来自认证未完成、SSH 配置不匹配，或者在连接尚未稳定前就开始浏览远程文件。",
        points: [
          "重新确认 SSH config 里的目标并干净重连。",
          "等终端明确出现远端 shell 状态后再使用远程资源管理器。",
          "如果仍然异常，先用普通 SSH 会话测试该目标。",
        ],
      },
      {
        title: "工作区显得很乱、不聚焦",
        body:
          "这通常意味着工作区目标过大，或者多个不相关路径与任务堆在了同一个操作面里。",
        points: [
          "把不相关任务拆成多个工作区。",
          "把当前目标压缩成一个明确结果。",
          "关闭不再参与当前决策链的文件和面板。",
        ],
      },
      {
        title: "监督器给出的下一步太空泛",
        body:
          "这往往意味着它缺少明确目标、最新文件证据，或者没有得到清晰的完成标准。",
        points: [
          "用一句话重述目标，并写明什么算完成。",
          "继续前先打开最相关的文件。",
          "把它重新指向当前仓库状态，而不是依赖旧对话记忆。",
        ],
      },
    ],
    updateTitle: "安全升级检查表",
    updateSteps: [
      "从 ICC 官方网站下载最新 DMG。",
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
      "ICC 当前对外发布版本为 v0.1.0。桌面产品、官方网站、多语言营销层以及发布资产现在都已经对齐到首个公开版本之后的第一条优化版本线上。",
    releaseModelTitle: "应该怎么读 ICC 的版本发布",
    releaseModelIntro:
      "把升级日志当成操作文档，而不仅仅是宣传页。好的发布记录应该帮助你判断是马上采用、先验证，还是等当前任务结束后再更新。",
    releaseModel: [
      {
        title: "1. 先把公开版本当作稳定线",
        body:
          "公开版本应该被视为可用于真实工作的稳定线。升级动作应该有节奏，而不是看到新构建就立即覆盖。",
        points: [
          "替换应用前先确认当前版本号。",
          "团队或项目集群尽量统一到同一批准构建。",
          "根据升级日志判断当前时机是否适合重要任务。",
        ],
      },
      {
        title: "2. 看影响面，不只看标题",
        body:
          "重点关注会改变操作面的内容，例如文件处理、SSH 行为、监督器流程、模型设置和打包行为。",
        points: [
          "优先看工作流变化，再看外观变化。",
          "确认远程行为、路由或设置持久化是否变化。",
          "把发布说明映射到你当前正在推进的任务上。",
        ],
      },
      {
        title: "3. 用一条干净路径做升级验证",
        body:
          "每次升级后，至少要在一个受控本地工作区和一个受控远程工作区中验证，确认无误后再作为默认日常版本。",
        points: [
          "打开一个本地仓库，确认编辑与保存正常。",
          "连接一台 SSH 主机，确认远程浏览符合预期。",
          "验证通过后，再把关键任务迁移到新版本。",
        ],
      },
    ],
    entriesTitle: "发布历史",
    entries: [
      {
        date: "2026年3月30日",
        version: "v0.1.0",
        title: "品牌细化、迁移快捷入口与协作能力升级",
        body:
          "这是 ICC 首个公开版本之后的优化更新，重点在于拉开品牌辨识度、降低从其他 AI 编码客户端迁移的成本，并增强工作区内的源码管理和多模型协作能力。",
        bullets: [
          "替换了面向发布的图标、欢迎语和可见产品文案，让 ICC 在应用与网站两侧都更统一、更有辨识度。",
          "新增 VS Code、Cursor、Claude Code、Codex 的快速导入入口。",
          "升级源码管理区和协作工具，让快速 pull、快速 push 以及多模型 pane 创建都能直接在 ICC 的真实终端里完成。",
        ],
      },
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
    supportTitle: "如果升级后行为和预期不一致",
    supportBody:
      "如果升级后感觉不对劲，先回到使用说明重新核对预期工作流，再对照版本发布页确认变更点，并通过可复现步骤、路径和设置状态提交问题。",
    supportChecklistTitle: "提交有效问题时最好附带这些信息",
    supportChecklist: [
      "ICC 版本号，以及问题属于本地、远程还是监督器相关。",
      "涉及的工作区路径或 SSH 目标。",
      "你的预期行为和实际行为分别是什么。",
      "一段可以稳定复现的点击、命令或提示词序列。",
      "如果问题和界面、远程连接或状态有关，附上截图或终端输出。",
    ],
    supportDownloadLabel: "稳定版 macOS 下载",
    supportAppcastLabel: "Sparkle 更新源",
    supportManifestLabel: "发布清单",
    supportRemoteManifestLabel: "远程助手清单",
    platformStatusTitle: "平台状态",
    platformStatusBody:
      "目前只有 macOS 提供正式桌面安装包。ICC 当前是原生 AppKit/SwiftUI 客户端，因此 Windows 桌面安装包暂未发布。",
    secondaryCta: "查看使用说明",
  },
  shared: {
    viewReleases: "查看版本发布",
    backHome: "返回首页",
    reportIssue: "报告问题",
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
