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
        text: QsServices.Audio.icon
        color: QsServices.Audio.muted ? QsServices.Wallust.muted : QsServices.Wallust.blue
        font.family: QsConfig.Config.fontFamily
        font.pixelSize: QsConfig.BarConfig.iconSize
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                QsServices.Audio.toggleMute()
            else
                root.barWindow.togglePopup("audio")
        }
        onWheel: event => {
            const delta = event.angleDelta.y > 0 ? 0.05 : -0.05
            QsServices.Audio.setVolume(QsServices.Audio.volume + delta)
        }
    }
}
