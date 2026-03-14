# Widgets Reference

All widgets live in `Modules/HUDBar/Widgets/` and are arranged horizontally in the 32px HUDBar panel.

---

## Workspaces

Displays workspace indicators for the current monitor. Each workspace shows its number with a colored background. The active workspace is highlighted and the focused workspace has a top indicator bar.

**Interaction:** Click a workspace to switch to it via `niri msg action focus-workspace`.

**Update interval:** 250ms (polls `niri msg -j workspaces`)

---

## WindowTitle

Shows the title of the currently focused window, truncated to 300px max width with ellipsis.

**Update interval:** 500ms (polls `niri msg -j windows`)

---

## Clock

Displays the current time in `HH:mm` format. On hover, expands to show seconds (`HH:mm:ss`) and opens a tooltip window with the full date, day of week, and ISO week number.

**Update interval:** 60s (1s while hovering)

---

## SystemTray

Renders StatusNotifierItem (SNI) icons from D-Bus system tray entries. Each icon is 24px.

**Interaction:**
- Left-click: Activate the tray item
- Right-click: Open context menu

---

## Audio

Shows current volume percentage or "Muted" with a dynamic volume icon.

**Interaction:**
- Click: Toggle mute
- Scroll up/down: Adjust volume by 2%

**Service:** `AudioService`

---

## Network

Shows connection type and status:
- WiFi: SSID name + signal icon
- Ethernet: "Ethernet"
- USB: "USB Tethering"
- Disconnected: "Disconnected" (orange text)

**Service:** `NetworkService`

---

## Privacy

Shows orange indicator icons when camera, microphone, or screencast are active. Hidden when no resources are in use.

**Service:** `PrivacyService`

---

## Battery

Displays battery percentage with a level-appropriate icon. Color-coded: green (charging), red (<15%), orange (<30%).

Hidden if no battery is detected in `/sys/class/power_supply/`.

**Update interval:** 30 seconds

---

## NotificationBell

Badge showing unread notification count (capped at "99+"). Click to toggle the notification center (HUDShade).

**Service:** `NotificationCenterService`

---

## MprisCard

Media player card shown inside HUDShade (not in the main bar). Displays album art, track title, artist, and playback controls (previous/play-pause/next).

**Service:** `MprisService`

---

## Inhibit

Quick toggle for idle inhibition, shown in the HUDShade controls section.

**Service:** `InhibitService`
