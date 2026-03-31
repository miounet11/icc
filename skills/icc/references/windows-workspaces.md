# Windows and Workspaces

Window/workspace lifecycle and ordering operations.

## Inspect

```bash
icc list-windows
icc current-window
icc list-workspaces
icc current-workspace
```

## Create/Focus/Close

```bash
icc new-window
icc focus-window --window window:2
icc close-window --window window:2

icc new-workspace
icc select-workspace --workspace workspace:4
icc close-workspace --workspace workspace:4
```

## Reorder and Move

```bash
icc reorder-workspace --workspace workspace:4 --before workspace:2
icc move-workspace-to-window --workspace workspace:4 --window window:1
```
