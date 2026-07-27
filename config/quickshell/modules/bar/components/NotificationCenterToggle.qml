import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    id: root
    property var barWindow

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: QsServices.Notifs.unreadCount > 0 ? "󰂚" : "󰂜"
            color: QsServices.Notifs.doNotDisturb ? QsServices.Wallust.muted
                 : QsServices.Notifs.unreadCount > 0 ? QsServices.Wallust.blue
                 : QsServices.Wallust.fg
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.BarConfig.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        // Unread badge
        Rectangle {
            visible: QsServices.Notifs.unreadCount > 0
            width: badgeText.implicitWidth + 6
            height: 14
            radius: 0
            color: QsServices.Wallust.blue
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: QsServices.Notifs.unreadCount > 99 ? "99+" : QsServices.Notifs.unreadCount
                color: QsServices.Wallust.bg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.barWindow) root.barWindow.togglePopup("notifications")
            QsServices.Notifs.markAllRead()
        }
    }
}
