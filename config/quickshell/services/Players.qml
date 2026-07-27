pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property bool hasPlayer: false
    property string title: ""
    property string artist: ""
    property string status: "Stopped"

    readonly property string icon: {
        if (!hasPlayer || status === "Stopped") return String.fromCodePoint(0xf0387)
        if (status === "Playing") return String.fromCodePoint(0xf03e4)
        if (status === "Paused") return String.fromCodePoint(0xf040a)
        return String.fromCodePoint(0xf0387)
    }

    function playPause() {
        controlProc.command = ["playerctl", "play-pause"]
        controlProc.running = true
    }

    function next() {
        controlProc.command = ["playerctl", "next"]
        controlProc.running = true
    }

    function previous() {
        controlProc.command = ["playerctl", "previous"]
        controlProc.running = true
    }

    // Poll playerctl every 2 seconds
    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: readProc.running = true
    }

    Process {
        id: readProc
        command: ["playerctl", "metadata", "--format", "{{artist}}|||{{title}}|||{{status}}"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|||")
                if (parts.length >= 3) {
                    root.artist = parts[0] || ""
                    root.title = parts[1] || ""
                    const s = parts[2] || ""
                    if (s === "Playing" || s === "Paused" || s === "Stopped") {
                        root.status = s
                    } else {
                        root.status = "Stopped"
                    }
                    root.hasPlayer = true
                } else {
                    root.hasPlayer = false
                    root.title = ""
                    root.artist = ""
                    root.status = "Stopped"
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            // playerctl exits non-zero when no player is available
            if (exitCode !== 0) {
                root.hasPlayer = false
                root.title = ""
                root.artist = ""
                root.status = "Stopped"
            }
        }
    }

    Process {
        id: controlProc
        running: false
    }
}
