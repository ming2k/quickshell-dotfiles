/**
 * Summon Service - Singleton
 *
 * Manages the application summon (launcher) state and provides methods to show/hide it.
 * Handles IPC communication via named pipe to receive toggle commands from external sources.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    // Summon visibility state
    property bool visible: false

    // Reference to the summon window instance
    property var summonWindow: null

    /**
     * Named Pipe (FIFO) for IPC
     *
     * External programs can write commands to this pipe:
     * - "toggle" - Toggle summon visibility
     * - "show" - Show summon
     * - "hide" - Hide summon
     */
    property Process fifoWatcher: Process {
        running: true
        command: ["sh", "-c", "mkfifo /tmp/quickshell-summon.fifo 2>/dev/null || true; while true; do if read cmd < /tmp/quickshell-summon.fifo; then echo \"$cmd\"; fi; done"]

        stdout: SplitParser {
            onRead: data => {
                const cmd = data.trim()
                console.log("Summon IPC received:", cmd)

                switch(cmd) {
                    case "toggle":
                        service.toggle()
                        break
                    case "show":
                        service.show()
                        break
                    case "hide":
                        service.hide()
                        break
                    default:
                        console.warn("Unknown summon command:", cmd)
                }
            }
        }
    }

    /**
     * Toggle summon visibility
     */
    function toggle() {
        visible = !visible
        console.log("Summon toggled:", visible ? "visible" : "hidden")
    }

    /**
     * Show summon
     */
    function show() {
        visible = true
        console.log("Summon shown")
    }

    /**
     * Hide summon
     */
    function hide() {
        visible = false
        console.log("Summon hidden")
    }

    Component.onCompleted: {
        console.log("SummonService initialized")
        console.log("IPC available at: /tmp/quickshell-summon.fifo")
    }
}
