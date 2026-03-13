import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Common"
import "../../Services"
import "Widgets"

WlrLayershell {
    id: shade

    required property string screenName
    readonly property int barHeight: 32

    visible: NotificationCenterService.centerVisible
        && NotificationCenterService.activeScreenName === screenName

    layer: WlrLayershell.Overlay
    namespace: "quickshell:hud-shade:" + screenName
    exclusiveZone: -1
    keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    margins {
        top: barHeight
        left: 0
        right: 0
        bottom: 0
    }

    color: "transparent"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: mouse => {
            const insideCard = mouse.x >= shadeCard.x
                && mouse.x <= shadeCard.x + shadeCard.width
                && mouse.y >= shadeCard.y
                && mouse.y <= shadeCard.y + shadeCard.height

            if (!insideCard)
                NotificationCenterService.closeCenter()
        }
    }

    Rectangle {
        id: shadeCard
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 8
        width: Math.min(460, shade.width - 16)
        height: shadeLayout.implicitHeight + 28
        z: 1
        clip: true
        radius: 22
        color: Colors.overlayDark
        border.width: 1
        border.color: Colors.bg2

        ColumnLayout {
            id: shadeLayout
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Control Center"
                        color: Colors.fg1
                        font.pixelSize: 16
                        font.family: "Cantarell"
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: NotificationCenterService.unreadCount > 0
                            ? `${NotificationCenterService.unreadCount} unread`
                            : "All caught up"
                        color: Colors.fg3
                        font.pixelSize: 11
                        font.family: "Cantarell"
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 10
                    color: closeMouse.containsMouse ? Colors.bg3 : Colors.bg1

                    Text {
                        anchors.centerIn: parent
                        text: "x"
                        color: Colors.fg1
                        font.pixelSize: 12
                        font.family: "Cantarell"
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationCenterService.closeCenter()
                    }
                }
            }

            MprisCard {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 16
                color: Colors.bg1
                border.width: 1
                border.color: Colors.bg2
                implicitHeight: quickControls.implicitHeight + 24

                ColumnLayout {
                    id: quickControls
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "Quick Controls"
                        color: Colors.fg1
                        font.pixelSize: 13
                        font.family: "Cantarell"
                        font.weight: Font.DemiBold
                    }

                    Inhibit {
                        compact: false
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: Colors.bg0
                        implicitHeight: statsColumn.implicitHeight + 16

                        ColumnLayout {
                            id: statsColumn
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            Text {
                                text: `${NotificationCenterService.items.length} stored in history`
                                color: Colors.fg1
                                font.pixelSize: 12
                                font.family: "Cantarell"
                            }

                            Text {
                                text: "Notifications stay here after popups disappear."
                                color: Colors.fg3
                                font.pixelSize: 11
                                font.family: "Cantarell"
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notifications"
                    color: Colors.fg1
                    font.pixelSize: 14
                    font.family: "Cantarell"
                    font.weight: Font.DemiBold
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: NotificationCenterService.items.length > 0
                    implicitWidth: clearText.implicitWidth + 18
                    implicitHeight: 30
                    radius: 10
                    color: clearMouse.containsMouse ? Colors.bg3 : Colors.bg1

                    Text {
                        id: clearText
                        anchors.centerIn: parent
                        text: "Clear"
                        color: Colors.fg1
                        font.pixelSize: 12
                        font.family: "Cantarell"
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationCenterService.clearHistory()
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: NotificationCenterService.items.length > 0
                    ? Math.min(420, Math.max(120, notificationList.contentHeight))
                    : 120

                ListView {
                    id: notificationList
                    anchors.fill: parent
                    clip: true
                    spacing: 8
                    model: NotificationCenterService.items
                    visible: model.length > 0

                    delegate: Rectangle {
                        id: notificationCard
                        required property var modelData

                        width: notificationList.width
                        height: notificationBody.implicitHeight + 18
                        radius: 16
                        color: modelData.isRead ? Colors.bg1 : Colors.bg0
                        border.width: 1
                        border.color: modelData.isRead ? Colors.bg2 : Colors.blue_dim

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                Layout.alignment: Qt.AlignTop
                                radius: 10
                                color: Colors.bg2
                                clip: true

                                Image {
                                    id: notificationImage
                                    property string resolvedSource: {
                                        if (!modelData.image)
                                            return ""
                                        if (modelData.image.startsWith("/"))
                                            return "file://" + modelData.image
                                        return modelData.image
                                    }

                                    anchors.fill: parent
                                    source: resolvedSource
                                    fillMode: Image.PreserveAspectCrop
                                    visible: status === Image.Ready && resolvedSource !== ""
                                    asynchronous: true
                                }

                                Icon {
                                    anchors.centerIn: parent
                                    visible: !notificationImage.visible
                                    name: modelData.appIcon || "dialog-information"
                                    fallback: "dialog-information"
                                    size: 18
                                    iconColor: modelData.urgency >= 2 ? Colors.red : Colors.accent
                                }
                            }

                            ColumnLayout {
                                id: notificationBody
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: modelData.summary
                                        textFormat: Text.PlainText
                                        color: Colors.fg1
                                        font.pixelSize: 13
                                        font.family: "Cantarell"
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: Qt.formatDateTime(new Date(modelData.timestamp), "HH:mm")
                                        color: Colors.fg3
                                        font.pixelSize: 10
                                        font.family: "Cantarell"
                                    }
                                }

                                Text {
                                    visible: !!modelData.appName
                                    text: modelData.appName
                                    color: Colors.aqua
                                    font.pixelSize: 10
                                    font.family: "Cantarell"
                                }

                                Text {
                                    visible: !!modelData.body
                                    text: modelData.body
                                    textFormat: Text.RichText
                                    color: Colors.fg2
                                    font.pixelSize: 12
                                    font.family: "Cantarell"
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 4
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    visible: modelData.actions && modelData.actions.length > 0
                                    spacing: 6

                                    Repeater {
                                        model: modelData.actions || []

                                        delegate: Rectangle {
                                            required property var modelData

                                            radius: 9
                                            color: actionMouse.containsMouse ? Colors.bg3 : Colors.bg2
                                            implicitWidth: actionText.implicitWidth + 14
                                            implicitHeight: 28

                                            Text {
                                                id: actionText
                                                anchors.centerIn: parent
                                                text: modelData.text
                                                color: Colors.fg1
                                                font.pixelSize: 11
                                                font.family: "Cantarell"
                                            }

                                            MouseArea {
                                                id: actionMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    modelData.invoke()
                                                    NotificationCenterService.markAsRead(notificationCard.modelData.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                Layout.alignment: Qt.AlignTop
                                radius: 8
                                color: removeMouse.containsMouse ? Colors.bg3 : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "x"
                                    color: Colors.fg3
                                    font.pixelSize: 11
                                    font.family: "Cantarell"
                                }

                                MouseArea {
                                    id: removeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: NotificationCenterService.removeNotification(modelData.id)
                                }
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    visible: NotificationCenterService.items.length === 0
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications yet"
                        color: Colors.fg1
                        font.pixelSize: 15
                        font.family: "Cantarell"
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "New notifications will appear here on the right."
                        color: Colors.fg3
                        font.pixelSize: 11
                        font.family: "Cantarell"
                    }
                }
            }
        }
    }
}
