import QtQuick
import "../config" as QsConfig

Rectangle {
    id: root

    property bool hovered: false
    property bool pressed: false

    color: pressed ? Qt.rgba(1, 1, 1, 0.1)
         : hovered ? Qt.rgba(1, 1, 1, 0.05)
         : "transparent"
    radius: 0

    Behavior on color {
        ColorAnimation { duration: QsConfig.AppearanceConfig.animFast }
    }
}
