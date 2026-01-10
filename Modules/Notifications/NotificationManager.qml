/**
 * Notification Manager Component
 *
 * This component manages the notification system by listening to the NotificationServer
 * and creating popup windows for each incoming notification.
 *
 * Key Features:
 * - Receives notifications from the D-Bus notification service
 * - Dynamically creates NotificationPopup instances for each notification
 * - Handles automatic cleanup when notifications are dismissed or expire
 *
 * Implementation Notes:
 * - All popups appear on the primary screen (Quickshell.screens[0])
 * - Popups are destroyed when notifications are closed to prevent memory leaks
 * - Uses component-based creation for better modularity and error handling
 *
 * @see NotificationPopup.qml for the popup window implementation
 */

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    /**
     * Notification D-Bus Server
     *
     * Implements the org.freedesktop.Notifications D-Bus interface.
     * Applications send notifications to this server, which are then
     * emitted through the onNotification signal.
     */
    NotificationServer {
        id: server

        /**
         * Notification Handler
         *
         * Called whenever a new notification is received from any application.
         * Creates a visual popup window to display the notification content.
         *
         * @param notification - The notification object containing:
         *   - summary: Title text
         *   - body: Detailed message
         *   - icon: Icon name or path
         *   - appIcon: Application icon fallback
         *   - actions: Array of action buttons
         *   - urgency: Low, Normal, or Critical
         */
        onNotification: notification => {
            console.log("Notification received:", notification.summary)

            // Dynamically load the NotificationPopup component
            const component = Qt.createComponent("NotificationPopup.qml")

            if (component.status === Component.Ready) {
                // Create a new popup instance with the notification data
                const popup = component.createObject(null, {
                    notification: notification,
                    screen: Quickshell.screens[0]  // Display on primary monitor
                })

                /**
                 * Automatic Cleanup Handler
                 *
                 * Destroys the popup when the notification is closed.
                 * This can happen when:
                 * - User clicks the close button
                 * - User clicks an action button
                 * - Auto-dismiss timer expires (5 seconds)
                 * - Application programmatically closes the notification
                 */
                notification.onClosed.connect(() => {
                    popup.destroy()
                })
            } else {
                // Log component creation errors for debugging
                console.error("Failed to create notification popup:", component.errorString())
            }
        }
    }
}
