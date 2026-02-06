pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: inhibitService

    property bool isInhibited: false

    function toggleInhibit() {
        if (isInhibited) {
            resumeLoader.active = true
        } else {
            stopLoader.active = true
        }
    }

    // Pause swayidle (SIGSTOP)
    property var stopLoader: Loader {
        id: stopLoader
        active: false

        sourceComponent: Process {
            running: true
            command: ["pkill", "-STOP", "-x", "swayidle"]
            onExited: {
                inhibitService.isInhibited = true
                stopLoader.active = false
            }
        }
    }

    // Resume swayidle (SIGCONT)
    property var resumeLoader: Loader {
        id: resumeLoader
        active: false

        sourceComponent: Process {
            running: true
            command: ["pkill", "-CONT", "-x", "swayidle"]
            onExited: {
                inhibitService.isInhibited = false
                resumeLoader.active = false
            }
        }
    }
}
