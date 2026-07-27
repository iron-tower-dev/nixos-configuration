import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    implicitWidth: 360
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted
    clip: true

    // --- State ---
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property string selectedDate: formatDate(new Date().getFullYear(), new Date().getMonth(), new Date().getDate())
    property var events: ({})
    property string newEventText: ""

    // --- Animation state ---
    property real gridOpacity: 1.0
    property real gridTranslateX: 0
    property int _navDirection: 0  // -1 = prev, 1 = next

    // --- JS Helpers ---
    function daysInMonth(year, month) { return new Date(year, month + 1, 0).getDate() }
    function firstDayOfWeek(year, month) { return (new Date(year, month, 1).getDay() + 6) % 7 }
    function formatDate(year, month, day) {
        return `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`
    }
    function monthName(month) {
        const names = ["January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"]
        return names[month]
    }
    function navigateMonth(direction) {
        _navDirection = direction
        fadeOut.start()
    }
    function _applyNavigation() {
        if (_navDirection < 0) {
            if (viewMonth === 0) { viewMonth = 11; viewYear-- }
            else { viewMonth-- }
        } else {
            if (viewMonth === 11) { viewMonth = 0; viewYear++ }
            else { viewMonth++ }
        }
        gridTranslateX = _navDirection * -30
        fadeIn.start()
    }
    function goToToday() {
        const now = new Date()
        viewYear = now.getFullYear()
        viewMonth = now.getMonth()
        selectedDate = formatDate(now.getFullYear(), now.getMonth(), now.getDate())
    }
    function todayStr() {
        const d = new Date()
        return formatDate(d.getFullYear(), d.getMonth(), d.getDate())
    }
    function eventsForSelected() {
        return events[selectedDate] || []
    }
    function addEvent() {
        if (!newEventText.trim()) return
        let copy = JSON.parse(JSON.stringify(events))
        if (!copy[selectedDate]) copy[selectedDate] = []
        copy[selectedDate].push(newEventText.trim())
        events = copy
        newEventText = ""
        eventInput.text = ""
        saveEvents()
    }
    function removeEvent(idx) {
        let copy = JSON.parse(JSON.stringify(events))
        if (copy[selectedDate]) {
            copy[selectedDate].splice(idx, 1)
            if (copy[selectedDate].length === 0) delete copy[selectedDate]
        }
        events = copy
        saveEvents()
    }
    function saveEvents() {
        const json = JSON.stringify(events)
        saveProc.command = ["/bin/sh", "-c", `printf '%s' '${json.replace(/'/g, "'\\''")}' > /home/ds/.config/quickshell/events.json`]
        saveProc.running = true
    }

    // --- Animations ---
    SequentialAnimation {
        id: fadeOut
        ParallelAnimation {
            NumberAnimation { target: root; property: "gridOpacity"; to: 0; duration: 120; easing.type: Easing.OutQuad }
            NumberAnimation { target: root; property: "gridTranslateX"; to: root._navDirection * 30; duration: 120; easing.type: Easing.OutQuad }
        }
        ScriptAction { script: root._applyNavigation() }
    }

    SequentialAnimation {
        id: fadeIn
        ParallelAnimation {
            NumberAnimation { target: root; property: "gridOpacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "gridTranslateX"; to: 0; duration: 180; easing.type: Easing.OutCubic }
        }
    }

    // --- File I/O ---
    FileView {
        id: eventsFile
        path: "/home/ds/.config/quickshell/events.json"
        watchChanges: true
        Component.onCompleted: reload()
        onLoaded: {
            try {
                const parsed = JSON.parse(text())
                if (parsed && typeof parsed === "object") root.events = parsed
                else root.events = {}
            } catch (e) { root.events = {} }
        }
        onFileChanged: reload()
        onLoadFailed: { root.events = {} }
    }

    Process { id: saveProc; running: false }

    // --- Mouse wheel navigation ---
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: root.goToToday()
        onWheel: event => {
            if (event.angleDelta.y > 0) root.navigateMonth(-1)
            else if (event.angleDelta.y < 0) root.navigateMonth(1)
        }
    }

    // --- Layout ---
    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // === MONTH NAVIGATION ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Rectangle {
                width: 28; height: 28
                color: prevArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xf053)
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 16
                }
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.navigateMonth(-1)
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: `${root.monthName(root.viewMonth)} ${root.viewYear}`
                color: QsServices.Wallust.blue
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
                opacity: root.gridOpacity

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goToToday()
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 28; height: 28
                color: nextArea.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xf054)
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 16
                }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.navigateMonth(1)
                }
            }
        }

        // === DAY OF WEEK HEADERS ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                Text {
                    Layout.fillWidth: true
                    text: modelData
                    color: (index >= 5) ? Qt.lighter(QsServices.Wallust.red, 1.3) : QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // === CALENDAR GRID ===
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: calGrid.height
            clip: true

            Grid {
                id: calGrid
                width: parent.width
                columns: 7
                spacing: 2
                opacity: root.gridOpacity
                transform: Translate { x: root.gridTranslateX }

                Repeater {
                    model: 42

                    Rectangle {
                        id: dayCell
                        width: (calGrid.width - 12) / 7
                        height: 34
                        required property int index

                        property int dayNum: index - root.firstDayOfWeek(root.viewYear, root.viewMonth) + 1
                        property bool isValid: dayNum >= 1 && dayNum <= root.daysInMonth(root.viewYear, root.viewMonth)
                        property string dateStr: isValid ? root.formatDate(root.viewYear, root.viewMonth, dayNum) : ""
                        property bool isToday: dateStr === root.todayStr()
                        property bool isSelected: dateStr === root.selectedDate
                        property bool isWeekend: (index % 7) >= 5
                        property bool hasEvents: isValid && dateStr !== "" && (root.events[dateStr] ? root.events[dateStr].length > 0 : false)

                        color: {
                            if (!isValid) return "transparent"
                            if (isSelected) return QsServices.Wallust.blue
                            if (isToday) return Qt.rgba(QsServices.Wallust.blue.r, QsServices.Wallust.blue.g, QsServices.Wallust.blue.b, 0.15)
                            if (dayCellHover.containsMouse) return QsServices.Wallust.bgAlt
                            return "transparent"
                        }

                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.isValid ? dayCell.dayNum : ""
                            color: {
                                if (dayCell.isSelected) return QsServices.Wallust.bg
                                if (dayCell.isToday) return QsServices.Wallust.blue
                                if (dayCell.isWeekend) return Qt.lighter(QsServices.Wallust.red, 1.3)
                                return QsServices.Wallust.fg
                            }
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            font.weight: (dayCell.isToday || dayCell.isSelected) ? Font.Bold : Font.Normal
                        }

                        Rectangle {
                            visible: dayCell.hasEvents
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            width: 5; height: 5
                            color: dayCell.isSelected ? QsServices.Wallust.bg : QsServices.Wallust.green
                        }

                        MouseArea {
                            id: dayCellHover
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: dayCell.isValid
                            cursorShape: dayCell.isValid ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (dayCell.isValid) root.selectedDate = dayCell.dateStr
                            }
                        }
                    }
                }
            }
        }

        // === SEPARATOR ===
        Rectangle { Layout.fillWidth: true; height: 1; color: QsServices.Wallust.muted }

        // === EVENTS SECTION ===
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: Qt.formatDate(new Date(root.selectedDate), "ddd, MMM d")
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 12
                font.weight: Font.Bold
                Layout.fillWidth: true
            }
            Text {
                text: root.eventsForSelected().length > 0 ? `${root.eventsForSelected().length} event${root.eventsForSelected().length > 1 ? "s" : ""}` : ""
                color: QsServices.Wallust.muted
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 10
            }
        }

        // Event list
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            visible: root.eventsForSelected().length > 0

            Repeater {
                model: root.eventsForSelected().length

                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    color: evtHover.containsMouse ? QsServices.Wallust.bgAlt : "transparent"
                    required property int index

                    Behavior on color { ColorAnimation { duration: 80 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Rectangle {
                            width: 3; height: 16
                            color: QsServices.Wallust.green
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.eventsForSelected()[index]
                            color: QsServices.Wallust.fg
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        Text {
                            text: String.fromCodePoint(0xf0156)
                            color: evtHover.containsMouse ? QsServices.Wallust.red : "transparent"
                            font.family: QsConfig.Config.fontFamily
                            font.pixelSize: 14
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.removeEvent(index)
                            }
                        }
                    }

                    MouseArea {
                        id: evtHover
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }

        // No events
        Text {
            visible: root.eventsForSelected().length === 0
            text: "No events scheduled"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
            font.italic: true
        }

        // === ADD EVENT FORM ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                Layout.fillWidth: true
                height: 30
                color: QsServices.Wallust.bgAlt
                border.width: eventInput.activeFocus ? 1 : 0
                border.color: QsServices.Wallust.blue

                TextInput {
                    id: eventInput
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: TextInput.AlignVCenter
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                    clip: true
                    onTextChanged: root.newEventText = text
                    onAccepted: root.addEvent()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "New event..."
                        color: QsServices.Wallust.muted
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 12
                        font.italic: true
                        visible: !eventInput.text && !eventInput.activeFocus
                    }
                }
            }

            Rectangle {
                width: 30; height: 30
                color: addBtnArea.containsMouse ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt

                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xf0415)
                    color: addBtnArea.containsMouse ? QsServices.Wallust.bg : QsServices.Wallust.blue
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 16
                }

                MouseArea {
                    id: addBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addEvent()
                }
            }
        }
    }
}
