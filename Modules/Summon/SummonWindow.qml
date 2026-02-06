import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Common"
import "../../Services"

WlrLayershell {
    id: summon

    visible: SummonService.visible && !hideDelayTimer.running

    Timer {
        id: hideDelayTimer
        interval: 10
        onTriggered: {}
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.forceActiveFocus()
            searchInput.text = ""
            selectedIndex = 0
        }
    }

    Connections {
        target: SummonService
        function onVisibleChanged() {
            if (!SummonService.visible && visible) {
                // User wants to hide - clear focus first, then delay
                searchInput.focus = false
                hideDelayTimer.start()
            }
        }
    }

    layer: WlrLayershell.Overlay
    namespace: "quickshell:summon"
    exclusiveZone: -1
    keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
    }

    margins {
        top: Math.round((screen.height - 400) / 2)
        left: Math.round((screen.width - 600) / 2)
    }

    implicitWidth: 600
    implicitHeight: 400

    color: "transparent"

    property int selectedIndex: 0

    property var filteredApplications: {
        const _history = SummonHistoryService.history  // force reactivity

        const query = searchInput.text.toLowerCase()

        let apps = DesktopEntries.applications.values

        const seen = new Set()
        apps = apps.filter(app => {
            const key = app.name.toLowerCase()
            if (seen.has(key)) return false
            seen.add(key)
            return true
        })

        if (query !== "") {
            apps = apps.filter(app =>
                app.name.toLowerCase().includes(query) ||
                (app.description && app.description.toLowerCase().includes(query))
            )
        }

        return SummonHistoryService.sortByFrecency(apps)
    }

    function launchApplication(app) {
        searchInput.focus = false
        SummonHistoryService.recordLaunch(SummonHistoryService.getAppId(app))

        Quickshell.execDetached(app.command)
        SummonService.hide()
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.bg0  // Gruvbox dark
        border.width: 2
        border.color: Colors.bg2
        radius: 8
        opacity: 0.98

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                border.width: 2
                border.color: searchInput.activeFocus ? Colors.blue : Colors.bg2
                radius: 4

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: Colors.fg1
                    font.pixelSize: 15
                    font.family: "Cantarell"
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true

                    Text {
                        visible: !searchInput.text && !searchInput.activeFocus
                        text: "Search applications..."
                        color: Colors.gray
                        font: searchInput.font
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onTextChanged: {
                        selectedIndex = 0
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            searchInput.focus = false  // Clear focus to avoid Wayland warnings
                            SummonService.hide()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            if (selectedIndex < filteredApplications.length - 1) {
                                selectedIndex++
                                appList.positionViewAtIndex(selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (selectedIndex > 0) {
                                selectedIndex--
                                appList.positionViewAtIndex(selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (filteredApplications.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApplications.length) {
                                launchApplication(filteredApplications[selectedIndex])
                            }
                            event.accepted = true
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height - 60
                color: "transparent"

                ListView {
                    id: appList
                    anchors.fill: parent
                    clip: true
                    spacing: 2
                    model: filteredApplications

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 42
                        color: {
                            if (index === selectedIndex) return Colors.bg2
                            if (appMouseArea.containsMouse) return Colors.bg1
                            return "transparent"
                        }
                        radius: 4

                        Row {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 10

                            Icon {
                                name: modelData.icon || "application-x-executable"
                                size: 28
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 50

                                Text {
                                    text: modelData.name
                                    color: Colors.fg1
                                    font.pixelSize: 15
                                    font.family: "Cantarell"
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: modelData.description || ""
                                    color: Colors.gray
                                    font.pixelSize: 11
                                    font.family: "Cantarell"
                                    elide: Text.ElideRight
                                    width: parent.width
                                    visible: text.length > 0
                                }
                            }
                        }

                        MouseArea {
                            id: appMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                selectedIndex = index
                                launchApplication(modelData)
                            }
                            onEntered: selectedIndex = index
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                Text {
                    visible: filteredApplications.length === 0
                    anchors.centerIn: parent
                    text: searchInput.text ? "No applications found" : "No applications available"
                    color: Colors.gray
                    font.pixelSize: 14
                    font.family: "Cantarell"
                }
            }
        }
    }

    Component.onCompleted: {
        SummonService.summonWindow = summon
        console.log("Summon initialized with", DesktopEntries.applications.values.length, "applications")
    }
}
