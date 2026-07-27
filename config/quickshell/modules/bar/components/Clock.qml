import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    required property var barWindow

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: QsServices.Time.timeStr
            color: QsServices.Wallust.purple
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        Text {
            text: QsServices.Time.dateStr
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 12
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.barWindow.togglePopup("calendar")
    }
}
