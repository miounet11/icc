# V2 Socket API Notes

This document tracks the modern JSON socket API used by `icc`.

Historical note:

- The current product and shipped CLI are `icc`.
- The implementation still contains legacy `icc` naming in protocol handlers, tests, and scripts.

## Purpose

The v2 API exists to give agent workflows a stable, handle-based JSON protocol for:

- windows
- workspaces
- panes
- surfaces
- notifications
- browser automation

## Envelope

Each request is one JSON object per line:

```json
{"id":"1","method":"workspace.list","params":{}}
```

Each response is one JSON object per line:

```json
{"id":"1","ok":true,"result":{}}
```

Errors:

```json
{"id":"1","ok":false,"error":{"code":"not_found","message":"workspace not found"}}
```

## Migration guidance

- Prefer v2 for new automation.
- Keep v1 compatibility until the rest of the toolchain no longer depends on it.
- Treat IDs as stable handles and indexes as convenience output only.

## Current state

- v2 window, workspace, pane, and surface controls are implemented
- notification calls are implemented
- browser operations are implemented
- compatibility with legacy workflows is still intentionally preserved
