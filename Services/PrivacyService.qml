pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: privacyService

    property bool cameraActive: false
    property bool microphoneActive: false
    property bool screencastActive: false
    property bool anyActive: cameraActive || microphoneActive || screencastActive

    function refresh() {
        if (!privacyChecker.running) {
            privacyChecker.running = true
        }
    }

    property var privacyChecker: Process {
        id: privacyChecker
        running: true
        command: ["sh", "-c", `
            status=$(wpctl status 2>/dev/null || echo "")
            mic=$(echo "$status" | awk '/Audio/,/Video/' | grep -c 'capture_')
            screen=$(echo "$status" | awk '/Video/,/Settings/' | grep -c -E '<.*xdg-desktop-portal')
            cam=$(fuser /dev/video* 2>/dev/null | grep -q . && echo 1 || echo 0)
            printf '%s|%s|%s\n' "$cam" "$mic" "$screen"
        `]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")
                if (parts.length < 3) return
                privacyService.cameraActive = parts[0] === "1"
                privacyService.microphoneActive = parseInt(parts[1]) > 0
                privacyService.screencastActive = parseInt(parts[2]) > 0
            }
        }
    }

    property var checkTimer: Timer {
        interval: 5000  // Reduced to 5s for better responsiveness since check is now extremely cheap
        running: true
        repeat: true
        onTriggered: privacyService.refresh()
    }
}
