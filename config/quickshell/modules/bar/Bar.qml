import QtQuick
import QtQuick.Layouts
import "../../config" as QsConfig
import "../../services" as QsServices
import "components"

Item {
    id: root

    required property var barWindow

    // Left section
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: QsConfig.BarConfig.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Workspaces {
            barWindow: root.barWindow
        }
    }

    // Center section (absolute center)
    Clock {
        anchors.centerIn: parent
        barWindow: root.barWindow
    }

    // Right section
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: QsConfig.BarConfig.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: QsConfig.BarConfig.spacing

        MediaStatus {
            barWindow: root.barWindow
        }

        Separator { visible: QsServices.Players.hasPlayer }

        Volume {
            barWindow: root.barWindow
        }

        Network {
            barWindow: root.barWindow
        }

        BluetoothButton {
            barWindow: root.barWindow
        }

        Separator {}

        WallpaperButton {
            barWindow: root.barWindow
        }

        NotifButton {
            barWindow: root.barWindow
        }

        QuickSettingsButton {
            barWindow: root.barWindow
        }
    }
}
