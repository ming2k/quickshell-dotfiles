import QtQuick
import QtQuick.Layouts
import "../../../Common"
import "../../../Services"

Rectangle {
    id: root

    color: Colors.bg1
    radius: 18
    border.width: 1
    border.color: Colors.bg2
    implicitHeight: contentColumn.implicitHeight + 28

    function resolvePlayerIcon() {
        if (!MprisService.hasPlayers)
            return "audio-headphones"
        if (MprisService.desktopEntry)
            return MprisService.desktopEntry

        return MprisService.playerName.split(".")[0] || ""
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 88
                Layout.preferredHeight: 88
                radius: 14
                color: Colors.bg2
                clip: true

                Image {
                    id: artImage
                    anchors.fill: parent
                    source: MprisService.artUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                    asynchronous: true
                    smooth: true
                }

                Icon {
                    anchors.centerIn: parent
                    visible: !artImage.visible
                    name: root.resolvePlayerIcon()
                    fallbackText: MprisService.identity || MprisService.playerName || "Media"
                    size: 26
                    iconColor: Colors.fg2
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: MprisService.identity || "Media"
                        color: Colors.aqua
                        font.pixelSize: 12
                        font.family: "Cantarell"
                        font.weight: Font.Medium
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MprisService.playbackStatus
                        color: MprisService.playbackStatus === "Playing"
                            ? Colors.green
                            : Colors.fg3
                        font.pixelSize: 12
                        font.family: "Cantarell"
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: MprisService.displayTitle
                    color: Colors.fg1
                    font.pixelSize: 16
                    font.family: "Cantarell"
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: MprisService.displaySubtitle
                    color: Colors.fg3
                    font.pixelSize: 13
                    font.family: "Cantarell"
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.topMargin: 6
                    spacing: 8

                    Repeater {
                        model: [
                            {
                                iconName: "media-skip-backward",
                                enabled: MprisService.hasPlayers && MprisService.canGoPrevious,
                                action: () => MprisService.previous()
                            },
                            {
                                iconName: MprisService.playbackStatus === "Playing"
                                    ? "media-playback-pause"
                                    : "media-playback-start",
                                enabled: MprisService.hasPlayers && MprisService.canTogglePlayback,
                                action: () => MprisService.togglePlayback()
                            },
                            {
                                iconName: "media-skip-forward",
                                enabled: MprisService.hasPlayers && MprisService.canGoNext,
                                action: () => MprisService.next()
                            },
                            {
                                iconName: "go-up",
                                enabled: MprisService.hasPlayers && MprisService.canRaise,
                                action: () => MprisService.raise()
                            }
                        ]

                        delegate: Rectangle {
                            required property var modelData

                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 10
                            color: modelData.enabled ? (controlArea.containsMouse ? Colors.bg3 : Colors.bg2) : Colors.bg0
                            opacity: modelData.enabled ? 1 : 0.45

                            Icon {
                                anchors.centerIn: parent
                                name: modelData.iconName
                                fallback: "media-playback-start"
                                size: 16
                                iconColor: Colors.fg1
                            }

                            MouseArea {
                                id: controlArea
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: parent.modelData.enabled
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: parent.modelData.action()
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            visible: MprisService.playerCount > 1
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Players"
                color: Colors.fg3
                font.pixelSize: 11
                font.family: "Cantarell"
            }

            Repeater {
                model: MprisService.players

                delegate: Rectangle {
                    required property var modelData

                    radius: 10
                    color: MprisService.activePlayerName === modelData.dbusName ? Colors.blue_dim : Colors.bg2
                    implicitWidth: playerLabel.implicitWidth + 18
                    implicitHeight: 28

                    Text {
                        id: playerLabel
                        anchors.centerIn: parent
                        text: modelData.identity || modelData.desktopEntry || modelData.dbusName
                        color: Colors.fg1
                        font.pixelSize: 11
                        font.family: "Cantarell"
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.selectPlayer(modelData)
                    }
                }
            }
        }
    }
}
