pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property bool visible: false
    property string focusedOutput: ""
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

    property Process focusedOutputQuery: Process {
        running: true
        command: ["sh", "-c", "niri msg -j workspaces"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    let ws = JSON.parse(data.trim())
                    let focused = ws.find(w => w.is_focused)
                    if (focused) service.focusedOutput = focused.output
                    if (service.showPending) {
                        service.visible = true
                        service.showPending = false
                    }
                } catch (e) {}
            }
        }
    }

    property Timer focusedOutputTimer: Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: focusedOutputQuery.running = true
    }

    function requestShow() {
        if (focusedOutput) {
            visible = true
            showPending = false
            focusedOutputQuery.running = true
            return
        }

        showPending = true
        focusedOutputQuery.running = true
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
}
