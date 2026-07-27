import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 320
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    property var devices: []

    Component.onCompleted: scanDevices()

    function scanDevices() {
        pairedProc.running = true
    }

    function connectDevice(mac) {
        connectProc.command = ["bluetoothctl", "connect", mac]
        connectProc.running = true
    }

    function disconnectDevice(mac) {
        disconnectProc.command = ["bluetoothctl", "disconnect", mac]
        disconnectProc.running = true
    }

    // Scan paired devices
    Process {
        id: pairedProc
        command: ["bluetoothctl", "devices", "Paired"]
        running: false
        property var _devs: []

        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (!line.startsWith("Device ")) return
                const rest = line.substring(7)
                const spaceIdx = rest.indexOf(" ")
                if (spaceIdx < 0) return
                pairedProc._devs.push({
                    mac: rest.substring(0, spaceIdx),
                    name: rest.substring(spaceIdx + 1),
                    connected: false
                })
            }
        }
        onRunningChanged: { if (running) _devs = [] }
        onExited: {
            // Now check which are connected
            root.devices = _devs
            connectedProc.running = true
        }
    }

    // Check connected devices
    Process {
        id: connectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        running: false
        property var _connected: []

        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (!line.startsWith("Device ")) return
                const mac = line.substring(7, line.indexOf(" ", 7))
                connectedProc._connected.push(mac)
            }
        }
        onRunningChanged: { if (running) _connected = [] }
        onExited: {
            const updated = root.devices.map(d => ({
                mac: d.mac,
                name: d.name,
                connected: connectedProc._connected.includes(d.mac)
            }))
            // Sort: connected first
            root.devices = updated.sort((a, b) => b.connected - a.connected)
        }
    }

    Process {
        id: connectProc
        running: false
        onExited: Qt.callLater(root.scanDevices)
    }

    Process {
        id: disconnectProc
        running: false
        onExited: Qt.callLater(root.scanDevices)
    }

    // Auto-refresh every 5s when visible
    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: root.scanDevices()
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: String.fromCodePoint(0xf00af)
                color: Qt.lighter(QsServices.Wallust.blue, 1.2)
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 18
            }

            Text {
                text: "Bluetooth"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            // Power toggle
            Rectangle {
                width: 40; height: 22
                color: QsServices.Bluetooth.powered ? Qt.lighter(QsServices.Wallust.blue, 1.2) : QsServices.Wallust.muted
                Behavior on color { ColorAnimation { duration: 200 } }

                Rectangle {
                    width: 16; height: 16; y: 3
                    x: QsServices.Bluetooth.powered ? parent.width - width - 3 : 3
                    color: QsServices.Bluetooth.powered ? QsServices.Wallust.bg : QsServices.Wallust.fg
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Bluetooth.togglePower()
                }
            }
        }

        // Status
        Text {
            text: {
                if (!QsServices.Bluetooth.powered) return "Bluetooth is off"
                const connected = root.devices.filter(d => d.connected)
                if (connected.length > 0) return `Connected to ${connected[0].name}`
                return `${root.devices.length} paired device${root.devices.length !== 1 ? "s" : ""}`
            }
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // Device list
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            visible: QsServices.Bluetooth.powered

            Repeater {
                model: root.devices.length

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: devArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                    required property int index

                    Behavior on color { ColorAnimation { duration: 200 } }

                    property var dev: root.devices[index]

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10

                        // Device icon
                        Text {
                            text: dev.connected ? String.fromCodePoint(0xf00b1) : String.fromCodePoint(0xf00af)
                            color: dev.connected ? Qt.lighter(QsServices.Wallust.blue, 1.2) : QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 14
                        }

                        // Name
                        Text {
                            text: dev.name
                            color: dev.connected ? QsServices.Wallust.fg : QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            font.weight: dev.connected ? Font.Medium : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Connect/Disconnect button
                        Rectangle {
                            width: btnLabel.implicitWidth + 14
                            height: 22
                            color: dev.connected ? QsServices.Wallust.red : Qt.lighter(QsServices.Wallust.blue, 1.2)
                            visible: devArea.containsMouse || dev.connected

                            Text {
                                id: btnLabel
                                anchors.centerIn: parent
                                text: dev.connected ? "Disconnect" : "Connect"
                                color: QsServices.Wallust.bg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 10
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (dev.connected)
                                        root.disconnectDevice(dev.mac)
                                    else
                                        root.connectDevice(dev.mac)
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: devArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }

        // Empty/off states
        Text {
            visible: !QsServices.Bluetooth.powered
            text: "Turn on Bluetooth to see devices"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.italic: true
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            visible: QsServices.Bluetooth.powered && root.devices.length === 0
            text: "No paired devices"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.italic: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // Settings button
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: settingsArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
            Behavior on color { ColorAnimation { duration: 200 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: String.fromCodePoint(0xf0493)
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 14
                }

                Text {
                    text: "Bluetooth settings"
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                }
            }

            MouseArea {
                id: settingsArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: btSettingsProc.running = true
            }
        }
    }

    Process {
        id: btSettingsProc
        command: ["blueman-manager"]
        running: false
    }
}
