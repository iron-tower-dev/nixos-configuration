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
        text: QsServices.Notifs.doNotDisturb ? String.fromCodePoint(0xf009c) : String.fromCodePoint(0xf009a)
        color: QsServices.Notifs.unreadCount > 0 ? QsServices.Wallust.blue : QsServices.Wallust.fg
        font.family: QsConfig.Config.fontFamily
        font.pixelSize: QsConfig.BarConfig.iconSize
    }

    // Unread dot indicator
    Rectangle {
        visible: QsServices.Notifs.unreadCount > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 4
        width: 6; height: 6
        color: QsServices.Wallust.red
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.barWindow.togglePopup("notifications")
    }
}
