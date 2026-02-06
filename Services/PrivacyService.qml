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

    property var cameraChecker: Process {
        id: cameraChecker
        running: true
        command: ["sh", "-c", "fuser /dev/video* 2>/dev/null | grep -q . && echo 'active' || echo 'inactive'"]

        stdout: SplitParser {
            onRead: data => { privacyService.cameraActive = data.trim() === "active" }
        }
    }

    property var microphoneChecker: Process {
        id: microphoneChecker
        running: true
        command: ["sh", "-c", "pactl list source-outputs 2>/dev/null | grep -q 'Source Output' && echo 'active' || echo 'inactive'"]

        stdout: SplitParser {
            onRead: data => { privacyService.microphoneActive = data.trim() === "active" }
        }
    }

    property var screencastChecker: Process {
        id: screencastChecker
        running: true
        command: ["sh", "-c", "pw-dump 2>/dev/null | jq -r '.[] | select(.info.props.\"media.class\" == \"Video/Source\" and .info.props.\"media.role\" != \"Camera\") | .id' 2>/dev/null | grep -q . && echo 'active' || echo 'inactive'"]

        stdout: SplitParser {
            onRead: data => { privacyService.screencastActive = data.trim() === "active" }
        }
    }

    property var checkTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            cameraChecker.running = true
            microphoneChecker.running = true
            screencastChecker.running = true
        }
    }

    Component.onCompleted: {
        cameraChecker.running = true
        microphoneChecker.running = true
        screencastChecker.running = true
    }
}
