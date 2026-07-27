pragma Singleton

import Quickshell
import QtQuick
import "../config" as QsConfig

Singleton {
    id: root

    readonly property bool debugMode: QsConfig.Config.debug

    function log(component, msg) {
        if (debugMode)
            console.log(`[LOG][${component}]`, msg)
    }

    function warn(component, msg) {
        console.warn(`[WARN][${component}]`, msg)
    }

    function error(component, msg) {
        console.error(`[ERROR][${component}]`, msg)
    }
}
