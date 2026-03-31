import AppKit
import Foundation
import SwiftUI

struct WorkspaceSupervisorTaskCharter: Codable, Equatable, Sendable {
    var goal: String
    var doneDefinition: String
    var constraints: String
    var scopeNotes: String

    init(
        goal: String = "",
        doneDefinition: String = "",
        constraints: String = "",
        scopeNotes: String = ""
    ) {
        self.goal = goal
        self.doneDefinition = doneDefinition
        self.constraints = constraints
        self.scopeNotes = scopeNotes
    }

    var isEmpty: Bool {
        goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            doneDefinition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            constraints.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            scopeNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct WorkspaceSupervisorRunEntry: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var title: String
    var summary: String
    var outcome: String
    var nextAction: String
    var source: String
    var timestamp: TimeInterval

    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        outcome: String,
        nextAction: String,
        source: String,
        timestamp: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.outcome = outcome
        self.nextAction = nextAction
        self.source = source
        self.timestamp = timestamp
    }
}

struct WorkspaceSupervisorLoopSettings: Codable, Equatable, Sendable {
    var maxIterations: Int
    var intervalSeconds: Double
    var useLLMReview: Bool
    var stopOnBlocked: Bool
    var stopOnCompleted: Bool

    init(
        maxIterations: Int = 3,
        intervalSeconds: Double = 4,
        useLLMReview: Bool = false,
        stopOnBlocked: Bool = true,
        stopOnCompleted: Bool = true
    ) {
        self.maxIterations = maxIterations
        self.intervalSeconds = intervalSeconds
        self.useLLMReview = useLLMReview
        self.stopOnBlocked = stopOnBlocked
        self.stopOnCompleted = stopOnCompleted
    }
}

enum WorkspaceSupervisorLoopState: String, Codable, Sendable {
    case idle
    case running
    case completed
    case blocked
    case stopped

    var displayText: String {
        switch self {
        case .idle: "空闲"
        case .running: "循环中"
        case .completed: "已完成"
        case .blocked: "已阻塞"
        case .stopped: "已停止"
        }
    }
}

enum WorkspaceSupervisorHealth: String, Codable, CaseIterable, Sendable {
    case idle
    case running
    case attention
    case blocked
    case completed

    var displayText: String {
        switch self {
        case .idle: "待配置"
        case .running: "执行中"
        case .attention: "需关注"
        case .blocked: "已阻塞"
        case .completed: "已完成"
        }
    }

    var tint: Color {
        switch self {
        case .idle: .secondary
        case .running: .blue
        case .attention: .orange
        case .blocked: .red
        case .completed: .green
        }
    }
}

struct WorkspaceSupervisorReview: Codable, Equatable, Sendable {
    var health: WorkspaceSupervisorHealth
    var summary: String
    var reason: String
    var nextAction: String
    var suggestedPrompt: String
    var source: String
    var model: String?
    var generatedAt: TimeInterval
}

struct WorkspaceSupervisorStartupPlan: Codable, Equatable, Sendable {
    var goal: String
    var progressSummary: String
    var recommendedAction: String
    var starterPrompt: String
    var assumptions: String
    var source: String
    var model: String?
    var generatedAt: TimeInterval
}

struct WorkspaceSupervisorExecutionBrief: Codable, Equatable, Sendable {
    var title: String
    var objective: String
    var executionSteps: [String]
    var successSignals: [String]
    var risks: [String]
    var operatorPrompt: String
    var source: String
    var model: String?
    var generatedAt: TimeInterval
}

struct WorkspaceSupervisorPanelHandoff: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var panelID: UUID
    var panelTitle: String
    var panelType: String
    var workingDirectory: String
    var objective: String
    var nextAction: String
    var status: String
    var operatorPrompt: String
    var source: String
    var generatedAt: TimeInterval
}

struct WorkspaceSupervisorPanelRoundEntry: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var iteration: Int
    var panelID: UUID
    var status: String
    var summary: String
    var outcome: String
    var nextAction: String
    var source: String
    var timestamp: TimeInterval

    init(
        id: UUID = UUID(),
        iteration: Int,
        panelID: UUID,
        status: String,
        summary: String,
        outcome: String,
        nextAction: String,
        source: String,
        timestamp: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.id = id
        self.iteration = iteration
        self.panelID = panelID
        self.status = status
        self.summary = summary
        self.outcome = outcome
        self.nextAction = nextAction
        self.source = source
        self.timestamp = timestamp
    }
}

struct WorkspaceSupervisorPanelRoundState: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var panelID: UUID
    var panelTitle: String
    var panelType: String
    var workingDirectory: String
    var status: String
    var iterationCount: Int
    var lastSummary: String
    var lastOutcome: String
    var nextAction: String
    var source: String
    var lastUpdatedAt: TimeInterval
    var history: [WorkspaceSupervisorPanelRoundEntry]
}

struct WorkspaceSupervisorQueueItem: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var panelID: UUID
    var panelTitle: String
    var role: String
    var priority: Int
    var dependsOnPanelID: UUID?
    var readiness: String
    var nextMilestone: String
    var rotationRule: String
    var generatedAt: TimeInterval
}

struct WorkspaceSupervisorLoopTarget: Codable, Equatable, Sendable {
    var panelID: UUID
    var panelTitle: String
    var workingDirectory: String
    var selectedAt: TimeInterval
}

struct WorkspaceSupervisorAutomationReadiness: Sendable {
    var headline: String
    var statusText: String
    var shellIntegrationMode: String
    var shellIntegrationInjected: Bool
    var appleScriptAutomationEnabled: Bool
    var focusedPanelTitle: String
    var focusedPanelType: String
    var focusedDirectory: String
    var focusedShellState: String
    var terminalPanelCount: Int
    var promptReadyCount: Int
    var runningCount: Int
    var unknownCount: Int
    var trackedDirectoryCount: Int
    var notes: [String]
}

enum WorkspaceSupervisorOperatorMode: String, CaseIterable, Identifiable, Sendable {
    case observe
    case suggest
    case drive
    case autonomy

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .observe: "观察"
        case .suggest: "建议"
        case .drive: "驾驶"
        case .autonomy: "自治"
        }
    }

    var subtitle: String {
        switch self {
        case .observe:
            "只读取状态，不派发动作。"
        case .suggest:
            "生成任务包和建议，但不直接接管窗口。"
        case .drive:
            "允许向终端窗口派发下一步动作。"
        case .autonomy:
            "允许轮转多个窗口，持续编排执行。"
        }
    }
}

enum WorkspaceSupervisorAuthorityLevel: String, Sendable {
    case limited
    case standard
    case elevated
    case orchestrator

    var displayText: String {
        switch self {
        case .limited: "观察级"
        case .standard: "工作级"
        case .elevated: "驱动级"
        case .orchestrator: "编排级"
        }
    }

    var subtitle: String {
        switch self {
        case .limited:
            "仅解释状态和风险。"
        case .standard:
            "可整理目标、目录、文件与上下文。"
        case .elevated:
            "可向执行窗口下达边界清晰的动作。"
        case .orchestrator:
            "可跨窗口轮转、派发、跟踪与复盘。"
        }
    }
}

enum WorkspaceSupervisorCapabilityAvailability: String, Sendable {
    case ready
    case partial
    case caution
    case unavailable

    var displayText: String {
        switch self {
        case .ready: "可用"
        case .partial: "待补齐"
        case .caution: "需谨慎"
        case .unavailable: "不可用"
        }
    }
}

enum WorkspaceSupervisorCapabilityKind: String, CaseIterable, Identifiable, Sendable {
    case terminalControl
    case commandExecution
    case browserOperator
    case localFiles
    case remoteFiles
    case sourceControl
    case sessionRouting
    case skillStudio

    var id: String { rawValue }

    var title: String {
        switch self {
        case .terminalControl: "终端接管"
        case .commandExecution: "命令执行"
        case .browserOperator: "浏览器上下文"
        case .localFiles: "本地文件"
        case .remoteFiles: "远程文件"
        case .sourceControl: "源代码管理"
        case .sessionRouting: "窗口编排"
        case .skillStudio: "技能工坊"
        }
    }

    var subtitle: String {
        switch self {
        case .terminalControl: "聚焦、派发、保持会话连续。"
        case .commandExecution: "基于 shell 状态决定是否可继续。"
        case .browserOperator: "读取和利用浏览器面板上下文。"
        case .localFiles: "读取、查看、编辑当前项目文件。"
        case .remoteFiles: "连接远程主机后查看与编辑文件。"
        case .sourceControl: "读取 Git 分支、变更和仓库绑定。"
        case .sessionRouting: "在多个窗口之间轮转任务。"
        case .skillStudio: "把当前方法沉淀成可复用技能。"
        }
    }

    var systemImage: String {
        switch self {
        case .terminalControl: "terminal"
        case .commandExecution: "play.circle"
        case .browserOperator: "globe"
        case .localFiles: "folder"
        case .remoteFiles: "externaldrive.connected.to.line.below"
        case .sourceControl: "arrow.triangle.branch"
        case .sessionRouting: "square.split.2x2"
        case .skillStudio: "wand.and.stars"
        }
    }
}

struct WorkspaceSupervisorCapabilityState: Identifiable, Sendable {
    var id: WorkspaceSupervisorCapabilityKind { kind }
    var kind: WorkspaceSupervisorCapabilityKind
    var availability: WorkspaceSupervisorCapabilityAvailability
    var summary: String
    var detail: String
}

struct WorkspaceSupervisorOperatorProfile: Sendable {
    var mode: WorkspaceSupervisorOperatorMode
    var authority: WorkspaceSupervisorAuthorityLevel
    var missionTitle: String
    var missionSummary: String
    var accessSummary: String
    var operatingNotes: [String]
    var laneSummaries: [String]
    var capabilityStates: [WorkspaceSupervisorCapabilityState]
}

enum WorkspaceSupervisorExperienceMode: String, CaseIterable, Identifiable, Sendable {
    case auto
    case expert

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .auto: "零配置"
        case .expert: "专家"
        }
    }

    var subtitle: String {
        switch self {
        case .auto:
            "自动推断模式、上下文和下一步。"
        case .expert:
            "显示全部能力、模式和高级控制项。"
        }
    }
}

struct WorkspaceSupervisorZeroConfigBootstrap: Sendable {
    var projectLabel: String
    var primaryActionTitle: String
    var headline: String
    var summary: String
    var recommendedGoal: String
    var interactionSeed: String
    var badges: [String]
}

struct WorkspaceSupervisorResolvedLLMConfiguration: Sendable {
    var endpoint: String
    var apiKey: String
    var model: String
    var sourceLabel: String
    var isImplicit: Bool
}

struct WorkspaceSupervisorSkillBlueprint: Sendable {
    var title: String
    var summary: String
    var recommendedDirectory: String
    var trigger: String
    var toolset: [String]
    var steps: [String]
    var guardrails: [String]
    var seedPrompt: String

    var markdown: String {
        """
        # \(title)

        ## Summary
        \(summary)

        ## Recommended Directory
        \(recommendedDirectory)

        ## Trigger
        \(trigger)

        ## Toolset
        \(toolset.map { "- \($0)" }.joined(separator: "\n"))

        ## Steps
        \(steps.map { "- \($0)" }.joined(separator: "\n"))

        ## Guardrails
        \(guardrails.map { "- \($0)" }.joined(separator: "\n"))

        ## Seed Prompt
        ```text
        \(seedPrompt)
        ```
        """
    }

    var suggestedFilename: String {
        let cleaned = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "\n", with: " ")
        let fallback = cleaned.isEmpty ? "supervisor-skill-blueprint" : cleaned
        return "\(fallback).md"
    }
}

struct WorkspaceSupervisorSnapshot: Sendable {
    var title: String
    var customTitle: String?
    var currentDirectory: String
    var observedDirectories: [String]
    var goal: String
    var doneDefinition: String
    var constraints: String
    var scopeNotes: String
    var progressValue: Double?
    var progressLabel: String?
    var gitBranch: String?
    var gitDirty: Bool
    var remoteTarget: String?
    var remoteState: String
    var remoteCompatibility: String?
    var remoteDetail: String?
    var statusEntries: [(key: String, value: String)]
    var recentLogs: [String]
    var recentRunHeadlines: [String]
    var focusedPanelDirectory: String?
}

enum WorkspaceSupervisorHeuristics {
    private static func stageLabel(snapshot: WorkspaceSupervisorSnapshot, interactions: String = "") -> String {
        let normalizedGoal = snapshot.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedInteractions = interactions.lowercased()
        let recentSignals = (
            snapshot.recentLogs
            + snapshot.statusEntries.map(\.value)
            + snapshot.recentRunHeadlines
        )
        .joined(separator: "\n")
        .lowercased()

        if normalizedGoal.isEmpty {
            return "待澄清"
        }
        if recentSignals.contains("completed successfully")
            || recentSignals.contains("task_complete")
            || snapshot.progressValue.map({ $0 >= 0.999 }) == true {
            return "已完成"
        }
        if recentSignals.contains("error")
            || recentSignals.contains("failed")
            || recentSignals.contains("blocked")
            || recentSignals.contains("permission denied") {
            return "阻塞中"
        }
        if normalizedInteractions.contains("规划")
            || normalizedInteractions.contains("目标")
            || snapshot.recentRunHeadlines.isEmpty {
            return "准备开工"
        }
        if snapshot.gitDirty || snapshot.progressValue != nil {
            return "执行中"
        }
        return "推进中"
    }

    private static func contextBulletLines(snapshot: WorkspaceSupervisorSnapshot) -> [String] {
        var lines: [String] = []
        lines.append("当前目录：\(snapshot.currentDirectory)")
        if let focusedPanelDirectory = snapshot.focusedPanelDirectory, !focusedPanelDirectory.isEmpty {
            lines.append("聚焦面板目录：\(focusedPanelDirectory)")
        }
        if !snapshot.observedDirectories.isEmpty {
            lines.append("已访问目录：\(snapshot.observedDirectories.joined(separator: ", "))")
        }
        if let gitBranch = snapshot.gitBranch, !gitBranch.isEmpty {
            lines.append("Git：\(gitBranch)\(snapshot.gitDirty ? "（有未提交改动）" : "（干净）")")
        }
        if let remoteTarget = snapshot.remoteTarget, !remoteTarget.isEmpty {
            let remoteDetail = snapshot.remoteDetail?.trimmingCharacters(in: .whitespacesAndNewlines)
            lines.append("远程：\(remoteTarget) / \(snapshot.remoteState)\(remoteDetail?.isEmpty == false ? " / \(remoteDetail!)" : "")")
        }
        if let remoteCompatibility = snapshot.remoteCompatibility, !remoteCompatibility.isEmpty {
            lines.append("远程 SSH：\(remoteCompatibility)")
        }
        if !snapshot.recentRunHeadlines.isEmpty {
            lines.append("最近监督记录：\(snapshot.recentRunHeadlines.joined(separator: " | "))")
        }
        return lines
    }

    static func evaluate(snapshot: WorkspaceSupervisorSnapshot) -> WorkspaceSupervisorReview {
        let normalizedGoal = snapshot.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        let recentText = ([snapshot.remoteDetail] + snapshot.statusEntries.map(\.value) + snapshot.recentLogs + snapshot.recentRunHeadlines)
            .compactMap { $0?.lowercased() }
            .joined(separator: "\n")

        let health: WorkspaceSupervisorHealth
        let reason: String
        let summary: String
        let nextAction: String
        let suggestedPrompt: String

        if normalizedGoal.isEmpty {
            health = .idle
            reason = "当前工作区还没有设置明确目标。"
            summary = "监督器处于待配置状态，因为工作区缺少明确目标。"
            nextAction = snapshot.doneDefinition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "先补充一个可以验收的目标，再让监督器判断进度和下一步。"
                : "先补充明确目标，再结合完成标准让监督器判断进度和下一步。"
            suggestedPrompt = "目标：请描述这个工作区最终必须交付的结果。"
        } else if recentText.contains("task_complete")
            || recentText.contains("completed successfully")
            || snapshot.progressValue.map({ $0 >= 0.999 }) == true {
            health = .completed
            reason = "最近的工作区信号显示任务已经完成。"
            summary = "当前工作区看起来已经达成目标。"
            nextAction = "先核验交付物，再决定归档工作区还是分配新的目标。"
            suggestedPrompt = "请确认目标是否已完全完成，总结交付结果，并列出剩余风险。"
        } else if recentText.contains("error")
            || recentText.contains("failed")
            || recentText.contains("exception")
            || recentText.contains("traceback")
            || recentText.contains("permission denied")
            || recentText.contains("blocked") {
            health = .blocked
            reason = "最近的日志或侧边栏元数据里出现了明确报错或阻塞。"
            summary = "当前工作区已被阻塞，需要人工干预。"
            nextAction = "先检查最新失败命令或工具输出，再给出最小修正动作。"
            suggestedPrompt = "你当前被阻塞。请仔细阅读最近错误，定位根因，并给出继续推进“\(normalizedGoal)”的最小修复步骤。"
        } else if snapshot.remoteState == "disconnected" && snapshot.remoteDetail?.isEmpty == false {
            health = .attention
            reason = "当前工作区的远程连接存在问题，可能影响继续执行。"
            summary = "远程会话状态异常，需要优先关注。"
            nextAction = "优先恢复远程连接，或者切回本地工作区继续推进。"
            suggestedPrompt = "远程会话不健康。如果安全可行，请重连；否则说明是什么阻碍了“\(normalizedGoal)”的推进。"
        } else {
            health = .running
            reason = "工作区已有明确目标，且当前没有检测到明显阻塞。"
            summary = "当前工作区看起来在正常推进中。"
            if let label = snapshot.progressLabel, !label.isEmpty {
                nextAction = "继续当前计划，并围绕“\(label)”定期核对进展。"
            } else {
                nextAction = "继续执行，并把最新输出与工作区目标逐条比对。"
            }
            suggestedPrompt = "当前目标：\(normalizedGoal)\n请评估最新状态，判断任务是否在正轨上，并给出最安全的下一步。"
        }

        return WorkspaceSupervisorReview(
            health: health,
            summary: summary,
            reason: reason,
            nextAction: nextAction,
            suggestedPrompt: suggestedPrompt,
            source: "heuristic",
            model: nil,
            generatedAt: Date().timeIntervalSince1970
        )
    }

    static func prepareStartupPlan(
        snapshot: WorkspaceSupervisorSnapshot,
        interactions: String
    ) -> WorkspaceSupervisorStartupPlan {
        let trimmed = interactions.trimmingCharacters(in: .whitespacesAndNewlines)
        let interactionLines = trimmed
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let stage = stageLabel(snapshot: snapshot, interactions: trimmed)
        let contextLines = contextBulletLines(snapshot: snapshot)
        let inferredGoal = snapshot.goal.isEmpty
            ? (interactionLines.first ?? "整理需求并形成一个可执行、可验收的工作目标。")
            : snapshot.goal
        let progress = snapshot.recentLogs.isEmpty && snapshot.recentRunHeadlines.isEmpty
            ? "当前项目进度信息较少，需要先根据用户最近 2-3 轮交流补齐上下文；当前阶段判断为“\(stage)”。"
            : "已读取到最近工作区日志、监督记录与运行状态；当前阶段判断为“\(stage)”，可以据此快速定位当前进展与阻塞点。"
        let nextAction = interactionLines.isEmpty
            ? "先补充 2-3 轮用户需求或补充说明，再生成可执行开工建议。"
            : "基于最近交流整理目标、确认约束、拆出第一步可执行动作，然后立即开工。"
        let prompt = """
        请根据以下用户交流，提炼最终目标、当前进度判断、约束条件，并直接给出第一步执行动作。
        请优先结合这些工作区信号：
        \(contextLines.joined(separator: "\n"))

        当前判断阶段：\(stage)

        输出要求：
        1. 先用一句话说明当前到底处于哪个阶段。
        2. 给出一个可以立即执行的第一步。
        3. 如果信息不足，只允许提出一个最关键的澄清问题。

        最近用户交流：
        \(trimmed.isEmpty ? "暂无交流内容" : trimmed)
        """

        return WorkspaceSupervisorStartupPlan(
            goal: inferredGoal,
            progressSummary: progress,
            recommendedAction: nextAction,
            starterPrompt: prompt,
            assumptions: interactionLines.isEmpty ? "缺少最近交流内容，当前建议偏保守。" : "已根据最近 2-3 轮交流做了初步目标提炼，仍需你最终确认。",
            source: "heuristic",
            model: nil,
            generatedAt: Date().timeIntervalSince1970
        )
    }

    static func prepareExecutionBrief(
        snapshot: WorkspaceSupervisorSnapshot,
        review: WorkspaceSupervisorReview?,
        startupPlan: WorkspaceSupervisorStartupPlan?
    ) -> WorkspaceSupervisorExecutionBrief {
        let effectiveGoal = snapshot.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? (startupPlan?.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? startupPlan?.goal ?? "推进当前工作区任务。"
                : "推进当前工作区任务。")
            : snapshot.goal
        let effectiveAction = review?.nextAction ?? startupPlan?.recommendedAction ?? "检查当前状态并执行最小下一步。"
        let stage = stageLabel(snapshot: snapshot)
        let executionDirectory = snapshot.focusedPanelDirectory?.isEmpty == false
            ? snapshot.focusedPanelDirectory ?? snapshot.currentDirectory
            : snapshot.currentDirectory

        var executionSteps: [String] = [
            "先核对目标、完成标准和当前目录，确认本轮只推进“\(effectiveGoal)”。",
            effectiveAction,
            "优先在目录 \(executionDirectory) 内执行本轮动作，并记录关键输出。"
        ]
        if let remoteTarget = snapshot.remoteTarget, !remoteTarget.isEmpty {
            executionSteps.append("如果动作依赖远程环境，先确认 \(remoteTarget) 连接正常，再继续执行。")
        }

        var successSignals: [String] = []
        if let progressLabel = snapshot.progressLabel, !progressLabel.isEmpty {
            successSignals.append("进度标签出现新的推进信号：\(progressLabel)")
        }
        successSignals.append("最新日志不再出现明显错误，且输出能证明当前动作已经完成。")
        successSignals.append("完成后可以明确判断任务状态是继续推进、已阻塞，还是已完成。")

        var risks: [String] = []
        if snapshot.gitDirty {
            risks.append("仓库存在未提交修改，执行动作时不要覆盖已有改动。")
        }
        if let review, review.health == .blocked {
            risks.append("监督器已判断为阻塞状态，本轮应优先解阻，而不是继续扩张范围。")
        }
        if let remoteTarget = snapshot.remoteTarget, !remoteTarget.isEmpty {
            risks.append("当前动作可能依赖远程目标 \(remoteTarget)，需要避免在断连状态下误判执行结果。")
        }
        if risks.isEmpty {
            risks.append("不要扩大任务范围；如果信息不足，只补一个最关键的缺口。")
        }

        let constraintsText = (snapshot.constraints + "\n" + snapshot.scopeNotes)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let operatorPrompt = """
        You are executing one bounded step inside this workspace.

        Goal:
        \(effectiveGoal)

        Current stage:
        \(stage)

        Working directory:
        \(executionDirectory)

        Constraints:
        \(constraintsText.isEmpty ? "Use minimal, scope-safe changes only." : constraintsText)

        Do exactly this next:
        \(effectiveAction)

        Success signals:
        \(successSignals.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))

        Before stopping, summarize what changed, what remains, and whether the task is blocked, running, or complete.
        """

        return WorkspaceSupervisorExecutionBrief(
            title: "执行简报: \(stage)",
            objective: effectiveGoal,
            executionSteps: executionSteps,
            successSignals: successSignals,
            risks: risks,
            operatorPrompt: operatorPrompt,
            source: "heuristic",
            model: nil,
            generatedAt: Date().timeIntervalSince1970
        )
    }

    static func handoffStatus(for review: WorkspaceSupervisorReview?) -> String {
        switch review?.health {
        case .completed: return "completed"
        case .blocked: return "blocked"
        case .attention: return "attention"
        case .running: return "running"
        default: return "ready"
        }
    }

    static func handoffDisplayStatus(_ status: String) -> String {
        switch status {
        case "completed": return "已完成"
        case "blocked": return "已阻塞"
        case "attention": return "需关注"
        case "running": return "执行中"
        case "supporting": return "支援中"
        case "pending": return "待处理"
        default: return "就绪"
        }
    }
}

enum WorkspaceSupervisorSettings {
    static let endpointKey = "workspaceSupervisor.endpoint"
    static let apiKeyKey = "workspaceSupervisor.apiKey"
    static let modelKey = "workspaceSupervisor.model"
    static let operatorModeKey = "workspaceSupervisor.operatorMode"
    static let experienceModeKey = "workspaceSupervisor.experienceMode"
    static let defaultEndpoint = "https://api.openai.com/v1/chat/completions"
    static let defaultModel = "gpt-4.1-mini"
}

struct SupervisorPaneView: View {
    @ObservedObject var workspace: Workspace
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(WorkspaceSupervisorSettings.endpointKey) private var endpoint = WorkspaceSupervisorSettings.defaultEndpoint
    @AppStorage(WorkspaceSupervisorSettings.apiKeyKey) private var apiKey = ""
    @AppStorage(WorkspaceSupervisorSettings.modelKey) private var model = WorkspaceSupervisorSettings.defaultModel
    @AppStorage(WorkspaceSupervisorSettings.operatorModeKey) private var operatorModeRaw = WorkspaceSupervisorOperatorMode.suggest.rawValue
    @AppStorage(WorkspaceSupervisorSettings.experienceModeKey) private var experienceModeRaw = WorkspaceSupervisorExperienceMode.auto.rawValue
    @State private var isQuickStarting = false
    @State private var isRunningLLMReview = false
    @State private var isGeneratingStartupPlan = false
    @State private var isGeneratingExecutionBrief = false
    @State private var supervisorDispatchStatus: String?
    @State private var skillStudioStatus: String?
    @State private var advancedControlsExpanded = false
    @State private var llmSettingsSavedAt = Date()

    private var review: WorkspaceSupervisorReview? {
        workspace.supervisorLastReview
    }

    private var updatedText: String {
        guard let date = workspace.supervisorUpdatedAt else { return "尚未生成评估" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private var llmSavedText: String {
        "LLM 设置已自动保存到本机 \(llmSettingsSavedAt.formatted(date: .omitted, time: .shortened))"
    }

    private var reviewHealth: WorkspaceSupervisorHealth {
        review?.health ?? .idle
    }

    private var storedOperatorMode: WorkspaceSupervisorOperatorMode {
        WorkspaceSupervisorOperatorMode(rawValue: operatorModeRaw) ?? .suggest
    }

    private var experienceMode: WorkspaceSupervisorExperienceMode {
        WorkspaceSupervisorExperienceMode(rawValue: experienceModeRaw) ?? .auto
    }

    private var isAutoExperience: Bool {
        experienceMode == .auto
    }

    private var resolvedLLMConfiguration: WorkspaceSupervisorResolvedLLMConfiguration {
        let trimmedEndpoint = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let env = ProcessInfo.processInfo.environment

        if !trimmedAPIKey.isEmpty {
            return WorkspaceSupervisorResolvedLLMConfiguration(
                endpoint: trimmedEndpoint.isEmpty ? WorkspaceSupervisorSettings.defaultEndpoint : trimmedEndpoint,
                apiKey: trimmedAPIKey,
                model: trimmedModel.isEmpty ? WorkspaceSupervisorSettings.defaultModel : trimmedModel,
                sourceLabel: "本机已保存",
                isImplicit: false
            )
        }

        if let openRouterKey = env["OPENROUTER_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines),
           !openRouterKey.isEmpty {
            let openRouterEndpoint = env["OPENROUTER_BASE_URL"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedEndpoint = openRouterEndpoint?.isEmpty == false
                ? openRouterEndpoint!
                : "https://openrouter.ai/api/v1/chat/completions"
            return WorkspaceSupervisorResolvedLLMConfiguration(
                endpoint: resolvedEndpoint,
                apiKey: openRouterKey,
                model: trimmedModel.isEmpty ? WorkspaceSupervisorSettings.defaultModel : trimmedModel,
                sourceLabel: "环境变量 OpenRouter",
                isImplicit: true
            )
        }

        if let openAIKey = env["OPENAI_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines),
           !openAIKey.isEmpty {
            let baseURL = env["OPENAI_BASE_URL"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let openAIModel = env["OPENAI_MODEL"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedEndpoint: String
            if let baseURL, !baseURL.isEmpty {
                if baseURL.hasSuffix("/chat/completions") {
                    resolvedEndpoint = baseURL
                } else {
                    resolvedEndpoint = baseURL.hasSuffix("/") ? baseURL + "chat/completions" : baseURL + "/chat/completions"
                }
            } else {
                resolvedEndpoint = trimmedEndpoint.isEmpty ? WorkspaceSupervisorSettings.defaultEndpoint : trimmedEndpoint
            }
            return WorkspaceSupervisorResolvedLLMConfiguration(
                endpoint: resolvedEndpoint,
                apiKey: openAIKey,
                model: (openAIModel?.isEmpty == false ? openAIModel! : nil)
                    ?? (trimmedModel.isEmpty ? WorkspaceSupervisorSettings.defaultModel : trimmedModel),
                sourceLabel: "环境变量 OpenAI",
                isImplicit: true
            )
        }

        return WorkspaceSupervisorResolvedLLMConfiguration(
            endpoint: trimmedEndpoint.isEmpty ? WorkspaceSupervisorSettings.defaultEndpoint : trimmedEndpoint,
            apiKey: "",
            model: trimmedModel.isEmpty ? WorkspaceSupervisorSettings.defaultModel : trimmedModel,
            sourceLabel: "启发式模式",
            isImplicit: false
        )
    }

    private var operatorMode: WorkspaceSupervisorOperatorMode {
        if isAutoExperience {
            return workspace.supervisorRecommendedOperatorMode()
        }
        return storedOperatorMode
    }

    private var zeroConfigBootstrap: WorkspaceSupervisorZeroConfigBootstrap {
        workspace.supervisorZeroConfigBootstrap(
            preferredMode: operatorMode,
            llmConfigured: !resolvedLLMConfiguration.apiKey.isEmpty
        )
    }

    private var operatorProfile: WorkspaceSupervisorOperatorProfile {
        workspace.supervisorOperatorProfile(mode: operatorMode)
    }

    private var skillBlueprint: WorkspaceSupervisorSkillBlueprint {
        workspace.supervisorSkillBlueprint(mode: operatorMode)
    }

    private var recentRuns: [WorkspaceSupervisorRunEntry] {
        Array(workspace.supervisorRunJournal.prefix(5))
    }

    private var recentPanelStates: [WorkspaceSupervisorPanelRoundState] {
        Array(
            workspace.supervisorPanelRoundStates
                .sorted { lhs, rhs in
                    lhs.lastUpdatedAt > rhs.lastUpdatedAt
                }
                .prefix(4)
        )
    }

    private var queueItems: [WorkspaceSupervisorQueueItem] {
        Array(workspace.supervisorExecutionQueue.prefix(4))
    }

    private var automationReadiness: WorkspaceSupervisorAutomationReadiness {
        workspace.supervisorAutomationReadiness()
    }

    private var modeAllowsDispatch: Bool {
        switch operatorMode {
        case .drive, .autonomy:
            return true
        case .observe, .suggest:
            return false
        }
    }

    private var modeAllowsAutonomyLoop: Bool {
        operatorMode == .autonomy
    }

    private var modeRestrictionNote: String? {
        switch operatorMode {
        case .observe:
            return "当前模式仅用于观察与复盘，不会直接向窗口派发动作。"
        case .suggest:
            return "当前模式会生成计划、任务包和技能蓝图，但不会直接接管终端。"
        case .drive:
            return "当前模式允许手动派发到终端窗口，但不会自动轮转多个窗口。"
        case .autonomy:
            return nil
        }
    }

    private var canSendToCurrentWindow: Bool {
        modeAllowsDispatch && workspace.canDispatchSupervisorPrompt(preferredPanelID: workspace.focusedPanelId)
    }

    private var canSendToActiveWindow: Bool {
        modeAllowsDispatch && workspace.canDispatchSupervisorPrompt(preferredPanelID: workspace.supervisorActiveLoopTarget?.panelID)
    }

    private var loopStateText: String {
        workspace.supervisorLoopState.displayText
    }

    private var interactionLines: [String] {
        workspace.supervisorInteractionNotes
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var interactionCharacterCount: Int {
        workspace.supervisorInteractionNotes
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .count
    }

    private var canQuickStartSupervisor: Bool {
        !workspace.supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || interactionLines.count >= 2
            || interactionCharacterCount >= 32
    }

    private var quickStartStatusText: String {
        if !workspace.supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "已具备明确目标，可以直接生成执行简报并进入监督。"
        }
        if interactionLines.count >= 2 || interactionCharacterCount >= 32 {
            return "最近交流信息已足够，监督器可以直接提炼目标并开工。"
        }
        return "再补充 2-3 轮用户交流，或直接填写目标，即可一键进入自动化监督。"
    }

    private var quickStartButtonTitle: String {
        resolvedLLMConfiguration.apiKey.isEmpty ? "一键开工" : "一键开工（LLM 增强）"
    }

    private var metricColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 120, maximum: 180), spacing: 10, alignment: .top)]
    }

    private var compactInfoColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 220, maximum: .infinity), spacing: 12, alignment: .top)]
    }

    var body: some View {
        let readiness = automationReadiness
        let snapshot = workspace.supervisorSnapshot
        let llmConfig = resolvedLLMConfiguration
        let bootstrap = zeroConfigBootstrap
        let profile = operatorProfile
        let blueprint = skillBlueprint

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ICCSidebarCard(emphasized: true) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 12) {
                            ICCIconBadge(
                                systemImage: "brain.head.profile",
                                primary: reviewHealth.tint,
                                secondary: ICCChrome.secondaryAccent(for: colorScheme)
                            )

                            VStack(alignment: .leading, spacing: 5) {
                                HStack(alignment: .center, spacing: 8) {
                                    Text("监督器 / Operator")
                                        .font(.title3.weight(.semibold))
                                    ICCStatusPill(text: reviewHealth.displayText, tint: reviewHealth.tint, emphasized: reviewHealth != .idle)
                                    ICCStatusPill(text: profile.authority.displayText, tint: profile.authority.tint)
                                    if workspace.supervisorLoopState == .running {
                                        ICCStatusPill(text: loopStateText, tint: ICCChrome.secondaryAccent(for: colorScheme))
                                    }
                                }

                                Text(profile.missionTitle)
                                    .font(.system(size: 14.5, weight: .semibold))
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(profile.missionSummary)
                                    .font(.system(size: 12.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text("LLM: \(llmConfig.sourceLabel)")
                                    .font(.system(size: 11.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 0)
                        }

                        LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 10) {
                            ICCMetricCard(title: "监督状态", value: reviewHealth.displayText, subtitle: updatedText, tint: reviewHealth.tint)
                            ICCMetricCard(title: "操作模式", value: operatorMode.displayText, subtitle: operatorMode.subtitle, tint: operatorMode.tint)
                            ICCMetricCard(title: "窗口交接", value: "\(workspace.supervisorPanelHandoffs.count)", subtitle: "可编排窗口", tint: .blue)
                            ICCMetricCard(title: "空闲终端", value: "\(readiness.promptReadyCount)", subtitle: "可安全派发", tint: readiness.promptReadyCount > 0 ? .green : .secondary)
                            ICCMetricCard(title: "已访目录", value: "\(snapshot.observedDirectories.count)", subtitle: "当前上下文", tint: .teal)
                            ICCMetricCard(
                                title: "远程状态",
                                value: snapshot.remoteTarget == nil ? "本地" : readiness.statusText,
                                subtitle: snapshot.remoteTarget ?? "未连接远程主机",
                                tint: snapshot.remoteTarget == nil ? .secondary : (snapshot.remoteState == "connected" ? .green : .orange)
                            )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            SupervisorSectionHeader(title: "工作方式", subtitle: "默认使用零配置自动推断；需要时再切换到专家模式。")

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: .infinity), spacing: 8)], alignment: .leading, spacing: 8) {
                                ForEach(WorkspaceSupervisorExperienceMode.allCases) { mode in
                                    SupervisorExperienceButton(mode: mode, isSelected: experienceMode == mode) {
                                        experienceModeRaw = mode.rawValue
                                        advancedControlsExpanded = mode == .expert
                                        supervisorDispatchStatus = nil
                                    }
                                }
                            }
                        }

                        HStack(alignment: .center, spacing: 10) {
                            Toggle("启用监督", isOn: $workspace.supervisorEnabled)
                                .toggleStyle(.switch)
                                .controlSize(.small)

                            Spacer(minLength: 0)

                            Button("刷新判断") {
                                workspace.refreshSupervisorHeuristicReview()
                            }
                            .buttonStyle(SupervisorSecondaryButtonStyle())
                            .disabled(!workspace.supervisorEnabled)

                            if !isAutoExperience {
                                Button(isRunningLLMReview ? "评估中..." : "运行 LLM 评估") {
                                    Task {
                                        isRunningLLMReview = true
                                        await workspace.requestSupervisorLLMReview(
                                            endpoint: llmConfig.endpoint,
                                            apiKey: llmConfig.apiKey,
                                            model: llmConfig.model
                                        )
                                        isRunningLLMReview = false
                                    }
                                }
                                .buttonStyle(SupervisorPrimaryButtonStyle())
                                .disabled(!workspace.supervisorEnabled || isRunningLLMReview)

                                Button(isQuickStarting ? "开工中..." : quickStartButtonTitle) {
                                    Task {
                                        isQuickStarting = true
                                        await runZeroConfigContinue(using: bootstrap, llmConfig: llmConfig)
                                        isQuickStarting = false
                                    }
                                }
                                .buttonStyle(SupervisorSecondaryButtonStyle())
                                .disabled(isQuickStarting)
                            }
                        }

                        if let modeRestrictionNote {
                            SupervisorInfoTile(title: "当前边界", content: modeRestrictionNote)
                        }
                    }
                }

                ICCSidebarCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("零配置启动")
                                    .font(.system(size: 15, weight: .semibold))
                                Text(bootstrap.headline)
                                    .font(.system(size: 12.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                            ICCStatusPill(text: bootstrap.projectLabel, tint: .blue)
                        }

                        SupervisorInfoTile(title: "推荐动作", content: bootstrap.summary)

                        if !bootstrap.badges.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(bootstrap.badges, id: \.self) { badge in
                                        ICCStatusPill(text: badge, tint: .teal)
                                    }
                                }
                            }
                        }

                        HStack(spacing: 10) {
                            Button(isQuickStarting ? "处理中..." : bootstrap.primaryActionTitle) {
                                Task {
                                    isQuickStarting = true
                                    await runZeroConfigContinue(using: bootstrap, llmConfig: llmConfig)
                                    isQuickStarting = false
                                }
                            }
                            .buttonStyle(SupervisorPrimaryButtonStyle())
                            .disabled(isQuickStarting)

                            if isAutoExperience {
                                Button(advancedControlsExpanded ? "收起高级控制" : "展开高级控制") {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        advancedControlsExpanded.toggle()
                                    }
                                }
                                .buttonStyle(SupervisorSecondaryButtonStyle())
                            }
                        }
                    }
                }

                if !isAutoExperience || advancedControlsExpanded {
                    LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                    ICCSidebarCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SupervisorSectionHeader(title: "任务章程", subtitle: "先定义目标、验收标准与边界，再让监督器接管。")
                            SupervisorInfoTile(title: "任务指令", content: profile.accessSummary)
                            SupervisorLabeledEditor(
                                title: "目标",
                                text: Binding(
                                    get: { workspace.supervisorTaskCharter.goal },
                                    set: {
                                        workspace.supervisorTaskCharter.goal = $0
                                        workspace.supervisorGoal = $0
                                    }
                                ),
                                minHeight: 92
                            )
                            SupervisorLabeledEditor(title: "完成标准", text: $workspace.supervisorTaskCharter.doneDefinition, minHeight: 72)
                            SupervisorLabeledEditor(title: "约束条件", text: $workspace.supervisorTaskCharter.constraints, minHeight: 72)
                            SupervisorLabeledEditor(title: "执行范围", text: $workspace.supervisorTaskCharter.scopeNotes, minHeight: 72)
                        }
                    }

                    ICCSidebarCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SupervisorSectionHeader(title: "权限与环境", subtitle: "把终端、浏览器、文件与远程环境汇总成一个实时操作面。")
                            if !isAutoExperience {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: .infinity), spacing: 8)], alignment: .leading, spacing: 8) {
                                    ForEach(WorkspaceSupervisorOperatorMode.allCases) { mode in
                                        SupervisorModeButton(mode: mode, isSelected: storedOperatorMode == mode) {
                                            operatorModeRaw = mode.rawValue
                                        }
                                    }
                                }
                            }
                            HStack(spacing: 8) {
                                ICCStatusPill(text: operatorMode.displayText, tint: operatorMode.tint, emphasized: true)
                                ICCStatusPill(text: profile.authority.displayText, tint: profile.authority.tint)
                                ICCStatusPill(text: readiness.statusText, tint: readiness.promptReadyCount > 0 ? .green : .orange)
                            }

                            SupervisorInfoTile(title: "接管范围", content: profile.authority.subtitle)
                            SupervisorInfoTile(title: "环境摘要", content: profile.accessSummary)

                            if !profile.operatingNotes.isEmpty {
                                SupervisorListTile(title: "操作建议", items: Array(profile.operatingNotes.prefix(4)))
                            }
                        }
                    }
                    }

                    ICCSidebarCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SupervisorSectionHeader(title: "工具权限矩阵", subtitle: "让监督器明确知道自己到底能接管什么、哪里要保守、哪里可以直接推进。")
                            LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                                ForEach(profile.capabilityStates) { capability in
                                    SupervisorCapabilityTile(capability: capability)
                                }
                            }
                        }
                    }

                    LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                        ICCSidebarCard {
                            VStack(alignment: .leading, spacing: 12) {
                                SupervisorSectionHeader(title: "最近 2-3 轮用户交流", subtitle: "监督器会根据这些交流快速提炼目标、进度和第一步动作。")
                                SupervisorLabeledEditor(title: "交流摘要", text: $workspace.supervisorInteractionNotes, minHeight: 144)
                                SupervisorInfoTile(title: "最快开工路径", content: quickStartStatusText)

                                HStack(spacing: 10) {
                                    Button(isGeneratingStartupPlan ? "生成中..." : "生成开工建议") {
                                        Task {
                                            isGeneratingStartupPlan = true
                                            await workspace.requestSupervisorStartupPlan(
                                                endpoint: llmConfig.endpoint,
                                                apiKey: llmConfig.apiKey,
                                                model: llmConfig.model
                                            )
                                            isGeneratingStartupPlan = false
                                        }
                                    }
                                    .buttonStyle(SupervisorPrimaryButtonStyle())

                                    if let startupPlan = workspace.supervisorStartupPlan, !startupPlan.goal.isEmpty {
                                        Button("采用建议目标") {
                                            workspace.supervisorTaskCharter.goal = startupPlan.goal
                                            workspace.supervisorGoal = startupPlan.goal
                                            workspace.supervisorEnabled = true
                                            workspace.scheduleSupervisorHeuristicRefresh(delay: 0.1)
                                        }
                                        .buttonStyle(SupervisorSecondaryButtonStyle())
                                    }
                                }

                                if let startupPlan = workspace.supervisorStartupPlan {
                                    SupervisorInfoTile(title: "建议目标", content: startupPlan.goal)
                                    SupervisorInfoTile(title: "进度判断", content: startupPlan.progressSummary)
                                    SupervisorInfoTile(title: "建议下一步", content: startupPlan.recommendedAction)
                                    SupervisorPromptDisclosure(title: "开工提示词", prompt: startupPlan.starterPrompt)
                                }
                            }
                        }

                        ICCSidebarCard {
                            VStack(alignment: .leading, spacing: 12) {
                                SupervisorSectionHeader(title: "工作区上下文", subtitle: "把目录、Git、远程目标和已访问路径压缩成监督器可直接使用的上下文。")
                                SupervisorInfoTile(title: "当前目录", content: snapshot.currentDirectory, monospaced: true)

                                if let gitBranch = snapshot.gitBranch, !gitBranch.isEmpty {
                                    SupervisorInfoTile(
                                        title: "Git 状态",
                                        content: "\(gitBranch)\(snapshot.gitDirty ? " · 有未提交改动" : " · 工作区干净")",
                                        monospaced: true
                                    )
                                }

                                if let remoteTarget = snapshot.remoteTarget, !remoteTarget.isEmpty {
                                    let remoteCompatibility = snapshot.remoteCompatibility?.trimmingCharacters(in: .whitespacesAndNewlines)
                                    SupervisorInfoTile(
                                        title: "远程目标",
                                        content: remoteCompatibility?.isEmpty == false ? "\(remoteTarget)\n\(remoteCompatibility!)" : remoteTarget,
                                        monospaced: true
                                    )
                                }

                                if !snapshot.observedDirectories.isEmpty {
                                    SupervisorListTile(title: "已访问目录", items: snapshot.observedDirectories, monospaced: true)
                                }
                            }
                        }
                    }
                }

                ICCSidebarCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .center, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("执行任务包")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("把当前目标、动作边界、成功信号与派发入口整理成一个可直接执行的包。")
                                    .font(.system(size: 11.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)

                            Button(isGeneratingExecutionBrief ? "生成中..." : "生成任务包") {
                                Task {
                                    isGeneratingExecutionBrief = true
                                    await workspace.requestSupervisorExecutionBrief(
                                        endpoint: llmConfig.endpoint,
                                        apiKey: llmConfig.apiKey,
                                        model: llmConfig.model
                                    )
                                    isGeneratingExecutionBrief = false
                                }
                            }
                            .buttonStyle(SupervisorSecondaryButtonStyle())

                            Button("发送到当前窗口") {
                                supervisorDispatchStatus = workspace.dispatchSupervisorPromptToCurrentPanel()
                            }
                            .buttonStyle(SupervisorSecondaryButtonStyle())
                            .disabled(!canSendToCurrentWindow)

                            Button("发送到循环窗口") {
                                supervisorDispatchStatus = workspace.dispatchSupervisorPromptToActiveLoopPanel()
                            }
                            .buttonStyle(SupervisorPrimaryButtonStyle())
                            .disabled(!canSendToActiveWindow)
                        }

                        if let supervisorDispatchStatus,
                           !supervisorDispatchStatus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            SupervisorInfoTile(title: "操作反馈", content: supervisorDispatchStatus)
                        }

                        if let executionBrief = workspace.supervisorExecutionBrief {
                            LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                                SupervisorInfoTile(title: "执行标题", content: executionBrief.title)
                                SupervisorInfoTile(title: "执行目标", content: executionBrief.objective)
                                SupervisorListTile(title: "执行步骤", items: executionBrief.executionSteps)
                                SupervisorListTile(title: "成功信号", items: executionBrief.successSignals)
                                SupervisorListTile(title: "风险提醒", items: executionBrief.risks)
                            }

                            Button("复制执行提示词") {
                                copyToPasteboard(executionBrief.operatorPrompt)
                                supervisorDispatchStatus = "执行提示词已复制到剪贴板。"
                            }
                            .buttonStyle(SupervisorSecondaryButtonStyle())

                            SupervisorPromptDisclosure(title: "执行提示词", prompt: executionBrief.operatorPrompt)
                        } else {
                            SupervisorInfoTile(
                                title: "尚无任务包",
                                content: "生成后会提供一个边界清晰的执行包，包含当前目标、执行步骤、成功信号和可直接派发的提示词。"
                            )
                        }

                        if let modeRestrictionNote {
                            SupervisorInfoTile(title: "派发边界", content: modeRestrictionNote)
                        }
                    }
                }

                if !isAutoExperience || advancedControlsExpanded {
                    ICCSidebarCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("执行编排")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("借鉴多会话网关与自动循环的方式，把当前窗口、支援窗口和轮转队列整理成可跟踪编排。")
                                        .font(.system(size: 11.5, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                                Button("刷新编排") {
                                    workspace.refreshSupervisorPanelHandoffs()
                                }
                                .buttonStyle(SupervisorSecondaryButtonStyle())
                            }

                            if let activeTarget = workspace.supervisorActiveLoopTarget {
                                SupervisorInfoTile(
                                    title: "当前循环目标",
                                    content: """
                                    窗口: \(activeTarget.panelTitle)
                                    目录: \(activeTarget.workingDirectory)
                                    选定时间: \(Date(timeIntervalSince1970: activeTarget.selectedAt).formatted(date: .omitted, time: .shortened))
                                    """,
                                    monospaced: true
                                )
                            }

                            if !profile.laneSummaries.isEmpty {
                                SupervisorListTile(title: "编排摘要", items: profile.laneSummaries)
                            }

                            if workspace.supervisorPanelHandoffs.isEmpty {
                                SupervisorInfoTile(
                                    title: "尚无交接窗口",
                                    content: "交接合同会按当前活跃窗口生成。每个窗口都会有自己的角色、下一步动作和执行提示词。"
                                )
                            } else {
                                LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                                    ForEach(workspace.supervisorPanelHandoffs.prefix(4)) { handoff in
                                        SupervisorLaneTile(
                                            title: handoff.panelTitle,
                                            status: WorkspaceSupervisorHeuristics.handoffDisplayStatus(handoff.status),
                                            subtitle: handoff.nextAction,
                                            directory: handoff.workingDirectory
                                        )
                                    }
                                }
                            }

                            if !queueItems.isEmpty {
                                LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                                    ForEach(queueItems) { item in
                                        SupervisorLaneTile(
                                            title: "#\(item.priority) \(item.panelTitle)",
                                            status: item.readiness,
                                            subtitle: item.nextMilestone,
                                            directory: item.rotationRule
                                        )
                                    }
                                }
                            }

                            if !recentPanelStates.isEmpty {
                                LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                                    ForEach(recentPanelStates) { state in
                                        SupervisorLaneTile(
                                            title: state.panelTitle,
                                            status: WorkspaceSupervisorHeuristics.handoffDisplayStatus(state.status),
                                            subtitle: state.nextAction,
                                            directory: state.workingDirectory
                                        )
                                    }
                                }
                            }
                        }
                    }

                    ICCSidebarCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("技能工坊")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("把当前工作区的最佳执行方法、目录边界和工具权限沉淀成可复用技能蓝图。")
                                        .font(.system(size: 11.5, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)

                                Button("复制蓝图提示词") {
                                    copyToPasteboard(blueprint.seedPrompt)
                                    skillStudioStatus = "技能蓝图提示词已复制到剪贴板。"
                                }
                                .buttonStyle(SupervisorSecondaryButtonStyle())

                                Button("导出蓝图文件") {
                                    exportSkillBlueprint(blueprint)
                                }
                                .buttonStyle(SupervisorPrimaryButtonStyle())
                            }

                            if let skillStudioStatus,
                               !skillStudioStatus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                SupervisorInfoTile(title: "导出结果", content: skillStudioStatus)
                            }

                            LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                                SupervisorInfoTile(title: "蓝图标题", content: blueprint.title)
                                SupervisorInfoTile(title: "推荐目录", content: blueprint.recommendedDirectory, monospaced: true)
                                SupervisorInfoTile(title: "触发条件", content: blueprint.trigger)
                                SupervisorInfoTile(title: "技能摘要", content: blueprint.summary)
                                SupervisorListTile(title: "工具集合", items: blueprint.toolset)
                                SupervisorListTile(title: "执行步骤", items: blueprint.steps)
                                SupervisorListTile(title: "守护规则", items: blueprint.guardrails)
                            }

                            SupervisorPromptDisclosure(title: "技能种子提示词", prompt: blueprint.seedPrompt)
                        }
                    }

                    LazyVGrid(columns: compactInfoColumns, alignment: .leading, spacing: 12) {
                        ICCSidebarCard {
                            VStack(alignment: .leading, spacing: 12) {
                                SupervisorSectionHeader(title: "自动循环", subtitle: "适用于多窗口并行推进。自治模式下，监督器会轮转窗口、持续评估和复盘。")
                                LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 10) {
                                    ICCMetricCard(title: "Shell 集成", value: readiness.shellIntegrationMode, subtitle: readiness.shellIntegrationInjected ? "已注入" : "未注入")
                                    ICCMetricCard(title: "终端窗口", value: "\(readiness.terminalPanelCount)", subtitle: "当前工作区内的终端")
                                    ICCMetricCard(title: "运行中", value: "\(readiness.runningCount)", subtitle: "仍在执行命令")
                                    ICCMetricCard(title: "待确认", value: "\(readiness.unknownCount)", subtitle: "尚未回报 shell 状态")
                                }

                                VStack(alignment: .leading, spacing: 10) {
                                    Stepper("最大轮次 \(workspace.supervisorLoopSettings.maxIterations)", value: $workspace.supervisorLoopSettings.maxIterations, in: 1...12)
                                    Stepper(
                                        "间隔 \(Int(workspace.supervisorLoopSettings.intervalSeconds)) 秒",
                                        value: $workspace.supervisorLoopSettings.intervalSeconds,
                                        in: 1...30,
                                        step: 1
                                    )
                                }

                                Toggle("循环时使用 LLM 评估", isOn: $workspace.supervisorLoopSettings.useLLMReview)
                                Toggle("遇到阻塞时停止", isOn: $workspace.supervisorLoopSettings.stopOnBlocked)
                                Toggle("识别完成时停止", isOn: $workspace.supervisorLoopSettings.stopOnCompleted)

                                HStack(spacing: 10) {
                                    Button(workspace.supervisorLoopState == .running ? "循环执行中..." : "启动自动循环") {
                                        Task {
                                            await workspace.runSupervisorAutonomyLoop(
                                                endpoint: llmConfig.endpoint,
                                                apiKey: llmConfig.apiKey,
                                                model: llmConfig.model
                                            )
                                        }
                                    }
                                    .buttonStyle(SupervisorPrimaryButtonStyle())
                                    .disabled(!workspace.supervisorEnabled || workspace.supervisorLoopState == .running || !modeAllowsAutonomyLoop)

                                    Button("停止循环") {
                                        workspace.stopSupervisorAutonomyLoop(reason: "manual")
                                    }
                                    .buttonStyle(SupervisorSecondaryButtonStyle())
                                    .disabled(workspace.supervisorLoopState != .running)
                                }

                                if let summary = workspace.supervisorLoopStatusSummary, !summary.isEmpty {
                                    SupervisorInfoTile(title: "循环状态", content: summary)
                                }

                                if !readiness.notes.isEmpty {
                                    SupervisorListTile(title: "自动化建议", items: readiness.notes)
                                }

                                if !modeAllowsAutonomyLoop {
                                    SupervisorInfoTile(title: "自治边界", content: "只有切换到“自治”模式后，监督器才会自动轮转多个窗口。")
                                }
                            }
                        }
                    }
                }

                ICCSidebarCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SupervisorSectionHeader(title: "监督洞察", subtitle: "保留当前判断、阻塞原因和最近运行记录，方便快速复盘。")

                        if let review {
                            SupervisorInfoTile(title: "进度摘要", content: review.summary)
                            SupervisorInfoTile(title: "判断依据", content: review.reason)
                            SupervisorInfoTile(title: "当前建议动作", content: review.nextAction)
                            SupervisorPromptDisclosure(title: "监督提示词", prompt: review.suggestedPrompt)
                        } else {
                            SupervisorInfoTile(title: "进度摘要", content: "正在整理当前工作区状态，稍后会生成监督判断。")
                        }

                        Button("记录当前判断") {
                            workspace.recordSupervisorCheckpoint(source: "manual")
                        }
                        .buttonStyle(SupervisorSecondaryButtonStyle())

                        if recentRuns.isEmpty {
                            SupervisorInfoTile(
                                title: "暂无运行记录",
                                content: "生成开工建议、刷新判断或运行 LLM 评估后，这里会保留最近的监督记录。"
                            )
                        } else {
                            ForEach(recentRuns) { entry in
                                SupervisorRunEntryCard(entry: entry)
                            }
                        }
                    }
                }

                if !isAutoExperience || advancedControlsExpanded || resolvedLLMConfiguration.apiKey.isEmpty {
                    ICCSidebarCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SupervisorSectionHeader(title: "LLM 设置", subtitle: "监督器会优先使用本机保存的配置，其次尝试兼容的环境变量。")
                            TextField("接口地址", text: $endpoint)
                                .textFieldStyle(.roundedBorder)
                            TextField("模型名称", text: $model)
                                .textFieldStyle(.roundedBorder)
                            SecureField("API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                            Text("当前来源：\(llmConfig.sourceLabel)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(llmSavedText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Text("最近更新时间：\(updatedText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(Color.clear)
        .onAppear {
            if experienceMode == .expert {
                advancedControlsExpanded = true
            }
            if workspace.supervisorPanelHandoffs.isEmpty {
                workspace.refreshSupervisorPanelHandoffs()
            }
            if workspace.supervisorEnabled, workspace.supervisorLastReview == nil {
                workspace.scheduleSupervisorHeuristicRefresh(delay: 0.1)
            }
        }
        .onChange(of: endpoint) { llmSettingsSavedAt = Date() }
        .onChange(of: model) { llmSettingsSavedAt = Date() }
        .onChange(of: apiKey) { llmSettingsSavedAt = Date() }
        .onChange(of: experienceModeRaw) {
            advancedControlsExpanded = experienceMode == .expert
        }
        .onChange(of: workspace.supervisorEnabled) {
            if workspace.supervisorEnabled {
                workspace.scheduleSupervisorHeuristicRefresh(delay: 0.1)
            } else {
                workspace.publishSupervisorStatusEntry()
            }
        }
        .onChange(of: workspace.supervisorGoal) {
            guard workspace.supervisorEnabled else { return }
            workspace.scheduleSupervisorHeuristicRefresh(delay: 0.45)
        }
        .onChange(of: workspace.supervisorTaskCharter.doneDefinition) {
            guard workspace.supervisorEnabled else { return }
            workspace.scheduleSupervisorHeuristicRefresh(delay: 0.45)
        }
        .onChange(of: workspace.supervisorTaskCharter.constraints) {
            guard workspace.supervisorEnabled else { return }
            workspace.scheduleSupervisorHeuristicRefresh(delay: 0.45)
        }
        .onChange(of: workspace.supervisorTaskCharter.scopeNotes) {
            guard workspace.supervisorEnabled else { return }
            workspace.scheduleSupervisorHeuristicRefresh(delay: 0.45)
        }
        .onChange(of: workspace.supervisorInteractionNotes) {
            let trimmed = workspace.supervisorInteractionNotes.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            workspace.supervisorStartupPlan = WorkspaceSupervisorHeuristics.prepareStartupPlan(
                snapshot: workspace.supervisorSnapshot,
                interactions: trimmed
            )
            workspace.supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
                snapshot: workspace.supervisorSnapshot,
                review: workspace.supervisorLastReview,
                startupPlan: workspace.supervisorStartupPlan
            )
            if workspace.supervisorEnabled {
                workspace.scheduleSupervisorHeuristicRefresh(delay: 0.45)
            }
        }
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func runZeroConfigContinue(
        using bootstrap: WorkspaceSupervisorZeroConfigBootstrap,
        llmConfig: WorkspaceSupervisorResolvedLLMConfiguration
    ) async {
        if workspace.supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !bootstrap.recommendedGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            workspace.supervisorTaskCharter.goal = bootstrap.recommendedGoal
            workspace.supervisorGoal = bootstrap.recommendedGoal
        }

        if workspace.supervisorInteractionNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !bootstrap.interactionSeed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            workspace.supervisorInteractionNotes = bootstrap.interactionSeed
        }

        workspace.supervisorEnabled = true
        await workspace.quickStartSupervisor(
            endpoint: llmConfig.endpoint,
            apiKey: llmConfig.apiKey,
            model: llmConfig.model
        )
    }

    private func exportSkillBlueprint(_ blueprint: WorkspaceSupervisorSkillBlueprint) {
        let baseDirectory = workspace.currentDirectory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? FileManager.default.currentDirectoryPath
            : workspace.currentDirectory
        let exportDirectory = URL(fileURLWithPath: baseDirectory, isDirectory: true)
            .appendingPathComponent(".icc", isDirectory: true)
            .appendingPathComponent("skill-blueprints", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
            let targetURL = exportDirectory.appendingPathComponent(blueprint.suggestedFilename, isDirectory: false)
            try blueprint.markdown.write(to: targetURL, atomically: true, encoding: .utf8)
            skillStudioStatus = "技能蓝图已导出到 \(targetURL.path)"
        } catch {
            skillStudioStatus = "技能蓝图导出失败：\(error.localizedDescription)"
        }
    }
}

private extension WorkspaceSupervisorOperatorMode {
    var tint: Color {
        switch self {
        case .observe: .secondary
        case .suggest: .teal
        case .drive: .blue
        case .autonomy: .orange
        }
    }
}

private extension WorkspaceSupervisorExperienceMode {
    var tint: Color {
        switch self {
        case .auto: .teal
        case .expert: .orange
        }
    }
}

private extension WorkspaceSupervisorAuthorityLevel {
    var tint: Color {
        switch self {
        case .limited: .secondary
        case .standard: .teal
        case .elevated: .blue
        case .orchestrator: .orange
        }
    }
}

private extension WorkspaceSupervisorCapabilityAvailability {
    var tint: Color {
        switch self {
        case .ready: .green
        case .partial: .blue
        case .caution: .orange
        case .unavailable: .secondary
        }
    }
}

private struct SupervisorSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            Text(subtitle)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct SupervisorExperienceButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let mode: WorkspaceSupervisorExperienceMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(mode.displayText)
                        .font(.system(size: 12.5, weight: .semibold))
                    Spacer(minLength: 0)
                    ICCStatusPill(text: isSelected ? "默认" : "可切换", tint: mode.tint, emphasized: isSelected)
                }
                Text(mode.subtitle)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? ICCChrome.cardGradient(for: colorScheme, emphasized: true) : ICCChrome.cardGradient(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(mode.tint.opacity(isSelected ? 0.42 : 0.12), lineWidth: isSelected ? 1.4 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SupervisorModeButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let mode: WorkspaceSupervisorOperatorMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(mode.displayText)
                        .font(.system(size: 12.5, weight: .semibold))
                    Spacer(minLength: 0)
                    ICCStatusPill(text: isSelected ? "已选中" : "可切换", tint: mode.tint, emphasized: isSelected)
                }
                Text(mode.subtitle)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? ICCChrome.cardGradient(for: colorScheme, emphasized: true) : ICCChrome.cardGradient(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(mode.tint.opacity(isSelected ? 0.42 : 0.12), lineWidth: isSelected ? 1.4 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SupervisorInfoTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let content: String
    var monospaced: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(content.isEmpty ? "暂无内容" : content)
                .font(monospaced ? .system(size: 12, design: .monospaced) : .system(size: 12))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ICCChrome.cardGradient(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9), lineWidth: 1)
                )
        )
    }
}

private struct SupervisorListTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let items: [String]
    var monospaced: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(.secondary)

            if items.isEmpty {
                Text("暂无内容")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text(item)
                                .font(monospaced ? .system(size: 12, design: .monospaced) : .system(size: 12))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .textSelection(.enabled)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ICCChrome.cardGradient(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9), lineWidth: 1)
                )
        )
    }
}

private struct SupervisorCapabilityTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let capability: WorkspaceSupervisorCapabilityState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: capability.kind.systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(capability.availability.tint)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 3) {
                    Text(capability.kind.title)
                        .font(.system(size: 12.5, weight: .semibold))
                    Text(capability.kind.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                ICCStatusPill(text: capability.availability.displayText, tint: capability.availability.tint, emphasized: capability.availability == .ready)
            }

            Text(capability.summary)
                .font(.system(size: 12.5, weight: .semibold))

            Text(capability.detail)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ICCChrome.cardGradient(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(capability.availability.tint.opacity(0.16), lineWidth: 1)
                )
        )
    }
}

private struct SupervisorLaneTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let status: String
    let subtitle: String
    let directory: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(2)
                Spacer(minLength: 0)
                ICCStatusPill(text: status, tint: .blue)
            }

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(directory)
                .font(.system(size: 11.5, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ICCChrome.cardGradient(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9), lineWidth: 1)
                )
        )
    }
}

private struct SupervisorPromptDisclosure: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let prompt: String
    private let maxPromptHeight: CGFloat = 220

    var body: some View {
        DisclosureGroup {
            Group {
                if prompt.isEmpty {
                    Text("暂无提示词")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        Text(prompt)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.primary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: maxPromptHeight, alignment: .topLeading)
                }
            }
            .padding(.top, 8)
        } label: {
            Text(title)
                .font(.system(size: 12.5, weight: .semibold))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ICCChrome.cardGradient(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9), lineWidth: 1)
                )
        )
    }
}

private struct SupervisorLabeledEditor: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    @Binding var text: String
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            TextEditor(text: $text)
                .font(.system(size: 12, design: .monospaced))
                .frame(minHeight: minHeight)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(ICCChrome.cardGradient(for: colorScheme))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9), lineWidth: 1)
                }
        }
    }
}

private struct SupervisorPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.82 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

private struct SupervisorRunEntryCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let entry: WorkspaceSupervisorRunEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.title)
                    .font(.system(size: 12.5, weight: .semibold))
                Spacer(minLength: 0)
                Text(Date(timeIntervalSince1970: entry.timestamp).formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(entry.summary)
                .font(.system(size: 12))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("结果：\(entry.outcome)")
                .font(.system(size: 11.5))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("下一步：\(entry.nextAction)")
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ICCChrome.cardGradient(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9), lineWidth: 1)
                )
        )
    }
}

private struct SupervisorSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(Color.primary)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color.primary.opacity(configuration.isPressed ? 0.12 : 0.07))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

private struct WorkspaceSupervisorLLMResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String?
        }
        let message: Message
    }
    let choices: [Choice]
}

enum WorkspaceSupervisorLLMClient {
    static func review(
        snapshot: WorkspaceSupervisorSnapshot,
        endpoint: String,
        apiKey: String,
        model: String
    ) async throws -> WorkspaceSupervisorReview {
        let heuristic = WorkspaceSupervisorHeuristics.evaluate(snapshot: snapshot)
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "icc.supervisor", code: 10, userInfo: [NSLocalizedDescriptionKey: "Invalid LLM endpoint URL"])
        }

        let prompt = """
        Return strict JSON with keys:
        health, summary, reason, nextAction, suggestedPrompt

        Health must be one of: idle, running, attention, blocked, completed.
        Ground your answer in the workspace charter, observed directories, remote state, and recent supervisor run history.
        Prefer concrete next actions over generic advice.

        Workspace snapshot:
        \(serializedSnapshot(snapshot))

        Heuristic baseline:
        \(serializedReview(heuristic))
        """

        let body: [String: Any] = [
            "model": model,
            "temperature": 0.2,
            "response_format": ["type": "json_object"],
            "messages": [
                [
                    "role": "system",
                    "content": "You are a cautious engineering supervisor for a terminal workspace. Focus on current state, blockers, and the safest next prompt."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown API error"
            throw NSError(domain: "icc.supervisor", code: 11, userInfo: [NSLocalizedDescriptionKey: errorText])
        }

        let decoded = try JSONDecoder().decode(WorkspaceSupervisorLLMResponse.self, from: data)
        let content = decoded.choices.first?.message.content ?? ""
        guard let payloadData = content.data(using: .utf8),
              let payload = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            throw NSError(domain: "icc.supervisor", code: 12, userInfo: [NSLocalizedDescriptionKey: "LLM returned invalid JSON"])
        }

        let health = WorkspaceSupervisorHealth(rawValue: String(describing: payload["health"] ?? "")) ?? heuristic.health
        return WorkspaceSupervisorReview(
            health: health,
            summary: stringValue(payload["summary"]) ?? heuristic.summary,
            reason: stringValue(payload["reason"]) ?? heuristic.reason,
            nextAction: stringValue(payload["nextAction"]) ?? heuristic.nextAction,
            suggestedPrompt: stringValue(payload["suggestedPrompt"]) ?? heuristic.suggestedPrompt,
            source: "llm",
            model: model,
            generatedAt: Date().timeIntervalSince1970
        )
    }

    static func startupPlan(
        snapshot: WorkspaceSupervisorSnapshot,
        interactions: String,
        endpoint: String,
        apiKey: String,
        model: String
    ) async throws -> WorkspaceSupervisorStartupPlan {
        let heuristic = WorkspaceSupervisorHeuristics.prepareStartupPlan(snapshot: snapshot, interactions: interactions)
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "icc.supervisor", code: 10, userInfo: [NSLocalizedDescriptionKey: "无效的 LLM 接口地址"])
        }

        let prompt = """
        你是一个终端工作区的项目监督器。请根据当前工作区状态和最近 2-3 轮用户交流，输出严格 JSON，包含以下字段：
        goal, progressSummary, recommendedAction, starterPrompt, assumptions

        额外要求：
        1. progressSummary 必须明确指出当前项目阶段，例如“准备开工 / 执行中 / 阻塞中 / 已完成”。
        2. recommendedAction 必须是一个可以立刻执行的动作，不要写成泛泛建议。
        3. starterPrompt 必须像真正要发给执行模型的提示词，包含目标、约束、当前目录或远程信息。
        4. assumptions 里只保留最关键的 1-3 条前提，不要写空话。

        工作区状态：
        \(serializedSnapshot(snapshot))

        最近用户交流：
        \(interactions)

        本地启发式基线：
        \(serializedStartupPlan(heuristic))
        """

        let body: [String: Any] = [
            "model": model,
            "temperature": 0.2,
            "response_format": ["type": "json_object"],
            "messages": [
                [
                    "role": "system",
                    "content": "你是一个谨慎、务实的工程监督器。你的任务是根据有限交流快速形成可以开工的执行建议。"
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown API error"
            throw NSError(domain: "icc.supervisor", code: 11, userInfo: [NSLocalizedDescriptionKey: errorText])
        }

        let decoded = try JSONDecoder().decode(WorkspaceSupervisorLLMResponse.self, from: data)
        let content = decoded.choices.first?.message.content ?? ""
        guard let payloadData = content.data(using: .utf8),
              let payload = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            throw NSError(domain: "icc.supervisor", code: 12, userInfo: [NSLocalizedDescriptionKey: "LLM 返回了无效 JSON"])
        }

        return WorkspaceSupervisorStartupPlan(
            goal: stringValue(payload["goal"]) ?? heuristic.goal,
            progressSummary: stringValue(payload["progressSummary"]) ?? heuristic.progressSummary,
            recommendedAction: stringValue(payload["recommendedAction"]) ?? heuristic.recommendedAction,
            starterPrompt: stringValue(payload["starterPrompt"]) ?? heuristic.starterPrompt,
            assumptions: stringValue(payload["assumptions"]) ?? heuristic.assumptions,
            source: "llm",
            model: model,
            generatedAt: Date().timeIntervalSince1970
        )
    }

    static func executionBrief(
        snapshot: WorkspaceSupervisorSnapshot,
        review: WorkspaceSupervisorReview?,
        startupPlan: WorkspaceSupervisorStartupPlan?,
        endpoint: String,
        apiKey: String,
        model: String
    ) async throws -> WorkspaceSupervisorExecutionBrief {
        let heuristic = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
            snapshot: snapshot,
            review: review,
            startupPlan: startupPlan
        )
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "icc.supervisor", code: 10, userInfo: [NSLocalizedDescriptionKey: "Invalid LLM endpoint URL"])
        }

        let prompt = """
        Return strict JSON with keys:
        title, objective, executionSteps, successSignals, risks, operatorPrompt

        Requirements:
        - executionSteps, successSignals, and risks must be JSON arrays of strings.
        - Keep the plan bounded to one concrete execution slice.
        - operatorPrompt must be directly usable as an executor model prompt.

        Workspace snapshot:
        \(serializedSnapshot(snapshot))

        Latest review:
        \(review.map(serializedReview) ?? "{}")

        Startup plan:
        \(startupPlan.map(serializedStartupPlan) ?? "{}")

        Heuristic baseline:
        \(serializedExecutionBrief(heuristic))
        """

        let body: [String: Any] = [
            "model": model,
            "temperature": 0.2,
            "response_format": ["type": "json_object"],
            "messages": [
                [
                    "role": "system",
                    "content": "You are an engineering supervisor producing a bounded execution brief for one workspace. Be concrete, scope-safe, and operational."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown API error"
            throw NSError(domain: "icc.supervisor", code: 11, userInfo: [NSLocalizedDescriptionKey: errorText])
        }

        let decoded = try JSONDecoder().decode(WorkspaceSupervisorLLMResponse.self, from: data)
        let content = decoded.choices.first?.message.content ?? ""
        guard let payloadData = content.data(using: .utf8),
              let payload = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            throw NSError(domain: "icc.supervisor", code: 12, userInfo: [NSLocalizedDescriptionKey: "LLM returned invalid JSON"])
        }

        return WorkspaceSupervisorExecutionBrief(
            title: stringValue(payload["title"]) ?? heuristic.title,
            objective: stringValue(payload["objective"]) ?? heuristic.objective,
            executionSteps: stringArray(payload["executionSteps"]) ?? heuristic.executionSteps,
            successSignals: stringArray(payload["successSignals"]) ?? heuristic.successSignals,
            risks: stringArray(payload["risks"]) ?? heuristic.risks,
            operatorPrompt: stringValue(payload["operatorPrompt"]) ?? heuristic.operatorPrompt,
            source: "llm",
            model: model,
            generatedAt: Date().timeIntervalSince1970
        )
    }

    private static func serializedSnapshot(_ snapshot: WorkspaceSupervisorSnapshot) -> String {
        let payload: [String: Any] = [
            "title": snapshot.title,
            "customTitle": snapshot.customTitle as Any,
            "currentDirectory": snapshot.currentDirectory,
            "observedDirectories": snapshot.observedDirectories,
            "goal": snapshot.goal,
            "doneDefinition": snapshot.doneDefinition,
            "constraints": snapshot.constraints,
            "scopeNotes": snapshot.scopeNotes,
            "progressValue": snapshot.progressValue as Any,
            "progressLabel": snapshot.progressLabel as Any,
            "gitBranch": snapshot.gitBranch as Any,
            "gitDirty": snapshot.gitDirty,
            "remoteTarget": snapshot.remoteTarget as Any,
            "remoteState": snapshot.remoteState,
            "remoteCompatibility": snapshot.remoteCompatibility as Any,
            "remoteDetail": snapshot.remoteDetail as Any,
            "statusEntries": snapshot.statusEntries.map { ["key": $0.key, "value": $0.value] },
            "recentLogs": snapshot.recentLogs,
            "recentRunHeadlines": snapshot.recentRunHeadlines,
            "focusedPanelDirectory": snapshot.focusedPanelDirectory as Any
        ]
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    private static func serializedReview(_ review: WorkspaceSupervisorReview) -> String {
        let payload: [String: Any] = [
            "health": review.health.rawValue,
            "summary": review.summary,
            "reason": review.reason,
            "nextAction": review.nextAction,
            "suggestedPrompt": review.suggestedPrompt
        ]
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    private static func serializedStartupPlan(_ plan: WorkspaceSupervisorStartupPlan) -> String {
        let payload: [String: Any] = [
            "goal": plan.goal,
            "progressSummary": plan.progressSummary,
            "recommendedAction": plan.recommendedAction,
            "starterPrompt": plan.starterPrompt,
            "assumptions": plan.assumptions
        ]
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    private static func serializedExecutionBrief(_ brief: WorkspaceSupervisorExecutionBrief) -> String {
        let payload: [String: Any] = [
            "title": brief.title,
            "objective": brief.objective,
            "executionSteps": brief.executionSteps,
            "successSignals": brief.successSignals,
            "risks": brief.risks,
            "operatorPrompt": brief.operatorPrompt
        ]
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    private static func stringValue(_ value: Any?) -> String? {
        guard let value else { return nil }
        let text = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private static func stringArray(_ value: Any?) -> [String]? {
        guard let array = value as? [Any] else { return nil }
        let strings = array
            .map { String(describing: $0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return strings.isEmpty ? nil : strings
    }
}

extension Workspace {
    private func supervisorTerminalPanel(for panelID: UUID?) -> TerminalPanel? {
        guard let panelID,
              let terminalPanel = panels[panelID] as? TerminalPanel else {
            return nil
        }
        return terminalPanel
    }

    private func supervisorResolvedDispatchTarget(
        preferredPanelID: UUID?,
        handoffs: [WorkspaceSupervisorPanelHandoff]
    ) -> WorkspaceSupervisorPanelHandoff? {
        let terminalPanelIDs = Set(
            sidebarOrderedPanelIds().filter { supervisorTerminalPanel(for: $0) != nil }
        )

        guard !terminalPanelIDs.isEmpty else { return nil }

        if let preferredPanelID,
           terminalPanelIDs.contains(preferredPanelID),
           let exact = handoffs.first(where: { $0.panelID == preferredPanelID }) {
            return exact
        }

        if let activePanelID = supervisorActiveLoopTarget?.panelID,
           terminalPanelIDs.contains(activePanelID),
           let active = handoffs.first(where: { $0.panelID == activePanelID }) {
            return active
        }

        if let focusedPanelId,
           terminalPanelIDs.contains(focusedPanelId),
           let focused = handoffs.first(where: { $0.panelID == focusedPanelId }) {
            return focused
        }

        return handoffs.first(where: { terminalPanelIDs.contains($0.panelID) })
    }

    private func supervisorDispatchPrompt(for handoff: WorkspaceSupervisorPanelHandoff?) -> String? {
        let prompt = handoff?.operatorPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? supervisorExecutionBrief?.operatorPrompt.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let prompt, !prompt.isEmpty else { return nil }
        return prompt.hasSuffix("\n") ? prompt : prompt + "\n"
    }

    func canDispatchSupervisorPrompt(preferredPanelID: UUID?) -> Bool {
        let handoffs = computedSupervisorPanelHandoffsSnapshot().handoffs
        guard let handoff = supervisorResolvedDispatchTarget(
                preferredPanelID: preferredPanelID,
                handoffs: handoffs
              ),
              supervisorTerminalPanel(for: handoff.panelID) != nil else {
            return false
        }
        return supervisorDispatchPrompt(for: handoff) != nil
    }

    @discardableResult
    func dispatchSupervisorPromptToCurrentPanel() -> String {
        dispatchSupervisorPrompt(preferredPanelID: focusedPanelId, source: "dispatch-current-panel")
    }

    @discardableResult
    func dispatchSupervisorPromptToActiveLoopPanel() -> String {
        dispatchSupervisorPrompt(
            preferredPanelID: supervisorActiveLoopTarget?.panelID,
            source: "dispatch-active-loop-panel"
        )
    }

    @discardableResult
    func dispatchSupervisorPrompt(preferredPanelID: UUID?, source: String) -> String {
        let handoffs = computedSupervisorPanelHandoffsSnapshot().handoffs
        guard let handoff = supervisorResolvedDispatchTarget(
                preferredPanelID: preferredPanelID,
                handoffs: handoffs
              ) else {
            let message = "No terminal window is available for supervisor dispatch."
            appendLogEntry(message, level: .warning, source: "supervisor")
            return message
        }

        guard let terminalPanel = supervisorTerminalPanel(for: handoff.panelID) else {
            let message = "The selected supervisor target is not a terminal window."
            appendLogEntry(message, level: .warning, source: "supervisor")
            return message
        }

        let shellState = panelShellActivityState(for: handoff.panelID)
        if shellState.blocksPromptDispatch {
            let message = "The target terminal is still running a command. Wait for a prompt before dispatching the supervisor prompt."
            appendLogEntry(message, level: .warning, source: "supervisor")
            appendSupervisorRun(
                title: "派发执行提示词",
                summary: "未向 \(handoff.panelTitle) 派发提示词。",
                outcome: "目标窗口仍在执行命令，已阻止本次派发。",
                nextAction: "等待终端回到提示符空闲状态后再发送。",
                source: "\(source)-blocked"
            )
            return message
        }

        guard let prompt = supervisorDispatchPrompt(for: handoff) else {
            let message = "No supervisor prompt is ready to send yet."
            appendLogEntry(message, level: .warning, source: "supervisor")
            return message
        }

        supervisorActiveLoopTarget = WorkspaceSupervisorLoopTarget(
            panelID: handoff.panelID,
            panelTitle: handoff.panelTitle,
            workingDirectory: handoff.workingDirectory,
            selectedAt: Date().timeIntervalSince1970
        )

        focusPanel(handoff.panelID)
        terminalPanel.sendText(prompt)

        let shellStateNote = shellState == .unknown
            ? "Shell state is still unverified, so dispatch safety is best-effort."
            : "Terminal was idle at a prompt when the prompt was dispatched."
        let message = "Supervisor prompt sent to \(handoff.panelTitle)."
        appendSupervisorRun(
            title: "派发执行提示词",
            summary: "已向 \(handoff.panelTitle) 派发执行提示词。",
            outcome: "目标目录：\(handoff.workingDirectory)；\(shellStateNote)",
            nextAction: handoff.nextAction,
            source: source
        )
        appendLogEntry(message, level: .info, source: "supervisor")
        publishSupervisorStatusEntry()
        return message
    }

    func supervisorAutomationReadiness() -> WorkspaceSupervisorAutomationReadiness {
        let shellIntegrationMode = GhosttyApp.shared.shellIntegrationMode()
        let shellIntegrationInjected = UserDefaults.standard.object(forKey: "sidebarShellIntegration") as? Bool ?? true
        let appleScriptEnabled = GhosttyApp.shared.appleScriptAutomationEnabled()

        let terminalPanelIDs = sidebarOrderedPanelIds().filter { terminalPanel(for: $0) != nil }
        let promptReadyCount = terminalPanelIDs.filter { panelShellActivityState(for: $0) == .promptIdle }.count
        let runningCount = terminalPanelIDs.filter { panelShellActivityState(for: $0) == .commandRunning }.count
        let unknownCount = max(0, terminalPanelIDs.count - promptReadyCount - runningCount)
        let trackedDirectoryCount = Set(
            terminalPanelIDs.compactMap { panelDirectories[$0]?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        ).count

        let focusedPanel = focusedPanelId.flatMap { panels[$0] }
        let focusedPanelTitle = focusedPanelId.flatMap { panelTitle(panelId: $0) }?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? focusedPanel?.displayTitle
            ?? "未选定"
        let focusedPanelType: String = {
            switch focusedPanel?.panelType {
            case .terminal:
                return "终端"
            case .browser:
                return "浏览器"
            case .markdown:
                return "文件"
            case nil:
                return "未选定"
            }
        }()
        let focusedDirectory = focusedPanelId
            .map { normalizedPanelDirectory(for: $0) }
            ?? currentDirectory
        let focusedShellState: Workspace.PanelShellActivityState = {
            guard let focusedPanelId, terminalPanel(for: focusedPanelId) != nil else { return .unknown }
            return panelShellActivityState(for: focusedPanelId)
        }()

        var notes: [String] = []
        if terminalPanelIDs.isEmpty {
            notes.append("当前工作区还没有终端窗口，监督器无法把执行提示词真正交给执行面板。")
        }
        if !shellIntegrationInjected {
            notes.append("icc 侧边栏 shell integration 注入已关闭，目录和提示符边界会更难准确追踪。")
        }
        if shellIntegrationMode == "none" {
            notes.append("Ghostty 配置中的 shell-integration = none，监督器无法可靠判断终端是否回到了提示符。")
        }
        if focusedPanel?.panelType != .terminal, focusedPanel != nil {
            notes.append("当前聚焦窗口不是终端。发送执行提示词前，最好先选中目标终端窗口。")
        } else if focusedShellState == .commandRunning {
            notes.append("当前聚焦终端仍在执行命令。icc 已阻止监督器直接插入提示词，以免打断正在运行的任务。")
        } else if focusedShellState == .unknown, focusedPanel?.panelType == .terminal {
            notes.append("当前聚焦终端尚未上报 shell 状态。可以继续派发，但安全性只能按最佳努力处理。")
        }
        if terminalPanelIDs.count > trackedDirectoryCount {
            notes.append("有些终端尚未回报当前目录。建议等待 shell integration 完成初始化后再启动自动化。")
        }

        let headline: String
        let statusText: String
        if terminalPanelIDs.isEmpty {
            statusText = "缺终端"
            headline = "先打开至少一个终端窗口，再让监督器真正接管任务执行。"
        } else if !shellIntegrationInjected || shellIntegrationMode == "none" {
            statusText = "弱就绪"
            headline = "终端已经可用，但 shell integration 不完整，自动化判断会退化为保守模式。"
        } else if promptReadyCount > 0 {
            statusText = "可派发"
            headline = "已有 \(promptReadyCount) 个终端处于提示符空闲状态，监督器可以更安全地派发执行提示词。"
        } else if runningCount > 0 {
            statusText = "忙碌"
            headline = "终端仍在执行命令。等待回到提示符后，再进行自动派发会更稳妥。"
        } else {
            statusText = "待确认"
            headline = "终端已打开，但还没有收到明确的提示符状态回报。"
        }

        return WorkspaceSupervisorAutomationReadiness(
            headline: headline,
            statusText: statusText,
            shellIntegrationMode: shellIntegrationMode,
            shellIntegrationInjected: shellIntegrationInjected,
            appleScriptAutomationEnabled: appleScriptEnabled,
            focusedPanelTitle: focusedPanelTitle,
            focusedPanelType: focusedPanelType,
            focusedDirectory: focusedDirectory,
            focusedShellState: focusedShellState.localizedSupervisorText,
            terminalPanelCount: terminalPanelIDs.count,
            promptReadyCount: promptReadyCount,
            runningCount: runningCount,
            unknownCount: unknownCount,
            trackedDirectoryCount: trackedDirectoryCount,
            notes: notes
        )
    }

    func supervisorRecommendedOperatorMode() -> WorkspaceSupervisorOperatorMode {
        let readiness = supervisorAutomationReadiness()
        if supervisorLoopState == .running {
            return .autonomy
        }
        let hasGoal = !supervisorEffectiveMissionGoal().isEmpty
        let handoffCount = computedSupervisorPanelHandoffsSnapshot().handoffs.count
        if readiness.promptReadyCount > 0 && handoffCount > 1 {
            return .autonomy
        }
        if readiness.promptReadyCount > 0 && hasGoal {
            return .drive
        }
        if hasGoal || !supervisorInteractionNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .suggest
        }
        return .observe
    }

    func supervisorZeroConfigBootstrap(
        preferredMode: WorkspaceSupervisorOperatorMode,
        llmConfigured: Bool
    ) -> WorkspaceSupervisorZeroConfigBootstrap {
        let directory = currentDirectory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? FileManager.default.currentDirectoryPath
            : currentDirectory
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        let entries = (try? FileManager.default.contentsOfDirectory(atPath: directory)) ?? []
        let topLevel = Array(entries.sorted().prefix(8))
        let lowercasedNames = Set(entries.map { $0.lowercased() })
        let xcodeProjectExists = entries.contains { $0.hasSuffix(".xcodeproj") || $0.hasSuffix(".xcworkspace") }

        let projectLabel: String
        let recommendedGoal: String
        if xcodeProjectExists || lowercasedNames.contains("package.swift") {
            projectLabel = "Swift / Apple"
            recommendedGoal = "快速理解这个 Swift 项目的当前进度，定位最值得推进的下一步，并给出最小安全动作。"
        } else if lowercasedNames.contains("package.json") {
            projectLabel = "Node / Web"
            recommendedGoal = "快速理解这个 Node/Web 项目的当前状态，判断最小安全推进路径，并开始执行。"
        } else if lowercasedNames.contains("pyproject.toml") || lowercasedNames.contains("requirements.txt") {
            projectLabel = "Python"
            recommendedGoal = "快速理解这个 Python 项目的当前状态，提炼目标和阻塞点，然后执行第一步。"
        } else if lowercasedNames.contains("cargo.toml") {
            projectLabel = "Rust"
            recommendedGoal = "快速理解这个 Rust 项目的结构和当前进度，给出一个边界清晰的下一步。"
        } else if lowercasedNames.contains("go.mod") {
            projectLabel = "Go"
            recommendedGoal = "快速理解这个 Go 项目的模块和当前进度，提炼并执行最小下一步。"
        } else if lowercasedNames.contains("makefile") {
            projectLabel = "CLI / Build"
            recommendedGoal = "先理解这个命令行项目的入口和构建方式，再推进一个最小可执行动作。"
        } else {
            projectLabel = "通用项目"
            recommendedGoal = "快速读取当前项目上下文，判断现阶段目标与下一步，并开始安全推进。"
        }

        let effectiveGoal = supervisorEffectiveMissionGoal()
        let finalGoal = effectiveGoal.isEmpty ? recommendedGoal : effectiveGoal
        let gitLabel = gitBranch.map { "\($0.branch)\($0.isDirty ? " *" : "")" }
        let promptReadyCount = supervisorAutomationReadiness().promptReadyCount
        let terminalCount = sidebarOrderedPanelIds().filter { terminalPanel(for: $0) != nil }.count
        let remoteLabel = remoteDisplayTarget

        var badges: [String] = [projectLabel]
        if let gitLabel, !gitLabel.isEmpty {
            badges.append("Git \(gitLabel)")
        }
        badges.append("\(terminalCount) 个终端")
        if promptReadyCount > 0 {
            badges.append("\(promptReadyCount) 个待命")
        }
        if let remoteLabel, !remoteLabel.isEmpty {
            badges.append("远程 \(remoteLabel)")
        }
        if llmConfigured {
            badges.append("LLM 已就绪")
        }

        let primaryActionTitle: String = {
            if supervisorExecutionBrief != nil {
                return "继续推进"
            }
            if supervisorStartupPlan != nil {
                return "生成任务包"
            }
            if supervisorEnabled {
                return "继续监督"
            }
            return "开始监督"
        }()

        let headline: String = {
            if supervisorExecutionBrief != nil {
                return "当前项目已经有任务包，可以直接继续。"
            }
            if !effectiveGoal.isEmpty {
                return "目标已明确，监督器可以直接整理任务包并开工。"
            }
            return "用户什么都不填也可以开工，监督器会先基于当前项目推断目标和上下文。"
        }()

        let contextLines: [String] = [
            "项目类型：\(projectLabel)",
            "当前目录：\(directoryURL.path)",
            topLevel.isEmpty ? nil : "顶层文件：\(topLevel.joined(separator: ", "))",
            gitLabel.map { "Git：\($0)" },
            remoteLabel.map { "远程：\($0) / \(remoteConnectionState.rawValue)" },
            "推荐模式：\(preferredMode.displayText)"
        ].compactMap { $0 }

        let interactionSeed = """
        用户还没有提供完整的目标。请先根据当前项目上下文建立一个可以立即开工的任务包。
        \(contextLines.joined(separator: "\n"))

        你需要先判断：
        1. 当前项目大概处于什么阶段。
        2. 最值得推进的下一个动作是什么。
        3. 哪些约束会影响继续执行。
        """

        let summary = """
        \(headline)

        当前监督器会优先读取目录、Git、终端空闲状态和最近窗口上下文，然后自动生成目标、执行简报和下一步动作。
        """

        return WorkspaceSupervisorZeroConfigBootstrap(
            projectLabel: projectLabel,
            primaryActionTitle: primaryActionTitle,
            headline: headline,
            summary: summary,
            recommendedGoal: finalGoal,
            interactionSeed: interactionSeed,
            badges: badges
        )
    }

    func supervisorOperatorProfile(mode: WorkspaceSupervisorOperatorMode) -> WorkspaceSupervisorOperatorProfile {
        let snapshot = supervisorSnapshot
        let readiness = supervisorAutomationReadiness()
        let liveOrchestration = computedSupervisorPanelHandoffsSnapshot()
        let orderedPanelIDs = sidebarOrderedPanelIds()
        let terminalCount = orderedPanelIDs.filter { terminalPanel(for: $0) != nil }.count
        let browserCount = orderedPanelIDs.filter { browserPanel(for: $0) != nil }.count
        let fileCount = orderedPanelIDs.filter { markdownPanel(for: $0) != nil }.count
        let hasWorkspaceDirectory = !snapshot.currentDirectory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let gitBranchText = snapshot.gitBranch?.trimmingCharacters(in: .whitespacesAndNewlines)
        let gitReady = gitBranchText?.isEmpty == false || !panelGitBranches.isEmpty
        let remoteConfigured = remoteConfiguration != nil
        let remoteConnected = remoteConnectionState == .connected
        let effectiveGoal = supervisorEffectiveMissionGoal()

        let capabilityStates: [WorkspaceSupervisorCapabilityState] = [
            WorkspaceSupervisorCapabilityState(
                kind: .terminalControl,
                availability: terminalCount > 0 ? .ready : .unavailable,
                summary: terminalCount > 0 ? "已发现 \(terminalCount) 个终端窗口。" : "当前没有可接管的终端窗口。",
                detail: terminalCount > 0
                    ? "监督器可在这些终端之间保持会话上下文、聚焦窗口并准备派发。"
                    : "先打开至少一个终端窗口，监督器才有真正的执行载体。"
            ),
            WorkspaceSupervisorCapabilityState(
                kind: .commandExecution,
                availability: readiness.promptReadyCount > 0 ? .ready : (readiness.runningCount > 0 ? .caution : (terminalCount > 0 ? .partial : .unavailable)),
                summary: readiness.promptReadyCount > 0
                    ? "有 \(readiness.promptReadyCount) 个终端处于提示符空闲状态。"
                    : (readiness.runningCount > 0
                        ? "终端仍在执行命令，暂不适合插入新动作。"
                        : (terminalCount > 0 ? "终端可见，但 shell 状态仍待确认。" : "当前没有终端可供执行。")),
                detail: "命令派发依赖 shell integration 回报的提示符边界，避免在任务运行中打断窗口。"
            ),
            WorkspaceSupervisorCapabilityState(
                kind: .browserOperator,
                availability: browserCount > 0 ? .ready : (terminalCount > 0 || hasWorkspaceDirectory ? .partial : .unavailable),
                summary: browserCount > 0 ? "已发现 \(browserCount) 个浏览器面板。" : "当前没有浏览器面板处于激活状态。",
                detail: browserCount > 0
                    ? "监督器可以读取浏览器上下文，把当前网页状态纳入任务包。"
                    : "如需浏览器侧任务，请先打开浏览器面板；监督器会把它纳入编排。"
            ),
            WorkspaceSupervisorCapabilityState(
                kind: .localFiles,
                availability: hasWorkspaceDirectory ? .ready : .unavailable,
                summary: hasWorkspaceDirectory
                    ? "当前项目目录为 \(SidebarPathFormatter.shortenedPath(snapshot.currentDirectory))。"
                    : "当前没有稳定的本地项目目录。",
                detail: hasWorkspaceDirectory
                    ? "本地文件树、文件查看与编辑已经可用，可直接作为执行与复盘证据。"
                    : "没有目录就无法建立可靠的文件读写边界。"
            ),
            WorkspaceSupervisorCapabilityState(
                kind: .remoteFiles,
                availability: remoteConnected ? .ready : (remoteConfigured ? .caution : .unavailable),
                summary: remoteConnected
                    ? "远程目标已连接，可查看和编辑远程文件。"
                    : (remoteConfigured ? "远程目标已配置，但当前连接不稳定或未连接。" : "当前没有远程主机配置。"),
                detail: remoteConfigured
                    ? "远程文件能力依赖 SSH 会话健康度；断连时需要先恢复连接。"
                    : "如需远程编排，先在远程资源管理器里配置并连接主机。"
            ),
            WorkspaceSupervisorCapabilityState(
                kind: .sourceControl,
                availability: gitReady ? .ready : (hasWorkspaceDirectory ? .partial : .unavailable),
                summary: gitReady
                    ? "当前仓库分支：\(gitBranchText ?? "已连接 Git")。"
                    : (hasWorkspaceDirectory ? "当前目录已就绪，但还没有确认 Git 仓库状态。" : "没有本地目录就无法建立源代码管理上下文。"),
                detail: gitReady
                    ? "监督器可把分支、脏工作区与 GitHub 绑定状态纳入执行判断。"
                    : "如需安全推进代码任务，最好先确认当前项目已处于 Git 仓库中。"
            ),
            WorkspaceSupervisorCapabilityState(
                kind: .sessionRouting,
                availability: liveOrchestration.handoffs.count > 1 || liveOrchestration.queue.count > 1 ? .ready : (liveOrchestration.handoffs.count == 1 ? .partial : .unavailable),
                summary: liveOrchestration.handoffs.count > 0
                    ? "已生成 \(liveOrchestration.handoffs.count) 个窗口交接对象。"
                    : "当前尚未形成可编排的窗口交接。",
                detail: liveOrchestration.handoffs.count > 1
                    ? "监督器可在多个窗口之间轮转，并通过队列安排优先级与依赖。"
                    : "单窗口也能运行，但多窗口编排价值尚未释放。"
            ),
            WorkspaceSupervisorCapabilityState(
                kind: .skillStudio,
                availability: hasWorkspaceDirectory && (!effectiveGoal.isEmpty || !supervisorInteractionNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? .ready : (hasWorkspaceDirectory ? .partial : .unavailable),
                summary: hasWorkspaceDirectory
                    ? "可把当前工作区方法沉淀成技能蓝图。"
                    : "缺少工作区目录，技能沉淀无法形成稳定落点。",
                detail: hasWorkspaceDirectory
                    ? "技能工坊会把目标、目录、工具和守护规则打包为可导出的蓝图文件。"
                    : "技能蓝图需要一个本地目录作为导出位置。"
            )
        ]

        let authority: WorkspaceSupervisorAuthorityLevel = {
            switch mode {
            case .observe:
                return .limited
            case .suggest:
                return hasWorkspaceDirectory ? .standard : .limited
            case .drive:
                return readiness.promptReadyCount > 0 ? .elevated : .standard
            case .autonomy:
                if readiness.promptReadyCount > 0 && (liveOrchestration.handoffs.count > 1 || liveOrchestration.queue.count > 1) {
                    return .orchestrator
                }
                return readiness.promptReadyCount > 0 ? .elevated : .standard
            }
        }()

        let missionTitle = effectiveGoal.isEmpty
            ? "还没有明确目标，监督器需要先拿到一个可验收的任务。"
            : effectiveGoal
        let missionSummary = supervisorLastReview?.summary
            ?? supervisorStartupPlan?.progressSummary
            ?? "监督器会根据目标、目录、远程状态和最近交流，构建一个边界清晰的执行面。"

        var accessFragments: [String] = []
        if hasWorkspaceDirectory {
            accessFragments.append("目录 \(SidebarPathFormatter.shortenedPath(snapshot.currentDirectory))")
        }
        accessFragments.append("\(terminalCount) 个终端")
        if browserCount > 0 {
            accessFragments.append("\(browserCount) 个浏览器面板")
        }
        if fileCount > 0 {
            accessFragments.append("\(fileCount) 个文件面板")
        }
        if gitReady {
            accessFragments.append("Git \(gitBranchText ?? "已连接")")
        }
        if remoteConfigured {
            accessFragments.append("远程 \(remoteDisplayTarget ?? "已配置") · \(remoteConnectionState.rawValue)")
        }

        var notes = readiness.notes
        switch mode {
        case .observe:
            notes.insert("当前模式只负责判断、复盘和提出边界清晰的建议。", at: 0)
        case .suggest:
            notes.insert("当前模式会产出任务包和技能蓝图，但不会直接派发到终端。", at: 0)
        case .drive:
            notes.insert("当前模式允许手动派发到终端窗口，适合人机协同推进。", at: 0)
        case .autonomy:
            notes.insert("当前模式会在多个窗口之间轮转，持续评估、派发和复盘。", at: 0)
        }
        if notes.isEmpty {
            notes = ["当前工作区已具备基础接管条件，可以开始构建任务包。"]
        }

        let laneSummaries: [String] = {
            if !liveOrchestration.queue.isEmpty {
                return liveOrchestration.queue.prefix(4).map { item in
                    "#\(item.priority) \(item.panelTitle) · \(item.nextMilestone)"
                }
            }
            if !liveOrchestration.handoffs.isEmpty {
                return liveOrchestration.handoffs.prefix(4).map { handoff in
                    "[\(WorkspaceSupervisorHeuristics.handoffDisplayStatus(handoff.status))] \(handoff.panelTitle) · \(handoff.nextAction)"
                }
            }
            if terminalCount > 0 || browserCount > 0 {
                return ["当前窗口已准备好，但还需要一次任务包或交接刷新来形成编排。"]
            }
            return []
        }()

        return WorkspaceSupervisorOperatorProfile(
            mode: mode,
            authority: authority,
            missionTitle: missionTitle,
            missionSummary: missionSummary,
            accessSummary: accessFragments.joined(separator: " · "),
            operatingNotes: notes,
            laneSummaries: laneSummaries,
            capabilityStates: capabilityStates
        )
    }

    func supervisorSkillBlueprint(mode: WorkspaceSupervisorOperatorMode) -> WorkspaceSupervisorSkillBlueprint {
        let snapshot = supervisorSnapshot
        let profile = supervisorOperatorProfile(mode: mode)
        let goal = supervisorEffectiveMissionGoal()
        let recommendedDirectory: String = {
            if let focused = snapshot.focusedPanelDirectory?.trimmingCharacters(in: .whitespacesAndNewlines), !focused.isEmpty {
                return focused
            }
            let current = snapshot.currentDirectory.trimmingCharacters(in: .whitespacesAndNewlines)
            return current.isEmpty ? FileManager.default.currentDirectoryPath : current
        }()

        var toolset = profile.capabilityStates
            .filter { $0.availability != .unavailable }
            .map { "\($0.kind.title)：\($0.summary)" }
        if toolset.isEmpty {
            toolset = ["监督器：当前仅能观察状态与整理上下文。"]
        }

        var steps: [String] = [
            "先读取当前目标、完成标准、约束和最近 2-3 轮交流，形成一个边界清晰的任务切片。",
            "在 \(SidebarPathFormatter.shortenedPath(recommendedDirectory)) 内核对目录、文件、Git 状态和远程会话健康度。",
            "优先把动作压缩成一个最小可执行步骤，再决定是否需要向终端窗口派发。",
            "完成后记录结果、剩余风险和下一步，并更新监督器运行记录。"
        ]
        if let firstStep = supervisorExecutionBrief?.executionSteps.first, !firstStep.isEmpty {
            steps.insert("参考当前任务包的第一步：\(firstStep)", at: 1)
        }

        var guardrails: [String] = []
        let constraintsText = (snapshot.constraints + "\n" + snapshot.scopeNotes).trimmingCharacters(in: .whitespacesAndNewlines)
        if !constraintsText.isEmpty {
            guardrails.append("严格遵守这些约束与范围：\(constraintsText)")
        }
        if snapshot.gitDirty {
            guardrails.append("不要覆盖已有未提交改动；优先做增量修改。")
        }
        if let remoteTarget = snapshot.remoteTarget, !remoteTarget.isEmpty {
            guardrails.append("涉及远程目标 \(remoteTarget) 时，先确认连接与目录状态再继续。")
        }
        if mode == .autonomy {
            guardrails.append("每轮只推进一个有边界的执行切片，不要同时扩张多个窗口的范围。")
        }
        if guardrails.isEmpty {
            guardrails.append("保持最小改动原则；信息不足时只补一个最关键的缺口。")
        }

        let title = goal.isEmpty ? "监督器技能蓝图" : "监督器技能蓝图：\(goal)"
        let summary = goal.isEmpty
            ? "适用于用户刚给出需求、需要快速形成开工包并建立监督边界的工作区。"
            : "适用于目标“\(goal)”的工作区，可把目录、终端、文件与编排状态整理成持续执行方法。"
        let trigger = goal.isEmpty
            ? "当用户刚给出 2-3 轮需求，需要在最短时间内形成开工包时。"
            : "当工作区目标明确，需要把监督、派发、编排和复盘沉淀为固定方法时。"

        let prompt = """
        Create a reusable SKILL.md-style operator playbook for this workspace.

        Mission:
        \(goal.isEmpty ? "Clarify the mission and bootstrap the first safe step." : goal)

        Working directory:
        \(recommendedDirectory)

        Mode:
        \(mode.displayText) / \(profile.authority.displayText)

        Available tools:
        \(toolset.joined(separator: "\n"))

        Required workflow:
        \(steps.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))

        Guardrails:
        \(guardrails.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))

        Output:
        1. A concise skill title and purpose.
        2. Trigger conditions and required inputs.
        3. Step-by-step execution method.
        4. Explicit safety boundaries for files, terminals, remote access, and scope growth.
        """

        return WorkspaceSupervisorSkillBlueprint(
            title: title,
            summary: summary,
            recommendedDirectory: recommendedDirectory,
            trigger: trigger,
            toolset: toolset,
            steps: steps,
            guardrails: guardrails,
            seedPrompt: prompt
        )
    }

    private func supervisorEffectiveMissionGoal() -> String {
        let charterGoal = supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        if !charterGoal.isEmpty {
            return charterGoal
        }
        if let startupGoal = supervisorStartupPlan?.goal.trimmingCharacters(in: .whitespacesAndNewlines), !startupGoal.isEmpty {
            return startupGoal
        }
        let storedGoal = supervisorGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        return storedGoal
    }

    private func supervisorPanelEvidenceLines(panelID: UUID) -> [String] {
        var lines: [String] = []
        let directory = normalizedPanelDirectory(for: panelID)
        lines.append("Directory: \(directory)")
        if let gitBranch, !gitBranch.branch.isEmpty {
            lines.append("Git: \(gitBranch.branch)\(gitBranch.isDirty ? " (dirty)" : " (clean)")")
        }
        if let remoteTarget = remoteDisplayTarget, !remoteTarget.isEmpty {
            let detail = remoteConnectionDetail?.trimmingCharacters(in: .whitespacesAndNewlines)
            let compatibility = remoteSSHCompatibilitySummary?.trimmingCharacters(in: .whitespacesAndNewlines)
            lines.append(
                "Remote: \(remoteTarget) / \(remoteConnectionState)\(detail?.isEmpty == false ? " / \(detail!)" : "")\(compatibility?.isEmpty == false ? " / \(compatibility!)" : "")"
            )
        }
        let recentSignals = Array(logEntries.suffix(3).map(\.message))
        if !recentSignals.isEmpty {
            lines.append("Recent signals: \(recentSignals.joined(separator: " | "))")
        }
        let recentRuns = supervisorRunJournal.prefix(2).map(\.summary).filter { !$0.isEmpty }
        if !recentRuns.isEmpty {
            lines.append("Recent supervisor notes: \(recentRuns.joined(separator: " | "))")
        }
        return lines
    }

    private func supervisorPanelRole(
        panelType: PanelType,
        isActiveTarget: Bool,
        isFocused: Bool,
        status: String
    ) -> String {
        if status == "completed" {
            return "Completed"
        }
        if status == "blocked" {
            return "Blocked"
        }
        if isActiveTarget {
            switch panelType {
            case .terminal:
                return "Lead Executor"
            case .browser:
                return "Lead Research"
            case .markdown:
                return "Lead Spec"
            }
        }
        if isFocused {
            switch panelType {
            case .terminal:
                return "Ready Executor"
            case .browser:
                return "Ready Research"
            case .markdown:
                return "Ready Spec"
            }
        }
        switch panelType {
        case .terminal:
            return "Support Executor"
        case .browser:
            return "Support Research"
        case .markdown:
            return "Support Notes"
        }
    }

    private func supervisorPanelFallbackAction(
        panelType: PanelType,
        role: String,
        fallbackAction: String
    ) -> String {
        if role.hasPrefix("Lead") || role.hasPrefix("Ready") {
            switch panelType {
            case .terminal:
                return fallbackAction
            case .browser:
                return "Inspect the references or remote state needed for the current step, then extract only the facts needed to unblock execution."
            case .markdown:
                return "Capture the current goal, acceptance criteria, and latest decision so execution can continue without ambiguity."
            }
        }

        switch panelType {
        case .terminal:
            return "Prepare a verification command, compare recent terminal output with the workspace goal, and surface the next safe terminal action."
        case .browser:
            return "Gather a minimal supporting reference or remote confirmation for the active step; avoid drifting into broad exploration."
        case .markdown:
            return "Update notes, checklist, or acceptance criteria for the active step so the execution window can move faster."
        }
    }

    private func supervisorPanelPrompt(
        panelTitle: String,
        panelType: PanelType,
        role: String,
        directory: String,
        objective: String,
        status: String,
        nextAction: String,
        evidenceLines: [String]
    ) -> String {
        let executionRules: String = {
            switch panelType {
            case .terminal:
                return """
                Use this panel to execute or verify concrete commands. Keep scope tight. When you act, report the exact command, the key output, and whether the result changes the task state.
                """
            case .browser:
                return """
                Use this panel to inspect references, docs, web UI state, or remote evidence. Extract facts, do not brainstorm. Summarize only the details that change the next action.
                """
            case .markdown:
                return """
                Use this panel to maintain structured notes, specs, or checklists. Convert ambiguity into a concrete acceptance checklist or decision record for the active task.
                """
            }
        }()

        return """
        You own the panel "\(panelTitle)".
        Role: \(role)
        Panel type: \(panelType.rawValue)
        Working directory: \(directory)
        Workspace objective: \(objective)
        Current status: \(WorkspaceSupervisorHeuristics.handoffDisplayStatus(status))

        Evidence:
        \(evidenceLines.joined(separator: "\n"))

        Next action:
        \(nextAction)

        Operating rules:
        \(executionRules)

        Before stopping, report:
        1. what changed in this panel,
        2. the most important evidence you found,
        3. whether this panel is now blocked, running, ready, or complete.
        """
    }

    private func buildSupervisorExecutionQueue(
        orderedPanelIds: [UUID],
        stateByPanelID: [UUID: WorkspaceSupervisorPanelRoundState],
        activeTargetPanelID: UUID?,
        fallbackAction: String
    ) -> [WorkspaceSupervisorQueueItem] {
        var items: [WorkspaceSupervisorQueueItem] = []
        var previousTerminalLikePanelID: UUID?

        for panelId in orderedPanelIds {
            guard let panel = panels[panelId] else { continue }
            let state = stateByPanelID[panelId]
            let title = panelTitle(panelId: panelId)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? panel.displayTitle
            let isFocused = panelId == focusedPanelId
            let isActiveTarget = panelId == activeTargetPanelID
            let status = state?.status ?? (isActiveTarget ? "running" : "pending")
            let role = supervisorPanelRole(
                panelType: panel.panelType,
                isActiveTarget: isActiveTarget,
                isFocused: isFocused,
                status: status
            )

            let readiness: String = {
                switch status {
                case "completed": return "completed"
                case "blocked": return "blocked"
                case "attention": return "needs_attention"
                case "running": return "active"
                case "supporting": return "supporting"
                default: return "ready"
                }
            }()

            let priority: Int = {
                if isActiveTarget { return 1 }
                switch panel.panelType {
                case .terminal:
                    return isFocused ? 2 : 3
                case .browser:
                    return 4
                case .markdown:
                    return 5
                }
            }()

            let nextMilestone = state?.nextAction.isEmpty == false
                ? state!.nextAction
                : supervisorPanelFallbackAction(
                    panelType: panel.panelType,
                    role: role,
                    fallbackAction: fallbackAction
                )

            let dependsOnPanelID: UUID? = {
                switch panel.panelType {
                case .terminal:
                    return nil
                case .browser, .markdown:
                    return previousTerminalLikePanelID
                }
            }()

            let rotationRule: String = {
                switch panel.panelType {
                case .terminal:
                    return "Rotate after a command result changes state, the panel becomes blocked, or no new evidence appears for two rounds."
                case .browser:
                    return "Rotate back once the needed fact, remote confirmation, or reference has been extracted for the executor."
                case .markdown:
                    return "Rotate after the checklist, spec, or decision note removes ambiguity for the active execution step."
                }
            }()

            items.append(
                WorkspaceSupervisorQueueItem(
                    id: panelId,
                    panelID: panelId,
                    panelTitle: title,
                    role: role,
                    priority: priority,
                    dependsOnPanelID: dependsOnPanelID,
                    readiness: readiness,
                    nextMilestone: nextMilestone,
                    rotationRule: rotationRule,
                    generatedAt: Date().timeIntervalSince1970
                )
            )

            if panel.panelType == .terminal {
                previousTerminalLikePanelID = panelId
            }
        }

        return items.sorted { lhs, rhs in
            if lhs.priority != rhs.priority { return lhs.priority < rhs.priority }
            return lhs.panelTitle.localizedCaseInsensitiveCompare(rhs.panelTitle) == .orderedAscending
        }
    }

    private func supervisorPanelStateMap() -> [UUID: WorkspaceSupervisorPanelRoundState] {
        Dictionary(uniqueKeysWithValues: supervisorPanelRoundStates.map { ($0.panelID, $0) })
    }

    private func normalizedPanelDirectory(for panelId: UUID) -> String {
        let candidate = panelDirectories[panelId]?.trimmingCharacters(in: .whitespacesAndNewlines)
        return candidate?.isEmpty == false ? candidate! : currentDirectory
    }

    private func upsertSupervisorPanelState(
        panelID: UUID,
        status: String,
        summary: String,
        outcome: String,
        nextAction: String,
        source: String,
        iteration: Int? = nil
    ) {
        guard let panel = panels[panelID] else { return }
        let title = panelTitle(panelId: panelID)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? panel.displayTitle
        let directory = normalizedPanelDirectory(for: panelID)
        let timestamp = Date().timeIntervalSince1970

        var state = supervisorPanelRoundStates.first(where: { $0.panelID == panelID }) ?? WorkspaceSupervisorPanelRoundState(
            id: panelID,
            panelID: panelID,
            panelTitle: title,
            panelType: panel.panelType.rawValue,
            workingDirectory: directory,
            status: "pending",
            iterationCount: 0,
            lastSummary: "",
            lastOutcome: "",
            nextAction: "",
            source: source,
            lastUpdatedAt: timestamp,
            history: []
        )

        state.panelTitle = title
        state.panelType = panel.panelType.rawValue
        state.workingDirectory = directory
        state.status = status
        state.lastSummary = summary
        state.lastOutcome = outcome
        state.nextAction = nextAction
        state.source = source
        state.lastUpdatedAt = timestamp
        if let iteration {
            state.iterationCount = max(state.iterationCount, iteration)
            state.history.insert(
                WorkspaceSupervisorPanelRoundEntry(
                    iteration: iteration,
                    panelID: panelID,
                    status: status,
                    summary: summary,
                    outcome: outcome,
                    nextAction: nextAction,
                    source: source,
                    timestamp: timestamp
                ),
                at: 0
            )
            if state.history.count > 8 {
                state.history.removeLast(state.history.count - 8)
            }
        }

        if let index = supervisorPanelRoundStates.firstIndex(where: { $0.panelID == panelID }) {
            supervisorPanelRoundStates[index] = state
        } else {
            supervisorPanelRoundStates.append(state)
        }
        supervisorPanelRoundStates.sort { lhs, rhs in
            lhs.lastUpdatedAt > rhs.lastUpdatedAt
        }
    }

    private func pruneSupervisorPanelStates(validPanelIDs: Set<UUID>) {
        supervisorPanelRoundStates.removeAll { validPanelIDs.contains($0.panelID) == false }
    }

    private func supervisorQueueMap() -> [UUID: WorkspaceSupervisorQueueItem] {
        Dictionary(uniqueKeysWithValues: supervisorExecutionQueue.map { ($0.panelID, $0) })
    }

    private func supervisorQueuePriority(for panelID: UUID, queueByPanelID: [UUID: WorkspaceSupervisorQueueItem]) -> Int {
        queueByPanelID[panelID]?.priority ?? Int.max
    }

    private func supervisorDependencyResolutionTarget(
        preferredDependencyPanelID: UUID? = nil,
        handoffs: [WorkspaceSupervisorPanelHandoff],
        stateByPanelID: [UUID: WorkspaceSupervisorPanelRoundState],
        queueByPanelID: [UUID: WorkspaceSupervisorQueueItem]
    ) -> WorkspaceSupervisorPanelHandoff? {
        let eligibleStatuses = Set(["ready", "pending", "running", "attention", "supporting"])

        func isEligible(_ handoff: WorkspaceSupervisorPanelHandoff) -> Bool {
            eligibleStatuses.contains(handoff.status)
        }

        let dependencyCandidates: [UUID] = {
            let prioritized = preferredDependencyPanelID.map { [$0] } ?? []
            let queued = supervisorExecutionQueue
                .map(\.panelID)
                .filter { prioritized.contains($0) == false }
            return prioritized + queued
        }()

        for dependencyPanelID in dependencyCandidates {
            guard let dependencyState = stateByPanelID[dependencyPanelID],
                  dependencyState.status == "blocked" || dependencyState.status == "attention" else {
                continue
            }

            let items = handoffs
                .filter { handoff in
                    guard isEligible(handoff) else { return false }
                    guard let queueItem = queueByPanelID[handoff.panelID] else { return false }
                    guard queueItem.dependsOnPanelID == dependencyPanelID else { return false }
                    return stateByPanelID[handoff.panelID]?.status != "completed"
                }
                .sorted { lhs, rhs in
                    let lhsState = stateByPanelID[lhs.panelID]
                    let rhsState = stateByPanelID[rhs.panelID]
                    let dependencyIteration = dependencyState.iterationCount
                    let lhsNeedsTurn = (lhsState?.iterationCount ?? 0) <= dependencyIteration
                    let rhsNeedsTurn = (rhsState?.iterationCount ?? 0) <= dependencyIteration
                    if lhsNeedsTurn != rhsNeedsTurn {
                        return lhsNeedsTurn && !rhsNeedsTurn
                    }
                    let lhsPriority = supervisorQueuePriority(for: lhs.panelID, queueByPanelID: queueByPanelID)
                    let rhsPriority = supervisorQueuePriority(for: rhs.panelID, queueByPanelID: queueByPanelID)
                    if lhsPriority != rhsPriority {
                        return lhsPriority < rhsPriority
                    }
                    let lhsUpdated = lhsState?.lastUpdatedAt ?? 0
                    let rhsUpdated = rhsState?.lastUpdatedAt ?? 0
                    if lhsUpdated != rhsUpdated {
                        return lhsUpdated < rhsUpdated
                    }
                    return lhs.panelTitle.localizedCaseInsensitiveCompare(rhs.panelTitle) == .orderedAscending
                }

            if let item = items.first {
                return item
            }
        }

        return nil
    }

    private func supervisorCanContinuePastBlockedReview(
        activePanelID: UUID?,
        handoffs: [WorkspaceSupervisorPanelHandoff],
        stateByPanelID: [UUID: WorkspaceSupervisorPanelRoundState],
        queueByPanelID: [UUID: WorkspaceSupervisorQueueItem]
    ) -> Bool {
        supervisorDependencyResolutionTarget(
            preferredDependencyPanelID: activePanelID,
            handoffs: handoffs,
            stateByPanelID: stateByPanelID,
            queueByPanelID: queueByPanelID
        ) != nil
    }

    private func computedSupervisorPanelHandoffsSnapshot() -> (
        queue: [WorkspaceSupervisorQueueItem],
        handoffs: [WorkspaceSupervisorPanelHandoff],
        activeTargetStillValid: Bool
    ) {
        let orderedPanelIds = sidebarOrderedPanelIds()
        let validPanelIDs = Set(orderedPanelIds)
        let fallbackObjective: String? = {
            if let objective = supervisorExecutionBrief?.objective, !objective.isEmpty {
                return objective
            }
            if let goal = supervisorStartupPlan?.goal, !goal.isEmpty {
                return goal
            }
            let charterGoal = supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines)
            return charterGoal.isEmpty ? nil : charterGoal
        }()
        let fallbackAction = supervisorExecutionBrief?.executionSteps.first
            ?? supervisorLastReview?.nextAction
            ?? supervisorStartupPlan?.recommendedAction
            ?? "Inspect the current panel state and make the smallest safe move."
        let globalStatus = WorkspaceSupervisorHeuristics.handoffStatus(for: supervisorLastReview)
        let stateByPanelID = Dictionary(
            uniqueKeysWithValues: supervisorPanelRoundStates
                .filter { validPanelIDs.contains($0.panelID) }
                .map { ($0.panelID, $0) }
        )
        let activeTargetPanelID = supervisorActiveLoopTarget?.panelID
        let queue = buildSupervisorExecutionQueue(
            orderedPanelIds: orderedPanelIds,
            stateByPanelID: stateByPanelID,
            activeTargetPanelID: activeTargetPanelID,
            fallbackAction: fallbackAction
        )

        var handoffs: [WorkspaceSupervisorPanelHandoff] = []
        for panelId in orderedPanelIds {
            guard let panel = panels[panelId] else { continue }
            let panelTitle = panelTitle(panelId: panelId)?.trimmingCharacters(in: .whitespacesAndNewlines)
                ?? panel.displayTitle
            let directory = normalizedPanelDirectory(for: panelId)
            let isFocused = panelId == focusedPanelId
            let panelState = stateByPanelID[panelId]
            let isActiveTarget = panelId == activeTargetPanelID
            let status = panelState?.status
                ?? (isActiveTarget ? "running" : (isFocused ? globalStatus : "pending"))
            let role = supervisorPanelRole(
                panelType: panel.panelType,
                isActiveTarget: isActiveTarget,
                isFocused: isFocused,
                status: status
            )
            let objective = panelState?.lastSummary.isEmpty == false
                ? panelState!.lastSummary
                : (isFocused
                ? (fallbackObjective?.isEmpty == false ? fallbackObjective! : "Advance the focused panel safely.")
                : "Support the workspace goal from this panel without expanding scope.")
            let nextAction = panelState?.nextAction.isEmpty == false
                ? panelState!.nextAction
                : supervisorPanelFallbackAction(
                    panelType: panel.panelType,
                    role: role,
                    fallbackAction: fallbackAction
                )
            let evidenceLines = supervisorPanelEvidenceLines(panelID: panelId)
            let prompt = supervisorPanelPrompt(
                panelTitle: panelTitle,
                panelType: panel.panelType,
                role: role,
                directory: directory,
                objective: objective,
                status: status,
                nextAction: nextAction,
                evidenceLines: evidenceLines
            )

            handoffs.append(WorkspaceSupervisorPanelHandoff(
                id: panelId,
                panelID: panelId,
                panelTitle: "[\(role)] \(panelTitle)",
                panelType: panel.panelType.rawValue,
                workingDirectory: directory,
                objective: objective,
                nextAction: nextAction,
                status: status,
                operatorPrompt: prompt,
                source: supervisorExecutionBrief?.source ?? supervisorStartupPlan?.source ?? "heuristic",
                generatedAt: Date().timeIntervalSince1970
            ))
        }
        let activeTargetStillValid: Bool
        if let activePanelID = supervisorActiveLoopTarget?.panelID {
            activeTargetStillValid = handoffs.contains(where: { $0.panelID == activePanelID })
        } else {
            activeTargetStillValid = true
        }

        return (
            queue: queue,
            handoffs: handoffs,
            activeTargetStillValid: activeTargetStillValid
        )
    }

    func refreshSupervisorPanelHandoffs() {
        pruneSupervisorPanelStates(validPanelIDs: Set(sidebarOrderedPanelIds()))
        let snapshot = computedSupervisorPanelHandoffsSnapshot()
        supervisorExecutionQueue = snapshot.queue
        supervisorPanelHandoffs = snapshot.handoffs
        if snapshot.activeTargetStillValid == false {
            supervisorActiveLoopTarget = nil
        }
    }

    func selectSupervisorLoopTarget(preferredPanelID: UUID? = nil) -> WorkspaceSupervisorPanelHandoff? {
        refreshSupervisorPanelHandoffs()
        let preferredID = preferredPanelID ?? focusedPanelId
        let eligibleStatuses = Set(["ready", "pending", "running", "attention", "supporting"])
        let panelStates = supervisorPanelStateMap()
        let queueByPanelID = supervisorQueueMap()

        func isEligible(_ handoff: WorkspaceSupervisorPanelHandoff) -> Bool {
            eligibleStatuses.contains(handoff.status)
        }

        let dependencyResolutionTarget = supervisorDependencyResolutionTarget(
            preferredDependencyPanelID: preferredID,
            handoffs: supervisorPanelHandoffs,
            stateByPanelID: panelStates,
            queueByPanelID: queueByPanelID
        )

        let selected = dependencyResolutionTarget
            ?? supervisorPanelHandoffs.first(where: { $0.panelID == preferredID && isEligible($0) })
            ?? supervisorPanelHandoffs
                .filter(isEligible)
                .sorted { lhs, rhs in
                    let lhsQueue = queueByPanelID[lhs.panelID]
                    let rhsQueue = queueByPanelID[rhs.panelID]
                    let lhsPriority = lhsQueue?.priority ?? Int.max
                    let rhsPriority = rhsQueue?.priority ?? Int.max
                    if lhsPriority != rhsPriority {
                        return lhsPriority < rhsPriority
                    }
                    let lhsState = panelStates[lhs.panelID]
                    let rhsState = panelStates[rhs.panelID]
                    let lhsIterations = lhsState?.iterationCount ?? 0
                    let rhsIterations = rhsState?.iterationCount ?? 0
                    if lhsIterations != rhsIterations {
                        return lhsIterations < rhsIterations
                    }
                    let lhsUpdated = lhsState?.lastUpdatedAt ?? 0
                    let rhsUpdated = rhsState?.lastUpdatedAt ?? 0
                    if lhsUpdated != rhsUpdated {
                        return lhsUpdated < rhsUpdated
                    }
                    return lhs.panelTitle.localizedCaseInsensitiveCompare(rhs.panelTitle) == .orderedAscending
                }
                .first
            ?? supervisorPanelHandoffs.first
        if let selected {
            supervisorActiveLoopTarget = WorkspaceSupervisorLoopTarget(
                panelID: selected.panelID,
                panelTitle: selected.panelTitle,
                workingDirectory: selected.workingDirectory,
                selectedAt: Date().timeIntervalSince1970
            )
        } else {
            supervisorActiveLoopTarget = nil
        }
        return selected
    }

    private func markSupervisorSupportingPanels(activePanelID: UUID?, defaultAction: String) {
        let activeID = activePanelID
        for panelId in sidebarOrderedPanelIds() where panelId != activeID && panels[panelId] != nil {
            let existing = supervisorPanelRoundStates.first(where: { $0.panelID == panelId })
            let preservedStatus = existing.map { state in
                switch state.status {
                case "completed", "blocked", "attention":
                    return state.status
                default:
                    return "supporting"
                }
            } ?? "supporting"
            let summary = existing?.lastSummary.isEmpty == false
                ? existing!.lastSummary
                : "This panel is currently supporting the active workspace step."
            let outcome = existing?.lastOutcome.isEmpty == false
                ? existing!.lastOutcome
                : "Waiting for the active window to finish its current round."
            let nextAction = existing?.nextAction.isEmpty == false
                ? existing!.nextAction
                : defaultAction
            upsertSupervisorPanelState(
                panelID: panelId,
                status: preservedStatus,
                summary: summary,
                outcome: outcome,
                nextAction: nextAction,
                source: "supporting"
            )
        }
    }

    var supervisorSnapshot: WorkspaceSupervisorSnapshot {
        let focusedDirectory = focusedPanelId.flatMap { panelDirectories[$0] }
        var observedDirectories: [String] = []
        for candidate in [currentDirectory, focusedDirectory] + Array(panelDirectories.values) {
            guard let trimmed = candidate?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !trimmed.isEmpty,
                  !observedDirectories.contains(trimmed) else {
                continue
            }
            observedDirectories.append(trimmed)
        }
        let orderedStatuses = statusEntries.values
            .sorted { lhs, rhs in lhs.priority == rhs.priority ? lhs.key < rhs.key : lhs.priority > rhs.priority }
            .map { ($0.key, $0.value) }
        let recentLogs = logEntries.suffix(8).map(\.message)
        let recentRunHeadlines = supervisorRunJournal
            .prefix(6)
            .map { entry in
                let summary = entry.summary.trimmingCharacters(in: .whitespacesAndNewlines)
                return summary.isEmpty ? entry.title : "\(entry.title)：\(summary)"
            }
        return WorkspaceSupervisorSnapshot(
            title: title,
            customTitle: customTitle,
            currentDirectory: currentDirectory,
            observedDirectories: observedDirectories,
            goal: supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? supervisorGoal : supervisorTaskCharter.goal,
            doneDefinition: supervisorTaskCharter.doneDefinition,
            constraints: supervisorTaskCharter.constraints,
            scopeNotes: supervisorTaskCharter.scopeNotes,
            progressValue: progress?.value,
            progressLabel: progress?.label,
            gitBranch: gitBranch?.branch,
            gitDirty: gitBranch?.isDirty ?? false,
            remoteTarget: remoteDisplayTarget,
            remoteState: "\(remoteConnectionState)",
            remoteCompatibility: remoteSSHCompatibilitySummary,
            remoteDetail: remoteConnectionDetail,
            statusEntries: orderedStatuses,
            recentLogs: recentLogs,
            recentRunHeadlines: recentRunHeadlines,
            focusedPanelDirectory: focusedDirectory
        )
    }

    func refreshSupervisorHeuristicReview() {
        supervisorLastReview = WorkspaceSupervisorHeuristics.evaluate(snapshot: supervisorSnapshot)
        supervisorHealth = supervisorLastReview?.health ?? .idle
        supervisorUpdatedAt = Date()
        supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
            snapshot: supervisorSnapshot,
            review: supervisorLastReview,
            startupPlan: supervisorStartupPlan
        )
        refreshSupervisorPanelHandoffs()
        recordSupervisorCheckpoint(source: "heuristic")
        publishSupervisorStatusEntry()
    }

    func requestSupervisorLLMReview(endpoint: String, apiKey: String, model: String) async {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            refreshSupervisorHeuristicReview()
            return
        }

        let snapshot = supervisorSnapshot
        do {
            let review = try await WorkspaceSupervisorLLMClient.review(
                snapshot: snapshot,
                endpoint: endpoint,
                apiKey: trimmedKey,
                model: model
            )
            supervisorLastReview = review
            supervisorHealth = review.health
            supervisorUpdatedAt = Date()
            supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
                snapshot: snapshot,
                review: review,
                startupPlan: supervisorStartupPlan
            )
            refreshSupervisorPanelHandoffs()
            recordSupervisorCheckpoint(source: "llm-review")
            appendLogEntry("Supervisor LLM review updated", level: .info, source: "supervisor")
        } catch {
            refreshSupervisorHeuristicReview()
            appendLogEntry("Supervisor review failed: \(error.localizedDescription)", level: .warning, source: "supervisor")
        }
        publishSupervisorStatusEntry()
    }

    func requestSupervisorStartupPlan(endpoint: String, apiKey: String, model: String) async {
        let snapshot = supervisorSnapshot
        let interactions = supervisorInteractionNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedKey.isEmpty else {
            supervisorStartupPlan = WorkspaceSupervisorHeuristics.prepareStartupPlan(
                snapshot: snapshot,
                interactions: interactions
            )
            supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
                snapshot: snapshot,
                review: supervisorLastReview,
                startupPlan: supervisorStartupPlan
            )
            refreshSupervisorPanelHandoffs()
            return
        }

        do {
            supervisorStartupPlan = try await WorkspaceSupervisorLLMClient.startupPlan(
                snapshot: snapshot,
                interactions: interactions,
                endpoint: endpoint,
                apiKey: trimmedKey,
                model: model
            )
            appendSupervisorRun(
                title: "生成开工建议",
                summary: supervisorStartupPlan?.progressSummary ?? "已基于最近交流生成开工建议。",
                outcome: supervisorStartupPlan?.source == "llm" ? "LLM 已产出开工建议。" : "已生成开工建议。",
                nextAction: supervisorStartupPlan?.recommendedAction ?? "确认目标与第一步动作。",
                source: supervisorStartupPlan?.source ?? "startup-plan"
            )
            supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
                snapshot: snapshot,
                review: supervisorLastReview,
                startupPlan: supervisorStartupPlan
            )
            refreshSupervisorPanelHandoffs()
            appendLogEntry("已生成开工建议", level: .info, source: "supervisor")
        } catch {
            supervisorStartupPlan = WorkspaceSupervisorHeuristics.prepareStartupPlan(
                snapshot: snapshot,
                interactions: interactions
            )
            appendSupervisorRun(
                title: "生成开工建议",
                summary: supervisorStartupPlan?.progressSummary ?? "已回退到启发式开工建议。",
                outcome: "LLM 生成失败，已回退到启发式建议。",
                nextAction: supervisorStartupPlan?.recommendedAction ?? "确认目标与第一步动作。",
                source: "heuristic-fallback"
            )
            supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
                snapshot: snapshot,
                review: supervisorLastReview,
                startupPlan: supervisorStartupPlan
            )
            refreshSupervisorPanelHandoffs()
            appendLogEntry("开工建议生成失败：\(error.localizedDescription)", level: .warning, source: "supervisor")
        }
    }

    func requestSupervisorExecutionBrief(endpoint: String, apiKey: String, model: String) async {
        let snapshot = supervisorSnapshot
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedKey.isEmpty else {
            supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
                snapshot: snapshot,
                review: supervisorLastReview,
                startupPlan: supervisorStartupPlan
            )
            appendSupervisorRun(
                title: "生成执行简报",
                summary: supervisorExecutionBrief?.title ?? "已生成执行简报。",
                outcome: "已使用启发式规则整理出当前执行任务包。",
                nextAction: supervisorExecutionBrief?.executionSteps.first ?? "检查当前执行边界。",
                source: "heuristic-execution-brief"
            )
            refreshSupervisorPanelHandoffs()
            publishSupervisorStatusEntry()
            return
        }

        do {
            supervisorExecutionBrief = try await WorkspaceSupervisorLLMClient.executionBrief(
                snapshot: snapshot,
                review: supervisorLastReview,
                startupPlan: supervisorStartupPlan,
                endpoint: endpoint,
                apiKey: trimmedKey,
                model: model
            )
            appendSupervisorRun(
                title: "生成执行简报",
                summary: supervisorExecutionBrief?.title ?? "已生成执行简报。",
                outcome: supervisorExecutionBrief?.source == "llm" ? "LLM 已产出执行任务包。" : "已生成执行任务包。",
                nextAction: supervisorExecutionBrief?.executionSteps.first ?? "检查当前执行边界。",
                source: supervisorExecutionBrief?.source ?? "execution-brief"
            )
            refreshSupervisorPanelHandoffs()
            appendLogEntry("Supervisor execution brief updated", level: .info, source: "supervisor")
        } catch {
            supervisorExecutionBrief = WorkspaceSupervisorHeuristics.prepareExecutionBrief(
                snapshot: snapshot,
                review: supervisorLastReview,
                startupPlan: supervisorStartupPlan
            )
            appendSupervisorRun(
                title: "生成执行简报",
                summary: supervisorExecutionBrief?.title ?? "已回退到启发式执行简报。",
                outcome: "LLM 生成失败，已回退到启发式执行任务包。",
                nextAction: supervisorExecutionBrief?.executionSteps.first ?? "检查当前执行边界。",
                source: "heuristic-execution-fallback"
            )
            refreshSupervisorPanelHandoffs()
            appendLogEntry("Supervisor execution brief failed: \(error.localizedDescription)", level: .warning, source: "supervisor")
        }
        publishSupervisorStatusEntry()
    }

    func quickStartSupervisor(endpoint: String, apiKey: String, model: String) async {
        if supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           supervisorInteractionNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            refreshSupervisorHeuristicReview()
            return
        }

        await requestSupervisorStartupPlan(
            endpoint: endpoint,
            apiKey: apiKey,
            model: model
        )

        if supervisorTaskCharter.goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let suggestedGoal = supervisorStartupPlan?.goal.trimmingCharacters(in: .whitespacesAndNewlines),
           !suggestedGoal.isEmpty {
            supervisorTaskCharter.goal = suggestedGoal
            supervisorGoal = suggestedGoal
        }

        supervisorEnabled = true
        supervisorLastReview = WorkspaceSupervisorHeuristics.evaluate(snapshot: supervisorSnapshot)
        supervisorHealth = supervisorLastReview?.health ?? .idle
        supervisorUpdatedAt = Date()

        await requestSupervisorExecutionBrief(
            endpoint: endpoint,
            apiKey: apiKey,
            model: model
        )

        refreshSupervisorPanelHandoffs()
        appendSupervisorRun(
            title: "一键开工",
            summary: supervisorStartupPlan?.progressSummary ?? "监督器已根据最近交流整理开工上下文。",
            outcome: apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "已通过启发式规则生成开工建议与执行简报。"
                : "已生成开工建议与执行简报，并进入监督状态。",
            nextAction: supervisorExecutionBrief?.executionSteps.first
                ?? supervisorStartupPlan?.recommendedAction
                ?? "检查当前目标并执行第一步。",
            source: "quick-start"
        )
        publishSupervisorStatusEntry()
    }

    func runSupervisorAutonomyLoop(endpoint: String, apiKey: String, model: String) async {
        stopSupervisorAutonomyLoop(reason: "restart")
        let settings = supervisorLoopSettings
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        supervisorLoopState = .running
        supervisorLoopStatusSummary = "自动循环已启动，最多执行 \(settings.maxIterations) 轮。"
        let initialTarget = selectSupervisorLoopTarget()
        appendSupervisorRun(
            title: "启动自动循环",
            summary: initialTarget.map { "自动循环已启动，当前目标窗口：\($0.panelTitle)" } ?? (supervisorLoopStatusSummary ?? "自动循环已启动。"),
            outcome: "等待第一轮评估。",
            nextAction: initialTarget?.nextAction ?? "按轮次检查当前工作区状态。",
            source: "loop-start"
        )

        supervisorAutonomyLoopTask = Task { @MainActor [weak self] in
            guard let self else { return }
            var lastFingerprint: String?
            var repeatedStableCount = 0

            for iteration in 1...settings.maxIterations {
                guard !Task.isCancelled else { return }
                let activeTarget = self.selectSupervisorLoopTarget()
                if let activeTarget {
                    self.upsertSupervisorPanelState(
                        panelID: activeTarget.panelID,
                        status: "running",
                        summary: "Round \(iteration) is now executing in this window.",
                        outcome: "The supervisor selected this window as the active execution target.",
                        nextAction: activeTarget.nextAction,
                        source: "loop-selection"
                    )
                }
                self.markSupervisorSupportingPanels(
                    activePanelID: activeTarget?.panelID,
                    defaultAction: "Stand by, preserve context, and prepare to support the active execution target."
                )
                self.refreshSupervisorPanelHandoffs()

                if settings.useLLMReview, !trimmedKey.isEmpty {
                    await self.requestSupervisorLLMReview(endpoint: endpoint, apiKey: trimmedKey, model: model)
                } else {
                    self.refreshSupervisorHeuristicReview()
                }

                guard let review = self.supervisorLastReview else { continue }
                let fingerprint = "\(review.health.rawValue)|\(review.nextAction)|\(review.summary)"
                if fingerprint == lastFingerprint {
                    repeatedStableCount += 1
                } else {
                    repeatedStableCount = 0
                    lastFingerprint = fingerprint
                }

                let targetText = activeTarget.map { "\($0.panelTitle) @ \($0.workingDirectory)" } ?? "当前工作区"
                let panelStatus = WorkspaceSupervisorHeuristics.handoffStatus(for: review)
                if let activeTarget {
                    self.upsertSupervisorPanelState(
                        panelID: activeTarget.panelID,
                        status: panelStatus,
                        summary: review.summary,
                        outcome: review.reason,
                        nextAction: review.nextAction,
                        source: settings.useLLMReview && !trimmedKey.isEmpty ? "loop-llm" : "loop-heuristic",
                        iteration: iteration
                    )
                }
                self.markSupervisorSupportingPanels(
                    activePanelID: activeTarget?.panelID,
                    defaultAction: "Review whether this window can unblock or accelerate the active execution target."
                )
                self.refreshSupervisorPanelHandoffs()
                self.supervisorLoopStatusSummary = "第 \(iteration)/\(settings.maxIterations) 轮已完成，当前状态：\(review.health.displayText)，目标窗口：\(targetText)。"
                self.appendSupervisorRun(
                    title: "自动循环第 \(iteration) 轮",
                    summary: activeTarget.map { "[\($0.panelTitle)] \(review.summary)" } ?? review.summary,
                    outcome: activeTarget.map { "目标窗口：\($0.panelTitle)。\(review.reason)" } ?? review.reason,
                    nextAction: activeTarget?.nextAction ?? review.nextAction,
                    source: settings.useLLMReview && !trimmedKey.isEmpty ? "loop-llm" : "loop-heuristic"
                )

                if settings.stopOnCompleted, review.health == .completed {
                    self.supervisorLoopState = .completed
                    self.supervisorLoopStatusSummary = "自动循环已停止：监督器判断任务已完成。"
                    self.supervisorActiveLoopTarget = nil
                    self.supervisorAutonomyLoopTask = nil
                    return
                }

                if settings.stopOnBlocked, review.health == .blocked {
                    let handoffs = self.supervisorPanelHandoffs
                    let stateByPanelID = self.supervisorPanelStateMap()
                    let queueByPanelID = self.supervisorQueueMap()
                    if self.supervisorCanContinuePastBlockedReview(
                        activePanelID: activeTarget?.panelID,
                        handoffs: handoffs,
                        stateByPanelID: stateByPanelID,
                        queueByPanelID: queueByPanelID
                    ) {
                        self.supervisorLoopStatusSummary = "第 \(iteration)/\(settings.maxIterations) 轮识别到阻塞，下一轮将切换到支援窗口尝试解阻。"
                    } else {
                        self.supervisorLoopState = .blocked
                        self.supervisorLoopStatusSummary = "自动循环已停止：监督器判断当前任务已阻塞。"
                        self.supervisorActiveLoopTarget = nil
                        self.supervisorAutonomyLoopTask = nil
                        return
                    }
                }

                if repeatedStableCount >= 1 {
                    self.supervisorLoopState = .stopped
                    self.supervisorLoopStatusSummary = "自动循环已停止：连续两轮没有新的判断变化。"
                    self.supervisorAutonomyLoopTask = nil
                    return
                }

                if iteration < settings.maxIterations {
                    let waitNs = UInt64(max(1, settings.intervalSeconds) * 1_000_000_000)
                    try? await Task.sleep(nanoseconds: waitNs)
                }
            }

            self.supervisorLoopState = .stopped
            self.supervisorLoopStatusSummary = "自动循环已完成设定轮次。"
            self.supervisorActiveLoopTarget = nil
            self.supervisorAutonomyLoopTask = nil
        }
    }

    func stopSupervisorAutonomyLoop(reason: String) {
        supervisorAutonomyLoopTask?.cancel()
        supervisorAutonomyLoopTask = nil
        supervisorActiveLoopTarget = nil
        if supervisorLoopState == .running {
            supervisorLoopState = .stopped
            supervisorLoopStatusSummary = reason == "manual" ? "自动循环已手动停止。" : "自动循环已停止。"
            appendSupervisorRun(
                title: "停止自动循环",
                summary: supervisorLoopStatusSummary ?? "自动循环已停止。",
                outcome: "当前不会继续自动评估。",
                nextAction: "如需继续，请再次启动自动循环。",
                source: "loop-stop"
            )
        }
    }

    func recordSupervisorCheckpoint(source: String) {
        let review = supervisorLastReview ?? WorkspaceSupervisorHeuristics.evaluate(snapshot: supervisorSnapshot)
        appendSupervisorRun(
            title: "监督循环检查",
            summary: review.summary,
            outcome: review.reason,
            nextAction: review.nextAction,
            source: source
        )
    }

    private func appendSupervisorRun(
        title: String,
        summary: String,
        outcome: String,
        nextAction: String,
        source: String
    ) {
        let entry = WorkspaceSupervisorRunEntry(
            title: title,
            summary: summary,
            outcome: outcome,
            nextAction: nextAction,
            source: source
        )
        supervisorRunJournal.insert(entry, at: 0)
        if supervisorRunJournal.count > 40 {
            supervisorRunJournal.removeLast(supervisorRunJournal.count - 40)
        }
    }

    func publishSupervisorStatusEntry() {
        guard supervisorEnabled else {
            statusEntries.removeValue(forKey: "supervisor.health")
            metadataBlocks.removeValue(forKey: "supervisor.review")
            return
        }

        guard let review = supervisorLastReview else {
            statusEntries.removeValue(forKey: "supervisor.health")
            metadataBlocks.removeValue(forKey: "supervisor.review")
            return
        }
        let color: String
        switch review.health {
        case .idle: color = "gray"
        case .running: color = "blue"
        case .attention: color = "orange"
        case .blocked: color = "red"
        case .completed: color = "green"
        }

        statusEntries["supervisor.health"] = SidebarStatusEntry(
            key: "监督器",
            value: review.health.displayText,
            icon: "brain",
            color: color,
            priority: 95,
            timestamp: Date()
        )
        metadataBlocks["supervisor.review"] = SidebarMetadataBlock(
            key: "监督器",
            markdown: """
            **目标**
            \((supervisorTaskCharter.goal.isEmpty ? supervisorGoal : supervisorTaskCharter.goal).isEmpty ? "未设置" : (supervisorTaskCharter.goal.isEmpty ? supervisorGoal : supervisorTaskCharter.goal))

            **完成标准**
            \(supervisorTaskCharter.doneDefinition.isEmpty ? "未设置" : supervisorTaskCharter.doneDefinition)

            **约束与范围**
            \((supervisorTaskCharter.constraints + "\n" + supervisorTaskCharter.scopeNotes).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "未设置" : (supervisorTaskCharter.constraints + "\n" + supervisorTaskCharter.scopeNotes).trimmingCharacters(in: .whitespacesAndNewlines))

            **进度摘要**
            \(review.summary)

            **判断依据**
            \(review.reason)

            **下一步动作**
            \(review.nextAction)

            **建议提示词**
            ```
            \(review.suggestedPrompt)
            ```

            **执行简报**
            \(supervisorExecutionBrief?.title ?? "未生成")

            **执行模型提示词**
            ```
            \(supervisorExecutionBrief?.operatorPrompt ?? "暂无")
            ```

            **窗口交接数**
            \(supervisorPanelHandoffs.count)

            **当前循环窗口**
            \(supervisorActiveLoopTarget?.panelTitle ?? "未选定")

            **最近一次循环**
            \(supervisorRunJournal.first?.summary ?? "暂无")
            """,
            priority: 95,
            timestamp: Date()
        )
    }
}
