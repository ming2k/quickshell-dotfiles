import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Common"
import "../../../Services"

Rectangle {
    Layout.preferredHeight: 24
    Layout.preferredWidth: 28
    Layout.alignment: Qt.AlignVCenter
    radius: 4
    color: InhibitService.isInhibited ? Colors.aqua : "transparent"

    Text {
        anchors.centerIn: parent
        text: "\u2615"
        font.pixelSize: 16
        font.family: "Noto Sans"
        color: InhibitService.isInhibited ? Colors.bg0 : Colors.fg1
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: InhibitService.toggleInhibit()
    }
}
