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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            // Create tooltip window on hover
            const component = Qt.createComponent("ClockTooltip.qml")
            if (component.status === Component.Ready) {
                tooltipWindow = component.createObject(null, {
                    currentDate: clock.currentDate,
                    clockX: clock.mapToGlobal(0, 0).x,
                    clockY: clock.mapToGlobal(0, 0).y,
                    clockWidth: clock.width,
                    screen: Quickshell.screens[0]
                })
            } else {
                console.error("Failed to create clock tooltip:", component.errorString())
            }
        }
        onExited: {
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
            text = Qt.formatDateTime(currentDate, "HH:mm")
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
