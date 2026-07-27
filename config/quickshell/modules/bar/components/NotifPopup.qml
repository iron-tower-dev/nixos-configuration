import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: popup
    implicitWidth: 380
    implicitHeight: Math.min(col.implicitHeight + 2 * QsConfig.AppearanceConfig.paddingLg, 400)
    color: QsServices.Wallust.bg
    radius: 0
    border.width: 1
    border.color: QsServices.Wallust.muted
    clip: true

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: QsConfig.AppearanceConfig.paddingLg
        spacing: QsConfig.AppearanceConfig.spacingMd

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: QsConfig.AppearanceConfig.spacingSm

            Text {
                text: "Notifications"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: QsConfig.AppearanceConfig.fontSizeMd
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            // DND toggle
            Rectangle {
                width: dndRow.implicitWidth + 12
                height: 24
                radius: 0
                color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.red : QsServices.Wallust.bgAlt

                Row {
                    id: dndRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: QsServices.Notifs.doNotDisturb ? "󰂛" : "󰂚"
                        color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: QsConfig.AppearanceConfig.fontSizeXs
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "DND"
                        color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.bg : QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: QsConfig.AppearanceConfig.fontSizeXs
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: QsServices.Notifs.toggleDND()
                }
            }

            // Clear all
            Rectangle {
                width: clearText.implicitWidth + 12
                height: 24
                radius: 0
                color: clearArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "Clear"
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeXs
                }

                MouseArea {
                    id: clearArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: QsServices.Notifs.clearAll()
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: QsServices.Wallust.muted
        }

        // Notification list
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 40
            Layout.maximumHeight: 300
            contentHeight: notifCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: notifCol
                width: parent.width
                spacing: QsConfig.AppearanceConfig.spacingSm

                // Empty state
                Text {
                    visible: QsServices.Notifs.history.count === 0
                    text: "No notifications"
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: QsConfig.AppearanceConfig.spacingLg
                }

                Repeater {
                    model: QsServices.Notifs.history

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: notifItemCol.implicitHeight + 2 * QsConfig.AppearanceConfig.paddingSm
                        radius: 0
                        color: notifItemArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

                        ColumnLayout {
                            id: notifItemCol
                            anchors.fill: parent
                            anchors.margins: QsConfig.AppearanceConfig.paddingSm
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: model.appName || "Unknown"
                                    color: QsServices.Wallust.blue
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeXs
                                    font.weight: Font.Bold
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: {
                                        const d = new Date(model.timestamp)
                                        return Qt.formatDateTime(d, "hh:mm")
                                    }
                                    color: QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeXs
                                }
                            }

                            Text {
                                text: model.summary || ""
                                color: QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text !== ""
                            }

                            Text {
                                text: model.body || ""
                                color: QsServices.Wallust.muted
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: QsConfig.AppearanceConfig.fontSizeXs
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                visible: text !== ""
                            }
                        }

                        MouseArea {
                            id: notifItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.RightButton
                            onClicked: QsServices.Notifs.dismiss(index)
                        }
                    }
                }
            }
        }
    }
}
