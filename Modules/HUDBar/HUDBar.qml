import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Common"
import "Widgets"

Rectangle {
    id: hudBar
    color: Colors.barBackground

    property var window
    property string screenName: ""

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left: Workspaces & Window Title
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0

            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8
                spacing: 0

                Workspaces {
                    Layout.alignment: Qt.AlignVCenter
                    screenName: hudBar.screenName
                }

                WindowTitle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 12
                }
            }
        }

        // Center: Clock
        Clock {
            Layout.alignment: Qt.AlignCenter
            barWindow: hudBar.window
        }

        // Right: System status
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 8
                spacing: 8

                SystemTray {
                    Layout.alignment: Qt.AlignVCenter
                    parentWindow: hudBar.window
                }

                Privacy {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 12
                }

                Audio {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 12
                }

                Network {
                    Layout.alignment: Qt.AlignVCenter
                }

                Battery {
                    Layout.alignment: Qt.AlignVCenter
                }

                Inhibit {
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
