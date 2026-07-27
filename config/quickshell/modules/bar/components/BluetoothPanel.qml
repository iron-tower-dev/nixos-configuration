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
                text: "󰂯"
                color: QsServices.Wallust.blue
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
                color: QsServices.Bluetooth.powered ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                Rectangle {
                    width: 16; height: 16; y: 3
                    x: QsServices.Bluetooth.powered ? parent.width - width - 3 : 3
                    color: QsServices.Wallust.fg
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
                MouseArea { anchors.fill: parent; onClicked: QsServices.Bluetooth.togglePower() }
            }
        }

        // Status
        Text {
            text: QsServices.Bluetooth.connected ? "Connected: " + QsServices.Bluetooth.connectedDevice : (QsServices.Bluetooth.powered ? "No devices connected" : "Bluetooth disabled")
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
        }

        // Settings button
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: settingsArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "󰒓"; color: QsServices.Wallust.muted; font.family: QsConfig.Config.fontFamily; font.pixelSize: 14 }
                Text { text: "Bluetooth Settings"; color: QsServices.Wallust.muted; font.family: QsConfig.Config.fontFamily; font.pixelSize: 12 }
            }
            MouseArea {
                id: settingsArea
                anchors.fill: parent
                hoverEnabled: true
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
