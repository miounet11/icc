# Command Reference (icc Browser)

This maps common `agent-browser` usage to `icc browser` usage.

## Direct Equivalents

- `agent-browser open <url>` -> `icc browser open <url>`
- `agent-browser goto|navigate <url>` -> `icc browser <surface> goto|navigate <url>`
- `agent-browser snapshot -i` -> `icc browser <surface> snapshot --interactive`
- `agent-browser click <ref>` -> `icc browser <surface> click <ref>`
- `agent-browser fill <ref> <text>` -> `icc browser <surface> fill <ref> <text>`
- `agent-browser type <ref> <text>` -> `icc browser <surface> type <ref> <text>`
- `agent-browser select <ref> <value>` -> `icc browser <surface> select <ref> <value>`
- `agent-browser get text <ref>` -> `icc browser <surface> get text <ref-or-selector>`
- `agent-browser get url` -> `icc browser <surface> get url`
- `agent-browser get title` -> `icc browser <surface> get title`

## Core Command Groups

### Navigation

```bash
icc browser open <url>                        # opens in caller's workspace (uses ICC_WORKSPACE_ID)
icc browser open <url> --workspace <id|ref>   # opens in a specific workspace
icc browser <surface> goto <url>
icc browser <surface> back|forward|reload
icc browser <surface> get url|title
```

> **Workspace context:** `browser open` targets the workspace of the terminal where the command is run (via `ICC_WORKSPACE_ID`), even if a different workspace is currently focused. Use `--workspace` to override.

### Snapshot and Inspection

```bash
icc browser <surface> snapshot --interactive
icc browser <surface> snapshot --interactive --compact --max-depth 3
icc browser <surface> get text body
icc browser <surface> get html body
icc browser <surface> get value "#email"
icc browser <surface> get attr "#email" --attr placeholder
icc browser <surface> get count ".row"
icc browser <surface> get box "#submit"
icc browser <surface> get styles "#submit" --property color
icc browser <surface> eval '<js>'
```

### Interaction

```bash
icc browser <surface> click|dblclick|hover|focus <selector-or-ref>
icc browser <surface> fill <selector-or-ref> [text]   # empty text clears
icc browser <surface> type <selector-or-ref> <text>
icc browser <surface> press|keydown|keyup <key>
icc browser <surface> select <selector-or-ref> <value>
icc browser <surface> check|uncheck <selector-or-ref>
icc browser <surface> scroll [--selector <css>] [--dx <n>] [--dy <n>]
```

### Wait

```bash
icc browser <surface> wait --selector "#ready" --timeout-ms 10000
icc browser <surface> wait --text "Done" --timeout-ms 10000
icc browser <surface> wait --url-contains "/dashboard" --timeout-ms 10000
icc browser <surface> wait --load-state complete --timeout-ms 15000
icc browser <surface> wait --function "document.readyState === 'complete'" --timeout-ms 10000
```

### Session/State

```bash
icc browser <surface> cookies get|set|clear ...
icc browser <surface> storage local|session get|set|clear ...
icc browser <surface> tab list|new|switch|close ...
icc browser <surface> state save|load <path>
```

### Diagnostics

```bash
icc browser <surface> console list|clear
icc browser <surface> errors list|clear
icc browser <surface> highlight <selector>
icc browser <surface> screenshot
icc browser <surface> download wait --timeout-ms 10000
```

## Agent Reliability Tips

- Use `--snapshot-after` on mutating actions to return a fresh post-action snapshot.
- Re-snapshot after navigation, modal open/close, or major DOM changes.
- Prefer short handles in outputs by default (`surface:N`, `pane:N`, `workspace:N`, `window:N`).
- Use `--id-format both` only when a UUID must be logged/exported.

## Known WKWebView Gaps (`not_supported`)

- `browser.viewport.set`
- `browser.geolocation.set`
- `browser.offline.set`
- `browser.trace.start|stop`
- `browser.network.route|unroute|requests`
- `browser.screencast.start|stop`
- `browser.input_mouse|input_keyboard|input_touch`

See also:
- [snapshot-refs.md](snapshot-refs.md)
- [authentication.md](authentication.md)
- [session-management.md](session-management.md)
