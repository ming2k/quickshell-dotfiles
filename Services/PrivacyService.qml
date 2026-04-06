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
            cam=$(fuser /dev/video* 2>/dev/null | grep -q . && echo 1 || echo 0)
            pwout=$(pw-dump 2>/dev/null)
            mic_count=$(echo "$pwout" | jq '[.[] | select(.info.props."media.class" == "Stream/Input/Audio")] | length' 2>/dev/null || echo 0)
            screen_count=$(echo "$pwout" | jq '[.[] | select(.info.props."media.class" == "Video/Source" and (.info.props."media.role" // "") != "Camera")] | length' 2>/dev/null || echo 0)
            [ "$mic_count" -gt 0 ] && mic=1 || mic=0
            [ "$screen_count" -gt 0 ] && screen=1 || screen=0
            printf '%s|%s|%s\n' "$cam" "$mic" "$screen"
        `]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")
                if (parts.length < 3) return
                privacyService.cameraActive = parts[0] === "1"
                privacyService.microphoneActive = parts[1] === "1"
                privacyService.screencastActive = parts[2] === "1"
            }
        }
    }

    property var checkTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: privacyService.refresh()
    }
}
