import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // Track info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: QsServices.Players.title || "No Track"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 15
                font.weight: Font.Bold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: QsServices.Players.artist || "Unknown Artist"
                color: QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Progress indicator
        Rectangle {
            Layout.fillWidth: true
            height: 4
            color: QsServices.Wallust.bgAlt

            Rectangle {
                width: parent.width * (QsServices.Players.status === "Playing" ? 0.6 : 0.3)
                height: parent.height
                color: QsServices.Wallust.green

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            }
        }

        // Controls
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            // Previous
            Rectangle {
                width: 36; height: 36
                color: prevArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xf04ae)
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 18
                }

                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Players.previous()
                }
            }

            // Play/Pause
            Rectangle {
                width: 44; height: 44
                color: QsServices.Wallust.green

                Text {
                    anchors.centerIn: parent
                    text: QsServices.Players.status === "Playing" ? String.fromCodePoint(0xf03e4) : String.fromCodePoint(0xf040a)
                    color: QsServices.Wallust.bg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 22
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Players.playPause()
                }
            }

            // Next
            Rectangle {
                width: 36; height: 36
                color: nextArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xf04ad)
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 18
                }

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Players.next()
                }
            }
        }

        // Status
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: QsServices.Players.status
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
        }
    }
}
