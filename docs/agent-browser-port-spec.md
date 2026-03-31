# Browser Automation Contract

Last updated: 2026-03-25

This document summarizes the browser automation surface shipped with `icc`.

Historical note:

- The executable users install is `icc`.
- Some implementation files, protocols, and legacy tests still refer to `icc` because the browser automation layer was ported from that codebase and remains backward compatible.

## Goals

1. keep a stable browser automation surface for agent workflows
2. let browser operations target a specific workspace, pane, or surface
3. preserve compatibility while the codebase still contains legacy protocol names

## Current scope

The built-in browser supports:

- open, navigate, back, forward, reload
- snapshot and DOM-style element references
- click, double-click, hover, type, fill, focus
- check, uncheck, select, scroll, scroll-into-view
- screenshot, eval, wait
- title, URL, text, HTML, value, attribute, count, visibility, and state queries
- tab and session helpers needed by the current app integration

## Current targeting model

Canonical concepts:

1. `window`: native macOS window
2. `workspace`: main work unit inside a window
3. `pane`: split region inside a workspace
4. `surface`: terminal or browser tab inside a pane

For new documentation and operator examples, prefer `surface` and `pane`.

## Product-facing guidance

- Document the browser feature as an `icc` capability.
- Keep legacy protocol names only where they are part of the actual API or compatibility layer.
- When adding examples, prefer the current CLI binary name `icc` even if the underlying source file is still `CLI/icc.swift`.
