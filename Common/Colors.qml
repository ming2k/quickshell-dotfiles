/**
 * Colors - Global Color Palette
 *
 * This singleton provides the color scheme for the entire Quickshell configuration.
 * It implements the Gruvbox Dark theme, a retro-inspired color palette with
 * warm, earthy tones and excellent contrast for readability.
 *
 * Color Philosophy:
 * - Background: Dark, warm grays (bg0-bg4) for comfortable long-term viewing
 * - Foreground: Cream/beige tones (fg0-fg4) for easy reading
 * - Accents: Muted, pastel-like colors that don't strain the eyes
 *
 * Usage:
 * Import this singleton in any QML file to access colors:
 *   import "path/to/Common"
 *   color: Colors.accent
 *
 * @singleton
 * @see https://github.com/morhetz/gruvbox for the original color scheme
 */

pragma Singleton
import QtQuick

QtObject {
    //==========================================================================
    // GRUVBOX DARK BASE COLORS
    //==========================================================================

    /**
     * Background Colors (bg0-bg4)
     *
     * Progressively lighter background shades for layering UI elements.
     * Use darker shades for base backgrounds, lighter for elevated surfaces.
     */
    readonly property color bg0_hard: "#1d2021"  // Darkest background (alternate)
    readonly property color bg0: "#282828"        // Primary background
    readonly property color bg1: "#3c3836"        // Slightly elevated surfaces
    readonly property color bg2: "#504945"        // Secondary surfaces, separators
    readonly property color bg3: "#665c54"        // Active/hover states
    readonly property color bg4: "#7c6f64"        // Lightest background layer

    /**
     * Foreground Colors (fg0-fg4)
     *
     * Progressively darker foreground shades for text hierarchy.
     * Use brighter shades for primary text, darker for secondary/disabled text.
     */
    readonly property color fg0: "#fbf1c7"  // Brightest text (high emphasis)
    readonly property color fg1: "#ebdbb2"  // Primary text
    readonly property color fg2: "#d5c4a1"  // Secondary text
    readonly property color fg3: "#bdae93"  // Tertiary/muted text
    readonly property color fg4: "#a89984"  // Disabled/placeholder text

    /**
     * Neutral Gray
     *
     * A balanced mid-tone gray for subtle UI elements like
     * inactive icons, dividers, and placeholder text.
     */
    readonly property color gray: "#928374"

    //==========================================================================
    // ACCENT COLORS (Bright Variants)
    //==========================================================================

    /**
     * Bright Accent Colors
     *
     * Vibrant colors for active elements, status indicators, and highlights.
     * These are the primary accent colors used throughout the UI.
     */
    readonly property color red: "#fb4934"      // Error states, urgent notifications
    readonly property color green: "#b8bb26"    // Success states, positive feedback
    readonly property color yellow: "#fabd2f"   // Warning states, attention needed
    readonly property color blue: "#83a598"     // Links, primary actions, info
    readonly property color purple: "#d3869b"   // Special states, decorative
    readonly property color aqua: "#8ec07c"     // Alternative accent, success variant
    readonly property color orange: "#fe8019"   // Highlight, emphasis

    //==========================================================================
    // ACCENT COLORS (Dim Variants)
    //==========================================================================

    /**
     * Dim Accent Colors
     *
     * Muted versions of the bright accents for subtle use cases.
     * Use these for backgrounds, borders, or when bright colors are too prominent.
     */
    readonly property color red_dim: "#cc241d"
    readonly property color green_dim: "#98971a"
    readonly property color yellow_dim: "#d79921"
    readonly property color blue_dim: "#458588"
    readonly property color purple_dim: "#b16286"
    readonly property color aqua_dim: "#689d6a"
    readonly property color orange_dim: "#d65d0e"

    //==========================================================================
    // SEMANTIC UI COLORS
    //==========================================================================

    /**
     * Common UI Colors
     *
     * Semantic color assignments for common UI patterns.
     * These provide consistent meaning across different components.
     */
    readonly property color primary: bg0         // Primary background color
    readonly property color secondary: bg1       // Secondary background color
    readonly property color accent: blue         // Primary brand/accent color
    readonly property color text: fg1            // Primary text color
    readonly property color textSecondary: fg2   // Secondary text color
    readonly property color textTertiary: fg3    // Tertiary/muted text color
    readonly property color border: bg3          // Default border color
    readonly property color separator: bg2       // Divider/separator lines

    /**
     * Transparency Variants
     *
     * Semi-transparent overlays for modals, tooltips, and layered content.
     * The alpha channel provides varying levels of opacity.
     */
    readonly property color transparent: "transparent"  // Fully transparent
    readonly property color overlay: "#aa282828"        // Semi-transparent overlay (67% opacity)
    readonly property color overlayDark: "#dd1d2021"    // Dark overlay (87% opacity)

    /**
     * Status Colors
     *
     * Standard semantic colors for system states and user feedback.
     * Follow common UI conventions for intuitive understanding.
     */
    readonly property color success: green   // Successful operations
    readonly property color warning: yellow  // Warnings and cautions
    readonly property color error: red       // Errors and failures
    readonly property color info: blue       // Informational messages

    //==========================================================================
    // COMPONENT-SPECIFIC COLORS
    //==========================================================================

    /**
     * Widget-Specific Colors
     *
     * Colors customized for specific UI components.
     * Provides fine-grained control over individual elements.
     */
    readonly property color barBackground: bg0          // HUD bar background
    readonly property color barAccent: blue             // HUD bar accent elements
    readonly property color notificationBackground: bg0 // Notification popup background
    readonly property color notificationBorder: bg2     // Notification border
    readonly property color buttonBackground: bg1       // Button default state
    readonly property color buttonHover: bg2            // Button hover state
    readonly property color buttonActive: bg3           // Button pressed state

    /**
     * Workspace Colors
     *
     * Colors specific to the workspace/virtual desktop widget.
     * Distinguishes between active, inactive, and occupied workspaces.
     */
    readonly property color workspaceActive: "#285577"           // Active workspace background
    readonly property color workspaceActiveIndicator: "#4c7899"  // Active workspace indicator
    readonly property color workspaceInactive: transparent       // Inactive workspace (no background)
    readonly property color workspaceOccupied: bg2               // Occupied but not active

    //==========================================================================
    // UI METRICS
    //==========================================================================

    /**
     * HUD Bar Icon Size
     *
     * Standard icon size for all HUD bar widgets (Audio, Battery, Network, etc.)
     * Change this value to adjust all HUD bar icons at once.
     */
    readonly property int hudIconSize: 9

    /**
     * HUD Bar Icon Spacing
     *
     * Spacing between icons and text in HUD bar widgets.
     * Change this value to adjust spacing across all widgets at once.
     */
    readonly property int hudIconSpacing: 4

    /**
     * System Tray Icon Size
     *
     * Icon size for system tray icons (separate from HUD bar widgets).
     */
    readonly property int trayIconSize: 16

    /**
     * System Tray Icon Spacing
     *
     * Spacing between system tray icons.
     */
    readonly property int trayIconSpacing: 3
}
