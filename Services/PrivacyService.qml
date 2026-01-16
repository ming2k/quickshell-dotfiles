pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: privacyService

    // Privacy indicator states
    property bool cameraActive: false
    property bool microphoneActive: false
    property bool screencastActive: false

    // Combined state for quick visibility check
    property bool anyActive: cameraActive || microphoneActive || screencastActive

    // Camera detection via /proc - check if any process has /dev/video* open
    property var cameraChecker: Process {
        id: cameraChecker
        running: true
        command: ["sh", "-c", "for f in /proc/*/fd/*; do readlink \"$f\" 2>/dev/null; done | grep -q '/dev/video' && echo 'active' || echo 'inactive'"]

        stdout: SplitParser {
            onRead: data => {
                privacyService.cameraActive = data.trim() === "active"
            }
        }
    }

    // Microphone detection via PipeWire/PulseAudio source outputs
    property var microphoneChecker: Process {
        id: microphoneChecker
        running: true
        command: ["sh", "-c", "pactl list source-outputs 2>/dev/null | grep -q 'Source Output' && echo 'active' || echo 'inactive'"]

        stdout: SplitParser {
            onRead: data => {
                privacyService.microphoneActive = data.trim() === "active"
            }
        }
    }

    // Screencast detection via PipeWire - look for Video/Source that's not a camera
    property var screencastChecker: Process {
        id: screencastChecker
        running: true
        command: ["sh", "-c", "pw-dump 2>/dev/null | jq -r '.[] | select(.info.props.\"media.class\" == \"Video/Source\" and .info.props.\"media.role\" != \"Camera\") | .id' 2>/dev/null | grep -q . && echo 'active' || echo 'inactive'"]

        stdout: SplitParser {
            onRead: data => {
                privacyService.screencastActive = data.trim() === "active"
            }
        }
    }

    // Poll timer - check every 5 seconds (balance between responsiveness and power)
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
        // Initial check
        cameraChecker.running = true
        microphoneChecker.running = true
        screencastChecker.running = true
    }
}
