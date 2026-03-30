import AppKit
import Bonsplit
import Combine
import SwiftUI

final class NonDraggableHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { false }
}

enum TitlebarControlsStyle: Int, CaseIterable, Identifiable {
    case classic
    case compact
    case roomy
    case pillGroup
    case softButtons

    var id: Int { rawValue }

    var menuTitle: String {
        switch self {
        case .classic:
            return "Classic"
        case .compact:
            return "Compact"
        case .roomy:
            return "Roomy"
        case .pillGroup:
            return "Pill Group"
        case .softButtons:
            return "Soft Buttons"
        }
    }

    var config: TitlebarControlsStyleConfig {
        switch self {
        case .classic:
            return TitlebarControlsStyleConfig(
                spacing: 6,
                iconSize: 14,
                buttonSize: 24,
                badgeSize: 14,
                badgeOffset: CGSize(width: 2, height: -2),
                groupBackground: true,
                groupPadding: EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5),
                buttonBackground: false,
                buttonCornerRadius: 8,
                hoverBackground: true
            )
        case .compact:
            return TitlebarControlsStyleConfig(
                spacing: 5,
                iconSize: 13,
                buttonSize: 19,
                badgeSize: 12,
                badgeOffset: CGSize(width: 1, height: -1),
                groupBackground: true,
                groupPadding: EdgeInsets(top: 1, leading: 3, bottom: 1, trailing: 3),
                buttonBackground: false,
                buttonCornerRadius: 6,
                hoverBackground: true
            )
        case .roomy:
            return TitlebarControlsStyleConfig(
                spacing: 14,
                iconSize: 16,
                buttonSize: 28,
                badgeSize: 16,
                badgeOffset: CGSize(width: 3, height: -3),
                groupBackground: false,
                groupPadding: EdgeInsets(),
                buttonBackground: false,
                buttonCornerRadius: 10,
                hoverBackground: false
            )
        case .pillGroup:
            return TitlebarControlsStyleConfig(
                spacing: 8,
                iconSize: 14,
                buttonSize: 24,
                badgeSize: 14,
                badgeOffset: CGSize(width: 2, height: -2),
                groupBackground: false,
                groupPadding: EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4),
                buttonBackground: false,
                buttonCornerRadius: 8,
                hoverBackground: true
            )
        case .softButtons:
            return TitlebarControlsStyleConfig(
                spacing: 8,
                iconSize: 15,
                buttonSize: 26,
                badgeSize: 14,
                badgeOffset: CGSize(width: 2, height: -2),
                groupBackground: false,
                groupPadding: EdgeInsets(),
                buttonBackground: true,
                buttonCornerRadius: 8,
                hoverBackground: false
            )
        }
    }
}

struct TitlebarControlsStyleConfig {
    let spacing: CGFloat
    let iconSize: CGFloat
    let buttonSize: CGFloat
    let badgeSize: CGFloat
    let badgeOffset: CGSize
    let groupBackground: Bool
    let groupPadding: EdgeInsets
    let buttonBackground: Bool
    let buttonCornerRadius: CGFloat
    let hoverBackground: Bool
}

final class TitlebarControlsViewModel: ObservableObject {
    weak var notificationsAnchorView: NSView?
}

extension Notification.Name {
    static let cmuxNotificationsPopoverVisibilityDidChange = Notification.Name("cmux.notificationsPopoverVisibilityDidChange")
}

private enum NotificationsPopoverVisibilityUserInfoKey {
    static let isShown = "isShown"
}

private func postNotificationsPopoverVisibilityDidChange(isShown: Bool) {
    NotificationCenter.default.post(
        name: .cmuxNotificationsPopoverVisibilityDidChange,
        object: nil,
        userInfo: [NotificationsPopoverVisibilityUserInfoKey.isShown: isShown]
    )
}

struct NotificationsAnchorView: NSViewRepresentable {
    let onResolve: (NSView) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = AnchorNSView()
        view.onLayout = { [weak view] in
            guard let view else { return }
            onResolve(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

final class AnchorNSView: NSView {
    var onLayout: (() -> Void)?

    override func layout() {
        super.layout()
        onLayout?()
    }
}

struct ShortcutHintLanePlanner {
    static func assignLanes(for intervals: [ClosedRange<CGFloat>], minSpacing: CGFloat = 4) -> [Int] {
        guard !intervals.isEmpty else { return [] }

        var laneMaxX: [CGFloat] = []
        var lanes: [Int] = []
        lanes.reserveCapacity(intervals.count)

        for interval in intervals {
            var lane = 0
            while lane < laneMaxX.count {
                let requiredMinX = laneMaxX[lane] + minSpacing
                if interval.lowerBound >= requiredMinX {
                    break
                }
                lane += 1
            }

            if lane == laneMaxX.count {
                laneMaxX.append(interval.upperBound)
            } else {
                laneMaxX[lane] = max(laneMaxX[lane], interval.upperBound)
            }
            lanes.append(lane)
        }

        return lanes
    }
}

struct ShortcutHintHorizontalPlanner {
    static func assignRightEdges(for intervals: [ClosedRange<CGFloat>], minSpacing: CGFloat = 6) -> [CGFloat] {
        guard !intervals.isEmpty else { return [] }

        var assignedRightEdges = Array(repeating: CGFloat.zero, count: intervals.count)
        var nextMaxRight = CGFloat.greatestFiniteMagnitude

        for index in stride(from: intervals.count - 1, through: 0, by: -1) {
            let interval = intervals[index]
            let width = interval.upperBound - interval.lowerBound
            let preferredRightEdge = interval.upperBound
            let adjustedRightEdge = min(preferredRightEdge, nextMaxRight)
            assignedRightEdges[index] = adjustedRightEdge
            nextMaxRight = adjustedRightEdge - width - minSpacing
        }

        return assignedRightEdges
    }
}

func titlebarShortcutHintHeight(for config: TitlebarControlsStyleConfig) -> CGFloat {
    max(14, config.iconSize + 1)
}

func titlebarShortcutHintVerticalOffset(for config: TitlebarControlsStyleConfig) -> CGFloat {
    max(0, floor(config.buttonSize - titlebarShortcutHintHeight(for: config)))
}

struct TitlebarControlButton<Content: View>: View {
    let config: TitlebarControlsStyleConfig
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    @State private var isHovering = false

    var body: some View {
        let baseButton = Button(action: action) {
            content()
                .frame(width: config.buttonSize, height: config.buttonSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: config.buttonSize, height: config.buttonSize)
        .contentShape(Rectangle())
        .background(hoverBackground)

        if titlebarControlsShouldTrackButtonHover(config: config) {
            baseButton.onHover { isHovering = $0 }
        } else {
            baseButton
        }
    }

    @ViewBuilder
    private var hoverBackground: some View {
        if config.hoverBackground && isHovering {
            RoundedRectangle(cornerRadius: config.buttonCornerRadius, style: .continuous)
                .fill(Color.primary.opacity(0.08))
        }
    }
}

struct TitlebarControlsView: View {
    enum LayoutMode {
        case full
        case compactMenu
    }

    @ObservedObject var notificationStore: TerminalNotificationStore
    @ObservedObject var viewModel: TitlebarControlsViewModel
    let onToggleSidebar: () -> Void
    let onToggleNotifications: () -> Void
    let onOpenFolder: () -> Void
    let onNewWindow: () -> Void
    let onNewWorkspace: () -> Void
    let onOpenRemoteExplorer: () -> Void
    let visibilityMode: TitlebarControlsVisibilityMode
    let layoutMode: LayoutMode
    @AppStorage("titlebarControlsStyle") private var styleRawValue = TitlebarControlsStyle.classic.rawValue
    @AppStorage(ShortcutHintDebugSettings.titlebarHintXKey) private var titlebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultTitlebarHintX
    @AppStorage(ShortcutHintDebugSettings.titlebarHintYKey) private var titlebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultTitlebarHintY
    @AppStorage(ShortcutHintDebugSettings.alwaysShowHintsKey) private var alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
    @State private var shortcutRefreshTick = 0
    @State private var isHoveringControls = false
    @State private var isNotificationsPopoverShown = false
    @StateObject private var modifierKeyMonitor = TitlebarShortcutHintModifierMonitor()
    private let titlebarHintRightSafetyShift: CGFloat = 10
    private let titlebarHintBaseXShift: CGFloat = -10

    private enum HintSlot: Int, CaseIterable {
        case toggleSidebar
        case showNotifications
        case openFolder

        var action: KeyboardShortcutSettings.Action {
            switch self {
            case .toggleSidebar:
                return .toggleSidebar
            case .showNotifications:
                return .showNotifications
            case .openFolder:
                return .openFolder
            }
        }
    }

    private struct TitlebarHintLayoutItem: Identifiable {
        let action: KeyboardShortcutSettings.Action
        let shortcut: StoredShortcut
        let width: CGFloat
        let leftEdge: CGFloat

        var id: String { action.rawValue }
    }

    private var shouldShowTitlebarShortcutHints: Bool {
        guard layoutMode == .full else { return false }
        return alwaysShowShortcutHints || modifierKeyMonitor.isModifierPressed
    }

    private var shouldShowControls: Bool {
        if visibilityMode == .alwaysVisible {
            return true
        }
        return isHoveringControls || isNotificationsPopoverShown || shouldShowTitlebarShortcutHints
    }

    var body: some View {
        // Force the `.safeHelp(...)` tooltips to re-evaluate when shortcuts are changed in settings.
        // (The titlebar controls don't otherwise re-render on UserDefaults changes.)
        let _ = shortcutRefreshTick
        let style = TitlebarControlsStyle(rawValue: styleRawValue) ?? .classic
        let config = style.config
        controlsGroup(config: config)
            .padding(.leading, 4)
            .padding(.trailing, titlebarHintTrailingInset)
            .contentShape(Rectangle())
            .opacity(shouldShowControls ? 1 : 0)
            .allowsHitTesting(shouldShowControls)
            .animation(.easeInOut(duration: 0.14), value: shouldShowControls)
            .background(
                WindowAccessor { window in
                    modifierKeyMonitor.setHostWindow(window)
                }
                .frame(width: 0, height: 0)
            )
            .onHover { hovering in
                isHoveringControls = hovering
            }
            .onReceive(NotificationCenter.default.publisher(for: KeyboardShortcutSettings.didChangeNotification)) { _ in
                shortcutRefreshTick &+= 1
            }
            .onAppear {
                isNotificationsPopoverShown = AppDelegate.shared?.isNotificationsPopoverShown() ?? false
            }
            .onReceive(NotificationCenter.default.publisher(for: .cmuxNotificationsPopoverVisibilityDidChange)) { notification in
                isNotificationsPopoverShown = (notification.userInfo?[NotificationsPopoverVisibilityUserInfoKey.isShown] as? Bool) ?? false
            }
            .onAppear {
                modifierKeyMonitor.start()
            }
            .onDisappear {
                modifierKeyMonitor.stop()
            }
    }

    private var titlebarHintTrailingInset: CGFloat {
        // Keep room for blur + shadow so the rightmost hint never clips.
        max(0, ShortcutHintDebugSettings.clamped(titlebarShortcutHintXOffset)) + titlebarHintRightSafetyShift + 8
    }

    private func titlebarHintVerticalBaseOffset(for config: TitlebarControlsStyleConfig) -> CGFloat {
        titlebarShortcutHintVerticalOffset(for: config)
    }

    @ViewBuilder
    private func controlsGroup(config: TitlebarControlsStyleConfig) -> some View {
        let hintLayoutItems = titlebarHintLayoutItems(config: config)
        let content = HStack(spacing: config.spacing) {
            if layoutMode == .full {
                TitlebarControlButton(config: config, action: {
                    #if DEBUG
                    dlog("titlebar.toggleSidebar")
                    #endif
                    onToggleSidebar()
                }) {
                    iconLabel(systemName: "sidebar.left", config: config)
                }
                .accessibilityIdentifier("titlebarControl.toggleSidebar")
                .accessibilityLabel(String(localized: "titlebar.sidebar.accessibilityLabel", defaultValue: "Toggle Sidebar"))
                .safeHelp(KeyboardShortcutSettings.Action.toggleSidebar.tooltip(String(localized: "titlebar.sidebar.tooltip", defaultValue: "Show or hide the sidebar")))

                TitlebarControlButton(config: config, action: {
                    #if DEBUG
                    dlog("titlebar.notifications")
                    #endif
                    onToggleNotifications()
                }) {
                    ZStack(alignment: .topTrailing) {
                        iconLabel(systemName: "bell", config: config)

                        if notificationStore.unreadCount > 0 {
                            Text("\(min(notificationStore.unreadCount, 99))")
                                .font(.system(size: max(8, config.badgeSize - 5), weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: config.badgeSize, height: config.badgeSize)
                                .background(
                                    Circle().fill(cmuxAccentColor())
                                )
                                .offset(x: config.badgeOffset.width, y: config.badgeOffset.height)
                        }
                    }
                    .frame(width: config.buttonSize, height: config.buttonSize)
                }
                .accessibilityIdentifier("titlebarControl.showNotifications")
                .background(NotificationsAnchorView { viewModel.notificationsAnchorView = $0 })
                .accessibilityLabel(String(localized: "titlebar.notifications.accessibilityLabel", defaultValue: "Notifications"))
                .safeHelp(KeyboardShortcutSettings.Action.showNotifications.tooltip(String(localized: "titlebar.notifications.tooltip", defaultValue: "Show notifications")))
            }

            creationMenuButton(config: config)
        }

        let paddedContent = content.padding(config.groupPadding)

        if config.groupBackground {
            paddedContent
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.72))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.28), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    titlebarShortcutHintOverlay(items: hintLayoutItems, config: config)
                }
        } else {
            paddedContent
                .overlay(alignment: .topLeading) {
                    titlebarShortcutHintOverlay(items: hintLayoutItems, config: config)
                }
        }
    }

    private func titlebarHintLayoutItems(config: TitlebarControlsStyleConfig) -> [TitlebarHintLayoutItem] {
        let xOffset = CGFloat(ShortcutHintDebugSettings.clamped(titlebarShortcutHintXOffset))
        let intervals = titlebarHintIntervals(config: config, xOffset: xOffset)
        guard !intervals.isEmpty else { return [] }

        // Keep all titlebar hints on the same Y lane and resolve overlaps by shifting left.
        let minimumSpacing: CGFloat = 6
        let assignedRightEdges = ShortcutHintHorizontalPlanner.assignRightEdges(
            for: intervals.map { $0.interval },
            minSpacing: minimumSpacing
        )

        var items: [TitlebarHintLayoutItem] = []
        items.reserveCapacity(intervals.count)
        for (index, item) in intervals.enumerated() {
            let rightEdge = assignedRightEdges[index]
            items.append(
                TitlebarHintLayoutItem(
                    action: item.action,
                    shortcut: item.shortcut,
                    width: item.width,
                    leftEdge: rightEdge - item.width
                )
            )
        }
        return items
    }

    private func titlebarHintIntervals(
        config: TitlebarControlsStyleConfig,
        xOffset: CGFloat
    ) -> [(action: KeyboardShortcutSettings.Action, shortcut: StoredShortcut, width: CGFloat, interval: ClosedRange<CGFloat>)] {
        guard shouldShowTitlebarShortcutHints else { return [] }

        return HintSlot.allCases.compactMap { slot in
            let shortcut = KeyboardShortcutSettings.shortcut(for: slot.action)
            guard shortcut.command else { return nil }

            let width = titlebarHintWidth(for: shortcut, config: config)
            let rightEdge = config.groupPadding.leading
                + titlebarButtonRightEdge(for: slot, config: config)
                + xOffset
                + titlebarHintRightSafetyShift
                + titlebarHintBaseXShift
            return (slot.action, shortcut, width, (rightEdge - width)...rightEdge)
        }
    }

    private func titlebarHintWidth(for shortcut: StoredShortcut, config: TitlebarControlsStyleConfig) -> CGFloat {
        let font = NSFont.systemFont(ofSize: max(8, config.iconSize - 4), weight: .semibold)
        let textWidth = (shortcut.displayString as NSString).size(withAttributes: [.font: font]).width
        return ceil(textWidth) + 12
    }

    private func titlebarButtonRightEdge(for slot: HintSlot, config: TitlebarControlsStyleConfig) -> CGFloat {
        let index = CGFloat(slot.rawValue)
        return (index + 1) * config.buttonSize + index * config.spacing
    }

    @ViewBuilder
    private func titlebarShortcutHintOverlay(
        items: [TitlebarHintLayoutItem],
        config: TitlebarControlsStyleConfig
    ) -> some View {
        let yOffset = config.groupPadding.top
            + titlebarHintVerticalBaseOffset(for: config)
            + ShortcutHintDebugSettings.clamped(titlebarShortcutHintYOffset)

        ZStack(alignment: .topLeading) {
            ForEach(items) { item in
                titlebarShortcutHintPill(shortcut: item.shortcut, config: config)
                    .accessibilityIdentifier("titlebarShortcutHint.\(item.action.rawValue)")
                    .frame(width: item.width, alignment: .leading)
                    .offset(x: item.leftEdge, y: yOffset)
            }
        }
        .animation(.easeInOut(duration: 0.14), value: shouldShowTitlebarShortcutHints)
        .transition(.opacity)
        .allowsHitTesting(false)
    }

    private func titlebarShortcutHintPill(
        shortcut: StoredShortcut,
        config: TitlebarControlsStyleConfig
    ) -> some View {
        Text(shortcut.displayString)
            .font(.system(size: max(8, config.iconSize - 5), weight: .semibold, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundColor(.primary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(minHeight: titlebarShortcutHintHeight(for: config))
            .background(ShortcutHintPillBackground())
    }

    @ViewBuilder
    private func iconLabel(systemName: String, config: TitlebarControlsStyleConfig) -> some View {
        let icon = Image(systemName: systemName)
            .font(.system(size: config.iconSize, weight: .semibold))
            .frame(width: config.buttonSize, height: config.buttonSize)

        if config.buttonBackground {
            icon
                .background(
                    RoundedRectangle(cornerRadius: config.buttonCornerRadius)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.7))
                )
        } else {
            icon
        }
    }

    @ViewBuilder
    private func creationMenuButton(config: TitlebarControlsStyleConfig) -> some View {
        Menu {
            Button(String(localized: "menu.file.openFolder", defaultValue: "Open Folder…")) {
                #if DEBUG
                dlog("titlebar.openFolder")
                #endif
                onOpenFolder()
            }

            Button(String(localized: "menu.file.newWindow", defaultValue: "New Window")) {
                #if DEBUG
                dlog("titlebar.newWindow")
                #endif
                onNewWindow()
            }

            Button(String(localized: "menu.file.newWorkspace", defaultValue: "New Workspace")) {
                #if DEBUG
                dlog("titlebar.newWorkspace")
                #endif
                onNewWorkspace()
            }

            Divider()

            Button(String(localized: "sidebar.remote.title", defaultValue: "Remote Explorer")) {
                #if DEBUG
                dlog("titlebar.remoteExplorer")
                #endif
                onOpenRemoteExplorer()
            }
        } label: {
            iconLabel(systemName: "plus", config: config)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityIdentifier("titlebarControl.createMenu")
        .accessibilityLabel(String(localized: "titlebar.createMenu.accessibilityLabel", defaultValue: "Open creation menu"))
        .safeHelp(KeyboardShortcutSettings.Action.openFolder.tooltip(String(localized: "titlebar.createMenu.tooltip", defaultValue: "Open folder, create workspace, or connect remote")))
    }
}

struct HiddenTitlebarSidebarControlsView: View {
    @ObservedObject var notificationStore: TerminalNotificationStore
    @StateObject private var viewModel = TitlebarControlsViewModel()

    private let hostWidth: CGFloat = 124
    private let hostHeight: CGFloat = 28

    var body: some View {
        TitlebarControlsView(
            notificationStore: notificationStore,
            viewModel: viewModel,
            onToggleSidebar: { _ = AppDelegate.shared?.sidebarState?.toggle() },
            onToggleNotifications: { [viewModel] in
                AppDelegate.shared?.toggleNotificationsPopover(
                    animated: true,
                    anchorView: viewModel.notificationsAnchorView
                )
            },
            onOpenFolder: { AppDelegate.shared?.openFolderFromTitlebar() },
            onNewWindow: { AppDelegate.shared?.openNewMainWindow(nil) },
            onNewWorkspace: {
                if AppDelegate.shared?.addWorkspaceInPreferredMainWindow(debugSource: "titlebar.newWorkspace") == nil {
                    AppDelegate.shared?.openNewMainWindow(nil)
                }
            },
            onOpenRemoteExplorer: { AppDelegate.shared?.openRemoteExplorerPage() },
            visibilityMode: .onHover,
            layoutMode: .full
        )
        .frame(width: hostWidth, height: hostHeight, alignment: .leading)
    }
}

enum TitlebarControlsVisibilityMode {
    case alwaysVisible
    case onHover
}

@MainActor
private final class TitlebarShortcutHintModifierMonitor: ObservableObject {
    @Published private(set) var isModifierPressed = false

    private weak var hostWindow: NSWindow?
    private var hostWindowDidBecomeKeyObserver: NSObjectProtocol?
    private var hostWindowDidResignKeyObserver: NSObjectProtocol?
    private var flagsMonitor: Any?
    private var keyDownMonitor: Any?
    private var appResignObserver: NSObjectProtocol?
    private var pendingShowWorkItem: DispatchWorkItem?

    func setHostWindow(_ window: NSWindow?) {
        guard hostWindow !== window else { return }
        removeHostWindowObservers()
        hostWindow = window
        guard let window else {
            cancelPendingHintShow(resetVisible: true)
            return
        }

        hostWindowDidBecomeKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.update(from: NSEvent.modifierFlags, eventWindow: nil)
            }
        }

        hostWindowDidResignKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.cancelPendingHintShow(resetVisible: true)
            }
        }

        update(from: NSEvent.modifierFlags, eventWindow: nil)
    }

    func start() {
        guard flagsMonitor == nil else {
            update(from: NSEvent.modifierFlags, eventWindow: nil)
            return
        }

        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.update(from: event.modifierFlags, eventWindow: event.window)
            return event
        }

        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyDown(event)
            return event
        }

        appResignObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.cancelPendingHintShow(resetVisible: true)
            }
        }

        update(from: NSEvent.modifierFlags, eventWindow: nil)
    }

    func stop() {
        if let flagsMonitor {
            NSEvent.removeMonitor(flagsMonitor)
            self.flagsMonitor = nil
        }
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
        if let appResignObserver {
            NotificationCenter.default.removeObserver(appResignObserver)
            self.appResignObserver = nil
        }
        removeHostWindowObservers()
        cancelPendingHintShow(resetVisible: true)
    }

    private func handleKeyDown(_ event: NSEvent) {
        guard isCurrentWindow(eventWindow: event.window) else { return }
        cancelPendingHintShow(resetVisible: true)
    }

    private func isCurrentWindow(eventWindow: NSWindow?) -> Bool {
        ShortcutHintModifierPolicy.isCurrentWindow(
            hostWindowNumber: hostWindow?.windowNumber,
            hostWindowIsKey: hostWindow?.isKeyWindow ?? false,
            eventWindowNumber: eventWindow?.windowNumber,
            keyWindowNumber: NSApp.keyWindow?.windowNumber
        )
    }

    private func update(from modifierFlags: NSEvent.ModifierFlags, eventWindow: NSWindow?) {
        guard ShortcutHintModifierPolicy.shouldShowHints(
            for: modifierFlags,
            hostWindowNumber: hostWindow?.windowNumber,
            hostWindowIsKey: hostWindow?.isKeyWindow ?? false,
            eventWindowNumber: eventWindow?.windowNumber,
            keyWindowNumber: NSApp.keyWindow?.windowNumber
        ) else {
            cancelPendingHintShow(resetVisible: true)
            return
        }

        queueHintShow()
    }

    private func queueHintShow() {
        guard !isModifierPressed else { return }
        guard pendingShowWorkItem == nil else { return }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.pendingShowWorkItem = nil
            guard ShortcutHintModifierPolicy.shouldShowHints(
                for: NSEvent.modifierFlags,
                hostWindowNumber: self.hostWindow?.windowNumber,
                hostWindowIsKey: self.hostWindow?.isKeyWindow ?? false,
                eventWindowNumber: nil,
                keyWindowNumber: NSApp.keyWindow?.windowNumber
            ) else { return }
            self.isModifierPressed = true
        }

        pendingShowWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + ShortcutHintModifierPolicy.intentionalHoldDelay, execute: workItem)
    }

    private func cancelPendingHintShow(resetVisible: Bool) {
        pendingShowWorkItem?.cancel()
        pendingShowWorkItem = nil
        if resetVisible {
            isModifierPressed = false
        }
    }

    private func removeHostWindowObservers() {
        if let hostWindowDidBecomeKeyObserver {
            NotificationCenter.default.removeObserver(hostWindowDidBecomeKeyObserver)
            self.hostWindowDidBecomeKeyObserver = nil
        }
        if let hostWindowDidResignKeyObserver {
            NotificationCenter.default.removeObserver(hostWindowDidResignKeyObserver)
            self.hostWindowDidResignKeyObserver = nil
        }
    }
}

struct TitlebarControlsLayoutSnapshot: Equatable {
    let contentSize: NSSize
    let containerHeight: CGFloat
    let yOffset: CGFloat
}

func titlebarControlsShouldTrackButtonHover(config: TitlebarControlsStyleConfig) -> Bool {
    config.hoverBackground
}

func titlebarControlsShouldScheduleForViewSizeChange(
    previous: NSSize,
    current: NSSize,
    tolerance: CGFloat = 0.5
) -> Bool {
    guard current.width > 0, current.height > 0 else { return false }
    guard previous.width > 0, previous.height > 0 else { return true }
    return abs(previous.width - current.width) > tolerance
        || abs(previous.height - current.height) > tolerance
}

func titlebarControlsShouldApplyLayout(
    previous: TitlebarControlsLayoutSnapshot?,
    next: TitlebarControlsLayoutSnapshot,
    tolerance: CGFloat = 0.5
) -> Bool {
    guard let previous else { return true }
    return abs(previous.contentSize.width - next.contentSize.width) > tolerance
        || abs(previous.contentSize.height - next.contentSize.height) > tolerance
        || abs(previous.containerHeight - next.containerHeight) > tolerance
        || abs(previous.yOffset - next.yOffset) > tolerance
}

final class TitlebarControlsAccessoryViewController: NSTitlebarAccessoryViewController, NSPopoverDelegate {
    private let hostingView: NonDraggableHostingView<TitlebarControlsView>
    private let containerView = NSView()
    private let notificationStore: TerminalNotificationStore
    private lazy var notificationsPopover: NSPopover = makeNotificationsPopover()
    private var pendingSizeUpdate = false
    private var fittingSizeNeedsRefresh = true
    private var cachedFittingSize: NSSize?
    private var lastObservedViewSize: NSSize = .zero
    private var lastAppliedLayoutSnapshot: TitlebarControlsLayoutSnapshot?
    private let viewModel = TitlebarControlsViewModel()
    private var userDefaultsObserver: NSObjectProtocol?
    var popoverIsShownForTesting: Bool { notificationsPopover.isShown }
    private var showsWorkspaceTitlebar: Bool { !WorkspacePresentationModeSettings.isMinimal() }

    init(notificationStore: TerminalNotificationStore) {
        self.notificationStore = notificationStore
        let toggleSidebar = { _ = AppDelegate.shared?.sidebarState?.toggle() }
        let toggleNotifications: () -> Void = { _ = AppDelegate.shared?.toggleNotificationsPopover(animated: true) }
        let openFolder: () -> Void = { AppDelegate.shared?.openFolderFromTitlebar() }
        let newWindow: () -> Void = { AppDelegate.shared?.openNewMainWindow(nil) }
        let newWorkspace = {
            if AppDelegate.shared?.addWorkspaceInPreferredMainWindow(debugSource: "titlebar.newWorkspace") == nil {
                AppDelegate.shared?.openNewMainWindow(nil)
            }
        }
        let openRemoteExplorer: () -> Void = { AppDelegate.shared?.openRemoteExplorerPage() }

        hostingView = NonDraggableHostingView(
            rootView: TitlebarControlsView(
                notificationStore: notificationStore,
                viewModel: viewModel,
                onToggleSidebar: toggleSidebar,
                onToggleNotifications: toggleNotifications,
                onOpenFolder: openFolder,
                onNewWindow: newWindow,
                onNewWorkspace: newWorkspace,
                onOpenRemoteExplorer: openRemoteExplorer,
                visibilityMode: .onHover,
                layoutMode: .compactMenu
            )
        )

        super.init(nibName: nil, bundle: nil)

        view = containerView
        containerView.translatesAutoresizingMaskIntoConstraints = true
        // Prevent the titlebar accessory from clipping button backgrounds
        // at the bottom edge (the system constrains accessory height to the
        // titlebar, which can be slightly shorter than the button frames).
        containerView.wantsLayer = true
        containerView.layer?.masksToBounds = false
        hostingView.translatesAutoresizingMaskIntoConstraints = true
        hostingView.autoresizingMask = [.width, .height]
        containerView.addSubview(hostingView)

        userDefaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyWorkspaceTitlebarVisibility()
            self?.scheduleSizeUpdate(invalidateFittingSize: true)
        }

        applyWorkspaceTitlebarVisibility()
        scheduleSizeUpdate(invalidateFittingSize: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let userDefaultsObserver {
            NotificationCenter.default.removeObserver(userDefaultsObserver)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        scheduleSizeUpdate(invalidateFittingSize: true)
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        let currentViewSize = view.bounds.size
        guard titlebarControlsShouldScheduleForViewSizeChange(
            previous: lastObservedViewSize,
            current: currentViewSize
        ) else {
            return
        }
        lastObservedViewSize = currentViewSize
        scheduleSizeUpdate(invalidateFittingSize: true)
    }

    private func scheduleSizeUpdate(invalidateFittingSize: Bool = false) {
        if invalidateFittingSize {
            fittingSizeNeedsRefresh = true
        }
        guard !pendingSizeUpdate else { return }
        pendingSizeUpdate = true
        DispatchQueue.main.async { [weak self] in
            self?.pendingSizeUpdate = false
            self?.updateSize()
        }
    }

    private func updateSize() {
        applyWorkspaceTitlebarVisibility()
        guard showsWorkspaceTitlebar else { return }
        let contentSize: NSSize
        if fittingSizeNeedsRefresh || cachedFittingSize == nil {
            hostingView.invalidateIntrinsicContentSize()
            hostingView.layoutSubtreeIfNeeded()
            cachedFittingSize = hostingView.fittingSize
            fittingSizeNeedsRefresh = false
        }
        contentSize = cachedFittingSize ?? .zero

        guard contentSize.width > 0, contentSize.height > 0 else { return }
        // Use the traffic-light close button's superview height as the true
        // titlebar height. This excludes the tab bar so the icons align with
        // the traffic-light buttons (like Slack does) instead of centering in
        // the full non-content area which includes the tab strip.
        let titlebarHeight: CGFloat = {
            if let window = view.window,
               let closeButton = window.standardWindowButton(.closeButton),
               let titlebarView = closeButton.superview,
               titlebarView.frame.height > 0 {
                return titlebarView.frame.height
            }
            // Fallback: derive from the window geometry.
            return view.window.map { window in
                window.frame.height - window.contentLayoutRect.height
            } ?? contentSize.height
        }()
        let containerHeight = max(contentSize.height, titlebarHeight)
        let yOffset = max(0, (containerHeight - contentSize.height) / 2.0)
        let nextLayoutSnapshot = TitlebarControlsLayoutSnapshot(
            contentSize: contentSize,
            containerHeight: containerHeight,
            yOffset: yOffset
        )
        guard titlebarControlsShouldApplyLayout(
            previous: lastAppliedLayoutSnapshot,
            next: nextLayoutSnapshot
        ) else {
            return
        }
        lastAppliedLayoutSnapshot = nextLayoutSnapshot
        preferredContentSize = NSSize(width: contentSize.width, height: containerHeight)
        containerView.frame = NSRect(x: 0, y: 0, width: contentSize.width, height: containerHeight)
        hostingView.frame = NSRect(x: 0, y: yOffset, width: contentSize.width, height: contentSize.height)
    }

    private func applyWorkspaceTitlebarVisibility() {
        let shouldShow = showsWorkspaceTitlebar
        view.isHidden = !shouldShow
        if !shouldShow {
            preferredContentSize = .zero
            containerView.frame = .zero
            hostingView.frame = .zero
        }
    }

    func toggleNotificationsPopover(animated: Bool = true, externalAnchor: NSView? = nil) {
        if notificationsPopover.isShown {
            notificationsPopover.performClose(nil)
            return
        }
        // Recreate content view each time to avoid stale observers when popover is hidden
        let hostingController = NSHostingController(
            rootView: NotificationsPopoverView(
                notificationStore: notificationStore,
                onDismiss: { [weak notificationsPopover] in
                    notificationsPopover?.performClose(nil)
                }
            )
        )
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = .clear
        notificationsPopover.contentViewController = hostingController

        guard let window = externalAnchor?.window ?? view.window ?? hostingView.window ?? NSApp.keyWindow,
              let contentView = window.contentView else {
            return
        }

        // Force layout to ensure geometry is current.
        contentView.layoutSubtreeIfNeeded()

        // Use external anchor (e.g. fullscreen sidebar controls) if provided.
        if let externalAnchor, externalAnchor.window != nil {
            externalAnchor.superview?.layoutSubtreeIfNeeded()
            let anchorRect = externalAnchor.convert(externalAnchor.bounds, to: contentView)
            if !anchorRect.isEmpty {
                notificationsPopover.animates = animated
                notificationsPopover.show(relativeTo: anchorRect, of: contentView, preferredEdge: .maxY)
                postNotificationsPopoverVisibilityDidChange(isShown: true)
                return
            }
        }

        if let anchorView = viewModel.notificationsAnchorView, anchorView.window != nil, !isHidden {
            anchorView.superview?.layoutSubtreeIfNeeded()
            let anchorRect = anchorView.convert(anchorView.bounds, to: contentView)
            if !anchorRect.isEmpty {
                notificationsPopover.animates = animated
                notificationsPopover.show(relativeTo: anchorRect, of: contentView, preferredEdge: .maxY)
                postNotificationsPopoverVisibilityDidChange(isShown: true)
                return
            }
        }

        // Fallback: position near top-left of the window content.
        let bounds = contentView.bounds
        let anchorRect = NSRect(x: 12, y: bounds.maxY - 8, width: 1, height: 1)
        notificationsPopover.animates = animated
        notificationsPopover.show(relativeTo: anchorRect, of: contentView, preferredEdge: .maxY)
        postNotificationsPopoverVisibilityDidChange(isShown: true)
    }

    func dismissNotificationsPopover() {
        if notificationsPopover.isShown {
            notificationsPopover.performClose(nil)
        }
    }

    private func makeNotificationsPopover() -> NSPopover {
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.animates = true
        popover.delegate = self
        // Content view controller is set dynamically in toggleNotificationsPopover
        return popover
    }

    // MARK: - NSPopoverDelegate

    func popoverDidClose(_ notification: Notification) {
        // Clear the content view controller to stop SwiftUI observers when popover is hidden
        notificationsPopover.contentViewController = nil
        postNotificationsPopoverVisibilityDidChange(isShown: false)
    }
}

private struct NotificationsPopoverView: View {
    @ObservedObject var notificationStore: TerminalNotificationStore
    @AppStorage(KeyboardShortcutSettings.Action.jumpToUnread.defaultsKey) private var jumpToUnreadShortcutData = Data()
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            popoverHeader

            if notificationStore.notifications.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        popoverSummary

                        LazyVStack(spacing: 10) {
                            ForEach(notificationStore.notifications) { notification in
                                NotificationPopoverRow(
                                    notification: notification,
                                    tabTitle: tabTitle(for: notification.tabId),
                                    onOpen: { open(notification) },
                                    onClear: { notificationStore.remove(id: notification.id) }
                                )
                            }
                        }
                    }
                    .padding(14)
                }
                .frame(minWidth: 420, idealWidth: 460, maxWidth: 520, minHeight: 320, maxHeight: 520)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var popoverHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("通知")
                        .font(.system(size: 18, weight: .semibold))

                    Text("快速处理最新提醒，或跳回对应会话。")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 10)

                HStack(spacing: 6) {
                    Image(systemName: hasUnreadNotifications ? "bell.badge.fill" : "bell")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(hasUnreadNotifications ? cmuxAccentColor() : .secondary)
                    Text(hasUnreadNotifications ? "有未读" : "已读")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(hasUnreadNotifications ? .primary : .secondary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    jumpToUnreadButton
                    clearAllButton
                    openInboxButton
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        jumpToUnreadButton
                        clearAllButton
                    }
                    openInboxButton
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(
            Rectangle()
                .fill(Color(nsColor: .windowBackgroundColor))
                .overlay(alignment: .bottom) {
                    Divider()
                }
        )
    }

    private var popoverSummary: some View {
        HStack(spacing: 10) {
            PopoverSummaryCard(title: "总数", value: "\(notificationStore.notifications.count)")
            PopoverSummaryCard(title: "未读", value: "\(unreadCount)")
            PopoverSummaryCard(title: "最新", value: latestTimeText)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 12)

            Image(systemName: "bell.slash")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.secondary)

            Text("暂时没有通知")
                .font(.system(size: 17, weight: .semibold))

            Text("新的桌面通知会出现在这里。")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                openInboxButton
                jumpToUnreadButton
            }

            Spacer(minLength: 12)
        }
        .frame(minWidth: 380, idealWidth: 420, maxWidth: 480, minHeight: 210)
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    private func tabTitle(for tabId: UUID) -> String? {
        AppDelegate.shared?.tabTitle(for: tabId)
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

    private var latestTimeText: String {
        guard let latest = notificationStore.notifications.first else { return "--" }
        return latest.createdAt.formatted(date: .omitted, time: .shortened)
    }

    private func decodeShortcut(from data: Data, fallback: StoredShortcut) -> StoredShortcut {
        guard !data.isEmpty,
              let shortcut = try? JSONDecoder().decode(StoredShortcut.self, from: data) else {
            return fallback
        }
        return shortcut
    }

    private func jumpToLatestUnread() {
        DispatchQueue.main.async {
            AppDelegate.shared?.jumpToLatestUnread()
            onDismiss()
        }
    }

    private var jumpToUnreadButton: some View {
        Button(action: jumpToLatestUnread) {
            HStack(spacing: 6) {
                Label("跳到未读", systemImage: "arrow.turn.down.right")
                Text(jumpToUnreadShortcut.displayString)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                    )
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        .accessibilityIdentifier("notificationsPopover.jumpToLatest")
        .accessibilityValue(jumpToUnreadShortcut.displayString)
        .safeHelp(
            KeyboardShortcutSettings.Action.jumpToUnread.tooltip(
                String(localized: "notifications.jumpToLatest", defaultValue: "Jump to Latest")
            )
        )
        .disabled(!hasUnreadNotifications)
    }

    private var clearAllButton: some View {
        Button("全部清除") {
            notificationStore.clearAll()
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .accessibilityIdentifier("notificationsPopover.clearAll")
        .disabled(notificationStore.notifications.isEmpty)
    }

    private var openInboxButton: some View {
        Button {
            DispatchQueue.main.async {
                AppDelegate.shared?.openNotificationsPage()
                onDismiss()
            }
        } label: {
            Label("打开通知页", systemImage: "sidebar.right")
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }

    private func open(_ notification: TerminalNotification) {
        // SwiftUI action closures are not guaranteed to run on the main actor.
        // Ensure window focus + tab selection happens on the main thread.
        DispatchQueue.main.async {
            _ = AppDelegate.shared?.openNotification(
                tabId: notification.tabId,
                surfaceId: notification.surfaceId,
                notificationId: notification.id
            )
            onDismiss()
        }
    }
}

private struct NotificationPopoverRow: View {
    let notification: TerminalNotification
    let tabTitle: String?
    let onOpen: () -> Void
    let onClear: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onOpen) {
                HStack(alignment: .top, spacing: 12) {
                    unreadDot

                    VStack(alignment: .leading, spacing: 7) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(notification.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            Spacer()
                            Text(notification.createdAt.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                        }

                        if !notification.body.isEmpty {
                            Text(notification.body)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }

                        HStack(spacing: 7) {
                            if let tabTitle, !tabTitle.isEmpty {
                                metaPill(systemImage: "rectangle.stack", text: tabTitle)
                            }

                            metaPill(
                                systemImage: notification.isRead ? "checkmark.circle" : "circle.badge",
                                text: notification.isRead ? "已读" : "未读"
                            )

                            Spacer(minLength: 0)

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(isHovering ? .primary : .secondary)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("NotificationPopoverRow.\(notification.id.uuidString)")
            // XCUITest's `.click()` is not always reliable for SwiftUI `Button`s hosted in an `NSPopover`.
            // Provide an explicit accessibility action so AXPress always routes to `onOpen`.
            .accessibilityAction { onOpen() }

            Button(action: onClear) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 26, height: 26)
                    .background(
                        Circle()
                            .fill(Color.primary.opacity(isHovering ? 0.08 : 0.04))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.055) : Color(nsColor: .controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(notification.isRead ? Color.primary.opacity(0.08) : cmuxAccentColor().opacity(0.22), lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onHover { isHovering = $0 }
    }

    private var unreadDot: some View {
        Circle()
            .fill(notification.isRead ? Color.clear : cmuxAccentColor())
            .frame(width: 9, height: 9)
            .overlay(
                Circle()
                    .stroke(cmuxAccentColor().opacity(notification.isRead ? 0.24 : 1), lineWidth: 1.1)
            )
            .padding(.top, 5)
    }

    private func metaPill(systemImage: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.system(size: 10.5, weight: .medium))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule(style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

private struct PopoverSummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

@MainActor
final class UpdateTitlebarAccessoryController {
    private weak var updateViewModel: UpdateViewModel?
    private var didStart = false
    private let attachedWindows = NSHashTable<NSWindow>.weakObjects()
    private var observers: [NSObjectProtocol] = []
    private var pendingAttachRetries: [ObjectIdentifier: Int] = [:]
    private var startupScanWorkItems: [DispatchWorkItem] = []
    private let controlsIdentifier = NSUserInterfaceItemIdentifier("cmux.titlebarControls")
    private let controlsControllers = NSHashTable<TitlebarControlsAccessoryViewController>.weakObjects()

    init(viewModel: UpdateViewModel) {
        self.updateViewModel = viewModel
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func start() {
        guard !didStart else { return }
        didStart = true
        attachToExistingWindows()
        installObservers()
        scheduleStartupWindowScans()
    }

    func attach(to window: NSWindow) {
        attachIfNeeded(to: window)
    }

    private func installObservers() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: NSWindow.didBecomeMainNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let window = notification.object as? NSWindow else { return }
            Task { @MainActor [weak self] in
                self?.attachIfNeeded(to: window)
            }
        })

        observers.append(center.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let window = notification.object as? NSWindow else { return }
            Task { @MainActor [weak self] in
                self?.attachIfNeeded(to: window)
            }
        })

        // We intentionally do not rely on "window became visible" notifications here:
        // AppKit does not provide a stable cross-SDK API for this. Startup scans handle this case.
    }

    private func attachToExistingWindows() {
        for window in NSApp.windows {
            attachIfNeeded(to: window)
        }
    }

    private func scheduleStartupWindowScans() {
        // We want to be robust to SwiftUI/AppKit timing and to XCTest automation. Scanning
        // NSApp.windows briefly at startup is cheap and ensures accessories are attached even
        // if key/main/visible notifications are missed.
        let delays: [TimeInterval] = [0.05, 0.15, 0.3, 0.6, 1.0, 2.0, 3.0]
        for delay in delays {
            let item = DispatchWorkItem { [weak self] in
                Task { @MainActor [weak self] in
                    self?.attachToExistingWindows()
                }
#if DEBUG
                let env = ProcessInfo.processInfo.environment
                if env["CMUX_UI_TEST_MODE"] == "1" {
                    let ids = NSApp.windows.map { $0.identifier?.rawValue ?? "<nil>" }
                    let delayText = String(format: "%.2f", delay)
                    UpdateLogStore.shared.append("startup window scan (delay=\(delayText)) count=\(NSApp.windows.count) ids=\(ids.joined(separator: ","))")
                }
#endif
            }
            startupScanWorkItems.append(item)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
        }
    }

    private func attachIfNeeded(to window: NSWindow) {
        guard !isSettingsWindow(window) else { return }

        // Window identifiers are assigned by SwiftUI via WindowAccessor, which can run
        // after didBecomeKey/didBecomeMain notifications. Retry briefly to avoid missing
        // attaching accessories (notably in UI tests).
        if !isMainTerminalWindow(window) {
            let key = ObjectIdentifier(window)
            let attempts = pendingAttachRetries[key, default: 0]
            if attempts < 40 {
                pendingAttachRetries[key] = attempts + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self, weak window] in
                    Task { @MainActor [weak self, weak window] in
                        guard let self, let window else { return }
                        self.attachIfNeeded(to: window)
                    }
                }
            } else {
                pendingAttachRetries.removeValue(forKey: key)
            }
            return
        }

        pendingAttachRetries.removeValue(forKey: ObjectIdentifier(window))

        guard !WorkspacePresentationModeSettings.isMinimal() else {
            removeAccessoryIfPresent(from: window)
            return
        }

        guard !attachedWindows.contains(window) else { return }

        if !window.titlebarAccessoryViewControllers.contains(where: { $0.view.identifier == controlsIdentifier }) {
            let controls = TitlebarControlsAccessoryViewController(
                notificationStore: TerminalNotificationStore.shared
            )
            controls.layoutAttribute = .left
            controls.view.identifier = controlsIdentifier
            window.addTitlebarAccessoryViewController(controls)
            controlsControllers.add(controls)
        }

        attachedWindows.add(window)

#if DEBUG
        let env = ProcessInfo.processInfo.environment
        if env["CMUX_UI_TEST_MODE"] == "1" {
            let ident = window.identifier?.rawValue ?? "<nil>"
            UpdateLogStore.shared.append("attached titlebar accessories to window id=\(ident)")
        }
#endif
    }

    private func removeAccessoryIfPresent(from window: NSWindow) {
        let matchingIndices = window.titlebarAccessoryViewControllers.indices.reversed().filter { index in
            window.titlebarAccessoryViewControllers[index].view.identifier == controlsIdentifier
        }
        guard !matchingIndices.isEmpty || attachedWindows.contains(window) else { return }

        for index in matchingIndices {
            let accessory = window.titlebarAccessoryViewControllers[index]
            if let controls = accessory as? TitlebarControlsAccessoryViewController {
                controls.dismissNotificationsPopover()
            }
            window.removeTitlebarAccessoryViewController(at: index)
        }

        attachedWindows.remove(window)
        pendingAttachRetries.removeValue(forKey: ObjectIdentifier(window))
        DispatchQueue.main.async { [weak window] in
            guard let window else { return }
            window.contentView?.needsLayout = true
            window.contentView?.superview?.needsLayout = true
            window.contentView?.layoutSubtreeIfNeeded()
            window.contentView?.superview?.layoutSubtreeIfNeeded()
            window.invalidateShadow()
        }

#if DEBUG
        let env = ProcessInfo.processInfo.environment
        if env["CMUX_UI_TEST_MODE"] == "1" {
            let ident = window.identifier?.rawValue ?? "<nil>"
            UpdateLogStore.shared.append("removed titlebar accessories from window id=\(ident)")
        }
#endif
    }

    private func isSettingsWindow(_ window: NSWindow) -> Bool {
        if let raw = window.identifier?.rawValue,
           raw == "cmux.settings" || raw == "iatlas.settings" || raw == "icc.settings" {
            return true
        }
        return window.title == "Settings"
    }

    private func isMainTerminalWindow(_ window: NSWindow) -> Bool {
        guard let raw = window.identifier?.rawValue else { return false }
        return raw == "cmux.main" || raw == "iatlas.main" || raw == "icc.main" || raw.hasPrefix("cmux.main.") || raw.hasPrefix("iatlas.main.") || raw.hasPrefix("icc.main.")
    }

    private func preferredNotificationsController(
        from controllers: [TitlebarControlsAccessoryViewController],
        preferShownPopover: Bool
    ) -> TitlebarControlsAccessoryViewController? {
        if let keyWindow = NSApp.keyWindow,
           let match = controllers.first(where: { $0.view.window === keyWindow }) {
            return match
        }
        if let keyMain = NSApp.windows.first(where: { $0.isKeyWindow && isMainTerminalWindow($0) }),
           let match = controllers.first(where: { $0.view.window === keyMain }) {
            return match
        }
        if preferShownPopover,
           let shown = controllers.first(where: { $0.popoverIsShownForTesting }) {
            return shown
        }
        return controllers.first
    }

    func toggleNotificationsPopover(animated: Bool = true, anchorView: NSView? = nil) {
        let controllers = controlsControllers.allObjects
        guard !controllers.isEmpty else { return }

        // If an external anchor is provided (e.g. fullscreen sidebar controls),
        // use it for popover positioning instead of the hidden titlebar accessory.
        if let anchorView, anchorView.window != nil {
            let target = preferredNotificationsController(from: controllers, preferShownPopover: true)
            for controller in controllers where controller !== target {
                controller.dismissNotificationsPopover()
            }
            target?.toggleNotificationsPopover(animated: animated, externalAnchor: anchorView)
            return
        }

        let target = preferredNotificationsController(from: controllers, preferShownPopover: true)
        for controller in controllers {
            if controller !== target {
                controller.dismissNotificationsPopover()
            }
        }
        target?.toggleNotificationsPopover(animated: animated)
    }

    func isNotificationsPopoverShown() -> Bool {
        controlsControllers.allObjects.contains(where: { $0.popoverIsShownForTesting })
    }

    @discardableResult
    func dismissNotificationsPopoverIfShown() -> Bool {
        let controllers = controlsControllers.allObjects
        var dismissed = false
        for controller in controllers where controller.popoverIsShownForTesting {
            controller.dismissNotificationsPopover()
            dismissed = true
        }
        return dismissed
    }

    func showNotificationsPopover(animated: Bool = true) {
        let controllers = controlsControllers.allObjects
        guard !controllers.isEmpty else { return }

        let target = preferredNotificationsController(from: controllers, preferShownPopover: false)
        for controller in controllers {
            if controller !== target {
                controller.dismissNotificationsPopover()
            }
        }
        guard let target else { return }
        if target.popoverIsShownForTesting {
            return
        }
        target.toggleNotificationsPopover(animated: animated)
    }
}
