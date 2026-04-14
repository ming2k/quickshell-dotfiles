import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../Common"
import "../../../Services"

RowLayout {
    spacing: 8
    visible: NiriService.focusedWindow !== null

    property string windowTitle: NiriService.focusedWindow ? NiriService.focusedWindow.title : ""
    property string appId: NiriService.focusedWindow ? NiriService.focusedWindow.app_id : ""

    Icon {
        name: appId
        fallbackText: windowTitle
        size: 18
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        id: titleText
        Layout.alignment: Qt.AlignVCenter
        Layout.maximumWidth: 300

        text: windowTitle
        color: "#d5c4a1"
        font.pixelSize: 15
        font.family: "Cantarell"
        elide: Text.ElideRight
        maximumLineCount: 1
    }
}
