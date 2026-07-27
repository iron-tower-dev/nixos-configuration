//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import "services" as QsServices
import "config" as QsConfig
import "modules/osd"
import "modules/bar"

ShellRoot {
    id: root

    // Initialize services (access triggers singleton creation)
    readonly property var wallust: QsServices.Wallust
    readonly property var audio: QsServices.Audio
    readonly property var brightness: QsServices.Brightness

    // Notification server (only if enabled in config)
    Loader {
        active: QsConfig.Config.notifications.registerServer ?? true
        sourceComponent: NotificationServer {
            keepOnReload: false
            actionsSupported: true
            bodyMarkupSupported: true
            imageSupported: true

            onNotification: notif => {
                notif.tracked = true
                QsServices.Notifs.addNotification(notif)
            }
        }
    }

    // Bar module
    BarWrapper {}

    // OSD overlays (volume and brightness)
    Wrapper {}

    // Notification toast popups
    Loader {
        source: "modules/notifications/NotificationPopups.qml"
    }

    // IPC handler for reload
    IpcHandler {
        target: "shell"
        function reload(): void { Quickshell.reload(true) }
    }

    Component.onCompleted: {
        QsServices.Logger.log("Shell", "Loaded")
    }
}
