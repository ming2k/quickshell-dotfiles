# Environment & Configuration

## System Requirements

| Component | Required | Used by |
|-----------|----------|---------|
| [Quickshell](https://quickshell.outfoxxed.me/) | Framework | Everything |
| [Niri](https://github.com/YaLTeR/niri) | Wayland compositor | Workspaces, WindowTitle, SummonService |
| PipeWire + wireplumber | Audio server | AudioService (`wpctl`) |
| iwd | WiFi daemon | NetworkService (`iwctl`) |
| swayidle + swaylock | Idle/lock management | InhibitService |
| Papirus-Dark | Icon theme | All icons |
| jq | JSON processor | PrivacyService screencast detection |

## Qt Configuration

Set in `shell.qml` via pragma directives:

```qml
//@ pragma UseQApplication           // Required for SystemTray support
//@ pragma IconTheme Papirus-Dark    // Icon theme
//@ pragma Env QT_QPA_PLATFORMTHEME = qt6ct
```

## External Control

The application launcher (Summon) is controlled via a FIFO:

```bash
# Bind in your Niri config:
echo toggle > /tmp/quickshell-summon.fifo
echo show   > /tmp/quickshell-summon.fifo
echo hide   > /tmp/quickshell-summon.fifo
```

The FIFO is created automatically on shell startup.

## Data Storage

All persistent data is stored in `~/.local/share/quickshell/`:

| File | Format | Content |
|------|--------|---------|
| `summon-history.json` | JSON | `{appId: {count, lastLaunch}}` |
| `notification-history.json` | JSON | Array of notification objects |

## Notification Sounds

Notification popups play sounds on arrival:
- Critical/urgent notifications: `critical.mp3`
- Normal notifications: `normal.mp3`

Sound files should be placed where the NotificationPopup component expects them (check `NotificationPopup.qml` for the path).

## Wayland Layer Shell

Windows use WlrLayershell for positioning:

| Window | Layer | Purpose |
|--------|-------|---------|
| PanelWindow (HUDBar) | Top | Main panel, 32px tall |
| NotificationPopup | Overlay | Notification popups, top-right |
| ClockTooltip | Overlay | Clock hover tooltip |
| HUDShade | Overlay | Notification center overlay |
| SummonWindow | Overlay | Application launcher |
