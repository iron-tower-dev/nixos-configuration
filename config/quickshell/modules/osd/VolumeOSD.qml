import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../config" as QsConfig
import "../../services" as QsServices

Scope {
    id: osdRoot

    property real _lastVolume: -1
    property bool _visible: false

    Connections {
        target: QsServices.Audio
        function onVolumeChanged() {
            if (osdRoot._lastVolume >= 0) {
                osdRoot._visible = true
                hideTimer.restart()
            }
            osdRoot._lastVolume = QsServices.Audio.volume
        }
        function onMutedChanged() {
            osdRoot._visible = true
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: QsConfig.Config.osd.volumeTimeoutMs ?? 2000
        onTriggered: osdRoot._visible = false
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            property var modelData
            screen: modelData

            visible: osdRoot._visible
            anchors {
                bottom: true
            }

            WlrLayershell.namespace: "quickshell-osd"
            exclusionMode: ExclusionMode.Ignore

            implicitWidth: 300
            implicitHeight: 50
            color: "transparent"

            anchors.left: false
            anchors.right: false

            Item {
                anchors.fill: parent

                Rectangle {
                    anchors.centerIn: parent
                    width: 280
                    height: 40
                    radius: 0
                    color: QsServices.Wallust.bg
                    border.width: 1
                    border.color: QsServices.Wallust.muted

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: QsServices.Audio.icon
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 160
                            height: 4
                            radius: 0
                            color: QsServices.Wallust.muted
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: parent.width * QsServices.Audio.volume
                                height: parent.height
                                radius: 0
                                color: QsServices.Wallust.blue

                                Behavior on width {
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }

                        Text {
                            text: Math.round(QsServices.Audio.volume * 100) + "%"
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32
                        }
                    }
                }
            }
        }
    }
}
