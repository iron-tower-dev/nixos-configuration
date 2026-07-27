import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    visible: QsServices.Brightness.available

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: QsServices.Brightness.icon
            color: QsServices.Wallust.fg
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.BarConfig.iconSize
        }

        Text {
            text: QsServices.Brightness.percentage + "%"
            color: QsServices.Wallust.fg
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: event => {
            const delta = event.angleDelta.y > 0 ? 0.05 : -0.05
            QsServices.Brightness.setLevel(QsServices.Brightness.level + delta)
        }
    }
}
