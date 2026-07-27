import QtQuick
import Qt5Compat.GraphicalEffects
import "../config" as QsConfig

Item {
    id: root

    property int elevation: QsConfig.AppearanceConfig.elevationLow
    property alias content: contentItem.data
    property alias color: contentItem.color

    Rectangle {
        id: contentItem
        anchors.fill: parent
        radius: 0
        color: "transparent"

        layer.enabled: root.elevation > 0
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: root.elevation
            radius: root.elevation * 2
            samples: root.elevation * 4 + 1
            color: Qt.rgba(0, 0, 0, 0.3)
        }
    }
}
