import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../services" as QsServices
import "../../config" as QsConfig

PanelWindow {
    id: root

    property bool shouldShow: false

    property var activeScreen: Quickshell.screens[0]
    screen: activeScreen
    anchors { top: true; right: true }
    margins { right: 0; top: QsConfig.BarConfig.height }

    implicitWidth: 420
    implicitHeight: Math.min(800, screen.height - QsConfig.BarConfig.height - 20)
    color: QsServices.Wallust.bg
    visible: shouldShow

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-controlcenter"
    exclusionMode: ExclusionMode.Ignore

    FocusScope {
        id: focusRoot
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.shouldShow = false

        property bool mouseHasEntered: false

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hovered) {
                    focusRoot.mouseHasEntered = true
                    closeTimer.stop()
                } else if (focusRoot.mouseHasEntered && root.shouldShow) {
                    closeTimer.restart()
                }
            }
        }

        Timer {
            id: closeTimer
            interval: 400
            onTriggered: if (!hoverHandler.hovered) root.shouldShow = false
        }

        // Border
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: QsServices.Wallust.muted
        }

        Flickable {
            anchors.fill: parent
            anchors.margins: 16
            contentHeight: mainColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: mainColumn
                width: parent.width
                spacing: 16

                // ========== HEADER ==========
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: QsServices.Time.timeStr
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 32
                            font.weight: Font.Bold
                        }
                        Text {
                            text: QsServices.Time.dateStr
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 14
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Lock button
                    Rectangle {
                        width: 36; height: 36
                        color: hoverLock.hovered ? QsServices.Wallust.bgAlt : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰌾"
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 18
                        }
                        HoverHandler { id: hoverLock }
                        TapHandler {
                            onTapped: lockProc.running = true
                        }
                    }

                    // Power button
                    Rectangle {
                        width: 36; height: 36
                        color: hoverPower.hovered ? QsServices.Wallust.bgAlt : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰐥"
                            color: QsServices.Wallust.red
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 18
                        }
                        HoverHandler { id: hoverPower }
                        TapHandler {
                            onTapped: powerProc.running = true
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: QsServices.Wallust.muted
                }

                // ========== QUICK TOGGLES ==========
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 8

                    // WiFi Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: QsServices.Network.connected ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Text {
                                text: "󰖩"
                                color: QsServices.Network.connected ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 18
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: "Wi-Fi"
                                    color: QsServices.Network.connected ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: QsServices.Network.connected ? QsServices.Network.ssid : "Disconnected"
                                    color: QsServices.Network.connected ? Qt.rgba(QsServices.Wallust.bg.r, QsServices.Wallust.bg.g, QsServices.Wallust.bg.b, 0.7) : QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 100
                                }
                            }
                        }
                    }

                    // Bluetooth Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: QsServices.Bluetooth.powered ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Text {
                                text: "󰂯"
                                color: QsServices.Bluetooth.powered ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 18
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: "Bluetooth"
                                    color: QsServices.Bluetooth.powered ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: QsServices.Bluetooth.powered ? (QsServices.Bluetooth.connected ? QsServices.Bluetooth.connectedDevice : "On") : "Off"
                                    color: QsServices.Bluetooth.powered ? Qt.rgba(QsServices.Wallust.bg.r, QsServices.Wallust.bg.g, QsServices.Wallust.bg.b, 0.7) : QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 100
                                }
                            }
                        }
                        TapHandler { onTapped: QsServices.Bluetooth.togglePower() }
                    }

                    // DND Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Text {
                                text: "󰔎"
                                color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 18
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: "Do Not Disturb"
                                    color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: QsServices.Notifs.doNotDisturb ? "On" : "Off"
                                    color: QsServices.Notifs.doNotDisturb ? Qt.rgba(QsServices.Wallust.bg.r, QsServices.Wallust.bg.g, QsServices.Wallust.bg.b, 0.7) : QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }
                        TapHandler { onTapped: QsServices.Notifs.toggleDND() }
                    }

                    // Caffeine Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: QsServices.IdleInhibitor.inhibited ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Text {
                                text: "󰅶"
                                color: QsServices.IdleInhibitor.inhibited ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 18
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: "Caffeine"
                                    color: QsServices.IdleInhibitor.inhibited ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: QsServices.IdleInhibitor.inhibited ? "On" : "Off"
                                    color: QsServices.IdleInhibitor.inhibited ? Qt.rgba(QsServices.Wallust.bg.r, QsServices.Wallust.bg.g, QsServices.Wallust.bg.b, 0.7) : QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }
                        TapHandler { onTapped: QsServices.IdleInhibitor.inhibited = !QsServices.IdleInhibitor.inhibited }
                    }

                    // Screenshot Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: QsServices.Wallust.bgAlt
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Text {
                                text: "󰹑"
                                color: QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 18
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: "Screenshot"
                                    color: QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: "Screen"
                                    color: QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }
                        TapHandler {
                            onTapped: {
                                QsServices.Screenshot.takeScreenshot("screen")
                                root.shouldShow = false
                            }
                        }
                    }

                    // Screen Record Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: QsServices.Screenshot.isRecording ? QsServices.Wallust.red : QsServices.Wallust.bgAlt
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Text {
                                text: QsServices.Screenshot.isRecording ? "󰛿" : "󰻃"
                                color: QsServices.Screenshot.isRecording ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 18
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: QsServices.Screenshot.isRecording ? "Stop" : "Record"
                                    color: QsServices.Screenshot.isRecording ? QsServices.Wallust.bg : QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: QsServices.Screenshot.isRecording ? "Recording..." : "Screen"
                                    color: QsServices.Screenshot.isRecording ? Qt.rgba(QsServices.Wallust.bg.r, QsServices.Wallust.bg.g, QsServices.Wallust.bg.b, 0.7) : QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }
                        TapHandler {
                            onTapped: {
                                if (QsServices.Screenshot.isRecording)
                                    QsServices.Screenshot.stopRecording()
                                else
                                    QsServices.Screenshot.startRecording()
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: QsServices.Wallust.muted
                }

                // ========== VOLUME SLIDER ==========
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Text {
                            text: QsServices.Audio.muted ? "󰖁" : "󰕾"
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 16
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            color: QsServices.Wallust.bgAlt

                            Rectangle {
                                width: parent.width * QsServices.Audio.volume
                                height: parent.height
                                color: QsServices.Wallust.blue
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: mouse => {
                                    QsServices.Audio.setVolume(mouse.x / width)
                                }
                                onPositionChanged: mouse => {
                                    if (pressed)
                                        QsServices.Audio.setVolume(mouse.x / width)
                                }
                            }
                        }
                        Text {
                            text: Math.round(QsServices.Audio.volume * 100) + "%"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            Layout.preferredWidth: 36
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // ========== BRIGHTNESS SLIDER ==========
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Text {
                            text: "󰃟"
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 16
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            color: QsServices.Wallust.bgAlt

                            Rectangle {
                                width: parent.width * QsServices.Brightness.level
                                height: parent.height
                                color: QsServices.Wallust.yellow
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: mouse => {
                                    QsServices.Brightness.setLevel(mouse.x / width)
                                }
                                onPositionChanged: mouse => {
                                    if (pressed)
                                        QsServices.Brightness.setLevel(mouse.x / width)
                                }
                            }
                        }
                        Text {
                            text: QsServices.Brightness.percentage + "%"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            Layout.preferredWidth: 36
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: QsServices.Wallust.muted
                }

                // ========== SYSTEM STATS ==========
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "System"
                        color: QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    // CPU Bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: "CPU"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            Layout.preferredWidth: 32
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            color: QsServices.Wallust.bgAlt
                            Rectangle {
                                width: parent.width * QsServices.SystemUsage.cpuUsage
                                height: parent.height
                                color: QsServices.Wallust.green
                            }
                        }
                        Text {
                            text: QsServices.SystemUsage.cpuPercentage + "%"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            Layout.preferredWidth: 36
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // RAM Bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: "RAM"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            Layout.preferredWidth: 32
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            color: QsServices.Wallust.bgAlt
                            Rectangle {
                                width: parent.width * QsServices.SystemUsage.memUsage
                                height: parent.height
                                color: QsServices.Wallust.cyan
                            }
                        }
                        Text {
                            text: QsServices.SystemUsage.memPercentage + "%"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            Layout.preferredWidth: 36
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: QsServices.Wallust.muted
                }

                // ========== MEDIA CARD ==========
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: mediaCol.implicitHeight + 20
                    color: QsServices.Wallust.bgAlt
                    visible: QsServices.Players.hasPlayer

                    ColumnLayout {
                        id: mediaCol
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: QsServices.Players.title || "No media"
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: QsServices.Players.artist || "Unknown"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "󰒮"
                                color: QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 20
                                TapHandler { onTapped: QsServices.Players.previous() }
                            }
                            Text {
                                text: QsServices.Players.status === "Playing" ? "󰏤" : "󰐊"
                                color: QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 24
                                TapHandler { onTapped: QsServices.Players.playPause() }
                            }
                            Text {
                                text: "󰒭"
                                color: QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 20
                                TapHandler { onTapped: QsServices.Players.next() }
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: QsServices.Wallust.muted
                    visible: QsServices.Notifs.history.count > 0
                }

                // ========== NOTIFICATIONS ==========
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: QsServices.Notifs.history.count > 0

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Notifications"
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Clear"
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                            TapHandler { onTapped: QsServices.Notifs.clearAll() }
                        }
                    }

                    Repeater {
                        model: QsServices.Notifs.history

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: notifCol.implicitHeight + 16
                            color: QsServices.Wallust.bgAlt

                            ColumnLayout {
                                id: notifCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 8
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: model.appName || "App"
                                        color: QsServices.Wallust.muted
                                        font.family: QsConfig.Config.fontFamily
                                        font.pixelSize: 10
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: "×"
                                        color: QsServices.Wallust.muted
                                        font.family: QsConfig.Config.fontFamily
                                        font.pixelSize: 12
                                        TapHandler { onTapped: QsServices.Notifs.dismiss(index) }
                                    }
                                }
                                Text {
                                    text: model.summary || ""
                                    color: QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: model.body || ""
                                    color: QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    visible: (model.body || "") !== ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Processes
    Process {
        id: lockProc
        command: ["loginctl", "lock-session"]
        running: false
    }
    Process {
        id: powerProc
        command: ["wlogout"]
        running: false
    }
}
