import QtQuick
import Quickshell
import Quickshell.Widgets

Image {
    id: root

    // Primary icon name or path
    property string name: ""

    // Fallback icon if primary fails
    property string fallback: ""

    // Icon size
    property int size: 16

    // Icon color (placeholder for compatibility - not used)
    property color iconColor: "white"

    // Placeholder for compatibility (not used)
    property bool enableColorization: false

    width: size
    height: size
    sourceSize.width: size
    sourceSize.height: size
    asynchronous: true
    mipmap: true
    fillMode: Image.PreserveAspectFit
    smooth: true

    // Track which path to try
    property int _tryIndex: 0

    // All possible paths to check
    property var _candidatePaths: {
        if (!name) return []

        const homeDir = Quickshell.env("HOME") || "/home/ming"
        let paths = []

        // Handle various URL schemes - image://, file://, qrc://, etc.
        if (name.startsWith("image:") || name.startsWith("file:") || name.startsWith("qrc:")) {
            return [name]
        }

        // If it's already a full path, use it directly
        if (name.startsWith("/")) {
            return ["file://" + name]
        }

        // Try theme lookup first
        const themePath = Quickshell.iconPath(name)
        if (themePath) {
            paths.push(themePath)
        }

        // For flatpak-style names (with dots), add flatpak paths
        if (name.indexOf(".") !== -1) {
            paths = paths.concat([
                // User flatpak icons - various sizes
                "file://" + homeDir + "/.local/share/flatpak/exports/share/icons/hicolor/scalable/apps/" + name + ".svg",
                "file://" + homeDir + "/.local/share/flatpak/exports/share/icons/hicolor/512x512/apps/" + name + ".png",
                "file://" + homeDir + "/.local/share/flatpak/exports/share/icons/hicolor/256x256/apps/" + name + ".png",
                "file://" + homeDir + "/.local/share/flatpak/exports/share/icons/hicolor/128x128/apps/" + name + ".png",
                "file://" + homeDir + "/.local/share/flatpak/exports/share/icons/hicolor/64x64/apps/" + name + ".png",
                "file://" + homeDir + "/.local/share/flatpak/exports/share/icons/hicolor/48x48/apps/" + name + ".png",
                // System flatpak icons
                "file:///var/lib/flatpak/exports/share/icons/hicolor/scalable/apps/" + name + ".svg",
                "file:///var/lib/flatpak/exports/share/icons/hicolor/512x512/apps/" + name + ".png",
                "file:///var/lib/flatpak/exports/share/icons/hicolor/256x256/apps/" + name + ".png",
                "file:///var/lib/flatpak/exports/share/icons/hicolor/128x128/apps/" + name + ".png",
                "file:///var/lib/flatpak/exports/share/icons/hicolor/64x64/apps/" + name + ".png"
            ])
        }

        // Add standard icon locations
        paths = paths.concat([
            "file://" + homeDir + "/.local/share/icons/hicolor/scalable/apps/" + name + ".svg",
            "file://" + homeDir + "/.local/share/icons/hicolor/48x48/apps/" + name + ".png",
            "file:///usr/share/pixmaps/" + name + ".png",
            "file:///usr/share/pixmaps/" + name + ".svg",
            "file:///usr/share/icons/hicolor/scalable/apps/" + name + ".svg",
            "file:///usr/share/icons/hicolor/48x48/apps/" + name + ".png"
        ])

        // Try fallback theme icon
        if (fallback) {
            const fallbackPath = Quickshell.iconPath(fallback)
            if (fallbackPath) {
                paths.push(fallbackPath)
            }
        }

        // Last resort
        const defaultPath = Quickshell.iconPath("application-x-executable")
        if (defaultPath) {
            paths.push(defaultPath)
        }

        return paths
    }

    // Reset try index when name changes
    onNameChanged: _tryIndex = 0

    // Handle load failures by trying next path
    onStatusChanged: {
        if (status === Image.Error && _tryIndex < _candidatePaths.length - 1) {
            _tryIndex++
        }
    }

    source: _candidatePaths.length > 0 ? _candidatePaths[_tryIndex] : ""
}
