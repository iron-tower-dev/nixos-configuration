import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    id: root
    property var barWindow

    implicitWidth: icon.implicitWidth + 8
    implicitHeight: icon.implicitHeight

    Text {
        id: icon
        anchors.centerIn: parent
        text: "󰸉"
        color: barWindow && barWindow.activePopup === "wallpaper" ? QsServices.Wallust.blue : QsServices.Wallust.orange
        font.family: QsConfig.Config.fontFamily
        font.pixelSize: QsConfig.BarConfig.iconSize
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (barWindow) barWindow.togglePopup("wallpaper")
        }
    }
}
