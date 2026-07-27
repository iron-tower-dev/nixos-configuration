pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property var date: clock.date

    readonly property string timeStr: Qt.formatDateTime(clock.date, "hh:mm")

    readonly property string dateStr: Qt.formatDateTime(clock.date, "ddd MMM d")

    readonly property string fullStr: Qt.formatDateTime(clock.date, "ddd MMM d  hh:mm")
}
