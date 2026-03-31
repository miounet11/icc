import AppKit
import SwiftUI
import Darwin
import Bonsplit
import UniformTypeIdentifiers
#if canImport(Security)
import Security
#endif

enum WorkspaceTitlebarSettings {
    static let showTitlebarKey = "workspaceTitlebarVisible"
    static let defaultShowTitlebar = true

    static func isVisible(defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: showTitlebarKey) == nil {
            return defaultShowTitlebar
        }
        return defaults.bool(forKey: showTitlebarKey)
    }
}

enum WorkspacePresentationModeSettings {
    static let modeKey = "workspacePresentationMode"

    enum Mode: String {
        case standard
        case minimal
    }

    static let defaultMode: Mode = .standard

    static func mode(for rawValue: String?) -> Mode {
        Mode(rawValue: rawValue ?? "") ?? defaultMode
    }

    static func mode(defaults: UserDefaults = .standard) -> Mode {
        mode(for: defaults.string(forKey: modeKey))
    }

    static func isMinimal(defaults: UserDefaults = .standard) -> Bool {
        mode(defaults: defaults) == .minimal
    }
}

enum WorkspaceButtonFadeSettings {
    static let modeKey = "workspaceButtonsFadeMode"
    static let legacyTitlebarControlsVisibilityModeKey = "titlebarControlsVisibilityMode"
    static let legacyPaneTabBarControlsVisibilityModeKey = "paneTabBarControlsVisibilityMode"

    enum Mode: String {
        case enabled
        case disabled
    }

    static let defaultMode: Mode = .disabled

    static func mode(for rawValue: String?) -> Mode {
        Mode(rawValue: rawValue ?? "") ?? defaultMode
    }

    static func isEnabled(defaults: UserDefaults = .standard) -> Bool {
        mode(for: defaults.string(forKey: modeKey)) == .enabled
    }

    static func initializeStoredModeIfNeeded(defaults: UserDefaults = .standard) {
        guard defaults.string(forKey: modeKey) == nil else { return }

        if let migratedMode = migratedLegacyMode(defaults: defaults) {
            defaults.set(migratedMode.rawValue, forKey: modeKey)
            return
        }

        let initialMode: Mode = WorkspaceTitlebarSettings.isVisible(defaults: defaults) ? .disabled : .enabled
        defaults.set(initialMode.rawValue, forKey: modeKey)
    }

    private static func migratedLegacyMode(defaults: UserDefaults) -> Mode? {
        let legacyValues = [
            defaults.string(forKey: legacyTitlebarControlsVisibilityModeKey),
            defaults.string(forKey: legacyPaneTabBarControlsVisibilityModeKey),
        ]

        if legacyValues.contains(where: { $0 == "onHover" || $0 == "hover" || $0 == "enabled" }) {
            return .enabled
        }
        if legacyValues.contains(where: { $0 == "always" || $0 == "disabled" }) {
            return .disabled
        }
        return nil
    }
}

enum PaneFirstClickFocusSettings {
    static let enabledKey = "paneFirstClickFocus.enabled"
    static let defaultEnabled = false

    static func isEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: enabledKey) as? Bool ?? defaultEnabled
    }
}

enum UITestLaunchManifest {
    static let argumentName = "-iccUITestLaunchManifest"

    struct Payload: Decodable {
        let environment: [String: String]
    }

    static func applyIfPresent(
        arguments: [String] = CommandLine.arguments,
        loadData: (String) -> Data? = { path in
            try? Data(contentsOf: URL(fileURLWithPath: path))
        },
        applyEnvironment: (String, String) -> Void = { key, value in
            setenv(key, value, 1)
        }
    ) {
        guard let path = manifestPath(from: arguments),
              let data = loadData(path),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            return
        }

        for (key, value) in payload.environment {
            applyEnvironment(key, value)
        }
    }

    static func manifestPath(from arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: argumentName) else { return nil }
        let valueIndex = arguments.index(after: index)
        guard valueIndex < arguments.endIndex else { return nil }

        let rawPath = arguments[valueIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        return rawPath.isEmpty ? nil : rawPath
    }
}

@main
struct iccApp: App {
    @StateObject private var tabManager: TabManager
    @StateObject private var notificationStore = TerminalNotificationStore.shared
    @StateObject private var sidebarState = SidebarState()
    @StateObject private var sidebarSelectionState = SidebarSelectionState()
    private let primaryWindowId = UUID()
    @AppStorage(AppearanceSettings.appearanceModeKey) private var appearanceMode = AppearanceSettings.defaultMode.rawValue
    @AppStorage("titlebarControlsStyle") private var titlebarControlsStyle = TitlebarControlsStyle.classic.rawValue
    @AppStorage(ShortcutHintDebugSettings.alwaysShowHintsKey) private var alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
    @AppStorage(DevBuildBannerDebugSettings.sidebarBannerVisibleKey)
    private var showSidebarDevBuildBanner = DevBuildBannerDebugSettings.defaultShowSidebarBanner
    @AppStorage(SocketControlSettings.appStorageKey) private var socketControlMode = SocketControlSettings.defaultMode.rawValue
    @AppStorage(KeyboardShortcutSettings.Action.toggleSidebar.defaultsKey) private var toggleSidebarShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.newTab.defaultsKey) private var newWorkspaceShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.newWindow.defaultsKey) private var newWindowShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.showNotifications.defaultsKey) private var showNotificationsShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.jumpToUnread.defaultsKey) private var jumpToUnreadShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.nextSurface.defaultsKey) private var nextSurfaceShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.prevSurface.defaultsKey) private var prevSurfaceShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.nextSidebarTab.defaultsKey) private var nextWorkspaceShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.prevSidebarTab.defaultsKey) private var prevWorkspaceShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.selectWorkspaceByNumber.defaultsKey) private var selectWorkspaceByNumberShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.splitRight.defaultsKey) private var splitRightShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.splitDown.defaultsKey) private var splitDownShortcutData = Data()
    @AppStorage(BrowserToolbarAccessorySpacingDebugSettings.key) private var browserToolbarAccessorySpacingRaw = BrowserToolbarAccessorySpacingDebugSettings.defaultSpacing
    @AppStorage(KeyboardShortcutSettings.Action.toggleBrowserDeveloperTools.defaultsKey)
    private var toggleBrowserDeveloperToolsShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.showBrowserJavaScriptConsole.defaultsKey)
    private var showBrowserJavaScriptConsoleShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.splitBrowserRight.defaultsKey) private var splitBrowserRightShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.splitBrowserDown.defaultsKey) private var splitBrowserDownShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.renameWorkspace.defaultsKey) private var renameWorkspaceShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.openFolder.defaultsKey) private var openFolderShortcutData = Data()
    @AppStorage(KeyboardShortcutSettings.Action.closeWorkspace.defaultsKey) private var closeWorkspaceShortcutData = Data()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private var browserToolbarAccessorySpacing: Int {
        BrowserToolbarAccessorySpacingDebugSettings.resolved(browserToolbarAccessorySpacingRaw)
    }

    init() {
        UITestLaunchManifest.applyIfPresent()

        if SocketControlSettings.shouldBlockUntaggedDebugLaunch() {
            Self.terminateForMissingLaunchTag()
        }

        Self.configureGhosttyEnvironment()

        // Apply saved language preference before any UI loads
        LanguageSettings.apply(LanguageSettings.languageAtLaunch)

        let startupAppearance = AppearanceSettings.resolvedMode()
        Self.applyAppearance(startupAppearance)
        _tabManager = StateObject(wrappedValue: TabManager())
        // Migrate legacy and old-format socket mode values to the new enum.
        let defaults = UserDefaults.standard
        if let stored = defaults.string(forKey: SocketControlSettings.appStorageKey) {
            let migrated = SocketControlSettings.migrateMode(stored)
            if migrated.rawValue != stored {
                defaults.set(migrated.rawValue, forKey: SocketControlSettings.appStorageKey)
            }
        } else if let legacy = defaults.object(forKey: SocketControlSettings.legacyEnabledKey) as? Bool {
            defaults.set(legacy ? SocketControlMode.iccOnly.rawValue : SocketControlMode.off.rawValue,
                         forKey: SocketControlSettings.appStorageKey)
        }
        // Skip keychain migration for DEV/staging builds. Each tagged build gets a
        // unique bundle ID with its own UserDefaults domain, so migration would run
        // on every launch and trigger a macOS keychain access prompt (the legacy
        // keychain item was created by a differently-signed app).
        let bundleID = Bundle.main.bundleIdentifier
        if !SocketControlSettings.isDebugLikeBundleIdentifier(bundleID)
            && !SocketControlSettings.isStagingBundleIdentifier(bundleID) {
            SocketControlPasswordStore.migrateLegacyKeychainPasswordIfNeeded(defaults: defaults)
        }
        migrateSidebarAppearanceDefaultsIfNeeded(defaults: defaults)

        // UI tests depend on AppDelegate wiring happening even if SwiftUI view appearance
        // callbacks (e.g. `.onAppear`) are delayed or skipped.
        appDelegate.configure(tabManager: tabManager, notificationStore: notificationStore, sidebarState: sidebarState)
    }

    private static func terminateForMissingLaunchTag() -> Never {
        let message = "error: refusing to launch untagged iatlas DEV; start with ./scripts/reload.sh --tag <name> (or set ICC_TAG for test harnesses)"
        fputs("\(message)\n", stderr)
        fflush(stderr)
        NSLog("%@", message)
        Darwin.exit(64)
    }

    private static func configureGhosttyEnvironment() {
        let fileManager = FileManager.default
        let ghosttyAppResources = "/Applications/Ghostty.app/Contents/Resources/ghostty"
        let bundledGhosttyURL = Bundle.main.resourceURL?.appendingPathComponent("ghostty")
        var resolvedResourcesDir: String?

        if getenv("GHOSTTY_RESOURCES_DIR") == nil {
            if let bundledGhosttyURL,
               fileManager.fileExists(atPath: bundledGhosttyURL.path),
               fileManager.fileExists(atPath: bundledGhosttyURL.appendingPathComponent("themes").path) {
                resolvedResourcesDir = bundledGhosttyURL.path
            } else if fileManager.fileExists(atPath: ghosttyAppResources) {
                resolvedResourcesDir = ghosttyAppResources
            } else if let bundledGhosttyURL, fileManager.fileExists(atPath: bundledGhosttyURL.path) {
                resolvedResourcesDir = bundledGhosttyURL.path
            }

            if let resolvedResourcesDir {
                setenv("GHOSTTY_RESOURCES_DIR", resolvedResourcesDir, 1)
            }
        }

        if getenv("TERM") == nil {
            setenv("TERM", "xterm-ghostty", 1)
        }

        if getenv("TERM_PROGRAM") == nil {
            setenv("TERM_PROGRAM", "ghostty", 1)
        }

        if let resourcesDir = getenv("GHOSTTY_RESOURCES_DIR").flatMap({ String(cString: $0) }) {
            let resourcesURL = URL(fileURLWithPath: resourcesDir)
            let resourcesParent = resourcesURL.deletingLastPathComponent()
            let dataDir = resourcesParent.path
            let manDir = resourcesParent.appendingPathComponent("man").path

            appendEnvPathIfMissing(
                "XDG_DATA_DIRS",
                path: dataDir,
                defaultValue: "/usr/local/share:/usr/share"
            )
            appendEnvPathIfMissing("MANPATH", path: manDir)
        }
    }

    private static func appendEnvPathIfMissing(_ key: String, path: String, defaultValue: String? = nil) {
        if path.isEmpty { return }
        var current = getenv(key).flatMap { String(cString: $0) } ?? ""
        if current.isEmpty, let defaultValue {
            current = defaultValue
        }
        if current.split(separator: ":").contains(Substring(path)) {
            return
        }
        let updated = current.isEmpty ? path : "\(current):\(path)"
        setenv(key, updated, 1)
    }

    private func migrateSidebarAppearanceDefaultsIfNeeded(defaults: UserDefaults) {
        let migrationKey = "sidebarAppearanceDefaultsVersion"
        let targetVersion = 1
        guard defaults.integer(forKey: migrationKey) < targetVersion else { return }

        func normalizeHex(_ value: String) -> String {
            value
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "#", with: "")
                .uppercased()
        }

        func approximatelyEqual(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.0001) -> Bool {
            abs(lhs - rhs) <= tolerance
        }

        let material = defaults.string(forKey: "sidebarMaterial") ?? SidebarMaterialOption.sidebar.rawValue
        let blendMode = defaults.string(forKey: "sidebarBlendMode") ?? SidebarBlendModeOption.behindWindow.rawValue
        let state = defaults.string(forKey: "sidebarState") ?? SidebarStateOption.followWindow.rawValue
        let tintHex = defaults.string(forKey: "sidebarTintHex") ?? "#101010"
        let tintOpacity = defaults.object(forKey: "sidebarTintOpacity") as? Double ?? 0.54
        let blurOpacity = defaults.object(forKey: "sidebarBlurOpacity") as? Double ?? 0.79
        let cornerRadius = defaults.object(forKey: "sidebarCornerRadius") as? Double ?? 0.0

        let usesLegacyDefaults =
            material == SidebarMaterialOption.sidebar.rawValue &&
            blendMode == SidebarBlendModeOption.behindWindow.rawValue &&
            state == SidebarStateOption.followWindow.rawValue &&
            normalizeHex(tintHex) == "101010" &&
            approximatelyEqual(tintOpacity, 0.54) &&
            approximatelyEqual(blurOpacity, 0.79) &&
            approximatelyEqual(cornerRadius, 0.0)

        if usesLegacyDefaults {
            let preset = SidebarPresetOption.nativeSidebar
            defaults.set(preset.rawValue, forKey: "sidebarPreset")
            defaults.set(preset.material.rawValue, forKey: "sidebarMaterial")
            defaults.set(preset.blendMode.rawValue, forKey: "sidebarBlendMode")
            defaults.set(preset.state.rawValue, forKey: "sidebarState")
            defaults.set(preset.tintHex, forKey: "sidebarTintHex")
            defaults.set(preset.tintOpacity, forKey: "sidebarTintOpacity")
            defaults.set(preset.blurOpacity, forKey: "sidebarBlurOpacity")
            defaults.set(preset.cornerRadius, forKey: "sidebarCornerRadius")
        }

        defaults.set(targetVersion, forKey: migrationKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(updateViewModel: appDelegate.updateViewModel, windowId: primaryWindowId)
                .environmentObject(tabManager)
                .environmentObject(notificationStore)
                .environmentObject(sidebarState)
                .environmentObject(sidebarSelectionState)
                .onAppear {
#if DEBUG
                    if ProcessInfo.processInfo.environment["ICC_UI_TEST_MODE"] == "1" {
                        UpdateLogStore.shared.append("ui test: iccApp onAppear")
                    }
#endif
                    // Start the Unix socket controller for programmatic access
                    updateSocketController()
                    appDelegate.configure(tabManager: tabManager, notificationStore: notificationStore, sidebarState: sidebarState)
                    applyAppearance()
                    if ProcessInfo.processInfo.environment["ICC_UI_TEST_SHOW_SETTINGS"] == "1" {
                        DispatchQueue.main.async {
                            appDelegate.openPreferencesWindow(debugSource: "uiTestShowSettings")
                        }
                    }
                }
                .onChange(of: appearanceMode) { _ in
                    applyAppearance()
                }
                .onChange(of: socketControlMode) { _ in
                    updateSocketController()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(String(localized: "menu.app.settings", defaultValue: "Settings…")) {
                    appDelegate.openPreferencesWindow(debugSource: "menu.cmdComma")
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandGroup(replacing: .appInfo) {
                Button(String(localized: "menu.app.about", defaultValue: "About icc")) {
                    showAboutPanel()
                }
                Button(String(localized: "menu.app.ghosttySettings", defaultValue: "Ghostty Settings…")) {
                    GhosttyApp.shared.openConfigurationInTextEdit()
                }
                Button(String(localized: "menu.app.reloadConfiguration", defaultValue: "Reload Configuration")) {
                    GhosttyApp.shared.reloadConfiguration(source: "menu.reload_configuration")
                }
                .keyboardShortcut(",", modifiers: [.command, .shift])
                Divider()
                Button(String(localized: "menu.app.checkForUpdates", defaultValue: "Check for Updates…")) {
                    appDelegate.checkForUpdates(nil)
                }
                InstallUpdateMenuItem(model: appDelegate.updateViewModel)
            }

#if DEBUG
            CommandMenu("Update Pill") {
                Button("Show Update Pill") {
                    appDelegate.showUpdatePill(nil)
                }
                Button("Show Long Nightly Pill") {
                    appDelegate.showUpdatePillLongNightly(nil)
                }
                Button("Show Loading State") {
                    appDelegate.showUpdatePillLoading(nil)
                }
                Button("Hide Update Pill") {
                    appDelegate.hideUpdatePill(nil)
                }
                Button("Automatic Update Pill") {
                    appDelegate.clearUpdatePillOverride(nil)
                }
            }
#endif

            CommandMenu(String(localized: "menu.notifications.title", defaultValue: "Notifications")) {
                let snapshot = notificationMenuSnapshot

                Button(snapshot.stateHintTitle) {}
                    .disabled(true)

                if !snapshot.recentNotifications.isEmpty {
                    Divider()

                    ForEach(snapshot.recentNotifications) { notification in
                        Button(notificationMenuItemTitle(for: notification)) {
                            openNotificationFromMainMenu(notification)
                        }
                    }

                    Divider()
                }

                splitCommandButton(title: String(localized: "menu.notifications.show", defaultValue: "Show Notifications"), shortcut: showNotificationsMenuShortcut) {
                    showNotificationsPopover()
                }

                splitCommandButton(title: String(localized: "menu.notifications.jumpToUnread", defaultValue: "Jump to Latest Unread"), shortcut: jumpToUnreadMenuShortcut) {
                    appDelegate.jumpToLatestUnread()
                }
                .disabled(!snapshot.hasUnreadNotifications)

                Button(String(localized: "menu.notifications.markAllRead", defaultValue: "Mark All Read")) {
                    notificationStore.markAllRead()
                }
                .disabled(!snapshot.hasUnreadNotifications)

                Button(String(localized: "menu.notifications.clearAll", defaultValue: "Clear All")) {
                    notificationStore.clearAll()
                }
                .disabled(!snapshot.hasNotifications)
            }

#if DEBUG
            CommandMenu("Debug") {
                Button("New Tab With Lorem Search Text") {
                    appDelegate.openDebugLoremTab(nil)
                }

                Button("New Tab With Large Scrollback") {
                    appDelegate.openDebugScrollbackTab(nil)
                }

                Button("Open Workspaces for All Workspace Colors") {
                    appDelegate.openDebugColorComparisonWorkspaces(nil)
                }

                Button(
                    String(
                        localized: "debug.menu.openStressWorkspacesWithLoadedSurfaces",
                        defaultValue: "Open Stress Workspaces and Load All Terminals"
                    )
                ) {
                    appDelegate.openDebugStressWorkspacesWithLoadedSurfaces(nil)
                }

                Divider()
                Menu("Debug Windows") {
                    Button("Debug Window Controls…") {
                        DebugWindowControlsWindowController.shared.show()
                    }

                    Button("Browser Import Hint Debug…") {
                        BrowserImportHintDebugWindowController.shared.show()
                    }

                    Button(
                        String(
                            localized: "debug.menu.browserProfilePopoverDebug",
                            defaultValue: "Browser Profile Popover Debug…"
                        )
                    ) {
                        BrowserProfilePopoverDebugWindowController.shared.show()
                    }

                    Button("Settings/About Titlebar Debug…") {
                        SettingsAboutTitlebarDebugWindowController.shared.show()
                    }

                    Divider()
                    Button("Sidebar Debug…") {
                        SidebarDebugWindowController.shared.show()
                    }

                    Button("Background Debug…") {
                        BackgroundDebugWindowController.shared.show()
                    }

                    Button("Menu Bar Extra Debug…") {
                        MenuBarExtraDebugWindowController.shared.show()
                    }

                    Divider()

                    Button("Open All Debug Windows") {
                        openAllDebugWindows()
                    }
                }

                Menu(
                    String(
                        localized: "debug.menu.browserToolbarButtonSpacing",
                        defaultValue: "Browser Toolbar Button Spacing"
                    )
                ) {
                    ForEach(BrowserToolbarAccessorySpacingDebugSettings.supportedValues, id: \.self) { spacing in
                        Button {
                            browserToolbarAccessorySpacingRaw = spacing
                        } label: {
                            if browserToolbarAccessorySpacing == spacing {
                                Label {
                                    Text(verbatim: "\(spacing)")
                                } icon: {
                                    Image(systemName: "checkmark")
                                }
                            } else {
                                Text(verbatim: "\(spacing)")
                            }
                        }
                    }
                }

                Toggle("Always Show Shortcut Hints", isOn: $alwaysShowShortcutHints)
                Toggle(
                    String(localized: "debug.devBuildBanner.show", defaultValue: "Show Dev Build Banner"),
                    isOn: $showSidebarDevBuildBanner
                )

                Divider()

                Picker("Titlebar Controls Style", selection: $titlebarControlsStyle) {
                    ForEach(TitlebarControlsStyle.allCases) { style in
                        Text(style.menuTitle).tag(style.rawValue)
                    }
                }

                Divider()

                Button(String(localized: "menu.updateLogs.copyUpdateLogs", defaultValue: "Copy Update Logs")) {
                    appDelegate.copyUpdateLogs(nil)
                }
                Button(String(localized: "menu.updateLogs.copyFocusLogs", defaultValue: "Copy Focus Logs")) {
                    appDelegate.copyFocusLogs(nil)
                }

                Divider()

                Button("Trigger Sentry Test Crash") {
                    appDelegate.triggerSentryTestCrash(nil)
                }
            }
#endif

            // New tab commands
            CommandGroup(replacing: .newItem) {
                splitCommandButton(title: String(localized: "menu.file.newWindow", defaultValue: "New Window"), shortcut: newWindowMenuShortcut) {
                    appDelegate.openNewMainWindow(nil)
                }

                splitCommandButton(title: String(localized: "menu.file.newWorkspace", defaultValue: "New Workspace"), shortcut: newWorkspaceMenuShortcut) {
                    if let appDelegate = AppDelegate.shared {
                        if appDelegate.addWorkspaceInPreferredMainWindow(debugSource: "menu.newWorkspace") == nil {
#if DEBUG
                            FocusLogStore.shared.append(
                                "cmdn.route phase=fallback_new_window src=menu.newWorkspace reason=workspace_creation_returned_nil"
                            )
#endif
                            appDelegate.openNewMainWindow(nil)
                        }
                    } else {
                        activeTabManager.addTab()
                    }
                }

                splitCommandButton(title: String(localized: "menu.file.openFolder", defaultValue: "Open Folder…"), shortcut: openFolderMenuShortcut) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.title = String(localized: "menu.file.openFolder.panelTitle", defaultValue: "Open Folder")
                    panel.prompt = String(localized: "menu.file.openFolder.panelPrompt", defaultValue: "Open")
                    if panel.runModal() == .OK, let url = panel.url {
                        if let appDelegate = AppDelegate.shared {
                            if appDelegate.addWorkspaceInPreferredMainWindow(
                                workingDirectory: url.path,
                                debugSource: "menu.openFolder"
                            ) == nil {
                                appDelegate.openNewMainWindow(nil)
                            }
                        } else {
                            activeTabManager.addWorkspace(workingDirectory: url.path)
                        }
                    }
                }
            }

            // Close tab/workspace
            CommandGroup(after: .newItem) {
                Button(String(localized: "menu.file.goToWorkspace", defaultValue: "Go to Workspace…")) {
                    let targetWindow = NSApp.keyWindow ?? NSApp.mainWindow
                    NotificationCenter.default.post(name: .commandPaletteSwitcherRequested, object: targetWindow)
                }
                .keyboardShortcut("p", modifiers: [.command])

                Button(String(localized: "menu.file.commandPalette", defaultValue: "Command Palette…")) {
                    let targetWindow = NSApp.keyWindow ?? NSApp.mainWindow
                    NotificationCenter.default.post(name: .commandPaletteRequested, object: targetWindow)
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])

                Divider()

                // Terminal semantics:
                // Cmd+W closes the focused tab/surface (with confirmation if needed). By
                // default, closing the last surface also closes the workspace and the window
                // if it was also the last workspace. Users can opt into keeping the workspace
                // open instead.
                Button(String(localized: "menu.file.closeTab", defaultValue: "Close Tab")) {
                    closePanelOrWindow()
                }
                .keyboardShortcut("w", modifiers: .command)

                Button(String(localized: "menu.file.closeOtherTabs", defaultValue: "Close Other Tabs in Pane")) {
                    closeOtherTabsInFocusedPane()
                }
                .keyboardShortcut("t", modifiers: [.command, .option])
                .disabled(!activeTabManager.canCloseOtherTabsInFocusedPane())

                // Cmd+Shift+W closes the current workspace (with confirmation if needed). If this
                // is the last workspace, it closes the window.
                splitCommandButton(title: String(localized: "menu.file.closeWorkspace", defaultValue: "Close Workspace"), shortcut: closeWorkspaceMenuShortcut) {
                    closeTabOrWindow()
                }

                Menu(String(localized: "commandPalette.switcher.workspaceLabel", defaultValue: "Workspace")) {
                    workspaceCommandMenuContent(manager: activeTabManager)
                }

                Button(String(localized: "menu.file.reopenClosedBrowserPanel", defaultValue: "Reopen Closed Browser Panel")) {
                    _ = activeTabManager.reopenMostRecentlyClosedBrowserPanel()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }

            // Find
            CommandGroup(after: .textEditing) {
                Menu(String(localized: "menu.find.title", defaultValue: "Find")) {
                    Button(String(localized: "menu.find.find", defaultValue: "Find…")) {
#if DEBUG
                        dlog("find.menu Cmd+F fired")
#endif
                        activeTabManager.startSearch()
                    }
                    .keyboardShortcut("f", modifiers: .command)

                    Button(String(localized: "menu.find.findNext", defaultValue: "Find Next")) {
                        activeTabManager.findNext()
                    }
                    .keyboardShortcut("g", modifiers: .command)

                    Button(String(localized: "menu.find.findPrevious", defaultValue: "Find Previous")) {
                        activeTabManager.findPrevious()
                    }
                    .keyboardShortcut("g", modifiers: [.command, .shift])

                    Divider()

                    Button(String(localized: "menu.find.hideFindBar", defaultValue: "Hide Find Bar")) {
                        activeTabManager.hideFind()
                    }
                    .keyboardShortcut("f", modifiers: [.command, .shift])
                    .disabled(!(activeTabManager.isFindVisible))

                    Divider()

                    Button(String(localized: "menu.find.useSelectionForFind", defaultValue: "Use Selection for Find")) {
                        activeTabManager.searchSelection()
                    }
                    .keyboardShortcut("e", modifiers: .command)
                    .disabled(!(activeTabManager.canUseSelectionForFind))
                }
            }

            // Tab navigation
            CommandGroup(after: .toolbar) {
                splitCommandButton(title: String(localized: "menu.view.toggleSidebar", defaultValue: "Toggle Sidebar"), shortcut: toggleSidebarMenuShortcut) {
                    if AppDelegate.shared?.toggleSidebarInActiveMainWindow() != true {
                        sidebarState.toggle()
                    }
                }

                Divider()

                splitCommandButton(title: String(localized: "menu.view.nextSurface", defaultValue: "Next Surface"), shortcut: nextSurfaceMenuShortcut) {
                    activeTabManager.selectNextSurface()
                }

                splitCommandButton(title: String(localized: "menu.view.previousSurface", defaultValue: "Previous Surface"), shortcut: prevSurfaceMenuShortcut) {
                    activeTabManager.selectPreviousSurface()
                }

                Button(String(localized: "menu.view.back", defaultValue: "Back")) {
                    activeTabManager.focusedBrowserPanel?.goBack()
                }
                .keyboardShortcut("[", modifiers: .command)

                Button(String(localized: "menu.view.forward", defaultValue: "Forward")) {
                    activeTabManager.focusedBrowserPanel?.goForward()
                }
                .keyboardShortcut("]", modifiers: .command)

                Button(String(localized: "menu.view.reloadPage", defaultValue: "Reload Page")) {
                    activeTabManager.focusedBrowserPanel?.reload()
                }
                .keyboardShortcut("r", modifiers: .command)

                splitCommandButton(title: String(localized: "menu.view.toggleDevTools", defaultValue: "Toggle Developer Tools"), shortcut: toggleBrowserDeveloperToolsMenuShortcut) {
                    let manager = activeTabManager
                    if !manager.toggleDeveloperToolsFocusedBrowser() {
                        NSSound.beep()
                    }
                }

                splitCommandButton(title: String(localized: "menu.view.showJSConsole", defaultValue: "Show JavaScript Console"), shortcut: showBrowserJavaScriptConsoleMenuShortcut) {
                    let manager = activeTabManager
                    if !manager.showJavaScriptConsoleFocusedBrowser() {
                        NSSound.beep()
                    }
                }

                Button(String(localized: "menu.view.zoomIn", defaultValue: "Zoom In")) {
                    _ = activeTabManager.zoomInFocusedBrowser()
                }
                .keyboardShortcut("=", modifiers: .command)

                Button(String(localized: "menu.view.zoomOut", defaultValue: "Zoom Out")) {
                    _ = activeTabManager.zoomOutFocusedBrowser()
                }
                .keyboardShortcut("-", modifiers: .command)

                Button(String(localized: "menu.view.actualSize", defaultValue: "Actual Size")) {
                    _ = activeTabManager.resetZoomFocusedBrowser()
                }
                .keyboardShortcut("0", modifiers: .command)

                Button(String(localized: "menu.view.clearBrowserHistory", defaultValue: "Clear Browser History")) {
                    BrowserHistoryStore.shared.clearHistory()
                }

                Button(String(localized: "menu.view.importFromBrowser", defaultValue: "Import Browser Data…")) {
                    // Defer modal presentation until after AppKit finishes menu tracking.
                    DispatchQueue.main.async {
                        BrowserDataImportCoordinator.shared.presentImportDialog()
                    }
                }

                splitCommandButton(title: String(localized: "menu.view.nextWorkspace", defaultValue: "Next Workspace"), shortcut: nextWorkspaceMenuShortcut) {
                    activeTabManager.selectNextTab()
                }

                splitCommandButton(title: String(localized: "menu.view.previousWorkspace", defaultValue: "Previous Workspace"), shortcut: prevWorkspaceMenuShortcut) {
                    activeTabManager.selectPreviousTab()
                }

                splitCommandButton(title: String(localized: "menu.view.renameWorkspace", defaultValue: "Rename Workspace…"), shortcut: renameWorkspaceMenuShortcut) {
                    _ = AppDelegate.shared?.requestRenameWorkspaceViaCommandPalette()
                }

                Divider()

                splitCommandButton(title: String(localized: "menu.view.splitRight", defaultValue: "Split Right"), shortcut: splitRightMenuShortcut) {
                    performSplitFromMenu(direction: .right)
                }

                splitCommandButton(title: String(localized: "menu.view.splitDown", defaultValue: "Split Down"), shortcut: splitDownMenuShortcut) {
                    performSplitFromMenu(direction: .down)
                }

                splitCommandButton(title: String(localized: "menu.view.splitBrowserRight", defaultValue: "Split Browser Right"), shortcut: splitBrowserRightMenuShortcut) {
                    performBrowserSplitFromMenu(direction: .right)
                }

                splitCommandButton(title: String(localized: "menu.view.splitBrowserDown", defaultValue: "Split Browser Down"), shortcut: splitBrowserDownMenuShortcut) {
                    performBrowserSplitFromMenu(direction: .down)
                }

                Divider()

                // Numbered workspace selection (9 = last workspace)
                ForEach(1...9, id: \.self) { number in
                    Button(String(localized: "menu.view.workspace", defaultValue: "Workspace \(number)")) {
                        let manager = activeTabManager
                        if let targetIndex = WorkspaceShortcutMapper.workspaceIndex(forDigit: number, workspaceCount: manager.tabs.count) {
                            manager.selectTab(at: targetIndex)
                        }
                    }
                    .keyboardShortcut(
                        KeyEquivalent(Character("\(number)")),
                        modifiers: selectWorkspaceByNumberMenuShortcut.eventModifiers
                    )
                }

                Divider()

                splitCommandButton(title: String(localized: "menu.view.jumpToUnread", defaultValue: "Jump to Latest Unread"), shortcut: jumpToUnreadMenuShortcut) {
                    AppDelegate.shared?.jumpToLatestUnread()
                }

                splitCommandButton(title: String(localized: "menu.view.showNotifications", defaultValue: "Show Notifications"), shortcut: showNotificationsMenuShortcut) {
                    showNotificationsPopover()
                }
            }
        }
    }

    private func showAboutPanel() {
        AboutWindowController.shared.show()
    }

    private func applyAppearance() {
        let mode = AppearanceSettings.mode(for: appearanceMode)
        if appearanceMode != mode.rawValue {
            appearanceMode = mode.rawValue
        }
        Self.applyAppearance(mode)
    }

    private static func applyAppearance(_ mode: AppearanceMode) {
        switch mode {
        case .system:
            NSApplication.shared.appearance = nil
        case .light:
            NSApplication.shared.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        case .auto:
            NSApplication.shared.appearance = nil
        }
    }

    private func updateSocketController() {
        let mode = SocketControlSettings.effectiveMode(userMode: currentSocketMode)
        if mode != .off {
            TerminalController.shared.start(
                tabManager: tabManager,
                socketPath: SocketControlSettings.socketPath(),
                accessMode: mode
            )
        } else {
            TerminalController.shared.stop()
        }
    }

    private var currentSocketMode: SocketControlMode {
        SocketControlSettings.migrateMode(socketControlMode)
    }

    private var splitRightMenuShortcut: StoredShortcut {
        decodeShortcut(from: splitRightShortcutData, fallback: KeyboardShortcutSettings.Action.splitRight.defaultShortcut)
    }

    private var toggleSidebarMenuShortcut: StoredShortcut {
        decodeShortcut(from: toggleSidebarShortcutData, fallback: KeyboardShortcutSettings.Action.toggleSidebar.defaultShortcut)
    }

    private var newWorkspaceMenuShortcut: StoredShortcut {
        decodeShortcut(from: newWorkspaceShortcutData, fallback: KeyboardShortcutSettings.Action.newTab.defaultShortcut)
    }

    private var newWindowMenuShortcut: StoredShortcut {
        decodeShortcut(from: newWindowShortcutData, fallback: KeyboardShortcutSettings.Action.newWindow.defaultShortcut)
    }

    private var openFolderMenuShortcut: StoredShortcut {
        decodeShortcut(from: openFolderShortcutData, fallback: KeyboardShortcutSettings.Action.openFolder.defaultShortcut)
    }

    private var showNotificationsMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: showNotificationsShortcutData,
            fallback: KeyboardShortcutSettings.Action.showNotifications.defaultShortcut
        )
    }

    private var jumpToUnreadMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: jumpToUnreadShortcutData,
            fallback: KeyboardShortcutSettings.Action.jumpToUnread.defaultShortcut
        )
    }

    private var nextSurfaceMenuShortcut: StoredShortcut {
        decodeShortcut(from: nextSurfaceShortcutData, fallback: KeyboardShortcutSettings.Action.nextSurface.defaultShortcut)
    }

    private var prevSurfaceMenuShortcut: StoredShortcut {
        decodeShortcut(from: prevSurfaceShortcutData, fallback: KeyboardShortcutSettings.Action.prevSurface.defaultShortcut)
    }

    private var nextWorkspaceMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: nextWorkspaceShortcutData,
            fallback: KeyboardShortcutSettings.Action.nextSidebarTab.defaultShortcut
        )
    }

    private var prevWorkspaceMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: prevWorkspaceShortcutData,
            fallback: KeyboardShortcutSettings.Action.prevSidebarTab.defaultShortcut
        )
    }

    private var selectWorkspaceByNumberMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: selectWorkspaceByNumberShortcutData,
            fallback: KeyboardShortcutSettings.Action.selectWorkspaceByNumber.defaultShortcut
        )
    }

    private var splitDownMenuShortcut: StoredShortcut {
        decodeShortcut(from: splitDownShortcutData, fallback: KeyboardShortcutSettings.Action.splitDown.defaultShortcut)
    }

    private var toggleBrowserDeveloperToolsMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: toggleBrowserDeveloperToolsShortcutData,
            fallback: KeyboardShortcutSettings.Action.toggleBrowserDeveloperTools.defaultShortcut
        )
    }

    private var showBrowserJavaScriptConsoleMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: showBrowserJavaScriptConsoleShortcutData,
            fallback: KeyboardShortcutSettings.Action.showBrowserJavaScriptConsole.defaultShortcut
        )
    }

    private var splitBrowserRightMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: splitBrowserRightShortcutData,
            fallback: KeyboardShortcutSettings.Action.splitBrowserRight.defaultShortcut
        )
    }

    private var splitBrowserDownMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: splitBrowserDownShortcutData,
            fallback: KeyboardShortcutSettings.Action.splitBrowserDown.defaultShortcut
        )
    }

    private var renameWorkspaceMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: renameWorkspaceShortcutData,
            fallback: KeyboardShortcutSettings.Action.renameWorkspace.defaultShortcut
        )
    }

    private var closeWorkspaceMenuShortcut: StoredShortcut {
        decodeShortcut(
            from: closeWorkspaceShortcutData,
            fallback: KeyboardShortcutSettings.Action.closeWorkspace.defaultShortcut
        )
    }

    private var notificationMenuSnapshot: NotificationMenuSnapshot {
        NotificationMenuSnapshotBuilder.make(notifications: notificationStore.notifications)
    }

    private var activeTabManager: TabManager {
        AppDelegate.shared?.synchronizeActiveMainWindowContext(
            preferredWindow: NSApp.keyWindow ?? NSApp.mainWindow
        ) ?? tabManager
    }

    private func decodeShortcut(from data: Data, fallback: StoredShortcut) -> StoredShortcut {
        guard !data.isEmpty,
              let shortcut = try? JSONDecoder().decode(StoredShortcut.self, from: data) else {
            return fallback
        }
        return shortcut
    }

    private func notificationMenuItemTitle(for notification: TerminalNotification) -> String {
        let tabTitle = appDelegate.tabTitle(for: notification.tabId)
        return MenuBarNotificationLineFormatter.menuTitle(notification: notification, tabTitle: tabTitle)
    }

    private func openNotificationFromMainMenu(_ notification: TerminalNotification) {
        _ = appDelegate.openNotification(
            tabId: notification.tabId,
            surfaceId: notification.surfaceId,
            notificationId: notification.id
        )
    }

    private func performSplitFromMenu(direction: SplitDirection) {
        if AppDelegate.shared?.performSplitShortcut(direction: direction) == true {
            return
        }
        tabManager.createSplit(direction: direction)
    }

    private func performBrowserSplitFromMenu(direction: SplitDirection) {
        if AppDelegate.shared?.performBrowserSplitShortcut(direction: direction) == true {
            return
        }
        _ = tabManager.createBrowserSplit(direction: direction)
    }

    private func selectedWorkspaceIndex(in manager: TabManager, workspaceId: UUID) -> Int? {
        manager.tabs.firstIndex { $0.id == workspaceId }
    }

    private func selectedWorkspaceWindowMoveTargets(in manager: TabManager) -> [AppDelegate.WindowMoveTarget] {
        let referenceWindowId = AppDelegate.shared?.windowId(for: manager)
        return AppDelegate.shared?.windowMoveTargets(referenceWindowId: referenceWindowId) ?? []
    }

    private func toggleSelectedWorkspacePinned(in manager: TabManager) {
        guard let workspace = manager.selectedWorkspace else { return }
        manager.setPinned(workspace, pinned: !workspace.isPinned)
    }

    private func clearSelectedWorkspaceCustomName(in manager: TabManager) {
        guard let workspace = manager.selectedWorkspace else { return }
        manager.clearCustomTitle(tabId: workspace.id)
    }

    private func moveSelectedWorkspace(in manager: TabManager, by delta: Int) {
        guard let workspace = manager.selectedWorkspace,
              let currentIndex = selectedWorkspaceIndex(in: manager, workspaceId: workspace.id) else { return }
        let targetIndex = currentIndex + delta
        guard targetIndex >= 0, targetIndex < manager.tabs.count else { return }
        _ = manager.reorderWorkspace(tabId: workspace.id, toIndex: targetIndex)
        manager.selectWorkspace(workspace)
    }

    private func moveSelectedWorkspaceToTop(in manager: TabManager) {
        guard let workspace = manager.selectedWorkspace else { return }
        manager.moveTabsToTop([workspace.id])
        manager.selectWorkspace(workspace)
    }

    private func moveSelectedWorkspace(in manager: TabManager, toWindow windowId: UUID) {
        guard let workspace = manager.selectedWorkspace else { return }
        _ = AppDelegate.shared?.moveWorkspaceToWindow(workspaceId: workspace.id, windowId: windowId, focus: true)
    }

    private func moveSelectedWorkspaceToNewWindow(in manager: TabManager) {
        guard let workspace = manager.selectedWorkspace else { return }
        _ = AppDelegate.shared?.moveWorkspaceToNewWindow(workspaceId: workspace.id, focus: true)
    }

    private func closeWorkspaceIds(
        _ workspaceIds: [UUID],
        in manager: TabManager,
        allowPinned: Bool
    ) {
        manager.closeWorkspacesWithConfirmation(workspaceIds, allowPinned: allowPinned)
    }

    private func closeOtherSelectedWorkspacePeers(in manager: TabManager) {
        guard let workspace = manager.selectedWorkspace else { return }
        let workspaceIds = manager.tabs.compactMap { $0.id == workspace.id ? nil : $0.id }
        closeWorkspaceIds(workspaceIds, in: manager, allowPinned: true)
    }

    private func closeSelectedWorkspacesBelow(in manager: TabManager) {
        guard let workspace = manager.selectedWorkspace,
              let anchorIndex = selectedWorkspaceIndex(in: manager, workspaceId: workspace.id) else { return }
        let workspaceIds = manager.tabs.suffix(from: anchorIndex + 1).map(\.id)
        closeWorkspaceIds(workspaceIds, in: manager, allowPinned: true)
    }

    private func closeSelectedWorkspacesAbove(in manager: TabManager) {
        guard let workspace = manager.selectedWorkspace,
              let anchorIndex = selectedWorkspaceIndex(in: manager, workspaceId: workspace.id) else { return }
        let workspaceIds = manager.tabs.prefix(upTo: anchorIndex).map(\.id)
        closeWorkspaceIds(workspaceIds, in: manager, allowPinned: true)
    }

    private func selectedWorkspaceHasUnreadNotifications(in manager: TabManager) -> Bool {
        guard let workspaceId = manager.selectedWorkspace?.id else { return false }
        return notificationStore.notifications.contains { $0.tabId == workspaceId && !$0.isRead }
    }

    private func selectedWorkspaceHasReadNotifications(in manager: TabManager) -> Bool {
        guard let workspaceId = manager.selectedWorkspace?.id else { return false }
        return notificationStore.notifications.contains { $0.tabId == workspaceId && $0.isRead }
    }

    private func markSelectedWorkspaceRead(in manager: TabManager) {
        guard let workspaceId = manager.selectedWorkspace?.id else { return }
        notificationStore.markRead(forTabId: workspaceId)
    }

    private func markSelectedWorkspaceUnread(in manager: TabManager) {
        guard let workspaceId = manager.selectedWorkspace?.id else { return }
        notificationStore.markUnread(forTabId: workspaceId)
    }

    @ViewBuilder
    private func workspaceCommandMenuContent(manager: TabManager) -> some View {
        let workspace = manager.selectedWorkspace
        let workspaceIndex = workspace.flatMap { selectedWorkspaceIndex(in: manager, workspaceId: $0.id) }
        let windowMoveTargets = selectedWorkspaceWindowMoveTargets(in: manager)

        Button(
            workspace?.isPinned == true
                ? String(localized: "contextMenu.unpinWorkspace", defaultValue: "Unpin Workspace")
                : String(localized: "contextMenu.pinWorkspace", defaultValue: "Pin Workspace")
        ) {
            toggleSelectedWorkspacePinned(in: manager)
        }
        .disabled(workspace == nil)

        Button(String(localized: "menu.view.renameWorkspace", defaultValue: "Rename Workspace…")) {
            _ = AppDelegate.shared?.requestRenameWorkspaceViaCommandPalette()
        }
        .disabled(workspace == nil)

        if workspace?.hasCustomTitle == true {
            Button(String(localized: "contextMenu.removeCustomWorkspaceName", defaultValue: "Remove Custom Workspace Name")) {
                clearSelectedWorkspaceCustomName(in: manager)
            }
        }

        Divider()

        Button(String(localized: "contextMenu.moveUp", defaultValue: "Move Up")) {
            moveSelectedWorkspace(in: manager, by: -1)
        }
        .disabled(workspaceIndex == nil || workspaceIndex == 0)

        Button(String(localized: "contextMenu.moveDown", defaultValue: "Move Down")) {
            moveSelectedWorkspace(in: manager, by: 1)
        }
        .disabled(workspaceIndex == nil || workspaceIndex == manager.tabs.count - 1)

        Button(String(localized: "contextMenu.moveToTop", defaultValue: "Move to Top")) {
            moveSelectedWorkspaceToTop(in: manager)
        }
        .disabled(workspace == nil || workspaceIndex == 0)

        Menu(String(localized: "contextMenu.moveWorkspaceToWindow", defaultValue: "Move Workspace to Window")) {
            Button(String(localized: "contextMenu.newWindow", defaultValue: "New Window")) {
                moveSelectedWorkspaceToNewWindow(in: manager)
            }
            .disabled(workspace == nil)

            if !windowMoveTargets.isEmpty {
                Divider()
            }

            ForEach(windowMoveTargets) { target in
                Button(target.label) {
                    moveSelectedWorkspace(in: manager, toWindow: target.windowId)
                }
                .disabled(target.isCurrentWindow || workspace == nil)
            }
        }
        .disabled(workspace == nil)

        Divider()

        Button(String(localized: "menu.file.closeWorkspace", defaultValue: "Close Workspace")) {
            manager.closeCurrentWorkspaceWithConfirmation()
        }
        .disabled(workspace == nil)

        Button(String(localized: "contextMenu.closeOtherWorkspaces", defaultValue: "Close Other Workspaces")) {
            closeOtherSelectedWorkspacePeers(in: manager)
        }
        .disabled(workspace == nil || manager.tabs.count <= 1)

        Button(String(localized: "contextMenu.closeWorkspacesBelow", defaultValue: "Close Workspaces Below")) {
            closeSelectedWorkspacesBelow(in: manager)
        }
        .disabled(workspaceIndex == nil || workspaceIndex == manager.tabs.count - 1)

        Button(String(localized: "contextMenu.closeWorkspacesAbove", defaultValue: "Close Workspaces Above")) {
            closeSelectedWorkspacesAbove(in: manager)
        }
        .disabled(workspaceIndex == nil || workspaceIndex == 0)

        Divider()

        Button(String(localized: "contextMenu.markWorkspaceRead", defaultValue: "Mark Workspace as Read")) {
            markSelectedWorkspaceRead(in: manager)
        }
        .disabled(!selectedWorkspaceHasUnreadNotifications(in: manager))

        Button(String(localized: "contextMenu.markWorkspaceUnread", defaultValue: "Mark Workspace as Unread")) {
            markSelectedWorkspaceUnread(in: manager)
        }
        .disabled(!selectedWorkspaceHasReadNotifications(in: manager))
    }

    @ViewBuilder
    private func splitCommandButton(title: String, shortcut: StoredShortcut, action: @escaping () -> Void) -> some View {
        if let key = shortcut.keyEquivalent {
            Button(title, action: action)
                .keyboardShortcut(key, modifiers: shortcut.eventModifiers)
        } else {
            Button(title, action: action)
        }
    }

    private func closePanelOrWindow() {
        if let window = NSApp.keyWindow ?? NSApp.mainWindow,
           iccWindowShouldOwnCloseShortcut(window) {
            window.performClose(nil)
            return
        }
        activeTabManager.closeCurrentPanelWithConfirmation()
    }

    private func closeOtherTabsInFocusedPane() {
        activeTabManager.closeOtherTabsInFocusedPaneWithConfirmation()
    }

    private func closeTabOrWindow() {
        activeTabManager.closeCurrentTabWithConfirmation()
    }

    private func showNotificationsPopover() {
        AppDelegate.shared?.toggleNotificationsPopover(animated: false)
    }

    private func openAllDebugWindows() {
        BrowserImportHintDebugWindowController.shared.show()
        BrowserProfilePopoverDebugWindowController.shared.show()
        SettingsAboutTitlebarDebugWindowController.shared.show()
        SidebarDebugWindowController.shared.show()
        BackgroundDebugWindowController.shared.show()
        MenuBarExtraDebugWindowController.shared.show()
    }
}

private let iccAuxiliaryWindowIdentifiers: Set<String> = [
    "icc.settings",
    "icc.about",
    "icc.licenses",
    "icc.browser-popup",
    "icc.settingsAboutTitlebarDebug",
    "icc.debugWindowControls",
    "icc.browserImportHintDebug",
    "icc.sidebarDebug",
    "icc.menubarDebug",
    "icc.backgroundDebug",
]

/// Returns whether the given window should handle the standard close shortcut
/// as a standalone auxiliary window instead of routing it through workspace or
/// panel-close behavior.
func iccWindowShouldOwnCloseShortcut(_ window: NSWindow?) -> Bool {
    guard let identifier = window?.identifier?.rawValue else { return false }
    return iccAuxiliaryWindowIdentifiers.contains(identifier)
}

private enum SettingsAboutWindowKind: String, CaseIterable, Identifiable {
    case settings
    case about

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .settings:
            return "Settings Window"
        case .about:
            return "About Window"
        }
    }

    var windowIdentifier: String {
        switch self {
        case .settings:
            return "icc.settings"
        case .about:
            return "icc.about"
        }
    }

    var fallbackTitle: String {
        switch self {
        case .settings:
            return "Settings"
        case .about:
            return "About icc"
        }
    }

    var minimumSize: NSSize {
        switch self {
        case .settings:
            return NSSize(width: 420, height: 360)
        case .about:
            return NSSize(width: 360, height: 520)
        }
    }
}

private enum TitlebarVisibilityOption: String, CaseIterable, Identifiable {
    case hidden
    case visible

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .hidden:
            return "Hidden"
        case .visible:
            return "Visible"
        }
    }

    var windowValue: NSWindow.TitleVisibility {
        switch self {
        case .hidden:
            return .hidden
        case .visible:
            return .visible
        }
    }
}

private enum TitlebarToolbarStyleOption: String, CaseIterable, Identifiable {
    case automatic
    case expanded
    case preference
    case unified
    case unifiedCompact

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .expanded:
            return "Expanded"
        case .preference:
            return "Preference"
        case .unified:
            return "Unified"
        case .unifiedCompact:
            return "Unified Compact"
        }
    }

    var windowValue: NSWindow.ToolbarStyle {
        switch self {
        case .automatic:
            return .automatic
        case .expanded:
            return .expanded
        case .preference:
            return .preference
        case .unified:
            return .unified
        case .unifiedCompact:
            return .unifiedCompact
        }
    }
}

private struct SettingsAboutTitlebarDebugOptions: Equatable {
    var overridesEnabled: Bool
    var windowTitle: String
    var titleVisibility: TitlebarVisibilityOption
    var titlebarAppearsTransparent: Bool
    var movableByWindowBackground: Bool
    var titled: Bool
    var closable: Bool
    var miniaturizable: Bool
    var resizable: Bool
    var fullSizeContentView: Bool
    var showToolbar: Bool
    var toolbarStyle: TitlebarToolbarStyleOption

    static func defaults(for kind: SettingsAboutWindowKind) -> SettingsAboutTitlebarDebugOptions {
        switch kind {
        case .settings:
            return SettingsAboutTitlebarDebugOptions(
                overridesEnabled: false,
                windowTitle: "Settings",
                titleVisibility: .hidden,
                titlebarAppearsTransparent: true,
                movableByWindowBackground: true,
                titled: true,
                closable: true,
                miniaturizable: true,
                resizable: true,
                fullSizeContentView: true,
                showToolbar: false,
                toolbarStyle: .unifiedCompact
            )
        case .about:
            return SettingsAboutTitlebarDebugOptions(
                overridesEnabled: false,
                windowTitle: "About icc",
                titleVisibility: .hidden,
                titlebarAppearsTransparent: true,
                movableByWindowBackground: false,
                titled: true,
                closable: true,
                miniaturizable: true,
                resizable: false,
                fullSizeContentView: false,
                showToolbar: false,
                toolbarStyle: .automatic
            )
        }
    }
}

@MainActor
private final class SettingsAboutTitlebarDebugStore: ObservableObject {
    static let shared = SettingsAboutTitlebarDebugStore()

    @Published var settingsOptions = SettingsAboutTitlebarDebugOptions.defaults(for: .settings) {
        didSet { applyToOpenWindows(for: .settings) }
    }
    @Published var aboutOptions = SettingsAboutTitlebarDebugOptions.defaults(for: .about) {
        didSet { applyToOpenWindows(for: .about) }
    }

    private init() {}

    func options(for kind: SettingsAboutWindowKind) -> SettingsAboutTitlebarDebugOptions {
        switch kind {
        case .settings:
            return settingsOptions
        case .about:
            return aboutOptions
        }
    }

    func update(_ newValue: SettingsAboutTitlebarDebugOptions, for kind: SettingsAboutWindowKind) {
        switch kind {
        case .settings:
            settingsOptions = newValue
        case .about:
            aboutOptions = newValue
        }
    }

    func reset(_ kind: SettingsAboutWindowKind) {
        update(SettingsAboutTitlebarDebugOptions.defaults(for: kind), for: kind)
    }

    func applyToOpenWindows(for kind: SettingsAboutWindowKind) {
        for window in NSApp.windows where window.identifier?.rawValue == kind.windowIdentifier {
            apply(options(for: kind), to: window, for: kind)
        }
    }

    func applyToOpenWindows() {
        applyToOpenWindows(for: .settings)
        applyToOpenWindows(for: .about)
    }

    func applyCurrentOptions(to window: NSWindow, for kind: SettingsAboutWindowKind) {
        apply(options(for: kind), to: window, for: kind)
    }

    func copyConfigToPasteboard() {
        let settings = options(for: .settings)
        let about = options(for: .about)
        let payload = """
        # Settings/About Titlebar Debug
        settings.overridesEnabled=\(settings.overridesEnabled)
        settings.title=\(settings.windowTitle)
        settings.titleVisibility=\(settings.titleVisibility.rawValue)
        settings.titlebarAppearsTransparent=\(settings.titlebarAppearsTransparent)
        settings.movableByWindowBackground=\(settings.movableByWindowBackground)
        settings.titled=\(settings.titled)
        settings.closable=\(settings.closable)
        settings.miniaturizable=\(settings.miniaturizable)
        settings.resizable=\(settings.resizable)
        settings.fullSizeContentView=\(settings.fullSizeContentView)
        settings.showToolbar=\(settings.showToolbar)
        settings.toolbarStyle=\(settings.toolbarStyle.rawValue)
        about.overridesEnabled=\(about.overridesEnabled)
        about.title=\(about.windowTitle)
        about.titleVisibility=\(about.titleVisibility.rawValue)
        about.titlebarAppearsTransparent=\(about.titlebarAppearsTransparent)
        about.movableByWindowBackground=\(about.movableByWindowBackground)
        about.titled=\(about.titled)
        about.closable=\(about.closable)
        about.miniaturizable=\(about.miniaturizable)
        about.resizable=\(about.resizable)
        about.fullSizeContentView=\(about.fullSizeContentView)
        about.showToolbar=\(about.showToolbar)
        about.toolbarStyle=\(about.toolbarStyle.rawValue)
        """
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(payload, forType: .string)
    }

    private func apply(_ options: SettingsAboutTitlebarDebugOptions, to window: NSWindow, for kind: SettingsAboutWindowKind) {
        let effective = options.overridesEnabled ? options : SettingsAboutTitlebarDebugOptions.defaults(for: kind)
        let resolvedTitle = effective.windowTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        window.title = resolvedTitle.isEmpty ? kind.fallbackTitle : resolvedTitle
        window.titleVisibility = effective.titleVisibility.windowValue
        window.titlebarAppearsTransparent = effective.titlebarAppearsTransparent
        window.isMovableByWindowBackground = effective.movableByWindowBackground
        window.toolbarStyle = effective.toolbarStyle.windowValue

        if effective.showToolbar {
            ensureToolbar(on: window, kind: kind)
        } else if window.toolbar != nil {
            window.toolbar = nil
        }

        var styleMask = window.styleMask
        setStyleMaskBit(&styleMask, .titled, enabled: effective.titled)
        setStyleMaskBit(&styleMask, .closable, enabled: effective.closable)
        setStyleMaskBit(&styleMask, .miniaturizable, enabled: effective.miniaturizable)
        setStyleMaskBit(&styleMask, .resizable, enabled: effective.resizable)
        setStyleMaskBit(&styleMask, .fullSizeContentView, enabled: effective.fullSizeContentView)
        window.styleMask = styleMask

        let maxSize = effective.resizable ? NSSize(width: 8192, height: 8192) : kind.minimumSize
        window.minSize = kind.minimumSize
        window.maxSize = maxSize
        window.contentMinSize = kind.minimumSize
        window.contentMaxSize = maxSize
        window.invalidateShadow()
        AppDelegate.shared?.applyWindowDecorations(to: window)
    }

    private func ensureToolbar(on window: NSWindow, kind: SettingsAboutWindowKind) {
        guard window.toolbar == nil else { return }
        let identifier = NSToolbar.Identifier("icc.debug.titlebar.\(kind.rawValue)")
        let toolbar = NSToolbar(identifier: identifier)
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.displayMode = .iconOnly
        toolbar.showsBaselineSeparator = false
        window.toolbar = toolbar
    }

    private func setStyleMaskBit(
        _ styleMask: inout NSWindow.StyleMask,
        _ bit: NSWindow.StyleMask,
        enabled: Bool
    ) {
        if enabled {
            styleMask.insert(bit)
        } else {
            styleMask.remove(bit)
        }
    }
}

private final class SettingsAboutTitlebarDebugWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SettingsAboutTitlebarDebugWindowController()

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 470, height: 690),
            styleMask: [.titled, .closable, .resizable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings/About Titlebar Debug"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("icc.settingsAboutTitlebarDebug")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: SettingsAboutTitlebarDebugView())
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        SettingsAboutTitlebarDebugStore.shared.applyToOpenWindows()
    }
}

private struct SettingsAboutTitlebarDebugView: View {
    @ObservedObject private var store = SettingsAboutTitlebarDebugStore.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Settings/About Titlebar Debug")
                    .font(.headline)

                editor(for: .settings)
                editor(for: .about)

                GroupBox("Actions") {
                    HStack(spacing: 10) {
                        Button("Reset All") {
                            store.reset(.settings)
                            store.reset(.about)
                        }
                        Button("Reapply to Open Windows") {
                            store.applyToOpenWindows()
                        }
                        Button("Copy Config") {
                            store.copyConfigToPasteboard()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func editor(for kind: SettingsAboutWindowKind) -> some View {
        let overridesEnabled = binding(for: kind, keyPath: \.overridesEnabled)

        return GroupBox(kind.displayTitle) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Enable Debug Overrides", isOn: overridesEnabled)

                Text("When disabled, icc uses the normal default titlebar behavior for this window.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("Window Title")
                        TextField("", text: binding(for: kind, keyPath: \.windowTitle))
                    }

                    HStack(spacing: 10) {
                        Picker("Title Visibility", selection: binding(for: kind, keyPath: \.titleVisibility)) {
                            ForEach(TitlebarVisibilityOption.allCases) { option in
                                Text(option.displayTitle).tag(option)
                            }
                        }
                        Picker("Toolbar Style", selection: binding(for: kind, keyPath: \.toolbarStyle)) {
                            ForEach(TitlebarToolbarStyleOption.allCases) { option in
                                Text(option.displayTitle).tag(option)
                            }
                        }
                    }

                    Toggle("Show Toolbar", isOn: binding(for: kind, keyPath: \.showToolbar))
                    Toggle("Transparent Titlebar", isOn: binding(for: kind, keyPath: \.titlebarAppearsTransparent))
                    Toggle("Movable by Window Background", isOn: binding(for: kind, keyPath: \.movableByWindowBackground))

                    Divider()

                    Text("Style Mask")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("Titled", isOn: binding(for: kind, keyPath: \.titled))
                    Toggle("Closable", isOn: binding(for: kind, keyPath: \.closable))
                    Toggle("Miniaturizable", isOn: binding(for: kind, keyPath: \.miniaturizable))
                    Toggle("Resizable", isOn: binding(for: kind, keyPath: \.resizable))
                    Toggle("Full Size Content View", isOn: binding(for: kind, keyPath: \.fullSizeContentView))

                    HStack(spacing: 10) {
                        Button("Reset \(kind == .settings ? "Settings" : "About")") {
                            store.reset(kind)
                        }
                        Button("Apply Now") {
                            store.applyToOpenWindows(for: kind)
                        }
                    }
                }
                .disabled(!overridesEnabled.wrappedValue)
                .opacity(overridesEnabled.wrappedValue ? 1 : 0.75)
            }
            .padding(.top, 2)
        }
    }

    private func binding<Value>(
        for kind: SettingsAboutWindowKind,
        keyPath: WritableKeyPath<SettingsAboutTitlebarDebugOptions, Value>
    ) -> Binding<Value> {
        Binding(
            get: { store.options(for: kind)[keyPath: keyPath] },
            set: { newValue in
                var updated = store.options(for: kind)
                updated[keyPath: keyPath] = newValue
                store.update(updated, for: kind)
            }
        )
    }
}

private enum DebugWindowConfigSnapshot {
    static func copyCombinedToPasteboard(defaults: UserDefaults = .standard) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(combinedPayload(defaults: defaults), forType: .string)
    }

    static func combinedPayload(defaults: UserDefaults = .standard) -> String {
        let sidebarPayload = """
        sidebarPreset=\(stringValue(defaults, key: "sidebarPreset", fallback: SidebarPresetOption.nativeSidebar.rawValue))
        sidebarMaterial=\(stringValue(defaults, key: "sidebarMaterial", fallback: SidebarMaterialOption.sidebar.rawValue))
        sidebarBlendMode=\(stringValue(defaults, key: "sidebarBlendMode", fallback: SidebarBlendModeOption.withinWindow.rawValue))
        sidebarState=\(stringValue(defaults, key: "sidebarState", fallback: SidebarStateOption.followWindow.rawValue))
        sidebarBlurOpacity=\(String(format: "%.2f", doubleValue(defaults, key: "sidebarBlurOpacity", fallback: 1.0)))
        sidebarTintHex=\(stringValue(defaults, key: "sidebarTintHex", fallback: "#000000"))
        sidebarTintHexLight=\(stringValue(defaults, key: "sidebarTintHexLight", fallback: "(nil)"))
        sidebarTintHexDark=\(stringValue(defaults, key: "sidebarTintHexDark", fallback: "(nil)"))
        sidebarTintOpacity=\(String(format: "%.2f", doubleValue(defaults, key: "sidebarTintOpacity", fallback: 0.18)))
        sidebarCornerRadius=\(String(format: "%.1f", doubleValue(defaults, key: "sidebarCornerRadius", fallback: 0.0)))
        sidebarBranchVerticalLayout=\(boolValue(defaults, key: SidebarBranchLayoutSettings.key, fallback: SidebarBranchLayoutSettings.defaultVerticalLayout))
        sidebarActiveTabIndicatorStyle=\(stringValue(defaults, key: SidebarActiveTabIndicatorSettings.styleKey, fallback: SidebarActiveTabIndicatorSettings.defaultStyle.rawValue))
        sidebarDevBuildBannerVisible=\(boolValue(defaults, key: DevBuildBannerDebugSettings.sidebarBannerVisibleKey, fallback: DevBuildBannerDebugSettings.defaultShowSidebarBanner))
        shortcutHintSidebarXOffset=\(String(format: "%.1f", doubleValue(defaults, key: ShortcutHintDebugSettings.sidebarHintXKey, fallback: ShortcutHintDebugSettings.defaultSidebarHintX)))
        shortcutHintSidebarYOffset=\(String(format: "%.1f", doubleValue(defaults, key: ShortcutHintDebugSettings.sidebarHintYKey, fallback: ShortcutHintDebugSettings.defaultSidebarHintY)))
        shortcutHintTitlebarXOffset=\(String(format: "%.1f", doubleValue(defaults, key: ShortcutHintDebugSettings.titlebarHintXKey, fallback: ShortcutHintDebugSettings.defaultTitlebarHintX)))
        shortcutHintTitlebarYOffset=\(String(format: "%.1f", doubleValue(defaults, key: ShortcutHintDebugSettings.titlebarHintYKey, fallback: ShortcutHintDebugSettings.defaultTitlebarHintY)))
        shortcutHintPaneTabXOffset=\(String(format: "%.1f", doubleValue(defaults, key: ShortcutHintDebugSettings.paneHintXKey, fallback: ShortcutHintDebugSettings.defaultPaneHintX)))
        shortcutHintPaneTabYOffset=\(String(format: "%.1f", doubleValue(defaults, key: ShortcutHintDebugSettings.paneHintYKey, fallback: ShortcutHintDebugSettings.defaultPaneHintY)))
        shortcutHintAlwaysShow=\(boolValue(defaults, key: ShortcutHintDebugSettings.alwaysShowHintsKey, fallback: ShortcutHintDebugSettings.defaultAlwaysShowHints))
        shortcutHintShowOnCommandHold=\(boolValue(defaults, key: ShortcutHintDebugSettings.showHintsOnCommandHoldKey, fallback: ShortcutHintDebugSettings.defaultShowHintsOnCommandHold))
        """

        let backgroundPayload = """
        bgGlassEnabled=\(boolValue(defaults, key: "bgGlassEnabled", fallback: false))
        bgGlassMaterial=\(stringValue(defaults, key: "bgGlassMaterial", fallback: "hudWindow"))
        bgGlassTintHex=\(stringValue(defaults, key: "bgGlassTintHex", fallback: "#000000"))
        bgGlassTintOpacity=\(String(format: "%.2f", doubleValue(defaults, key: "bgGlassTintOpacity", fallback: 0.03)))
        """

        let menuBarPayload = MenuBarIconDebugSettings.copyPayload(defaults: defaults)
        let browserDevToolsPayload = BrowserDevToolsButtonDebugSettings.copyPayload(defaults: defaults)

        return """
        # Sidebar Debug
        \(sidebarPayload)

        # Background Debug
        \(backgroundPayload)

        # Menu Bar Extra Debug
        \(menuBarPayload)

        # Browser DevTools Button
        \(browserDevToolsPayload)
        """
    }

    private static func stringValue(_ defaults: UserDefaults, key: String, fallback: String) -> String {
        defaults.string(forKey: key) ?? fallback
    }

    private static func doubleValue(_ defaults: UserDefaults, key: String, fallback: Double) -> Double {
        if let value = defaults.object(forKey: key) as? NSNumber {
            return value.doubleValue
        }
        if let text = defaults.string(forKey: key), let parsed = Double(text) {
            return parsed
        }
        return fallback
    }

    private static func boolValue(_ defaults: UserDefaults, key: String, fallback: Bool) -> Bool {
        guard defaults.object(forKey: key) != nil else { return fallback }
        return defaults.bool(forKey: key)
    }
}

private final class DebugWindowControlsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = DebugWindowControlsWindowController()

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 560),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = "Debug Window Controls"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("icc.debugWindowControls")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: DebugWindowControlsView())
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct DebugWindowControlsView: View {
    @AppStorage(ShortcutHintDebugSettings.sidebarHintXKey) private var sidebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultSidebarHintX
    @AppStorage(ShortcutHintDebugSettings.sidebarHintYKey) private var sidebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultSidebarHintY
    @AppStorage(ShortcutHintDebugSettings.titlebarHintXKey) private var titlebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultTitlebarHintX
    @AppStorage(ShortcutHintDebugSettings.titlebarHintYKey) private var titlebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultTitlebarHintY
    @AppStorage(ShortcutHintDebugSettings.paneHintXKey) private var paneShortcutHintXOffset = ShortcutHintDebugSettings.defaultPaneHintX
    @AppStorage(ShortcutHintDebugSettings.paneHintYKey) private var paneShortcutHintYOffset = ShortcutHintDebugSettings.defaultPaneHintY
    @AppStorage(ShortcutHintDebugSettings.alwaysShowHintsKey) private var alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
    @AppStorage(SidebarActiveTabIndicatorSettings.styleKey)
    private var sidebarActiveTabIndicatorStyle = SidebarActiveTabIndicatorSettings.defaultStyle.rawValue
    @AppStorage("debugTitlebarLeadingExtra") private var titlebarLeadingExtra: Double = 0
    @AppStorage(BrowserDevToolsButtonDebugSettings.iconNameKey) private var browserDevToolsIconNameRaw = BrowserDevToolsButtonDebugSettings.defaultIcon.rawValue
    @AppStorage(BrowserDevToolsButtonDebugSettings.iconColorKey) private var browserDevToolsIconColorRaw = BrowserDevToolsButtonDebugSettings.defaultColor.rawValue

    private var selectedDevToolsIconOption: BrowserDevToolsIconOption {
        BrowserDevToolsIconOption(rawValue: browserDevToolsIconNameRaw) ?? BrowserDevToolsButtonDebugSettings.defaultIcon
    }

    private var selectedDevToolsColorOption: BrowserDevToolsIconColorOption {
        BrowserDevToolsIconColorOption(rawValue: browserDevToolsIconColorRaw) ?? BrowserDevToolsButtonDebugSettings.defaultColor
    }

    private var selectedSidebarActiveTabIndicatorStyle: SidebarActiveTabIndicatorStyle {
        SidebarActiveTabIndicatorSettings.resolvedStyle(rawValue: sidebarActiveTabIndicatorStyle)
    }

    private var sidebarIndicatorStyleSelection: Binding<String> {
        Binding(
            get: { selectedSidebarActiveTabIndicatorStyle.rawValue },
            set: { sidebarActiveTabIndicatorStyle = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Debug Window Controls")
                    .font(.headline)

                GroupBox("Open") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Browser Import Hint Debug…") {
                            BrowserImportHintDebugWindowController.shared.show()
                        }
                        Button(
                            String(
                                localized: "debug.menu.browserProfilePopoverDebug",
                                defaultValue: "Browser Profile Popover Debug…"
                            )
                        ) {
                            BrowserProfilePopoverDebugWindowController.shared.show()
                        }
                        Button("Settings/About Titlebar Debug…") {
                            SettingsAboutTitlebarDebugWindowController.shared.show()
                        }
                        Button("Sidebar Debug…") {
                            SidebarDebugWindowController.shared.show()
                        }
                        Button("Background Debug…") {
                            BackgroundDebugWindowController.shared.show()
                        }
                        Button("Menu Bar Extra Debug…") {
                            MenuBarExtraDebugWindowController.shared.show()
                        }
                        Button("Open All Debug Windows") {
                            BrowserImportHintDebugWindowController.shared.show()
                            BrowserProfilePopoverDebugWindowController.shared.show()
                            SettingsAboutTitlebarDebugWindowController.shared.show()
                            SidebarDebugWindowController.shared.show()
                            BackgroundDebugWindowController.shared.show()
                            MenuBarExtraDebugWindowController.shared.show()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                }

                GroupBox("Shortcut Hints") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Always show shortcut hints", isOn: $alwaysShowShortcutHints)

                        hintOffsetSection(
                            "Sidebar Cmd+1…9",
                            x: $sidebarShortcutHintXOffset,
                            y: $sidebarShortcutHintYOffset
                        )

                        hintOffsetSection(
                            "Titlebar Buttons",
                            x: $titlebarShortcutHintXOffset,
                            y: $titlebarShortcutHintYOffset
                        )

                        hintOffsetSection(
                            "Pane Ctrl/Cmd+1…9",
                            x: $paneShortcutHintXOffset,
                            y: $paneShortcutHintYOffset
                        )

                        HStack(spacing: 12) {
                            Button("Reset Hints") {
                                resetShortcutHintOffsets()
                            }
                            Button("Copy Hint Config") {
                                copyShortcutHintConfig()
                            }
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Active Workspace Indicator") {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Style", selection: sidebarIndicatorStyleSelection) {
                            ForEach(SidebarActiveTabIndicatorStyle.allCases) { style in
                                Text(style.displayName).tag(style.rawValue)
                            }
                        }
                        .pickerStyle(.menu)

                        Button("Reset Indicator Style") {
                            sidebarActiveTabIndicatorStyle = SidebarActiveTabIndicatorSettings.defaultStyle.rawValue
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Titlebar Spacing") {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("Leading extra")
                            Slider(value: $titlebarLeadingExtra, in: 0...40)
                            Text(String(format: "%.0f", titlebarLeadingExtra))
                                .font(.caption)
                                .monospacedDigit()
                                .frame(width: 30, alignment: .trailing)
                        }
                        Button("Reset (0)") {
                            titlebarLeadingExtra = 0
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Browser DevTools Button") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("Icon")
                            Picker("Icon", selection: $browserDevToolsIconNameRaw) {
                                ForEach(BrowserDevToolsIconOption.allCases) { option in
                                    Text(option.title).tag(option.rawValue)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            Spacer()
                        }

                        HStack(spacing: 8) {
                            Text("Color")
                            Picker("Color", selection: $browserDevToolsIconColorRaw) {
                                ForEach(BrowserDevToolsIconColorOption.allCases) { option in
                                    Text(option.title).tag(option.rawValue)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            Spacer()
                        }

                        HStack(spacing: 8) {
                            Text("Preview")
                            Spacer()
                            Image(systemName: selectedDevToolsIconOption.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(selectedDevToolsColorOption.color)
                        }

                        HStack(spacing: 12) {
                            Button("Reset Button") {
                                resetBrowserDevToolsButton()
                            }
                            Button("Copy Button Config") {
                                copyBrowserDevToolsButtonConfig()
                            }
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Copy") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Copy All Debug Config") {
                            DebugWindowConfigSnapshot.copyCombinedToPasteboard()
                        }
                        Text("Copies sidebar, background, menu bar, and browser devtools settings as one payload.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func hintOffsetSection(_ title: String, x: Binding<Double>, y: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            sliderRow("X", value: x)
            sliderRow("Y", value: y)
        }
    }

    private func sliderRow(_ label: String, value: Binding<Double>) -> some View {
        HStack(spacing: 8) {
            Text(label)
            Slider(value: value, in: ShortcutHintDebugSettings.offsetRange)
            Text(String(format: "%.1f", ShortcutHintDebugSettings.clamped(value.wrappedValue)))
                .font(.caption)
                .monospacedDigit()
                .frame(width: 44, alignment: .trailing)
        }
    }

    private func resetShortcutHintOffsets() {
        sidebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultSidebarHintX
        sidebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultSidebarHintY
        titlebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultTitlebarHintX
        titlebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultTitlebarHintY
        paneShortcutHintXOffset = ShortcutHintDebugSettings.defaultPaneHintX
        paneShortcutHintYOffset = ShortcutHintDebugSettings.defaultPaneHintY
        alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
    }

    private func copyShortcutHintConfig() {
        let payload = """
        shortcutHintSidebarXOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(sidebarShortcutHintXOffset)))
        shortcutHintSidebarYOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(sidebarShortcutHintYOffset)))
        shortcutHintTitlebarXOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(titlebarShortcutHintXOffset)))
        shortcutHintTitlebarYOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(titlebarShortcutHintYOffset)))
        shortcutHintPaneTabXOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(paneShortcutHintXOffset)))
        shortcutHintPaneTabYOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(paneShortcutHintYOffset)))
        shortcutHintAlwaysShow=\(alwaysShowShortcutHints)
        """
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(payload, forType: .string)
    }

    private func resetBrowserDevToolsButton() {
        browserDevToolsIconNameRaw = BrowserDevToolsButtonDebugSettings.defaultIcon.rawValue
        browserDevToolsIconColorRaw = BrowserDevToolsButtonDebugSettings.defaultColor.rawValue
    }

    private func copyBrowserDevToolsButtonConfig() {
        let payload = BrowserDevToolsButtonDebugSettings.copyPayload(defaults: .standard)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(payload, forType: .string)
    }
}

private final class BrowserImportHintDebugWindowController: NSWindowController, NSWindowDelegate {
    static let shared = BrowserImportHintDebugWindowController()

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 420),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = "Browser Import Hint Debug"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("icc.browserImportHintDebug")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: BrowserImportHintDebugView())
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}

private final class BrowserProfilePopoverDebugWindowController: NSWindowController, NSWindowDelegate {
    static let shared = BrowserProfilePopoverDebugWindowController()

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 340),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = String(
            localized: "debug.windows.browserProfilePopover.title",
            defaultValue: "Browser Profile Popover Debug"
        )
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("icc.browserProfilePopoverDebug")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: BrowserProfilePopoverDebugView())
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct BrowserProfilePopoverDebugView: View {
    @AppStorage(BrowserProfilePopoverDebugSettings.horizontalPaddingKey)
    private var horizontalPaddingRaw = BrowserProfilePopoverDebugSettings.defaultHorizontalPadding
    @AppStorage(BrowserProfilePopoverDebugSettings.verticalPaddingKey)
    private var verticalPaddingRaw = BrowserProfilePopoverDebugSettings.defaultVerticalPadding

    private var horizontalPaddingBinding: Binding<Double> {
        Binding(
            get: { BrowserProfilePopoverDebugSettings.resolvedHorizontalPadding(horizontalPaddingRaw) },
            set: { horizontalPaddingRaw = BrowserProfilePopoverDebugSettings.resolvedHorizontalPadding($0) }
        )
    }

    private var verticalPaddingBinding: Binding<Double> {
        Binding(
            get: { BrowserProfilePopoverDebugSettings.resolvedVerticalPadding(verticalPaddingRaw) },
            set: { verticalPaddingRaw = BrowserProfilePopoverDebugSettings.resolvedVerticalPadding($0) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(
                    String(
                        localized: "debug.browserProfilePopover.heading",
                        defaultValue: "Browser Profile Popover"
                    )
                )
                .font(.headline)

                Text(
                    String(
                        localized: "debug.browserProfilePopover.note",
                        defaultValue: "Tune the profile popover padding live while comparing it against the browser toolbar menu."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                GroupBox(
                    String(
                        localized: "debug.browserProfilePopover.group.padding",
                        defaultValue: "Padding"
                    )
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        sliderRow(
                            String(
                                localized: "debug.browserProfilePopover.label.horizontal",
                                defaultValue: "Horizontal"
                            ),
                            value: horizontalPaddingBinding,
                            range: BrowserProfilePopoverDebugSettings.horizontalPaddingRange
                        )
                        sliderRow(
                            String(
                                localized: "debug.browserProfilePopover.label.vertical",
                                defaultValue: "Vertical"
                            ),
                            value: verticalPaddingBinding,
                            range: BrowserProfilePopoverDebugSettings.verticalPaddingRange
                        )
                    }
                    .padding(.top, 2)
                }

                GroupBox(
                    String(
                        localized: "debug.browserProfilePopover.group.preview",
                        defaultValue: "Preview"
                    )
                ) {
                    profilePopoverPreview
                        .padding(.top, 2)
                }

                HStack(spacing: 12) {
                    Button(
                        String(
                            localized: "debug.browserProfilePopover.reset",
                            defaultValue: "Reset"
                        )
                    ) {
                        horizontalPaddingRaw = BrowserProfilePopoverDebugSettings.defaultHorizontalPadding
                        verticalPaddingRaw = BrowserProfilePopoverDebugSettings.defaultVerticalPadding
                    }
                }

                Text(
                    String(
                        localized: "debug.browserProfilePopover.liveNote",
                        defaultValue: "Changes apply live to the browser profile popover."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var profilePopoverPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "browser.profile.menu.title", defaultValue: "Profiles"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                        .frame(width: 12, alignment: .center)
                    Text(String(localized: "browser.profile.default", defaultValue: "Default"))
                        .font(.system(size: 12))
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.primary.opacity(0.12))
                )
            }

            Divider()

            Text(String(localized: "browser.profile.new", defaultValue: "New Profile..."))
                .font(.system(size: 12))

            Text(String(localized: "menu.view.importFromBrowser", defaultValue: "Import Browser Data…"))
                .font(.system(size: 12))
        }
        .padding(.horizontal, BrowserProfilePopoverDebugSettings.resolvedHorizontalPadding(horizontalPaddingRaw))
        .padding(.vertical, BrowserProfilePopoverDebugSettings.resolvedVerticalPadding(verticalPaddingRaw))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.08))
                )
        )
    }

    private func sliderRow(_ label: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        HStack(spacing: 8) {
            Text(label)
            Slider(value: value, in: range, step: 1)
            Text(String(format: "%.0f", value.wrappedValue))
                .font(.caption)
                .monospacedDigit()
                .frame(width: 32, alignment: .trailing)
        }
    }
}

private struct BrowserImportHintDebugView: View {
    @AppStorage(BrowserImportHintSettings.variantKey)
    private var variantRaw = BrowserImportHintSettings.defaultVariant.rawValue
    @AppStorage(BrowserImportHintSettings.showOnBlankTabsKey)
    private var showOnBlankTabs = BrowserImportHintSettings.defaultShowOnBlankTabs
    @AppStorage(BrowserImportHintSettings.dismissedKey)
    private var isDismissed = BrowserImportHintSettings.defaultDismissed

    private var selectedVariant: BrowserImportHintVariant {
        BrowserImportHintSettings.variant(for: variantRaw)
    }

    private var variantSelection: Binding<String> {
        Binding(
            get: { selectedVariant.rawValue },
            set: { variantRaw = BrowserImportHintSettings.variant(for: $0).rawValue }
        )
    }

    private var showOnBlankTabsBinding: Binding<Bool> {
        Binding(
            get: { showOnBlankTabs },
            set: { newValue in
                showOnBlankTabs = newValue
                if newValue {
                    isDismissed = false
                }
            }
        )
    }

    private var presentation: BrowserImportHintPresentation {
        BrowserImportHintPresentation(
            variant: selectedVariant,
            showOnBlankTabs: showOnBlankTabs,
            isDismissed: isDismissed
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Browser Import Hint")
                    .font(.headline)

                Text("Try lighter blank-tab import surfaces and dismissal states without touching the permanent Browser settings home.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                GroupBox("Variant") {
                    VStack(alignment: .leading, spacing: 10) {
                        Picker("Blank Tab Style", selection: variantSelection) {
                            ForEach(BrowserImportHintVariant.allCases) { variant in
                                Text(title(for: variant)).tag(variant.rawValue)
                            }
                        }
                        .pickerStyle(.menu)

                        Text(description(for: selectedVariant))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 2)
                }

                GroupBox("State") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Show on blank browser tabs", isOn: showOnBlankTabsBinding)
                        Toggle("Pretend the user dismissed it", isOn: $isDismissed)

                        Text("Current blank-tab placement: \(placementTitle(presentation.blankTabPlacement))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Settings status: \(settingsStatusTitle(presentation.settingsStatus))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                }

                GroupBox("Quick Actions") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Button("Open Browser Settings") {
                                AppDelegate.presentPreferencesWindow(navigationTarget: .browser)
                            }
                            Button("Open Import Dialog") {
                                DispatchQueue.main.async {
                                    BrowserDataImportCoordinator.shared.presentImportDialog()
                                }
                            }
                        }

                        Button("Reset Hint Debug State") {
                            BrowserImportHintSettings.reset()
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Ideas") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Inline strip: default candidate, visible but quieter than the old floating card.")
                        Text("Floating card: strongest nudge, useful when we want more explanation.")
                        Text("Toolbar chip: most subtle, best when the hint should stay out of the content area.")
                        Text("Settings only: no in-browser nudge, Browser settings becomes the only permanent home.")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func title(for variant: BrowserImportHintVariant) -> String {
        switch variant {
        case .inlineStrip:
            return "Inline Strip"
        case .floatingCard:
            return "Floating Card"
        case .toolbarChip:
            return "Toolbar Chip"
        case .settingsOnly:
            return "Settings Only"
        }
    }

    private func description(for variant: BrowserImportHintVariant) -> String {
        switch variant {
        case .inlineStrip:
            return "Shows a thin hint bar at the top of blank browser tabs."
        case .floatingCard:
            return "Shows the fuller callout card inside blank browser tabs."
        case .toolbarChip:
            return "Moves the hint into a small toolbar chip beside the browser controls."
        case .settingsOnly:
            return "Hides the blank-tab hint and leaves Browser settings as the only home."
        }
    }

    private func placementTitle(_ placement: BrowserImportHintBlankTabPlacement) -> String {
        switch placement {
        case .hidden:
            return "Hidden"
        case .inlineStrip:
            return "Inline Strip"
        case .floatingCard:
            return "Floating Card"
        case .toolbarChip:
            return "Toolbar Chip"
        }
    }

    private func settingsStatusTitle(_ status: BrowserImportHintSettingsStatus) -> String {
        switch status {
        case .visible:
            return "Visible"
        case .hidden:
            return "Hidden"
        case .settingsOnly:
            return "Settings Only"
        }
    }
}

private final class AboutWindowController: NSWindowController, NSWindowDelegate {
    static let shared = AboutWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("icc.about")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: AboutPanelView())
        SettingsAboutTitlebarDebugStore.shared.applyCurrentOptions(to: window, for: .about)
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window else { return }
        SettingsAboutTitlebarDebugStore.shared.applyCurrentOptions(to: window, for: .about)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}

private final class AcknowledgmentsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = AcknowledgmentsWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.title = String(localized: "about.licenses.windowTitle", defaultValue: "Third-Party Licenses")
        window.identifier = NSUserInterfaceItemIdentifier("icc.licenses")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: AcknowledgmentsView())
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window else { return }
        window.makeKeyAndOrderFront(nil)
    }
}

private struct AcknowledgmentsView: View {
    private let content: String = {
        if let url = Bundle.main.url(forResource: "THIRD_PARTY_LICENSES", withExtension: "md"),
           let text = try? String(contentsOf: url) {
            return text
        }
        return String(localized: "about.licenses.notFound", defaultValue: "Licenses file not found.")
    }()

    var body: some View {
        ScrollView {
            Text(content)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SettingsWindowController()
    private var pendingFocusRestoreWorkItems: [DispatchWorkItem] = []
    private var focusRestoreGeneration = 0

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("icc.settings")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: SettingsRootView())
        SettingsAboutTitlebarDebugStore.shared.applyCurrentOptions(to: window, for: .settings)
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(navigationTarget: SettingsNavigationTarget? = nil) {
        guard let window else { return }
#if DEBUG
        dlog("settings.window.show requested isVisible=\(window.isVisible ? 1 : 0) isKey=\(window.isKeyWindow ? 1 : 0)")
#endif
        SettingsAboutTitlebarDebugStore.shared.applyCurrentOptions(to: window, for: .settings)
        if !window.isVisible {
            window.center()
        }
        window.makeKeyAndOrderFront(nil)
        if let navigationTarget {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                SettingsNavigationRequest.post(navigationTarget)
            }
        }
#if DEBUG
        dlog("settings.window.show completed isVisible=\(window.isVisible ? 1 : 0) isKey=\(window.isKeyWindow ? 1 : 0)")
#endif
    }

    func preserveFocusAfterPreferenceMutation() {
        guard let window, window.isVisible else { return }
        cancelPendingFocusRestore()
        focusRestoreGeneration += 1
        let generation = focusRestoreGeneration
        writeFocusDiagnosticsIfNeeded(stage: "requested")
        scheduleFocusRestore(
            for: window,
            generation: generation,
            delays: [0, 0.04, 0.12, 0.24, 0.4, 0.7]
        )
    }

    func windowWillClose(_ notification: Notification) {
        cancelPendingFocusRestore()
        writeFocusDiagnosticsIfNeeded(stage: "windowWillClose")
    }

    func windowDidBecomeKey(_ notification: Notification) {
        writeFocusDiagnosticsIfNeeded(stage: "didBecomeKey")
    }

    func windowDidResignKey(_ notification: Notification) {
        guard let window else { return }
        writeFocusDiagnosticsIfNeeded(stage: "didResignKey")
        guard focusRestoreGeneration > 0 else { return }
        scheduleFocusRestore(
            for: window,
            generation: focusRestoreGeneration,
            delays: [0, 0.03, 0.1]
        )
    }

    private func scheduleFocusRestore(
        for window: NSWindow,
        generation: Int,
        delays: [TimeInterval]
    ) {
        for (index, delay) in delays.enumerated() {
            let isLastAttempt = index == delays.count - 1
            let workItem = DispatchWorkItem { [weak self, weak window] in
                guard let self, let window, window.isVisible else { return }
                guard self.focusRestoreGeneration == generation else { return }
                self.writeFocusDiagnosticsIfNeeded(stage: "restoreAttempt.\(index)")
                if !window.isKeyWindow {
                    NSApp.activate(ignoringOtherApps: true)
                    window.orderFrontRegardless()
                    window.makeKeyAndOrderFront(nil)
                    self.writeFocusDiagnosticsIfNeeded(stage: "restoreApplied.\(index)")
                }
                if isLastAttempt, self.focusRestoreGeneration == generation {
                    self.focusRestoreGeneration = 0
                }
            }
            pendingFocusRestoreWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }

    private func cancelPendingFocusRestore() {
        pendingFocusRestoreWorkItems.forEach { $0.cancel() }
        pendingFocusRestoreWorkItems.removeAll()
        focusRestoreGeneration = 0
    }

    private func writeFocusDiagnosticsIfNeeded(stage: String) {
        let env = ProcessInfo.processInfo.environment
        guard let path = env["ICC_UI_TEST_DIAGNOSTICS_PATH"], !path.isEmpty else { return }

        var payload = loadFocusDiagnostics(at: path)
        payload["focusStage"] = stage
        payload["keyWindowIdentifier"] = NSApp.keyWindow?.identifier?.rawValue ?? ""
        payload["mainWindowIdentifier"] = NSApp.mainWindow?.identifier?.rawValue ?? ""
        payload["settingsWindowIsKey"] = (window?.isKeyWindow ?? false) ? "1" : "0"

        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
        try? data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }

    private func loadFocusDiagnostics(at path: String) -> [String: String] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return [:]
        }
        return object
    }
}

enum SettingsNavigationTarget: String {
    case automation
    case notifications
    case wechat
    case browser
    case browserImport
    case keyboardShortcuts
}

enum SettingsNavigationRequest {
    static let notificationName = Notification.Name("icc.settings.navigate")
    private static let targetKey = "target"

    static func post(_ target: SettingsNavigationTarget) {
        NotificationCenter.default.post(
            name: notificationName,
            object: nil,
            userInfo: [targetKey: target.rawValue]
        )
    }

    static func target(from notification: Notification) -> SettingsNavigationTarget? {
        guard let rawValue = notification.userInfo?[targetKey] as? String else { return nil }
        return SettingsNavigationTarget(rawValue: rawValue)
    }
}

private final class SidebarDebugWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SidebarDebugWindowController()

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 520),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = "Sidebar Debug"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("icc.sidebarDebug")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: SidebarDebugView())
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct AboutPanelView: View {
    @Environment(\.openURL) private var openURL

    private let githubURL = URL(string: "https://github.com/miounet11/icc")
    private let docsURL = URL(string: "https://github.com/miounet11/icc#readme")

    private var version: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }
    private var build: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }
    private var commit: String? {
        if let value = Bundle.main.infoDictionary?["ICCCommit"] as? String, !value.isEmpty {
            return value
        }
        let env = ProcessInfo.processInfo.environment["ICC_COMMIT"] ?? ""
        return env.isEmpty ? nil : env
    }
    private var copyright: String? { Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String }

    var body: some View {
        VStack(alignment: .center) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .renderingMode(.original)
                .frame(width: 96, height: 96)
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 3)

            VStack(alignment: .center, spacing: 32) {
                VStack(alignment: .center, spacing: 8) {
                    Text(String(localized: "about.appName", defaultValue: "icc"))
                        .bold()
                        .font(.title)
                    Text(String(localized: "about.description", defaultValue: "A Ghostty-based terminal with vertical tabs\nand a notification panel for macOS."))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.caption)
                        .tint(.secondary)
                        .opacity(0.8)
                }
                .textSelection(.enabled)

                VStack(spacing: 2) {
                    if let version {
                        AboutPropertyRow(label: String(localized: "about.version", defaultValue: "Version"), text: version)
                    }
                    if let build {
                        AboutPropertyRow(label: String(localized: "about.build", defaultValue: "Build"), text: build)
                    }
                    let commitText = commit ?? "—"
                    let commitURL = commit.flatMap { hash in
                        URL(string: "https://github.com/miounet11/icc/commit/\(hash)")
                    }
                    AboutPropertyRow(label: String(localized: "about.commit", defaultValue: "Commit"), text: commitText, url: commitURL)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 8) {
                    if let url = docsURL {
                        Button(String(localized: "about.docs", defaultValue: "Docs")) {
                            openURL(url)
                        }
                    }
                    if let url = githubURL {
                        Button(String(localized: "about.github", defaultValue: "GitHub")) {
                            openURL(url)
                        }
                    }
                    Button(String(localized: "about.licenses", defaultValue: "Licenses")) {
                        AcknowledgmentsWindowController.shared.show()
                    }
                }

                if let copy = copyright, !copy.isEmpty {
                    Text(copy)
                        .font(.caption)
                        .textSelection(.enabled)
                        .tint(.secondary)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 8)
        .padding(32)
        .frame(minWidth: 280)
        .background(AboutVisualEffectBackground(material: .underWindowBackground).ignoresSafeArea())
    }
}

private struct SidebarDebugView: View {
    @AppStorage("sidebarPreset") private var sidebarPreset = SidebarPresetOption.nativeSidebar.rawValue
    @AppStorage("sidebarTintOpacity") private var sidebarTintOpacity = SidebarTintDefaults.opacity
    @AppStorage("sidebarTintHex") private var sidebarTintHex = SidebarTintDefaults.hex
    @AppStorage("sidebarTintHexLight") private var sidebarTintHexLight: String?
    @AppStorage("sidebarTintHexDark") private var sidebarTintHexDark: String?
    @AppStorage("sidebarMaterial") private var sidebarMaterial = SidebarMaterialOption.sidebar.rawValue
    @AppStorage("sidebarBlendMode") private var sidebarBlendMode = SidebarBlendModeOption.withinWindow.rawValue
    @AppStorage("sidebarState") private var sidebarState = SidebarStateOption.followWindow.rawValue
    @AppStorage("sidebarCornerRadius") private var sidebarCornerRadius = 0.0
    @AppStorage("sidebarBlurOpacity") private var sidebarBlurOpacity = 1.0
    @AppStorage(SidebarBranchLayoutSettings.key) private var sidebarBranchVerticalLayout = SidebarBranchLayoutSettings.defaultVerticalLayout
    @AppStorage(ShortcutHintDebugSettings.sidebarHintXKey) private var sidebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultSidebarHintX
    @AppStorage(ShortcutHintDebugSettings.sidebarHintYKey) private var sidebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultSidebarHintY
    @AppStorage(ShortcutHintDebugSettings.titlebarHintXKey) private var titlebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultTitlebarHintX
    @AppStorage(ShortcutHintDebugSettings.titlebarHintYKey) private var titlebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultTitlebarHintY
    @AppStorage(ShortcutHintDebugSettings.paneHintXKey) private var paneShortcutHintXOffset = ShortcutHintDebugSettings.defaultPaneHintX
    @AppStorage(ShortcutHintDebugSettings.paneHintYKey) private var paneShortcutHintYOffset = ShortcutHintDebugSettings.defaultPaneHintY
    @AppStorage(ShortcutHintDebugSettings.alwaysShowHintsKey) private var alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
    @AppStorage(DevBuildBannerDebugSettings.sidebarBannerVisibleKey)
    private var showSidebarDevBuildBanner = DevBuildBannerDebugSettings.defaultShowSidebarBanner
    @AppStorage(SidebarActiveTabIndicatorSettings.styleKey)
    private var sidebarActiveTabIndicatorStyle = SidebarActiveTabIndicatorSettings.defaultStyle.rawValue

    private var selectedSidebarIndicatorStyle: SidebarActiveTabIndicatorStyle {
        SidebarActiveTabIndicatorSettings.resolvedStyle(rawValue: sidebarActiveTabIndicatorStyle)
    }

    private var sidebarIndicatorStyleSelection: Binding<String> {
        Binding(
            get: { selectedSidebarIndicatorStyle.rawValue },
            set: { sidebarActiveTabIndicatorStyle = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Sidebar Appearance")
                    .font(.headline)

                GroupBox("Presets") {
                    Picker("Preset", selection: $sidebarPreset) {
                        ForEach(SidebarPresetOption.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                    .onChange(of: sidebarPreset) { _ in
                        applyPreset()
                    }
                    .padding(.top, 2)
                }

                GroupBox("Blur") {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Material", selection: $sidebarMaterial) {
                            ForEach(SidebarMaterialOption.allCases) { option in
                                Text(option.title).tag(option.rawValue)
                            }
                        }

                        Picker("Blending", selection: $sidebarBlendMode) {
                            ForEach(SidebarBlendModeOption.allCases) { option in
                                Text(option.title).tag(option.rawValue)
                            }
                        }

                        Picker("State", selection: $sidebarState) {
                            ForEach(SidebarStateOption.allCases) { option in
                                Text(option.title).tag(option.rawValue)
                            }
                        }

                        HStack(spacing: 8) {
                            Text("Strength")
                            Slider(value: $sidebarBlurOpacity, in: 0...1)
                            Text(String(format: "%.0f%%", sidebarBlurOpacity * 100))
                                .font(.caption)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Tint") {
                    VStack(alignment: .leading, spacing: 8) {
                        ColorPicker("Tint Color", selection: tintColorBinding, supportsOpacity: false)

                        HStack(spacing: 8) {
                            Text("Opacity")
                            Slider(value: $sidebarTintOpacity, in: 0...0.7)
                            Text(String(format: "%.0f%%", sidebarTintOpacity * 100))
                                .font(.caption)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Shape") {
                    HStack(spacing: 8) {
                        Text("Corner Radius")
                        Slider(value: $sidebarCornerRadius, in: 0...20)
                        Text(String(format: "%.0f", sidebarCornerRadius))
                            .font(.caption)
                            .frame(width: 32, alignment: .trailing)
                    }
                    .padding(.top, 2)
                }

                GroupBox("Shortcut Hints") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Always show shortcut hints", isOn: $alwaysShowShortcutHints)

                        hintOffsetSection(
                            "Sidebar Cmd+1…9",
                            x: $sidebarShortcutHintXOffset,
                            y: $sidebarShortcutHintYOffset
                        )

                        hintOffsetSection(
                            "Titlebar Buttons",
                            x: $titlebarShortcutHintXOffset,
                            y: $titlebarShortcutHintYOffset
                        )

                        hintOffsetSection(
                            "Pane Ctrl/Cmd+1…9",
                            x: $paneShortcutHintXOffset,
                            y: $paneShortcutHintYOffset
                        )
                    }
                    .padding(.top, 2)
                }

                GroupBox("Active Workspace Indicator") {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Style", selection: sidebarIndicatorStyleSelection) {
                            ForEach(SidebarActiveTabIndicatorStyle.allCases) { style in
                                Text(style.displayName).tag(style.rawValue)
                            }
                        }
                    }
                    .padding(.top, 2)
                }

                GroupBox("Workspace Metadata") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Render branch list vertically", isOn: $sidebarBranchVerticalLayout)
                        Text("When enabled, each branch appears on its own line in the sidebar.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }

                HStack(spacing: 12) {
                    Button("Reset Tint") {
                        sidebarTintOpacity = 0.62
                        sidebarTintHex = SidebarTintDefaults.hex
                        sidebarTintHexLight = nil
                        sidebarTintHexDark = nil
                    }
                    Button("Reset Blur") {
                        sidebarMaterial = SidebarMaterialOption.hudWindow.rawValue
                        sidebarBlendMode = SidebarBlendModeOption.withinWindow.rawValue
                        sidebarState = SidebarStateOption.active.rawValue
                        sidebarBlurOpacity = 0.98
                    }
                    Button("Reset Shape") {
                        sidebarCornerRadius = 0.0
                    }
                    Button("Reset Hints") {
                        resetShortcutHintOffsets()
                    }
                    Button("Reset Active Indicator") {
                        sidebarActiveTabIndicatorStyle = SidebarActiveTabIndicatorSettings.defaultStyle.rawValue
                    }
                }

                Button("Copy Config") {
                    copySidebarConfig()
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private var tintColorBinding: Binding<Color> {
        Binding(
            get: {
                Color(nsColor: NSColor(hex: sidebarTintHex) ?? .black)
            },
            set: { newColor in
                let nsColor = NSColor(newColor)
                sidebarTintHex = nsColor.hexString()
            }
        )
    }

    private func hintOffsetSection(_ title: String, x: Binding<Double>, y: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            sliderRow("X", value: x)
            sliderRow("Y", value: y)
        }
    }

    private func sliderRow(_ label: String, value: Binding<Double>) -> some View {
        HStack(spacing: 8) {
            Text(label)
            Slider(value: value, in: ShortcutHintDebugSettings.offsetRange)
            Text(String(format: "%.1f", ShortcutHintDebugSettings.clamped(value.wrappedValue)))
                .font(.caption)
                .monospacedDigit()
                .frame(width: 44, alignment: .trailing)
        }
    }

    private func resetShortcutHintOffsets() {
        sidebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultSidebarHintX
        sidebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultSidebarHintY
        titlebarShortcutHintXOffset = ShortcutHintDebugSettings.defaultTitlebarHintX
        titlebarShortcutHintYOffset = ShortcutHintDebugSettings.defaultTitlebarHintY
        paneShortcutHintXOffset = ShortcutHintDebugSettings.defaultPaneHintX
        paneShortcutHintYOffset = ShortcutHintDebugSettings.defaultPaneHintY
        alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
    }

    private func copySidebarConfig() {
        let payload = """
        sidebarPreset=\(sidebarPreset)
        sidebarMaterial=\(sidebarMaterial)
        sidebarBlendMode=\(sidebarBlendMode)
        sidebarState=\(sidebarState)
        sidebarBlurOpacity=\(String(format: "%.2f", sidebarBlurOpacity))
        sidebarTintHex=\(sidebarTintHex)
        sidebarTintHexLight=\(sidebarTintHexLight ?? "(nil)")
        sidebarTintHexDark=\(sidebarTintHexDark ?? "(nil)")
        sidebarTintOpacity=\(String(format: "%.2f", sidebarTintOpacity))
        sidebarCornerRadius=\(String(format: "%.1f", sidebarCornerRadius))
        sidebarBranchVerticalLayout=\(sidebarBranchVerticalLayout)
        sidebarActiveTabIndicatorStyle=\(sidebarActiveTabIndicatorStyle)
        sidebarDevBuildBannerVisible=\(showSidebarDevBuildBanner)
        shortcutHintSidebarXOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(sidebarShortcutHintXOffset)))
        shortcutHintSidebarYOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(sidebarShortcutHintYOffset)))
        shortcutHintTitlebarXOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(titlebarShortcutHintXOffset)))
        shortcutHintTitlebarYOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(titlebarShortcutHintYOffset)))
        shortcutHintPaneTabXOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(paneShortcutHintXOffset)))
        shortcutHintPaneTabYOffset=\(String(format: "%.1f", ShortcutHintDebugSettings.clamped(paneShortcutHintYOffset)))
        shortcutHintAlwaysShow=\(alwaysShowShortcutHints)
        """
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(payload, forType: .string)
    }

    private func applyPreset() {
        guard let preset = SidebarPresetOption(rawValue: sidebarPreset) else { return }
        sidebarMaterial = preset.material.rawValue
        sidebarBlendMode = preset.blendMode.rawValue
        sidebarState = preset.state.rawValue
        sidebarTintHex = preset.tintHex
        sidebarTintOpacity = preset.tintOpacity
        sidebarCornerRadius = preset.cornerRadius
        sidebarBlurOpacity = preset.blurOpacity
        sidebarTintHexLight = nil
        sidebarTintHexDark = nil
    }
}

// MARK: - Menu Bar Extra Debug Window

private final class MenuBarExtraDebugWindowController: NSWindowController, NSWindowDelegate {
    static let shared = MenuBarExtraDebugWindowController()

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 430),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = "Menu Bar Extra Debug"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("iatlas.menubarDebug")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: MenuBarExtraDebugView())
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct MenuBarExtraDebugView: View {
    @AppStorage(MenuBarIconDebugSettings.previewEnabledKey) private var previewEnabled = false
    @AppStorage(MenuBarIconDebugSettings.previewCountKey) private var previewCount = 1
    @AppStorage(MenuBarIconDebugSettings.badgeRectXKey) private var badgeRectX = Double(MenuBarIconDebugSettings.defaultBadgeRect.origin.x)
    @AppStorage(MenuBarIconDebugSettings.badgeRectYKey) private var badgeRectY = Double(MenuBarIconDebugSettings.defaultBadgeRect.origin.y)
    @AppStorage(MenuBarIconDebugSettings.badgeRectWidthKey) private var badgeRectWidth = Double(MenuBarIconDebugSettings.defaultBadgeRect.width)
    @AppStorage(MenuBarIconDebugSettings.badgeRectHeightKey) private var badgeRectHeight = Double(MenuBarIconDebugSettings.defaultBadgeRect.height)
    @AppStorage(MenuBarIconDebugSettings.singleDigitFontSizeKey) private var singleDigitFontSize = Double(MenuBarIconDebugSettings.defaultSingleDigitFontSize)
    @AppStorage(MenuBarIconDebugSettings.multiDigitFontSizeKey) private var multiDigitFontSize = Double(MenuBarIconDebugSettings.defaultMultiDigitFontSize)
    @AppStorage(MenuBarIconDebugSettings.singleDigitYOffsetKey) private var singleDigitYOffset = Double(MenuBarIconDebugSettings.defaultSingleDigitYOffset)
    @AppStorage(MenuBarIconDebugSettings.multiDigitYOffsetKey) private var multiDigitYOffset = Double(MenuBarIconDebugSettings.defaultMultiDigitYOffset)
    @AppStorage(MenuBarIconDebugSettings.singleDigitXAdjustKey) private var singleDigitXAdjust = Double(MenuBarIconDebugSettings.defaultSingleDigitXAdjust)
    @AppStorage(MenuBarIconDebugSettings.multiDigitXAdjustKey) private var multiDigitXAdjust = Double(MenuBarIconDebugSettings.defaultMultiDigitXAdjust)
    @AppStorage(MenuBarIconDebugSettings.textRectWidthAdjustKey) private var textRectWidthAdjust = Double(MenuBarIconDebugSettings.defaultTextRectWidthAdjust)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Menu Bar Extra Icon")
                    .font(.headline)

                GroupBox("Preview Count") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Override unread count", isOn: $previewEnabled)

                        Stepper(value: $previewCount, in: 0...99) {
                            HStack {
                                Text("Unread Count")
                                Spacer()
                                Text("\(previewCount)")
                                    .font(.caption)
                                    .monospacedDigit()
                            }
                        }
                        .disabled(!previewEnabled)
                    }
                    .padding(.top, 2)
                }

                GroupBox("Badge Rect") {
                    VStack(alignment: .leading, spacing: 8) {
                        sliderRow("X", value: $badgeRectX, range: 0...20, format: "%.2f")
                        sliderRow("Y", value: $badgeRectY, range: 0...20, format: "%.2f")
                        sliderRow("Width", value: $badgeRectWidth, range: 4...14, format: "%.2f")
                        sliderRow("Height", value: $badgeRectHeight, range: 4...14, format: "%.2f")
                    }
                    .padding(.top, 2)
                }

                GroupBox("Badge Text") {
                    VStack(alignment: .leading, spacing: 8) {
                        sliderRow("1-digit size", value: $singleDigitFontSize, range: 6...14, format: "%.2f")
                        sliderRow("2-digit size", value: $multiDigitFontSize, range: 6...14, format: "%.2f")
                        sliderRow("1-digit X", value: $singleDigitXAdjust, range: -4...4, format: "%.2f")
                        sliderRow("2-digit X", value: $multiDigitXAdjust, range: -4...4, format: "%.2f")
                        sliderRow("1-digit Y", value: $singleDigitYOffset, range: -3...4, format: "%.2f")
                        sliderRow("2-digit Y", value: $multiDigitYOffset, range: -3...4, format: "%.2f")
                        sliderRow("Text width adjust", value: $textRectWidthAdjust, range: -3...5, format: "%.2f")
                    }
                    .padding(.top, 2)
                }

                HStack(spacing: 12) {
                    Button("Reset") {
                        previewEnabled = false
                        previewCount = 1
                        badgeRectX = Double(MenuBarIconDebugSettings.defaultBadgeRect.origin.x)
                        badgeRectY = Double(MenuBarIconDebugSettings.defaultBadgeRect.origin.y)
                        badgeRectWidth = Double(MenuBarIconDebugSettings.defaultBadgeRect.width)
                        badgeRectHeight = Double(MenuBarIconDebugSettings.defaultBadgeRect.height)
                        singleDigitFontSize = Double(MenuBarIconDebugSettings.defaultSingleDigitFontSize)
                        multiDigitFontSize = Double(MenuBarIconDebugSettings.defaultMultiDigitFontSize)
                        singleDigitYOffset = Double(MenuBarIconDebugSettings.defaultSingleDigitYOffset)
                        multiDigitYOffset = Double(MenuBarIconDebugSettings.defaultMultiDigitYOffset)
                        singleDigitXAdjust = Double(MenuBarIconDebugSettings.defaultSingleDigitXAdjust)
                        multiDigitXAdjust = Double(MenuBarIconDebugSettings.defaultMultiDigitXAdjust)
                        textRectWidthAdjust = Double(MenuBarIconDebugSettings.defaultTextRectWidthAdjust)
                        applyLiveUpdate()
                    }

                    Button("Copy Config") {
                        let payload = MenuBarIconDebugSettings.copyPayload()
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(payload, forType: .string)
                    }
                }

                Text("Tip: enable override count, then tune until the menu bar icon looks right.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .onAppear { applyLiveUpdate() }
        .onChange(of: previewEnabled) { _ in applyLiveUpdate() }
        .onChange(of: previewCount) { _ in applyLiveUpdate() }
        .onChange(of: badgeRectX) { _ in applyLiveUpdate() }
        .onChange(of: badgeRectY) { _ in applyLiveUpdate() }
        .onChange(of: badgeRectWidth) { _ in applyLiveUpdate() }
        .onChange(of: badgeRectHeight) { _ in applyLiveUpdate() }
        .onChange(of: singleDigitFontSize) { _ in applyLiveUpdate() }
        .onChange(of: multiDigitFontSize) { _ in applyLiveUpdate() }
        .onChange(of: singleDigitXAdjust) { _ in applyLiveUpdate() }
        .onChange(of: multiDigitXAdjust) { _ in applyLiveUpdate() }
        .onChange(of: singleDigitYOffset) { _ in applyLiveUpdate() }
        .onChange(of: multiDigitYOffset) { _ in applyLiveUpdate() }
        .onChange(of: textRectWidthAdjust) { _ in applyLiveUpdate() }
    }

    private func sliderRow(
        _ label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        format: String
    ) -> some View {
        HStack(spacing: 8) {
            Text(label)
            Slider(value: value, in: range)
            Text(String(format: format, value.wrappedValue))
                .font(.caption)
                .monospacedDigit()
                .frame(width: 58, alignment: .trailing)
        }
    }

    private func applyLiveUpdate() {
        AppDelegate.shared?.refreshMenuBarExtraForDebug()
    }
}

// MARK: - Background Debug Window

private final class BackgroundDebugWindowController: NSWindowController, NSWindowDelegate {
    static let shared = BackgroundDebugWindowController()

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 300),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = "Background Debug"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.identifier = NSUserInterfaceItemIdentifier("iatlas.backgroundDebug")
        window.center()
        window.contentView = IccFirstMouseHostingView(rootView: BackgroundDebugView())
        AppDelegate.shared?.applyWindowDecorations(to: window)
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct BackgroundDebugView: View {
    @AppStorage("bgGlassTintHex") private var bgGlassTintHex = "#000000"
    @AppStorage("bgGlassTintOpacity") private var bgGlassTintOpacity = 0.03
    @AppStorage("bgGlassMaterial") private var bgGlassMaterial = "hudWindow"
    @AppStorage("bgGlassEnabled") private var bgGlassEnabled = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Window Background Glass")
                    .font(.headline)

                GroupBox("Glass Effect") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Enable Glass Effect", isOn: $bgGlassEnabled)

                        Picker("Material", selection: $bgGlassMaterial) {
                            Text("HUD Window").tag("hudWindow")
                            Text("Under Window").tag("underWindowBackground")
                            Text("Sidebar").tag("sidebar")
                            Text("Menu").tag("menu")
                            Text("Popover").tag("popover")
                        }
                        .disabled(!bgGlassEnabled)
                    }
                    .padding(.top, 2)
                }

                GroupBox("Tint") {
                    VStack(alignment: .leading, spacing: 8) {
                        ColorPicker("Tint Color", selection: tintColorBinding, supportsOpacity: false)
                            .disabled(!bgGlassEnabled)

                        HStack(spacing: 8) {
                            Text("Opacity")
                            Slider(value: $bgGlassTintOpacity, in: 0...0.8)
                                .disabled(!bgGlassEnabled)
                            Text(String(format: "%.0f%%", bgGlassTintOpacity * 100))
                                .font(.caption)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .padding(.top, 2)
                }

                HStack(spacing: 12) {
                    Button("Reset") {
                        bgGlassTintHex = "#000000"
                        bgGlassTintOpacity = 0.03
                        bgGlassMaterial = "hudWindow"
                        bgGlassEnabled = false
                        updateWindowGlassTint()
                    }

                    Button("Copy Config") {
                        copyBgConfig()
                    }
                }

                Text("Tint changes apply live. Enable/disable requires reload.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .onChange(of: bgGlassTintHex) { _ in updateWindowGlassTint() }
        .onChange(of: bgGlassTintOpacity) { _ in updateWindowGlassTint() }
    }

    private func updateWindowGlassTint() {
        let window: NSWindow? = {
            if let key = NSApp.keyWindow,
               let raw = key.identifier?.rawValue,
               raw == "icc.main" || raw == "icc.main" || raw.hasPrefix("iatlas.main.") || raw.hasPrefix("icc.main.") {
                return key
            }
            return NSApp.windows.first(where: {
                guard let raw = $0.identifier?.rawValue else { return false }
                return raw == "icc.main" || raw == "icc.main" || raw.hasPrefix("iatlas.main.") || raw.hasPrefix("icc.main.")
            })
        }()
        guard let window else { return }
        let tintColor = (NSColor(hex: bgGlassTintHex) ?? .black).withAlphaComponent(bgGlassTintOpacity)
        WindowGlassEffect.updateTint(to: window, color: tintColor)
    }

    private var tintColorBinding: Binding<Color> {
        Binding(
            get: {
                Color(nsColor: NSColor(hex: bgGlassTintHex) ?? .black)
            },
            set: { newColor in
                let nsColor = NSColor(newColor)
                bgGlassTintHex = nsColor.hexString()
            }
        )
    }

    private func copyBgConfig() {
        let payload = """
        bgGlassEnabled=\(bgGlassEnabled)
        bgGlassMaterial=\(bgGlassMaterial)
        bgGlassTintHex=\(bgGlassTintHex)
        bgGlassTintOpacity=\(String(format: "%.2f", bgGlassTintOpacity))
        """
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(payload, forType: .string)
    }
}

private struct AboutPropertyRow: View {
    private let label: String
    private let text: String
    private let url: URL?

    init(label: String, text: String, url: URL? = nil) {
        self.label = label
        self.text = text
        self.url = url
    }

    @ViewBuilder private var textView: some View {
        Text(text)
            .frame(width: 140, alignment: .leading)
            .padding(.leading, 2)
            .tint(.secondary)
            .opacity(0.8)
            .monospaced()
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .frame(width: 126, alignment: .trailing)
                .padding(.trailing, 2)
            if let url {
                Link(destination: url) {
                    textView
                }
            } else {
                textView
            }
        }
        .font(.callout)
        .textSelection(.enabled)
        .frame(maxWidth: .infinity)
    }
}

private struct AboutVisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let isEmphasized: Bool

    init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        isEmphasized: Bool = false
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.isEmphasized = isEmphasized
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = isEmphasized
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffect = NSVisualEffectView()
        visualEffect.autoresizingMask = [.width, .height]
        return visualEffect
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    case auto

    var id: String { rawValue }

    static var visibleCases: [AppearanceMode] {
        [.system, .light, .dark]
    }

    var displayName: String {
        switch self {
        case .system:
            return String(localized: "appearance.system", defaultValue: "System")
        case .light:
            return String(localized: "appearance.light", defaultValue: "Light")
        case .dark:
            return String(localized: "appearance.dark", defaultValue: "Dark")
        case .auto:
            return String(localized: "appearance.auto", defaultValue: "Auto")
        }
    }
}

enum AppearanceSettings {
    static let appearanceModeKey = "appearanceMode"
    static let defaultMode: AppearanceMode = .system

    static func mode(for rawValue: String?) -> AppearanceMode {
        guard let rawValue, let mode = AppearanceMode(rawValue: rawValue) else {
            return defaultMode
        }
        if mode == .auto {
            return .system
        }
        return mode
    }

    @discardableResult
    static func resolvedMode(defaults: UserDefaults = .standard) -> AppearanceMode {
        let stored = defaults.string(forKey: appearanceModeKey)
        let resolved = mode(for: stored)
        if stored != resolved.rawValue {
            defaults.set(resolved.rawValue, forKey: appearanceModeKey)
        }
        return resolved
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case en
    case ar
    case bs
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case da
    case de
    case es
    case fr
    case it
    case ja
    case ko
    case nb
    case pl
    case ptBR = "pt-BR"
    case ru
    case th
    case tr

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return String(localized: "language.system", defaultValue: "System")
        case .en: return "English"
        case .ar: return "\u{200E}العربية (Arabic)"
        case .bs: return "Bosanski (Bosnian)"
        case .zhHans: return "简体中文 (Chinese Simplified)"
        case .zhHant: return "繁體中文 (Chinese Traditional)"
        case .da: return "Dansk (Danish)"
        case .de: return "Deutsch (German)"
        case .es: return "Español (Spanish)"
        case .fr: return "Français (French)"
        case .it: return "Italiano (Italian)"
        case .ja: return "日本語 (Japanese)"
        case .ko: return "한국어 (Korean)"
        case .nb: return "Norsk (Norwegian)"
        case .pl: return "Polski (Polish)"
        case .ptBR: return "Português (Brasil)"
        case .ru: return "Русский (Russian)"
        case .th: return "ไทย (Thai)"
        case .tr: return "Türkçe (Turkish)"
        }
    }
}

enum LanguageSettings {
    static let languageKey = "appLanguage"
    static let defaultLanguage: AppLanguage = .zhHans

    static func apply(_ language: AppLanguage) {
        if language == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        }
    }

    static var languageAtLaunch: AppLanguage = {
        let stored = UserDefaults.standard.string(forKey: languageKey)
        guard let stored, let lang = AppLanguage(rawValue: stored) else { return defaultLanguage }
        return lang
    }()
}

private enum PreferredChineseVariant {
    case none
    case simplified
    case traditional
}

private func preferredChineseVariant() -> PreferredChineseVariant {
    let languages = UserDefaults.standard.stringArray(forKey: "AppleLanguages") ?? Locale.preferredLanguages
    guard let first = languages.first?.lowercased() else { return .none }
    if first.hasPrefix("zh-hant") || first.contains("hant") || first.hasSuffix("-tw") || first.hasSuffix("-hk") {
        return .traditional
    }
    if first.hasPrefix("zh") {
        return .simplified
    }
    return .none
}

private func localizedSettingsText(
    _ key: String,
    english: String,
    simplifiedChinese: String,
    traditionalChinese: String? = nil
) -> String {
    let resolvedCandidate = NSLocalizedString(key, comment: "")
    let resolved = resolvedCandidate == key ? english : resolvedCandidate
    switch preferredChineseVariant() {
    case .simplified:
        return resolved == english ? simplifiedChinese : resolved
    case .traditional:
        return resolved == english ? (traditionalChinese ?? simplifiedChinese) : resolved
    case .none:
        return resolved
    }
}

private enum TerminalProfileImportSource: String, CaseIterable, Identifiable {
    case vscode
    case cursor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vscode:
            return "VS Code"
        case .cursor:
            return "Cursor"
        }
    }

    var settingsURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        switch self {
        case .vscode:
            return home.appendingPathComponent("Library/Application Support/Code/User/settings.json")
        case .cursor:
            return home.appendingPathComponent("Library/Application Support/Cursor/User/settings.json")
        }
    }
}

private enum AgentIntegrationInstallSource: String, CaseIterable, Identifiable {
    case claudeCode
    case codex

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claudeCode:
            return "Claude Code"
        case .codex:
            return "Codex"
        }
    }
}

private struct ImportedTerminalProfile {
    let fontFamily: String
    let fontSize: Double
    let backgroundHex: String
    let foregroundHex: String
    let cursorHex: String
    let cursorTextHex: String
    let selectionBackgroundHex: String
    let selectionForegroundHex: String
    let summary: String
}

enum AppIconMode: String, CaseIterable, Identifiable {
    case automatic
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .automatic: return String(localized: "appIcon.automatic", defaultValue: "Automatic")
        case .light: return String(localized: "appIcon.light", defaultValue: "Light")
        case .dark: return String(localized: "appIcon.dark", defaultValue: "Dark")
        }
    }

    var imageName: String? {
        switch self {
        case .automatic: return nil
        case .light: return "AppIconLight"
        case .dark: return "AppIconDark"
        }
    }
}

enum AppIconSettings {
    static let modeKey = "appIconMode"
    static let defaultMode: AppIconMode = .automatic

    static func resolvedMode(defaults: UserDefaults = .standard) -> AppIconMode {
        guard let raw = defaults.string(forKey: modeKey),
              let mode = AppIconMode(rawValue: raw) else {
            return defaultMode
        }
        return mode
    }

    static func applyIcon(_ mode: AppIconMode) {
        switch mode {
        case .automatic:
            // Let the asset catalog handle appearance-based icon selection (macOS 15+).
            // Reset to the default bundle icon.
            NSApplication.shared.applicationIconImage = nil
        case .light:
            if let icon = NSImage(named: "AppIconLight") {
                NSApplication.shared.applicationIconImage = icon
            }
        case .dark:
            if let icon = NSImage(named: "AppIconDark") {
                NSApplication.shared.applicationIconImage = icon
            }
        }
    }
}

enum QuitWarningSettings {
    static let warnBeforeQuitKey = "warnBeforeQuitShortcut"
    static let defaultWarnBeforeQuit = true

    static func isEnabled(defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: warnBeforeQuitKey) == nil {
            return defaultWarnBeforeQuit
        }
        return defaults.bool(forKey: warnBeforeQuitKey)
    }

    static func setEnabled(_ isEnabled: Bool, defaults: UserDefaults = .standard) {
        defaults.set(isEnabled, forKey: warnBeforeQuitKey)
    }
}

enum CommandPaletteRenameSelectionSettings {
    static let selectAllOnFocusKey = "commandPalette.renameSelectAllOnFocus"
    static let defaultSelectAllOnFocus = true

    static func selectAllOnFocusEnabled(defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: selectAllOnFocusKey) == nil {
            return defaultSelectAllOnFocus
        }
        return defaults.bool(forKey: selectAllOnFocusKey)
    }
}

enum CommandPaletteSwitcherSearchSettings {
    static let searchAllSurfacesKey = "commandPalette.switcherSearchAllSurfaces"
    static let defaultSearchAllSurfaces = false

    static func searchAllSurfacesEnabled(defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: searchAllSurfacesKey) == nil {
            return defaultSearchAllSurfaces
        }
        return defaults.bool(forKey: searchAllSurfacesKey)
    }
}

enum ClaudeCodeIntegrationSettings {
    static let hooksEnabledKey = "claudeCodeHooksEnabled"
    static let defaultHooksEnabled = true

    static func hooksEnabled(defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: hooksEnabledKey) == nil {
            return defaultHooksEnabled
        }
        return defaults.bool(forKey: hooksEnabledKey)
    }
}

enum WeChatChannelSettings {
    static let defaultsKey = "wechat.channel.configuration.v1"
}

enum WeChatBotTokenStore {
    static let serviceName = "com.icc.app.wechat.bot-token"

    static func loadToken(for accountId: UUID) -> String? {
#if canImport(Security)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: accountId.uuidString,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
#else
        return nil
#endif
    }

    static func hasToken(for accountId: UUID) -> Bool {
        guard let token = loadToken(for: accountId) else { return false }
        return !token.isEmpty
    }

    static func saveToken(_ token: String, for accountId: UUID) throws {
#if canImport(Security)
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            try clearToken(for: accountId)
            return
        }
        let data = Data(trimmed.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: accountId.uuidString,
        ]
        let attributes: [CFString: Any] = [
            kSecValueData: data,
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }
        guard updateStatus == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(updateStatus))
        }
        var createQuery = query
        createQuery[kSecValueData] = data
        let addStatus = SecItemAdd(createQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(addStatus))
        }
#endif
    }

    static func clearToken(for accountId: UUID) throws {
#if canImport(Security)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: accountId.uuidString,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
#endif
    }
}

enum WeChatAccountConnectionState: String, Codable, CaseIterable, Identifiable {
    case draft
    case qrReady
    case connected
    case paused

    var id: String { rawValue }

    var label: String {
        switch self {
        case .draft:
            return localizedSettingsText(
                "settings.wechat.state.draft",
                english: "Draft",
                simplifiedChinese: "草稿",
                traditionalChinese: "草稿"
            )
        case .qrReady:
            return localizedSettingsText(
                "settings.wechat.state.qrReady",
                english: "Waiting for Scan",
                simplifiedChinese: "等待扫码",
                traditionalChinese: "等待掃碼"
            )
        case .connected:
            return localizedSettingsText(
                "settings.wechat.state.connected",
                english: "Connected",
                simplifiedChinese: "已连接",
                traditionalChinese: "已連線"
            )
        case .paused:
            return localizedSettingsText(
                "settings.wechat.state.paused",
                english: "Paused",
                simplifiedChinese: "已暂停",
                traditionalChinese: "已暫停"
            )
        }
    }
}

enum WeChatBindingDestinationKind: String, Codable, Hashable {
    case unbound
    case autoCreateWindow
    case window
    case workspace
}

struct WeChatBindingDestination: Codable, Equatable, Hashable {
    var kind: WeChatBindingDestinationKind = .unbound
    var windowId: UUID?
    var workspaceId: UUID?

    static let unbound = WeChatBindingDestination(kind: .unbound, windowId: nil, workspaceId: nil)
    static let autoCreateWindow = WeChatBindingDestination(kind: .autoCreateWindow, windowId: nil, workspaceId: nil)
}

struct WeChatConversationBinding: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var sessionId: String
    var contactLabel: String
    var contextTokenHint: String
    var destination: WeChatBindingDestination
    var sendTypingIndicator = true
}

struct WeChatBotAccountConfiguration: Codable, Identifiable, Equatable {
    var id = UUID()
    var displayName: String
    var botId: String
    var userId: String
    var baseURLString: String
    var routeTag: String
    var tokenHint: String
    var isEnabled = true
    var connectionState: WeChatAccountConnectionState = .draft
    var bindings: [WeChatConversationBinding] = []
}

struct WeChatChannelConfiguration: Codable, Equatable {
    var integrationEnabled = false
    var autoCreateWindowForNewChats = true
    var sendTypingWhileWorking = true
    var mirrorWindowProgressIntoReplies = true
    var accounts: [WeChatBotAccountConfiguration] = []

    static let empty = WeChatChannelConfiguration()
}

@MainActor
final class WeChatChannelSettingsStore: ObservableObject {
    static let shared = WeChatChannelSettingsStore()

    @Published var configuration: WeChatChannelConfiguration {
        didSet { persist() }
    }

    init(defaults: UserDefaults = .standard) {
        if let data = defaults.data(forKey: WeChatChannelSettings.defaultsKey),
           let decoded = try? JSONDecoder().decode(WeChatChannelConfiguration.self, from: data) {
            configuration = decoded
        } else {
            configuration = .empty
        }
    }

    func addAccount() {
        var updated = configuration
        updated.accounts.append(
            WeChatBotAccountConfiguration(
                displayName: localizedSettingsText(
                    "settings.wechat.account.defaultName",
                    english: "WeChat Bot",
                    simplifiedChinese: "微信机器人",
                    traditionalChinese: "微信機器人"
                ),
                botId: "",
                userId: "",
                baseURLString: "https://ilinkai.weixin.qq.com",
                routeTag: "",
                tokenHint: "",
                bindings: [
                    WeChatConversationBinding(
                        title: localizedSettingsText(
                            "settings.wechat.binding.defaultTitle",
                            english: "Default Chat Route",
                            simplifiedChinese: "默认聊天路由",
                            traditionalChinese: "預設聊天路由"
                        ),
                        sessionId: "",
                        contactLabel: "",
                        contextTokenHint: "",
                        destination: .autoCreateWindow
                    )
                ]
            )
        )
        configuration = updated
    }

    func removeAccount(_ accountId: UUID) {
        configuration.accounts.removeAll { $0.id == accountId }
    }

    func updateAccount(_ accountId: UUID, mutate: (inout WeChatBotAccountConfiguration) -> Void) {
        guard let index = configuration.accounts.firstIndex(where: { $0.id == accountId }) else { return }
        var updated = configuration
        mutate(&updated.accounts[index])
        configuration = updated
    }

    func addBinding(to accountId: UUID) {
        updateAccount(accountId) { account in
            account.bindings.append(
                WeChatConversationBinding(
                    title: localizedSettingsText(
                        "settings.wechat.binding.newTitle",
                        english: "New Chat Route",
                        simplifiedChinese: "新聊天路由",
                        traditionalChinese: "新聊天路由"
                    ),
                    sessionId: "",
                    contactLabel: "",
                    contextTokenHint: "",
                    destination: account.bindings.isEmpty ? .autoCreateWindow : .unbound
                )
            )
        }
    }

    func removeBinding(accountId: UUID, bindingId: UUID) {
        updateAccount(accountId) { account in
            account.bindings.removeAll { $0.id == bindingId }
        }
    }

    func updateBinding(accountId: UUID, bindingId: UUID, mutate: (inout WeChatConversationBinding) -> Void) {
        updateAccount(accountId) { account in
            guard let index = account.bindings.firstIndex(where: { $0.id == bindingId }) else { return }
            mutate(&account.bindings[index])
        }
    }

    private func persist(defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        defaults.set(data, forKey: WeChatChannelSettings.defaultsKey)
    }
}

struct WeChatBindingTargetOption: Identifiable, Hashable {
    let id: String
    let label: String
    let destination: WeChatBindingDestination
}

@MainActor
final class WeChatBindingTargetCatalog: ObservableObject {
    static let shared = WeChatBindingTargetCatalog()

    @Published private(set) var options: [WeChatBindingTargetOption] = []
    private var observer: NSObjectProtocol?

    init() {
        refresh()
        observer = NotificationCenter.default.addObserver(
            forName: .mainWindowContextsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func refresh() {
        var nextOptions: [WeChatBindingTargetOption] = [
            WeChatBindingTargetOption(
                id: "unbound",
                label: localizedSettingsText(
                    "settings.wechat.destination.unbound",
                    english: "Unbound",
                    simplifiedChinese: "未绑定",
                    traditionalChinese: "未綁定"
                ),
                destination: .unbound
            ),
            WeChatBindingTargetOption(
                id: "auto",
                label: localizedSettingsText(
                    "settings.wechat.destination.auto",
                    english: "Auto-create a Window on First Message",
                    simplifiedChinese: "首次消息自动创建窗口",
                    traditionalChinese: "首次訊息自動建立視窗"
                ),
                destination: .autoCreateWindow
            ),
        ]

        if let appDelegate = AppDelegate.shared {
            let windows = appDelegate.windowMoveTargets(referenceWindowId: nil)
            let workspaces = appDelegate.workspaceMoveTargets(referenceWindowId: nil)

            nextOptions.append(contentsOf: windows.map { target in
                WeChatBindingTargetOption(
                    id: "window:\(target.windowId.uuidString)",
                    label: localizedSettingsText(
                        "settings.wechat.destination.windowPrefix",
                        english: "Window",
                        simplifiedChinese: "窗口",
                        traditionalChinese: "視窗"
                    ) + " · " + target.label,
                    destination: WeChatBindingDestination(kind: .window, windowId: target.windowId, workspaceId: nil)
                )
            })

            nextOptions.append(contentsOf: workspaces.map { target in
                WeChatBindingTargetOption(
                    id: "workspace:\(target.windowId.uuidString):\(target.workspaceId.uuidString)",
                    label: localizedSettingsText(
                        "settings.wechat.destination.workspacePrefix",
                        english: "Workspace",
                        simplifiedChinese: "工作区",
                        traditionalChinese: "工作區"
                    ) + " · " + target.label,
                    destination: WeChatBindingDestination(kind: .workspace, windowId: target.windowId, workspaceId: target.workspaceId)
                )
            })
        }

        options = nextOptions
    }

    func optionId(for destination: WeChatBindingDestination) -> String {
        switch destination.kind {
        case .unbound:
            return "unbound"
        case .autoCreateWindow:
            return "auto"
        case .window:
            return destination.windowId.map { "window:\($0.uuidString)" } ?? "unbound"
        case .workspace:
            if let windowId = destination.windowId, let workspaceId = destination.workspaceId {
                return "workspace:\(windowId.uuidString):\(workspaceId.uuidString)"
            }
            return "unbound"
        }
    }

    func destination(for optionId: String) -> WeChatBindingDestination {
        options.first(where: { $0.id == optionId })?.destination ?? .unbound
    }
}

enum WelcomeSettings {
    static let shownKey = "iccWelcomeShown"
}

enum TelemetrySettings {
    static let sendAnonymousTelemetryKey = "sendAnonymousTelemetry"
    static let defaultSendAnonymousTelemetry = true

    static func isEnabled(defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: sendAnonymousTelemetryKey) == nil {
            return defaultSendAnonymousTelemetry
        }
        return defaults.bool(forKey: sendAnonymousTelemetryKey)
    }

    // Freeze telemetry enablement once per launch. Settings changes apply on next restart.
    static let enabledForCurrentLaunch = isEnabled()
}

struct SettingsView: View {
    private let contentTopInset: CGFloat = 8
    private let pickerColumnWidth: CGFloat = 196
    private let notificationSoundControlWidth: CGFloat = 280
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(LanguageSettings.languageKey) private var appLanguage = LanguageSettings.defaultLanguage.rawValue
    @AppStorage(AppearanceSettings.appearanceModeKey) private var appearanceMode = AppearanceSettings.defaultMode.rawValue
    @AppStorage(AppIconSettings.modeKey) private var appIconMode = AppIconSettings.defaultMode.rawValue
    @AppStorage(WorkspacePresentationModeSettings.modeKey)
    private var workspacePresentationMode = WorkspacePresentationModeSettings.defaultMode.rawValue
    @AppStorage(SocketControlSettings.appStorageKey) private var socketControlMode = SocketControlSettings.defaultMode.rawValue
    @AppStorage(ClaudeCodeIntegrationSettings.hooksEnabledKey)
    private var claudeCodeHooksEnabled = ClaudeCodeIntegrationSettings.defaultHooksEnabled
    @AppStorage(TelemetrySettings.sendAnonymousTelemetryKey)
    private var sendAnonymousTelemetry = TelemetrySettings.defaultSendAnonymousTelemetry
    @AppStorage("iccPortBase") private var iccPortBase = 9100
    @AppStorage("iccPortRange") private var iccPortRange = 10
    @AppStorage(BrowserSearchSettings.searchEngineKey) private var browserSearchEngine = BrowserSearchSettings.defaultSearchEngine.rawValue
    @AppStorage(BrowserSearchSettings.searchSuggestionsEnabledKey) private var browserSearchSuggestionsEnabled = BrowserSearchSettings.defaultSearchSuggestionsEnabled
    @AppStorage(BrowserThemeSettings.modeKey) private var browserThemeMode = BrowserThemeSettings.defaultMode.rawValue
    @AppStorage(BrowserImportHintSettings.variantKey) private var browserImportHintVariantRaw = BrowserImportHintSettings.defaultVariant.rawValue
    @AppStorage(BrowserImportHintSettings.showOnBlankTabsKey) private var showBrowserImportHintOnBlankTabs = BrowserImportHintSettings.defaultShowOnBlankTabs
    @AppStorage(BrowserImportHintSettings.dismissedKey) private var isBrowserImportHintDismissed = BrowserImportHintSettings.defaultDismissed
    @AppStorage(BrowserLinkOpenSettings.openTerminalLinksInIccBrowserKey) private var openTerminalLinksInIccBrowser = BrowserLinkOpenSettings.defaultOpenTerminalLinksInIccBrowser
    @AppStorage(BrowserLinkOpenSettings.interceptTerminalOpenCommandInIccBrowserKey)
    private var interceptTerminalOpenCommandInIccBrowser = BrowserLinkOpenSettings.initialInterceptTerminalOpenCommandInIccBrowserValue()
    @AppStorage(BrowserLinkOpenSettings.browserHostWhitelistKey) private var browserHostWhitelist = BrowserLinkOpenSettings.defaultBrowserHostWhitelist
    @AppStorage(BrowserLinkOpenSettings.browserExternalOpenPatternsKey)
    private var browserExternalOpenPatterns = BrowserLinkOpenSettings.defaultBrowserExternalOpenPatterns
    @AppStorage(BrowserInsecureHTTPSettings.allowlistKey) private var browserInsecureHTTPAllowlist = BrowserInsecureHTTPSettings.defaultAllowlistText
    @AppStorage(NotificationSoundSettings.key) private var notificationSound = NotificationSoundSettings.defaultValue
    @AppStorage(NotificationSoundSettings.customFilePathKey)
    private var notificationSoundCustomFilePath = NotificationSoundSettings.defaultCustomFilePath
    @AppStorage(NotificationSoundSettings.customCommandKey) private var notificationCustomCommand = NotificationSoundSettings.defaultCustomCommand
    @AppStorage(NotificationBadgeSettings.dockBadgeEnabledKey) private var notificationDockBadgeEnabled = NotificationBadgeSettings.defaultDockBadgeEnabled
    @AppStorage(NotificationPaneRingSettings.enabledKey) private var notificationPaneRingEnabled = NotificationPaneRingSettings.defaultEnabled
    @AppStorage(NotificationPaneFlashSettings.enabledKey) private var notificationPaneFlashEnabled = NotificationPaneFlashSettings.defaultEnabled
    @AppStorage(MenuBarExtraSettings.showInMenuBarKey) private var showMenuBarExtra = MenuBarExtraSettings.defaultShowInMenuBar
    @AppStorage(QuitWarningSettings.warnBeforeQuitKey) private var warnBeforeQuitShortcut = QuitWarningSettings.defaultWarnBeforeQuit
    @AppStorage(CommandPaletteRenameSelectionSettings.selectAllOnFocusKey)
    private var commandPaletteRenameSelectAllOnFocus = CommandPaletteRenameSelectionSettings.defaultSelectAllOnFocus
    @AppStorage(CommandPaletteSwitcherSearchSettings.searchAllSurfacesKey)
    private var commandPaletteSearchAllSurfaces = CommandPaletteSwitcherSearchSettings.defaultSearchAllSurfaces
    @AppStorage(ShortcutHintDebugSettings.alwaysShowHintsKey)
    private var alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
    @AppStorage(WorkspacePlacementSettings.placementKey) private var newWorkspacePlacement = WorkspacePlacementSettings.defaultPlacement.rawValue
    @AppStorage(LastSurfaceCloseShortcutSettings.key)
    private var closeWorkspaceOnLastSurfaceShortcut = LastSurfaceCloseShortcutSettings.defaultValue
    @AppStorage(PaneFirstClickFocusSettings.enabledKey)
    private var paneFirstClickFocusEnabled = PaneFirstClickFocusSettings.defaultEnabled
    @AppStorage(WorkspaceAutoReorderSettings.key) private var workspaceAutoReorder = WorkspaceAutoReorderSettings.defaultValue
    @AppStorage(SidebarWorkspaceDetailSettings.hideAllDetailsKey)
    private var sidebarHideAllDetails = SidebarWorkspaceDetailSettings.defaultHideAllDetails
    @AppStorage(SidebarWorkspaceDetailSettings.showNotificationMessageKey)
    private var sidebarShowNotificationMessage = SidebarWorkspaceDetailSettings.defaultShowNotificationMessage
    @AppStorage(SidebarBranchLayoutSettings.key) private var sidebarBranchVerticalLayout = SidebarBranchLayoutSettings.defaultVerticalLayout
    @AppStorage(SidebarActiveTabIndicatorSettings.styleKey)
    private var sidebarActiveTabIndicatorStyle = SidebarActiveTabIndicatorSettings.defaultStyle.rawValue
    @AppStorage("sidebarShowBranchDirectory") private var sidebarShowBranchDirectory = true
    @AppStorage("sidebarShowPullRequest") private var sidebarShowPullRequest = true
    @AppStorage(BrowserLinkOpenSettings.openSidebarPullRequestLinksInIccBrowserKey)
    private var openSidebarPullRequestLinksInIccBrowser = BrowserLinkOpenSettings.defaultOpenSidebarPullRequestLinksInIccBrowser
    @AppStorage(ShortcutHintDebugSettings.showHintsOnCommandHoldKey)
    private var showShortcutHintsOnCommandHold = ShortcutHintDebugSettings.defaultShowHintsOnCommandHold
    @AppStorage("sidebarShowSSH") private var sidebarShowSSH = true
    @AppStorage(RemoteSSHTermMode.appStorageKey) private var remoteSSHTermModeRaw = RemoteSSHTermMode.defaultValue.rawValue
    @AppStorage("sidebarShowPorts") private var sidebarShowPorts = true
    @AppStorage("sidebarShowLog") private var sidebarShowLog = true
    @AppStorage("sidebarShowProgress") private var sidebarShowProgress = true
    @AppStorage("sidebarShowStatusPills") private var sidebarShowMetadata = true
    @AppStorage("sidebarTintHex") private var sidebarTintHex = SidebarTintDefaults.hex
    @AppStorage("sidebarTintHexLight") private var sidebarTintHexLight: String?
    @AppStorage("sidebarTintHexDark") private var sidebarTintHexDark: String?
    @AppStorage("sidebarTintOpacity") private var sidebarTintOpacity = SidebarTintDefaults.opacity

    @ObservedObject private var notificationStore = TerminalNotificationStore.shared
    @ObservedObject private var weChatChannelStore = WeChatChannelSettingsStore.shared
    @ObservedObject private var weChatBindingCatalog = WeChatBindingTargetCatalog.shared
    @State private var shortcutResetToken = UUID()
    @State private var topBlurOpacity: Double = 0
    @State private var topBlurBaselineOffset: CGFloat?
    @State private var settingsTitleLeadingInset: CGFloat = 92
    @State private var showClearBrowserHistoryConfirmation = false
    @State private var showOpenAccessConfirmation = false
    @State private var pendingOpenAccessMode: SocketControlMode?
    @State private var browserHistoryEntryCount: Int = 0
    @State private var detectedImportBrowsers: [InstalledBrowserCandidate] = []
    @State private var browserInsecureHTTPAllowlistDraft = BrowserInsecureHTTPSettings.defaultAllowlistText
    @State private var socketPasswordDraft = ""
    @State private var socketPasswordStatusMessage: String?
    @State private var socketPasswordStatusIsError = false
    @State private var quickImportStatusMessage: String?
    @State private var quickImportStatusIsError = false
    @State private var notificationCustomSoundStatusMessage: String?
    @State private var notificationCustomSoundStatusIsError = false
    @State private var showNotificationCustomSoundErrorAlert = false
    @State private var notificationCustomSoundErrorAlertMessage = ""
    @State private var telemetryValueAtLaunch = TelemetrySettings.enabledForCurrentLaunch
    @State private var showLanguageRestartAlert = false
    @State private var isResettingSettings = false
    @State private var workspaceTabDefaultEntries = WorkspaceTabColorSettings.defaultPaletteWithOverrides()
    @State private var workspaceTabCustomColors = WorkspaceTabColorSettings.customColors()
    @State private var selectedSettingsSection: SettingsSidebarSection = .app
    @State private var expandedWeChatAccountIds: Set<UUID> = []
    @State private var expandedWeChatBindingIds: Set<UUID> = []
    @State private var weChatBotTokenDrafts: [UUID: String] = [:]
    @State private var weChatAccountStatusMessages: [UUID: String] = [:]
    @State private var weChatAccountStatusErrors: Set<UUID> = []

    private var selectedWorkspacePlacement: NewWorkspacePlacement {
        NewWorkspacePlacement(rawValue: newWorkspacePlacement) ?? WorkspacePlacementSettings.defaultPlacement
    }

    private var minimalModeEnabled: Bool {
        WorkspacePresentationModeSettings.mode(for: workspacePresentationMode) == .minimal
    }

    private var minimalModeSubtitle: String {
        if minimalModeEnabled {
            return localizedSettingsText(
                "settings.app.minimalMode.subtitleOn",
                english: "Hide the workspace title bar and move workspace controls into the sidebar.",
                simplifiedChinese: "隐藏工作区标题栏，并把工作区控制项移到侧边栏。",
                traditionalChinese: "隱藏工作區標題列，並把工作區控制項移到側邊欄。"
            )
        }
        return localizedSettingsText(
            "settings.app.minimalMode.subtitleOff",
            english: "Use the standard workspace title bar and controls.",
            simplifiedChinese: "使用标准工作区标题栏和控制项。",
            traditionalChinese: "使用標準工作區標題列與控制項。"
        )
    }

    private var keepWorkspaceOpenOnLastSurfaceShortcut: Bool {
        !closeWorkspaceOnLastSurfaceShortcut
    }

    private var keepWorkspaceOpenOnLastSurfaceShortcutBinding: Binding<Bool> {
        Binding(
            get: { keepWorkspaceOpenOnLastSurfaceShortcut },
            set: { closeWorkspaceOnLastSurfaceShortcut = !$0 }
        )
    }

    private var closeWorkspaceOnLastSurfaceShortcutSubtitle: String {
        if keepWorkspaceOpenOnLastSurfaceShortcut {
            return localizedSettingsText(
                "settings.app.closeWorkspaceOnLastSurfaceShortcut.subtitleOn",
                english: "When the focused surface is the last one in its workspace, the close-surface shortcut closes only the surface and keeps the workspace open. Use the close-workspace shortcut to close the workspace explicitly.",
                simplifiedChinese: "当当前面板是工作区中的最后一个时，关闭面板快捷键只关闭面板，不关闭工作区。如需关闭工作区，请使用关闭工作区快捷键。",
                traditionalChinese: "當目前面板是工作區中的最後一個時，關閉面板快捷鍵只會關閉面板，不會關閉工作區。如需關閉工作區，請使用關閉工作區快捷鍵。"
            )
        }
        return localizedSettingsText(
            "settings.app.closeWorkspaceOnLastSurfaceShortcut.subtitleOff",
            english: "When the focused surface is the last one in its workspace, the close-surface shortcut also closes the workspace.",
            simplifiedChinese: "当当前面板是工作区中的最后一个时，关闭面板快捷键会同时关闭工作区。",
            traditionalChinese: "當目前面板是工作區中的最後一個時，關閉面板快捷鍵會同時關閉工作區。"
        )
    }

    private var paneFirstClickFocusSubtitle: String {
        if paneFirstClickFocusEnabled {
            return localizedSettingsText(
                "settings.app.paneFirstClickFocus.subtitleOn",
                english: "When icc is inactive, clicking a pane activates the window and focuses that pane in one click.",
                simplifiedChinese: "当 icc 未激活时，点击面板会同时激活窗口并聚焦该面板。",
                traditionalChinese: "當 icc 未啟用時，點擊面板會同時啟用視窗並聚焦該面板。"
            )
        }
        return localizedSettingsText(
            "settings.app.paneFirstClickFocus.subtitleOff",
            english: "When icc is inactive, the first click only activates the window. Click again to focus the pane.",
            simplifiedChinese: "当 icc 未激活时，第一次点击只会激活窗口；再次点击才会聚焦面板。",
            traditionalChinese: "當 icc 未啟用時，第一次點擊只會啟用視窗；再次點擊才會聚焦面板。"
        )
    }

    private var selectedSidebarActiveTabIndicatorStyle: SidebarActiveTabIndicatorStyle {
        SidebarActiveTabIndicatorSettings.resolvedStyle(rawValue: sidebarActiveTabIndicatorStyle)
    }

    private var sidebarIndicatorStyleSelection: Binding<String> {
        Binding(
            get: { selectedSidebarActiveTabIndicatorStyle.rawValue },
            set: { sidebarActiveTabIndicatorStyle = $0 }
        )
    }

    private var selectedSocketControlMode: SocketControlMode {
        SocketControlSettings.migrateMode(socketControlMode)
    }

    private var selectedBrowserThemeMode: BrowserThemeMode {
        BrowserThemeSettings.mode(for: browserThemeMode)
    }

    private var browserThemeModeSelection: Binding<String> {
        Binding(
            get: { browserThemeMode },
            set: { newValue in
                browserThemeMode = BrowserThemeSettings.mode(for: newValue).rawValue
            }
        )
    }

    private var browserImportHintVariant: BrowserImportHintVariant {
        BrowserImportHintSettings.variant(for: browserImportHintVariantRaw)
    }

    private var browserImportHintPresentation: BrowserImportHintPresentation {
        BrowserImportHintPresentation(
            variant: browserImportHintVariant,
            showOnBlankTabs: showBrowserImportHintOnBlankTabs,
            isDismissed: isBrowserImportHintDismissed
        )
    }

    private var browserImportHintVisibilityBinding: Binding<Bool> {
        Binding(
            get: { showBrowserImportHintOnBlankTabs },
            set: { newValue in
                showBrowserImportHintOnBlankTabs = newValue
                if newValue {
                    isBrowserImportHintDismissed = false
                }
            }
        )
    }

    private var socketModeSelection: Binding<String> {
        Binding(
            get: { socketControlMode },
            set: { newValue in
                let normalized = SocketControlSettings.migrateMode(newValue)
                if normalized == .allowAll && selectedSocketControlMode != .allowAll {
                    pendingOpenAccessMode = normalized
                    showOpenAccessConfirmation = true
                    return
                }
                socketControlMode = normalized.rawValue
                if normalized != .password {
                    socketPasswordStatusMessage = nil
                    socketPasswordStatusIsError = false
                }
            }
        )
    }

    private var minimalModeBinding: Binding<Bool> {
        Binding(
            get: { minimalModeEnabled },
            set: { newValue in
                workspacePresentationMode = newValue
                    ? WorkspacePresentationModeSettings.Mode.minimal.rawValue
                    : WorkspacePresentationModeSettings.Mode.standard.rawValue
                SettingsWindowController.shared.preserveFocusAfterPreferenceMutation()
            }
        )
    }

    private var settingsSidebarTintLightBinding: Binding<Color> {
        Binding(
            get: {
                Color(nsColor: NSColor(hex: sidebarTintHexLight ?? sidebarTintHex) ?? .black)
            },
            set: { newColor in
                let nsColor = NSColor(newColor)
                sidebarTintHexLight = nsColor.hexString()
            }
        )
    }

    private var settingsSidebarTintDarkBinding: Binding<Color> {
        Binding(
            get: {
                Color(nsColor: NSColor(hex: sidebarTintHexDark ?? sidebarTintHex) ?? .black)
            },
            set: { newColor in
                let nsColor = NSColor(newColor)
                sidebarTintHexDark = nsColor.hexString()
            }
        )
    }

    private var hasSocketPasswordConfigured: Bool {
        SocketControlPasswordStore.hasConfiguredPassword()
    }

    private var browserHistorySubtitle: String {
        switch browserHistoryEntryCount {
        case 0:
            return String(localized: "settings.browser.history.subtitleEmpty", defaultValue: "No saved pages yet.")
        case 1:
            return String(localized: "settings.browser.history.subtitleOne", defaultValue: "1 saved page appears in omnibar suggestions.")
        default:
            return String(localized: "settings.browser.history.subtitleMany", defaultValue: "\(browserHistoryEntryCount) saved pages appear in omnibar suggestions.")
        }
    }

    private var browserImportSubtitle: String {
        InstalledBrowserDetector.summaryText(for: detectedImportBrowsers)
    }

    private var browserImportHintSettingsNote: String {
        switch browserImportHintPresentation.settingsStatus {
        case .visible:
            return String(localized: "settings.browser.import.hint.note.visible", defaultValue: "Blank browser tabs can show this import suggestion. Hide or re-enable it here.")
        case .hidden:
            return String(localized: "settings.browser.import.hint.note.hidden", defaultValue: "The blank-tab import hint is hidden. Turn it back on here any time.")
        case .settingsOnly:
            return String(localized: "settings.browser.import.hint.note.settingsOnly", defaultValue: "Blank tabs are currently using Settings only mode from the debug window.")
        }
    }

    private var browserInsecureHTTPAllowlistHasUnsavedChanges: Bool {
        browserInsecureHTTPAllowlistDraft != browserInsecureHTTPAllowlist
    }

    private var hasCustomNotificationSoundFilePath: Bool {
        !notificationSoundCustomFilePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var notificationSoundCustomFileDisplayName: String {
        guard hasCustomNotificationSoundFilePath else {
            return String(
                localized: "settings.notifications.sound.custom.file.none",
                defaultValue: "No file selected"
            )
        }
        return URL(fileURLWithPath: notificationSoundCustomFilePath).lastPathComponent
    }

    private var canPreviewNotificationSound: Bool {
        switch notificationSound {
        case "none":
            return false
        case NotificationSoundSettings.customFileValue:
            return hasCustomNotificationSoundFilePath
        default:
            return true
        }
    }

    private var notificationPermissionStatusText: String {
        notificationStore.authorizationState.statusLabel
    }

    private var notificationPermissionStatusColor: Color {
        switch notificationStore.authorizationState {
        case .authorized, .provisional, .ephemeral:
            return .green
        case .denied:
            return .red
        case .unknown, .notDetermined:
            return .secondary
        }
    }

    private var notificationPermissionSubtitle: String {
        switch notificationStore.authorizationState {
        case .unknown, .notDetermined:
            return localizedSettingsText("settings.notifications.desktop.subtitle.unknown", english: "Desktop notifications are not enabled yet.", simplifiedChinese: "桌面通知尚未启用。", traditionalChinese: "桌面通知尚未啟用。")
        case .authorized:
            return localizedSettingsText("settings.notifications.desktop.subtitle.authorized", english: "Desktop notifications are enabled.", simplifiedChinese: "桌面通知已启用。", traditionalChinese: "桌面通知已啟用。")
        case .denied:
            return localizedSettingsText("settings.notifications.desktop.subtitle.denied", english: "Desktop notifications are disabled in System Settings.", simplifiedChinese: "桌面通知已在系统设置中关闭。", traditionalChinese: "桌面通知已在系統設定中關閉。")
        case .provisional:
            return localizedSettingsText("settings.notifications.desktop.subtitle.provisional", english: "Desktop notifications are enabled with quiet delivery.", simplifiedChinese: "桌面通知已启用，当前为安静投递。", traditionalChinese: "桌面通知已啟用，目前為安靜投遞。")
        case .ephemeral:
            return localizedSettingsText("settings.notifications.desktop.subtitle.ephemeral", english: "Desktop notifications are temporarily enabled.", simplifiedChinese: "桌面通知已临时启用。", traditionalChinese: "桌面通知已暫時啟用。")
        }
    }

    private var notificationPermissionActionTitle: String {
        switch notificationStore.authorizationState {
        case .unknown, .notDetermined:
            return localizedSettingsText("settings.notifications.desktop.action.enable", english: "Enable", simplifiedChinese: "启用", traditionalChinese: "啟用")
        case .authorized, .denied, .provisional, .ephemeral:
            return localizedSettingsText("settings.notifications.desktop.action.openSettings", english: "Open Settings", simplifiedChinese: "打开设置", traditionalChinese: "打開設定")
        }
    }

    private var selectedSidebarColorPreset: SidebarColorPreset? {
        let currentLight = (sidebarTintHexLight ?? sidebarTintHex).uppercased()
        let currentDark = (sidebarTintHexDark ?? sidebarTintHex).uppercased()
        return SidebarColorPreset.allCases.first { preset in
            currentLight == preset.lightHex && currentDark == preset.darkHex && abs(sidebarTintOpacity - preset.opacity) < 0.01
        }
    }

    private func applySidebarColorPreset(_ preset: SidebarColorPreset) {
        sidebarTintHex = preset.darkHex
        sidebarTintHexLight = preset.lightHex
        sidebarTintHexDark = preset.darkHex
        sidebarTintOpacity = preset.opacity
    }

    private func blurOpacity(forContentOffset offset: CGFloat) -> Double {
        guard let baseline = topBlurBaselineOffset else { return 0 }
        let reveal = (baseline - offset) / 24
        return Double(min(max(reveal, 0), 1))
    }

    private func previewNotificationSound() {
        if notificationSound == NotificationSoundSettings.customFileValue {
            NotificationSoundSettings.playCustomFileSound(path: notificationSoundCustomFilePath)
            return
        }
        NotificationSoundSettings.previewSound(value: notificationSound)
    }

    private func notificationCustomSoundIssueMessage(_ issue: NotificationSoundSettings.CustomSoundPreparationIssue) -> String {
        switch issue {
        case .emptyPath:
            return String(
                localized: "settings.notifications.sound.custom.status.empty",
                defaultValue: "Choose a custom audio file first."
            )
        case .missingFile(let path):
            let fileName = URL(fileURLWithPath: path).lastPathComponent
            return String(
                localized: "settings.notifications.sound.custom.status.missingFilePrefix",
                defaultValue: "File not found: "
            ) + fileName
        case .missingFileExtension(let path):
            let fileName = URL(fileURLWithPath: path).lastPathComponent
            return String(
                localized: "settings.notifications.sound.custom.status.missingExtensionPrefix",
                defaultValue: "File needs an extension: "
            ) + fileName
        case .stagingFailed(_, let details):
            let prefix = String(
                localized: "settings.notifications.sound.custom.status.prepareFailed",
                defaultValue: "Could not prepare this file for notifications. Try WAV, AIFF, or CAF."
            )
            return "\(prefix) (\(details))"
        }
    }

    private func notificationCustomSoundReadyStatusMessage(for path: String) -> String {
        let sourceExtension = URL(fileURLWithPath: path).pathExtension
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let stagedExtension = NotificationSoundSettings.stagedCustomSoundFileExtension(forSourceExtension: sourceExtension)
        if !sourceExtension.isEmpty, stagedExtension != sourceExtension {
            return String(
                localized: "settings.notifications.sound.custom.status.readyConverted",
                defaultValue: "Prepared for notifications (converted to CAF)."
            )
        }
        return String(
            localized: "settings.notifications.sound.custom.status.ready",
            defaultValue: "Ready for notifications."
        )
    }

    private func refreshNotificationCustomSoundStatus(showAlertOnFailure: Bool = false) {
        guard notificationSound == NotificationSoundSettings.customFileValue else {
            notificationCustomSoundStatusMessage = nil
            notificationCustomSoundStatusIsError = false
            return
        }
        let pathSnapshot = notificationSoundCustomFilePath
        DispatchQueue.global(qos: .userInitiated).async {
            let result = NotificationSoundSettings.prepareCustomFileForNotifications(path: pathSnapshot)
            DispatchQueue.main.async {
                guard notificationSound == NotificationSoundSettings.customFileValue else {
                    notificationCustomSoundStatusMessage = nil
                    notificationCustomSoundStatusIsError = false
                    return
                }
                guard notificationSoundCustomFilePath == pathSnapshot else { return }
                switch result {
                case .success:
                    notificationCustomSoundStatusMessage = notificationCustomSoundReadyStatusMessage(for: pathSnapshot)
                    notificationCustomSoundStatusIsError = false
                case .failure(let issue):
                    let message = notificationCustomSoundIssueMessage(issue)
                    notificationCustomSoundStatusMessage = message
                    notificationCustomSoundStatusIsError = true
                    if showAlertOnFailure {
                        notificationCustomSoundErrorAlertMessage = message
                        showNotificationCustomSoundErrorAlert = true
                    }
                }
            }
        }
    }

    private func chooseNotificationSoundFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.audio]
        panel.title = String(
            localized: "settings.notifications.sound.custom.choose.title",
            defaultValue: "Choose Notification Sound"
        )
        panel.prompt = String(
            localized: "settings.notifications.sound.custom.choose.prompt",
            defaultValue: "Choose"
        )
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let selectedPath = url.path
        switch NotificationSoundSettings.prepareCustomFileForNotifications(path: selectedPath) {
        case .success:
            notificationSoundCustomFilePath = selectedPath
            notificationSound = NotificationSoundSettings.customFileValue
            notificationCustomSoundStatusMessage = notificationCustomSoundReadyStatusMessage(for: selectedPath)
            notificationCustomSoundStatusIsError = false
            previewNotificationSound()
        case .failure(let issue):
            let message = notificationCustomSoundIssueMessage(issue)
            notificationCustomSoundErrorAlertMessage = message
            showNotificationCustomSoundErrorAlert = true
            refreshNotificationCustomSoundStatus()
        }
    }

    private func handleNotificationPermissionAction() {
        let state = notificationStore.authorizationState.statusLabel
#if DEBUG
        dlog("notification.ui enableTapped state=\(state)")
#endif
        NSLog("notification.ui enableTapped state=%@", state)
        switch notificationStore.authorizationState {
        case .unknown, .notDetermined:
            notificationStore.requestAuthorizationFromSettings()
        case .authorized, .denied, .provisional, .ephemeral:
            notificationStore.openNotificationSettings()
        }
    }

    private func saveSocketPassword() {
        let trimmed = socketPasswordDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            socketPasswordStatusMessage = String(localized: "settings.automation.socketPassword.enterFirst", defaultValue: "Enter a password first.")
            socketPasswordStatusIsError = true
            return
        }

        do {
            try SocketControlPasswordStore.savePassword(trimmed)
            socketPasswordDraft = ""
            socketPasswordStatusMessage = String(localized: "settings.automation.socketPassword.saved", defaultValue: "Password saved.")
            socketPasswordStatusIsError = false
        } catch {
            socketPasswordStatusMessage = String(localized: "settings.automation.socketPassword.saveFailed", defaultValue: "Failed to save password (\(error.localizedDescription)).")
            socketPasswordStatusIsError = true
        }
    }

    private func clearSocketPassword() {
        do {
            try SocketControlPasswordStore.clearPassword()
            socketPasswordDraft = ""
            socketPasswordStatusMessage = String(localized: "settings.automation.socketPassword.cleared", defaultValue: "Password cleared.")
            socketPasswordStatusIsError = false
        } catch {
            socketPasswordStatusMessage = String(localized: "settings.automation.socketPassword.clearFailed", defaultValue: "Failed to clear password (\(error.localizedDescription)).")
            socketPasswordStatusIsError = true
        }
    }

    private var weChatConfigurationBinding: Binding<Bool> {
        Binding(
            get: { weChatChannelStore.configuration.integrationEnabled },
            set: { newValue in
                var updated = weChatChannelStore.configuration
                updated.integrationEnabled = newValue
                weChatChannelStore.configuration = updated
            }
        )
    }

    private var weChatAutoCreateWindowBinding: Binding<Bool> {
        Binding(
            get: { weChatChannelStore.configuration.autoCreateWindowForNewChats },
            set: { newValue in
                var updated = weChatChannelStore.configuration
                updated.autoCreateWindowForNewChats = newValue
                weChatChannelStore.configuration = updated
            }
        )
    }

    private var weChatTypingBinding: Binding<Bool> {
        Binding(
            get: { weChatChannelStore.configuration.sendTypingWhileWorking },
            set: { newValue in
                var updated = weChatChannelStore.configuration
                updated.sendTypingWhileWorking = newValue
                weChatChannelStore.configuration = updated
            }
        )
    }

    private var weChatProgressMirrorBinding: Binding<Bool> {
        Binding(
            get: { weChatChannelStore.configuration.mirrorWindowProgressIntoReplies },
            set: { newValue in
                var updated = weChatChannelStore.configuration
                updated.mirrorWindowProgressIntoReplies = newValue
                weChatChannelStore.configuration = updated
            }
        )
    }

    private func weChatAccountStringBinding(
        accountId: UUID,
        keyPath: WritableKeyPath<WeChatBotAccountConfiguration, String>
    ) -> Binding<String> {
        Binding(
            get: {
                weChatChannelStore.configuration.accounts.first(where: { $0.id == accountId })?[keyPath: keyPath] ?? ""
            },
            set: { newValue in
                weChatChannelStore.updateAccount(accountId) { account in
                    account[keyPath: keyPath] = newValue
                }
            }
        )
    }

    private func weChatAccountBoolBinding(
        accountId: UUID,
        keyPath: WritableKeyPath<WeChatBotAccountConfiguration, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: {
                weChatChannelStore.configuration.accounts.first(where: { $0.id == accountId })?[keyPath: keyPath] ?? false
            },
            set: { newValue in
                weChatChannelStore.updateAccount(accountId) { account in
                    account[keyPath: keyPath] = newValue
                }
            }
        )
    }

    private func weChatAccountStateBinding(accountId: UUID) -> Binding<WeChatAccountConnectionState> {
        Binding(
            get: {
                weChatChannelStore.configuration.accounts.first(where: { $0.id == accountId })?.connectionState ?? .draft
            },
            set: { newValue in
                weChatChannelStore.updateAccount(accountId) { account in
                    account.connectionState = newValue
                }
            }
        )
    }

    private func weChatBindingStringBinding(
        accountId: UUID,
        bindingId: UUID,
        keyPath: WritableKeyPath<WeChatConversationBinding, String>
    ) -> Binding<String> {
        Binding(
            get: {
                weChatChannelStore.configuration.accounts
                    .first(where: { $0.id == accountId })?
                    .bindings.first(where: { $0.id == bindingId })?[keyPath: keyPath] ?? ""
            },
            set: { newValue in
                weChatChannelStore.updateBinding(accountId: accountId, bindingId: bindingId) { binding in
                    binding[keyPath: keyPath] = newValue
                }
            }
        )
    }

    private func weChatBindingBoolBinding(
        accountId: UUID,
        bindingId: UUID,
        keyPath: WritableKeyPath<WeChatConversationBinding, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: {
                weChatChannelStore.configuration.accounts
                    .first(where: { $0.id == accountId })?
                    .bindings.first(where: { $0.id == bindingId })?[keyPath: keyPath] ?? false
            },
            set: { newValue in
                weChatChannelStore.updateBinding(accountId: accountId, bindingId: bindingId) { binding in
                    binding[keyPath: keyPath] = newValue
                }
            }
        )
    }

    private func weChatBindingDestinationBinding(accountId: UUID, bindingId: UUID) -> Binding<String> {
        Binding(
            get: {
                let destination = weChatChannelStore.configuration.accounts
                    .first(where: { $0.id == accountId })?
                    .bindings.first(where: { $0.id == bindingId })?.destination ?? .unbound
                return weChatBindingCatalog.optionId(for: destination)
            },
            set: { optionId in
                let destination = weChatBindingCatalog.destination(for: optionId)
                weChatChannelStore.updateBinding(accountId: accountId, bindingId: bindingId) { binding in
                    binding.destination = destination
                }
            }
        )
    }

    private func weChatAccountStatusTint(_ state: WeChatAccountConnectionState) -> Color {
        switch state {
        case .connected:
            return .green
        case .qrReady:
            return .orange
        case .paused:
            return .secondary
        case .draft:
            return .blue
        }
    }

    private var weChatAccountCount: Int {
        weChatChannelStore.configuration.accounts.count
    }

    private var weChatEnabledAccountCount: Int {
        weChatChannelStore.configuration.accounts.filter(\.isEnabled).count
    }

    private var weChatRouteCount: Int {
        weChatChannelStore.configuration.accounts.reduce(0) { $0 + $1.bindings.count }
    }

    private var weChatConnectedAccountCount: Int {
        weChatChannelStore.configuration.accounts.filter { $0.connectionState == .connected }.count
    }

    private func weChatBotTokenDraftBinding(accountId: UUID) -> Binding<String> {
        Binding(
            get: {
                if let draft = weChatBotTokenDrafts[accountId] {
                    return draft
                }
                return ""
            },
            set: { newValue in
                weChatBotTokenDrafts[accountId] = newValue
            }
        )
    }

    private func ensureWeChatDraftState(for account: WeChatBotAccountConfiguration) {
        if expandedWeChatAccountIds.isEmpty && weChatChannelStore.configuration.accounts.count == 1 {
            expandedWeChatAccountIds.insert(account.id)
        }
        if weChatBotTokenDrafts[account.id] == nil {
            weChatBotTokenDrafts[account.id] = ""
        }
    }

    private func ensureWeChatBindingExpanded(_ bindingId: UUID) {
        if expandedWeChatBindingIds.isEmpty {
            expandedWeChatBindingIds.insert(bindingId)
        }
    }

    private func weChatHasSavedBotToken(_ accountId: UUID) -> Bool {
        WeChatBotTokenStore.hasToken(for: accountId)
    }

    private func saveWeChatBotToken(for accountId: UUID) {
        let trimmed = (weChatBotTokenDrafts[accountId] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            weChatAccountStatusMessages[accountId] = localizedSettingsText(
                "settings.wechat.account.token.empty",
                english: "Enter a bot token first.",
                simplifiedChinese: "请先输入机器人 Token。",
                traditionalChinese: "請先輸入機器人 Token。"
            )
            weChatAccountStatusErrors.insert(accountId)
            return
        }

        do {
            try WeChatBotTokenStore.saveToken(trimmed, for: accountId)
            weChatBotTokenDrafts[accountId] = ""
            weChatAccountStatusMessages[accountId] = localizedSettingsText(
                "settings.wechat.account.token.saved",
                english: "Bot token saved locally on this Mac.",
                simplifiedChinese: "机器人 Token 已保存在本机。",
                traditionalChinese: "機器人 Token 已保存在本機。"
            )
            weChatAccountStatusErrors.remove(accountId)
            weChatChannelStore.updateAccount(accountId) { account in
                account.tokenHint = String(trimmed.suffix(6))
            }
        } catch {
            weChatAccountStatusMessages[accountId] = localizedSettingsText(
                "settings.wechat.account.token.saveFailed",
                english: "Failed to save the bot token locally.",
                simplifiedChinese: "本地保存机器人 Token 失败。",
                traditionalChinese: "本地儲存機器人 Token 失敗。"
            )
            weChatAccountStatusErrors.insert(accountId)
        }
    }

    private func clearWeChatBotToken(for accountId: UUID) {
        do {
            try WeChatBotTokenStore.clearToken(for: accountId)
            weChatBotTokenDrafts[accountId] = ""
            weChatAccountStatusMessages[accountId] = localizedSettingsText(
                "settings.wechat.account.token.cleared",
                english: "Saved bot token removed from this Mac.",
                simplifiedChinese: "已删除本机保存的机器人 Token。",
                traditionalChinese: "已刪除本機儲存的機器人 Token。"
            )
            weChatAccountStatusErrors.remove(accountId)
            weChatChannelStore.updateAccount(accountId) { account in
                account.tokenHint = ""
            }
        } catch {
            weChatAccountStatusMessages[accountId] = localizedSettingsText(
                "settings.wechat.account.token.clearFailed",
                english: "Failed to remove the saved bot token.",
                simplifiedChinese: "删除已保存的机器人 Token 失败。",
                traditionalChinese: "刪除已儲存的機器人 Token 失敗。"
            )
            weChatAccountStatusErrors.insert(accountId)
        }
    }

    private func weChatBindingDestinationSummary(_ binding: WeChatConversationBinding) -> String {
        weChatBindingCatalog.options.first(where: { $0.destination == binding.destination })?.label
            ?? localizedSettingsText(
                "settings.wechat.destination.unbound",
                english: "Unbound",
                simplifiedChinese: "未绑定",
                traditionalChinese: "未綁定"
            )
    }

    private func weChatBindingStatusSummary(_ binding: WeChatConversationBinding) -> String {
        if !binding.sessionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "session_id: \(binding.sessionId)"
        }
        return localizedSettingsText(
            "settings.wechat.binding.session.waiting",
            english: "Waiting for the first inbound chat session.",
            simplifiedChinese: "等待首个进入的聊天会话。",
            traditionalChinese: "等待首個進入的聊天會話。"
        )
    }

    private func bindWeChatRouteToCurrentWindow(accountId: UUID, bindingId: UUID) {
        guard let target = AppDelegate.shared?.currentWindowMoveTarget() else { return }
        weChatChannelStore.updateBinding(accountId: accountId, bindingId: bindingId) { binding in
            binding.destination = WeChatBindingDestination(kind: .window, windowId: target.windowId, workspaceId: nil)
        }
        weChatBindingCatalog.refresh()
    }

    private func bindWeChatRouteToCurrentWorkspace(accountId: UUID, bindingId: UUID) {
        guard let target = AppDelegate.shared?.currentWorkspaceMoveTarget() else { return }
        weChatChannelStore.updateBinding(accountId: accountId, bindingId: bindingId) { binding in
            binding.destination = WeChatBindingDestination(kind: .workspace, windowId: target.windowId, workspaceId: target.workspaceId)
        }
        weChatBindingCatalog.refresh()
    }

    private var weChatCurrentWindowQuickBindTitle: String {
        if let target = AppDelegate.shared?.currentWindowMoveTarget() {
            return localizedSettingsText(
                "settings.wechat.binding.bindCurrentWindow",
                english: "Bind to Current Window",
                simplifiedChinese: "绑定到当前窗口",
                traditionalChinese: "綁定到目前視窗"
            ) + " · " + target.label
        }
        return localizedSettingsText(
            "settings.wechat.binding.bindCurrentWindow",
            english: "Bind to Current Window",
            simplifiedChinese: "绑定到当前窗口",
            traditionalChinese: "綁定到目前視窗"
        )
    }

    private var weChatCurrentWorkspaceQuickBindTitle: String {
        if let target = AppDelegate.shared?.currentWorkspaceMoveTarget() {
            return localizedSettingsText(
                "settings.wechat.binding.bindCurrentWorkspace",
                english: "Bind to Current Workspace",
                simplifiedChinese: "绑定到当前工作区",
                traditionalChinese: "綁定到目前工作區"
            ) + " · " + target.workspaceTitle
        }
        return localizedSettingsText(
            "settings.wechat.binding.bindCurrentWorkspace",
            english: "Bind to Current Workspace",
            simplifiedChinese: "绑定到当前工作区",
            traditionalChinese: "綁定到目前工作區"
        )
    }

    @ViewBuilder
    private func weChatDestinationPicker(accountId: UUID, bindingId: UUID) -> some View {
        Picker(
            "",
            selection: weChatBindingDestinationBinding(accountId: accountId, bindingId: bindingId)
        ) {
            ForEach(weChatBindingCatalog.options) { option in
                Text(option.label).tag(option.id)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .frame(width: 250)
    }

    private func scrollToSettingsSection(
        _ section: SettingsSidebarSection,
        proxy: ScrollViewProxy
    ) {
        selectedSettingsSection = section
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.18)) {
                proxy.scrollTo(section.rawValue, anchor: .top)
            }
        }
    }

    private func settingsNavigationSidebar(proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ICCSidebarCard(emphasized: true) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 12) {
                        ICCIconBadge(
                            systemImage: "slider.horizontal.3",
                            primary: ICCChrome.accent(for: colorScheme),
                            secondary: ICCChrome.secondaryAccent(for: colorScheme)
                        )

                        VStack(alignment: .leading, spacing: 6) {
                            Text("icc")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Text(
                                localizedSettingsText(
                                    "settings.nav.summary",
                                    english: "Configure the workspace, automation, browser, and notification flow from one place.",
                                    simplifiedChinese: "在这里统一配置工作区、自动化、浏览器和通知流程。",
                                    traditionalChinese: "在這裡統一設定工作區、自動化、瀏覽器與通知流程。"
                                )
                            )
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(spacing: 8) {
                        ICCStatusPill(
                            text: localizedSettingsText(
                                "settings.nav.workspace",
                                english: "Workspace",
                                simplifiedChinese: "工作区",
                                traditionalChinese: "工作區"
                            ),
                            tint: ICCChrome.accent(for: colorScheme)
                        )
                        ICCStatusPill(
                            text: localizedSettingsText(
                                "settings.nav.automation",
                                english: "Automation",
                                simplifiedChinese: "自动化",
                                traditionalChinese: "自動化"
                            ),
                            tint: ICCChrome.secondaryAccent(for: colorScheme)
                        )
                    }
                }
            }

            ICCSidebarCard {
                VStack(spacing: 8) {
                    ForEach(SettingsSidebarSection.allCases) { section in
                        SettingsSidebarNavButton(
                            section: section,
                            isSelected: selectedSettingsSection == section,
                            action: {
                                scrollToSettingsSection(section, proxy: proxy)
                            }
                        )
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(width: 280)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(
            ZStack {
                ICCChrome.panelGradient(for: colorScheme)
                LinearGradient(
                    colors: [
                        ICCChrome.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.08 : 0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .top) {
                HStack(spacing: 0) {
                    settingsNavigationSidebar(proxy: proxy)

                    Divider()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                    SettingsSectionHeader(title: SettingsSidebarSection.app.title)
                        .id(SettingsSidebarSection.app.rawValue)
                    SettingsCard {
                        SettingsCardRow(
                            String(localized: "settings.app.language", defaultValue: "Language"),
                            subtitle: appLanguage != LanguageSettings.languageAtLaunch.rawValue
                                ? String(localized: "settings.app.language.restartSubtitle", defaultValue: "Restart icc to apply")
                                : nil,
                            controlWidth: pickerColumnWidth
                        ) {
                            Picker("", selection: $appLanguage) {
                                ForEach(AppLanguage.allCases) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .onChange(of: appLanguage) { newValue in
                                guard !isResettingSettings else { return }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                                    // Re-check current value to handle rapid changes
                                    let current = appLanguage
                                    if let lang = AppLanguage(rawValue: current) {
                                        LanguageSettings.apply(lang)
                                    }
                                    if current != LanguageSettings.languageAtLaunch.rawValue {
                                        showLanguageRestartAlert = true
                                    }
                                }
                            }
                        }

                        SettingsCardDivider()

                        ThemePickerRow(
                            selectedMode: appearanceMode,
                            onSelect: { mode in
                                appearanceMode = mode.rawValue
                            }
                        )

                        SettingsCardDivider()

                        AppIconPickerRow(
                            selectedMode: appIconMode,
                            onSelect: { mode in
                                appIconMode = mode.rawValue
                                AppIconSettings.applyIcon(mode)
                            }
                        )

                        SettingsCardDivider()

                        SettingsPickerRow(
                            String(localized: "settings.app.newWorkspacePlacement", defaultValue: "New Workspace Placement"),
                            subtitle: selectedWorkspacePlacement.description,
                            controlWidth: pickerColumnWidth,
                            selection: $newWorkspacePlacement
                        ) {
                            ForEach(NewWorkspacePlacement.allCases) { placement in
                                Text(placement.displayName).tag(placement.rawValue)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.minimalMode", english: "Minimal Mode", simplifiedChinese: "极简模式", traditionalChinese: "極簡模式"),
                            subtitle: minimalModeSubtitle
                        ) {
                            Toggle("", isOn: minimalModeBinding)
                                .labelsHidden()
                                .controlSize(.small)
                                .accessibilityIdentifier("SettingsMinimalModeToggle")
                                .accessibilityLabel(
                                    localizedSettingsText("settings.app.minimalMode", english: "Minimal Mode", simplifiedChinese: "极简模式", traditionalChinese: "極簡模式")
                                )
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.closeWorkspaceOnLastSurfaceShortcut", english: "Keep Workspace Open When Closing Last Surface", simplifiedChinese: "关闭最后一个面板时保留工作区", traditionalChinese: "關閉最後一個面板時保留工作區"),
                            subtitle: closeWorkspaceOnLastSurfaceShortcutSubtitle
                        ) {
                            Toggle("", isOn: keepWorkspaceOpenOnLastSurfaceShortcutBinding)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.paneFirstClickFocus", english: "Focus Pane on First Click", simplifiedChinese: "首次点击直接聚焦面板", traditionalChinese: "首次點擊直接聚焦面板"),
                            subtitle: paneFirstClickFocusSubtitle
                        ) {
                            Toggle("", isOn: $paneFirstClickFocusEnabled)
                                .labelsHidden()
                                .controlSize(.small)
                                .accessibilityLabel(
                                    localizedSettingsText("settings.app.paneFirstClickFocus", english: "Focus Pane on First Click", simplifiedChinese: "首次点击直接聚焦面板", traditionalChinese: "首次點擊直接聚焦面板")
                                )
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.reorderOnNotification", english: "Reorder on Notification", simplifiedChinese: "收到通知时重新排序", traditionalChinese: "收到通知時重新排序"),
                            subtitle: localizedSettingsText("settings.app.reorderOnNotification.subtitle", english: "Move workspaces to the top when they receive a notification. Disable for stable shortcut positions.", simplifiedChinese: "工作区收到通知时自动移到顶部。若要保持快捷键位置稳定，可关闭此项。", traditionalChinese: "工作區收到通知時自動移到頂部。若要保持快捷鍵位置穩定，可關閉此項。")
                        ) {
                            Toggle("", isOn: $workspaceAutoReorder)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.dockBadge", english: "Dock Badge", simplifiedChinese: "程序坞角标", traditionalChinese: "Dock 角標"),
                            subtitle: localizedSettingsText("settings.app.dockBadge.subtitle", english: "Show unread count on app icon (Dock and Cmd+Tab).", simplifiedChinese: "在应用图标上显示未读数量，包括 Dock 和 Cmd+Tab。", traditionalChinese: "在應用圖示上顯示未讀數量，包括 Dock 與 Cmd+Tab。")
                        ) {
                            Toggle("", isOn: $notificationDockBadgeEnabled)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showInMenuBar", english: "Show in Menu Bar", simplifiedChinese: "在菜单栏显示", traditionalChinese: "在選單列顯示"),
                            subtitle: localizedSettingsText("settings.app.showInMenuBar.subtitle", english: "Keep icc in the menu bar for unread notifications and quick actions.", simplifiedChinese: "在菜单栏中保留 icc，用于未读提醒和快捷操作。", traditionalChinese: "在選單列中保留 icc，用於未讀提醒與快捷操作。")
                        ) {
                            Toggle("", isOn: $showMenuBarExtra)
                                .labelsHidden()
                                .controlSize(.small)
                                .accessibilityLabel(
                                    localizedSettingsText("settings.app.showInMenuBar", english: "Show in Menu Bar", simplifiedChinese: "在菜单栏显示", traditionalChinese: "在選單列顯示")
                                )
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.notifications.paneRing.title", english: "Unread Pane Ring", simplifiedChinese: "未读面板描边", traditionalChinese: "未讀面板描邊"),
                            subtitle: localizedSettingsText("settings.notifications.paneRing.subtitle", english: "Show a blue ring around panes with unread notifications.", simplifiedChinese: "带有未读通知的面板会显示蓝色描边。", traditionalChinese: "帶有未讀通知的面板會顯示藍色描邊。")
                        ) {
                            Toggle("", isOn: $notificationPaneRingEnabled)
                                .labelsHidden()
                                .controlSize(.small)
                                .accessibilityLabel(
                                    localizedSettingsText("settings.notifications.paneRing.title", english: "Unread Pane Ring", simplifiedChinese: "未读面板描边", traditionalChinese: "未讀面板描邊")
                                )
                        }
                        .id(SettingsSidebarSection.notifications.rawValue)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.notifications.paneFlash.title", english: "Pane Flash", simplifiedChinese: "面板闪烁提示", traditionalChinese: "面板閃爍提示"),
                            subtitle: localizedSettingsText("settings.notifications.paneFlash.subtitle", english: "Briefly flash a blue outline when icc highlights a pane.", simplifiedChinese: "icc 高亮面板时，会短暂闪烁蓝色边框。", traditionalChinese: "icc 高亮面板時，會短暫閃爍藍色邊框。")
                        ) {
                            Toggle("", isOn: $notificationPaneFlashEnabled)
                                .labelsHidden()
                                .controlSize(.small)
                                .accessibilityLabel(
                                    localizedSettingsText("settings.notifications.paneFlash.title", english: "Pane Flash", simplifiedChinese: "面板闪烁提示", traditionalChinese: "面板閃爍提示")
                                )
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.notifications.desktop.title", english: "Desktop Notifications", simplifiedChinese: "桌面通知", traditionalChinese: "桌面通知"),
                            subtitle: notificationPermissionSubtitle
                        ) {
                            HStack(spacing: 6) {
                                Text(notificationPermissionStatusText)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(notificationPermissionStatusColor)
                                    .frame(width: 98, alignment: .trailing)

                                Button(notificationPermissionActionTitle) {
                                    handleNotificationPermissionAction()
                                }
                                .controlSize(.small)

                                Button(localizedSettingsText("settings.notifications.desktop.sendTest", english: "Send Test", simplifiedChinese: "发送测试", traditionalChinese: "傳送測試")) {
                                    notificationStore.sendSettingsTestNotification()
                                }
                                .controlSize(.small)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.notifications.sound.title", english: "Notification Sound", simplifiedChinese: "通知声音", traditionalChinese: "通知聲音"),
                            subtitle: localizedSettingsText("settings.notifications.sound.subtitle", english: "Sound played when a notification arrives.", simplifiedChinese: "通知到达时播放的声音。", traditionalChinese: "通知到達時播放的聲音。"),
                            controlWidth: notificationSoundControlWidth
                        ) {
                            VStack(alignment: .trailing, spacing: 6) {
                                HStack(spacing: 6) {
                                    Picker("", selection: $notificationSound) {
                                        ForEach(NotificationSoundSettings.systemSounds, id: \.value) { sound in
                                            Text(sound.label).tag(sound.value)
                                        }
                                    }
                                    .labelsHidden()
                                    Button {
                                        previewNotificationSound()
                                    } label: {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 9))
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .disabled(!canPreviewNotificationSound)
                                }

                                if notificationSound == NotificationSoundSettings.customFileValue {
                                    HStack(spacing: 6) {
                                        Text(notificationSoundCustomFileDisplayName)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                            .frame(width: 170, alignment: .trailing)
                                        Button(
                                            localizedSettingsText("settings.notifications.sound.custom.choose.button", english: "Choose...", simplifiedChinese: "选择...", traditionalChinese: "選擇...")
                                        ) {
                                            chooseNotificationSoundFile()
                                        }
                                        .controlSize(.small)
                                        Button(
                                            localizedSettingsText("settings.notifications.sound.custom.clear.button", english: "Clear", simplifiedChinese: "清除", traditionalChinese: "清除")
                                        ) {
                                            notificationSoundCustomFilePath = NotificationSoundSettings.defaultCustomFilePath
                                            refreshNotificationCustomSoundStatus()
                                        }
                                        .controlSize(.small)
                                        .disabled(!hasCustomNotificationSoundFilePath)
                                    }
                                    if let notificationCustomSoundStatusMessage {
                                        Text(notificationCustomSoundStatusMessage)
                                            .font(.system(size: 11))
                                            .foregroundStyle(notificationCustomSoundStatusIsError ? Color.red : Color.secondary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.trailing)
                                            .frame(width: 260, alignment: .trailing)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.notifications.command.title", english: "Notification Command", simplifiedChinese: "通知命令", traditionalChinese: "通知命令"),
                            subtitle: localizedSettingsText("settings.notifications.command.subtitle", english: "Run a shell command when a notification arrives. $ICC_NOTIFICATION_TITLE, $ICC_NOTIFICATION_SUBTITLE, $ICC_NOTIFICATION_BODY are set.", simplifiedChinese: "通知到达时执行 Shell 命令。会自动注入 $ICC_NOTIFICATION_TITLE、$ICC_NOTIFICATION_SUBTITLE、$ICC_NOTIFICATION_BODY。", traditionalChinese: "通知到達時執行 Shell 指令。會自動注入 $ICC_NOTIFICATION_TITLE、$ICC_NOTIFICATION_SUBTITLE、$ICC_NOTIFICATION_BODY。")
                        ) {
                            TextField(localizedSettingsText("settings.notifications.command.placeholder", english: "say \"done\"", simplifiedChinese: "say \"完成\"", traditionalChinese: "say \"完成\""), text: $notificationCustomCommand)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.telemetry", english: "Send anonymous telemetry", simplifiedChinese: "发送匿名遥测", traditionalChinese: "傳送匿名遙測"),
                            subtitle: sendAnonymousTelemetry != telemetryValueAtLaunch
                                ? localizedSettingsText("settings.app.telemetry.subtitleChanged", english: "Change takes effect on next launch.", simplifiedChinese: "更改将在下次启动后生效。", traditionalChinese: "變更將在下次啟動後生效。")
                                : localizedSettingsText("settings.app.telemetry.subtitle", english: "Share anonymized crash and usage data to help improve icc.", simplifiedChinese: "共享匿名化的崩溃与使用数据，以帮助改进 icc。", traditionalChinese: "共享匿名化的崩潰與使用資料，以協助改進 icc。")
                        ) {
                            Toggle("", isOn: $sendAnonymousTelemetry)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.warnBeforeQuit", english: "Warn Before Quit", simplifiedChinese: "退出前确认", traditionalChinese: "退出前確認"),
                            subtitle: warnBeforeQuitShortcut
                                ? localizedSettingsText("settings.app.warnBeforeQuit.subtitleOn", english: "Show a confirmation before quitting with Cmd+Q.", simplifiedChinese: "使用 Cmd+Q 退出前先显示确认提示。", traditionalChinese: "使用 Cmd+Q 退出前先顯示確認提示。")
                                : localizedSettingsText("settings.app.warnBeforeQuit.subtitleOff", english: "Cmd+Q quits immediately without confirmation.", simplifiedChinese: "Cmd+Q 将直接退出，不再确认。", traditionalChinese: "Cmd+Q 將直接退出，不再確認。")
                        ) {
                            Toggle("", isOn: $warnBeforeQuitShortcut)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.renameSelectsName", english: "Rename Selects Existing Name", simplifiedChinese: "重命名时默认选中原名称", traditionalChinese: "重新命名時預設選取原名稱"),
                            subtitle: commandPaletteRenameSelectAllOnFocus
                                ? localizedSettingsText("settings.app.renameSelectsName.subtitleOn", english: "Command Palette rename starts with all text selected.", simplifiedChinese: "命令面板重命名时会默认全选文本。", traditionalChinese: "命令面板重新命名時會預設全選文字。")
                                : localizedSettingsText("settings.app.renameSelectsName.subtitleOff", english: "Command Palette rename keeps the caret at the end.", simplifiedChinese: "命令面板重命名时会把光标放在末尾。", traditionalChinese: "命令面板重新命名時會把游標放在末尾。")
                        ) {
                            Toggle("", isOn: $commandPaletteRenameSelectAllOnFocus)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.commandPaletteSearchAllSurfaces", english: "Command Palette Searches All Surfaces", simplifiedChinese: "命令面板搜索全部视图", traditionalChinese: "命令面板搜尋全部視圖"),
                            subtitle: commandPaletteSearchAllSurfaces
                                ? localizedSettingsText("settings.app.commandPaletteSearchAllSurfaces.subtitleOn", english: "Cmd+P also matches terminal, browser, and markdown surfaces across workspaces.", simplifiedChinese: "Cmd+P 会同时匹配各工作区中的终端、浏览器和 Markdown 视图。", traditionalChinese: "Cmd+P 會同時比對各工作區中的終端、瀏覽器與 Markdown 視圖。")
                                : localizedSettingsText("settings.app.commandPaletteSearchAllSurfaces.subtitleOff", english: "Cmd+P matches workspace rows only.", simplifiedChinese: "Cmd+P 仅匹配工作区行。", traditionalChinese: "Cmd+P 僅比對工作區列。")
                        ) {
                            Toggle("", isOn: $commandPaletteSearchAllSurfaces)
                                .labelsHidden()
                                .controlSize(.small)
                                .accessibilityIdentifier("CommandPaletteSearchAllSurfacesToggle")
                                .accessibilityLabel(
                                    localizedSettingsText("settings.app.commandPaletteSearchAllSurfaces", english: "Command Palette Searches All Surfaces", simplifiedChinese: "命令面板搜索全部视图", traditionalChinese: "命令面板搜尋全部視圖")
                                )
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.hideAllSidebarDetails", english: "Hide All Sidebar Details", simplifiedChinese: "隐藏侧边栏全部详情", traditionalChinese: "隱藏側邊欄全部詳情"),
                            subtitle: sidebarHideAllDetails
                                ? localizedSettingsText("settings.app.hideAllSidebarDetails.subtitleOn", english: "Show only the workspace title row. Overrides the detail toggles below.", simplifiedChinese: "只显示工作区标题行，并覆盖下面的详情开关。", traditionalChinese: "只顯示工作區標題列，並覆蓋下方的詳情開關。")
                                : localizedSettingsText("settings.app.hideAllSidebarDetails.subtitleOff", english: "Show secondary workspace details as controlled by the toggles below.", simplifiedChinese: "按下方开关显示工作区的次级详情。", traditionalChinese: "依照下方開關顯示工作區的次級詳情。")
                        ) {
                            Toggle("", isOn: $sidebarHideAllDetails)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsPickerRow(
                            localizedSettingsText("settings.app.sidebarBranchLayout", english: "Sidebar Branch Layout", simplifiedChinese: "侧边栏分支布局", traditionalChinese: "側邊欄分支佈局"),
                            subtitle: sidebarBranchVerticalLayout
                                ? localizedSettingsText("settings.app.sidebarBranchLayout.subtitleVertical", english: "Vertical: each branch appears on its own line.", simplifiedChinese: "纵向：每个分支单独占一行。", traditionalChinese: "縱向：每個分支單獨佔一行。")
                                : localizedSettingsText("settings.app.sidebarBranchLayout.subtitleInline", english: "Inline: all branches share one line.", simplifiedChinese: "内联：所有分支共用一行。", traditionalChinese: "內聯：所有分支共用一行。"),
                            controlWidth: pickerColumnWidth,
                            selection: $sidebarBranchVerticalLayout
                        ) {
                            Text(localizedSettingsText("settings.app.sidebarBranchLayout.vertical", english: "Vertical", simplifiedChinese: "纵向", traditionalChinese: "縱向")).tag(true)
                            Text(localizedSettingsText("settings.app.sidebarBranchLayout.inline", english: "Inline", simplifiedChinese: "内联", traditionalChinese: "內聯")).tag(false)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showNotificationMessage", english: "Show Notification Message in Sidebar", simplifiedChinese: "在侧边栏显示通知消息", traditionalChinese: "在側邊欄顯示通知訊息"),
                            subtitle: localizedSettingsText("settings.app.showNotificationMessage.subtitle", english: "Display the latest notification message below the workspace title.", simplifiedChinese: "在工作区标题下方显示最新通知内容。", traditionalChinese: "在工作區標題下方顯示最新通知內容。")
                        ) {
                            Toggle("", isOn: $sidebarShowNotificationMessage)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showBranchDirectory", english: "Show Branch + Directory in Sidebar", simplifiedChinese: "在侧边栏显示分支和目录", traditionalChinese: "在側邊欄顯示分支與目錄"),
                            subtitle: localizedSettingsText("settings.app.showBranchDirectory.subtitle", english: "Display the built-in git branch and working-directory row.", simplifiedChinese: "显示内置的 Git 分支和工作目录行。", traditionalChinese: "顯示內建的 Git 分支與工作目錄列。")
                        ) {
                            Toggle("", isOn: $sidebarShowBranchDirectory)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showPullRequests", english: "Show Pull Requests in Sidebar", simplifiedChinese: "在侧边栏显示合并请求", traditionalChinese: "在側邊欄顯示合併請求"),
                            subtitle: localizedSettingsText("settings.app.showPullRequests.subtitle", english: "Display review items (PR/MR/etc.) with status, number, and clickable link.", simplifiedChinese: "显示评审项（PR/MR 等）的状态、编号和可点击链接。", traditionalChinese: "顯示評審項目（PR/MR 等）的狀態、編號與可點擊連結。")
                        ) {
                            Toggle("", isOn: $sidebarShowPullRequest)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.openSidebarPRLinks", english: "Open Sidebar PR Links in icc Browser", simplifiedChinese: "在 icc 浏览器中打开侧边栏 PR 链接", traditionalChinese: "在 icc 瀏覽器中開啟側邊欄 PR 連結"),
                            subtitle: openSidebarPullRequestLinksInIccBrowser
                                ? localizedSettingsText("settings.app.openSidebarPRLinks.subtitleOn", english: "Clicks open inside the icc browser.", simplifiedChinese: "点击后会在 icc 内置浏览器中打开。", traditionalChinese: "點擊後會在 icc 內建瀏覽器中開啟。")
                                : localizedSettingsText("settings.app.openSidebarPRLinks.subtitleOff", english: "Clicks open in your default browser.", simplifiedChinese: "点击后会在系统默认浏览器中打开。", traditionalChinese: "點擊後會在系統預設瀏覽器中開啟。")
                        ) {
                            Toggle("", isOn: $openSidebarPullRequestLinksInIccBrowser)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showSSH", english: "Show SSH in Sidebar", simplifiedChinese: "在侧边栏显示 SSH", traditionalChinese: "在側邊欄顯示 SSH"),
                            subtitle: localizedSettingsText("settings.app.showSSH.subtitle", english: "Display the SSH target for remote workspaces in its own row.", simplifiedChinese: "为远程工作区单独显示 SSH 目标行。", traditionalChinese: "為遠端工作區單獨顯示 SSH 目標列。")
                        ) {
                            Toggle("", isOn: $sidebarShowSSH)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsPickerRow(
                            localizedSettingsText("settings.app.remoteSSHTermMode", english: "Managed Remote SSH TERM", simplifiedChinese: "受管远程 SSH 的 TERM", traditionalChinese: "受管遠端 SSH 的 TERM"),
                            subtitle: remoteSSHTermModeRaw == RemoteSSHTermMode.xterm256color.rawValue
                                ? localizedSettingsText("settings.app.remoteSSHTermMode.subtitleCompat", english: "Managed remote SSH sessions use TERM=xterm-256color for stronger compatibility. Reconnect terminals after changing this.", simplifiedChinese: "受管远程 SSH 会使用 TERM=xterm-256color 以获得更稳的兼容性。修改后请重新连接终端。", traditionalChinese: "受管遠端 SSH 會使用 TERM=xterm-256color 以獲得更穩的相容性。修改後請重新連線終端。")
                                : localizedSettingsText("settings.app.remoteSSHTermMode.subtitleGhostty", english: "Managed remote SSH sessions keep Ghostty's default TERM and expect remote terminfo support.", simplifiedChinese: "受管远程 SSH 会保留 Ghostty 默认 TERM，并假定远端已具备对应 terminfo。", traditionalChinese: "受管遠端 SSH 會保留 Ghostty 預設 TERM，並假定遠端已具備對應 terminfo。"),
                            controlWidth: pickerColumnWidth,
                            selection: $remoteSSHTermModeRaw
                        ) {
                            Text(localizedSettingsText("settings.app.remoteSSHTermMode.compat", english: "Compatibility First", simplifiedChinese: "兼容优先", traditionalChinese: "相容優先"))
                                .tag(RemoteSSHTermMode.xterm256color.rawValue)
                            Text(localizedSettingsText("settings.app.remoteSSHTermMode.ghostty", english: "Keep Ghostty TERM", simplifiedChinese: "保留 Ghostty TERM", traditionalChinese: "保留 Ghostty TERM"))
                                .tag(RemoteSSHTermMode.inheritGhostty.rawValue)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showPorts", english: "Show Listening Ports in Sidebar", simplifiedChinese: "在侧边栏显示监听端口", traditionalChinese: "在側邊欄顯示監聽連接埠"),
                            subtitle: localizedSettingsText("settings.app.showPorts.subtitle", english: "Display detected listening ports for the active workspace.", simplifiedChinese: "显示当前工作区检测到的监听端口。", traditionalChinese: "顯示目前工作區偵測到的監聽連接埠。")
                        ) {
                            Toggle("", isOn: $sidebarShowPorts)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showLog", english: "Show Latest Log in Sidebar", simplifiedChinese: "在侧边栏显示最新日志", traditionalChinese: "在側邊欄顯示最新日誌"),
                            subtitle: localizedSettingsText("settings.app.showLog.subtitle", english: "Display the latest imperative log/status message.", simplifiedChinese: "显示最新的指令式日志或状态消息。", traditionalChinese: "顯示最新的指令式日誌或狀態訊息。")
                        ) {
                            Toggle("", isOn: $sidebarShowLog)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showProgress", english: "Show Progress in Sidebar", simplifiedChinese: "在侧边栏显示进度", traditionalChinese: "在側邊欄顯示進度"),
                            subtitle: localizedSettingsText("settings.app.showProgress.subtitle", english: "Display the built-in progress bar from set_progress.", simplifiedChinese: "显示由 set_progress 提供的内置进度条。", traditionalChinese: "顯示由 set_progress 提供的內建進度條。")
                        ) {
                            Toggle("", isOn: $sidebarShowProgress)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.app.showMetadata", english: "Show Custom Metadata in Sidebar", simplifiedChinese: "在侧边栏显示自定义元数据", traditionalChinese: "在側邊欄顯示自訂中繼資料"),
                            subtitle: localizedSettingsText("settings.app.showMetadata.subtitle", english: "Display custom metadata from report_meta/set_status and report_meta_block.", simplifiedChinese: "显示来自 report_meta、set_status 和 report_meta_block 的自定义元数据。", traditionalChinese: "顯示來自 report_meta、set_status 與 report_meta_block 的自訂中繼資料。")
                        ) {
                            Toggle("", isOn: $sidebarShowMetadata)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(sidebarHideAllDetails)
                    }

                    SettingsSectionHeader(title: SettingsSidebarSection.workspaceColors.title)
                        .id(SettingsSidebarSection.workspaceColors.rawValue)
                    SettingsCard {
                        SettingsPickerRow(
                            String(localized: "settings.workspaceColors.indicator", defaultValue: "Workspace Color Indicator"),
                            controlWidth: pickerColumnWidth,
                            selection: sidebarIndicatorStyleSelection
                        ) {
                            ForEach(SidebarActiveTabIndicatorStyle.allCases) { style in
                                Text(style.displayName).tag(style.rawValue)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardNote(String(localized: "settings.workspaceColors.paletteNote", defaultValue: "Customize the workspace color palette used by Sidebar > Workspace Color. \"Choose Custom Color...\" entries are persisted below."))

                        ForEach(Array(workspaceTabDefaultEntries.enumerated()), id: \.element.name) { index, entry in
                            if index > 0 {
                                SettingsCardDivider()
                            }
                            SettingsCardRow(
                                entry.name,
                                subtitle: String(localized: "settings.workspaceColors.base", defaultValue: "Base: \(baseTabColorHex(for: entry.name))")
                            ) {
                                HStack(spacing: 8) {
                                    ColorPicker(
                                        "",
                                        selection: defaultTabColorBinding(for: entry.name),
                                        supportsOpacity: false
                                    )
                                    .labelsHidden()
                                    .frame(width: 38)

                                    Text(entry.hex)
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 76, alignment: .trailing)
                                }
                            }
                        }

                        SettingsCardDivider()

                        if workspaceTabCustomColors.isEmpty {
                            SettingsCardNote(String(localized: "settings.workspaceColors.noCustomColors", defaultValue: "Custom colors: none yet. Use \"Choose Custom Color...\" from a workspace context menu."))
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "settings.workspaceColors.customColors", defaultValue: "Custom Colors"))
                                    .font(.system(size: 13, weight: .semibold))

                                ForEach(workspaceTabCustomColors, id: \.self) { hex in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(nsColor: NSColor(hex: hex) ?? .gray))
                                            .frame(width: 11, height: 11)

                                        Text(hex)
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .foregroundStyle(.secondary)

                                        Spacer(minLength: 8)

                                        Button(String(localized: "settings.workspaceColors.remove", defaultValue: "Remove")) {
                                            removeWorkspaceCustomColor(hex)
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            String(localized: "settings.workspaceColors.resetPalette", defaultValue: "Reset Palette"),
                            subtitle: String(localized: "settings.workspaceColors.resetPalette.subtitle", defaultValue: "Restore built-in defaults and clear all custom colors.")
                        ) {
                            Button(String(localized: "settings.workspaceColors.resetPalette.button", defaultValue: "Reset")) {
                                resetWorkspaceTabColors()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }

                    SettingsSectionHeader(title: SettingsSidebarSection.sidebarAppearance.title)
                        .id(SettingsSidebarSection.sidebarAppearance.rawValue)
                    SettingsCard {
                        SettingsCardRow(
                            localizedSettingsText("settings.sidebarAppearance.preset.title", english: "Color Presets", simplifiedChinese: "配色方案", traditionalChinese: "配色方案"),
                            subtitle: localizedSettingsText("settings.sidebarAppearance.preset.subtitle", english: "Choose a balanced sidebar tint preset, then fine-tune below if needed.", simplifiedChinese: "先选择一个更协调的侧边栏配色，再按需微调。", traditionalChinese: "先選擇一個更協調的側邊欄配色，再按需微調。")
                        ) {
                            HStack(spacing: 8) {
                                ForEach(SidebarColorPreset.allCases) { preset in
                                    SidebarColorPresetChip(
                                        preset: preset,
                                        isSelected: selectedSidebarColorPreset == preset,
                                        onSelect: { applySidebarColorPreset(preset) }
                                    )
                                }
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.sidebarAppearance.tintColorLight", english: "Light Mode Tint", simplifiedChinese: "浅色模式着色", traditionalChinese: "淺色模式著色"),
                            subtitle: localizedSettingsText("settings.sidebarAppearance.tintColorLight.subtitle", english: "Sidebar tint color when using light appearance.", simplifiedChinese: "浅色外观下侧边栏使用的着色颜色。", traditionalChinese: "淺色外觀下側邊欄使用的著色顏色。")
                        ) {
                            HStack(spacing: 8) {
                                ColorPicker(
                                    localizedSettingsText("settings.sidebarAppearance.tintColorLight.picker", english: "Light tint", simplifiedChinese: "浅色着色", traditionalChinese: "淺色著色"),
                                    selection: settingsSidebarTintLightBinding,
                                    supportsOpacity: false
                                )
                                .labelsHidden()
                                .frame(width: 38)

                                Text(sidebarTintHexLight ?? localizedSettingsText("settings.sidebarAppearance.defaultLabel", english: "Default", simplifiedChinese: "默认", traditionalChinese: "預設"))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 76, alignment: .trailing)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.sidebarAppearance.tintColorDark", english: "Dark Mode Tint", simplifiedChinese: "深色模式着色", traditionalChinese: "深色模式著色"),
                            subtitle: localizedSettingsText("settings.sidebarAppearance.tintColorDark.subtitle", english: "Sidebar tint color when using dark appearance.", simplifiedChinese: "深色外观下侧边栏使用的着色颜色。", traditionalChinese: "深色外觀下側邊欄使用的著色顏色。")
                        ) {
                            HStack(spacing: 8) {
                                ColorPicker(
                                    localizedSettingsText("settings.sidebarAppearance.tintColorDark.picker", english: "Dark tint", simplifiedChinese: "深色着色", traditionalChinese: "深色著色"),
                                    selection: settingsSidebarTintDarkBinding,
                                    supportsOpacity: false
                                )
                                .labelsHidden()
                                .frame(width: 38)

                                Text(sidebarTintHexDark ?? localizedSettingsText("settings.sidebarAppearance.defaultLabel", english: "Default", simplifiedChinese: "默认", traditionalChinese: "預設"))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 76, alignment: .trailing)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.sidebarAppearance.tintOpacity", english: "Tint Opacity", simplifiedChinese: "着色强度", traditionalChinese: "著色強度"),
                            subtitle: localizedSettingsText("settings.sidebarAppearance.tintOpacity.subtitle", english: "How strongly the tint color shows over the sidebar material.", simplifiedChinese: "控制着色颜色在侧边栏材质上的显现强度。", traditionalChinese: "控制著色顏色在側邊欄材質上的顯現強度。")
                        ) {
                            HStack(spacing: 8) {
                                Slider(value: $sidebarTintOpacity, in: 0...1)
                                    .frame(width: 140)
                                Text(String(format: "%.0f%%", sidebarTintOpacity * 100))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText("settings.sidebarAppearance.reset", english: "Reset Sidebar Tint", simplifiedChinese: "重置侧边栏着色", traditionalChinese: "重設側邊欄著色"),
                            subtitle: localizedSettingsText("settings.sidebarAppearance.reset.subtitle", english: "Restore default sidebar appearance.", simplifiedChinese: "恢复默认的侧边栏外观。", traditionalChinese: "恢復預設的側邊欄外觀。")
                        ) {
                            Button(localizedSettingsText("settings.sidebarAppearance.reset.button", english: "Reset", simplifiedChinese: "重置", traditionalChinese: "重設")) {
                                sidebarTintHexLight = nil
                                sidebarTintHexDark = nil
                                sidebarTintHex = SidebarTintDefaults.hex
                                sidebarTintOpacity = SidebarTintDefaults.opacity
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }

                    SettingsSectionHeader(title: SettingsSidebarSection.automation.title)
                        .id(SettingsSidebarSection.automation.rawValue)
                    SettingsCard {
                        SettingsCardRow(
                            localizedSettingsText(
                                "settings.wechat.integration.title",
                                english: "WeChat Channel",
                                simplifiedChinese: "微信通道",
                                traditionalChinese: "微信通道"
                            ),
                            subtitle: localizedSettingsText(
                                "settings.wechat.integration.subtitle",
                                english: "Bind inbound WeChat chats to specific icc windows or workspaces, so each conversation controls the right target.",
                                simplifiedChinese: "把微信会话绑定到指定的 icc 窗口或工作区，让每个对话都控制正确的目标。",
                                traditionalChinese: "把微信會話綁定到指定的 icc 視窗或工作區，讓每個對話都控制正確的目標。"
                            )
                        ) {
                            Toggle("", isOn: weChatConfigurationBinding)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText(
                                "settings.wechat.integration.autoCreate",
                                english: "Auto-create Window for New Chats",
                                simplifiedChinese: "新聊天自动创建窗口",
                                traditionalChinese: "新聊天自動建立視窗"
                            ),
                            subtitle: localizedSettingsText(
                                "settings.wechat.integration.autoCreate.subtitle",
                                english: "When a chat has no explicit binding yet, create a fresh window so its work stays isolated.",
                                simplifiedChinese: "当聊天还没有明确绑定时，自动创建新窗口，避免不同会话混在一起。",
                                traditionalChinese: "當聊天還沒有明確綁定時，自動建立新視窗，避免不同會話混在一起。"
                            )
                        ) {
                            Toggle("", isOn: weChatAutoCreateWindowBinding)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(!weChatChannelStore.configuration.integrationEnabled)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText(
                                "settings.wechat.integration.typing",
                                english: "Send Typing While Agent Works",
                                simplifiedChinese: "执行期间发送“正在输入”",
                                traditionalChinese: "執行期間傳送「正在輸入」"
                            ),
                            subtitle: localizedSettingsText(
                                "settings.wechat.integration.typing.subtitle",
                                english: "Use the protocol typing signal while a bound window is still gathering results or executing work.",
                                simplifiedChinese: "当绑定窗口还在整理结果或执行任务时，通过协议发送“正在输入”提示。",
                                traditionalChinese: "當綁定視窗還在整理結果或執行任務時，透過協議傳送「正在輸入」提示。"
                            )
                        ) {
                            Toggle("", isOn: weChatTypingBinding)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(!weChatChannelStore.configuration.integrationEnabled)

                        SettingsCardDivider()

                        SettingsCardRow(
                            localizedSettingsText(
                                "settings.wechat.integration.progress",
                                english: "Mirror Window Progress in Replies",
                                simplifiedChinese: "在回复中同步窗口进度",
                                traditionalChinese: "在回覆中同步視窗進度"
                            ),
                            subtitle: localizedSettingsText(
                                "settings.wechat.integration.progress.subtitle",
                                english: "Summarize the current bound window goal, status, and progress when replying from WeChat.",
                                simplifiedChinese: "通过微信回复时，附带当前绑定窗口的目标、状态和进度摘要。",
                                traditionalChinese: "透過微信回覆時，附帶目前綁定視窗的目標、狀態與進度摘要。"
                            )
                        ) {
                            Toggle("", isOn: weChatProgressMirrorBinding)
                                .labelsHidden()
                                .controlSize(.small)
                        }
                        .disabled(!weChatChannelStore.configuration.integrationEnabled)

                        SettingsCardDivider()

                        SettingsCardNote(
                            localizedSettingsText(
                                "settings.wechat.integration.note",
                                english: "Recommended flow: add one bot account, let each WeChat chat bind to one window or workspace, and keep different projects split across separate chats.",
                                simplifiedChinese: "推荐流程：先添加一个机器人账号，再让每个微信会话绑定到一个窗口或工作区，不同项目拆分到不同聊天中。",
                                traditionalChinese: "推薦流程：先新增一個機器人帳號，再讓每個微信會話綁定到一個視窗或工作區，不同專案拆分到不同聊天中。"
                            )
                        )
                    }

                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(
                                        localizedSettingsText(
                                            "settings.wechat.accounts.title",
                                            english: "Bot Accounts and Chat Routes",
                                            simplifiedChinese: "机器人账号与聊天路由",
                                            traditionalChinese: "機器人帳號與聊天路由"
                                        )
                                    )
                                    .font(.system(size: 13, weight: .semibold))

                                    Text(
                                        localizedSettingsText(
                                            "settings.wechat.accounts.subtitle",
                                            english: "Each account keeps its own token/cursor. Each chat route should point to exactly one destination.",
                                            simplifiedChinese: "每个账号保存自己的 token 和游标；每个聊天路由都应该只指向一个目标。",
                                            traditionalChinese: "每個帳號保存自己的 token 與游標；每個聊天路由都應該只指向一個目標。"
                                        )
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 0)

                                Button(
                                    localizedSettingsText(
                                        "settings.wechat.accounts.add",
                                        english: "Add Account",
                                        simplifiedChinese: "添加账号",
                                        traditionalChinese: "新增帳號"
                                    )
                                ) {
                                    weChatChannelStore.addAccount()
                                    if let accountId = weChatChannelStore.configuration.accounts.last?.id {
                                        expandedWeChatAccountIds.insert(accountId)
                                        weChatBotTokenDrafts[accountId] = ""
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }

                            if weChatChannelStore.configuration.accounts.isEmpty {
                                Text(
                                    localizedSettingsText(
                                        "settings.wechat.accounts.empty",
                                        english: "No WeChat bot accounts yet. Add one account, then define one or more chat routes below it.",
                                        simplifiedChinese: "还没有微信机器人账号。先添加账号，再在该账号下定义一个或多个聊天路由。",
                                        traditionalChinese: "還沒有微信機器人帳號。先新增帳號，再在該帳號下定義一個或多個聊天路由。"
                                    )
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                            } else {
                                HStack(spacing: 8) {
                                    SettingsSummaryBadge(
                                        title: localizedSettingsText(
                                            "settings.wechat.summary.accounts",
                                            english: "Accounts",
                                            simplifiedChinese: "账号",
                                            traditionalChinese: "帳號"
                                        ),
                                        value: "\(weChatAccountCount)"
                                    )
                                    SettingsSummaryBadge(
                                        title: localizedSettingsText(
                                            "settings.wechat.summary.enabled",
                                            english: "Enabled",
                                            simplifiedChinese: "已启用",
                                            traditionalChinese: "已啟用"
                                        ),
                                        value: "\(weChatEnabledAccountCount)"
                                    )
                                    SettingsSummaryBadge(
                                        title: localizedSettingsText(
                                            "settings.wechat.summary.connected",
                                            english: "Connected",
                                            simplifiedChinese: "已连接",
                                            traditionalChinese: "已連線"
                                        ),
                                        value: "\(weChatConnectedAccountCount)"
                                    )
                                    SettingsSummaryBadge(
                                        title: localizedSettingsText(
                                            "settings.wechat.summary.routes",
                                            english: "Routes",
                                            simplifiedChinese: "路由",
                                            traditionalChinese: "路由"
                                        ),
                                        value: "\(weChatRouteCount)"
                                    )
                                }
                                .padding(.top, 2)

                                ForEach(weChatChannelStore.configuration.accounts) { account in
                                    DisclosureGroup(
                                        isExpanded: Binding(
                                            get: { expandedWeChatAccountIds.contains(account.id) },
                                            set: { isExpanded in
                                                if isExpanded {
                                                    expandedWeChatAccountIds.insert(account.id)
                                                } else {
                                                    expandedWeChatAccountIds.remove(account.id)
                                                }
                                            }
                                        )
                                    ) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack(spacing: 10) {
                                                TextField(
                                                    localizedSettingsText(
                                                        "settings.wechat.account.name.placeholder",
                                                        english: "Account name",
                                                        simplifiedChinese: "账号名称",
                                                        traditionalChinese: "帳號名稱"
                                                    ),
                                                    text: weChatAccountStringBinding(accountId: account.id, keyPath: \.displayName)
                                                )
                                                .textFieldStyle(.roundedBorder)

                                                Toggle(
                                                    localizedSettingsText(
                                                        "settings.wechat.account.enabled",
                                                        english: "Enabled",
                                                        simplifiedChinese: "启用",
                                                        traditionalChinese: "啟用"
                                                    ),
                                                    isOn: weChatAccountBoolBinding(accountId: account.id, keyPath: \.isEnabled)
                                                )
                                                .toggleStyle(.switch)
                                                .controlSize(.small)

                                                Spacer(minLength: 0)

                                                Button(
                                                    localizedSettingsText(
                                                        "settings.wechat.account.remove",
                                                        english: "Remove",
                                                        simplifiedChinese: "移除",
                                                        traditionalChinese: "移除"
                                                    )
                                                ) {
                                                    try? WeChatBotTokenStore.clearToken(for: account.id)
                                                    weChatChannelStore.removeAccount(account.id)
                                                    expandedWeChatAccountIds.remove(account.id)
                                                    weChatBotTokenDrafts[account.id] = nil
                                                    weChatAccountStatusMessages[account.id] = nil
                                                    weChatAccountStatusErrors.remove(account.id)
                                                }
                                                .buttonStyle(.bordered)
                                                .controlSize(.small)
                                            }

                                            HStack(alignment: .center, spacing: 8) {
                                                SecureField(
                                                    localizedSettingsText(
                                                        "settings.wechat.account.token.placeholder",
                                                        english: "Paste bot token",
                                                        simplifiedChinese: "粘贴机器人 Token",
                                                        traditionalChinese: "貼上機器人 Token"
                                                    ),
                                                    text: weChatBotTokenDraftBinding(accountId: account.id)
                                                )
                                                .textFieldStyle(.roundedBorder)

                                                Button(
                                                    weChatHasSavedBotToken(account.id)
                                                        ? localizedSettingsText("settings.wechat.account.token.change", english: "Update Token", simplifiedChinese: "更新 Token", traditionalChinese: "更新 Token")
                                                        : localizedSettingsText("settings.wechat.account.token.save", english: "Save Token", simplifiedChinese: "保存 Token", traditionalChinese: "儲存 Token")
                                                ) {
                                                    saveWeChatBotToken(for: account.id)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .controlSize(.small)
                                                .disabled((weChatBotTokenDrafts[account.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                                                if weChatHasSavedBotToken(account.id) {
                                                    Button(
                                                        localizedSettingsText(
                                                            "settings.wechat.account.token.clear",
                                                            english: "Clear",
                                                            simplifiedChinese: "清除",
                                                            traditionalChinese: "清除"
                                                        )
                                                    ) {
                                                        clearWeChatBotToken(for: account.id)
                                                    }
                                                    .buttonStyle(.bordered)
                                                    .controlSize(.small)
                                                }
                                            }

                                            HStack(spacing: 8) {
                                                if weChatHasSavedBotToken(account.id) {
                                                    SettingsInlinePill(
                                                        text: localizedSettingsText("settings.wechat.account.token.savedBadge", english: "Token saved locally", simplifiedChinese: "Token 已本地保存", traditionalChinese: "Token 已本地儲存"),
                                                        tint: .green
                                                    )
                                                }
                                                if !account.tokenHint.isEmpty {
                                                    SettingsInlinePill(
                                                        text: localizedSettingsText("settings.wechat.account.token.suffix", english: "Last 6", simplifiedChinese: "后 6 位", traditionalChinese: "後 6 位") + " · \(account.tokenHint)",
                                                        tint: .secondary
                                                    )
                                                }
                                                SettingsInlinePill(
                                                    text: "\(account.bindings.count) " + localizedSettingsText("settings.wechat.summary.routes", english: "routes", simplifiedChinese: "路由", traditionalChinese: "路由"),
                                                    tint: .blue
                                                )
                                            }

                                            if let message = weChatAccountStatusMessages[account.id] {
                                                Text(message)
                                                    .font(.caption)
                                                    .foregroundStyle(weChatAccountStatusErrors.contains(account.id) ? Color.red : Color.secondary)
                                            }

                                            DisclosureGroup(
                                                localizedSettingsText(
                                                    "settings.wechat.account.advanced",
                                                    english: "Advanced account fields",
                                                    simplifiedChinese: "高级账号字段",
                                                    traditionalChinese: "進階帳號欄位"
                                                )
                                            ) {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    HStack(spacing: 10) {
                                                        TextField(
                                                            localizedSettingsText(
                                                                "settings.wechat.account.botId",
                                                                english: "Bot ID",
                                                                simplifiedChinese: "机器人 ID",
                                                                traditionalChinese: "機器人 ID"
                                                            ),
                                                            text: weChatAccountStringBinding(accountId: account.id, keyPath: \.botId)
                                                        )
                                                            .textFieldStyle(.roundedBorder)
                                                        TextField(
                                                            localizedSettingsText(
                                                                "settings.wechat.account.userId",
                                                                english: "User ID",
                                                                simplifiedChinese: "用户 ID",
                                                                traditionalChinese: "使用者 ID"
                                                            ),
                                                            text: weChatAccountStringBinding(accountId: account.id, keyPath: \.userId)
                                                        )
                                                            .textFieldStyle(.roundedBorder)
                                                    }

                                                    HStack(spacing: 10) {
                                                        TextField(
                                                            localizedSettingsText(
                                                                "settings.wechat.account.baseUrl",
                                                                english: "Base URL",
                                                                simplifiedChinese: "接口地址",
                                                                traditionalChinese: "介面位址"
                                                            ),
                                                            text: weChatAccountStringBinding(accountId: account.id, keyPath: \.baseURLString)
                                                        )
                                                            .textFieldStyle(.roundedBorder)
                                                        TextField(
                                                            localizedSettingsText(
                                                                "settings.wechat.account.routeTag",
                                                                english: "SKRouteTag",
                                                                simplifiedChinese: "路由标签",
                                                                traditionalChinese: "路由標籤"
                                                            ),
                                                            text: weChatAccountStringBinding(accountId: account.id, keyPath: \.routeTag)
                                                        )
                                                            .textFieldStyle(.roundedBorder)
                                                            .frame(width: 160)
                                                    }

                                                    Picker("", selection: weChatAccountStateBinding(accountId: account.id)) {
                                                        ForEach(WeChatAccountConnectionState.allCases) { state in
                                                            Text(state.label).tag(state)
                                                        }
                                                    }
                                                    .labelsHidden()
                                                    .pickerStyle(.menu)
                                                    .frame(width: 220, alignment: .leading)
                                                }
                                                .padding(.top, 8)
                                            }

                                            Divider()

                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(
                                                        localizedSettingsText(
                                                            "settings.wechat.routes.title",
                                                            english: "Chat Routes",
                                                            simplifiedChinese: "聊天路由",
                                                            traditionalChinese: "聊天路由"
                                                        )
                                                    )
                                                    .font(.system(size: 12.5, weight: .semibold))
                                                    Text(
                                                        localizedSettingsText(
                                                            "settings.wechat.routes.subtitle",
                                                            english: "Bind each WeChat chat to exactly one window or workspace.",
                                                            simplifiedChinese: "让每个微信聊天只绑定到一个窗口或工作区。",
                                                            traditionalChinese: "讓每個微信聊天只綁定到一個視窗或工作區。"
                                                        )
                                                    )
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                }

                                                Spacer(minLength: 0)

                                                Button(
                                                    localizedSettingsText(
                                                        "settings.wechat.binding.add",
                                                        english: "Add Chat Route",
                                                        simplifiedChinese: "添加聊天路由",
                                                        traditionalChinese: "新增聊天路由"
                                                    )
                                                ) {
                                                    weChatChannelStore.addBinding(to: account.id)
                                                    if let newBindingId = weChatChannelStore.configuration.accounts.first(where: { $0.id == account.id })?.bindings.last?.id {
                                                        expandedWeChatBindingIds.insert(newBindingId)
                                                    }
                                                }
                                                .buttonStyle(.bordered)
                                                .controlSize(.small)
                                            }

                                            if account.bindings.isEmpty {
                                                Text(
                                                    localizedSettingsText(
                                                        "settings.wechat.binding.empty",
                                                        english: "No chat routes yet. Add at least one route so incoming WeChat sessions know where to run.",
                                                        simplifiedChinese: "还没有聊天路由。至少添加一个路由，微信会话才能知道该落到哪里执行。",
                                                        traditionalChinese: "還沒有聊天路由。至少新增一個路由，微信會話才能知道該落到哪裡執行。"
                                                    )
                                                )
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            } else {
                                                ForEach(account.bindings) { binding in
                                                    DisclosureGroup(
                                                        isExpanded: Binding(
                                                            get: { expandedWeChatBindingIds.contains(binding.id) },
                                                            set: { isExpanded in
                                                                if isExpanded {
                                                                    expandedWeChatBindingIds.insert(binding.id)
                                                                } else {
                                                                    expandedWeChatBindingIds.remove(binding.id)
                                                                }
                                                            }
                                                        )
                                                    ) {
                                                        VStack(alignment: .leading, spacing: 10) {
                                                            HStack(spacing: 8) {
                                                                TextField(
                                                                    localizedSettingsText(
                                                                        "settings.wechat.binding.title.placeholder",
                                                                        english: "Route label",
                                                                        simplifiedChinese: "路由名称",
                                                                        traditionalChinese: "路由名稱"
                                                                    ),
                                                                    text: weChatBindingStringBinding(accountId: account.id, bindingId: binding.id, keyPath: \.title)
                                                                )
                                                                .textFieldStyle(.roundedBorder)

                                                                TextField(
                                                                    localizedSettingsText(
                                                                        "settings.wechat.binding.contact.placeholder",
                                                                        english: "WeChat contact / memo",
                                                                        simplifiedChinese: "微信联系人 / 备注",
                                                                        traditionalChinese: "微信聯絡人 / 備註"
                                                                    ),
                                                                    text: weChatBindingStringBinding(accountId: account.id, bindingId: binding.id, keyPath: \.contactLabel)
                                                                )
                                                                .textFieldStyle(.roundedBorder)
                                                            }

                                                            HStack(spacing: 8) {
                                                                TextField(
                                                                    localizedSettingsText(
                                                                        "settings.wechat.binding.session.placeholder",
                                                                        english: "session_id",
                                                                        simplifiedChinese: "session_id",
                                                                        traditionalChinese: "session_id"
                                                                    ),
                                                                    text: weChatBindingStringBinding(accountId: account.id, bindingId: binding.id, keyPath: \.sessionId)
                                                                )
                                                                .textFieldStyle(.roundedBorder)

                                                                weChatDestinationPicker(accountId: account.id, bindingId: binding.id)
                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                            }

                                                            HStack(spacing: 8) {
                                                                Button(weChatCurrentWindowQuickBindTitle) {
                                                                    bindWeChatRouteToCurrentWindow(accountId: account.id, bindingId: binding.id)
                                                                }
                                                                .buttonStyle(.bordered)
                                                                .controlSize(.small)
                                                                .disabled(AppDelegate.shared?.currentWindowMoveTarget() == nil)

                                                                Button(weChatCurrentWorkspaceQuickBindTitle) {
                                                                    bindWeChatRouteToCurrentWorkspace(accountId: account.id, bindingId: binding.id)
                                                                }
                                                                .buttonStyle(.bordered)
                                                                .controlSize(.small)
                                                                .disabled(AppDelegate.shared?.currentWorkspaceMoveTarget() == nil)

                                                                Spacer(minLength: 0)
                                                            }

                                                            HStack(spacing: 12) {
                                                                Toggle(
                                                                    localizedSettingsText(
                                                                        "settings.wechat.binding.typing",
                                                                        english: "Typing",
                                                                        simplifiedChinese: "输入提示",
                                                                        traditionalChinese: "輸入提示"
                                                                    ),
                                                                    isOn: weChatBindingBoolBinding(accountId: account.id, bindingId: binding.id, keyPath: \.sendTypingIndicator)
                                                                )
                                                                .toggleStyle(.switch)
                                                                .controlSize(.small)

                                                                Spacer(minLength: 0)

                                                                Button(role: .destructive) {
                                                                    weChatChannelStore.removeBinding(accountId: account.id, bindingId: binding.id)
                                                                    expandedWeChatBindingIds.remove(binding.id)
                                                                } label: {
                                                                    Text(
                                                                        localizedSettingsText(
                                                                            "settings.wechat.binding.remove",
                                                                            english: "Remove Route",
                                                                            simplifiedChinese: "删除路由",
                                                                            traditionalChinese: "刪除路由"
                                                                        )
                                                                    )
                                                                }
                                                                .buttonStyle(.bordered)
                                                                .controlSize(.small)
                                                            }

                                                            DisclosureGroup(
                                                                localizedSettingsText(
                                                                    "settings.wechat.binding.advanced",
                                                                    english: "Advanced route fields",
                                                                    simplifiedChinese: "高级路由字段",
                                                                    traditionalChinese: "進階路由欄位"
                                                                )
                                                            ) {
                                                                VStack(alignment: .leading, spacing: 8) {
                                                                    TextField(
                                                                        localizedSettingsText(
                                                                            "settings.wechat.binding.context.placeholder",
                                                                            english: "context_token hint",
                                                                            simplifiedChinese: "context_token 提示",
                                                                            traditionalChinese: "context_token 提示"
                                                                        ),
                                                                        text: weChatBindingStringBinding(accountId: account.id, bindingId: binding.id, keyPath: \.contextTokenHint)
                                                                    )
                                                                    .textFieldStyle(.roundedBorder)
                                                                }
                                                                .padding(.top, 8)
                                                            }
                                                        }
                                                        .padding(.top, 8)
                                                    } label: {
                                                        VStack(alignment: .leading, spacing: 6) {
                                                            HStack(spacing: 8) {
                                                                Text(binding.title.isEmpty ? localizedSettingsText("settings.wechat.binding.newTitle", english: "New Chat Route", simplifiedChinese: "新聊天路由", traditionalChinese: "新聊天路由") : binding.title)
                                                                    .font(.system(size: 12.5, weight: .semibold))
                                                                SettingsInlinePill(text: weChatBindingDestinationSummary(binding), tint: .blue)
                                                            }
                                                            Text(binding.contactLabel.isEmpty ? weChatBindingStatusSummary(binding) : binding.contactLabel + " · " + weChatBindingStatusSummary(binding))
                                                                .font(.caption)
                                                                .foregroundStyle(.secondary)
                                                                .lineLimit(2)
                                                        }
                                                    }
                                                    .padding(10)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .fill(Color(nsColor: .controlBackgroundColor).opacity(0.72))
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .stroke(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 1)
                                                    )
                                                    .onAppear {
                                                        ensureWeChatBindingExpanded(binding.id)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                    } label: {
                                        HStack(spacing: 10) {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(account.displayName.isEmpty ? localizedSettingsText("settings.wechat.account.defaultName", english: "WeChat Bot", simplifiedChinese: "微信机器人", traditionalChinese: "微信機器人") : account.displayName)
                                                    .font(.system(size: 13, weight: .semibold))
                                                Text((account.baseURLString.isEmpty ? "https://ilinkai.weixin.qq.com" : account.baseURLString) + " · " + "\(account.bindings.count) " + localizedSettingsText("settings.wechat.summary.routes", english: "routes", simplifiedChinese: "路由", traditionalChinese: "路由"))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }

                                            Spacer(minLength: 0)

                                            Circle()
                                                .fill(weChatAccountStatusTint(account.connectionState))
                                                .frame(width: 8, height: 8)
                                            Text(account.connectionState.label)
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(weChatAccountStatusTint(account.connectionState))
                                            if weChatHasSavedBotToken(account.id) {
                                                SettingsInlinePill(
                                                    text: localizedSettingsText("settings.wechat.account.token.savedBadge", english: "Token saved", simplifiedChinese: "已保存 Token", traditionalChinese: "已儲存 Token"),
                                                    tint: .green
                                                )
                                            }
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.primary.opacity(0.035))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                                    )
                                    .onAppear {
                                        ensureWeChatDraftState(for: account)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }

                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizedSettingsText("settings.automation.quickImport.title", english: "Quick Import", simplifiedChinese: "快速导入", traditionalChinese: "快速匯入"))
                                    .font(.system(size: 13, weight: .semibold))
                                Text(localizedSettingsText("settings.automation.quickImport.subtitle", english: "Pull editor defaults into icc and install agent notification hooks with one click.", simplifiedChinese: "一键把编辑器默认项导入 icc，并安装代理通知集成。", traditionalChinese: "一鍵把編輯器預設匯入 icc，並安裝代理通知整合。"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            HStack(spacing: 8) {
                                Button(TerminalProfileImportSource.vscode.displayName) {
                                    applyTerminalProfileImport(.vscode)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Button(TerminalProfileImportSource.cursor.displayName) {
                                    applyTerminalProfileImport(.cursor)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Button(AgentIntegrationInstallSource.claudeCode.displayName) {
                                    installAgentIntegration(.claudeCode)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Button(AgentIntegrationInstallSource.codex.displayName) {
                                    installAgentIntegration(.codex)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }

                            Text(localizedSettingsText("settings.automation.quickImport.footnote", english: "VS Code and Cursor sync terminal font and color defaults. Claude Code and Codex add icc notification hooks without touching your other settings.", simplifiedChinese: "VS Code 和 Cursor 会同步终端字体与颜色默认值。Claude Code 和 Codex 会添加 icc 通知钩子，不影响你的其他设置。", traditionalChinese: "VS Code 和 Cursor 會同步終端字體與顏色預設。Claude Code 和 Codex 會加入 icc 通知鉤子，不影響你的其他設定。"))
                                .font(.system(size: 10.5))
                                .foregroundStyle(.tertiary)
                                .fixedSize(horizontal: false, vertical: true)

                            if let quickImportStatusMessage {
                                Text(quickImportStatusMessage)
                                    .font(.caption)
                                    .foregroundStyle(quickImportStatusIsError ? Color.red : Color.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }

                    SettingsCard {
                        SettingsPickerRow(
                            String(localized: "settings.automation.socketMode", defaultValue: "Socket Control Mode"),
                            subtitle: selectedSocketControlMode.description,
                            controlWidth: pickerColumnWidth,
                            selection: socketModeSelection,
                            accessibilityId: "AutomationSocketModePicker"
                        ) {
                            ForEach(SocketControlMode.uiCases) { mode in
                                Text(mode.displayName).tag(mode.rawValue)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardNote(String(localized: "settings.automation.socketMode.note", defaultValue: "Controls access to the local Unix socket for programmatic control. Choose a mode that matches your threat model."))
                        if selectedSocketControlMode == .password {
                            SettingsCardDivider()
                            SettingsCardRow(
                                String(localized: "settings.automation.socketPassword", defaultValue: "Socket Password"),
                                subtitle: hasSocketPasswordConfigured
                                    ? String(localized: "settings.automation.socketPassword.subtitleSet", defaultValue: "Stored in Application Support.")
                                    : String(localized: "settings.automation.socketPassword.subtitleUnset", defaultValue: "No password set. External clients will be blocked until one is configured.")
                            ) {
                                HStack(spacing: 8) {
                                    SecureField(String(localized: "settings.automation.socketPassword.placeholder", defaultValue: "Password"), text: $socketPasswordDraft)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 170)
                                    Button(hasSocketPasswordConfigured ? String(localized: "settings.automation.socketPassword.change", defaultValue: "Change") : String(localized: "settings.automation.socketPassword.set", defaultValue: "Set")) {
                                        saveSocketPassword()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .disabled(socketPasswordDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    if hasSocketPasswordConfigured {
                                        Button(String(localized: "settings.automation.socketPassword.clear", defaultValue: "Clear")) {
                                            clearSocketPassword()
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                    }
                                }
                            }
                            if let message = socketPasswordStatusMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(socketPasswordStatusIsError ? Color.red : Color.secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 8)
                            }
                        }
                        if selectedSocketControlMode == .allowAll {
                            SettingsCardDivider()
                            Text(String(localized: "settings.automation.openAccessWarning", defaultValue: "Warning: Full open access makes the control socket world-readable/writable on this Mac and disables auth checks. Use only for local debugging."))
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                        }
                        SettingsCardNote(String(localized: "settings.automation.socketOverrides.note", defaultValue: "Overrides: ICC_SOCKET_ENABLE, ICC_SOCKET_MODE, and ICC_SOCKET_PATH (set ICC_ALLOW_SOCKET_OVERRIDE=1 for stable/nightly builds)."))
                    }

                    SettingsCard {
                        SettingsCardRow(
                            String(localized: "settings.automation.claudeCode", defaultValue: "Claude Code Integration"),
                            subtitle: claudeCodeHooksEnabled
                                ? String(localized: "settings.automation.claudeCode.subtitleOn", defaultValue: "Sidebar shows Claude session status and notifications.")
                                : String(localized: "settings.automation.claudeCode.subtitleOff", defaultValue: "Claude Code runs without icc integration.")
                        ) {
                            Toggle("", isOn: $claudeCodeHooksEnabled)
                                .labelsHidden()
                                .controlSize(.small)
                                .accessibilityIdentifier("SettingsClaudeCodeHooksToggle")
                        }

                        SettingsCardDivider()

                        SettingsCardNote(String(localized: "settings.automation.claudeCode.note", defaultValue: "When enabled, icc wraps the claude command to inject session tracking and notification hooks. Disable if you prefer to manage Claude Code hooks yourself."))
                    }

                    SettingsCard {
                        SettingsCardRow(String(localized: "settings.automation.portBase", defaultValue: "Port Base"), subtitle: String(localized: "settings.automation.portBase.subtitle", defaultValue: "Starting port for ICC_PORT env var."), controlWidth: pickerColumnWidth) {
                            TextField("", value: $iccPortBase, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(String(localized: "settings.automation.portRange", defaultValue: "Port Range Size"), subtitle: String(localized: "settings.automation.portRange.subtitle", defaultValue: "Number of ports per workspace."), controlWidth: pickerColumnWidth) {
                            TextField("", value: $iccPortRange, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }

                        SettingsCardDivider()

                        SettingsCardNote(String(localized: "settings.automation.port.note", defaultValue: "Each workspace gets ICC_PORT and ICC_PORT_END env vars with a dedicated port range. New terminals inherit these values."))
                    }

                    SettingsSectionHeader(title: SettingsSidebarSection.browser.title)
                        .id(SettingsSidebarSection.browser.rawValue)
                        .accessibilityIdentifier("SettingsBrowserSection")
                    SettingsCard {
                        SettingsPickerRow(
                            String(localized: "settings.browser.searchEngine", defaultValue: "Default Search Engine"),
                            subtitle: String(localized: "settings.browser.searchEngine.subtitle", defaultValue: "Used by the browser address bar when input is not a URL."),
                            controlWidth: pickerColumnWidth,
                            selection: $browserSearchEngine
                        ) {
                            ForEach(BrowserSearchEngine.allCases) { engine in
                                Text(engine.displayName).tag(engine.rawValue)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(String(localized: "settings.browser.searchSuggestions", defaultValue: "Show Search Suggestions")) {
                            Toggle("", isOn: $browserSearchSuggestionsEnabled)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsPickerRow(
                            String(localized: "settings.browser.theme", defaultValue: "Browser Theme"),
                            subtitle: selectedBrowserThemeMode == .system
                                ? String(localized: "settings.browser.theme.subtitleSystem", defaultValue: "System follows app and macOS appearance.")
                                : String(localized: "settings.browser.theme.subtitleForced", defaultValue: "\(selectedBrowserThemeMode.displayName) forces that color scheme for compatible pages."),
                            controlWidth: pickerColumnWidth,
                            selection: browserThemeModeSelection
                        ) {
                            ForEach(BrowserThemeMode.allCases) { mode in
                                Text(mode.displayName).tag(mode.rawValue)
                            }
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            String(localized: "settings.browser.openTerminalLinks", defaultValue: "Open Terminal Links in icc Browser"),
                            subtitle: String(localized: "settings.browser.openTerminalLinks.subtitle", defaultValue: "When off, links clicked in terminal output open in your default browser.")
                        ) {
                            Toggle("", isOn: $openTerminalLinksInIccBrowser)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        SettingsCardRow(
                            String(localized: "settings.browser.interceptOpen", defaultValue: "Intercept open http(s) in Terminal"),
                            subtitle: String(localized: "settings.browser.interceptOpen.subtitle", defaultValue: "When off, `open https://...` and `open http://...` always use your default browser.")
                        ) {
                            Toggle("", isOn: $interceptTerminalOpenCommandInIccBrowser)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        if openTerminalLinksInIccBrowser || interceptTerminalOpenCommandInIccBrowser {
                            SettingsCardDivider()

                            VStack(alignment: .leading, spacing: 6) {
                                SettingsCardRow(
                                    String(localized: "settings.browser.hostWhitelist", defaultValue: "Hosts to Open in Embedded Browser"),
                                    subtitle: String(localized: "settings.browser.hostWhitelist.subtitle", defaultValue: "Applies to terminal link clicks and intercepted `open https://...` calls. Only these hosts open in icc. Others open in your default browser. One host or wildcard per line (for example: example.com, *.internal.example). Leave empty to open all hosts in icc.")
                                ) {
                                    EmptyView()
                                }

                                TextEditor(text: $browserHostWhitelist)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minHeight: 60, maxHeight: 120)
                                    .scrollContentBackground(.hidden)
                                    .padding(6)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)
                            }

                            SettingsCardDivider()

                            VStack(alignment: .leading, spacing: 6) {
                                SettingsCardRow(
                                    String(localized: "settings.browser.externalPatterns", defaultValue: "URLs to Always Open Externally"),
                                    subtitle: String(localized: "settings.browser.externalPatterns.subtitle", defaultValue: "Applies to terminal link clicks and intercepted `open https://...` calls. One rule per line. Plain text matches any URL substring, or prefix with `re:` for regex (for example: openai.com/usage, re:^https?://[^/]*\\.example\\.com/(billing|usage)).")
                                ) {
                                    EmptyView()
                                }

                                TextEditor(text: $browserExternalOpenPatterns)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minHeight: 60, maxHeight: 120)
                                    .scrollContentBackground(.hidden)
                                    .padding(6)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)
                            }
                        }

                        SettingsCardDivider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "settings.browser.httpAllowlist", defaultValue: "HTTP Hosts Allowed in Embedded Browser"))
                                .font(.system(size: 13, weight: .semibold))

                            Text(String(localized: "settings.browser.httpAllowlist.description", defaultValue: "Controls which HTTP (non-HTTPS) hosts can open in icc without a warning prompt. Defaults include localhost, 127.0.0.1, ::1, 0.0.0.0, and *.localtest.me."))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            TextEditor(text: $browserInsecureHTTPAllowlistDraft)
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .frame(minHeight: 86)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color(nsColor: .textBackgroundColor))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                                )
                                .accessibilityIdentifier("SettingsBrowserHTTPAllowlistField")

                            ViewThatFits(in: .horizontal) {
                                HStack(alignment: .center, spacing: 10) {
                                    Text(String(localized: "settings.browser.httpAllowlist.hint", defaultValue: "One host or wildcard per line (for example: localhost, 127.0.0.1, ::1, 0.0.0.0, *.localtest.me)."))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer(minLength: 0)

                                    Button(String(localized: "settings.browser.httpAllowlist.save", defaultValue: "Save")) {
                                        saveBrowserInsecureHTTPAllowlist()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .disabled(!browserInsecureHTTPAllowlistHasUnsavedChanges)
                                    .accessibilityIdentifier("SettingsBrowserHTTPAllowlistSaveButton")
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(localized: "settings.browser.httpAllowlist.hint", defaultValue: "One host or wildcard per line (for example: localhost, 127.0.0.1, ::1, 0.0.0.0, *.localtest.me)."))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    HStack {
                                        Spacer(minLength: 0)
                                        Button(String(localized: "settings.browser.httpAllowlist.save", defaultValue: "Save")) {
                                            saveBrowserInsecureHTTPAllowlist()
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        .disabled(!browserInsecureHTTPAllowlistHasUnsavedChanges)
                                        .accessibilityIdentifier("SettingsBrowserHTTPAllowlistSaveButton")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                        SettingsCardDivider()

                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "settings.browser.import", defaultValue: "Import Browser Data"))
                                    .font(.system(size: 13, weight: .semibold))

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(String(localized: "browser.import.hint.title", defaultValue: "Import browser data"))
                                        .font(.system(size: 12.5, weight: .semibold))

                                    Text(browserImportSubtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Text(String(localized: "browser.import.hint.settingsFootnote", defaultValue: "You can always find this in Settings > Browser."))
                                        .font(.system(size: 10.5))
                                        .foregroundStyle(.tertiary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(nsColor: .controlBackgroundColor))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
                                )
                            }

                            HStack(spacing: 8) {
                                Button(String(localized: "settings.browser.import.choose", defaultValue: "Choose…")) {
                                    DispatchQueue.main.async {
                                        BrowserDataImportCoordinator.shared.presentImportDialog()
                                        refreshDetectedImportBrowsers()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .accessibilityIdentifier("SettingsBrowserImportChooseButton")

                                Button(String(localized: "settings.browser.import.refresh", defaultValue: "Refresh")) {
                                    refreshDetectedImportBrowsers()
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            .accessibilityIdentifier("SettingsBrowserImportActions")

                            Toggle(
                                String(localized: "settings.browser.import.hint.show", defaultValue: "Show import hint on blank browser tabs"),
                                isOn: browserImportHintVisibilityBinding
                            )
                            .controlSize(.small)
                            .accessibilityIdentifier("SettingsBrowserImportHintToggle")

                            Text(browserImportHintSettingsNote)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .id(SettingsNavigationTarget.browserImport)
                        .accessibilityIdentifier("SettingsBrowserImportSection")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                        SettingsCardDivider()

                        SettingsCardRow(String(localized: "settings.browser.history", defaultValue: "Browsing History"), subtitle: browserHistorySubtitle) {
                            Button(String(localized: "settings.browser.history.clearButton", defaultValue: "Clear History…")) {
                                showClearBrowserHistoryConfirmation = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .disabled(browserHistoryEntryCount == 0)
                        }
                    }

                    SettingsSectionHeader(title: SettingsSidebarSection.keyboardShortcuts.title)
                        .id(SettingsSidebarSection.keyboardShortcuts.rawValue)
                        .accessibilityIdentifier("SettingsKeyboardShortcutsSection")
                    SettingsCard {
                        SettingsCardRow(
                            String(localized: "settings.shortcuts.showHints", defaultValue: "Show Cmd/Ctrl-Hold Shortcut Hints"),
                            subtitle: showShortcutHintsOnCommandHold
                                ? String(localized: "settings.shortcuts.showHints.subtitleOn", defaultValue: "Holding Cmd (sidebar/titlebar) or Ctrl/Cmd (pane tabs) shows shortcut hint pills.")
                                : String(localized: "settings.shortcuts.showHints.subtitleOff", defaultValue: "Holding Cmd or Ctrl keeps shortcut hint pills hidden.")
                        ) {
                            Toggle("", isOn: $showShortcutHintsOnCommandHold)
                                .labelsHidden()
                                .controlSize(.small)
                        }

                        SettingsCardDivider()

                        let actions = KeyboardShortcutSettings.Action.allCases
                        ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                            ShortcutSettingRow(action: action)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                            if index < actions.count - 1 {
                                SettingsCardDivider()
                            }
                        }
                    }
                    .id(shortcutResetToken)

                    Text(String(localized: "settings.shortcuts.recordHint", defaultValue: "Click a shortcut value to record a new shortcut."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 2)
                        .accessibilityIdentifier("ShortcutRecordingHint")

                    SettingsSectionHeader(title: SettingsSidebarSection.reset.title)
                        .id(SettingsSidebarSection.reset.rawValue)
                    SettingsCard {
                        HStack {
                            Spacer(minLength: 0)
                            Button(String(localized: "settings.reset.resetAll", defaultValue: "Reset All Settings")) {
                                resetAllSettings()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.regular)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, contentTopInset)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: SettingsTopOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("SettingsScrollArea")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "SettingsScrollArea")
            .onPreferenceChange(SettingsTopOffsetPreferenceKey.self) { value in
                if topBlurBaselineOffset == nil {
                    topBlurBaselineOffset = value
                }
                topBlurOpacity = blurOpacity(forContentOffset: value)
            }
                }

            ZStack(alignment: .top) {
                SettingsTitleLeadingInsetReader(inset: $settingsTitleLeadingInset)
                    .frame(width: 0, height: 0)

                AboutVisualEffectBackground(material: .underWindowBackground, blendingMode: .withinWindow)
                    .mask(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.9),
                                Color.black.opacity(0.64),
                                Color.black.opacity(0.36),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.52)

                AboutVisualEffectBackground(material: .underWindowBackground, blendingMode: .withinWindow)
                    .mask(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.98),
                                Color.black.opacity(0.78),
                                Color.black.opacity(0.42),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.14 + (topBlurOpacity * 0.86))

                HStack {
                    Text(String(localized: "settings.title", defaultValue: "Settings"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.92))
                    Spacer(minLength: 0)
                }
                .padding(.leading, settingsTitleLeadingInset)
                .padding(.top, 12)
            }
                .frame(height: 62)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(.container, edges: .top)
                .overlay(
                    Rectangle()
                        .fill(Color(nsColor: .separatorColor).opacity(0.07))
                        .frame(height: 1),
                    alignment: .bottom
                )
                .allowsHitTesting(false)
        }
        .background(ICCCanvasBackground().ignoresSafeArea())
        .toggleStyle(.switch)
        .onAppear {
            BrowserHistoryStore.shared.loadIfNeeded()
            notificationStore.refreshAuthorizationStatus()
            browserThemeMode = BrowserThemeSettings.mode(defaults: .standard).rawValue
            browserImportHintVariantRaw = BrowserImportHintSettings.variant(for: browserImportHintVariantRaw).rawValue
            browserHistoryEntryCount = BrowserHistoryStore.shared.entries.count
            browserInsecureHTTPAllowlistDraft = browserInsecureHTTPAllowlist
            refreshDetectedImportBrowsers()
            reloadWorkspaceTabColorSettings()
            refreshNotificationCustomSoundStatus()
            selectedSettingsSection = .app
        }
        .onChange(of: notificationSound) { _, _ in
            refreshNotificationCustomSoundStatus()
        }
        .onChange(of: notificationSoundCustomFilePath) { _, _ in
            refreshNotificationCustomSoundStatus()
        }
        .onChange(of: browserInsecureHTTPAllowlist) { oldValue, newValue in
            // Keep draft in sync with external changes unless the user has local unsaved edits.
            if browserInsecureHTTPAllowlistDraft == oldValue {
                browserInsecureHTTPAllowlistDraft = newValue
            }
        }
        .onReceive(BrowserHistoryStore.shared.$entries) { entries in
            browserHistoryEntryCount = entries.count
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            reloadWorkspaceTabColorSettings()
        }
        .onReceive(NotificationCenter.default.publisher(for: SettingsNavigationRequest.notificationName)) { notification in
            guard let target = SettingsNavigationRequest.target(from: notification) else { return }
            scrollToSettingsSection(SettingsSidebarSection.from(navigationTarget: target), proxy: proxy)
        }
        .confirmationDialog(
            String(localized: "settings.browser.history.clearDialog.title", defaultValue: "Clear browser history?"),
            isPresented: $showClearBrowserHistoryConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "settings.browser.history.clearDialog.confirm", defaultValue: "Clear History"), role: .destructive) {
                BrowserHistoryStore.shared.clearHistory()
            }
            Button(String(localized: "settings.browser.history.clearDialog.cancel", defaultValue: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "settings.browser.history.clearDialog.message", defaultValue: "This removes visited-page suggestions from the browser omnibar."))
        }
        .confirmationDialog(
            String(localized: "settings.automation.openAccess.dialog.title", defaultValue: "Enable full open access?"),
            isPresented: $showOpenAccessConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "settings.automation.openAccess.dialog.confirm", defaultValue: "Enable Full Open Access"), role: .destructive) {
                socketControlMode = (pendingOpenAccessMode ?? .allowAll).rawValue
                pendingOpenAccessMode = nil
            }
            Button(String(localized: "settings.automation.openAccess.dialog.cancel", defaultValue: "Cancel"), role: .cancel) {
                pendingOpenAccessMode = nil
            }
        } message: {
            Text(String(localized: "settings.automation.openAccess.dialog.message", defaultValue: "This disables ancestry and password checks and opens the socket to all local users. Only enable when you understand the risk."))
        }
        .confirmationDialog(
            String(localized: "settings.app.language.restartDialog.title", defaultValue: "Restart to apply language change?"),
            isPresented: $showLanguageRestartAlert,
            titleVisibility: .visible
        ) {
            Button(String(localized: "settings.app.language.restartDialog.confirm", defaultValue: "Restart Now")) {
                relaunchApp()
            }
            Button(String(localized: "settings.app.language.restartDialog.later", defaultValue: "Later"), role: .cancel) {}
        }
        .alert(
            String(
                localized: "settings.notifications.sound.custom.error.title",
                defaultValue: "Custom Notification Sound Error"
            ),
            isPresented: $showNotificationCustomSoundErrorAlert
        ) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
        } message: {
            Text(notificationCustomSoundErrorAlertMessage)
        }
        }
    }

    private func relaunchApp() {
        let bundlePath = Bundle.main.bundlePath
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", "sleep 1 && open -n -- \"$RELAUNCH_PATH\""]
        task.environment = ["RELAUNCH_PATH": bundlePath]
        do {
            try task.run()
        } catch {
            return
        }
        NSApplication.shared.terminate(nil)
    }

    private func resetAllSettings() {
        isResettingSettings = true
        appLanguage = LanguageSettings.defaultLanguage.rawValue
        LanguageSettings.apply(.system)
        if appLanguage != LanguageSettings.languageAtLaunch.rawValue {
            showLanguageRestartAlert = true
        }
        appearanceMode = AppearanceSettings.defaultMode.rawValue
        appIconMode = AppIconSettings.defaultMode.rawValue
        AppIconSettings.applyIcon(.automatic)
        socketControlMode = SocketControlSettings.defaultMode.rawValue
        claudeCodeHooksEnabled = ClaudeCodeIntegrationSettings.defaultHooksEnabled
        sendAnonymousTelemetry = TelemetrySettings.defaultSendAnonymousTelemetry
        browserSearchEngine = BrowserSearchSettings.defaultSearchEngine.rawValue
        browserSearchSuggestionsEnabled = BrowserSearchSettings.defaultSearchSuggestionsEnabled
        browserThemeMode = BrowserThemeSettings.defaultMode.rawValue
        browserImportHintVariantRaw = BrowserImportHintSettings.defaultVariant.rawValue
        showBrowserImportHintOnBlankTabs = BrowserImportHintSettings.defaultShowOnBlankTabs
        isBrowserImportHintDismissed = BrowserImportHintSettings.defaultDismissed
        openTerminalLinksInIccBrowser = BrowserLinkOpenSettings.defaultOpenTerminalLinksInIccBrowser
        interceptTerminalOpenCommandInIccBrowser = BrowserLinkOpenSettings.defaultInterceptTerminalOpenCommandInIccBrowser
        browserHostWhitelist = BrowserLinkOpenSettings.defaultBrowserHostWhitelist
        browserExternalOpenPatterns = BrowserLinkOpenSettings.defaultBrowserExternalOpenPatterns
        browserInsecureHTTPAllowlist = BrowserInsecureHTTPSettings.defaultAllowlistText
        browserInsecureHTTPAllowlistDraft = BrowserInsecureHTTPSettings.defaultAllowlistText
        notificationSound = NotificationSoundSettings.defaultValue
        notificationSoundCustomFilePath = NotificationSoundSettings.defaultCustomFilePath
        notificationCustomSoundStatusMessage = nil
        notificationCustomSoundStatusIsError = false
        showNotificationCustomSoundErrorAlert = false
        notificationCustomSoundErrorAlertMessage = ""
        notificationCustomCommand = NotificationSoundSettings.defaultCustomCommand
        notificationDockBadgeEnabled = NotificationBadgeSettings.defaultDockBadgeEnabled
        notificationPaneRingEnabled = NotificationPaneRingSettings.defaultEnabled
        notificationPaneFlashEnabled = NotificationPaneFlashSettings.defaultEnabled
        showMenuBarExtra = MenuBarExtraSettings.defaultShowInMenuBar
        warnBeforeQuitShortcut = QuitWarningSettings.defaultWarnBeforeQuit
        commandPaletteRenameSelectAllOnFocus = CommandPaletteRenameSelectionSettings.defaultSelectAllOnFocus
        commandPaletteSearchAllSurfaces = CommandPaletteSwitcherSearchSettings.defaultSearchAllSurfaces
        ShortcutHintDebugSettings.resetVisibilityDefaults()
        alwaysShowShortcutHints = ShortcutHintDebugSettings.defaultAlwaysShowHints
        newWorkspacePlacement = WorkspacePlacementSettings.defaultPlacement.rawValue
        workspacePresentationMode = WorkspacePresentationModeSettings.defaultMode.rawValue
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: WorkspaceTitlebarSettings.showTitlebarKey)
        defaults.removeObject(forKey: WorkspaceButtonFadeSettings.modeKey)
        defaults.removeObject(forKey: WorkspaceButtonFadeSettings.legacyTitlebarControlsVisibilityModeKey)
        defaults.removeObject(forKey: WorkspaceButtonFadeSettings.legacyPaneTabBarControlsVisibilityModeKey)
        closeWorkspaceOnLastSurfaceShortcut = LastSurfaceCloseShortcutSettings.defaultValue
        paneFirstClickFocusEnabled = PaneFirstClickFocusSettings.defaultEnabled
        workspaceAutoReorder = WorkspaceAutoReorderSettings.defaultValue
        sidebarHideAllDetails = SidebarWorkspaceDetailSettings.defaultHideAllDetails
        sidebarShowNotificationMessage = SidebarWorkspaceDetailSettings.defaultShowNotificationMessage
        sidebarBranchVerticalLayout = SidebarBranchLayoutSettings.defaultVerticalLayout
        sidebarActiveTabIndicatorStyle = SidebarActiveTabIndicatorSettings.defaultStyle.rawValue
        sidebarShowBranchDirectory = true
        sidebarShowPullRequest = true
        openSidebarPullRequestLinksInIccBrowser = BrowserLinkOpenSettings.defaultOpenSidebarPullRequestLinksInIccBrowser
        showShortcutHintsOnCommandHold = ShortcutHintDebugSettings.defaultShowHintsOnCommandHold
        sidebarShowSSH = true
        remoteSSHTermModeRaw = RemoteSSHTermMode.defaultValue.rawValue
        sidebarShowPorts = true
        sidebarShowLog = true
        sidebarShowProgress = true
        sidebarShowMetadata = true
        sidebarTintHex = SidebarTintDefaults.hex
        sidebarTintHexLight = nil
        sidebarTintHexDark = nil
        sidebarTintOpacity = SidebarTintDefaults.opacity
        showOpenAccessConfirmation = false
        pendingOpenAccessMode = nil
        socketPasswordDraft = ""
        socketPasswordStatusMessage = nil
        socketPasswordStatusIsError = false
        refreshDetectedImportBrowsers()
        KeyboardShortcutSettings.resetAll()
        WorkspaceTabColorSettings.reset()
        reloadWorkspaceTabColorSettings()
        shortcutResetToken = UUID()
        DispatchQueue.main.async { isResettingSettings = false }
    }

    private func defaultTabColorBinding(for name: String) -> Binding<Color> {
        Binding(
            get: {
                let hex = WorkspaceTabColorSettings.defaultColorHex(named: name)
                return Color(nsColor: NSColor(hex: hex) ?? .systemBlue)
            },
            set: { newValue in
                let hex = NSColor(newValue).hexString()
                WorkspaceTabColorSettings.setDefaultColor(named: name, hex: hex)
                reloadWorkspaceTabColorSettings()
            }
        )
    }

    private func baseTabColorHex(for name: String) -> String {
        WorkspaceTabColorSettings.defaultPalette
            .first(where: { $0.name == name })?
            .hex ?? "#1565C0"
    }

    private func removeWorkspaceCustomColor(_ hex: String) {
        WorkspaceTabColorSettings.removeCustomColor(hex)
        reloadWorkspaceTabColorSettings()
    }

    private func resetWorkspaceTabColors() {
        WorkspaceTabColorSettings.reset()
        reloadWorkspaceTabColorSettings()
    }

    private func reloadWorkspaceTabColorSettings() {
        workspaceTabDefaultEntries = WorkspaceTabColorSettings.defaultPaletteWithOverrides()
        workspaceTabCustomColors = WorkspaceTabColorSettings.customColors()
    }

    private func applyTerminalProfileImport(_ source: TerminalProfileImportSource) {
        do {
            let profile = try importedTerminalProfile(from: source)
            try writeManagedGhosttyOverride(
                named: "profile-import",
                lines: [
                    "font-family = \"\(profile.fontFamily.replacingOccurrences(of: "\"", with: "\\\""))\"",
                    "font-size = \(String(format: "%.0f", profile.fontSize))",
                    "background = \(profile.backgroundHex)",
                    "foreground = \(profile.foregroundHex)",
                    "cursor-color = \(profile.cursorHex)",
                    "cursor-text = \(profile.cursorTextHex)",
                    "selection-background = \(profile.selectionBackgroundHex)",
                    "selection-foreground = \(profile.selectionForegroundHex)",
                ]
            )
            GhosttyConfig.invalidateLoadCache()
            GhosttyApp.shared.reloadConfiguration(source: "settings.quickImport.\(source.rawValue)")
            quickImportStatusIsError = false
            quickImportStatusMessage = localizedSettingsText(
                "settings.automation.quickImport.success",
                english: "\(source.displayName) imported. \(profile.summary)",
                simplifiedChinese: "已导入 \(source.displayName)。\(profile.summary)",
                traditionalChinese: "已匯入 \(source.displayName)。\(profile.summary)"
            )
        } catch {
            quickImportStatusIsError = true
            quickImportStatusMessage = error.localizedDescription
        }
    }

    private func installAgentIntegration(_ source: AgentIntegrationInstallSource) {
        do {
            let message: String
            switch source {
            case .claudeCode:
                message = try installClaudeCodeNotificationHook()
            case .codex:
                message = try installCodexNotificationHook()
            }
            quickImportStatusIsError = false
            quickImportStatusMessage = message
        } catch {
            quickImportStatusIsError = true
            quickImportStatusMessage = error.localizedDescription
        }
    }

    private func importedTerminalProfile(from source: TerminalProfileImportSource) throws -> ImportedTerminalProfile {
        let settings = try loadJSONObject(at: source.settingsURL)

        let fontSize = settingDouble(
            settings["terminal.integrated.fontSize"]
                ?? settings["editor.fontSize"]
        ) ?? 14
        let fontFamily = settingString(
            settings["terminal.integrated.fontFamily"]
                ?? settings["editor.fontFamily"]
        ) ?? "Menlo"
        let themeName = settingString(settings["workbench.colorTheme"])?.lowercased() ?? ""
        let isLightTheme = themeName.contains("light") || themeName.contains("day")

        if isLightTheme {
            return ImportedTerminalProfile(
                fontFamily: fontFamily,
                fontSize: fontSize,
                backgroundHex: "#FFFFFF",
                foregroundHex: "#1F2328",
                cursorHex: "#24292F",
                cursorTextHex: "#FFFFFF",
                selectionBackgroundHex: "#ADD6FF",
                selectionForegroundHex: "#1F2328",
                summary: localizedSettingsText(
                    "settings.automation.quickImport.summary.light",
                    english: "Applied a light terminal profile with \(fontFamily) \(Int(fontSize))pt.",
                    simplifiedChinese: "已应用浅色终端配置，字体为 \(fontFamily) \(Int(fontSize))pt。",
                    traditionalChinese: "已套用淺色終端設定，字體為 \(fontFamily) \(Int(fontSize))pt。"
                )
            )
        }

        let darkBackground = source == .cursor ? "#141414" : "#1F1F1F"
        let darkForeground = source == .cursor ? "#F5F5F5" : "#CCCCCC"
        let darkCursor = source == .cursor ? "#FFFFFF" : "#AEAFAD"
        return ImportedTerminalProfile(
            fontFamily: fontFamily,
            fontSize: fontSize,
            backgroundHex: darkBackground,
            foregroundHex: darkForeground,
            cursorHex: darkCursor,
            cursorTextHex: darkBackground,
            selectionBackgroundHex: "#264F78",
            selectionForegroundHex: "#FFFFFF",
            summary: localizedSettingsText(
                "settings.automation.quickImport.summary.dark",
                english: "Applied a dark terminal profile with \(fontFamily) \(Int(fontSize))pt.",
                simplifiedChinese: "已应用深色终端配置，字体为 \(fontFamily) \(Int(fontSize))pt。",
                traditionalChinese: "已套用深色終端設定，字體為 \(fontFamily) \(Int(fontSize))pt。"
            )
        )
    }

    private func loadJSONObject(at url: URL) throws -> [String: Any] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(
                domain: "icc.settings",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: localizedSettingsText(
                    "settings.automation.quickImport.fileMissing",
                    english: "Couldn’t find \(url.lastPathComponent) at \(url.path).",
                    simplifiedChinese: "未在 \(url.path) 找到 \(url.lastPathComponent)。",
                    traditionalChinese: "未在 \(url.path) 找到 \(url.lastPathComponent)。"
                )]
            )
        }

        let contents = try String(contentsOf: url, encoding: .utf8)
        return try parseJSONObject(contents, path: url.path)
    }

    private func installClaudeCodeNotificationHook() throws -> String {
        let settingsURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/settings.json")
        let notificationCommand = "command -v icc >/dev/null 2>&1 && icc notify --title 'Claude Code' --body 'Waiting for input' || osascript -e 'display notification \"Waiting for input\" with title \"Claude Code\"'"

        var root = try loadOrCreateJSONObject(at: settingsURL)
        var hooks = root["hooks"] as? [String: Any] ?? [:]
        var notifications = hooks["Notification"] as? [[String: Any]] ?? []

        let alreadyInstalled = notifications.contains { entry in
            guard let hookEntries = entry["hooks"] as? [[String: Any]] else { return false }
            return hookEntries.contains { hook in
                (hook["command"] as? String) == notificationCommand
            }
        }

        if !alreadyInstalled {
            notifications.append([
                "matcher": "idle_prompt",
                "hooks": [[
                    "type": "command",
                    "command": notificationCommand,
                ]],
            ])
        }

        hooks["Notification"] = notifications
        root["hooks"] = hooks
        try writeJSONObject(root, to: settingsURL)
        claudeCodeHooksEnabled = true

        return alreadyInstalled
            ? localizedSettingsText("settings.automation.quickImport.claude.exists", english: "Claude Code already has the icc notification hook.", simplifiedChinese: "Claude Code 已存在 icc 通知钩子。", traditionalChinese: "Claude Code 已存在 icc 通知鉤子。")
            : localizedSettingsText("settings.automation.quickImport.claude.installed", english: "Installed the icc notification hook for Claude Code.", simplifiedChinese: "已为 Claude Code 安装 icc 通知钩子。", traditionalChinese: "已為 Claude Code 安裝 icc 通知鉤子。")
    }

    private func installCodexNotificationHook() throws -> String {
        let configURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/config.toml")
        let startMarker = "# >>> icc codex notify >>>"
        let endMarker = "# <<< icc codex notify <<<"
        let managedBlock = [
            startMarker,
            "notify = [\"bash\", \"-lc\", \"MSG=$(echo \\\"$1\\\" | jq -r '.\\\"last-assistant-message\\\" // \\\"Turn complete\\\"' 2>/dev/null | head -c 100); command -v icc >/dev/null 2>&1 && icc notify --title 'Codex' --body \\\"$MSG\\\" || osascript -e \\\"display notification \\\\\\\"$MSG\\\\\\\" with title \\\\\\\"Codex\\\\\\\"\\\"\", \"--\"]",
            endMarker,
        ].joined(separator: "\n")

        let fileManager = FileManager.default
        let existing = (try? String(contentsOf: configURL, encoding: .utf8)) ?? ""
        if existing.contains(startMarker) {
            try writeManagedTextBlock(
                managedBlock,
                to: configURL,
                startMarker: startMarker,
                endMarker: endMarker
            )
            return localizedSettingsText("settings.automation.quickImport.codex.updated", english: "Updated the icc notification block in Codex config.", simplifiedChinese: "已更新 Codex 配置中的 icc 通知区块。", traditionalChinese: "已更新 Codex 設定中的 icc 通知區塊。")
        }

        if existing
            .split(whereSeparator: \.isNewline)
            .contains(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("notify =") }) {
            throw NSError(
                domain: "icc.settings",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: localizedSettingsText(
                    "settings.automation.quickImport.codex.exists",
                    english: "Codex already defines `notify =`. Left it unchanged so you can merge manually.",
                    simplifiedChinese: "Codex 已定义 `notify =`。为避免覆盖，已保留原样，请手动合并。",
                    traditionalChinese: "Codex 已定義 `notify =`。為避免覆蓋，已保留原樣，請手動合併。"
                )]
            )
        }

        try fileManager.createDirectory(
            at: configURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        try writeManagedTextBlock(
            managedBlock,
            to: configURL,
            startMarker: startMarker,
            endMarker: endMarker
        )
        return localizedSettingsText("settings.automation.quickImport.codex.installed", english: "Installed the icc notification hook for Codex.", simplifiedChinese: "已为 Codex 安装 icc 通知钩子。", traditionalChinese: "已為 Codex 安裝 icc 通知鉤子。")
    }

    private func loadOrCreateJSONObject(at url: URL) throws -> [String: Any] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return [:] }
        let contents = try String(contentsOf: url, encoding: .utf8)
        guard !contents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [:] }
        return try parseJSONObject(contents, path: url.path)
    }

    private func writeJSONObject(_ object: [String: Any], to url: URL) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: url, options: .atomic)
    }

    private func writeManagedGhosttyOverride(named name: String, lines: [String]) throws {
        let startMarker = "# >>> icc managed \(name) >>>"
        let endMarker = "# <<< icc managed \(name) <<<"
        let managedBlock = ([startMarker] + lines + [endMarker]).joined(separator: "\n")
        try writeManagedTextBlock(
            managedBlock,
            to: iccGhosttyConfigURL(),
            startMarker: startMarker,
            endMarker: endMarker
        )
    }

    private func writeManagedTextBlock(
        _ block: String,
        to url: URL,
        startMarker: String,
        endMarker: String
    ) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )

        let existing = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        let trimmedBlock = block.trimmingCharacters(in: .whitespacesAndNewlines)
        let updated: String

        if let startRange = existing.range(of: startMarker),
           let endRange = existing.range(of: endMarker, range: startRange.lowerBound..<existing.endIndex) {
            let replaceRange = startRange.lowerBound..<endRange.upperBound
            updated = existing.replacingCharacters(in: replaceRange, with: trimmedBlock)
        } else if existing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updated = trimmedBlock
        } else {
            updated = existing.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n" + trimmedBlock
        }

        try (updated + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private func iccGhosttyConfigURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        return appSupport
            .appendingPathComponent("com.icc.app", isDirectory: true)
            .appendingPathComponent("config.ghostty", isDirectory: false)
    }

    private func settingString(_ value: Any?) -> String? {
        guard let string = value as? String else { return nil }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func settingDouble(_ value: Any?) -> Double? {
        switch value {
        case let number as NSNumber:
            return number.doubleValue
        case let string as String:
            return Double(string)
        default:
            return nil
        }
    }

    private func parseJSONObject(_ contents: String, path: String) throws -> [String: Any] {
        let sanitized = sanitizeJSONLikeText(contents)
        guard let data = sanitized.data(using: .utf8),
              let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "icc.settings",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: localizedSettingsText(
                    "settings.automation.quickImport.invalidJSON",
                    english: "The file at \(path) is not a valid JSON object.",
                    simplifiedChinese: "\(path) 不是有效的 JSON 对象。",
                    traditionalChinese: "\(path) 不是有效的 JSON 物件。"
                )]
            )
        }
        return object
    }

    private func sanitizeJSONLikeText(_ raw: String) -> String {
        let uncommented = stripJSONComments(from: raw)
        let pattern = ",(?=\\s*[}\\]])"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return uncommented
        }
        let range = NSRange(uncommented.startIndex..<uncommented.endIndex, in: uncommented)
        return regex.stringByReplacingMatches(in: uncommented, options: [], range: range, withTemplate: "")
    }

    private func stripJSONComments(from raw: String) -> String {
        var result = ""
        var iterator = raw.makeIterator()
        var inString = false
        var isEscaped = false

        while let character = iterator.next() {
            if inString {
                result.append(character)
                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    inString = false
                }
                continue
            }

            if character == "\"" {
                inString = true
                result.append(character)
                continue
            }

            if character == "/" {
                guard let next = iterator.next() else {
                    result.append(character)
                    break
                }
                if next == "/" {
                    while let lineChar = iterator.next() {
                        if lineChar == "\n" {
                            result.append("\n")
                            break
                        }
                    }
                    continue
                }
                if next == "*" {
                    var previous: Character?
                    while let blockChar = iterator.next() {
                        if previous == "*" && blockChar == "/" {
                            break
                        }
                        previous = blockChar
                    }
                    continue
                }

                result.append(character)
                result.append(next)
                continue
            }

            result.append(character)
        }

        return result
    }

    private func saveBrowserInsecureHTTPAllowlist() {
        browserInsecureHTTPAllowlist = browserInsecureHTTPAllowlistDraft
    }

    private func refreshDetectedImportBrowsers() {
        detectedImportBrowsers = InstalledBrowserDetector.detectInstalledBrowsers()
    }
}

private struct SettingsTopOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct SettingsTitleLeadingInsetReader: NSViewRepresentable {
    @Binding var inset: CGFloat

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
            let maxX = buttons
                .compactMap { window.standardWindowButton($0)?.frame.maxX }
                .max() ?? 78
            let nextInset = maxX + 14
            if abs(nextInset - inset) > 0.5 {
                inset = nextInset
            }
        }
    }
}

private struct SettingsSectionHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11.5, weight: .bold))
            .tracking(0.8)
            .foregroundColor(.secondary.opacity(ICCChrome.secondaryTextOpacity(for: colorScheme)))
            .padding(.leading, 2)
            .padding(.bottom, -2)
    }
}

private struct SettingsCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ICCChrome.cardGradient(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(ICCChrome.borderColor(for: colorScheme, emphasis: 1.1), lineWidth: 1)
                )
        )
        .shadow(color: ICCChrome.elevatedShadow(for: colorScheme), radius: 12, x: 0, y: 6)
    }
}

private struct SettingsCardRow<Trailing: View>: View {
    let title: String
    let subtitle: String?
    let controlWidth: CGFloat?
    @ViewBuilder let trailing: Trailing

    init(
        _ title: String,
        subtitle: String? = nil,
        controlWidth: CGFloat? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.controlWidth = controlWidth
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: subtitle == nil ? 0 : 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if let controlWidth {
                    trailing
                        .frame(width: controlWidth, alignment: .trailing)
                } else {
                    trailing
                }
            }
                .layoutPriority(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsPickerRow<SelectionValue: Hashable, PickerContent: View, ExtraTrailing: View>: View {
    let title: String
    let subtitle: String?
    let controlWidth: CGFloat
    @Binding var selection: SelectionValue
    let pickerContent: PickerContent
    let extraTrailing: ExtraTrailing
    let accessibilityId: String?

    init(
        _ title: String,
        subtitle: String? = nil,
        controlWidth: CGFloat,
        selection: Binding<SelectionValue>,
        accessibilityId: String? = nil,
        @ViewBuilder content: () -> PickerContent,
        @ViewBuilder extraTrailing: () -> ExtraTrailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.controlWidth = controlWidth
        self._selection = selection
        self.pickerContent = content()
        self.extraTrailing = extraTrailing()
        self.accessibilityId = accessibilityId
    }

    var body: some View {
        SettingsCardRow(title, subtitle: subtitle, controlWidth: controlWidth) {
            HStack(spacing: 6) {
                Picker("", selection: $selection) {
                    pickerContent
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .applyIf(accessibilityId != nil) { $0.accessibilityIdentifier(accessibilityId!) }
                extraTrailing
            }
        }
    }
}

extension SettingsPickerRow where ExtraTrailing == EmptyView {
    init(
        _ title: String,
        subtitle: String? = nil,
        controlWidth: CGFloat,
        selection: Binding<SelectionValue>,
        accessibilityId: String? = nil,
        @ViewBuilder content: () -> PickerContent
    ) {
        self.init(title, subtitle: subtitle, controlWidth: controlWidth, selection: selection, accessibilityId: accessibilityId, content: content) {
            EmptyView()
        }
    }
}

private extension View {
    @ViewBuilder
    func applyIf(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

private struct SettingsCardDivider: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(ICCChrome.borderColor(for: colorScheme, emphasis: 0.9))
            .frame(height: 1)
    }
}

private struct SettingsCardNote: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsSummaryBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
    }
}

private struct SettingsInlinePill: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10.5, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.12))
            )
    }
}

private enum SettingsSidebarSection: String, CaseIterable, Identifiable {
    case app
    case notifications
    case workspaceColors
    case sidebarAppearance
    case automation
    case browser
    case keyboardShortcuts
    case reset

    var id: String { rawValue }

    var title: String {
        switch self {
        case .app:
            return localizedSettingsText("settings.section.app", english: "App", simplifiedChinese: "应用", traditionalChinese: "應用")
        case .notifications:
            return localizedSettingsText("settings.section.notifications", english: "Notifications", simplifiedChinese: "通知", traditionalChinese: "通知")
        case .workspaceColors:
            return localizedSettingsText("settings.section.workspaceColors", english: "Workspace Colors", simplifiedChinese: "工作区配色", traditionalChinese: "工作區配色")
        case .sidebarAppearance:
            return localizedSettingsText("settings.section.sidebarAppearance", english: "Sidebar", simplifiedChinese: "侧边栏", traditionalChinese: "側邊欄")
        case .automation:
            return localizedSettingsText("settings.section.automation", english: "Automation", simplifiedChinese: "自动化", traditionalChinese: "自動化")
        case .browser:
            return localizedSettingsText("settings.section.browser", english: "Browser", simplifiedChinese: "浏览器", traditionalChinese: "瀏覽器")
        case .keyboardShortcuts:
            return localizedSettingsText("settings.section.keyboardShortcuts", english: "Shortcuts", simplifiedChinese: "快捷键", traditionalChinese: "快捷鍵")
        case .reset:
            return localizedSettingsText("settings.section.reset", english: "Reset", simplifiedChinese: "重置", traditionalChinese: "重置")
        }
    }

    var subtitle: String {
        switch self {
        case .app:
            return localizedSettingsText("settings.nav.app.subtitle", english: "Appearance, behavior, and core defaults", simplifiedChinese: "外观、行为与基础默认项", traditionalChinese: "外觀、行為與基礎預設")
        case .notifications:
            return localizedSettingsText("settings.nav.notifications.subtitle", english: "Alerts, permissions, and sounds", simplifiedChinese: "提醒、权限与声音", traditionalChinese: "提醒、權限與聲音")
        case .workspaceColors:
            return localizedSettingsText("settings.nav.workspaceColors.subtitle", english: "Color palette and active indicators", simplifiedChinese: "配色方案与激活标记", traditionalChinese: "配色方案與啟用標記")
        case .sidebarAppearance:
            return localizedSettingsText("settings.nav.sidebarAppearance.subtitle", english: "Workspace list density and details", simplifiedChinese: "工作区列表密度与细节", traditionalChinese: "工作區清單密度與細節")
        case .automation:
            return localizedSettingsText("settings.nav.automation.subtitle", english: "Supervisor, sockets, and local control", simplifiedChinese: "监督器、套接字与本地控制", traditionalChinese: "監督器、Socket 與本地控制")
        case .browser:
            return localizedSettingsText("settings.nav.browser.subtitle", english: "Embedded browser and import controls", simplifiedChinese: "内置浏览器与导入控制", traditionalChinese: "內建瀏覽器與匯入控制")
        case .keyboardShortcuts:
            return localizedSettingsText("settings.nav.shortcuts.subtitle", english: "Key bindings and hint behavior", simplifiedChinese: "按键绑定与提示行为", traditionalChinese: "按鍵綁定與提示行為")
        case .reset:
            return localizedSettingsText("settings.nav.reset.subtitle", english: "Recovery and cleanup", simplifiedChinese: "恢复与清理", traditionalChinese: "恢復與清理")
        }
    }

    var iconName: String {
        switch self {
        case .app:
            return "slider.horizontal.3"
        case .notifications:
            return "bell.badge"
        case .workspaceColors:
            return "paintpalette"
        case .sidebarAppearance:
            return "sidebar.left"
        case .automation:
            return "brain"
        case .browser:
            return "globe"
        case .keyboardShortcuts:
            return "command"
        case .reset:
            return "arrow.counterclockwise"
        }
    }

    static func from(navigationTarget: SettingsNavigationTarget) -> SettingsSidebarSection {
        switch navigationTarget {
        case .automation, .wechat:
            return .automation
        case .notifications:
            return .notifications
        case .browser, .browserImport:
            return .browser
        case .keyboardShortcuts:
            return .keyboardShortcuts
        }
    }
}

private struct SettingsSidebarNavButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let section: SettingsSidebarSection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                colors: [
                                    ICCChrome.accent(for: colorScheme),
                                    ICCChrome.secondaryAccent(for: colorScheme)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    ICCChrome.mutedFill(for: colorScheme),
                                    ICCChrome.mutedFill(for: colorScheme)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: section.iconName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.82))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(section.subtitle)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                            ? ICCChrome.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.14 : 0.10)
                            : Color.clear
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected
                            ? ICCChrome.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.34 : 0.22)
                            : ICCChrome.borderColor(for: colorScheme, emphasis: 0.45),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ThemeWindowThumbnail: View {
    let isDark: Bool

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // Wallpaper background
                if isDark {
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.05, green: 0.05, blue: 0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: height * 0.5))
                        path.addQuadCurve(to: CGPoint(x: width, y: height), control: CGPoint(x: width * 0.5, y: height * 0.2))
                        path.addLine(to: CGPoint(x: width, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                    }
                    .fill(LinearGradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.6).opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                } else {
                    LinearGradient(
                        colors: [Color(red: 0.6, green: 0.8, blue: 0.95), Color(red: 0.2, green: 0.4, blue: 0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: height * 0.5))
                        path.addQuadCurve(to: CGPoint(x: width, y: height), control: CGPoint(x: width * 0.5, y: height * 0.2))
                        path.addLine(to: CGPoint(x: width, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                    }
                    .fill(LinearGradient(colors: [Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                }

                // Menu bar
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.system(size: max(height * 0.08, 6)))
                            .foregroundColor(isDark ? .white : .black)
                            .opacity(0.8)
                        Spacer()
                    }
                    .padding(.horizontal, max(width * 0.04, 4))
                    .frame(height: max(height * 0.12, 8))
                    .background(.ultraThinMaterial)
                    Spacer()
                }

                // Back window
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(isDark ? Color(white: 0.2) : Color(white: 0.9))
                        .frame(height: max(height * 0.15, 8))
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(isDark ? Color(white: 0.15) : Color(white: 0.98))
                        RoundedRectangle(cornerRadius: max(width * 0.02, 2), style: .continuous)
                            .fill(Color.accentColor)
                            .frame(height: max(height * 0.12, 6))
                            .padding(max(width * 0.04, 4))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: max(width * 0.04, 4), style: .continuous))
                .frame(width: width * 0.65, height: height * 0.45)
                .shadow(color: .black.opacity(isDark ? 0.4 : 0.15), radius: 4, x: 0, y: 2)
                .offset(x: -width * 0.08, y: -height * 0.1)

                // Front window with traffic lights
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(isDark ? Color(white: 0.18) : Color(white: 0.92))
                        HStack(spacing: max(width * 0.025, 2)) {
                            Circle().fill(Color(red: 1.0, green: 0.37, blue: 0.34)).frame(width: max(width * 0.04, 3))
                            Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.18)).frame(width: max(width * 0.04, 3))
                            Circle().fill(Color(red: 0.15, green: 0.79, blue: 0.25)).frame(width: max(width * 0.04, 3))
                            Spacer()
                        }
                        .padding(.horizontal, max(width * 0.04, 4))
                    }
                    .frame(height: max(height * 0.18, 10))
                    Rectangle()
                        .fill(isDark ? Color(white: 0.1) : .white)
                }
                .clipShape(RoundedRectangle(cornerRadius: max(width * 0.05, 5), style: .continuous))
                .shadow(color: .black.opacity(isDark ? 0.5 : 0.2), radius: 6, x: 0, y: 3)
                .frame(width: width * 0.75, height: height * 0.55)
                .offset(x: width * 0.12, y: height * 0.2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

private struct ThemePickerRow: View {
    let selectedMode: String
    let onSelect: (AppearanceMode) -> Void

    private let thumbWidth: CGFloat = 76
    private let thumbHeight: CGFloat = 50

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(localized: "settings.app.theme", defaultValue: "Theme"))
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                ForEach(AppearanceMode.visibleCases) { mode in
                    let isSelected = selectedMode == mode.rawValue
                    Button {
                        onSelect(mode)
                    } label: {
                        VStack(spacing: 4) {
                            Group {
                                if mode == .system {
                                    ZStack {
                                        ThemeWindowThumbnail(isDark: false)
                                            .mask(
                                                GeometryReader { geo in
                                                    Rectangle()
                                                        .frame(width: geo.size.width / 2, height: geo.size.height)
                                                        .position(x: geo.size.width / 4, y: geo.size.height / 2)
                                                }
                                            )
                                        ThemeWindowThumbnail(isDark: true)
                                            .mask(
                                                GeometryReader { geo in
                                                    Rectangle()
                                                        .frame(width: geo.size.width / 2, height: geo.size.height)
                                                        .position(x: geo.size.width * 0.75, y: geo.size.height / 2)
                                                }
                                            )
                                        GeometryReader { geo in
                                            Rectangle()
                                                .fill(Color.primary.opacity(0.15))
                                                .frame(width: 1, height: geo.size.height)
                                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        }
                                    }
                                } else {
                                    ThemeWindowThumbnail(isDark: mode == .dark)
                                }
                            }
                            .frame(width: thumbWidth, height: thumbHeight)

                            Text(mode.displayName)
                                .font(.system(size: 10))
                                .fontWeight(isSelected ? .semibold : .regular)
                                .foregroundColor(isSelected ? .primary : .secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isSelected
                                    ? Color.accentColor.opacity(0.12)
                                    : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .layoutPriority(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum SidebarColorPreset: String, CaseIterable, Identifiable {
    case graphite
    case ocean
    case sand
    case forest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .graphite:
            return localizedSettingsText("settings.sidebarAppearance.preset.graphite", english: "Graphite", simplifiedChinese: "石墨", traditionalChinese: "石墨")
        case .ocean:
            return localizedSettingsText("settings.sidebarAppearance.preset.ocean", english: "Ocean", simplifiedChinese: "深海", traditionalChinese: "深海")
        case .sand:
            return localizedSettingsText("settings.sidebarAppearance.preset.sand", english: "Sand", simplifiedChinese: "沙岩", traditionalChinese: "沙岩")
        case .forest:
            return localizedSettingsText("settings.sidebarAppearance.preset.forest", english: "Forest", simplifiedChinese: "森林", traditionalChinese: "森林")
        }
    }

    var lightHex: String {
        switch self {
        case .graphite: return "#6B7280"
        case .ocean: return "#4F6D8A"
        case .sand: return "#A67C52"
        case .forest: return "#4E7A5D"
        }
    }

    var darkHex: String {
        switch self {
        case .graphite: return "#111827"
        case .ocean: return "#102A43"
        case .sand: return "#5A4632"
        case .forest: return "#16352A"
        }
    }

    var opacity: Double {
        switch self {
        case .graphite: return 0.18
        case .ocean: return 0.20
        case .sand: return 0.16
        case .forest: return 0.18
        }
    }
}

private struct SidebarColorPresetChip: View {
    let preset: SidebarColorPreset
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(nsColor: NSColor(hex: preset.lightHex) ?? .gray))
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(Color(nsColor: NSColor(hex: preset.darkHex) ?? .black))
                        .frame(width: 10, height: 10)
                }

                Text(preset.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(minWidth: 74, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.34) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct AppIconPickerRow: View {
    let selectedMode: String
    let onSelect: (AppIconMode) -> Void

    private let iconSize: CGFloat = 48
    private let autoIconSize: CGFloat = 36

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(String(localized: "settings.app.appIcon", defaultValue: "App Icon"))
                    .font(.system(size: 13, weight: .medium))
                Text(String(localized: "settings.app.appIcon.subtitle", defaultValue: "Dock and app switcher"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                ForEach(AppIconMode.allCases) { mode in
                    let isSelected = selectedMode == mode.rawValue
                    Button {
                        onSelect(mode)
                    } label: {
                        VStack(spacing: 4) {
                            Group {
                                if mode == .automatic {
                                    ZStack {
                                        Image("AppIconLight")
                                            .resizable()
                                            .interpolation(.high)
                                            .frame(width: autoIconSize, height: autoIconSize)
                                            .clipShape(RoundedRectangle(cornerRadius: autoIconSize * 0.22, style: .continuous))
                                            .offset(x: -10)
                                        Image("AppIconDark")
                                            .resizable()
                                            .interpolation(.high)
                                            .frame(width: autoIconSize, height: autoIconSize)
                                            .clipShape(RoundedRectangle(cornerRadius: autoIconSize * 0.22, style: .continuous))
                                            .offset(x: 10)
                                    }
                                    .frame(width: iconSize, height: iconSize)
                                } else {
                                    Image(mode.imageName ?? "AppIconLight")
                                        .resizable()
                                        .interpolation(.high)
                                        .frame(width: iconSize, height: iconSize)
                                        .clipShape(RoundedRectangle(cornerRadius: iconSize * 0.22, style: .continuous))
                                }
                            }

                            Text(mode.displayName)
                                .font(.system(size: 10))
                                .foregroundColor(isSelected ? .primary : .secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isSelected
                                    ? Color.accentColor.opacity(0.12)
                                    : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .layoutPriority(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ShortcutSettingRow: View {
    let action: KeyboardShortcutSettings.Action
    @State private var shortcut: StoredShortcut

    init(action: KeyboardShortcutSettings.Action) {
        self.action = action
        _shortcut = State(initialValue: KeyboardShortcutSettings.shortcut(for: action))
    }

    var body: some View {
        KeyboardShortcutRecorder(
            label: action.label,
            shortcut: $shortcut,
            displayString: { action.displayedShortcutString(for: $0) },
            transformRecordedShortcut: { action.normalizedRecordedShortcut($0) }
        )
            .onChange(of: shortcut) { newValue in
                KeyboardShortcutSettings.setShortcut(newValue, for: action)
            }
            .onReceive(NotificationCenter.default.publisher(for: KeyboardShortcutSettings.didChangeNotification)) { _ in
                let latest = KeyboardShortcutSettings.shortcut(for: action)
                if latest != shortcut {
                    shortcut = latest
                }
            }
    }
}

private struct SettingsRootView: View {
    var body: some View {
        SettingsView()
            .background(WindowAccessor { window in
                configureSettingsWindow(window)
            })
    }

    private func configureSettingsWindow(_ window: NSWindow) {
        window.identifier = NSUserInterfaceItemIdentifier("icc.settings")
        applyCurrentSettingsWindowStyle(to: window)

        let accessories = window.titlebarAccessoryViewControllers
        for index in accessories.indices.reversed() {
            guard let identifier = accessories[index].view.identifier?.rawValue else { continue }
            guard identifier.hasPrefix("icc.") else { continue }
            window.removeTitlebarAccessoryViewController(at: index)
        }
        AppDelegate.shared?.applyWindowDecorations(to: window)
    }

    private func applyCurrentSettingsWindowStyle(to window: NSWindow) {
        SettingsAboutTitlebarDebugStore.shared.applyCurrentOptions(to: window, for: .settings)
    }
}
