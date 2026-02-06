import QtQuick
import Quickshell
import Quickshell.Widgets

Image {
    id: root

    property string name: ""
    property string fallback: ""
    property int size: 16
    property color iconColor: "white"  // placeholder - Image doesn't support colorization

    width: size
    height: size
    sourceSize.width: size
    sourceSize.height: size
    asynchronous: true
    mipmap: true
    fillMode: Image.PreserveAspectFit
    smooth: true

    property int _tryIndex: 0

    property var _candidatePaths: {
        if (!name) return []

        if (name.startsWith("image:") || name.startsWith("file:") || name.startsWith("qrc:"))
            return [name]

        if (name.startsWith("/"))
            return ["file://" + name]

        const homeDir = Quickshell.env("HOME") || "/home/ming"
        let paths = []

        const themePath = Quickshell.iconPath(name)
        if (themePath) paths.push(themePath)

        if (name.indexOf(".") !== -1) {
            const flatpakDirs = [
                homeDir + "/.local/share/flatpak/exports/share/icons/hicolor",
                "/var/lib/flatpak/exports/share/icons/hicolor"
            ]
            const sizes = ["scalable/apps/" + name + ".svg", "128x128/apps/" + name + ".png", "64x64/apps/" + name + ".png"]
            for (const dir of flatpakDirs)
                for (const s of sizes)
                    paths.push("file://" + dir + "/" + s)
        }

        paths.push(
            "file://" + homeDir + "/.local/share/icons/hicolor/scalable/apps/" + name + ".svg",
            "file:///usr/share/pixmaps/" + name + ".png",
            "file:///usr/share/pixmaps/" + name + ".svg",
            "file:///usr/share/icons/hicolor/scalable/apps/" + name + ".svg"
        )

        if (fallback) {
            const fallbackPath = Quickshell.iconPath(fallback)
            if (fallbackPath) paths.push(fallbackPath)
        }

        const defaultPath = Quickshell.iconPath("application-x-executable")
        if (defaultPath) paths.push(defaultPath)

        return paths
    }

    onNameChanged: _tryIndex = 0

    onStatusChanged: {
        if (status === Image.Error && _tryIndex < _candidatePaths.length - 1)
            _tryIndex++
    }

    source: _candidatePaths.length > 0 ? _candidatePaths[_tryIndex] : ""
}
