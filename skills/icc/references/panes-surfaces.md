# Panes and Surfaces

Split layout, surface creation, focus, move, and reorder.

## Inspect

```bash
icc list-panes
icc list-pane-surfaces --pane pane:1
```

## Create Splits/Surfaces

```bash
icc new-split right --panel pane:1
icc new-surface --type terminal --pane pane:1
icc new-surface --type browser --pane pane:1 --url https://example.com
```

## Focus and Close

```bash
icc focus-pane --pane pane:2
icc focus-panel --panel surface:7
icc close-surface --surface surface:7
```

## Move/Reorder Surfaces

```bash
icc move-surface --surface surface:7 --pane pane:2 --focus true
icc move-surface --surface surface:7 --workspace workspace:2 --window window:1 --after surface:4
icc reorder-surface --surface surface:7 --before surface:3
```

Surface identity is stable across move/reorder operations.
