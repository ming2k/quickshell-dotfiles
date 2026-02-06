pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property bool visible: false
    property var summonWindow: null

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

    function toggle() { visible = !visible }
    function show() { visible = true }
    function hide() { visible = false }
}
