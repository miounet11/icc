# iccd-remote

`iccd-remote` is the internal remote helper used by `icc` for managed SSH workspaces.

Historical note:

- The product is `icc`.
- The daemon binary intentionally retains the legacy name `iccd-remote`.

## Responsibilities

- bootstrap remote control for `icc ssh`
- proxy browser and helper traffic through the remote session
- coordinate managed PTY attachments and resize semantics
- relay selected CLI calls from the remote host back to the local app

## Main commands

1. `iccd-remote version`
2. `iccd-remote serve --stdio`
3. `iccd-remote cli <command> [args...]`

When invoked as `icc` through the installed remote wrapper, the binary can auto-dispatch to the CLI relay path.

## RPC families

1. `hello`
2. `ping`
3. `proxy.*`
4. `session.*`

## Release note

Even though this daemon keeps the old name, release-facing documentation should describe it as the remote helper for `icc`, not as a separate end-user product.
