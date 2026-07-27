pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property bool powered: false
    property bool connected: false
    property string connectedDevice: ""

    readonly property string icon: {
        if (!powered) return String.fromCodePoint(0xf00b2)
        if (connected) return String.fromCodePoint(0xf00b1)
        return String.fromCodePoint(0xf00af)
    }

    function togglePower() {
        toggleProc.command = ["bluetoothctl", "power", powered ? "off" : "on"]
        toggleProc.running = true
    }

    // Poll bluetooth state every 5 seconds
    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: showProc.running = true
    }

    // Check power state: bluetoothctl show
    Process {
        id: showProc
        command: ["bluetoothctl", "show"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line.startsWith("Powered:")) {
                    root.powered = line.includes("yes")
                    // Only check connected devices if powered
                    if (root.powered) {
                        connectedProc.running = true
                    } else {
                        root.connected = false
                        root.connectedDevice = ""
                    }
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            // Handle missing bluetoothctl or adapter
            if (exitCode !== 0) {
                root.powered = false
                root.connected = false
                root.connectedDevice = ""
            }
        }
    }

    // Check connected devices: bluetoothctl devices Connected
    Process {
        id: connectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        running: false
        property string _output: ""
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                // Output format: "Device XX:XX:XX:XX:XX:XX DeviceName"
                if (line.startsWith("Device ")) {
                    const parts = line.substring(7).split(" ")
                    if (parts.length >= 2) {
                        connectedProc._output = parts.slice(1).join(" ")
                    }
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && connectedProc._output !== "") {
                root.connected = true
                root.connectedDevice = connectedProc._output
            } else {
                root.connected = false
                root.connectedDevice = ""
            }
            connectedProc._output = ""
        }
    }

    // Toggle power process
    Process {
        id: toggleProc
        running: false
        onExited: (exitCode, exitStatus) => {
            // Refresh state after toggling
            showProc.running = true
        }
    }
}
