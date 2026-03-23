import Foundation
import SwiftUI

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

struct WorkspaceSupervisorSnapshot: Sendable {
    var title: String
    var customTitle: String?
    var currentDirectory: String
    var observedDirectories: [String]
    var goal: String
    var progressValue: Double?
    var progressLabel: String?
    var gitBranch: String?
    var gitDirty: Bool
    var remoteTarget: String?
    var remoteState: String
    var remoteDetail: String?
    var statusEntries: [(key: String, value: String)]
    var recentLogs: [String]
    var focusedPanelDirectory: String?
}

enum WorkspaceSupervisorHeuristics {
    static func evaluate(snapshot: WorkspaceSupervisorSnapshot) -> WorkspaceSupervisorReview {
        let normalizedGoal = snapshot.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        let recentText = ([snapshot.remoteDetail] + snapshot.statusEntries.map(\.value) + snapshot.recentLogs)
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
            nextAction = "先补充一个可以验收的目标，再让监督器判断进度和下一步。"
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
        let inferredGoal = snapshot.goal.isEmpty
            ? (interactionLines.first ?? "整理需求并形成一个可执行、可验收的工作目标。")
            : snapshot.goal
        let progress = snapshot.recentLogs.isEmpty
            ? "当前项目进度信息较少，需要先根据用户最近 2-3 轮交流补齐上下文。"
            : "已读取到最近工作区日志与状态，可以在此基础上快速判断当前进展与阻塞点。"
        let nextAction = interactionLines.isEmpty
            ? "先补充 2-3 轮用户需求或补充说明，再生成可执行开工建议。"
            : "基于最近交流整理目标、确认约束、拆出第一步可执行动作，然后立即开工。"
        let prompt = """
        请根据以下用户交流，提炼最终目标、当前进度判断、约束条件，并直接给出第一步执行动作：
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
}

enum WorkspaceSupervisorSettings {
    static let endpointKey = "workspaceSupervisor.endpoint"
    static let apiKeyKey = "workspaceSupervisor.apiKey"
    static let modelKey = "workspaceSupervisor.model"
    static let defaultEndpoint = "https://api.openai.com/v1/chat/completions"
    static let defaultModel = "gpt-4.1-mini"
}

struct SupervisorPaneView: View {
    @ObservedObject var workspace: Workspace
    @AppStorage(WorkspaceSupervisorSettings.endpointKey) private var endpoint = WorkspaceSupervisorSettings.defaultEndpoint
    @AppStorage(WorkspaceSupervisorSettings.apiKeyKey) private var apiKey = ""
    @AppStorage(WorkspaceSupervisorSettings.modelKey) private var model = WorkspaceSupervisorSettings.defaultModel
    @State private var isRunningLLMReview = false
    @State private var isGeneratingStartupPlan = false
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .center, spacing: 12) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [reviewHealth.tint.opacity(0.9), reviewHealth.tint.opacity(0.55)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)
                            .overlay {
                                Image(systemName: "brain")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("监督器")
                                .font(.title3.weight(.semibold))
                            Text("根据目标、日志、远程状态与最近交流，快速判断当前项目是否可开工。")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Text(reviewHealth.displayText)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundStyle(reviewHealth == .idle ? Color.primary : Color.white)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(reviewHealth == .idle ? reviewHealth.tint.opacity(0.15) : reviewHealth.tint)
                            )
                    }

                    HStack(spacing: 12) {
                        SupervisorMetricPill(title: "目标", value: workspace.supervisorGoal.isEmpty ? "未设置" : "已设定")
                        SupervisorMetricPill(title: "开工建议", value: workspace.supervisorStartupPlan == nil ? "未生成" : "已生成")
                        SupervisorMetricPill(title: "最近更新", value: updatedText)
                    }

                    HStack(spacing: 10) {
                        Toggle("启用监督", isOn: $workspace.supervisorEnabled)
                            .toggleStyle(.switch)

                        Spacer()

                        Button("刷新判断") {
                            workspace.refreshSupervisorHeuristicReview()
                        }
                        .buttonStyle(SupervisorSecondaryButtonStyle())
                        .disabled(!workspace.supervisorEnabled)

                        Button(isRunningLLMReview ? "评估中..." : "运行 LLM 评估") {
                            Task {
                                isRunningLLMReview = true
                                await workspace.requestSupervisorLLMReview(
                                    endpoint: endpoint,
                                    apiKey: apiKey,
                                    model: model
                                )
                                isRunningLLMReview = false
                            }
                        }
                        .buttonStyle(SupervisorPrimaryButtonStyle())
                        .disabled(!workspace.supervisorEnabled || isRunningLLMReview)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.primary.opacity(0.045))
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("目标")
                        .font(.headline)
                    TextEditor(text: $workspace.supervisorGoal)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(minHeight: 96)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.primary.opacity(0.05))
                        )
                    Text("建议写成可以验收的一句话，例如：完成 SSH 远程资源管理器并保证能稳定连接。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("最近 2-3 轮用户交流")
                        .font(.headline)
                    TextEditor(text: $workspace.supervisorInteractionNotes)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.primary.opacity(0.05))
                        )
                    HStack(spacing: 10) {
                        Button(isGeneratingStartupPlan ? "生成中..." : "生成开工建议") {
                            Task {
                                isGeneratingStartupPlan = true
                                await workspace.requestSupervisorStartupPlan(
                                    endpoint: endpoint,
                                    apiKey: apiKey,
                                    model: model
                                )
                                isGeneratingStartupPlan = false
                            }
                        }
                        .buttonStyle(SupervisorPrimaryButtonStyle())

                        if let startupPlan = workspace.supervisorStartupPlan, !startupPlan.goal.isEmpty {
                            Button("采用建议目标") {
                                workspace.supervisorGoal = startupPlan.goal
                                workspace.supervisorEnabled = true
                                workspace.scheduleSupervisorHeuristicRefresh(delay: 0.1)
                            }
                            .buttonStyle(SupervisorSecondaryButtonStyle())
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    SupervisorReviewCard(title: "当前目录", content: workspace.supervisorSnapshot.currentDirectory, monospaced: true)
                    if let remoteTarget = workspace.supervisorSnapshot.remoteTarget, !remoteTarget.isEmpty {
                        SupervisorReviewCard(title: "远程目标", content: remoteTarget)
                    }
                    if !workspace.supervisorSnapshot.observedDirectories.isEmpty {
                        SupervisorReviewCard(
                            title: "已记录目录",
                            content: workspace.supervisorSnapshot.observedDirectories.joined(separator: "\n"),
                            monospaced: true
                        )
                    }
                }

                if let startupPlan = workspace.supervisorStartupPlan {
                    VStack(alignment: .leading, spacing: 10) {
                        SupervisorReviewCard(title: "建议目标", content: startupPlan.goal)
                        SupervisorReviewCard(title: "当前进度判断", content: startupPlan.progressSummary)
                        SupervisorReviewCard(title: "建议下一步", content: startupPlan.recommendedAction)
                        SupervisorReviewCard(title: "可直接开工的提示词", content: startupPlan.starterPrompt, monospaced: true)
                        SupervisorReviewCard(title: "前提假设", content: startupPlan.assumptions)
                    }
                }

                if let review {
                    VStack(alignment: .leading, spacing: 10) {
                        SupervisorReviewCard(title: "进度摘要", content: review.summary)
                        SupervisorReviewCard(title: "判断依据", content: review.reason)
                        SupervisorReviewCard(title: "当前建议动作", content: review.nextAction)
                        SupervisorReviewCard(title: "监督提示词", content: review.suggestedPrompt, monospaced: true)
                    }
                } else {
                    SupervisorReviewCard(
                        title: "进度摘要",
                        content: "正在整理当前工作区状态，稍后会生成监督判断。"
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("LLM 设置")
                        .font(.headline)
                    TextField("接口地址", text: $endpoint)
                        .textFieldStyle(.roundedBorder)
                    TextField("模型名称", text: $model)
                        .textFieldStyle(.roundedBorder)
                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                    Text(llmSavedText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("最近更新时间：\(updatedText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(Color.clear)
        .onAppear {
            if workspace.supervisorEnabled, workspace.supervisorLastReview == nil {
                workspace.scheduleSupervisorHeuristicRefresh(delay: 0.1)
            }
        }
        .onChange(of: endpoint) { llmSettingsSavedAt = Date() }
        .onChange(of: model) { llmSettingsSavedAt = Date() }
        .onChange(of: apiKey) { llmSettingsSavedAt = Date() }
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
    }
}

private struct SupervisorMetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
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
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.8 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
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

private struct SupervisorReviewCard: View {
    let title: String
    let content: String
    var monospaced: Bool = false

    var bodyView: some View {
        Text(content.isEmpty ? "暂无内容" : content)
            .font(monospaced ? .system(size: 12, design: .monospaced) : .system(size: 12))
            .foregroundStyle(.primary)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            bodyView
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
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
            throw NSError(domain: "cmux.supervisor", code: 10, userInfo: [NSLocalizedDescriptionKey: "Invalid LLM endpoint URL"])
        }

        let prompt = """
        Return strict JSON with keys:
        health, summary, reason, nextAction, suggestedPrompt

        Health must be one of: idle, running, attention, blocked, completed.

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
            throw NSError(domain: "cmux.supervisor", code: 11, userInfo: [NSLocalizedDescriptionKey: errorText])
        }

        let decoded = try JSONDecoder().decode(WorkspaceSupervisorLLMResponse.self, from: data)
        let content = decoded.choices.first?.message.content ?? ""
        guard let payloadData = content.data(using: .utf8),
              let payload = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            throw NSError(domain: "cmux.supervisor", code: 12, userInfo: [NSLocalizedDescriptionKey: "LLM returned invalid JSON"])
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
            throw NSError(domain: "cmux.supervisor", code: 10, userInfo: [NSLocalizedDescriptionKey: "无效的 LLM 接口地址"])
        }

        let prompt = """
        你是一个终端工作区的项目监督器。请根据当前工作区状态和最近 2-3 轮用户交流，输出严格 JSON，包含以下字段：
        goal, progressSummary, recommendedAction, starterPrompt, assumptions

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
            throw NSError(domain: "cmux.supervisor", code: 11, userInfo: [NSLocalizedDescriptionKey: errorText])
        }

        let decoded = try JSONDecoder().decode(WorkspaceSupervisorLLMResponse.self, from: data)
        let content = decoded.choices.first?.message.content ?? ""
        guard let payloadData = content.data(using: .utf8),
              let payload = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            throw NSError(domain: "cmux.supervisor", code: 12, userInfo: [NSLocalizedDescriptionKey: "LLM 返回了无效 JSON"])
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

    private static func serializedSnapshot(_ snapshot: WorkspaceSupervisorSnapshot) -> String {
        let payload: [String: Any] = [
            "title": snapshot.title,
            "customTitle": snapshot.customTitle as Any,
            "currentDirectory": snapshot.currentDirectory,
            "observedDirectories": snapshot.observedDirectories,
            "goal": snapshot.goal,
            "progressValue": snapshot.progressValue as Any,
            "progressLabel": snapshot.progressLabel as Any,
            "gitBranch": snapshot.gitBranch as Any,
            "gitDirty": snapshot.gitDirty,
            "remoteTarget": snapshot.remoteTarget as Any,
            "remoteState": snapshot.remoteState,
            "remoteDetail": snapshot.remoteDetail as Any,
            "statusEntries": snapshot.statusEntries.map { ["key": $0.key, "value": $0.value] },
            "recentLogs": snapshot.recentLogs,
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

    private static func stringValue(_ value: Any?) -> String? {
        guard let value else { return nil }
        let text = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}

extension Workspace {
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
        return WorkspaceSupervisorSnapshot(
            title: title,
            customTitle: customTitle,
            currentDirectory: currentDirectory,
            observedDirectories: observedDirectories,
            goal: supervisorGoal,
            progressValue: progress?.value,
            progressLabel: progress?.label,
            gitBranch: gitBranch?.branch,
            gitDirty: gitBranch?.isDirty ?? false,
            remoteTarget: remoteDisplayTarget,
            remoteState: "\(remoteConnectionState)",
            remoteDetail: remoteConnectionDetail,
            statusEntries: orderedStatuses,
            recentLogs: recentLogs,
            focusedPanelDirectory: focusedDirectory
        )
    }

    func refreshSupervisorHeuristicReview() {
        supervisorLastReview = WorkspaceSupervisorHeuristics.evaluate(snapshot: supervisorSnapshot)
        supervisorHealth = supervisorLastReview?.health ?? .idle
        supervisorUpdatedAt = Date()
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
            appendLogEntry("已生成开工建议", level: .info, source: "supervisor")
        } catch {
            supervisorStartupPlan = WorkspaceSupervisorHeuristics.prepareStartupPlan(
                snapshot: snapshot,
                interactions: interactions
            )
            appendLogEntry("开工建议生成失败：\(error.localizedDescription)", level: .warning, source: "supervisor")
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
            \(supervisorGoal.isEmpty ? "未设置" : supervisorGoal)

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
            """,
            priority: 95,
            timestamp: Date()
        )
    }
}
