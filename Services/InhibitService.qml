pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: inhibitService

    property bool isInhibited: false

    readonly property string swayidleCmd: "swayidle -w timeout 570 'brightnessctl -s set 10' resume 'brightnessctl -r' timeout 600 'swaylock -f' timeout 605 'niri msg output eDP-1 off; niri msg output HDMI-A-1 off' resume 'niri msg output eDP-1 on; niri msg output HDMI-A-1 on' timeout 1800 'systemctl suspend' before-sleep 'swaylock -f'"

    function toggleInhibit() {
        if (isInhibited) {
            restartLoader.active = true
        } else {
            killLoader.active = true
        }
    }

    // Kill swayidle to inhibit
    property var killLoader: Loader {
        id: killLoader
        active: false

        sourceComponent: Process {
            running: true
            command: ["pkill", "-x", "swayidle"]
            onExited: {
                inhibitService.isInhibited = true
                killLoader.active = false
            }
        }
    }

    // Restart swayidle to un-inhibit (fresh timers)
    property var restartLoader: Loader {
        id: restartLoader
        active: false

        sourceComponent: Process {
            running: true
            command: ["bash", "-c", "setsid " + inhibitService.swayidleCmd + " &"]
            onExited: {
                inhibitService.isInhibited = false
                restartLoader.active = false
            }
        }
    }
}
