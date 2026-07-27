pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property bool connected: false
    property string ssid: ""
    property int strength: 0
    property string type: "disconnected"

    readonly property string icon: {
        if (type === "disconnected") return String.fromCodePoint(0xf092e)
        if (type === "ethernet") return String.fromCodePoint(0xf0201)
        // wifi signal levels
        if (strength >= 75) return String.fromCodePoint(0xf0928)
        if (strength >= 50) return String.fromCodePoint(0xf0925)
        if (strength >= 25) return String.fromCodePoint(0xf0922)
        return String.fromCodePoint(0xf091f)
    }

    // Poll every 5 seconds
    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: deviceProc.running = true
    }

    // Get general device status (TYPE,STATE,CONNECTION)
    Process {
        id: deviceProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        running: false
        property string _bestType: "disconnected"
        property string _bestConnection: ""

        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line === "") return

                const parts = line.split(":")
                if (parts.length < 3) return

                const devType = parts[0]
                const state = parts[1]
                const connection = parts[2]

                // Only consider truly connected devices (not "connected (externally)" like loopback)
                if (state !== "connected") return

                // Prioritize: ethernet > wifi > other
                if (devType === "ethernet") {
                    deviceProc._bestType = "ethernet"
                    deviceProc._bestConnection = connection
                } else if (devType === "wifi" && deviceProc._bestType !== "ethernet") {
                    deviceProc._bestType = "wifi"
                    deviceProc._bestConnection = connection
                }
            }
        }
        onRunningChanged: {
            if (running) {
                deviceProc._bestType = "disconnected"
                deviceProc._bestConnection = ""
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.connected = false
                root.ssid = ""
                root.strength = 0
                root.type = "disconnected"
                return
            }

            if (deviceProc._bestType === "disconnected") {
                root.connected = false
                root.ssid = ""
                root.strength = 0
                root.type = "disconnected"
            } else {
                root.connected = true
                root.type = deviceProc._bestType
                root.ssid = deviceProc._bestConnection

                if (deviceProc._bestType === "wifi") {
                    wifiProc.running = true
                } else {
                    root.strength = 100
                }
            }
        }
    }

    // Get wifi signal strength
    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "active,ssid,signal,type", "device", "wifi"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line === "") return

                const parts = line.split(":")
                if (parts.length < 4) return

                const active = parts[0]
                if (active === "yes") {
                    root.ssid = parts[1]
                    root.strength = parseInt(parts[2]) || 0
                }
            }
        }
    }
}
