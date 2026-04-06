pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: typioService

    readonly property string serviceName: "org.typio.InputMethod1"
    readonly property string objectPath: "/org/typio/InputMethod1"
    readonly property string interfaceName: "org.typio.InputMethod1"

    property bool available: false
    property string activeEngine: ""
    property string displayName: ""
    property string iconName: "input-keyboard-symbolic"
    property string language: ""
    property string rimeSchema: ""
    property string modeClass: ""
    property string modeId: ""
    property string modeLabel: ""
    property string modeIconName: ""
    readonly property string statusText: {
        if (displayName && modeLabel) {
            return `${displayName} ${modeLabel}`
        }

        if (displayName) {
            return displayName
        }

        if (activeEngine) {
            const engineName = formatEngineName(activeEngine)
            return modeLabel ? `${engineName} ${modeLabel}` : engineName
        }

        return "Input"
    }

    function formatEngineName(engineName) {
        if (!engineName) {
            return ""
        }

        return engineName
            .split(/[-_]/)
            .filter(part => part.length > 0)
            .map(part => part.charAt(0).toUpperCase() + part.slice(1))
            .join(" ")
    }

    function refresh() {
        if (!statusChecker.running) {
            statusChecker.running = true
        }
    }

    function nextEngine() {
        if (!available || nextEngineLoader.active) {
            return
        }

        nextEngineLoader.active = true
    }

    function applyUnavailableState() {
        available = false
        activeEngine = ""
        displayName = ""
        iconName = "input-keyboard-symbolic"
        language = ""
        rimeSchema = ""
        modeClass = ""
        modeId = ""
        modeLabel = ""
        modeIconName = ""
    }

    property var statusChecker: Process {
        id: statusChecker
        running: true
        command: ["sh", "-c", `
            output=$(gdbus call --session \
                --dest org.typio.InputMethod1 \
                --object-path /org/typio/InputMethod1 \
                --method org.freedesktop.DBus.Properties.GetAll \
                org.typio.InputMethod1 2>/dev/null) || {
                echo "0|||||||||"
                exit 0
            }

            engine=$(printf '%s\n' "$output" | sed -n "s/.*'ActiveKeyboardEngine': <'\\([^']*\\)'.*/\\1/p")
            display=$(printf '%s\n' "$output" | sed -n "s/.*'display_name': <'\\([^']*\\)'.*/\\1/p")
            icon=$(printf '%s\n' "$output" | sed -n "s/.*'icon': <'\\([^']*\\)'.*/\\1/p")
            language=$(printf '%s\n' "$output" | sed -n "s/.*'language': <'\\([^']*\\)'.*/\\1/p")
            schema=$(printf '%s\n' "$output" | sed -n "s/.*'RimeSchema': <'\\([^']*\\)'.*/\\1/p")
            modeClass=$(printf '%s\n' "$output" | sed -n "s/.*'mode_class': <'\\([^']*\\)'.*/\\1/p")
            modeId=$(printf '%s\n' "$output" | sed -n "s/.*'mode_id': <'\\([^']*\\)'.*/\\1/p")
            modeLabel=$(printf '%s\n' "$output" | sed -n "s/.*'display_label': <'\\([^']*\\)'.*/\\1/p")
            modeIcon=$(printf '%s\n' "$output" | sed -n "s/.*'icon_name': <'\\([^']*\\)'.*/\\1/p")

            printf '1|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$engine" "$display" "$icon" "$language" "$schema" "$modeClass" "$modeId" "$modeLabel" "$modeIcon"
        `]

        stdout: SplitParser {
            onRead: data => {
                const output = data.trim()
                const parts = output.split("|")

                if (parts.length < 10) {
                    typioService.applyUnavailableState()
                    return
                }

                if (parts[0] !== "1") {
                    typioService.applyUnavailableState()
                    return
                }

                typioService.available = true
                typioService.activeEngine = parts[1] || ""
                typioService.displayName = parts[2] || typioService.formatEngineName(typioService.activeEngine)
                typioService.iconName = parts[3] || "input-keyboard-symbolic"
                typioService.language = parts[4] || ""
                typioService.rimeSchema = parts[5] || ""
                typioService.modeClass = parts[6] || ""
                typioService.modeId = parts[7] || ""
                typioService.modeLabel = parts[8] || ""
                typioService.modeIconName = parts[9] || ""
            }
        }
    }

    property var refreshTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: typioService.refresh()
    }

    property var propertyMonitor: Process {
        running: true
        command: [
            "gdbus", "monitor", "--session",
            "--dest", typioService.serviceName,
            "--object-path", typioService.objectPath
        ]

        stdout: SplitParser {
            onRead: data => {
                const output = data.trim()

                if (!output) {
                    return
                }

                if (output.includes("PropertiesChanged")
                    || output.includes("ActiveEngine")
                    || output.includes("RimeSchema")) {
                    typioService.refresh()
                }
            }
        }

        onExited: {
            typioService.refresh()
            monitorRestartTimer.restart()
        }
    }

    property var monitorRestartTimer: Timer {
        interval: 1000
        running: false
        repeat: false
        onTriggered: propertyMonitor.running = true
    }

    property var nextEngineLoader: Loader {
        id: nextEngineLoader
        active: false

        sourceComponent: Process {
            running: true
            command: [
                "gdbus", "call", "--session",
                "--dest", typioService.serviceName,
                "--object-path", typioService.objectPath,
                "--method", typioService.interfaceName + ".NextEngine"
            ]

            onExited: {
                nextEngineLoader.active = false
                typioService.refresh()
            }
        }
    }
}
