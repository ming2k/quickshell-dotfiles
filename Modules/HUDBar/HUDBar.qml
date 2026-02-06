/**
 * HUD Bar - Main Status Bar Component
 *
 * The primary status bar displayed at the top of each screen.
 * Provides workspace navigation, window information, and system status monitoring.
 *
 * Layout Structure:
 * ┌─────────────────────────────────────────────────────────────┐
 * │ [Workspaces] [Window Title]  [Clock]  [Tray|Audio|Net|Bat] │
 * └─────────────────────────────────────────────────────────────┘
 *
 * Three main sections:
 * - Left: Workspace switcher and active window title
 * - Center: Clock/date display
 * - Right: System tray and status widgets
 *
 * Design Philosophy:
 * - Minimal and unobtrusive
 * - Essential information at a glance
 * - Consistent with i3/sway status bar conventions
 *
 * @see Widgets/ for individual widget implementations
 */

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Common"
import "Widgets"

Rectangle {
    id: hudBar
    color: Colors.barBackground  // Gruvbox dark background

    /**
     * Window Reference Property
     *
     * Stores a reference to the parent PanelWindow.
     * Used by widgets (like SystemTray) for proper menu positioning
     * and window management.
     */
    property var window

    /**
     * Main Bar Layout
     *
     * Three-column layout with flexible left/right sections
     * and fixed-width center section for the clock.
     */
    RowLayout {
        anchors.fill: parent
        spacing: 0  // Sections manage their own spacing

        //======================================================================
        // LEFT SECTION - Workspaces & Window Info
        //======================================================================

        /**
         * Left Section Container
         *
         * Contains workspace switcher and active window title.
         * Expands to fill available space, pushing center section to middle.
         */
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0  // Allow shrinking when window is narrow

            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8  // Padding from screen edge
                spacing: 0

                /**
                 * Workspace Switcher
                 *
                 * Shows numbered buttons for virtual desktops/workspaces.
                 * Highlights active workspace, allows clicking to switch.
                 */
                Workspaces {
                    Layout.alignment: Qt.AlignVCenter
                }

                /**
                 * Active Window Title
                 *
                 * Displays the title of the currently focused window.
                 * Updates automatically when focus changes.
                 */
                WindowTitle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 12  // Space from workspace buttons
                }
            }
        }

        //======================================================================
        // CENTER SECTION - Clock
        //======================================================================

        /**
         * Clock Widget
         *
         * Displays current time and date in the center of the bar.
         * Layout.alignment centers it between left and right sections.
         */
        Clock {
            Layout.alignment: Qt.AlignCenter
        }

        //======================================================================
        // RIGHT SECTION - System Status
        //======================================================================

        /**
         * Right Section Container
         *
         * Contains system tray and status widgets (audio, network, battery).
         * Expands to fill available space, balanced with left section.
         */
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0  // Allow shrinking when window is narrow

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 8  // Padding from screen edge
                spacing: 8              // Space between widgets

                /**
                 * System Tray
                 *
                 * Displays application tray icons (network manager, messaging apps, etc.)
                 * Requires the parent window reference for proper popup positioning.
                 */
                SystemTray {
                    Layout.alignment: Qt.AlignVCenter
                    parentWindow: hudBar.window
                }

                /**
                 * Privacy Widget
                 *
                 * Shows indicators when camera, microphone, or screen sharing is active.
                 * Only visible when privacy-sensitive resources are in use.
                 */
                Privacy {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 12
                }

                /**
                 * Audio Widget
                 *
                 * Shows current volume level and mute status.
                 * Click to toggle mute, scroll to adjust volume.
                 */
                Audio {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 12  // Extra spacing after system tray
                }

                /**
                 * Network Widget
                 *
                 * Displays network connectivity status and type.
                 * Shows WiFi signal strength or ethernet connection.
                 */
                Network {
                    Layout.alignment: Qt.AlignVCenter
                }

                /**
                 * Battery Widget
                 *
                 * Shows battery charge level and charging status.
                 * Only visible on laptops/devices with batteries.
                 */
                Battery {
                    Layout.alignment: Qt.AlignVCenter
                }

                Inhibit {
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
