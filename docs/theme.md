# Theme Reference

The color theme is defined in `Common/Colors.qml` as a singleton, using the **Gruvbox Dark** palette.

```qml
import "../Common"
Rectangle { color: Colors.bg0 }
Text { color: Colors.fg1 }
```

## Background Colors

| Name | Hex | Usage |
|------|-----|-------|
| `bg0_hard` | `#1d2021` | Deepest background |
| `bg0` | `#282828` | Default background |
| `bg1` | `#3c3836` | Elevated surfaces |
| `bg2` | `#504945` | Buttons, inputs |
| `bg3` | `#665c54` | Borders, dividers |
| `bg4` | `#7c6f64` | Disabled elements |

## Foreground Colors

| Name | Hex | Usage |
|------|-----|-------|
| `fg0` | `#fbf1c7` | Brightest text |
| `fg1` | `#ebdbb2` | Default text |
| `fg2` | `#d5c4a1` | Secondary text |
| `fg3` | `#bdae93` | Muted text |
| `fg4` | `#a89984` | Dimmest text |

## Accent Colors

| Name | Hex | Dim variant |
|------|-----|-------------|
| `red` | `#fb4934` | `#cc241d` |
| `green` | `#b8bb26` | `#98971a` |
| `yellow` | `#fabd2f` | `#d79921` |
| `blue` | `#83a598` | `#458588` |
| `purple` | `#d3869b` | `#b16286` |
| `aqua` | `#8ec07c` | `#689d6a` |
| `orange` | `#fe8019` | `#d65d0e` |

## Semantic Aliases

| Name | Maps to | Purpose |
|------|---------|---------|
| `primary` | `blue` | Primary actions |
| `secondary` | `bg2` | Secondary surfaces |
| `accent` | `aqua` | Highlights |
| `text` | `fg1` | Body text |
| `border` | `bg3` | Borders |
| `success` | `green` | Success states |
| `error` | `red` | Errors |
| `info` | `blue` | Informational |

## Component-Specific

| Name | Hex | Purpose |
|------|-----|---------|
| `barBackground` | `#1d2021` | HUDBar background |
| `buttonHover` | `#3c3836` | Button hover state |
| `workspaceActive` | `#458588` | Active workspace indicator |

## Metrics

| Property | Value | Description |
|----------|-------|-------------|
| `hudIconSize` | 16 | Icon size in HUD bar |
| `hudIconSpacing` | 4 | Spacing between icons |
| `trayIconSize` | 16 | System tray icon size |
| `trayIconSpacing` | 3 | System tray spacing |

## Icon Component

`Common/Icon.qml` loads icons with a multi-level fallback chain, managed by `IconService`.

### Resolution Priority

1. **Overrides**: Checks `IconService.overrides` for name mapping (e.g., `foot` → `terminal`).
2. **Theme**: System icon theme lookup via `Quickshell.iconPath()`.
3. **Manual Lookup**: Direct filesystem search in `hicolor` directories, including Flatpak exports.
4. **System Pixmaps**: Checks `/usr/share/pixmaps`.
5. **Fallback**: User-specified `fallback` property.
6. **Default**: `application-x-executable` icon.
7. **Monogram**: First letter of the name on an HSL-hashed color background.

**Properties:** `name`, `fallback`, `size` (default 16), `iconColor`
