pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    Component.onCompleted: file.reload()

    property var data: ({})

    // --- Convenience properties with defaults ---

    property string fontFamily: data.appearance?.fontFamily ?? "JetBrainsMono Nerd Font"
    property string wallustColorsPath: _expandHome(data.paths?.wallustColors ?? "/home/ds/.cache/wallust/colors.json")
    property bool debug: data.debug ?? false

    property var notifications: data.notifications ?? {
        "popupWidth": 380,
        "maxVisible": 5,
        "timeoutMs": 5000,
        "registerServer": true
    }

    property var osd: data.osd ?? {
        "volumeTimeoutMs": 2000,
        "brightnessTimeoutMs": 2000
    }

    property var bar: data.bar ?? {
        "height": 42,
        "workspaceCount": 9
    }

    // --- Internal helpers ---

    function _expandHome(p) {
        if (!p || typeof p !== "string") return p
        if (p.startsWith("~/")) return `${Quickshell.env("HOME")}/${p.slice(2)}`
        return p
    }

    // --- FileView for shell.json ---

    FileView {
        id: file
        path: {
            const home = Quickshell.env("HOME")
            const xdg = Quickshell.env("XDG_CONFIG_HOME")
            const cfgHome = (xdg && xdg.length > 0) ? xdg : `${home}/.config`
            return `${cfgHome}/quickshell/shell.json`
        }
        watchChanges: true

        onLoaded: {
            try {
                root.data = JSON.parse(text())
            } catch (e) {
                console.warn("[Config] Failed to parse shell.json:", e?.message ?? e)
            }
        }

        onFileChanged: file.reload()

        onLoadFailed: err => {
            if (err !== FileViewError.FileNotFound)
                console.warn("[Config] Failed to read shell.json:", err)
            // On any load failure, keep existing defaults (data stays {})
        }
    }
}
