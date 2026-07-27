import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../config" as QsConfig
import "../../../services" as QsServices

RowLayout {
    id: root
    spacing: 4

    required property var barWindow

    // Get the monitor for this bar's screen
    readonly property var monitor: Hyprland.monitorFor(barWindow.screen)
    readonly property int activeWsId: monitor?.activeWorkspace?.id ?? -1

    Repeater {
        model: QsConfig.BarConfig.workspaceCount

        Rectangle {
            id: wsBtn
            required property int index
            property int wsId: index + 1
            property bool active: root.activeWsId === wsId
            property bool occupied: {
                for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                    const ws = Hyprland.workspaces.values[i]
                    if (ws.id === wsId) return true
                }
                return false
            }

            width: 24
            height: 24
            color: active ? QsServices.Wallust.blue : wsArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"

            Behavior on color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: wsBtn.wsId
                color: wsBtn.active ? QsServices.Wallust.bg : wsBtn.occupied ? QsServices.Wallust.fg : QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 12
                font.weight: wsBtn.active ? Font.Bold : Font.Normal
            }

            MouseArea {
                id: wsArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (Hyprland.usingLua)
                        Hyprland.dispatch('hl.dsp.focus({ workspace = "' + wsBtn.wsId + '" })')
                    else
                        Hyprland.dispatch("workspace " + wsBtn.wsId)
                }
            }
        }
    }
}
