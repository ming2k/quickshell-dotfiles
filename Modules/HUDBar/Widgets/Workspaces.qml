import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: workspaces
    spacing: 0

    property string screenName: ""
    property int activeWorkspace: -1
    property int focusedWorkspace: -1
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
            property bool isFocused: workspaceNum === workspaces.focusedWorkspace

            Layout.preferredWidth: 32
            Layout.preferredHeight: 30
            radius: 0
            color: isFocused ? "#285577" : isActive ? "#1a3a50" : "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: parent.isFocused ? "#4c7899" : parent.isActive ? "#3a6080" : "transparent"
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                text: workspaceNum
                color: isFocused ? "#ebdbb2" : isActive ? "#a89984" : "#928374"
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
        command: ["sh", "-c", "niri msg -j workspaces"]

        stdout: SplitParser {
            onRead: data => {
                let output = data.trim()
                try {
                    let allWs = JSON.parse(output)
                    let mine = allWs.filter(ws => ws.output === workspaces.screenName)
                    let indices = mine.map(ws => ws.idx).sort((a, b) => a - b)

                    let active = mine.find(ws => ws.is_active)
                    let focused = mine.find(ws => ws.is_focused)

                    workspaces.activeWorkspaces = indices
                    workspaces.activeWorkspace = active ? active.idx : -1
                    workspaces.focusedWorkspace = focused ? focused.idx : -1
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
