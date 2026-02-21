pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: networkService

    property string connectionType: "disconnected"  // "ethernet", "wifi", "disconnected"
    property string ssid: ""
    property int signalStrength: 0
    property string ipAddress: ""
    property string iconName: "network-offline"

    function updateIconName() {
        if (connectionType === "ethernet" || connectionType === "usb") {
            iconName = "network-wired-activated"
        } else if (connectionType === "wifi") {
            if (signalStrength >= 80) iconName = "network-wireless-signal-excellent"
            else if (signalStrength >= 60) iconName = "network-wireless-signal-good"
            else if (signalStrength >= 40) iconName = "network-wireless-signal-ok"
            else if (signalStrength >= 20) iconName = "network-wireless-signal-weak"
            else iconName = "network-wireless-signal-none"
        } else {
            iconName = "network-offline"
        }
    }

    // Network monitoring process
    property var networkChecker: Process {
        id: networkChecker
        running: true
        command: ["sh", "-c", `
            IP=/usr/sbin/ip

            # Find WiFi interface (UP state only)
            wifi_iface=$($IP -br link show 2>/dev/null | awk '/^wl/{if ($2=="UP"){print $1; exit}}')

            # Check if WiFi interface is up and connected
            if [ -n "$wifi_iface" ]; then
                # Try iwd first (since user is using iwd)
                if command -v iwctl >/dev/null 2>&1; then
                    iwd_output=$(iwctl station "$wifi_iface" show 2>/dev/null)

                    # Check if connected
                    if echo "$iwd_output" | grep -q "State.*connected"; then
                        # Extract SSID
                        ssid=$(echo "$iwd_output" | grep "Connected network" | awk '{print $3}')

                        # Extract RSSI and convert to signal strength percentage
                        rssi=$(echo "$iwd_output" | grep "RSSI" | head -1 | grep -oE '[-]?[0-9]+' | head -1)
                        if [ -n "$rssi" ]; then
                            # Convert RSSI to percentage (approximate)
                            # RSSI ranges from -90 (worst) to -30 (best)
                            signal=$(( 100 - ((rssi + 30) * -1 * 100 / 60) ))
                            [ "$signal" -lt 0 ] && signal=0
                            [ "$signal" -gt 100 ] && signal=100
                        else
                            signal=70
                        fi

                        # Get IP address
                        ip=$($IP -4 addr show "$wifi_iface" 2>/dev/null | awk '/inet /{split($2,a,"/"); print a[1]; exit}')

                        echo "wifi|$ssid|$signal|$ip"
                        exit 0
                    fi
                fi

                # Try NetworkManager
                if command -v nmcli >/dev/null 2>&1; then
                    ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
                    if [ -n "$ssid" ]; then
                        signal=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d':' -f2)
                        [ -z "$signal" ] && signal=70
                        ip=$($IP -4 addr show "$wifi_iface" 2>/dev/null | awk '/inet /{split($2,a,"/"); print a[1]; exit}')
                        echo "wifi|$ssid|$signal|$ip"
                        exit 0
                    fi
                fi

                # Try wpa_supplicant
                if command -v wpa_cli >/dev/null 2>&1; then
                    ssid=$(wpa_cli -i "$wifi_iface" status 2>/dev/null | grep "^ssid=" | cut -d'=' -f2)
                    if [ -n "$ssid" ]; then
                        ip=$($IP -4 addr show "$wifi_iface" 2>/dev/null | awk '/inet /{split($2,a,"/"); print a[1]; exit}')
                        echo "wifi|$ssid|70|$ip"
                        exit 0
                    fi
                fi
            fi

            # Check USB tethering (enp*u*, usb0, rndis*, etc.) - state can be UP or UNKNOWN
            usb_iface=$($IP -br link show 2>/dev/null | awk '/^(enp[^ ]*u|usb|rndis)/{if ($2=="UP"||$2=="UNKNOWN"){print $1; exit}}')
            if [ -n "$usb_iface" ]; then
                ip=$($IP -4 addr show "$usb_iface" 2>/dev/null | awk '/inet /{split($2,a,"/"); print a[1]; exit}')
                if [ -n "$ip" ]; then
                    echo "usb||0|$ip"
                    exit 0
                fi
            fi

            # Check ethernet (eth*, eno*, enp* excluding USB)
            eth_iface=$($IP -br link show 2>/dev/null | awk '/^(eth|eno)/{if ($2=="UP"){print $1; exit}}')
            if [ -z "$eth_iface" ]; then
                # Check enp* but exclude USB (enp*u*)
                eth_iface=$($IP -br link show 2>/dev/null | awk '/^enp/{if ($2=="UP" && $1 !~ /u/){print $1; exit}}')
            fi
            if [ -n "$eth_iface" ]; then
                ip=$($IP -4 addr show "$eth_iface" 2>/dev/null | awk '/inet /{split($2,a,"/"); print a[1]; exit}')
                echo "ethernet||0|$ip"
                exit 0
            fi

            # No connection
            echo "disconnected|||"
        `]

        stdout: SplitParser {
            onRead: data => {
                let output = data.trim()
                let parts = output.split("|")

                if (parts.length >= 4) {
                    let newType = parts[0]
                    let newSsid = parts[1] || ""
                    let newSignal = parseInt(parts[2]) || 0
                    let newIp = parts[3] || ""

                    // Update properties
                    networkService.connectionType = newType
                    networkService.ssid = newSsid
                    networkService.signalStrength = newSignal
                    networkService.ipAddress = newIp

                    networkService.updateIconName()
                }
            }
        }
    }

    property var networkCheckTimer: Timer {
        interval: 5000  // Check every 5 seconds (power saving)
        running: true
        repeat: true
        onTriggered: networkChecker.running = true
    }

    Component.onCompleted: {
        updateIconName()
    }
}
