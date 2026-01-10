/**
 * Quickshell Configuration - Main Entry Point
 *
 * This is the root configuration file for Quickshell, a Qt/QML-based Wayland compositor shell.
 * It sets up the primary UI components including the HUD bar and notification system.
 *
 * Architecture:
 * - ShellRoot: The top-level container for all shell components
 * - PanelWindow: Creates a bar on each connected screen
 * - NotificationManager: Handles system notification display
 *
 * @author Your Name
 * @requires Qt 6.x, Quickshell, Wayland
 */

//@ pragma UseQApplication
// Force the use of QApplication instead of QGuiApplication.
// Required for features like system tray support and better desktop integration.

//@ pragma IconTheme Papirus-Dark
// Set the icon theme to Papirus-Dark for consistent icon rendering.
// This theme will be used for all icon lookups throughout the application.

import QtQuick
import Quickshell
import Quickshell.Wayland
import "Common"
import "Services"
import "Modules/HUDBar"
import "Modules/Notifications"
import "Modules/Summon"

ShellRoot {
    /**
     * Component Initialization
     *
     * Called when the component has been fully constructed.
     * Services are implemented as singletons and are automatically initialized
     * when first accessed, so no explicit initialization is needed here.
     */
    Component.onCompleted: {
        console.log("Quickshell config initialized")
    }

    /**
     * Multi-Monitor HUD Bar Setup
     *
     * Creates a PanelWindow (top bar) for each connected screen.
     * The Variants component dynamically creates instances based on the model,
     * ensuring that connecting/disconnecting monitors works seamlessly.
     *
     * Each panel is:
     * - Anchored to the top of its screen
     * - 32 pixels tall (comfortable for 1080p+ displays)
     * - Transparent background (the HUDBar provides its own background)
     */
    Variants {
        model: Quickshell.screens  // Automatically updates when screens are added/removed

        PanelWindow {
            id: panelWindow
            property var modelData  // Reference to the screen object from the model
            screen: modelData        // Bind this panel to its specific screen

            // Position the bar at the top edge, spanning full width
            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 32       // Bar height in pixels
            color: "transparent"     // Let the HUDBar control its own background

            // The actual bar content
            HUDBar {
                anchors.fill: parent
                window: panelWindow  // Pass window reference for menu positioning
            }
        }
    }

    /**
     * Notification System
     *
     * Manages incoming desktop notifications from applications.
     * Automatically creates popup windows for each notification.
     * See NotificationManager.qml for implementation details.
     */
    NotificationManager {}

    /**
     * Application Summon
     *
     * Provides a rofi-like application summon interface.
     * Triggered via keyboard shortcut (Super+Space in niri).
     * See SummonWindow.qml and SummonService.qml for implementation.
     */
    SummonWindow {
        screen: Quickshell.screens[0]  // Display on primary monitor
    }
}