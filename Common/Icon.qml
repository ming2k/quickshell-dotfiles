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

    source: {
        if (!name) return ""

        // If it's already a full path or URL, use it directly
        if (name.indexOf("/") !== -1 || name.indexOf("://") !== -1) {
            return name
        }

        // Try theme lookup first
        let iconPath = Quickshell.iconPath(name)
        if (iconPath) return iconPath

        // Try fallback icon if specified
        if (fallback) {
            iconPath = Quickshell.iconPath(fallback)
            if (iconPath) return iconPath
        }

        // Get home directory from environment
        const homeDir = Quickshell.env("HOME") || "/home/ming"

        // Try direct file paths in order of preference
        // Priority: user local icons -> system pixmaps -> hicolor theme
        const tryPaths = [
            "file://" + homeDir + "/.local/share/icons/" + name + ".png",
            "file://" + homeDir + "/.local/share/icons/" + name + ".svg",
            "file:///usr/share/pixmaps/" + name + ".png",
            "file:///usr/share/pixmaps/" + name + ".svg",
            "file:///usr/share/icons/hicolor/48x48/apps/" + name + ".png",
            "file:///usr/share/icons/hicolor/scalable/apps/" + name + ".svg"
        ]

        // Return first path (Qt's Image will try to load it)
        return tryPaths[0]
    }
}