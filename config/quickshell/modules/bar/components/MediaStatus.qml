import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    visible: QsServices.Players.hasPlayer
    implicitWidth: visible ? row.implicitWidth + 12 : 0
    implicitHeight: 28
    color: area.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

    required property var barWindow

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        // Play/pause icon (clickable separately)
        Text {
            id: playIcon
            text: QsServices.Players.status === "Playing" ? String.fromCodePoint(0xf03e4) : String.fromCodePoint(0xf040a)
            color: QsServices.Wallust.green
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 14
        }

        // Track info
        Text {
            text: {
                const artist = QsServices.Players.artist
                const title = QsServices.Players.title
                if (artist && title) return `${artist} - ${title}`
                if (title) return title
                return ""
            }
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.maximumWidth: 200
        }
    }

    // Click handling: icon area = play/pause, rest = open popup
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.x < 28) {
                QsServices.Players.playPause()
            } else {
                root.barWindow.togglePopup("media")
            }
        }
    }
}
