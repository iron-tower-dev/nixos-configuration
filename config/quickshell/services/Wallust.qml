pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    Component.onCompleted: file.reload()

    // --- Tokyo Night fallback palette ---
    readonly property var _fallback: ({
        background: "#1a1b26",
        foreground: "#a9b1d6",
        cursor: "#c0caf5",
        color0: "#1f2335",
        color1: "#f7768e",
        color2: "#9ece6a",
        color3: "#e0af68",
        color4: "#7aa2f7",
        color5: "#ad8ee6",
        color6: "#0db9d7",
        color7: "#c0caf5",
        color8: "#444b6a",
        color9: "#ff9e64",
        color10: "#9ece6a",
        color11: "#e0af68",
        color12: "#7aa2f7",
        color13: "#ad8ee6",
        color14: "#0db9d7",
        color15: "#c0caf5"
    })

    // --- Internal parsed data ---
    property var _colors: _fallback

    // --- Individual color properties ---
    readonly property color background: _colors.background ?? _fallback.background
    readonly property color foreground: _colors.foreground ?? _fallback.foreground
    readonly property color cursor: _colors.cursor ?? _fallback.cursor
    readonly property color color0: _colors.color0 ?? _fallback.color0
    readonly property color color1: _colors.color1 ?? _fallback.color1
    readonly property color color2: _colors.color2 ?? _fallback.color2
    readonly property color color3: _colors.color3 ?? _fallback.color3
    readonly property color color4: _colors.color4 ?? _fallback.color4
    readonly property color color5: _colors.color5 ?? _fallback.color5
    readonly property color color6: _colors.color6 ?? _fallback.color6
    readonly property color color7: _colors.color7 ?? _fallback.color7
    readonly property color color8: _colors.color8 ?? _fallback.color8
    readonly property color color9: _colors.color9 ?? _fallback.color9
    readonly property color color10: _colors.color10 ?? _fallback.color10
    readonly property color color11: _colors.color11 ?? _fallback.color11
    readonly property color color12: _colors.color12 ?? _fallback.color12
    readonly property color color13: _colors.color13 ?? _fallback.color13
    readonly property color color14: _colors.color14 ?? _fallback.color14
    readonly property color color15: _colors.color15 ?? _fallback.color15

    // --- Semantic aliases ---
    readonly property color bg: background
    readonly property color fg: foreground
    readonly property color bgAlt: color0
    readonly property color muted: color8
    readonly property color red: color1
    readonly property color green: color2
    readonly property color yellow: color3
    readonly property color blue: color4
    readonly property color purple: color5
    readonly property color cyan: color6
    readonly property color orange: color9
    readonly property color fgBright: color15

    // --- FileView for colors.json ---

    FileView {
        id: file
        path: QsConfig.Config.wallustColorsPath
        watchChanges: true

        onLoaded: {
            try {
                const parsed = JSON.parse(text())
                if (parsed && typeof parsed === "object") {
                    root._colors = parsed
                    QsServices.Logger.log("Wallust", "Colors loaded successfully")
                } else {
                    root._colors = root._fallback
                    QsServices.Logger.warn("Wallust", "Invalid colors format, using fallback")
                }
            } catch (e) {
                root._colors = root._fallback
                QsServices.Logger.warn("Wallust", `Failed to parse colors.json: ${e?.message ?? e}`)
            }
        }

        onFileChanged: file.reload()

        onLoadFailed: err => {
            root._colors = root._fallback
            if (err === FileViewError.FileNotFound)
                QsServices.Logger.warn("Wallust", "colors.json not found, using Tokyo Night fallback")
            else
                QsServices.Logger.warn("Wallust", `Failed to read colors.json: ${err}`)
        }
    }
}
