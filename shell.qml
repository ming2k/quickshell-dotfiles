//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Wayland
import "Common"
import "Services"
import "Modules/HUDBar"
import "Modules/Notifications"
import "Modules/Summon"

ShellRoot {
    Component.onCompleted: {
        // Pre-create FIFO immediately so Super+Space works ASAP on boot.
        // The subprocess in SummonService takes time to start; this ensures
        // the FIFO exists before any external writer tries to use it.
        Quickshell.execDetached(["sh", "-c", "rm -f /tmp/quickshell-summon.fifo && mkfifo /tmp/quickshell-summon.fifo"])
    }

    // HUD bar on each screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 32
            color: "transparent"

            HUDBar {
                anchors.fill: parent
                window: panelWindow
                screenName: modelData.name
            }
        }
    }

    NotificationManager {}

    Variants {
        model: Quickshell.screens

        SummonWindow {
            property var modelData
            screen: modelData
            isFocusedScreen: modelData.name === SummonService.focusedOutput
        }
    }
}
