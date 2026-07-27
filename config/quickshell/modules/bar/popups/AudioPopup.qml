import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    // Filter nodes into sinks and sources
    readonly property var sinks: {
        const result = []
        for (let i = 0; i < Pipewire.nodes.values.length; i++) {
            const node = Pipewire.nodes.values[i]
            if (node.isSink && !node.isStream && node.audio)
                result.push(node)
        }
        return result
    }

    readonly property var sources: {
        const result = []
        for (let i = 0; i < Pipewire.nodes.values.length; i++) {
            const node = Pipewire.nodes.values[i]
            if (!node.isSink && !node.isStream && node.audio)
                result.push(node)
        }
        return result
    }

    // Track all relevant nodes
    PwObjectTracker {
        objects: [...root.sinks, ...root.sources]
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: String.fromCodePoint(0xf057e)
                color: QsServices.Wallust.blue
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 18
            }

            Text {
                text: "Audio Devices"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            Text {
                text: QsServices.Audio.muted ? "Muted" : `${Math.round(QsServices.Audio.volume * 100)}%`
                color: QsServices.Audio.muted ? QsServices.Wallust.red : QsServices.Wallust.blue
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // Output section
        Text {
            text: "Output"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
        }

        // Sink list
        Repeater {
            model: root.sinks.length

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                required property int index
                property var node: root.sinks[index]
                property bool isDefault: node === Pipewire.defaultAudioSink

                // Device name row (click to select)
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: sinkNameArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Rectangle {
                            width: 8; height: 8
                            color: isDefault ? QsServices.Wallust.blue : QsServices.Wallust.muted
                            opacity: isDefault ? 1 : 0.3
                        }

                        Text {
                            text: node.description || node.name || "Unknown"
                            color: isDefault ? QsServices.Wallust.blue : QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            font.weight: isDefault ? Font.Medium : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: node.audio ? `${Math.round(node.audio.volume * 100)}%` : ""
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        id: sinkNameArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Pipewire.preferredDefaultAudioSink = node
                    }
                }

                // Volume slider
                Item {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24
                    Layout.rightMargin: 8
                    height: 12

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 4
                        color: QsServices.Wallust.bgAlt

                        Rectangle {
                            width: parent.width * (node.audio?.volume ?? 0)
                            height: parent.height
                            color: isDefault ? QsServices.Wallust.blue : QsServices.Wallust.muted

                            Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse => {
                            if (node.audio) node.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                        }
                        onPositionChanged: mouse => {
                            if (pressed && node.audio)
                                node.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                        }
                    }
                }
            }
        }

        // Empty output state
        Text {
            visible: root.sinks.length === 0
            text: "No output devices found"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.italic: true
        }

        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted; opacity: 0.3 }

        // Input section
        Text {
            text: "Input"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
        }

        Repeater {
            model: root.sources.length

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                required property int index
                property var node: root.sources[index]
                property bool isDefault: node === Pipewire.defaultAudioSource

                // Device name row (click to select)
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: srcNameArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Rectangle {
                            width: 8; height: 8
                            color: isDefault ? QsServices.Wallust.cyan : QsServices.Wallust.muted
                            opacity: isDefault ? 1 : 0.3
                        }

                        Text {
                            text: node.description || node.name || "Unknown"
                            color: isDefault ? QsServices.Wallust.cyan : QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            font.weight: isDefault ? Font.Medium : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: node.audio ? `${Math.round(node.audio.volume * 100)}%` : ""
                            color: QsServices.Wallust.muted
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        id: srcNameArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Pipewire.preferredDefaultAudioSource = node
                    }
                }

                // Volume slider
                Item {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24
                    Layout.rightMargin: 8
                    height: 12

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 4
                        color: QsServices.Wallust.bgAlt

                        Rectangle {
                            width: parent.width * (node.audio?.volume ?? 0)
                            height: parent.height
                            color: isDefault ? QsServices.Wallust.cyan : QsServices.Wallust.muted

                            Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse => {
                            if (node.audio) node.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                        }
                        onPositionChanged: mouse => {
                            if (pressed && node.audio)
                                node.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                        }
                    }
                }
            }
        }

        // Empty input state
        Text {
            visible: root.sources.length === 0
            text: "No input devices found"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.italic: true
        }
    }
}
