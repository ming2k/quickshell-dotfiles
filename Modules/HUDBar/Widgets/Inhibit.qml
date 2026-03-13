import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Common"
import "../../../Services"

Rectangle {
    id: root

    property bool compact: true

    Layout.preferredHeight: compact ? 24 : 40
    Layout.preferredWidth: compact ? 28 : inhibitLayout.implicitWidth + 20
    Layout.alignment: Qt.AlignVCenter
    radius: compact ? 4 : 12
    color: InhibitService.isInhibited ? Colors.aqua : (compact ? "transparent" : Colors.bg1)
    border.width: compact ? 0 : 1
    border.color: InhibitService.isInhibited ? Colors.aqua_dim : Colors.bg2

    RowLayout {
        id: inhibitLayout
        anchors.centerIn: parent
        spacing: compact ? 0 : 8

        Text {
            text: "\u2615"
            font.pixelSize: 16
            font.family: "Noto Sans"
            color: InhibitService.isInhibited ? Colors.bg0 : Colors.fg1
        }

        Column {
            visible: !compact
            spacing: 0

            Text {
                text: "Idle Inhibit"
                color: Colors.fg1
                font.pixelSize: 13
                font.family: "Cantarell"
                font.weight: Font.Medium
            }

            Text {
                text: InhibitService.isInhibited ? "Enabled" : "Disabled"
                color: InhibitService.isInhibited ? Colors.bg0 : Colors.fg3
                font.pixelSize: 11
                font.family: "Cantarell"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: InhibitService.toggleInhibit()
    }
}
