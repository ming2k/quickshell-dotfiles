pragma Singleton
import QtQuick

QtObject {
    /**
     * Icon Override Mapping
     * 
     * Some applications use non-standard app_ids or have poor default icons.
     * This mapping allows us to specify a preferred icon name for a given app_id or name.
     */
    readonly property var overrides: ({
        "yazi": "utilities-terminal",
        "foot": "terminal",
        "org.wezfurlong.wezterm": "terminal",
        "pavucontrol": "multimedia-volume-control",
        "nm-connection-editor": "network-workgroup",
        "blueman-manager": "bluetooth",
        "chromium": "com.google.Chrome",
        "chrome": "com.google.Chrome",
        "firefox": "org.mozilla.firefox",
        "termusic": "multimedia-player",
        "termus": "multimedia-player",
        "ncspot": "multimedia-player",
        "spotify-tui": "multimedia-player",
        "musikcube": "multimedia-player"
    })

    /**
     * Resolves an icon name based on overrides.
     */
    function resolveName(name) {
        if (!name) return ""
        return overrides[name] || name
    }

    /**
     * Search Priority Configuration
     * 
     * 1. Theme (system-wide icon theme)
     * 2. Overrides (IconService.overrides)
     * 3. Manual Lookup (Flatpaks, ~/.local/share/icons)
     * 4. Fallback (specified in component)
     * 5. Default (application-x-executable)
     * 6. Monogram (generated placeholder)
     */
    readonly property var searchPriority: [
        "theme",
        "manual",
        "fallback",
        "default",
        "monogram"
    ]
}
