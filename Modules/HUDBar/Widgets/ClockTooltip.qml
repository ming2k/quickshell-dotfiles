/**
 * Clock Tooltip Window
 *
 * A layershell window that displays detailed date/time information when hovering over the clock.
 * Appears as a popup below the clock widget, showing day, date, time, and week number.
 *
 * This is implemented as a separate window (not a child of the clock) to avoid being clipped
 * by the 32px tall PanelWindow.
 */

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../Common"

WlrLayershell {
    id: tooltip

    // Properties passed from Clock widget
    required property var currentDate
    required property real clockX      // Clock's global X position
    required property real clockY      // Clock's global Y position
    required property real clockWidth  // Clock's width for centering

    // Layer configuration - appears above the bar
    layer: WlrLayershell.Overlay
    namespace: "quickshell:clock-tooltip"
    exclusiveZone: -1
    keyboardFocus: WlrKeyboardFocus.None

    // Position below the clock
    anchors {
        top: true
        left: true
    }

    margins {
        top: Math.round(clockY + 32 + 8)  // Below bar (32px) + 8px margin
        left: Math.round(clockX + (clockWidth / 2) - 110)  // Center under clock (220px / 2 = 110)
    }

    implicitWidth: 220
    implicitHeight: 90

    color: "transparent"

    // Tooltip content
    Rectangle {
        anchors.fill: parent
        color: Colors.bg0  // Gruvbox dark background
        border.width: 2
        border.color: Colors.bg2  // Gruvbox bg2
        radius: 4

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Day of week
            Text {
                text: Qt.formatDateTime(tooltip.currentDate, "dddd")
                color: Colors.fg1  // Gruvbox fg1
                font.pixelSize: 16
                font.family: "Cantarell"
                font.weight: Font.Bold
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            // Full date
            Text {
                text: Qt.formatDateTime(tooltip.currentDate, "MMMM d, yyyy")
                color: Colors.fg2  // Gruvbox fg2
                font.pixelSize: 14
                font.family: "Cantarell"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            // Week number
            Text {
                text: {
                    // Calculate ISO week number
                    let date = new Date(tooltip.currentDate)
                    let onejan = new Date(date.getFullYear(), 0, 1)
                    let weekNum = Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7)
                    return "Week " + weekNum
                }
                color: Colors.gray  // Gruvbox gray
                font.pixelSize: 11
                font.family: "Cantarell"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
