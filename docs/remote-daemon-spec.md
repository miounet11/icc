# Managed Remote SSH Spec

Last updated: 2026-03-25

This document is the current release-facing summary of `icc` managed SSH behavior.

Historical note:

- The shipped app is `icc`.
- Several internal components still keep legacy names such as `iccd-remote`, `ICC_*`, and `~/.icc/...` paths for compatibility.

## Goal

`icc ssh` and the remote explorer should provide:

1. durable remote terminals with reconnect support
2. remote file browsing and editing after login
3. browser traffic that can follow the remote execution path
4. stable SSH UX from both CLI and the right-side remote explorer

## Current user-facing behavior

### Remote explorer

- Reads host entries from `~/.ssh/config`, including included config files.
- Shows alias, hostname, user, port, and identity-file-derived details where available.
- Prompts for login as needed and stores passwords in the local macOS Keychain.
- Only shows the remote file tree on the right after the SSH session is actually connected.
- Supports remote file open, edit, and save from inside the app.

### Managed SSH workspaces

- `icc ssh <destination>` creates a remote-tagged workspace.
- The app bootstraps the remote helper when needed and reconnects managed sessions.
- Remote browser surfaces and remote file operations follow workspace-specific remote state instead of pretending the target is local.
- Disconnect, reconnect, error visibility, and compatibility status are surfaced in the UI.

## Architecture summary

### Remote helper

- Internal daemon name: `iccd-remote`
- Transport: newline-delimited JSON over stdio
- Main RPC groups: `hello`, `ping`, `proxy.*`, `session.*`

### Local relay and compatibility paths

- The app can install a remote wrapper under `~/.icc/bin/`.
- Reverse SSH forwarding is used so remote commands can speak back to the local app safely.
- Browser proxy traffic is tunneled through the remote daemon stream RPC instead of relying on ad hoc per-port forwarding.

### PTY sizing

- Managed multi-attachment remote sessions use tmux-style `smallest screen wins` semantics.

## Compatibility details

- Managed remote TERM mode can prefer `xterm-256color` for safer compatibility.
- Ghostty TERM can also be preserved when the remote host has matching terminfo support.
- Remote helper naming and `~/.icc/` paths remain legacy for now and should not be changed without a coordinated migration.

## Current status

- Remote workspace creation: shipped
- Remote reconnect and disconnect controls: shipped
- Remote file tree in the right-side explorer: shipped
- Remote file open/edit/save in-app: shipped
- Remote proxy broker for browser traffic: shipped
- Resize coordination for managed sessions: shipped
- Clear user-facing documentation and migration cleanup: in progress

## Operational notes

- If the right-side remote explorer is empty, verify that the SSH session is genuinely connected first.
- If a host requires credentials, let the UI complete the login flow before expecting file enumeration.
- Passwords are stored in the macOS Keychain, not in the repository or plain-text config files.
