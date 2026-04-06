import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Common"
import "../../../Services"

Item {
    visible: BatteryService.hasBattery
    Layout.preferredHeight: 30
    Layout.preferredWidth: visible ? batteryLayout.implicitWidth : 0

    RowLayout {
        id: batteryLayout
        anchors.fill: parent
        spacing: Colors.hudIconSpacing

        Icon {
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            iconColor: battText.color

            name: {
                const rounded = Math.min(Math.floor(BatteryService.percent / 10) * 10, 100)
                const percentStr = rounded.toString().padStart(3, '0')
                return BatteryService.isCharging
                    ? `battery-${percentStr}-charging`
                    : `battery-${percentStr}`
            }
        }

        Text {
            id: battText
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            font.family: "Cantarell"
            text: `${BatteryService.percent}%`

            color: {
                if (BatteryService.percent <= 15 && !BatteryService.isCharging) return Colors.red
                if (BatteryService.percent <= 30 && !BatteryService.isCharging) return Colors.orange
                if (BatteryService.isCharging) return Colors.aqua
                return Colors.fg1
            }
        }
    }
}
