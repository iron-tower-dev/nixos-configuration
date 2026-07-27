import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices
import Quickshell.Io

Rectangle {
    id: panel
    implicitWidth: 320
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: QsServices.Network.icon
                color: QsServices.Network.connected ? QsServices.Wallust.blue : QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 18
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Network"
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }
                Text {
                    text: QsServices.Network.connected ? QsServices.Network.ssid : "Disconnected"
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                }
            }
        }

        // Signal strength bar (only for WiFi)
        RowLayout {
            Layout.fillWidth: true
            visible: QsServices.Network.type === "wifi"
            spacing: 8
            Text { text: "Signal"; color: QsServices.Wallust.muted; font.family: QsConfig.Config.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 40 }
            Rectangle {
                Layout.fillWidth: true
                height: 6
                color: QsServices.Wallust.bgAlt
                Rectangle {
                    width: parent.width * QsServices.Network.strength / 100
                    height: parent.height
                    color: QsServices.Wallust.blue
                }
            }
            Text { text: QsServices.Network.strength + "%"; color: QsServices.Wallust.muted; font.family: QsConfig.Config.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 36; horizontalAlignment: Text.AlignRight }
        }

        // Type
        Text {
            text: "Type: " + QsServices.Network.type
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
        }

        // Settings
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: netSettingsArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "󰒓"; color: QsServices.Wallust.muted; font.family: QsConfig.Config.fontFamily; font.pixelSize: 14 }
                Text { text: "Network Settings"; color: QsServices.Wallust.muted; font.family: QsConfig.Config.fontFamily; font.pixelSize: 12 }
            }
            MouseArea {
                id: netSettingsArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: netSettingsProc.running = true
            }
        }
    }

    Process {
        id: netSettingsProc
        command: ["nm-connection-editor"]
        running: false
    }
}
