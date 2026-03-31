import Bonsplit
import SwiftUI

struct NotificationsPage: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var notificationStore: TerminalNotificationStore
    @EnvironmentObject var tabManager: TabManager
    @Binding var selection: SidebarSelection
    @FocusState private var focusedNotificationId: UUID?
    @AppStorage(KeyboardShortcutSettings.Action.jumpToUnread.defaultsKey) private var jumpToUnreadShortcutData = Data()

    private let pageHorizontalPadding: CGFloat = 18
    private let pageTopPadding: CGFloat = 18

    var body: some View {
        ZStack {
            ICCCanvasBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, pageHorizontalPadding)
                    .padding(.top, pageTopPadding)
                    .padding(.bottom, 14)

                if notificationStore.notifications.isEmpty {
                    emptyState
                        .padding(.horizontal, pageHorizontalPadding)
                        .padding(.bottom, 20)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            summaryStrip
                            notificationFeed
                        }
                        .padding(.horizontal, pageHorizontalPadding)
                        .padding(.bottom, 20)
                    }
                    .scrollIndicators(.visible)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: setInitialFocus)
        .onChange(of: notificationStore.notifications.first?.id) { _ in
            setInitialFocus()
        }
    }

    private func setInitialFocus() {
        guard selection == .notifications else { return }
        guard let firstId = notificationStore.notifications.first?.id else {
            focusedNotificationId = nil
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            focusedNotificationId = firstId
        }
    }

    private var header: some View {
        ICCSidebarCard(emphasized: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ICCIconBadge(
                        systemImage: hasUnreadNotifications ? "bell.badge.fill" : "bell",
                        primary: ICCChrome.accent(for: colorScheme),
                        secondary: ICCChrome.secondaryAccent(for: colorScheme)
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("通知中心")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("集中处理任务提醒、终端消息和桌面通知，避免在会话区来回跳转。")
                            .font(.system(size: 13.5, weight: .medium))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 12)

                    notificationStatusBadge
                }

                ViewThatFits(in: .horizontal) {
                    actionRow
                    compactActionRow
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            jumpToUnreadButton
            openSettingsButton

            if !notificationStore.notifications.isEmpty {
                clearAllButton
            }
        }
    }

    private var compactActionRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                jumpToUnreadButton
                openSettingsButton
            }

            if !notificationStore.notifications.isEmpty {
                clearAllButton
            }
        }
    }

    private var notificationStatusBadge: some View {
        ICCStatusPill(
            text: hasUnreadNotifications ? "有未读提醒" : "全部已读",
            tint: hasUnreadNotifications ? ICCChrome.accent(for: colorScheme) : .secondary,
            emphasized: hasUnreadNotifications
        )
    }

    private var summaryStrip: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                NotificationsSummaryCard(
                    title: "总数",
                    value: "\(notificationStore.notifications.count)",
                    subtitle: "当前收件箱"
                )

                NotificationsSummaryCard(
                    title: "未读",
                    value: "\(unreadCount)",
                    subtitle: unreadCount == 0 ? "已清空" : "需要处理"
                )

                NotificationsSummaryCard(
                    title: "最新",
                    value: latestNotificationTimeText,
                    subtitle: "最近一条提醒"
                )
            }

            VStack(spacing: 12) {
                NotificationsSummaryCard(
                    title: "总数",
                    value: "\(notificationStore.notifications.count)",
                    subtitle: "当前收件箱"
                )

                NotificationsSummaryCard(
                    title: "未读",
                    value: "\(unreadCount)",
                    subtitle: unreadCount == 0 ? "已清空" : "需要处理"
                )

                NotificationsSummaryCard(
                    title: "最新",
                    value: latestNotificationTimeText,
                    subtitle: "最近一条提醒"
                )
            }
        }
    }

    private var notificationFeed: some View {
        ICCSidebarCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("消息列表")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("点击卡片可直接跳转到对应会话")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }

                LazyVStack(spacing: 10) {
                    ForEach(notificationStore.notifications) { notification in
                        NotificationRow(
                            notification: notification,
                            tabTitle: tabTitle(for: notification.tabId),
                            onOpen: {
                                DispatchQueue.main.async {
                                    _ = AppDelegate.shared?.openNotification(
                                        tabId: notification.tabId,
                                        surfaceId: notification.surfaceId,
                                        notificationId: notification.id
                                    )
                                    selection = .tabs
                                }
                            },
                            onClear: {
                                notificationStore.remove(id: notification.id)
                            },
                            focusedNotificationId: $focusedNotificationId
                        )
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer(minLength: 20)

            ICCSidebarCard(emphasized: true) {
                VStack(spacing: 12) {
                    ICCIconBadge(
                        systemImage: "bell.slash",
                        primary: ICCChrome.accent(for: colorScheme),
                        secondary: ICCChrome.secondaryAccent(for: colorScheme)
                    )

                    Text("暂时没有通知")
                        .font(.system(size: 18, weight: .semibold))

                    Text("新的桌面通知和任务提醒会出现在这里，方便统一查看和回到对应会话。")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 360)

                    HStack(spacing: 10) {
                        openSettingsButton
                        jumpToUnreadButton
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
            }

            Spacer()
        }
    }

    private var openSettingsButton: some View {
        Button {
            AppDelegate.shared?.openPreferencesWindow(
                debugSource: "notifications.page",
                navigationTarget: .notifications
            )
        } label: {
            Label("通知设置", systemImage: "slider.horizontal.3")
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }

    private var clearAllButton: some View {
        Button("全部清除") {
            notificationStore.clearAll()
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }

    @ViewBuilder
    private var jumpToUnreadButton: some View {
        if let key = jumpToUnreadShortcut.keyEquivalent {
            Button(action: {
                AppDelegate.shared?.jumpToLatestUnread()
            }) {
                HStack(spacing: 8) {
                    Label("跳到最新未读", systemImage: "arrow.turn.down.right")
                    ShortcutAnnotation(text: jumpToUnreadShortcut.displayString)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .keyboardShortcut(key, modifiers: jumpToUnreadShortcut.eventModifiers)
            .safeHelp(KeyboardShortcutSettings.Action.jumpToUnread.tooltip("Jump to Latest Unread"))
            .disabled(!hasUnreadNotifications)
        } else {
            Button(action: {
                AppDelegate.shared?.jumpToLatestUnread()
            }) {
                HStack(spacing: 8) {
                    Label("跳到最新未读", systemImage: "arrow.turn.down.right")
                    ShortcutAnnotation(text: jumpToUnreadShortcut.displayString)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .safeHelp(KeyboardShortcutSettings.Action.jumpToUnread.tooltip("Jump to Latest Unread"))
            .disabled(!hasUnreadNotifications)
        }
    }

    private var jumpToUnreadShortcut: StoredShortcut {
        decodeShortcut(
            from: jumpToUnreadShortcutData,
            fallback: KeyboardShortcutSettings.Action.jumpToUnread.defaultShortcut
        )
    }

    private var hasUnreadNotifications: Bool {
        unreadCount > 0
    }

    private var unreadCount: Int {
        notificationStore.notifications.reduce(into: 0) { count, notification in
            if !notification.isRead {
                count += 1
            }
        }
    }

    private var latestNotificationTimeText: String {
        guard let latest = notificationStore.notifications.first else {
            return "--"
        }
        return latest.createdAt.formatted(date: .omitted, time: .shortened)
    }

    private func decodeShortcut(from data: Data, fallback: StoredShortcut) -> StoredShortcut {
        guard !data.isEmpty,
              let shortcut = try? JSONDecoder().decode(StoredShortcut.self, from: data) else {
            return fallback
        }
        return shortcut
    }

    private func tabTitle(for tabId: UUID) -> String? {
        AppDelegate.shared?.tabTitle(for: tabId) ?? tabManager.tabs.first(where: { $0.id == tabId })?.title
    }
}

private struct NotificationsSummaryCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        ICCMetricCard(title: title, value: value, subtitle: subtitle)
    }
}

struct ShortcutAnnotation: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String
    var accessibilityIdentifier: String? = nil

    @ViewBuilder
    var body: some View {
        if let accessibilityIdentifier {
            badge.accessibilityIdentifier(accessibilityIdentifier)
        } else {
            badge
        }
    }

    private var badge: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(.primary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(ICCChrome.cardGradient(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9), lineWidth: 1)
                    )
            )
    }
}

private struct NotificationRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let notification: TerminalNotification
    let tabTitle: String?
    let onOpen: () -> Void
    let onClear: () -> Void
    let focusedNotificationId: FocusState<UUID?>.Binding

    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onOpen) {
                HStack(alignment: .top, spacing: 14) {
                    unreadIndicator

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text(notification.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)

                            Spacer(minLength: 8)

                            Text(notification.createdAt.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                        }

                        if !notification.body.isEmpty {
                            Text(notification.body)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(spacing: 8) {
                            if let tabTitle, !tabTitle.isEmpty {
                                notificationMetaPill(systemImage: "rectangle.stack", text: tabTitle)
                            }

                            notificationMetaPill(
                                systemImage: notification.isRead ? "checkmark.circle" : "circle.badge",
                                text: notification.isRead ? "已读" : "未读"
                            )

                            Spacer(minLength: 8)

                            Label("打开", systemImage: "arrow.up.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(isHovering ? .primary : .secondary)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("NotificationRow.\(notification.id.uuidString)")
            .focusable()
            .focused(focusedNotificationId, equals: notification.id)
            .modifier(DefaultActionModifier(isActive: focusedNotificationId.wrappedValue == notification.id))

            Button(action: onClear) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.primary.opacity(isHovering ? 0.08 : 0.04))
                    )
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0.72)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardBackgroundGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(cardBorderColor, lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onHover { isHovering = $0 }
    }

    private var unreadIndicator: some View {
        Circle()
            .fill(notification.isRead ? Color.clear : iccAccentColor())
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(iccAccentColor().opacity(notification.isRead ? 0.28 : 1), lineWidth: 1.2)
            )
            .padding(.top, 6)
    }

    private var cardBackgroundGradient: LinearGradient {
        if isHovering {
            return ICCChrome.cardGradient(for: colorScheme, emphasized: true)
        }
        return ICCChrome.cardGradient(for: colorScheme)
    }

    private var cardBorderColor: Color {
        notification.isRead
            ? ICCChrome.borderColor(for: colorScheme, emphasis: 1.05)
            : ICCChrome.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.34 : 0.26)
    }

    private func notificationMetaPill(systemImage: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(ICCChrome.mutedFill(for: colorScheme))
        )
    }
}

private struct DefaultActionModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content.keyboardShortcut(.defaultAction)
        } else {
            content
        }
    }
}
