pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root

    // Track the default audio sink
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    property var sink: Pipewire.defaultAudioSink
    property var audio: sink?.audio ?? null

    // Public API
    readonly property real volume: audio?.volume ?? 0
    readonly property bool muted: audio?.muted ?? false

    readonly property string icon: {
        if (muted || volume === 0) return String.fromCodePoint(0xf0581)
        if (volume < 0.33) return String.fromCodePoint(0xf057f)
        if (volume < 0.66) return String.fromCodePoint(0xf0580)
        return String.fromCodePoint(0xf057e)
    }

    function setVolume(val) {
        if (!audio) return
        audio.volume = Math.max(0, Math.min(1, val))
    }

    function toggleMute() {
        if (!audio) return
        audio.muted = !audio.muted
    }
}
