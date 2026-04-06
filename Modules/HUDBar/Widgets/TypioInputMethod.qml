import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Common"
import "../../../Services"

Item {
    id: typioWidget

    visible: TypioService.available
    Layout.preferredHeight: 30
    Layout.preferredWidth: visible ? contentLayout.implicitWidth : 0

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: Colors.hudIconSpacing

        Icon {
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            iconColor: Colors.fg1
            name: TypioService.modeIconName || TypioService.iconName
            fallback: "input-keyboard-symbolic"
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            color: Colors.fg1
            font.pixelSize: 15
            font.family: "Cantarell"
            text: TypioService.statusText
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: TypioService.nextEngine()
    }
}
