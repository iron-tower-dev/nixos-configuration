import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: Math.min(col.implicitHeight + 32, 500)
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    property var wallpapers: []
    property string currentWallpaper: ""

    Component.onCompleted: listProc.running = true

    // --- List wallpapers ---
    Process {
        id: listProc
        command: ["/bin/sh", "-c", "ls " + Quickshell.env("HOME") + "/.config/wallpapers/ | grep -iE '\\.(png|jpg|jpeg|gif|webp|bmp)$'"]
        running: false
        property string _output: ""
        stdout: SplitParser {
            onRead: data => {
                const name = data.trim()
                if (name) listProc._output += name + "\n"
            }
        }
        onExited: {
            root.wallpapers = listProc._output.trim().split("\n").filter(f => f.length > 0)
            listProc._output = ""
        }
    }

    // --- Apply wallpaper ---
    Process {
        id: swwwProc
        running: false
    }

    Process {
        id: themeSwitchProc
        running: false
    }

    function applyWallpaper(filename) {
        const path = `${Quickshell.env("HOME")}/.config/wallpapers/${filename}`
        currentWallpaper = filename
        swwwProc.command = ["swww", "img", path]
        swwwProc.running = true
        themeSwitchProc.command = ["theme-switch", "--wallpaper", path]
        themeSwitchProc.running = true
    }

    // --- Layout ---
    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text {
                text: "󰸉"
                color: QsServices.Wallust.orange
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 18
            }
            Text {
                text: "Wallpaper"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.fillWidth: true
            }
            Text {
                text: root.wallpapers.length + " images"
                color: QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 11
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: QsServices.Wallust.muted
        }

        // Wallpaper list (scrollable)
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: Math.min(root.wallpapers.length * 36, 360)
            contentHeight: wpColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: wpColumn
                width: parent.width
                spacing: 2

                Repeater {
                    model: root.wallpapers.length

                    Rectangle {
                        Layout.fillWidth: true
                        height: 34
                        required property int index
                        color: {
                            const name = root.wallpapers[index]
                            if (name === root.currentWallpaper) return Qt.rgba(QsServices.Wallust.blue.r, QsServices.Wallust.blue.g, QsServices.Wallust.blue.b, 0.2)
                            return wpItemArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: root.wallpapers[index] === root.currentWallpaper ? "󰸉" : "󰋩"
                                color: root.wallpapers[index] === root.currentWallpaper ? QsServices.Wallust.blue : QsServices.Wallust.muted
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 14
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.wallpapers[index]
                                color: root.wallpapers[index] === root.currentWallpaper ? QsServices.Wallust.blue : QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 12
                                elide: Text.ElideMiddle
                            }
                        }

                        MouseArea {
                            id: wpItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyWallpaper(root.wallpapers[index])
                        }
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: QsServices.Wallust.muted
        }

        // Current wallpaper display
        Text {
            text: root.currentWallpaper ? `Current: ${root.currentWallpaper}` : "No wallpaper selected"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            elide: Text.ElideMiddle
            Layout.fillWidth: true
        }
    }
}
