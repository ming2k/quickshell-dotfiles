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
        spacing: Colors.hudIconSpacing

        // Camera indicator
        Icon {
            visible: PrivacyService.cameraActive
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            name: "file://" + Quickshell.env("HOME") + "/.config/quickshell/Common/Icons/privacy-camera.svg"
            iconColor: Colors.privacyIndicator
        }

        // Microphone indicator
        Icon {
            visible: PrivacyService.microphoneActive
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            name: "file://" + Quickshell.env("HOME") + "/.config/quickshell/Common/Icons/privacy-mic.svg"
            iconColor: Colors.privacyIndicator
        }

        // Screencast indicator
        Icon {
            visible: PrivacyService.screencastActive
            size: Colors.hudIconSize
            Layout.alignment: Qt.AlignVCenter
            name: "file://" + Quickshell.env("HOME") + "/.config/quickshell/Common/Icons/privacy-screen.svg"
            iconColor: Colors.privacyIndicator
        }
    }
}
