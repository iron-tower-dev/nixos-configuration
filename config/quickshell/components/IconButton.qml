import QtQuick
import "../config" as QsConfig
import "../services" as QsServices

Item {
    id: root

    property string icon: ""
    property color iconColor: QsServices.Wallust.fg
    property int iconSize: QsConfig.BarConfig.iconSize

    signal clicked()

    implicitWidth: Math.max(iconSize + 8, 28)
    implicitHeight: Math.max(iconSize + 8, 28)

    StateLayer {
        anchors.fill: parent
        hovered: hoverHandler.hovered
        pressed: tapHandler.pressed
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.family: QsConfig.Config.fontFamily
        font.pixelSize: root.iconSize
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        id: tapHandler
        onTapped: root.clicked()
    }
}
