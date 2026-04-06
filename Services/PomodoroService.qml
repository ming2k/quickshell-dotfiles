pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: pomodoroService

    readonly property string serviceName: "io.github.ming2k.PomodoroTimer"
    readonly property string objectPath: "/io/github/ming2k/PomodoroTimer"
    readonly property string interfaceName: "io.github.ming2k.PomodoroTimer"

    property bool available: false
    property string state: "stopped"
    property string sessionType: "work"
    property int timeRemaining: 0
    property int totalDuration: 0
    property real progressPercent: 0.0
    property int sessionsCompleted: 0

    readonly property string timeText: {
        const m = Math.floor(timeRemaining / 60)
        const s = timeRemaining % 60
        return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
    }

    readonly property string sessionLabel: {
        switch (sessionType) {
            case "work": return "Work"
            case "short_break": return "Break"
            case "long_break": return "Long Break"
            default: return sessionType
        }
    }

    function refresh() {
        if (!statusChecker.running) {
            statusChecker.running = true
        }
    }

    function applyUnavailableState() {
        available = false
    }

    function toggleStartPause() {
        if (state === "running") {
            pauseLoader.active = true
        } else {
            startLoader.active = true
        }
    }

    function skip() {
        skipLoader.active = true
    }

    function stop() {
        stopLoader.active = true
    }

    property var statusChecker: Process {
        id: statusChecker
        running: true
        command: ["sh", "-c", `
            output=$(gdbus call --session \
                --dest io.github.ming2k.PomodoroTimer \
                --object-path /io/github/ming2k/PomodoroTimer \
                --method org.freedesktop.DBus.Properties.GetAll \
                io.github.ming2k.PomodoroTimer 2>/dev/null) || {
                echo "0|||||"
                exit 0
            }
            state=$(printf '%s\n' "$output" | sed -n "s/.*'State': <'\\([^']*\\)'.*/\\1/p")
            session=$(printf '%s\n' "$output" | sed -n "s/.*'SessionType': <'\\([^']*\\)'.*/\\1/p")
            remaining=$(printf '%s\n' "$output" | sed -n "s/.*'TimeRemaining': <uint32 \\([0-9]*\\).*/\\1/p")
            total=$(printf '%s\n' "$output" | sed -n "s/.*'TotalDuration': <uint32 \\([0-9]*\\).*/\\1/p")
            progress=$(printf '%s\n' "$output" | sed -n "s/.*'ProgressPercent': <\\([0-9.]*\\).*/\\1/p")
            completed=$(printf '%s\n' "$output" | sed -n "s/.*'SessionsCompleted': <uint32 \\([0-9]*\\).*/\\1/p")
            remaining=\${remaining:-0}
            total=\${total:-0}
            progress=\${progress:-0}
            completed=\${completed:-0}
            if [ -z "$state" ]; then
                echo "0|||||"
            else
                printf '1|%s|%s|%s|%s|%s|%s\n' "$state" "$session" "$remaining" "$total" "$progress" "$completed"
            fi
        `]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")
                if (parts.length < 7 || parts[0] !== "1") {
                    pomodoroService.applyUnavailableState()
                    return
                }
                pomodoroService.available = true
                pomodoroService.state = parts[1]
                pomodoroService.sessionType = parts[2]
                pomodoroService.timeRemaining = parseInt(parts[3]) || 0
                pomodoroService.totalDuration = parseInt(parts[4]) || 0
                pomodoroService.progressPercent = parseFloat(parts[5]) || 0.0
                pomodoroService.sessionsCompleted = parseInt(parts[6]) || 0
            }
        }
    }

    property var countdownTimer: Timer {
        interval: 1000
        running: pomodoroService.available && pomodoroService.state === "running"
        repeat: true
        onTriggered: {
            if (pomodoroService.timeRemaining > 0) {
                pomodoroService.timeRemaining -= 1
            }
        }
    }

    property var refreshTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: pomodoroService.refresh()
    }

    property var propertyMonitor: Process {
        running: true
        command: [
            "gdbus", "monitor", "--session",
            "--dest", pomodoroService.serviceName,
            "--object-path", pomodoroService.objectPath
        ]

        stdout: SplitParser {
            onRead: data => {
                if (data.trim().includes("StateChanged")) {
                    pomodoroService.refresh()
                }
            }
        }

        onExited: {
            pomodoroService.applyUnavailableState()
            monitorRestartTimer.restart()
        }
    }

    property var monitorRestartTimer: Timer {
        interval: 5000
        running: false
        repeat: false
        onTriggered: propertyMonitor.running = true
    }

    property var startLoader: Loader {
        id: startLoader
        active: false
        sourceComponent: Process {
            running: true
            command: ["gdbus", "call", "--session",
                "--dest", pomodoroService.serviceName,
                "--object-path", pomodoroService.objectPath,
                "--method", pomodoroService.interfaceName + ".Start"]
            onExited: {
                startLoader.active = false
                pomodoroService.refresh()
            }
        }
    }

    property var pauseLoader: Loader {
        id: pauseLoader
        active: false
        sourceComponent: Process {
            running: true
            command: ["gdbus", "call", "--session",
                "--dest", pomodoroService.serviceName,
                "--object-path", pomodoroService.objectPath,
                "--method", pomodoroService.interfaceName + ".Pause"]
            onExited: {
                pauseLoader.active = false
                pomodoroService.refresh()
            }
        }
    }

    property var stopLoader: Loader {
        id: stopLoader
        active: false
        sourceComponent: Process {
            running: true
            command: ["gdbus", "call", "--session",
                "--dest", pomodoroService.serviceName,
                "--object-path", pomodoroService.objectPath,
                "--method", pomodoroService.interfaceName + ".Stop"]
            onExited: {
                stopLoader.active = false
                pomodoroService.refresh()
            }
        }
    }

    property var skipLoader: Loader {
        id: skipLoader
        active: false
        sourceComponent: Process {
            running: true
            command: ["gdbus", "call", "--session",
                "--dest", pomodoroService.serviceName,
                "--object-path", pomodoroService.objectPath,
                "--method", pomodoroService.interfaceName + ".Skip"]
            onExited: {
                skipLoader.active = false
                pomodoroService.refresh()
            }
        }
    }
}
