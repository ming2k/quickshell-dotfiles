import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Rectangle {
    id: clock
    width: timeText.implicitWidth + 20
    height: 30
    color: "transparent"

    property var currentDate: new Date()
    property var tooltipWindow: null
    property bool isHovering: false
    property var barWindow

    Timer {
        id: hoverDelayTimer
        interval: 400
        running: false
        repeat: false
        onTriggered: {
            clock.isHovering = true
            timeText.updateTime()
            liveUpdateTimer.running = true
            const component = Qt.createComponent("ClockTooltip.qml")
            if (component.status === Component.Ready) {
                const pos = clock.mapToItem(null, 0, 0)
                tooltipWindow = component.createObject(null, {
                    currentDate: new Date(),
                    clockX: pos.x,
                    clockY: pos.y,
                    clockWidth: clock.width,
                    screen: barWindow ? barWindow.screen : Quickshell.screens[0]
                })
            } else {
                console.error("Failed to create clock tooltip:", component.errorString())
            }
        }
    }

    Timer {
        id: liveUpdateTimer
        interval: 1000
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
            hoverDelayTimer.restart()
        }
        onExited: {
            clock.isHovering = false
            hoverDelayTimer.stop()
            liveUpdateTimer.stop()
            timeText.updateTime()
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
        color: "#ebdbb2"
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
            interval: 60000
            running: true
            repeat: true
            onTriggered: timeText.updateTime()
        }
    }

}
