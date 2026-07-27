import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    property var networks: []
    property bool scanning: false
    property string connectingSsid: ""
    property string passwordSsid: ""
    property bool showPassword: false

    Component.onCompleted: scan()

    function scan() {
        scanning = true
        scanProc.running = true
    }

    function connectToNetwork(ssid) {
        // Try connecting (saved credentials)
        connectProc.command = ["nmcli", "device", "wifi", "connect", ssid]
        connectingSsid = ssid
        connectProc.running = true
    }

    function connectWithPassword(ssid, password) {
        connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password]
        connectingSsid = ssid
        showPassword = false
        passwordSsid = ""
        connectProc.running = true
    }

    function disconnect() {
        disconnectProc.running = true
    }

    // Scan for networks
    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "yes"]
        running: false
        property var _networks: []

        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (!line) return
                const parts = line.split(":")
                if (parts.length < 4) return
                const active = parts[0] === "yes"
                const ssid = parts[1]
                const signal = parseInt(parts[2]) || 0
                const security = parts[3]
                if (ssid) scanProc._networks.push({ ssid, signal, security, active })
            }
        }
        onRunningChanged: { if (running) _networks = [] }
        onExited: {
            // Sort: active first, then by signal
            root.networks = _networks.sort((a, b) => {
                if (a.active !== b.active) return b.active - a.active
                return b.signal - a.signal
            }).slice(0, 10)
            root.scanning = false
        }
    }

    Process {
        id: connectProc
        running: false
        onExited: (exitCode) => {
            if (exitCode !== 0 && root.connectingSsid) {
                // Connection failed — probably needs password
                root.passwordSsid = root.connectingSsid
                root.showPassword = true
            }
            root.connectingSsid = ""
            // Refresh
            Qt.callLater(root.scan)
        }
    }

    Process {
        id: disconnectProc
        command: ["nmcli", "device", "disconnect", "wlan0"]
        running: false
        onExited: Qt.callLater(root.scan)
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: QsServices.Network.icon
                color: QsServices.Wallust.green
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 18
            }

            Text {
                text: "Networks"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            // Rescan button
            Rectangle {
                width: rescanText.implicitWidth + 16
                height: 24
                color: rescanArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    id: rescanText
                    anchors.centerIn: parent
                    text: root.scanning ? "Scanning..." : "Rescan"
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                }

                MouseArea {
                    id: rescanArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.scanning
                    onClicked: root.scan()
                }
            }
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // Network list
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(netCol.implicitHeight, 300)
            contentHeight: netCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: netCol
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.networks.length

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: netRow.implicitHeight + 12
                        color: netItemArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                        required property int index

                        Behavior on color { ColorAnimation { duration: 200 } }

                        property var net: root.networks[index]

                        RowLayout {
                            id: netRow
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 10

                            // Signal icon
                            Text {
                                text: {
                                    const s = net.signal
                                    if (s >= 75) return String.fromCodePoint(0xf0928)
                                    if (s >= 50) return String.fromCodePoint(0xf0925)
                                    if (s >= 25) return String.fromCodePoint(0xf0922)
                                    return String.fromCodePoint(0xf091f)
                                }
                                color: net.active ? QsServices.Wallust.green : QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 14
                            }

                            // SSID + security
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: net.ssid
                                    color: net.active ? QsServices.Wallust.green : QsServices.Wallust.fg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12
                                    font.weight: net.active ? Font.Medium : Font.Normal
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: net.active ? "Connected" : (net.security || "Open")
                                    color: QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                }
                            }

                            // Signal %
                            Text {
                                text: net.signal + "%"
                                color: QsServices.Wallust.muted
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 10
                            }

                            // Connect/disconnect button
                            Rectangle {
                                width: btnText.implicitWidth + 12
                                height: 22
                                color: net.active ? QsServices.Wallust.red : QsServices.Wallust.blue
                                visible: netItemArea.containsMouse || net.active
                                opacity: visible ? 1 : 0

                                Behavior on opacity { NumberAnimation { duration: 200 } }

                                Text {
                                    id: btnText
                                    anchors.centerIn: parent
                                    text: {
                                        if (root.connectingSsid === net.ssid) return "..."
                                        return net.active ? "Disconnect" : "Connect"
                                    }
                                    color: QsServices.Wallust.bg
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (net.active) root.disconnect()
                                        else root.connectToNetwork(net.ssid)
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: netItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }

                // Empty state
                Text {
                    visible: root.networks.length === 0 && !root.scanning
                    text: "No networks found"
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                    font.italic: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 12
                }
            }
        }

        // Password dialog
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.showPassword

            Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

            Text {
                text: `Password for "${root.passwordSsid}":`
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 12
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    color: QsServices.Wallust.bgAlt
                    border.width: pwInput.activeFocus ? 1 : 0
                    border.color: QsServices.Wallust.blue

                    TextInput {
                        id: pwInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        color: QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 12
                        echoMode: TextInput.Password
                        clip: true
                        onAccepted: {
                            if (text.length > 0)
                                root.connectWithPassword(root.passwordSsid, text)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Enter password..."
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            visible: !pwInput.text && !pwInput.activeFocus
                        }
                    }
                }

                Rectangle {
                    width: 60; height: 30
                    color: connectBtnArea.containsMouse ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Join"
                        color: connectBtnArea.containsMouse ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: connectBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (pwInput.text.length > 0)
                                root.connectWithPassword(root.passwordSsid, pwInput.text)
                        }
                    }
                }

                Rectangle {
                    width: 30; height: 30
                    color: cancelBtnArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: String.fromCodePoint(0xf0156)
                        color: QsServices.Wallust.muted
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: cancelBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.showPassword = false; root.passwordSsid = ""; pwInput.text = "" }
                    }
                }
            }
        }
    }
}
