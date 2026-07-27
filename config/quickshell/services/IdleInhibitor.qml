pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property bool inhibited: false

    onInhibitedChanged: {
        if (inhibited) {
            inhibitProc.running = true
            QsServices.Logger.log("IdleInhibitor", "Caffeine enabled")
        } else {
            inhibitProc.signal(15)  // SIGTERM
            QsServices.Logger.log("IdleInhibitor", "Caffeine disabled")
        }
    }

    Process {
        id: inhibitProc
        command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=User requested", "sleep", "infinity"]
        running: false
    }
}
