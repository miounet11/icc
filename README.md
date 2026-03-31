# icc

> AI Command Center for macOS

`icc` is a native macOS command center for serious AI work. It brings Ghostty-grade terminal rendering, local and remote explorers, in-app file editing, browser-assisted execution, and a supervisor layer into one focused workspace so you can move from idea to execution without losing context.

Repository: <https://github.com/miounet11/icc>

Language docs: English | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [Français](README.fr.md) | [Italiano](README.it.md) | [Dansk](README.da.md) | [Polski](README.pl.md) | [Русский](README.ru.md) | [Bosanski](README.bs.md) | [العربية](README.ar.md) | [Norsk](README.no.md) | [Português (Brasil)](README.pt-BR.md) | [ไทย](README.th.md) | [Türkçe](README.tr.md) | [ភាសាខ្មែរ](README.km.md) | [Tiếng Việt](README.vi.md)

Brand guide: [docs/brand-guidelines.md](docs/brand-guidelines.md)

## Why icc lands differently

- One cockpit for terminal execution, files, remote hosts, browser workflows, and supervision.
- Native macOS feel, low-latency rendering, and a layout built for long working sessions.
- Fast path from a few user turns to a real execution plan instead of another setup ritual.
- Stronger operational visibility than a plain terminal, without giving up terminal-first speed.

## What people notice first

- The terminal stays first-class.
- Files and remote hosts stay visible beside the active conversation.
- The supervisor can turn fragmented context into a concrete next move.
- Local work and remote work use the same mental model.

## Positioning

`icc` is for operators, founders, engineers, and power users who are already running multiple tools to get AI-assisted work done and want one sharper control surface instead of more window sprawl.

## What icc ships today

- Native Swift/AppKit macOS app built on `libghostty`, with low-latency terminal rendering and Ghostty-compatible theme and font behavior.
- Workspace-first UI with a compact left rail and the main work surface centered on terminal conversations and split panes.
- Right-side local file explorer for the current project, with tree navigation, drag-to-terminal path insertion, and in-app file open, edit, and save.
- Right-side remote SSH explorer that reads `~/.ssh/config`, supports interactive login, remembers remote passwords in the macOS Keychain, and exposes remote files after connection.
- Remote file open, edit, and save flow from the same explorer panel used for local work.
- Built-in browser surface and socket/CLI automation for browser-assisted agent workflows.
- Workspace supervisor panel that can infer project state from the current workspace, recent interaction notes, visited directories, remote status, and panel history.
- LLM-backed supervisor mode: configure endpoint, model, and API key, then generate a startup plan, execution brief, panel handoffs, and looped reviews.
- Notification and task-follow-up workflow for Claude Code, Codex, OpenCode, and other agent-driven terminal sessions.
- WeChat channel settings for binding inbound conversations to a specific window or workspace.

## Install

### Release builds

Release artifacts should be published on the GitHub Releases page:

<https://github.com/miounet11/icc/releases>

If you are validating the app before the first public release, build from source instead.

### Build from source

Prerequisites:

- macOS 14 or later
- Xcode 15 or later
- Zig (`brew install zig`)

Clone with submodules and run setup:

```bash
git clone --recursive https://github.com/miounet11/icc.git
cd icc
./scripts/setup.sh
```

Build and launch a tagged debug app:

```bash
./scripts/reload.sh --tag local-dev
```

Build and launch the release app:

```bash
./scripts/reloadp.sh
```

## Quick start

1. Launch `icc`.
2. Open a local folder from the window toolbar or the file explorer action.
3. Open the remote explorer to import hosts from `~/.ssh/config`.
4. Connect to a host, then browse and edit remote files in the right-side panel.
5. Open Settings and configure Automation if you want supervisor and LLM-assisted orchestration.
6. Install the bundled CLI into `PATH` from the in-app shell command action if you want `icc` commands in Terminal.

## Why teams evaluate icc

- Replace the usual split between terminal app, SFTP client, scratch notes, and remote SSH helper with one workspace.
- Keep execution context visible while an agent or operator is working.
- Reduce friction when moving between local repos, remote machines, and browser-backed flows.
- Give every active workspace a control layer that can summarize status and propose the next action.

## CLI notes

The bundled executable is `icc`.

Common examples:

```bash
icc --help
icc notify --title "Build complete" --body "Tests passed"
icc list-notifications
icc clear-notifications
```

Compatibility note:

- Some internal protocol names, environment variables, sockets, and daemon binaries still use legacy `icc` or `ICC_*` names. That is intentional for compatibility during the transition.
- The user-facing app name and shipped CLI name are `icc`.

## Remote workflow

`icc` supports two complementary remote paths:

- UI-driven remote explorer: reads OpenSSH and VS Code-compatible host entries from `~/.ssh/config`, prompts for missing credentials, stores passwords in the local macOS Keychain, and reveals the remote file tree after connection.
- CLI-driven SSH workspaces: `icc ssh ...` creates a managed remote workspace, bootstraps the remote helper, and reconnects browser and terminal state through the app.

Remote compatibility details:

- Managed SSH sessions can prefer `TERM=xterm-256color` for compatibility or keep Ghostty's TERM when the remote host has matching terminfo support.
- Remote file interactions shown in the explorer are the remote host contents, not a local mirror.

## Supervisor workflow

The supervisor panel is designed for fast startup after only a few user turns:

- capture the workspace goal, done definition, constraints, and scope
- track visited directories and current working context
- infer a startup plan from recent interaction notes
- generate an execution brief for the active terminal window
- optionally call a configured LLM endpoint for deeper reviews and iteration loops

Open Settings → Automation to configure:

- LLM endpoint
- model
- API key
- socket control mode
- Claude Code integration

## Documentation map

- [CONTRIBUTING.md](CONTRIBUTING.md): local development workflow
- [CHANGELOG.md](CHANGELOG.md): release history and rename note
- [docs/brand-guidelines.md](docs/brand-guidelines.md): ICC naming, positioning, and voice
- [docs/notifications.md](docs/notifications.md): notification hooks and CLI usage
- [docs/remote-daemon-spec.md](docs/remote-daemon-spec.md): managed SSH architecture and status
- [docs/agent-browser-port-spec.md](docs/agent-browser-port-spec.md): browser automation contract
- [docs/v2-api-migration.md](docs/v2-api-migration.md): v2 socket API notes
- [docs/ghostty-fork.md](docs/ghostty-fork.md): Ghostty fork delta carried by this repo
- [docs/release-update-rules.md](docs/release-update-rules.md): release tags, appcast URLs, and upgrade rules

## Development notes

- The repository name is now `icc`, and the product being released is `icc`.
- Some Xcode target names, scripts, package identifiers, and helper binaries still use legacy `icc` naming. Do not mass-rename those blindly; several are still part of the working build and protocol surface.
- The Homebrew tap submodule is still legacy-named and should be treated as migration work, not the primary install path for this release.

## License

`icc` is licensed under `AGPL-3.0-or-later`. See [LICENSE](LICENSE).
