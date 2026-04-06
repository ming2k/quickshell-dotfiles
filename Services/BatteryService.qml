pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: batteryService

    property int percent: 0
    property bool isCharging: false
    property bool hasBattery: false

    property var batteryChecker: Process {
        id: batteryChecker
        running: true
        command: ["sh", "-c", `
            bat=$(ls /sys/class/power_supply/ | grep -i 'BAT' | head -1)
            if [ -z "$bat" ]; then
                echo "NONE"
                exit 0
            fi
            capacity=$(cat /sys/class/power_supply/$bat/capacity 2>/dev/null || echo "0")
            status=$(cat /sys/class/power_supply/$bat/status 2>/dev/null || echo "Unknown")
            echo "$capacity|$status"
        `]

        stdout: SplitParser {
            onRead: data => {
                const output = data.trim()
                if (output === "NONE") {
                    batteryService.hasBattery = false
                    return
                }
                const parts = output.split("|")
                if (parts.length === 2) {
                    batteryService.hasBattery = true
                    batteryService.percent = parseInt(parts[0]) || 0
                    batteryService.isCharging = parts[1].toLowerCase() === "charging"
                }
            }
        }
    }

    property var checkTimer: Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: batteryChecker.running = true
    }
}
