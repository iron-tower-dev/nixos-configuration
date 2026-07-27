import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: popup
    implicitWidth: 300
    implicitHeight: col.implicitHeight + 2 * QsConfig.AppearanceConfig.paddingLg
    color: QsServices.Wallust.bg
    radius: 0
    border.width: 1
    border.color: QsServices.Wallust.muted

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: QsConfig.AppearanceConfig.paddingLg
        spacing: QsConfig.AppearanceConfig.spacingMd

        // Title and artist
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: QsServices.Players.title || "No Track"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: QsConfig.AppearanceConfig.fontSizeMd
                font.weight: Font.Bold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: QsServices.Players.artist || "Unknown Artist"
                color: QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Status indicator
        Rectangle {
            Layout.fillWidth: true
            height: 4
            radius: 0
            color: QsServices.Wallust.bgAlt

            Rectangle {
                width: parent.width * (QsServices.Players.status === "Playing" ? 1.0 : 0.5)
                height: parent.height
                radius: 0
                color: QsServices.Players.status === "Playing" ? QsServices.Wallust.green
                     : QsServices.Players.status === "Paused" ? QsServices.Wallust.yellow
                     : QsServices.Wallust.muted

                Behavior on width {
                    NumberAnimation { duration: QsConfig.AppearanceConfig.animNormal }
                }
            }
        }

        // Controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: QsConfig.AppearanceConfig.spacingLg

            // Previous
            Rectangle {
                width: 36; height: 36
                radius: 0
                color: prevArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeXl
                }

                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: QsServices.Players.previous()
                }
            }

            // Play/Pause
            Rectangle {
                width: 44; height: 44
                radius: 0
                color: playArea.containsMouse ? QsServices.Wallust.bgAlt : QsServices.Wallust.blue

                Text {
                    anchors.centerIn: parent
                    text: QsServices.Players.status === "Playing" ? "󰏤" : "󰐊"
                    color: QsServices.Wallust.bg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeXl
                }

                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: QsServices.Players.playPause()
                }
            }

            // Next
            Rectangle {
                width: 36; height: 36
                radius: 0
                color: nextArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeXl
                }

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: QsServices.Players.next()
                }
            }
        }

        // Status text
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: QsServices.Players.status
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.AppearanceConfig.fontSizeXs
        }
    }
}
