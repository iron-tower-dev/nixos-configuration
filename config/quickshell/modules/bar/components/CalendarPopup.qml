import QtQuick
import QtQuick.Layouts
import "../../../config" as QsConfig
import "../../../services" as QsServices
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: col.implicitHeight + 32
    color: QsServices.Wallust.bg
    border.width: 1
    border.color: QsServices.Wallust.muted

    // --- State ---
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property string selectedDate: formatDate(new Date().getFullYear(), new Date().getMonth(), new Date().getDate())
    property var events: ({})
    property string newEventText: ""

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
    function prevMonth() {
        if (viewMonth === 0) { viewMonth = 11; viewYear-- }
        else { viewMonth-- }
    }
    function nextMonth() {
        if (viewMonth === 11) { viewMonth = 0; viewYear++ }
        else { viewMonth++ }
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
            } catch (e) {
                root.events = {}
            }
        }
        onFileChanged: reload()
        onLoadFailed: { root.events = {} }
    }

    Process {
        id: saveProc
        running: false
    }

    // --- Layout ---
    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Month navigation
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "◀"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 16
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevMonth()
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: `${root.monthName(root.viewMonth)} ${root.viewYear}`
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "▶"
                color: QsServices.Wallust.fg
                font.family: QsConfig.Config.fontFamily
                font.pixelSize: 16
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextMonth()
                }
            }
        }

        // Day headers
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                Text {
                    Layout.fillWidth: true
                    text: modelData
                    color: QsServices.Wallust.muted
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Calendar grid
        Grid {
            Layout.fillWidth: true
            columns: 7
            spacing: 2

            Repeater {
                model: 42

                Rectangle {
                    id: dayCell
                    width: (root.implicitWidth - 32 - 12) / 7
                    height: 32
                    color: {
                        if (!dayCell.isValid) return "transparent"
                        if (dayCell.dateStr === root.selectedDate) return QsServices.Wallust.blue
                        if (dayCell.dateStr === root.todayStr()) return QsServices.Wallust.bgAlt
                        return "transparent"
                    }

                    required property int index

                    property int dayNum: {
                        const offset = root.firstDayOfWeek(root.viewYear, root.viewMonth)
                        return index - offset + 1
                    }
                    property bool isValid: dayNum >= 1 && dayNum <= root.daysInMonth(root.viewYear, root.viewMonth)
                    property string dateStr: isValid ? root.formatDate(root.viewYear, root.viewMonth, dayNum) : ""

                    Text {
                        anchors.centerIn: parent
                        text: dayCell.isValid ? dayCell.dayNum : ""
                        color: {
                            if (dayCell.dateStr === root.selectedDate) return QsServices.Wallust.bg
                            if (dayCell.dateStr === root.todayStr()) return QsServices.Wallust.blue
                            return QsServices.Wallust.fg
                        }
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 12
                    }

                    // Event dot
                    Rectangle {
                        visible: dayCell.isValid && dayCell.dateStr !== "" && (root.events[dayCell.dateStr] ? root.events[dayCell.dateStr].length > 0 : false)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: 4
                        height: 4
                        color: dayCell.dateStr === root.selectedDate ? QsServices.Wallust.bg : QsServices.Wallust.orange
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: dayCell.isValid
                        cursorShape: dayCell.isValid ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (dayCell.isValid) root.selectedDate = dayCell.dateStr
                        }
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: QsServices.Wallust.muted
        }

        // Events header
        Text {
            text: `Events for ${root.selectedDate}:`
            color: QsServices.Wallust.fg
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
        }

        // Events list
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            visible: root.eventsForSelected().length > 0

            Repeater {
                model: root.eventsForSelected().length

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    required property int index
                    Text {
                        Layout.fillWidth: true
                        text: "• " + root.eventsForSelected()[index]
                        color: QsServices.Wallust.fg
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                    Text {
                        text: "×"
                        color: QsServices.Wallust.red
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 14
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.removeEvent(index)
                        }
                    }
                }
            }
        }

        // No events message
        Text {
            visible: root.eventsForSelected().length === 0
            text: "No events"
            color: QsServices.Wallust.muted
            font.family: QsConfig.Config.fontFamily
            font.pixelSize: 11
        }

        // Add event form
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                height: 28
                color: QsServices.Wallust.bgAlt
                border.width: 1
                border.color: QsServices.Wallust.muted

                TextInput {
                    id: eventInput
                    anchors.fill: parent
                    anchors.margins: 4
                    color: QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                    clip: true
                    onTextChanged: root.newEventText = text
                    onAccepted: root.addEvent()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        text: "Add event..."
                        color: QsServices.Wallust.muted
                        font.family: QsConfig.Config.fontFamily
                        font.pixelSize: 12
                        visible: !eventInput.text && !eventInput.activeFocus
                    }
                }
            }

            Rectangle {
                width: 48
                height: 28
                color: addArea.containsMouse ? QsServices.Wallust.blue : QsServices.Wallust.bgAlt
                border.width: 1
                border.color: QsServices.Wallust.muted

                Text {
                    anchors.centerIn: parent
                    text: "Add"
                    color: addArea.containsMouse ? QsServices.Wallust.bg : QsServices.Wallust.fg
                    font.family: QsConfig.Config.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    id: addArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addEvent()
                }
            }
        }
    }
}
