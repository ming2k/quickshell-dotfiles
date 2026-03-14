# Services Reference

All services are QML singletons (`pragma Singleton`) — a single instance shared across all components.

Services use a polling pattern: a `Process` runs a shell command, a `Timer` re-triggers it on an interval, and QML property bindings propagate state changes to the UI automatically.

```qml
import "../Services"
Text { text: AudioService.volumeLevel + "%" }
```

---

## AudioService

Controls and monitors system audio via `wpctl` (PipeWire/wireplumber).

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `volumeLevel` | string | Current volume 0-100 |
| `isMuted` | bool | Mute state |
| `iconName` | string | Dynamic icon based on level |

**Methods:**
- `toggleMute()` — Toggle mute on/off
- `increaseVolume()` — +2%
- `decreaseVolume()` — -2%
- `setVolume(percentage)` — Set absolute volume

**Poll interval:** 2 seconds

**Note:** Uses `wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+` syntax (the `%+`/`%-` suffix form, not prefix).

---

## NetworkService

Monitors network connectivity — WiFi (iwd), Ethernet, and USB tethering.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `connectionType` | string | `"wifi"`, `"ethernet"`, `"usb"`, or `"disconnected"` |
| `ssid` | string | WiFi network name |
| `signalStrength` | int | WiFi signal 0-100% |
| `ipAddress` | string | Current IP address |
| `iconName` | string | Dynamic icon |

**Poll interval:** 5 seconds

**Signal strength formula:**
```
signal = 100 - ((rssi + 30) * -1 * 100 / 60)
// RSSI range: -90 (worst) to -30 (best), clamped 0-100
```

---

## PrivacyService

Monitors active camera, microphone, and screencast usage.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `cameraActive` | bool | `/dev/video*` in use |
| `microphoneActive` | bool | Audio source outputs active |
| `screencastActive` | bool | PipeWire screen share active |
| `anyActive` | bool | Any of the above |

**Detection methods:**
- Camera: `fuser /dev/video*`
- Microphone: `pactl list source-outputs`
- Screencast: `pw-dump | jq` (PipeWire graph query)

**Poll interval:** 5 seconds

---

## InhibitService

Controls idle inhibition by starting/stopping `swayidle`.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `isInhibited` | bool | True when swayidle is killed |

**Methods:**
- `toggleInhibit()` — Toggle idle inhibition

**Idle timeouts (when active):**
- 570s: Dim display to 10%
- 600s: Lock with swaylock
- 605s: Turn off displays
- 1800s: Suspend

---

## MprisService

Media player integration via MPRIS D-Bus interface.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `players` | array | All MPRIS players |
| `activePlayer` | object | Currently active player |
| `hasPlayers` | bool | Any players available |
| `displayTitle` | string | Track title or "Nothing playing" |
| `displaySubtitle` | string | Artist, album, or player name |
| `playbackStatus` | string | "Playing", "Paused", "Stopped" |
| `artUrl` | string | Album art URL |
| `canGoPrevious` | bool | Player capability |
| `canGoNext` | bool | Player capability |

**Methods:**
- `togglePlayback()` — Play/pause
- `previous()` / `next()` — Skip tracks
- `raise()` — Bring player window to front
- `selectPlayer(player)` — Choose specific player

**Player selection priority:** preferred player > last active (playing) > any playing > last active > first available.

---

## SummonService

Controls the application launcher window visibility.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `visible` | bool | Launcher shown |
| `focusedOutput` | string | Current monitor name |

**Methods:**
- `show()` / `hide()` / `toggle()`
- `requestShow()` — Show with focus detection

**External control:** Write `toggle`, `show`, or `hide` to `/tmp/quickshell-summon.fifo`.

---

## SummonHistoryService

Tracks app launch history and provides frecency-based sorting.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `history` | object | `{appId: {count, lastLaunch}}` |

**Methods:**
- `recordLaunch(appId)` — Record a launch
- `getFrecency(appId)` — Get frecency score
- `sortByFrecency(apps)` — Sort app list

**Frecency algorithm:**
```
recencyScore  = exp(-age / 30 days) * 100     // exponential decay
frequencyScore = min(count * 2, 100)           // capped
frecency = recency * 0.6 + frequency * 0.4
```

**Storage:** `~/.local/share/quickshell/summon-history.json`

---

## NotificationCenterService

Manages notification history, read status, and the notification center panel.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `items` | array | All notifications (max 100) |
| `centerVisible` | bool | Center panel open |
| `activeScreenName` | string | Monitor showing center |
| `unreadCount` | int | Unread notification count |
| `popupIds` | array | Currently visible popup IDs |

**Methods:**
- `addNotification(notification)` — Add to history
- `markAsRead(id)` / `markAllRead()` — Mark read
- `removeNotification(id)` — Remove from history
- `clearHistory()` — Clear all
- `openCenter(screenName)` / `closeCenter()` / `toggleCenter(screenName)`
- `launchApp(desktopEntry)` — Open associated app

**Storage:** `~/.local/share/quickshell/notification-history.json`
