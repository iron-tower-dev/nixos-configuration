import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 360
    implicitHeight: Math.min(col.implicitHeight + 32, 500)
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Notifications"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            Rectangle {
                width: clearLabel.implicitWidth + 16
                height: 24
                color: clearArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                visible: QsServices.Notifs.history.count > 0
                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    id: clearLabel
                    anchors.centerIn: parent
                    text: "Clear all"
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                }

                MouseArea {
                    id: clearArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Notifs.clearAll()
                }
            }
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // Notification list
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: Math.min(notifCol.implicitHeight, 400)
            contentHeight: notifCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: notifCol
                width: parent.width
                spacing: 6

                Repeater {
                    model: QsServices.Notifs.history

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: notifContent.implicitHeight + 16
                        color: notifHover.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }

                        ColumnLayout {
                            id: notifContent
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: model.appName || "Unknown"
                                    color: QsServices.Wallust.blue
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: String.fromCodePoint(0xf0156)
                                    color: notifHover.containsMouse ? QsServices.Wallust.red : "transparent"
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 12

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: QsServices.Notifs.dismiss(index)
                                    }
                                }
                            }

                            Text {
                                text: model.summary || ""
                                color: QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                visible: text !== ""
                            }

                            Text {
                                text: model.body || ""
                                color: QsServices.Wallust.muted
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }

                        MouseArea {
                            id: notifHover
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            visible: QsServices.Notifs.history.count === 0
            text: "No notifications"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 12
            font.italic: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
        }
    }

    Component.onCompleted: QsServices.Notifs.markAllRead()
}
