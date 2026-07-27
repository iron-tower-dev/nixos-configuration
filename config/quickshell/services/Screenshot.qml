pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property bool isRecording: false
    readonly property string screenshotsDir: {
        const dir = QsConfig.Config.data?.paths?.screenshotsDir
        if (dir) {
            if (dir.startsWith("~/")) return Quickshell.env("HOME") + "/" + dir.slice(2)
            return dir
        }
        return Quickshell.env("HOME") + "/Pictures/Screenshots"
    }

    function takeScreenshot(mode) {
        if (mode === "region") {
            regionProc.running = true
        } else {
            screenProc.running = true
        }
    }

    function startRecording() {
        recordProc.running = true
        root.isRecording = true
    }

    function stopRecording() {
        recordProc.signal(2)  // SIGINT
        root.isRecording = false
    }

    Process {
        id: screenProc
        command: ["/bin/sh", "-c", `grim "${root.screenshotsDir}/screenshot_$(date +%Y%m%d_%H%M%S).png"`]
        running: false
        onExited: QsServices.Logger.log("Screenshot", "Screenshot saved")
    }

    Process {
        id: regionProc
        command: ["/bin/sh", "-c", `grim -g "$(slurp)" "${root.screenshotsDir}/screenshot_$(date +%Y%m%d_%H%M%S).png"`]
        running: false
        onExited: QsServices.Logger.log("Screenshot", "Region screenshot saved")
    }

    Process {
        id: recordProc
        command: ["/bin/sh", "-c", `wf-recorder -f "${root.screenshotsDir}/recording_$(date +%Y%m%d_%H%M%S).mp4"`]
        running: false
    }
}
