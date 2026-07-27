pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property real cpuUsage: 0.0  // 0.0 – 1.0
    property real memUsage: 0.0  // 0.0 – 1.0
    property real memTotal: 0    // GB
    property real memUsed: 0     // GB

    readonly property int cpuPercentage: Math.round(cpuUsage * 100)
    readonly property int memPercentage: Math.round(memUsage * 100)

    // Previous CPU values for delta calculation
    property real _prevTotal: 0
    property real _prevIdle: 0

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
        }
    }

    Process {
        id: cpuProc
        command: ["/bin/sh", "-c", "head -1 /proc/stat"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length < 5) return
                // cpu user nice system idle iowait irq softirq
                const values = parts.slice(1).map(Number)
                const total = values.reduce((a, b) => a + b, 0)
                const idle = values[3] + (values[4] || 0)  // idle + iowait
                
                const totalDelta = total - root._prevTotal
                const idleDelta = idle - root._prevIdle
                
                if (totalDelta > 0 && root._prevTotal > 0) {
                    root.cpuUsage = Math.max(0, Math.min(1, (totalDelta - idleDelta) / totalDelta))
                }
                root._prevTotal = total
                root._prevIdle = idle
            }
        }
    }

    Process {
        id: memProc
        command: ["/bin/sh", "-c", "free -b | grep Mem"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length < 3) return
                const total = parseInt(parts[1])
                const used = parseInt(parts[2])
                if (total > 0) {
                    root.memTotal = total / (1024 * 1024 * 1024)
                    root.memUsed = used / (1024 * 1024 * 1024)
                    root.memUsage = used / total
                }
            }
        }
    }
}
