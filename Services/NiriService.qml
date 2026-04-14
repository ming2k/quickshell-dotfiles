pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property var workspaces: []
    property var windows: []

    property string focusedOutput: ""
    property int focusedWorkspaceId: -1
    property var focusedWindow: null

    property Process eventStream: Process {
        running: true
        command: ["niri", "msg", "-j", "event-stream"]

        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                try {
                    let event = JSON.parse(data.trim())
                    service.handleEvent(event)
                } catch (e) {
                    console.log("NiriService: Failed to parse event:", e)
                }
            }
        }
    }

    // Fallback timer to fetch full state initially if event-stream misses it,
    // and to correct any missed states (every 10 seconds instead of 0.25s).
    property Timer statePoller: Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            workspaceQuery.running = true
            windowQuery.running = true
        }
    }

    property Process workspaceQuery: Process {
        running: true // run once on startup
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    service.workspaces = JSON.parse(data.trim())
                    service.updateWorkspaceFocus()
                } catch (e) {}
            }
        }
    }

    property Process windowQuery: Process {
        running: true // run once on startup
        command: ["niri", "msg", "-j", "windows"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    service.windows = JSON.parse(data.trim())
                    service.updateWindowFocus()
                } catch (e) {}
            }
        }
    }

    function handleEvent(event) {
        if (event.WorkspacesChanged) {
            workspaces = event.WorkspacesChanged.workspaces
            updateWorkspaceFocus()
        }
        else if (event.WindowsChanged) {
            windows = event.WindowsChanged.windows
            updateWindowFocus()
        }
        else if (event.WindowFocusChanged) {
            let id = event.WindowFocusChanged.id
            let updated = []
            let foundFocus = null
            for (let w of windows) {
                let copy = Object.assign({}, w)
                copy.is_focused = (copy.id === id)
                updated.push(copy)
                if (copy.is_focused) foundFocus = copy
            }
            windows = updated
            focusedWindow = foundFocus
        }
        else if (event.WorkspaceActivated) {
            let id = event.WorkspaceActivated.id
            let updated = []
            for (let w of workspaces) {
                let copy = Object.assign({}, w)
                copy.is_focused = (copy.id === id)
                if (copy.is_focused) focusedOutput = copy.output
                updated.push(copy)
            }
            workspaces = updated
            focusedWorkspaceId = id
        }
        else if (event.WindowOpenedOrClosed || event.WindowFocusTimestampChanged || event.WorkspaceActiveWindowChanged) {
            // These might indicate structural changes that need a full refresh if WindowsChanged wasn't emitted.
            // Niri usually emits WindowsChanged anyway, but just in case, we can trigger a soft refresh.
            // To avoid spamming, we debounce it.
            refreshDebounce.restart()
        }
    }

    property Timer refreshDebounce: Timer {
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            workspaceQuery.running = true
            windowQuery.running = true
        }
    }

    function updateWorkspaceFocus() {
        let activeOutput = ""
        let activeId = -1
        for (let w of workspaces) {
            if (w.is_focused) {
                activeOutput = w.output
                activeId = w.id
                break
            }
        }
        focusedOutput = activeOutput
        focusedWorkspaceId = activeId
    }

    function updateWindowFocus() {
        let activeWin = null
        for (let w of windows) {
            if (w.is_focused) {
                activeWin = w
                break
            }
        }
        focusedWindow = activeWin
    }
}
