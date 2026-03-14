pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property var items: []
    property var popupIds: []
    property bool centerVisible: false
    property string activeScreenName: ""
    property int nextNotificationId: 1
    property int nextPopupId: 1

    readonly property int historyLimit: 100
    readonly property int unreadCount: {
        let unread = 0
        for (const item of items) {
            if (!item.isRead)
                unread++
        }
        return unread
    }

    readonly property string historyFile: {
        const dataHome = Quickshell.env("XDG_DATA_HOME") || (Quickshell.env("HOME") + "/.local/share")
        return dataHome + "/quickshell/notification-history.json"
    }

    property Process loadProcess: Process {
        id: loadProc
        running: false
        command: ["sh", "-c", `cat "${service.historyFile}" 2>/dev/null; printf '\\004'`]

        stdout: SplitParser {
            splitMarker: "\x04"
            onRead: data => {
                if (!data.trim()) {
                    service.items = []
                    return
                }

                try {
                    const loaded = JSON.parse(data)
                    const normalized = Array.isArray(loaded) ? loaded.map(entry => service.deserializeEntry(entry)) : []
                    service.items = normalized.slice(0, service.historyLimit)

                    let maxId = 0
                    for (const item of service.items)
                        maxId = Math.max(maxId, item.id || 0)
                    service.nextNotificationId = maxId + 1
                } catch (error) {
                    console.log("Failed to load notification history:", error)
                    service.items = []
                    service.nextNotificationId = 1
                }
            }
        }
    }

    function notificationImage(notification) {
        if (notification.image)
            return notification.image

        const appIcon = notification.appIcon || ""
        if (appIcon.startsWith("file://") || appIcon.startsWith("/"))
            return appIcon

        return ""
    }

    function serializeEntry(entry) {
        return {
            id: entry.id,
            appName: entry.appName,
            summary: entry.summary,
            body: entry.body,
            appIcon: entry.appIcon,
            image: entry.image,
            urgency: entry.urgency,
            timestamp: entry.timestamp,
            isRead: entry.isRead,
            desktopEntry: entry.desktopEntry
        }
    }

    function deserializeEntry(entry) {
        return {
            id: entry.id || 0,
            appName: entry.appName || "",
            summary: entry.summary || "Notification",
            body: entry.body || "",
            appIcon: entry.appIcon || "",
            image: entry.image || "",
            urgency: entry.urgency || 0,
            timestamp: entry.timestamp || Date.now(),
            isRead: entry.isRead !== false,
            desktopEntry: entry.desktopEntry || "",
            isClosed: true,
            isTransient: false,
            notification: null,
            actions: []
        }
    }

    function allocatePopupId() {
        return nextPopupId++
    }

    function saveHistory() {
        const serialized = items
            .filter(entry => !entry.isTransient)
            .map(entry => serializeEntry(entry))
        const json = JSON.stringify(serialized, null, 2)
        const cmd = `mkdir -p "$(dirname "${historyFile}")" && cat > "${historyFile}" <<'HISTEOF'\n${json}\nHISTEOF\n`
        Quickshell.execDetached(["sh", "-c", cmd])
    }

    function addNotification(notification) {
        if (notification.transient)
            return -1

        const entry = {
            id: nextNotificationId++,
            appName: notification.appName || "",
            summary: notification.summary || "Notification",
            body: notification.body || "",
            appIcon: notification.appIcon || "",
            image: notificationImage(notification),
            urgency: notification.urgency || 0,
            timestamp: Date.now(),
            isRead: centerVisible,
            desktopEntry: notification.desktopEntry || "",
            isClosed: false,
            isTransient: !!notification.transient,
            notification: notification,
            actions: notification.actions ? notification.actions.slice() : []
        }

        items = [entry].concat(items).slice(0, historyLimit)
        saveHistory()
        return entry.id
    }

    function updateEntry(id, transform) {
        let changed = false
        const updated = items.map(entry => {
            if (entry.id !== id)
                return entry

            changed = true
            const patch = transform(entry) || {}
            return Object.assign({}, entry, patch)
        })

        if (changed) {
            items = updated
            saveHistory()
        }
    }

    function markAsRead(id) {
        updateEntry(id, entry => entry.isRead ? null : { isRead: true })
    }

    function markAllRead() {
        let changed = false
        const updated = items.map(entry => {
            if (entry.isRead)
                return entry
            changed = true
            return Object.assign({}, entry, { isRead: true })
        })

        if (changed) {
            items = updated
            saveHistory()
        }
    }

    function removeNotification(id) {
        const entry = items.find(candidate => candidate.id === id)
        if (entry && entry.notification && !entry.isClosed)
            entry.notification.dismiss()

        const filtered = items.filter(candidate => candidate.id !== id)
        if (filtered.length !== items.length) {
            items = filtered
            saveHistory()
        }
    }

    function clearHistory() {
        if (items.length === 0)
            return

        for (const entry of items) {
            if (entry.notification && !entry.isClosed)
                entry.notification.dismiss()
        }

        items = []
        saveHistory()
    }

    function hidePopupNotification(id) {
        if (id < 0)
            return

        updateEntry(id, () => ({ isRead: true }))
    }

    function closeNotification(id) {
        if (id < 0)
            return

        updateEntry(id, () => ({
            isClosed: true,
            isRead: true,
            notification: null,
            actions: []
        }))
    }

    function launchApp(desktopEntry) {
        if (!desktopEntry)
            return
        // Try exact name first, then search for matching .desktop file
        // Handles cases like desktopEntry="firefox" → "org.mozilla.firefox.desktop"
        const script = `
            entry="${desktopEntry}"
            if gtk-launch "$entry" 2>/dev/null; then exit 0; fi
            for dir in /usr/share/applications /usr/local/share/applications \
                       "$HOME/.local/share/applications" \
                       /var/lib/flatpak/exports/share/applications \
                       "$HOME/.local/share/flatpak/exports/share/applications"; do
                match=$(find "$dir" -maxdepth 1 -iname "*$entry*.desktop" 2>/dev/null | head -1)
                if [ -n "$match" ]; then
                    gtk-launch "$(basename "$match" .desktop)" 2>/dev/null && exit 0
                fi
            done
        `
        Quickshell.execDetached(["sh", "-c", script])
    }

    function notificationEntry(id) {
        return items.find(entry => entry.id === id) || null
    }

    function registerPopup(id) {
        if (popupIds.indexOf(id) !== -1)
            return

        popupIds = popupIds.concat(id)
    }

    function unregisterPopup(id) {
        popupIds = popupIds.filter(popupId => popupId !== id)
    }

    function popupIndexFor(id) {
        return popupIds.indexOf(id)
    }

    function openCenter(screenName) {
        activeScreenName = screenName
        centerVisible = true
        markAllRead()
    }

    function closeCenter() {
        centerVisible = false
    }

    function toggleCenter(screenName) {
        if (centerVisible && activeScreenName === screenName) {
            closeCenter()
        } else {
            openCenter(screenName)
        }
    }

    Component.onCompleted: {
        loadProcess.running = true
    }
}
