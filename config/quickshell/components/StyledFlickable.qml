import QtQuick
import QtQuick.Controls
import "../services" as QsServices

Flickable {
    id: root

    clip: true

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded

        contentItem: Rectangle {
            implicitWidth: 4
            radius: 0
            color: QsServices.Wallust.muted
            opacity: parent.active ? 0.8 : 0.4

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
