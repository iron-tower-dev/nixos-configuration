import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../config" as QsConfig
import "../../services" as QsServices

// Notification toast popups - top right corner
Scope {
    id: root

    property var _activePopups: []
    property int _maxVisible: QsConfig.Config.notifications.maxVisible ?? 5

    Connections {
        target: QsServices.Notifs
        function onHistoryChanged() {
            // Show popup for the newest notification
            if (QsServices.Notifs.history.count > 0) {
                const latest = QsServices.Notifs.history.get(0)
                if (latest && !latest.read) {
                    // The popup model handles display
                    popupModel.insert(0, {
                        summary: latest.summary,
                        body: latest.body,
                        appName: latest.appName,
                        uid: Date.now()
                    })
                    if (popupModel.count > root._maxVisible)
                        popupModel.remove(popupModel.count - 1)
                }
            }
        }
    }

    ListModel {
        id: popupModel
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: popupWindow
            property var modelData
            screen: modelData

            anchors { top: true; right: true }
            margins { top: 50; right: 12 }

            WlrLayershell.namespace: "quickshell-notifications"
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            implicitWidth: 380
            implicitHeight: popupColumn.implicitHeight
            visible: popupModel.count > 0

            ColumnLayout {
                id: popupColumn
                width: parent.width
                spacing: 8

                Repeater {
                    model: popupModel

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: notifContent.implicitHeight + 20
                        color: QsServices.Wallust.bg
                        border.width: 1
                        border.color: QsServices.Wallust.muted

                        ColumnLayout {
                            id: notifContent
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: model.appName || "Notification"
                                    color: QsServices.Wallust.blue
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "×"
                                    color: QsServices.Wallust.muted
                                    font.family: QsConfig.Config.fontFamily
                                    font.pixelSize: 14
                                    TapHandler { onTapped: popupModel.remove(index) }
                                }
                            }

                            Text {
                                text: model.summary || ""
                                color: QsServices.Wallust.fg
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.body || ""
                                color: QsServices.Wallust.muted
                                font.family: QsConfig.Config.fontFamily
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: (model.body || "") !== ""
                            }
                        }

                        // Auto-dismiss after timeout
                        Timer {
                            interval: QsConfig.Config.notifications.timeoutMs ?? 5000
                            running: true
                            onTriggered: {
                                if (index >= 0 && index < popupModel.count)
                                    popupModel.remove(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
