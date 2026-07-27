pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property real level: 0.0
    property bool available: false
    readonly property int percentage: Math.round(level * 100)

    readonly property string icon: {
        if (level <= 0.25) return String.fromCodePoint(0xf00de)
        if (level <= 0.5) return String.fromCodePoint(0xf00df)
        if (level <= 0.75) return String.fromCodePoint(0xf00e0)
        return String.fromCodePoint(0xf00e0)
    }

    function setLevel(val) {
        if (!available) return
        const clamped = Math.max(0, Math.min(1, val))
        setProc.command = ["brightnessctl", "-c", "backlight", "set", `${Math.round(clamped * 100)}%`]
        setProc.running = true
    }

    // Poll current brightness every 2 seconds
    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: readProc.running = true
    }

    Process {
        id: readProc
        command: ["brightnessctl", "-m", "-c", "backlight"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                // brightnessctl -m -c backlight output format:
                // device,backlight,current,max,percentage%
                const parts = data.trim().split(",")
                if (parts.length >= 5 && parts[1] === "backlight") {
                    const pctStr = parts[4]
                    const p = parseInt(pctStr)
                    if (!isNaN(p)) {
                        root.level = p / 100
                        root.available = true
                    }
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.available = false
            }
        }
    }

    Process {
        id: setProc
        running: false
    }
}
