pragma Singleton
import QtQuick

QtObject {
    /**
     * Icon Override Mapping
     * 
     * Only override icons that are known to have missing or broken defaults.
     * We keep this list minimal to respect original application branding and colors.
     */
    readonly property var overrides: ({
        "yazi": "utilities-terminal",
        "foot": "terminal",
        "org.wezfurlong.wezterm": "terminal",
        "pavucontrol": "multimedia-volume-control",
        "nm-connection-editor": "network-workgroup",
        "blueman-manager": "bluetooth"
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
     */
    readonly property var searchPriority: [
        "theme",
        "manual",
        "fallback",
        "default",
        "monogram"
    ]
}
