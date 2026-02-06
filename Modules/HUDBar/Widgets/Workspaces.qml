import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: workspaces
    spacing: 0

    property int activeWorkspace: 1
    property var activeWorkspaces: []

    Loader {
        id: switcherLoader
        active: false
        property int workspaceToSwitch: 1

        sourceComponent: Process {
            running: true
            command: ["niri", "msg", "action", "focus-workspace", switcherLoader.workspaceToSwitch.toString()]
            onExited: {
                switcherLoader.active = false
            }
        }
    }

    Repeater {
        model: workspaces.activeWorkspaces

        Rectangle {
            required property var modelData
            property int workspaceNum: modelData
            property bool isActive: workspaceNum === workspaces.activeWorkspace

            Layout.preferredWidth: 32
            Layout.preferredHeight: 30
            radius: 0
            color: isActive ? "#285577" : "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: parent.isActive ? "#4c7899" : "transparent"
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                text: workspaceNum
                color: isActive ? "#ebdbb2" : "#928374"
                font.pixelSize: 15
                font.family: "Cantarell"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    let num = workspaceNum
                    switcherLoader.workspaceToSwitch = num
                    switcherLoader.active = true
                }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }

    Process {
        id: workspaceQuery
        running: true
        command: ["sh", "-c", "niri msg -j workspaces | jq -c '{active: (.[] | select(.is_focused == true) | .idx), all: [.[] | .idx] | sort}'"]

        stdout: SplitParser {
            onRead: data => {
                let output = data.trim()
                try {
                    let result = JSON.parse(output)
                    if (result.active !== undefined) {
                        workspaces.activeWorkspace = result.active
                    }
                    if (result.all && Array.isArray(result.all)) {
                        workspaces.activeWorkspaces = result.all
                    }
                } catch (e) {
                    console.log("Failed to parse workspace data:", e)
                }
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: workspaceQuery.running = true
    }

}
