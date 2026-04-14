import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../Common"

RowLayout {
    spacing: 8

    property string windowTitle: ""
    property string appId: ""

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

    Process {
        id: windowQuery
        running: true
        command: ["sh", "-c", "niri msg -j windows | jq -r '.[] | select(.is_focused == true) | \"\\(.app_id)\\t\\(.title)\"' 2>/dev/null || echo ''"]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("\t")
                if (parts.length >= 2) {
                    appId = parts[0]
                    windowTitle = parts[1]
                } else {
                    appId = ""
                    windowTitle = data.trim()
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: windowQuery.running = true
    }
}
