import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    id: root
    property var controlCenter
    property var barWindow

    implicitWidth: icon.implicitWidth + 8
    implicitHeight: icon.implicitHeight

    Text {
        id: icon
        anchors.centerIn: parent
        text: "󰒓"
        color: controlCenter && controlCenter.shouldShow ? QsServices.Wallust.blue : QsServices.Wallust.fg
        font.family: QsConfig.Config.fontFamily
        font.pixelSize: QsConfig.BarConfig.iconSize
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (controlCenter) {
                if (barWindow) controlCenter.activeScreen = barWindow.screen
                controlCenter.shouldShow = !controlCenter.shouldShow
            }
        }
    }
}
