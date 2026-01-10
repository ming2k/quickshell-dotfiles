/**
 * Audio Widget
 *
 * Displays current volume level and mute status.
 * Interactive features:
 * - Click to toggle mute
 * - Scroll up to increase volume
 * - Scroll down to decrease volume
 */

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Common"
import "../../../Services"

Item {
    Layout.preferredHeight: 30
    Layout.preferredWidth: audioLayout.implicitWidth

    // Visual content
    RowLayout {
        id: audioLayout
        anchors.fill: parent
        spacing: 6

        Icon {
            id: audioIcon
            size: 16
            Layout.alignment: Qt.AlignVCenter
            iconColor: Colors.fg1
            name: AudioService.iconName
        }

        Text {
            id: audioText
            Layout.alignment: Qt.AlignVCenter
            color: Colors.fg1
            font.pixelSize: 13
            font.family: "Cantarell"
            text: AudioService.isMuted ? "Muted" : `${AudioService.volumeLevel}%`
        }
    }

    // Interactive overlay covering the entire widget
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: AudioService.toggleMute()

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                AudioService.increaseVolume()
            } else if (wheel.angleDelta.y < 0) {
                AudioService.decreaseVolume()
            }
        }
    }
}
