import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: popup
    implicitWidth: 500
    implicitHeight: 420
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    property var wallpapers: []
    property string wallpaperDir: `${Quickshell.env("HOME")}/.config/wallpapers`

    Component.onCompleted: scanProc.running = true

    Process {
        id: scanProc
        command: ["/bin/sh", "-c", `ls -1 "${popup.wallpaperDir}" | grep -iE '\\.(png|jpg|jpeg|gif|webp)$'`]
        running: false
        property string _output: ""
        stdout: SplitParser {
            onRead: data => {
                const name = data.trim()
                if (name) scanProc._output += name + "\n"
            }
        }
        onExited: {
            popup.wallpapers = scanProc._output.trim().split("\n").filter(n => n.length > 0)
            scanProc._output = ""
        }
    }

    Process {
        id: setWallpaperProc
        running: false
    }

    Process {
        id: wallustProc
        running: false
    }

    function setWallpaper(filename) {
        const fullPath = `${wallpaperDir}/${filename}`
        setWallpaperProc.command = ["awww", "img", fullPath]
        setWallpaperProc.running = true
        wallustTimer.wallpaperPath = fullPath
        wallustTimer.start()
    }

    Timer {
        id: wallustTimer
        property string wallpaperPath: ""
        interval: 500
        onTriggered: {
            wallustProc.command = [Quickshell.env("HOME") + "/.cargo/bin/wallust", "run", wallpaperPath]
            wallustProc.running = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text {
                text: "󰸉"
                color: QsServices.Wallust.blue
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 18
            }
            Text {
                text: "Wallpapers"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.fillWidth: true
            }
            Text {
                text: popup.wallpapers.length + " images"
                color: QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 11
            }
        }

        // Grid of thumbnails
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: wallGrid.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            GridLayout {
                id: wallGrid
                width: parent.width
                columns: 3
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: popup.wallpapers

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: wallItemArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                        border.width: wallItemArea.containsMouse ? 1 : 0
                        border.color: QsServices.Wallust.blue
                        clip: true
                        required property string modelData

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: `file://${popup.wallpaperDir}/${modelData}`
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize: Qt.size(200, 100)
                        }

                        // Filename overlay at bottom
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 18
                            color: Qt.rgba(0, 0, 0, 0.7)
                            Text {
                                anchors.centerIn: parent
                                text: modelData.length > 18 ? modelData.substring(0, 15) + "..." : modelData
                                color: "#ffffff"
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: wallItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.setWallpaper(modelData)
                        }
                    }
                }
            }
        }
    }
}
