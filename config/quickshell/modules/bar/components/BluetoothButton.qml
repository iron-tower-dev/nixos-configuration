import QtQuick
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    implicitWidth: 28
    implicitHeight: 28
    color: area.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

    required property var barWindow

    Behavior on color { ColorAnimation { duration: 200 } }

    Text {
        anchors.centerIn: parent
        text: String.fromCodePoint(0xf00af)
        color: QsServices.Bluetooth.powered ? Qt.lighter(QsServices.Wallust.blue, 1.2) : QsServices.Wallust.muted
        font.family: QsConfig.Config.fontFamily
        font.pixelSize: QsConfig.BarConfig.iconSize

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.barWindow.togglePopup("bluetooth")
    }
}
