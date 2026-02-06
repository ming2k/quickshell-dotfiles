pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    // { "app-id": { count: number, lastLaunch: timestamp } }
    property var history: ({})

    readonly property string historyFile: {
        const dataHome = Quickshell.env("XDG_DATA_HOME") || (Quickshell.env("HOME") + "/.local/share")
        return dataHome + "/quickshell/summon-history.json"
    }

    readonly property real recencyWeight: 0.6
    readonly property real frequencyWeight: 0.4
    readonly property real maxAge: 30 * 24 * 60 * 60 * 1000  // 30 days (use real to avoid int overflow)

    property Process loadProcess: Process {
        id: loadProc
        running: false
        command: ["cat", historyFile]

        stdout: SplitParser {
            splitMarker: "\x04"
            onRead: data => {
                try {
                    service.history = JSON.parse(data)
                    service.pruneOldEntries()
                } catch (e) {
                    service.history = {}
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                service.history = {}
            }
        }
    }

    function loadHistory() {
        loadProcess.running = true
    }

    function saveHistory() {
        const json = JSON.stringify(history, null, 2)
        const cmd = `mkdir -p "$(dirname "${historyFile}")" && cat > "${historyFile}" <<'HISTEOF'\n${json}\nHISTEOF\n`
        Quickshell.execDetached(["sh", "-c", cmd])
    }

    function recordLaunch(appId) {
        if (!appId) return

        if (!history[appId]) {
            history[appId] = { count: 0, lastLaunch: 0 }
        }

        history[appId].count++
        history[appId].lastLaunch = Date.now()

        // Trigger property change for QML bindings
        history = Object.assign({}, history)
        saveHistory()
    }

    function getFrecency(appId) {
        const entry = history[appId]
        if (!entry) return 0

        const age = Date.now() - entry.lastLaunch
        const recencyScore = Math.exp(-age / maxAge) * 100
        const frequencyScore = Math.min(entry.count * 2, 100)
        return (recencyScore * recencyWeight) + (frequencyScore * frequencyWeight)
    }

    function sortByFrecency(apps) {
        return apps.slice().sort((a, b) => {
            const frecencyA = getFrecency(getAppId(a))
            const frecencyB = getFrecency(getAppId(b))

            if (frecencyA > 0 && frecencyB > 0) return frecencyB - frecencyA
            if (frecencyA > 0) return -1
            if (frecencyB > 0) return 1
            return a.name.localeCompare(b.name)
        })
    }

    function getAppId(app) {
        const cmd = app.command || app.name
        return Array.isArray(cmd) ? cmd.join(",") : String(cmd)
    }

    // Remove entries older than 90 days with low frequency
    function pruneOldEntries() {
        const now = Date.now()
        const pruneAge = 90 * 24 * 60 * 60 * 1000
        let pruned = 0

        for (const appId in history) {
            const entry = history[appId]
            if (now - entry.lastLaunch > pruneAge && entry.count < 3) {
                delete history[appId]
                pruned++
            }
        }

        if (pruned > 0) {
            history = Object.assign({}, history)
            saveHistory()
        }
    }

    Component.onCompleted: {
        loadHistory()
    }
}
