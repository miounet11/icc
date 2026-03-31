import Foundation

struct RemoteRelayZshBootstrap {
    let shellStateDir: String

    private var sharedHistoryLines: [String] {
        [
            "if [ -z \"${HISTFILE:-}\" ] || [ \"$HISTFILE\" = \"\(shellStateDir)/.zsh_history\" ]; then export HISTFILE=\"$ICC_REAL_ZDOTDIR/.zsh_history\"; fi",
        ]
    }

    var zshEnvLines: [String] {
        [
            "[ -f \"$ICC_REAL_ZDOTDIR/.zshenv\" ] && source \"$ICC_REAL_ZDOTDIR/.zshenv\"",
            "if [ -n \"${ZDOTDIR:-}\" ] && [ \"$ZDOTDIR\" != \"\(shellStateDir)\" ]; then export ICC_REAL_ZDOTDIR=\"$ZDOTDIR\"; fi",
        ] + sharedHistoryLines + [
            "export ZDOTDIR=\"\(shellStateDir)\"",
        ]
    }

    var zshProfileLines: [String] {
        [
            "[ -f \"$ICC_REAL_ZDOTDIR/.zprofile\" ] && source \"$ICC_REAL_ZDOTDIR/.zprofile\"",
        ]
    }

    func zshRCLines(commonShellLines: [String]) -> [String] {
        sharedHistoryLines + [
            "[ -f \"$ICC_REAL_ZDOTDIR/.zshrc\" ] && source \"$ICC_REAL_ZDOTDIR/.zshrc\"",
        ] + commonShellLines
    }

    var zshLoginLines: [String] {
        [
            "[ -f \"$ICC_REAL_ZDOTDIR/.zlogin\" ] && source \"$ICC_REAL_ZDOTDIR/.zlogin\"",
        ]
    }
}
