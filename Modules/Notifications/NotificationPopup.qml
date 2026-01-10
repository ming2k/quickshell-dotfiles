/**
 * Notification Popup Window
 *
 * A layershell window that displays individual notification popups.
 * This component implements the visual presentation of desktop notifications
 * with support for icons, actions, and interactive elements.
 *
 * Features:
 * - Slide-in animation from top
 * - Interactive close button
 * - Support for notification actions (buttons)
 * - Auto-dismiss after 5 seconds
 * - Icon display with fallbacks
 * - Multi-line body text with ellipsis
 *
 * Layout:
 * - Positioned at top-center of screen
 * - 350px wide (compact size for better screen real estate)
 * - Height adjusts to content
 * - 50px top margin to avoid screen edge
 *
 * @see NotificationManager.qml for the creation logic
 */

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications
import "../../Common"

/**
 * Wayland Layershell Window
 *
 * Uses the wlr-layer-shell protocol to create a notification overlay window.
 * This ensures notifications appear above all normal windows.
 */
WlrLayershell {
    id: popup

    // The notification object passed from NotificationManager
    required property var notification

    // Determine sound file based on urgency level
    property string soundFile: {
        const urgency = notification.urgency || 0  // 0=Low, 1=Normal, 2=Critical
        if (urgency >= 2) {
            // Critical or High urgency → critical sound
            return Qt.resolvedUrl("audio/critical.mp3")
        } else {
            // Normal or Low urgency → normal sound
            return Qt.resolvedUrl("audio/normal.mp3")
        }
    }

    // Layer configuration
    layer: WlrLayershell.Overlay          // Appears above normal windows
    namespace: "quickshell:notification-popup"  // Unique identifier for window
    exclusiveZone: -1                      // Don't reserve screen space
    keyboardFocus: WlrKeyboardFocus.None   // Don't steal keyboard focus

    // Position at top of screen, spanning full width
    anchors {
        top: true
        left: true
        right: true
    }

    // Offset from screen edge (optimized for better screen usage)
    margins {
        top: 40  // Reduced from 50px for better space utilization
    }

    implicitHeight: notifContent.implicitHeight  // Adjust to content size

    color: "transparent"  // Background is handled by the Rectangle inside

    /**
     * Sound Player Process
     *
     * Plays notification sound using ffplay (same tool used by mako).
     * Sound file is determined by notification urgency level.
     * Runs in background without blocking the UI.
     */
    Process {
        id: soundPlayer
        command: ["ffplay", "-nodisp", "-autoexit", "-loglevel", "error", soundFile]
        running: false
    }

    /**
     * Notification Content Container
     *
     * The main visible notification card with background, border, and content.
     * Positioned at the top-center of the screen with smooth animations.
     */
    Rectangle {
        id: notifContent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 350  // Compact width for better screen real estate
        implicitHeight: contentLayout.implicitHeight + 20  // Content height + padding (optimized)

        // Visual styling from Gruvbox theme
        color: Colors.notificationBackground  // Dark background
        radius: 10                             // Slightly more rounded for modern look
        border.color: Colors.notificationBorder  // Subtle border
        border.width: 1                        // Thinner border for cleaner look

        // Initial state for slide-in animation
        opacity: 0      // Start invisible
        scale: 0.95     // Start slightly smaller

        /**
         * Start Animation and Sound on Creation
         *
         * Triggers the slide-in animation and plays notification sound
         * as soon as the notification appears on screen.
         */
        Component.onCompleted: {
            slideIn.start()
            soundPlayer.running = true
        }

        /**
         * Slide-In Animation
         *
         * Creates a smooth entrance effect with:
         * - Fade in (opacity 0 → 1)
         * - Scale up (0.95 → 1.0)
         * - OutBack easing for a subtle bounce effect
         * - 200ms duration for snappy feel
         */
        ParallelAnimation {
            id: slideIn
            NumberAnimation {
                target: notifContent
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: notifContent
                property: "scale"
                from: 0.95
                to: 1.0
                duration: 200
                easing.type: Easing.OutBack  // Subtle bounce
            }
        }

        /**
         * Main Content Layout
         *
         * Horizontal layout containing icon and text content.
         * Structure: [Icon] [Title/Body/Actions]
         * Optimized spacing for compact, modern appearance.
         */
        RowLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 10  // Reduced padding for tighter layout
            spacing: 10          // Reduced space between icon and text

            /**
             * Notification Icon
             *
             * Displays the notification icon with fallback chain:
             * 1. notification.icon (specific icon for this notification)
             * 2. notification.appIcon (application's icon)
             * 3. "dialog-information" (default fallback)
             *
             * Icon is aligned to center for better visual balance with text.
             */
            Icon {
                name: popup.notification.icon || popup.notification.appIcon || "dialog-information"
                size: 32  // Better proportioned with 15px title + body text
                Layout.alignment: Qt.AlignVCenter  // Changed from AlignTop for better balance
                iconColor: Colors.accent  // Blue tint from Gruvbox theme
            }

            /**
             * Text Content Column
             *
             * Contains notification title, body text, and action buttons.
             * Expands to fill available width.
             */
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4  // Tighter vertical spacing for compact design

                /**
                 * Title Row
                 *
                 * Contains the notification summary (title) and close button.
                 * The title takes available space, close button is fixed size.
                 */
                RowLayout {
                    Layout.fillWidth: true

                    // Notification title
                    Text {
                        text: popup.notification.summary || "Notification"
                        font.bold: true
                        font.pixelSize: 15  // Slightly smaller for better proportions
                        font.family: "Cantarell"
                        color: Colors.fg1  // Bright foreground color
                        Layout.fillWidth: true
                        elide: Text.ElideRight  // Truncate with "..." if too long
                    }

                    /**
                     * Close Button
                     *
                     * Modern circular close button with smooth hover effects.
                     * Subtle by default, prominent on interaction.
                     */
                    Rectangle {
                        width: 24
                        height: 24
                        color: closeArea.pressed ? Colors.bg3 : (closeArea.containsMouse ? Colors.bg2 : "transparent")
                        radius: 12  // Fully circular

                        // Smooth color transitions
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "×"  // Unicode multiplication sign (cleaner than ✕)
                            color: closeArea.containsMouse ? Colors.fg1 : Colors.gray
                            font.pixelSize: 20
                            font.family: "Cantarell"

                            // Smooth color transitions on hover
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true  // Enable hover effects
                            onClicked: {
                                popup.notification.tracked = false  // Mark as closed
                                popup.destroy()  // Remove popup window
                            }
                            cursorShape: Qt.PointingHandCursor  // Show pointer cursor
                        }
                    }
                }

                /**
                 * Notification Body Text
                 *
                 * The detailed message content of the notification.
                 * Hidden if the notification has no body text.
                 *
                 * Text handling:
                 * - Wraps to multiple lines (up to 4 lines for compactness)
                 * - Truncates with "..." if longer than 4 lines
                 * - Slightly dimmer color than title for hierarchy
                 */
                Text {
                    text: popup.notification.body
                    color: Colors.fg2  // Dimmer than title
                    font.pixelSize: 14  // Increased for better readability
                    font.family: "Cantarell"
                    wrapMode: Text.Wrap      // Allow text to wrap
                    Layout.fillWidth: true
                    maximumLineCount: 4       // Reduced to 4 lines for compactness
                    elide: Text.ElideRight    // Add "..." if truncated
                    visible: text.length > 0  // Hide if no body text
                    lineHeight: 1.0           // Single line spacing for minimal gaps
                }

                /**
                 * Action Buttons Row
                 *
                 * Displays interactive action buttons provided by the application.
                 * Examples: "Reply", "Mark as Read", "Open", etc.
                 *
                 * Only visible when the notification includes actions.
                 * Each action invokes its callback and closes the notification.
                 */
                RowLayout {
                    visible: popup.notification.actions && popup.notification.actions.length > 0
                    Layout.topMargin: 4  // Reduced space above buttons
                    spacing: 6           // Tighter spacing between buttons

                    Repeater {
                        model: popup.notification.actions
                        delegate: Rectangle {
                            // Modern button background with smooth hover/press states
                            color: actionArea.pressed ? Colors.buttonActive : (actionArea.containsMouse ? Colors.buttonHover : Colors.buttonBackground)
                            radius: 6  // More rounded for modern look
                            implicitHeight: 28  // Slightly shorter for compact design
                            implicitWidth: actionText.implicitWidth + 20  // Text width + reduced padding
                            Layout.preferredHeight: implicitHeight
                            Layout.preferredWidth: implicitWidth

                            Text {
                                id: actionText
                                anchors.centerIn: parent
                                text: modelData.text  // Action button label
                                color: actionArea.containsMouse ? Colors.fg0 : Colors.fg1
                                font.pixelSize: 12  // Slightly smaller for compact design
                                font.family: "Cantarell"

                                // Smooth color transitions on hover
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            MouseArea {
                                id: actionArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    modelData.invoke()  // Call the action callback
                                    popup.notification.tracked = false
                                    popup.destroy()  // Close notification after action
                                }
                            }

                            // Smooth color transitions on hover
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Auto-Dismiss Timer
     *
     * Automatically closes the notification after 5 seconds.
     * This prevents notifications from accumulating on screen.
     *
     * User can still manually close earlier using the close button
     * or by clicking an action.
     */
    Timer {
        interval: 5000  // 5 seconds in milliseconds
        running: true   // Start immediately
        onTriggered: {
            popup.notification.tracked = false  // Mark as closed
            popup.destroy()  // Remove popup window
        }
    }
}
