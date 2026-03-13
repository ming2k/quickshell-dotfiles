import QtQuick
import QtQuick.Layouts
import "../../../Common"
import "../../../Services"

Rectangle {
    id: root

    required property string screenName

    Layout.preferredHeight: 28
    Layout.preferredWidth: bellRow.implicitWidth + 18
    radius: 999
    color: NotificationCenterService.centerVisible && NotificationCenterService.activeScreenName === screenName
        ? Colors.blue_dim
        : (NotificationCenterService.unreadCount > 0 ? Colors.bg1 : "transparent")
    border.width: NotificationCenterService.unreadCount > 0 ? 1 : 0
    border.color: NotificationCenterService.unreadCount > 0 ? Colors.bg3 : "transparent"

    RowLayout {
        id: bellRow
        anchors.centerIn: parent
        spacing: 6

        Icon {
            name: "preferences-system-notifications"
            fallback: "dialog-information"
            size: 16
            iconColor: Colors.fg1
        }

        Text {
            visible: NotificationCenterService.unreadCount > 0
            text: NotificationCenterService.unreadCount > 99 ? "99+" : NotificationCenterService.unreadCount
            color: Colors.fg0
            font.pixelSize: 12
            font.family: "Cantarell"
            font.weight: Font.Bold
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: NotificationCenterService.toggleCenter(root.screenName)
    }
}
