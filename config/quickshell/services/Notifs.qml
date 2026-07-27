pragma Singleton

import Quickshell
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    property bool doNotDisturb: false

    property ListModel history: ListModel {}

    readonly property int unreadCount: {
        let count = 0
        for (let i = 0; i < history.count; i++) {
            if (!history.get(i).read) count++
        }
        return count
    }

    function addNotification(notif) {
        if (doNotDisturb) return

        history.insert(0, {
            "summary": notif.summary ?? "",
            "body": notif.body ?? "",
            "appName": notif.appName ?? "",
            "appIcon": notif.appIcon ?? "",
            "timestamp": new Date().getTime(),
            "read": false
        })

        // Cap at 100 notifications
        while (history.count > 100)
            history.remove(history.count - 1)

        QsServices.Logger.log("Notifs", `Received: ${notif.appName} - ${notif.summary}`)
    }

    function dismiss(index) {
        if (index >= 0 && index < history.count)
            history.remove(index)
    }

    function clearAll() {
        history.clear()
    }

    function markAllRead() {
        for (let i = 0; i < history.count; i++) {
            history.setProperty(i, "read", true)
        }
    }

    function toggleDND() {
        doNotDisturb = !doNotDisturb
        QsServices.Logger.log("Notifs", `DND: ${doNotDisturb ? "enabled" : "disabled"}`)
    }
}
