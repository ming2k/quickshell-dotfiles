/**
 * Summon History Service - Singleton
 *
 * Tracks application launch history and provides frecency-based sorting.
 * Frecency = Frequency + Recency - prioritizes both often-used and recently-used apps.
 *
 * Storage: ~/.local/share/quickshell/summon-history.json
 * Format: { "app-id": { "count": 5, "lastLaunch": 1234567890 } }
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    // History data: { "app-id": { count: number, lastLaunch: timestamp } }
    property var history: ({})

    // Storage file path (XDG_DATA_HOME)
    readonly property string historyFile: {
        const dataHome = Quickshell.env("XDG_DATA_HOME") || (Quickshell.env("HOME") + "/.local/share")
        return dataHome + "/quickshell/summon-history.json"
    }

    // Frecency weights
    readonly property real recencyWeight: 0.6  // 60% weight on recency
    readonly property real frequencyWeight: 0.4  // 40% weight on frequency
    readonly property int maxAge: 30 * 24 * 60 * 60 * 1000  // 30 days in milliseconds

    // Process for loading history
    property Process loadProcess: Process {
        id: loadProc
        running: false

        command: ["cat", historyFile]

        stdout: SplitParser {
            splitMarker: "\x04"  // Use EOT character as unlikely delimiter
            onRead: data => {
                try {
                    const parsed = JSON.parse(data)
                    history = parsed
                    console.log("Summon history loaded:", Object.keys(history).length, "entries")
                } catch (e) {
                    console.warn("Failed to parse history file:", e)
                    history = {}
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                // File doesn't exist or can't be read - that's fine
                console.log("No existing history file, starting fresh")
                history = {}
            }
        }
    }

    /**
     * Load history from disk
     */
    function loadHistory() {
        loadProcess.running = true
    }

    /**
     * Save history to disk
     */
    function saveHistory() {
        const json = JSON.stringify(history, null, 2)

        // Use Quickshell.execDetached to run save command
        // This is fire-and-forget, which is fine for saving history
        const cmd = `mkdir -p "$(dirname "${historyFile}")" && cat > "${historyFile}" <<'HISTEOF'\n${json}\nHISTEOF\n`
        Quickshell.execDetached(["sh", "-c", cmd])
    }

    /**
     * Record an application launch
     */
    function recordLaunch(appId) {
        if (!appId) return

        const now = Date.now()

        if (!history[appId]) {
            history[appId] = { count: 0, lastLaunch: 0 }
        }

        history[appId].count++
        history[appId].lastLaunch = now

        // Trigger property change for QML bindings
        history = Object.assign({}, history)

        saveHistory()
        console.log("Recorded launch:", appId, "->", history[appId].count, "times")
    }

    /**
     * Calculate frecency score for an application
     * Higher score = more relevant (should appear first)
     */
    function getFrecency(appId) {
        const entry = history[appId]
        if (!entry) return 0

        const now = Date.now()
        const age = now - entry.lastLaunch  // milliseconds since last launch

        // Recency score: exponential decay over 30 days
        // Recently launched apps get higher scores
        const recencyScore = Math.exp(-age / maxAge) * 100

        // Frequency score: normalize launch count
        // Apps launched more often get higher scores
        const frequencyScore = Math.min(entry.count * 2, 100)

        // Combined frecency score
        const frecency = (recencyScore * recencyWeight) + (frequencyScore * frequencyWeight)

        return frecency
    }

    /**
     * Sort applications by frecency
     * Apps with no history appear at the end, sorted alphabetically
     */
    function sortByFrecency(apps) {
        return apps.slice().sort((a, b) => {
            const frecencyA = getFrecency(getAppId(a))
            const frecencyB = getFrecency(getAppId(b))

            // If both have history, sort by frecency
            if (frecencyA > 0 && frecencyB > 0) {
                return frecencyB - frecencyA  // Higher frecency first
            }

            // If only one has history, it goes first
            if (frecencyA > 0) return -1
            if (frecencyB > 0) return 1

            // If neither has history, sort alphabetically
            return a.name.localeCompare(b.name)
        })
    }

    /**
     * Get a stable app ID from a desktop entry
     * Uses command as the ID (more stable than name)
     */
    function getAppId(app) {
        // Use command as ID (e.g., "firefox", "code", etc.)
        // This is more stable than names which might change with localization
        return app.command || app.name
    }

    /**
     * Clear old entries (optional maintenance)
     * Remove entries older than 90 days with low frequency
     */
    function pruneOldEntries() {
        const now = Date.now()
        const pruneAge = 90 * 24 * 60 * 60 * 1000  // 90 days
        let pruned = 0

        for (const appId in history) {
            const entry = history[appId]
            const age = now - entry.lastLaunch

            // Remove if very old AND rarely used
            if (age > pruneAge && entry.count < 3) {
                delete history[appId]
                pruned++
            }
        }

        if (pruned > 0) {
            history = Object.assign({}, history)
            saveHistory()
            console.log("Pruned", pruned, "old entries from history")
        }
    }

    Component.onCompleted: {
        loadHistory()

        // Prune old entries on startup (optional maintenance)
        pruneOldEntries()

        console.log("SummonHistoryService initialized")
        console.log("History file:", historyFile)
    }
}
