# Services Reference

All services are QML singletons (`pragma Singleton`) — a single instance shared across all components.

Services use a combination of strategies: event-driven D-Bus monitors (`gdbus monitor`) for low-latency updates with no overhead at rest, and periodic polling as a fallback. QML property bindings propagate state changes to the UI automatically.

```qml
import "../Services"
Text { text: AudioService.volumeLevel + "%" }
```

---

## AudioService

Controls and monitors system audio via `wpctl` (PipeWire/WirePlumber).

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

**Poll interval:** 5 seconds

**Note:** Uses `wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+` syntax (the `%+`/`%-` suffix form, not prefix).

---

## BatteryService

Reads battery state from `/sys/class/power_supply/`.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `hasBattery` | bool | Whether a battery device was found |
| `percent` | int | Current charge 0-100 |
| `isCharging` | bool | True when status is `Charging` |

**Poll interval:** 30 seconds

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

**Methods:**
- `refresh()` — Re-query network state immediately

**Strategy:** `gdbus monitor --system --dest net.connman.iwd` triggers an immediate refresh on any IWD state change; 30-second polling acts as fallback.

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
| `microphoneActive` | bool | PipeWire audio input stream active |
| `screencastActive` | bool | PipeWire screen share active |
| `anyActive` | bool | Any of the above |

**Detection methods (single combined process):**
- Camera: `fuser /dev/video*`
- Microphone: `pw-dump | jq` — `Stream/Input/Audio` nodes
- Screencast: `pw-dump | jq` — `Video/Source` nodes with non-Camera role

**Poll interval:** 10 seconds

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

Media player integration via Quickshell's built-in MPRIS support. Fully event-driven — no polling.

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

## TypioService

Monitors the `org.typio.InputMethod1` session-bus service and exposes the active input engine for HUDBar.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `available` | bool | Whether Typio is reachable on the session bus |
| `activeEngine` | string | Active keyboard engine id |
| `displayName` | string | Human-readable engine name |
| `iconName` | string | Engine icon name from `ActiveEngineState` |
| `language` | string | Active engine language code |
| `rimeSchema` | string | Current Rime schema id |
| `modeClass` | string | Active mode class from `ActiveEngineMode` |
| `modeId` | string | Active mode id from `ActiveEngineMode` |
| `modeLabel` | string | Short active mode label shown in HUDBar |
| `modeIconName` | string | Active mode icon name from `ActiveEngineMode` |
| `statusText` | string | Label shown in HUDBar |

**Methods:**
- `refresh()` — Re-query Typio state immediately
- `nextEngine()` — Call `org.typio.InputMethod1.NextEngine`

**Strategy:** `gdbus monitor --session` on the Typio object triggers an immediate refresh on `PropertiesChanged` or engine changes; 5-second polling acts as fallback.

---

## PomodoroService

Integrates with the [Pomodoro Timer](https://github.com/ming2k/pomodoro-timer) app via its D-Bus interface (`io.github.ming2k.PomodoroTimer`). The widget is hidden when the app is not running.

**D-Bus details:**
| Field | Value |
|-------|-------|
| Bus | Session |
| Service | `io.github.ming2k.PomodoroTimer` |
| Object path | `/io/github/ming2k/PomodoroTimer` |

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `available` | bool | App is running and reachable |
| `state` | string | `stopped`, `running`, `paused`, `completed` |
| `sessionType` | string | `work`, `short_break`, `long_break` |
| `timeRemaining` | int | Seconds remaining (decremented locally each second when running) |
| `totalDuration` | int | Total seconds for current session |
| `progressPercent` | real | Elapsed percentage 0.0–100.0 |
| `sessionsCompleted` | int | Work sessions finished since app start |
| `timeText` | string | `"MM:SS"` formatted time |
| `sessionLabel` | string | `"Work"`, `"Break"`, or `"Long Break"` |

**Methods:**
- `toggleStartPause()` — Start if stopped/paused, pause if running
- `skip()` — Skip to next session
- `stop()` — Stop and reset current session

**Strategy:** `gdbus monitor --session` on the Pomodoro object triggers a refresh on every `StateChanged` signal (fired on state transitions and once per minute while running). A local 1-second `Timer` decrements `timeRemaining` while running so the display stays smooth. 10-second polling acts as fallback.

---

## IconService

Provides centralized icon name resolution and override management for `Icon.qml`. This service manages the mapping between application identifiers and the icon names found in system themes.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `overrides` | object | Map of app names to preferred icon names |
| `searchPriority` | list | List of search categories in order: `theme` > `manual` > `fallback` > `default` > `monogram` |

**Methods:**
- `resolveName(name)` — Returns the overridden icon name or the original name if no override exists.

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
recencyScore   = exp(-age / 30 days) * 100     // exponential decay
frequencyScore = min(count * 2, 100)            // capped
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
