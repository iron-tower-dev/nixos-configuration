import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    id: root
    property var barWindow

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    visible: QsServices.Players.hasPlayer

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: QsServices.Players.icon
            color: QsServices.Players.status === "Playing" ? QsServices.Wallust.green : QsServices.Wallust.yellow
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.BarConfig.iconSize
        }

        Text {
            text: {
                if (!QsServices.Players.hasPlayer) return ""
                const parts = []
                if (QsServices.Players.artist) parts.push(QsServices.Players.artist)
                if (QsServices.Players.title) parts.push(QsServices.Players.title)
                return parts.join(" – ")
            }
            color: QsServices.Wallust.fg
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
            elide: Text.ElideRight
            Layout.maximumWidth: 250
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.barWindow) root.barWindow.togglePopup("media")
        }
    }
}
