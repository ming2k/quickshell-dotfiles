pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property bool visible: false
    property string focusedOutput: NiriService.focusedOutput
    property bool showPending: false

    // FIFO IPC watcher - reads commands (toggle/show/hide) from named pipe.
    // FIFO is pre-created in shell.qml for fastest boot readiness.
    property Process fifoWatcher: Process {
        running: true
        command: ["sh", "-c", "while ! [ -p /tmp/quickshell-summon.fifo ]; do sleep 0.05; done; while true; do if read cmd < /tmp/quickshell-summon.fifo; then echo \"$cmd\"; fi; done"]

        stdout: SplitParser {
            onRead: data => {
                const cmd = data.trim()
                switch(cmd) {
                    case "toggle": service.toggle(); break
                    case "show": service.show(); break
                    case "hide": service.hide(); break
                }
            }
        }
    }

    onFocusedOutputChanged: {
        if (showPending && focusedOutput) {
            visible = true
            showPending = false
        }
    }

    function requestShow() {
        if (focusedOutput) {
            visible = true
            showPending = false
            return
        }
        showPending = true
    }

    function toggle() {
        if (visible || showPending) hide()
        else requestShow()
    }

    function show() { requestShow() }

    function hide() {
        showPending = false
        visible = false
    }

    // Polling for Flatpak exports for newly installed applications/icons.
    // Quickshell's DesktopEntries only watches standard paths; this ensures
    // new Flatpaks show up without a manual shell restart.
    property string _lastFlatpakState: ""
    
    property Process flatpakPoller: Process {
        id: flatpakPoller
        running: false
        command: [
            "sh", "-c",
            "ls -ld --time-style=+%s " +
            "/var/lib/flatpak/exports/share/applications " +
            "/var/lib/flatpak/exports/share/icons " +
            "~/.local/share/flatpak/exports/share/applications " +
            "~/.local/share/flatpak/exports/share/icons " +
            "2>/dev/null | awk '{print $6}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const currentState = text
                    .trim()
                    .split(/\s+/)
                    .filter(value => value.length > 0)
                    .sort()
                    .join("\n")

                if (service._lastFlatpakState !== "" && service._lastFlatpakState !== currentState) {
                    Quickshell.reload(false)
                }

                service._lastFlatpakState = currentState
            }
        }
    }

    // Polling for Flatpaks reduced from 10s to 30s as it's not a critical high-frequency task
    property Timer flatpakPollTimer: Timer {
        interval: 30000 // Poll every 30 seconds
        running: true
        repeat: true
        onTriggered: flatpakPoller.running = true
    }
}
