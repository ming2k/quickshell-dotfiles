/**
 * Privacy Widget
 *
 * Displays privacy indicators when camera, microphone, or screencast are active.
 * Only visible when at least one privacy-sensitive resource is in use.
 */

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Common"
import "../../../Services"

Item {
    id: privacyWidget

    // Only take space when indicators are active
    visible: PrivacyService.anyActive
    Layout.preferredHeight: 30
    Layout.preferredWidth: visible ? privacyLayout.implicitWidth : 0

    RowLayout {
        id: privacyLayout
        anchors.fill: parent
        spacing: 6

        // Camera indicator
        Icon {
            visible: PrivacyService.cameraActive
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            iconColor: Colors.orange
            name: "camera-web-symbolic"
            fallback: "camera-video-symbolic"
        }

        // Microphone indicator
        Icon {
            visible: PrivacyService.microphoneActive
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            iconColor: Colors.orange
            name: "microphone-sensitivity-high-symbolic"
            fallback: "audio-input-microphone-symbolic"
        }

        // Screencast indicator
        Icon {
            visible: PrivacyService.screencastActive
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            iconColor: Colors.orange
            name: "screen-shared-symbolic"
            fallback: "video-display"
        }
    }
}
