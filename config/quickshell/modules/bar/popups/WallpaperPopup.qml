import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 420
    implicitHeight: 380
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    property var wallpapers: []
    property string wallpaperDir: `${Quickshell.env("HOME")}/.config/wallpapers`

    Component.onCompleted: scanProc.running = true

    Process {
        id: scanProc
        command: ["/bin/sh", "-c", `ls -1 "${root.wallpaperDir}" | grep -iE '\\.(png|jpg|jpeg|gif|webp)$' | sort`]
        running: false
        property string _output: ""
        stdout: SplitParser {
            onRead: data => {
                const name = data.trim()
                if (name) scanProc._output += name + "\n"
            }
        }
        onExited: {
            root.wallpapers = scanProc._output.trim().split("\n").filter(n => n.length > 0)
            scanProc._output = ""
        }
    }

    Process { id: awwwProc; running: false }
    Process { id: wallustProc; running: false }

    function applyWallpaper(filename) {
        const fullPath = `${wallpaperDir}/${filename}`
        awwwProc.command = ["awww", "img", fullPath]
        awwwProc.running = true
        wallustTimer.path = fullPath
        wallustTimer.start()
    }

    Timer {
        id: wallustTimer
        property string path: ""
        interval: 500
        onTriggered: {
            wallustProc.command = [Quickshell.env("HOME") + "/.cargo/bin/wallust", "run", path]
            wallustProc.running = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: String.fromCodePoint(0xf0e09)
                color: QsServices.Wallust.blue
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 16
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
                text: root.wallpapers.length + " files"
                color: QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 11
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // Thumbnail grid
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: grid.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            GridLayout {
                id: grid
                width: parent.width
                columns: 3
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: root.wallpapers

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: "transparent"
                        border.width: imgArea.containsMouse ? 2 : 0
                        border.color: QsServices.Wallust.blue
                        clip: true

                        required property string modelData

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: `file://${root.wallpaperDir}/${modelData}`
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize: Qt.size(180, 100)
                        }

                        // Name overlay
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 16
                            color: Qt.rgba(0, 0, 0, 0.75)

                            Text {
                                anchors.centerIn: parent
                                text: modelData.length > 20 ? modelData.substring(0, 17) + "..." : modelData
                                color: "#fff"
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: imgArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyWallpaper(modelData)
                        }
                    }
                }
            }
        }
    }
}
