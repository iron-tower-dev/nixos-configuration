import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: popup
    implicitWidth: 280
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

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: QsConfig.AppearanceConfig.spacingSm

            Text {
                text: QsServices.Audio.icon
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: QsConfig.AppearanceConfig.fontSizeLg
            }

            Text {
                text: "Volume"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: QsConfig.AppearanceConfig.fontSizeMd
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            Text {
                text: Math.round(QsServices.Audio.volume * 100) + "%"
                color: QsServices.Audio.muted ? QsServices.Wallust.muted : QsServices.Wallust.blue
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: QsConfig.AppearanceConfig.fontSizeMd
                font.weight: Font.Bold
            }
        }

        // Volume slider
        Item {
            Layout.fillWidth: true
            height: 24

            // Track background
            Rectangle {
                id: sliderTrack
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: 0
                color: QsServices.Wallust.bgAlt

                // Fill
                Rectangle {
                    width: parent.width * QsServices.Audio.volume
                    height: parent.height
                    radius: 0
                    color: QsServices.Audio.muted ? QsServices.Wallust.muted : QsServices.Wallust.blue
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed: mouse => {
                    const val = Math.max(0, Math.min(1, mouse.x / width))
                    QsServices.Audio.setVolume(val)
                }
                onPositionChanged: mouse => {
                    if (pressed) {
                        const val = Math.max(0, Math.min(1, mouse.x / width))
                        QsServices.Audio.setVolume(val)
                    }
                }
            }
        }

        // Mute toggle
        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: 0
            color: muteArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: QsConfig.AppearanceConfig.paddingSm
                anchors.rightMargin: QsConfig.AppearanceConfig.paddingSm
                spacing: QsConfig.AppearanceConfig.spacingSm

                Text {
                    text: QsServices.Audio.muted ? "󰖁" : "󰕾"
                    color: QsServices.Audio.muted ? QsServices.Wallust.red : QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeMd
                }

                Text {
                    text: QsServices.Audio.muted ? "Unmute" : "Mute"
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                id: muteArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: QsServices.Audio.toggleMute()
            }
        }
    }
}
