import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    property string name: ""
    property string fallback: ""
    property int size: 16
    property color iconColor: "white"  // placeholder - Image doesn't support colorization

    width: size
    height: size
    implicitWidth: size
    implicitHeight: size

    property string resolvedName: {
        switch (root.name) {
        case "yazi":
            return "utilities-terminal"
        default:
            return root.name
        }
    }

    Image {
        id: img

        anchors.fill: parent
        sourceSize.width: root.size
        sourceSize.height: root.size
        asynchronous: true
        mipmap: true
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: status === Image.Ready || status === Image.Loading

        property int _tryIndex: 0

        property var _candidatePaths: {
            if (!root.resolvedName) return []

            if (root.resolvedName.startsWith("image:") || root.resolvedName.startsWith("file:") || root.resolvedName.startsWith("qrc:"))
                return [root.resolvedName]

            if (root.resolvedName.startsWith("/"))
                return ["file://" + root.resolvedName]

            const homeDir = Quickshell.env("HOME") || "/home/ming"
            let paths = []

            const themePath = Quickshell.iconPath(root.resolvedName)
            if (themePath) paths.push(themePath)

            if (root.resolvedName.indexOf(".") !== -1) {
                const flatpakDirs = [
                    homeDir + "/.local/share/flatpak/exports/share/icons/hicolor",
                    "/var/lib/flatpak/exports/share/icons/hicolor"
                ]
                const sizes = ["scalable/apps/" + root.resolvedName + ".svg", "128x128/apps/" + root.resolvedName + ".png", "64x64/apps/" + root.resolvedName + ".png"]
                for (const dir of flatpakDirs)
                    for (const s of sizes)
                        paths.push("file://" + dir + "/" + s)
            }

            paths.push(
                "file://" + homeDir + "/.local/share/icons/hicolor/scalable/apps/" + root.resolvedName + ".svg",
                "file:///usr/share/pixmaps/" + root.resolvedName + ".png",
                "file:///usr/share/pixmaps/" + root.resolvedName + ".svg",
                "file:///usr/share/icons/hicolor/scalable/apps/" + root.resolvedName + ".svg"
            )

            if (root.fallback) {
                const fallbackPath = Quickshell.iconPath(root.fallback)
                if (fallbackPath) paths.push(fallbackPath)
            }

            const defaultPath = Quickshell.iconPath("application-x-executable")
            if (defaultPath) paths.push(defaultPath)

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
        visible: img.status === Image.Error && img._tryIndex >= img._candidatePaths.length - 1
        radius: root.size * 0.2
        color: {
            if (!root.name) return "#555"
            const h = (root.name.charCodeAt(0) * 37 + root.name.charCodeAt(1) * 17) % 360
            return Qt.hsla(h / 360, 0.5, 0.38, 1)
        }

        Text {
            anchors.centerIn: parent
            text: root.name ? root.name.charAt(0).toUpperCase() : "?"
            color: "white"
            font.pixelSize: root.size * 0.5
            font.bold: true
        }
    }
}
