# Quickshell Configuration

A QML-based desktop shell for the **Niri** Wayland compositor, providing a complete panel experience with system monitoring, notifications, media controls, and an application launcher.

## Overview

This configuration builds on the [Quickshell](https://quickshell.outfoxxed.me/) framework (Qt6/QML) and uses the Wayland Layer Shell protocol for window management. It features a Gruvbox color theme throughout.

## Architecture

```
shell.qml                      Entry point
├── Services/                   Singleton services (system state)
│   ├── AudioService            Volume/mute via wpctl (PipeWire)
│   ├── BatteryService          Battery level/charge via sysfs
│   ├── NetworkService          WiFi/Ethernet/USB — IWD D-Bus monitor + iwctl
│   ├── PrivacyService          Camera/mic/screencast via fuser + pw-dump
│   ├── InhibitService          Idle inhibit (swayidle control)
│   ├── MprisService            Media player integration (D-Bus, event-driven)
│   ├── TypioService            Typio input method status + engine cycling
│   ├── PomodoroService         Pomodoro Timer D-Bus integration
│   ├── SummonService           App launcher visibility control
│   ├── SummonHistoryService    Launch history + frecency sorting
│   └── NotificationCenterService  Notification history + center
├── Modules/
│   ├── HUDBar/                 Top panel + notification center overlay
│   │   ├── HUDBar.qml          Main 32px panel bar
│   │   ├── HUDShade.qml        Notification center + quick controls
│   │   └── Widgets/            Individual panel widgets
│   ├── Notifications/          Desktop notification popups (D-Bus)
│   └── Summon/                 Application launcher
└── Common/
    ├── Colors.qml              Gruvbox color theme singleton
    └── Icon.qml                Icon loader with fallback chain
```

## Panel Layout (HUDBar)

```
[Workspaces] [Window Title]  |  [Clock]  |  [SystemTray] [Typio] [Pomodoro] [Privacy] [Audio] [Network] [Battery] [Bell]
```

## Key Bindings

| Action         | Trigger                               |
|----------------|---------------------------------------|
| Open launcher  | Write `toggle` to `/tmp/quickshell-summon.fifo` (bind to Super+Space in Niri) |
| Search apps    | Type while launcher is open           |
| Navigate apps  | Arrow keys + Enter                    |
| Close launcher | Escape                                |
| Adjust volume  | Scroll on Audio widget                |
| Toggle mute    | Click Audio widget                    |
| Notification center | Click Bell widget                |

## Data Files

| File | Purpose |
|------|---------|
| `~/.local/share/quickshell/summon-history.json` | App launch frecency data |
| `~/.local/share/quickshell/notification-history.json` | Persistent notification history |

## Documentation

- [Services](services.md) - System services reference
- [Widgets](widgets.md) - Panel widget reference
- [Theme](theme.md) - Colors and styling
- [Environment](environment.md) - System requirements and configuration
