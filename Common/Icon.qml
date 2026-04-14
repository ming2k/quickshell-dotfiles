import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../Services"

Item {
    id: root

    property string name: ""
    property string fallback: ""
    property string fallbackText: name
    property int size: 16
    property color iconColor: "transparent"

    width: size
    height: size
    implicitWidth: size
    implicitHeight: size

    property string resolvedName: IconService.resolveName(root.name)
    
    // Using alpha channel for robust transparency check
    property bool colorize: root.iconColor.a > 0.001

    Image {
        id: img

        anchors.fill: parent
        sourceSize.width: root.size
        sourceSize.height: root.size
        asynchronous: true
        mipmap: true
        fillMode: Image.PreserveAspectFit
        smooth: true
        
        // Only enable the colorization layer if a non-transparent color is provided
        layer.enabled: root.colorize && (status === Image.Ready || status === Image.Loading)
        layer.effect: ColorOverlay {
            color: root.iconColor
        }

        property int _tryIndex: 0

        property var _candidatePaths: {
            if (!root.resolvedName) return []

            // Direct paths
            if (root.resolvedName.startsWith("image:") || root.resolvedName.startsWith("file:") || root.resolvedName.startsWith("qrc:"))
                return [root.resolvedName]

            if (root.resolvedName.startsWith("/"))
                return ["file://" + root.resolvedName]

            const homeDir = Quickshell.env("HOME") || "/home/ming"
            const xdgDataDirs = (Quickshell.env("XDG_DATA_DIRS") || "/usr/local/share:/usr/share").split(":")
            let paths = []

            // 1. Theme lookup (High Priority)
            const themePath = Quickshell.iconPath(root.resolvedName)
            if (themePath) paths.push(themePath)

            // 2. Manual lookup (Medium Priority - handles stale cache / Flatpaks)
            const searchDirs = [
                ...xdgDataDirs.map(d => d + "/icons/hicolor"),
                homeDir + "/.local/share/icons/hicolor",
                "/var/lib/flatpak/exports/share/icons/hicolor",
                homeDir + "/.local/share/flatpak/exports/share/icons/hicolor"
            ]

            const searchFiles = [
                "scalable/apps/" + root.resolvedName + ".svg",
                "128x128/apps/" + root.resolvedName + ".png",
                "64x64/apps/" + root.resolvedName + ".png",
                "48x48/apps/" + root.resolvedName + ".png",
                "32x32/apps/" + root.resolvedName + ".png",
                "scalable/apps/" + root.resolvedName + ".png"
            ]

            for (const dir of searchDirs) {
                for (const file of searchFiles) {
                    const fullPath = "file://" + dir + "/" + file
                    if (paths.indexOf(fullPath) === -1) {
                        paths.push(fullPath)
                    }
                }
            }

            // 3. System pixmaps (Low Priority)
            paths.push(
                "file:///usr/share/pixmaps/" + root.resolvedName + ".png",
                "file:///usr/share/pixmaps/" + root.resolvedName + ".svg"
            )

            // 4. Fallback chain
            if (root.fallback) {
                const fallbackPath = Quickshell.iconPath(root.fallback)
                if (fallbackPath) paths.push(fallbackPath)
            }

            return paths
        }

        onStatusChanged: {
            if (status === Image.Error && _tryIndex < _candidatePaths.length - 1)
                _tryIndex++
        }

        source: _candidatePaths.length > 0 ? _candidatePaths[_tryIndex] : ""

        Connections {
            target: root
            function onNameChanged() { img._tryIndex = 0 }
            function onResolvedNameChanged() { img._tryIndex = 0 }
        }
    }

    // Monogram fallback: shown when all image candidates are exhausted
    Rectangle {
        anchors.fill: parent
        // Visible if no candidates at all OR if we tried everything and it's not Ready/Loading
        visible: img._candidatePaths.length === 0 || (img.status !== Image.Ready && img.status !== Image.Loading && img._tryIndex >= img._candidatePaths.length - 1)
        radius: root.size * 0.2
        color: {
            const textToHash = root.fallbackText || "Unknown"
            const h = (textToHash.charCodeAt(0) * 37 + (textToHash.length > 1 ? textToHash.charCodeAt(1) * 17 : 0)) % 360
            return Qt.hsla(h / 360, 0.5, 0.38, 1)
        }

        Text {
            anchors.centerIn: parent
            text: {
                if (!root.fallbackText) return "?"
                const match = root.fallbackText.match(/[a-zA-Z0-9\u4e00-\u9fa5]/)
                return match ? match[0].toUpperCase() : root.fallbackText.charAt(0).toUpperCase()
            }
            color: "white"
            font.pixelSize: root.size * 0.6
            font.bold: true
        }
    }
}
