import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices

Item {
    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    visible: SystemTray.items.count > 0

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            Item {
                required property SystemTrayItem modelData
                implicitWidth: 18
                implicitHeight: 18
                Layout.alignment: Qt.AlignVCenter

                Image {
                    anchors.fill: parent
                    source: modelData.icon ?? ""
                    sourceSize: Qt.size(18, 18)
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: event => {
                        if (event.button === Qt.RightButton)
                            modelData.activate()
                        else
                            modelData.activate()
                    }
                }
            }
        }
    }
}
