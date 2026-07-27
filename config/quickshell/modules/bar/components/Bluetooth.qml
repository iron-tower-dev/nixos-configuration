import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property var barWindow

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: QsServices.Bluetooth.icon
            color: QsServices.Bluetooth.powered ? QsServices.Wallust.cyan : QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.BarConfig.iconSize
        }

        Text {
            text: QsServices.Bluetooth.connectedDevice
            color: QsServices.Wallust.fg
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
            visible: QsServices.Bluetooth.connected
            elide: Text.ElideRight
            Layout.maximumWidth: 80
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                if (root.barWindow) root.barWindow.togglePopup("bluetooth")
            } else {
                QsServices.Bluetooth.togglePower()
            }
        }
    }
}
