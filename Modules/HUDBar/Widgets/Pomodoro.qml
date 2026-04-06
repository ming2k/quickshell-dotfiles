import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Common"
import "../../../Services"

Item {
    id: pomodoroWidget

    visible: PomodoroService.available
    Layout.preferredHeight: 30
    Layout.preferredWidth: visible ? contentLayout.implicitWidth : 0

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: Colors.hudIconSpacing

        Icon {
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            iconColor: PomodoroService.state === "paused" ? Colors.fg4 : Colors.fg1
            name: "timer-symbolic"
            fallback: "appointment-soon-symbolic"
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            color: PomodoroService.state === "paused" ? Colors.fg4 : Colors.fg1
            font.pixelSize: 15
            font.family: "Cantarell"
            text: `${PomodoroService.timeText} ${PomodoroService.sessionLabel}`
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                PomodoroService.toggleStartPause()
            } else if (mouse.button === Qt.RightButton) {
                PomodoroService.skip()
            } else if (mouse.button === Qt.MiddleButton) {
                PomodoroService.stop()
            }
        }
    }
}
