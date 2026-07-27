import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 360
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    // Weather state
    property string weatherTemp: "..."
    property string weatherDesc: "Loading..."
    property string weatherIcon: String.fromCodePoint(0xf0590)

    Component.onCompleted: weatherProc.running = true

    Process {
        id: weatherProc
        command: ["/bin/sh", "-c", "curl -sf 'wttr.in/?format=%t|%C' 2>/dev/null || echo '?|Unavailable'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")
                if (parts.length >= 2) {
                    root.weatherTemp = parts[0]
                    root.weatherDesc = parts[1]
                }
            }
        }
    }

    // Refresh weather every 10 minutes
    Timer {
        interval: 600000
        repeat: true
        running: true
        onTriggered: weatherProc.running = true
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ===== HEADER: Time + Weather =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 2
                Text {
                    text: QsServices.Time.timeStr
                    color: QsServices.Wallust.purple
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
                Text {
                    text: QsServices.Time.dateStr
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }

            // Weather
            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignRight

                Text {
                    text: root.weatherTemp
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignRight
                }
                Text {
                    text: root.weatherDesc
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignRight
                    elide: Text.ElideRight
                    Layout.maximumWidth: 120
                }
            }
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // ===== SYSTEM RESOURCES =====
        Text {
            text: "System"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
        }

        // CPU
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: String.fromCodePoint(0xf035b)
                    color: QsServices.Wallust.green
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 14
                }
                Text {
                    text: "CPU"
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                Text {
                    text: QsServices.SystemUsage.cpuPercentage + "%"
                    color: QsServices.SystemUsage.cpuUsage > 0.8 ? QsServices.Wallust.red : QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                color: QsServices.Wallust.bgAlt

                Rectangle {
                    width: parent.width * QsServices.SystemUsage.cpuUsage
                    height: parent.height
                    color: QsServices.SystemUsage.cpuUsage > 0.8 ? QsServices.Wallust.red : QsServices.Wallust.green
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }

        // Memory
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: String.fromCodePoint(0xf035b)
                    color: QsServices.Wallust.cyan
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 14
                }
                Text {
                    text: "Memory"
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                Text {
                    text: `${QsServices.SystemUsage.memUsed.toFixed(1)} / ${QsServices.SystemUsage.memTotal.toFixed(1)} GB`
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                color: QsServices.Wallust.bgAlt

                Rectangle {
                    width: parent.width * QsServices.SystemUsage.memUsage
                    height: parent.height
                    color: QsServices.SystemUsage.memUsage > 0.8 ? QsServices.Wallust.red : QsServices.Wallust.cyan
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // ===== QUICK TOGGLES =====
        Text {
            text: "Toggles"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            // DND
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.orange : QsServices.Wallust.bgAlt
                Behavior on color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    Text {
                        text: String.fromCodePoint(0xf009b)
                        color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 14
                    }
                    Text {
                        text: "DND"
                        color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Notifs.toggleDND()
                }
            }

            // Caffeine
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: QsServices.IdleInhibitor.inhibited ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                Behavior on color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    Text {
                        text: String.fromCodePoint(0xf0176)
                        color: QsServices.IdleInhibitor.inhibited ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 14
                    }
                    Text {
                        text: "Caffeine"
                        color: QsServices.IdleInhibitor.inhibited ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.IdleInhibitor.inhibited = !QsServices.IdleInhibitor.inhibited
                }
            }

            // Screenshot
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: ssArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                border.width: 1
                border.color: QsServices.Wallust.muted
                Behavior on color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    Text {
                        text: String.fromCodePoint(0xf0e51)
                        color: QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 14
                    }
                    Text {
                        text: "Screenshot"
                        color: QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: ssArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Screenshot.takeScreenshot("screen")
                }
            }

            // Record
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: QsServices.Screenshot.isRecording ? QsServices.Wallust.red : recArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                border.width: QsServices.Screenshot.isRecording ? 0 : 1
                border.color: QsServices.Wallust.muted
                Behavior on color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    Text {
                        text: QsServices.Screenshot.isRecording ? String.fromCodePoint(0xf06ff) : String.fromCodePoint(0xf0ec3)
                        color: QsServices.Screenshot.isRecording ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 14
                    }
                    Text {
                        text: QsServices.Screenshot.isRecording ? "Stop" : "Record"
                        color: QsServices.Screenshot.isRecording ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: recArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (QsServices.Screenshot.isRecording) QsServices.Screenshot.stopRecording()
                        else QsServices.Screenshot.startRecording()
                    }
                }
            }
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // ===== POWER ROW =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { icon: 0xf033e, cmd: "loginctl lock-session", label: "Lock" },
                    { icon: 0xf0425, cmd: "systemctl poweroff", label: "Power Off" },
                    { icon: 0xf0709, cmd: "systemctl reboot", label: "Reboot" },
                    { icon: 0xf0343, cmd: "loginctl terminate-user $USER", label: "Logout" }
                ]

                Rectangle {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    height: 36
                    color: pwrArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: String.fromCodePoint(modelData.icon)
                            color: pwrArea.containsMouse ? QsServices.Wallust.red : QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 16

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 9
                        }
                    }

                    MouseArea {
                        id: pwrArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            pwrProc.command = ["/bin/sh", "-c", modelData.cmd]
                            pwrProc.running = true
                        }
                    }
                }
            }
        }
    }

    Process { id: pwrProc; running: false }
}
