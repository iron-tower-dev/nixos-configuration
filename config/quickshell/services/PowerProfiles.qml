pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property string activeProfile: "balanced"
    readonly property var profiles: ["power-saver", "balanced", "performance"]

    readonly property string icon: {
        if (activeProfile === "performance") return String.fromCodePoint(0xf140b)
        if (activeProfile === "power-saver") return String.fromCodePoint(0xf032a)
        return String.fromCodePoint(0xf05d1)
    }

    function setProfile(profile) {
        setProc.command = ["powerprofilesctl", "set", profile]
        setProc.running = true
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: readProc.running = true
    }

    Process {
        id: readProc
        command: ["powerprofilesctl", "get"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const profile = data.trim()
                if (profile && root.profiles.includes(profile)) {
                    root.activeProfile = profile
                }
            }
        }
    }

    Process {
        id: setProc
        running: false
        onExited: readProc.running = true
    }
}
