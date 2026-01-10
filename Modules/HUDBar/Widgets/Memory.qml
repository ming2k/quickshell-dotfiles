import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../Common"

RowLayout {
    spacing: Colors.hudIconSpacing

    Icon {
        id: memIcon
        size: Colors.hudIconSize
        Layout.alignment: Qt.AlignVCenter
        iconColor: Colors.fg1
        name: "memory"
        fallback: "dialog-memory"
    }

    Text {
        id: memText
        Layout.alignment: Qt.AlignVCenter
        font.pixelSize: 13
        font.family: "Cantarell"
        color: Colors.fg1

        text: "--"
    }
}
