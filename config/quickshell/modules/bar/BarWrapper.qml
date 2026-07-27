import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../config" as QsConfig
import "../../services" as QsServices
import "components"
import "popups"

Scope {
    id: root

    property string activePopup: ""
    property var activePopupScreen: null

    function togglePopup(name, screen) {
        if (root.activePopup === name) {
            root.activePopup = ""
            root.activePopupScreen = null
        } else {
            root.activePopup = name
            root.activePopupScreen = screen
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            property var modelData
            screen: modelData

            function togglePopup(name) {
                root.togglePopup(name, modelData)
            }

            anchors {
                top: true
                left: true
                right: true
            }

            exclusiveZone: QsConfig.BarConfig.height
            implicitHeight: QsConfig.BarConfig.height
            color: QsServices.Wallust.bg

            WlrLayershell.namespace: "quickshell-bar"

            Bar {
                anchors.fill: parent
                barWindow: barWindow
            }

            // Calendar Popup
            PopupWindow {
                id: calendarPopup
                anchor.window: barWindow
                anchor.rect.x: (barWindow.width - 360) / 2
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "calendar" && root.activePopupScreen === modelData

                implicitWidth: calendarContent.implicitWidth
                implicitHeight: calendarContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "calendar")
                        root.activePopup = ""
                }

                CalendarPopup { id: calendarContent }
            }

            // Quick Settings Popup
            PopupWindow {
                id: qsPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 320
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "quicksettings" && root.activePopupScreen === modelData

                implicitWidth: qsContent.implicitWidth
                implicitHeight: qsContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "quicksettings")
                        root.activePopup = ""
                }

                QuickSettingsPopup { id: qsContent }
            }

            // Notifications Popup
            PopupWindow {
                id: notifPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 380
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "notifications" && root.activePopupScreen === modelData

                implicitWidth: notifContent.implicitWidth
                implicitHeight: notifContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "notifications")
                        root.activePopup = ""
                }

                NotificationsPopup { id: notifContent }
            }

            // Wallpaper Popup
            PopupWindow {
                id: wallpaperPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 440
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "wallpaper" && root.activePopupScreen === modelData

                implicitWidth: wallpaperContent.implicitWidth
                implicitHeight: wallpaperContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "wallpaper")
                        root.activePopup = ""
                }

                WallpaperPopup { id: wallpaperContent }
            }

            // Media Popup
            PopupWindow {
                id: mediaPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 500
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "media" && root.activePopupScreen === modelData

                implicitWidth: mediaContent.implicitWidth
                implicitHeight: mediaContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "media")
                        root.activePopup = ""
                }

                MediaPopup { id: mediaContent }
            }

            // Audio Popup
            PopupWindow {
                id: audioPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 400
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "audio" && root.activePopupScreen === modelData

                implicitWidth: audioContent.implicitWidth
                implicitHeight: audioContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "audio")
                        root.activePopup = ""
                }

                AudioPopup { id: audioContent }
            }

            // Network Popup
            PopupWindow {
                id: networkPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 400
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "network" && root.activePopupScreen === modelData

                implicitWidth: networkContent.implicitWidth
                implicitHeight: networkContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "network")
                        root.activePopup = ""
                }

                NetworkPopup { id: networkContent }
            }

            // Bluetooth Popup
            PopupWindow {
                id: bluetoothPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 380
                anchor.rect.y: barWindow.implicitHeight
                anchor.rect.width: 1
                anchor.rect.height: 1
                visible: root.activePopup === "bluetooth" && root.activePopupScreen === modelData

                implicitWidth: bluetoothContent.implicitWidth
                implicitHeight: bluetoothContent.implicitHeight
                color: "transparent"

                onVisibleChanged: {
                    if (!visible && root.activePopup === "bluetooth")
                        root.activePopup = ""
                }

                BluetoothPopup { id: bluetoothContent }
            }
        }
    }
}
