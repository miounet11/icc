# Contributing to icc

`icc` is currently released from the `miounet11/icc` repository:

<https://github.com/miounet11/icc>

Historical note:

- The shipped app and CLI are named `icc`.
- Some Xcode targets, scripts, sockets, helpers, and internal protocols still use legacy `icc` names.
- Do not rename those blindly while contributing. Many are still part of the active build and automation surface.
- Follow [docs/brand-guidelines.md](docs/brand-guidelines.md) for user-facing naming and positioning.

## Prerequisites

- macOS 14+
- Xcode 15+
- Zig (`brew install zig`)

## Getting started

Clone with submodules:

```bash
git clone --recursive https://github.com/miounet11/icc.git
cd icc
```

Run setup once:

```bash
./scripts/setup.sh
```

This initializes submodules, builds `GhosttyKit.xcframework`, and prepares local symlinks used by the app and scripts.

## Build and run

Tagged debug build:

```bash
./scripts/reload.sh --tag my-change
```

Release build:

```bash
./scripts/reloadp.sh
```

Useful scripts:

| Script | Purpose |
| --- | --- |
| `./scripts/setup.sh` | One-time setup for submodules and GhosttyKit |
| `./scripts/reload.sh --tag <tag>` | Build and launch an isolated debug app |
| `./scripts/reloadp.sh` | Build and launch the release app |
| `./scripts/reload2.sh --tag <tag>` | Reload debug and release variants |
| `./scripts/rebuild.sh` | Clean rebuild |

## Working conventions

- Prefer tagged debug runs so your app instance does not collide with other local sessions.
- Assume the repo may already contain unrelated user changes. Do not revert work you did not make.
- Keep user-facing documentation and product references on `icc`, even when the underlying code still says `icc`.
- Use the canonical short descriptor `AI Command Center for macOS` when a concise product label is needed.
- When changing Ghostty behavior, update [docs/ghostty-fork.md](docs/ghostty-fork.md) together with the submodule pointer.

## Tests

This repository uses VM- or CI-oriented integration coverage.

Recommended commands:

```bash
./scripts/run-tests-v1.sh
./scripts/run-tests-v2.sh
./scripts/test-unit.sh
```

Historical note:

- Several scripts, test suites, and bundle names still use legacy `icc` naming internally.
- That is expected until the deeper build/test rename is completed.

## Ghostty fork

The `ghostty` submodule currently points to:

<https://github.com/manaflow-ai/ghostty>

If you change the fork:

1. Commit and push the submodule changes first.
2. Update [docs/ghostty-fork.md](docs/ghostty-fork.md).
3. Commit the parent repo with the new submodule SHA.

## License

By contributing to this repository, you agree that your contributions are licensed under `AGPL-3.0-or-later`.
