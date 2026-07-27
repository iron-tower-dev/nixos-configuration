import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // Track the display device (combined battery)
    readonly property var battery: UPower.displayDevice
    readonly property real level: battery?.percentage ?? 0
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
    readonly property bool hasBattery: (battery?.isPresent ?? false) && (battery?.type === UPowerDeviceType.Battery)

    visible: hasBattery

    readonly property string icon: {
        if (charging) return "󰂄"
        if (level >= 90) return "󰁹"
        if (level >= 70) return "󰂁"
        if (level >= 50) return "󰁾"
        if (level >= 30) return "󰁼"
        if (level >= 10) return "󰁺"
        return "󰂎"
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: icon
            color: {
                if (charging) return QsServices.Wallust.green
                if (level <= 20) return QsServices.Wallust.red
                return QsServices.Wallust.fg
            }
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.BarConfig.iconSize
        }

        Text {
            text: Math.round(level) + "%"
            color: QsServices.Wallust.fg
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: QsConfig.AppearanceConfig.fontSizeSm
        }
    }
}
