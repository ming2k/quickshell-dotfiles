import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../Services"

RowLayout {
    id: workspaces
    spacing: 0

    property string screenName: ""

    // Bind state directly to NiriService to avoid polling
    property var activeWorkspaces: {
        let mine = NiriService.workspaces.filter(ws => ws.output === workspaces.screenName)
        return mine.map(ws => ws.idx).sort((a, b) => a - b)
    }

    property int activeWorkspace: {
        let mine = NiriService.workspaces.filter(ws => ws.output === workspaces.screenName)
        let active = mine.find(ws => ws.is_active)
        return active ? active.idx : -1
    }

    property int focusedWorkspace: {
        let mine = NiriService.workspaces.filter(ws => ws.output === workspaces.screenName)
        let focused = mine.find(ws => ws.is_focused)
        return focused ? focused.idx : -1
    }

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
}
