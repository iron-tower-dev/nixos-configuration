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
        text: String.fromCodePoint(0xf0493)
        color: QsServices.Wallust.fg
        font.family: QsConfig.Config.fontFamily
        font.pixelSize: QsConfig.BarConfig.iconSize
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.barWindow.togglePopup("quicksettings")
    }
}
