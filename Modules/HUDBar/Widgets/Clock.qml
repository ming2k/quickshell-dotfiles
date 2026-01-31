import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Match waybar style - simple clock with seconds, bold
Rectangle {
    id: clock
    width: timeText.implicitWidth + 20
    height: 30
    color: "transparent"

    property var currentDate: new Date()
    property var tooltipWindow: null
    property bool isHovering: false

    // Timer to show seconds and tooltip after hovering
    Timer {
        id: hoverDelayTimer
        interval: 400  // 0.4 second delay
        running: false
        repeat: false
        onTriggered: {
            clock.isHovering = true
            // Update to show seconds
            timeText.updateTime()
            // Start live second updates
            liveUpdateTimer.running = true
            // Create tooltip window
            const component = Qt.createComponent("ClockTooltip.qml")
            if (component.status === Component.Ready) {
                tooltipWindow = component.createObject(null, {
                    currentDate: new Date(),
                    clockX: clock.mapToGlobal(0, 0).x,
                    clockY: clock.mapToGlobal(0, 0).y,
                    clockWidth: clock.width,
                    screen: Quickshell.screens[0]
                })
            } else {
                console.error("Failed to create clock tooltip:", component.errorString())
            }
        }
    }

    // Timer for live second updates in main clock (only runs when hovering)
    Timer {
        id: liveUpdateTimer
        interval: 1000  // Update every second
        running: false
        repeat: true
        onTriggered: {
            timeText.updateTime()
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            // Start the delay timer (both seconds and tooltip appear after delay)
            hoverDelayTimer.restart()
        }
        onExited: {
            clock.isHovering = false
            // Stop all timers
            hoverDelayTimer.stop()
            liveUpdateTimer.stop()
            // Restore normal time format
            timeText.updateTime()
            // Destroy tooltip window when hover ends
            if (tooltipWindow) {
                tooltipWindow.destroy()
                tooltipWindow = null
            }
        }
        z: 2
    }

    Text {
        id: timeText
        anchors.centerIn: parent
        color: "#ebdbb2"  // Gruvbox fg1
        font.pixelSize: 15
        font.family: "Cantarell"
        font.weight: Font.Bold
        z: 1

        function updateTime() {
            currentDate = new Date()
            text = clock.isHovering
                ? Qt.formatDateTime(currentDate, "HH:mm:ss")
                : Qt.formatDateTime(currentDate, "HH:mm")
        }

        Component.onCompleted: updateTime()

        Timer {
            interval: 60000  // Update every 60 seconds (power saving)
            running: true
            repeat: true
            onTriggered: timeText.updateTime()
        }
    }

}
