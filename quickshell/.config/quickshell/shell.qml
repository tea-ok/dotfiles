import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    property color colBg: "#303446"
    property color colFg: "#c6d0f5"
    property color colMuted: "#737994"
    property color colCyan: "#99d1db"
    property color colPurple: "#ca9ee6"
    property color colRed: "#e78284"
    property color colYellow: "#e5c890"
    property color colBlue: "#8caaee"
    property color colSurface: "#414559"
    property color colOverlay: "#51576d"

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property int cpuUsage: 0
    property int memUsage: 0
    property int volumeLevel: 0
    property string activeWindow: "Window"
    property string currentLayout: "Tile"
    property int unreadNotificationCount: 0
    property bool notificationCenterOpen: false
    property bool notificationCenterClosing: false
    property var notificationCenterScreen: null
    property var notificationItems: []
    property var activeNotificationItems: []
    property var popupNotificationItems: []
    property var groupedNotificationItems: []

    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    function syncNotifications() {
        activeNotificationItems = notificationItems.filter(item => !item.closed)
        popupNotificationItems = notificationItems.filter(item => item.popup && !item.closed)

        const groups = new Map()
        for (const item of activeNotificationItems) {
            const key = item.appName && item.appName !== "" ? item.appName : "Notifications"
            if (!groups.has(key)) {
                groups.set(key, [])
            }
            groups.get(key).push(item)
        }

        groupedNotificationItems = Array.from(groups, ([appName, items]) => ({
            appName: appName,
            items: items
        }))
    }

    function closeNotification(uid) {
        notificationItems = notificationItems.map(item => {
            if (item.uid !== uid) {
                return item
            }

            if (item.notification && typeof item.notification.dismiss === "function") {
                item.notification.dismiss()
            }

            return {
                uid: item.uid,
                notification: item.notification,
                summary: item.summary,
                body: item.body,
                appName: item.appName,
                appIcon: item.appIcon,
                actions: item.actions,
                closed: true,
                popup: false
            }
        })

        syncNotifications()
    }

    function expirePopup(uid) {
        notificationItems = notificationItems.map(item => item.uid === uid ? {
            uid: item.uid,
            notification: item.notification,
            summary: item.summary,
            body: item.body,
            appName: item.appName,
            appIcon: item.appIcon,
            actions: item.actions,
            closed: item.closed,
            popup: false
        } : item)
        syncNotifications()
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                const parts = data.trim().split(/\s+/)
                const user = parseInt(parts[1]) || 0
                const nice = parseInt(parts[2]) || 0
                const system = parseInt(parts[3]) || 0
                const idle = parseInt(parts[4]) || 0
                const iowait = parseInt(parts[5]) || 0
                const irq = parseInt(parts[6]) || 0
                const softirq = parseInt(parts[7]) || 0

                const total = user + nice + system + idle + iowait + irq + softirq
                const idleTime = idle + iowait

                if (root.lastCpuTotal > 0) {
                    const totalDiff = total - root.lastCpuTotal
                    const idleDiff = idleTime - root.lastCpuIdle
                    if (totalDiff > 0) {
                        root.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                    }
                }

                root.lastCpuTotal = total
                root.lastCpuIdle = idleTime
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                const parts = data.trim().split(/\s+/)
                const total = parseInt(parts[1]) || 1
                const used = parseInt(parts[2]) || 0
                root.memUsage = Math.round(100 * used / total)
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                const match = data.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    root.volumeLevel = Math.round(parseFloat(match[1]) * 100)
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    root.activeWindow = data.trim()
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: layoutProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    root.currentLayout = data.trim()
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            volProc.running = true
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            windowProc.running = true
            layoutProc.running = true
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true
            layoutProc.running = true
        }
    }

    NotificationServer {
        id: notificationServer
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true
            const item = {
                uid: Date.now().toString() + Math.random().toString(16).slice(2),
                notification: notification,
                summary: notification.summary || "Notification",
                body: notification.body || "",
                appName: notification.appName || notification.desktopEntry || "",
                appIcon: notification.appIcon || "",
                actions: notification.actions.map(action => ({
                    text: action.text,
                    invoke: () => action.invoke()
                })),
                closed: false,
                popup: true
            }

            notificationItems = [item, ...notificationItems]
            syncNotifications()

            if (!root.notificationCenterOpen) {
                root.unreadNotificationCount += 1
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30
            color: root.colBg

            margins {
                top: 0
                bottom: 0
                left: 0
                right: 0
            }

            Rectangle {
                anchors.fill: parent
                color: root.colBg

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item { width: 8 }

                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        color: "transparent"

                        Image {
                            anchors.fill: parent
                            source: "file:///usr/share/pixmaps/archlinux-logo.svg"
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Item { width: 8 }

                    Repeater {
                        model: 9

                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: parent.height
                            color: "transparent"

                            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                            property bool isActive: Hyprland.focusedWorkspace?.id === index + 1
                            property bool hasWindows: workspace !== null

                            Text {
                                anchors.centerIn: parent
                                text: index + 1
                                color: parent.isActive ? root.colCyan : (parent.hasWindows ? root.colCyan : root.colMuted)
                                font.pixelSize: root.fontSize
                                font.family: root.fontFamily
                                font.bold: true
                            }

                            Rectangle {
                                width: 20
                                height: 3
                                color: parent.isActive ? root.colPurple : root.colBg
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: root.currentLayout
                        color: root.colFg
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 2
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: root.activeWindow
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        text: "CPU: " + root.cpuUsage + "%"
                        color: root.colYellow
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: "Mem: " + root.memUsage + "%"
                        color: root.colCyan
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: "Vol: " + root.volumeLevel + "%"
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        id: notificationButton
                        Layout.preferredWidth: root.unreadNotificationCount > 0 ? 54 : 28
                        Layout.preferredHeight: 22
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 8
                        radius: 6
                        color: root.notificationCenterOpen && root.notificationCenterScreen === panelWindow.screen
                            ? root.colSurface
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: root.unreadNotificationCount > 0 ? " " + root.unreadNotificationCount : ""
                            color: root.colFg
                            font.pixelSize: root.fontSize
                            font.family: root.fontFamily
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (root.notificationCenterOpen && root.notificationCenterScreen === panelWindow.screen) {
                                    root.notificationCenterOpen = false
                                    root.notificationCenterClosing = true
                                } else {
                                    root.notificationCenterClosing = false
                                    root.notificationCenterOpen = true
                                    root.notificationCenterScreen = panelWindow.screen
                                    root.unreadNotificationCount = 0
                                }
                            }
                        }
                    }

                    Text {
                        id: clockText
                        text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                        color: root.colCyan
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                        }
                    }

                    Item { width: 8 }
                }
            }

            PopupWindow {
                anchor.window: panelWindow
                anchor.rect.x: panelWindow.width - implicitWidth - 12
                anchor.rect.y: panelWindow.height + 8
                implicitWidth: 380
                implicitHeight: 460
                visible: (root.notificationCenterOpen || root.notificationCenterClosing) && root.notificationCenterScreen === panelWindow.screen
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: root.colBg
                    border.width: 1
                    border.color: root.colMuted
                    opacity: root.notificationCenterOpen && root.notificationCenterScreen === panelWindow.screen ? 1 : 0
                    scale: root.notificationCenterOpen && root.notificationCenterScreen === panelWindow.screen ? 1 : 0.985
                    y: root.notificationCenterOpen && root.notificationCenterScreen === panelWindow.screen ? 0 : -6

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 210
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 170
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 170
                            easing.type: Easing.OutCubic
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Notifications"
                                color: root.colFg
                                font.pixelSize: root.fontSize
                                font.family: root.fontFamily
                                font.bold: true
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: root.activeNotificationItems.length > 0
                                    ? root.activeNotificationItems.length.toString()
                                    : ""
                                color: root.colMuted
                                font.pixelSize: root.fontSize - 1
                                font.family: root.fontFamily
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.colSurface

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 10
                                clip: true
                                contentHeight: notificationColumn.implicitHeight

                                Column {
                                    id: notificationColumn
                                    width: parent.width
                                    spacing: 8

                                    Text {
                                        visible: root.activeNotificationItems.length === 0
                                        width: parent.width
                                        text: "No notifications"
                                        color: root.colMuted
                                        font.pixelSize: root.fontSize
                                        font.family: root.fontFamily
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Repeater {
                                        model: root.groupedNotificationItems

                                        Rectangle {
                                            required property var modelData
                                            property var group: modelData

                                            width: notificationColumn.width
                                            radius: 10
                                            color: root.colOverlay
                                            border.width: 1
                                            border.color: root.colMuted
                                            implicitHeight: groupLayout.implicitHeight + 16

                                            ColumnLayout {
                                                id: groupLayout
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                spacing: 8

                                                RowLayout {
                                                    Layout.fillWidth: true

                                                    Text {
                                                        text: group.appName
                                                        color: root.colBlue
                                                        font.pixelSize: root.fontSize - 1
                                                        font.family: root.fontFamily
                                                        font.bold: true
                                                        Layout.fillWidth: true
                                                        elide: Text.ElideRight
                                                    }

                                                    Rectangle {
                                                        radius: 999
                                                        color: root.colSurface
                                                        implicitWidth: groupCountText.implicitWidth + 12
                                                        implicitHeight: groupCountText.implicitHeight + 6

                                                        Text {
                                                            id: groupCountText
                                                            anchors.centerIn: parent
                                                            text: group.items.length.toString()
                                                            color: root.colFg
                                                            font.pixelSize: root.fontSize - 2
                                                            font.family: root.fontFamily
                                                            font.bold: true
                                                        }
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 6

                                                    Repeater {
                                                        model: group.items

                                                        Rectangle {
                                                            required property var modelData
                                                            property var notif: modelData

                                                            Layout.fillWidth: true
                                                            radius: 8
                                                            color: root.colSurface
                                                            border.width: 1
                                                            border.color: root.colMuted
                                                            implicitHeight: notificationLayout.implicitHeight + 16

                                                            ColumnLayout {
                                                                id: notificationLayout
                                                                anchors.fill: parent
                                                                anchors.margins: 8
                                                                spacing: 6

                                                                RowLayout {
                                                                    Layout.fillWidth: true

                                                                    Text {
                                                                        text: notif.summary || "Notification"
                                                                        color: root.colFg
                                                                        font.pixelSize: root.fontSize
                                                                        font.family: root.fontFamily
                                                                        font.bold: true
                                                                        wrapMode: Text.Wrap
                                                                        Layout.fillWidth: true
                                                                    }

                                                                    Text {
                                                                        text: "✕"
                                                                        color: root.colMuted
                                                                        font.pixelSize: root.fontSize
                                                                        font.family: root.fontFamily

                                                                        MouseArea {
                                                                            anchors.fill: parent
                                                                            onClicked: root.closeNotification(notif.uid)
                                                                        }
                                                                    }
                                                                }

                                                                Text {
                                                                    visible: notif.body !== ""
                                                                    Layout.fillWidth: true
                                                                    text: notif.body
                                                                    color: root.colFg
                                                                    font.pixelSize: root.fontSize - 1
                                                                    font.family: root.fontFamily
                                                                    wrapMode: Text.Wrap
                                                                    textFormat: Text.PlainText
                                                                }

                                                                RowLayout {
                                                                    visible: notif.actions.length > 0
                                                                    Layout.fillWidth: true
                                                                    spacing: 6

                                                                    Repeater {
                                                                        model: notif.actions

                                                                        Rectangle {
                                                                            required property var modelData
                                                                            property var action: modelData

                                                                            radius: 6
                                                                            color: root.colPurple
                                                                            implicitWidth: actionText.implicitWidth + 14
                                                                            implicitHeight: actionText.implicitHeight + 8

                                                                            Text {
                                                                                id: actionText
                                                                                anchors.centerIn: parent
                                                                                text: action.text
                                                                                color: root.colBg
                                                                                font.pixelSize: root.fontSize - 2
                                                                                font.family: root.fontFamily
                                                                                font.bold: true
                                                                            }

                                                                            MouseArea {
                                                                                anchors.fill: parent
                                                                                onClicked: action.invoke()
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Timer {
                    interval: 180
                    running: root.notificationCenterClosing
                    repeat: false
                    onTriggered: {
                        if (!root.notificationCenterOpen) {
                            root.notificationCenterClosing = false
                            root.notificationCenterScreen = null
                        }
                    }
                }
            }

            PopupWindow {
                anchor.window: panelWindow
                anchor.rect.x: panelWindow.width - implicitWidth - 12
                anchor.rect.y: panelWindow.height + 8
                implicitWidth: 360
                implicitHeight: Math.min(toastList.contentHeight + 12, 320)
                visible: root.popupNotificationItems.length > 0
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    ListView {
                        id: toastList
                        anchors.fill: parent
                        anchors.margins: 6
                        clip: true
                        spacing: 8
                        interactive: contentHeight > height
                        model: root.popupNotificationItems

                        move: Transition {
                            NumberAnimation {
                                property: "y"
                                duration: 320
                                easing.type: Easing.OutCubic
                            }
                        }

                        displaced: Transition {
                            NumberAnimation {
                                property: "y"
                                duration: 320
                                easing.type: Easing.OutCubic
                            }
                        }

                        delegate: Item {
                            id: toastWrapper

                            required property int index
                            required property string uid
                            required property string summary
                            required property string body
                            required property string appName

                            width: toastList.width
                            implicitHeight: toastCard.implicitHeight

                            ListView.onRemove: removeAnim.start()

                            SequentialAnimation {
                                id: removeAnim

                                PropertyAction {
                                    target: toastWrapper
                                    property: "ListView.delayRemove"
                                    value: true
                                }
                                PropertyAction {
                                    target: toastWrapper
                                    property: "enabled"
                                    value: false
                                }
                                PropertyAction {
                                    target: toastWrapper
                                    property: "implicitHeight"
                                    value: 0
                                }
                                NumberAnimation {
                                    target: toastCard
                                    property: "x"
                                    to: toastCard.width * 2
                                    duration: 260
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    target: toastCard
                                    property: "opacity"
                                    to: 0
                                    duration: 220
                                    easing.type: Easing.OutCubic
                                }
                                PropertyAction {
                                    target: toastWrapper
                                    property: "ListView.delayRemove"
                                    value: false
                                }
                            }

                            Rectangle {
                                id: toastCard
                                width: parent.width
                                radius: 10
                                color: root.colSurface
                                border.width: 1
                                border.color: root.colMuted
                                implicitHeight: toastLayout.implicitHeight + 16
                                x: width
                                opacity: 1

                                Component.onCompleted: x = 0

                                Behavior on x {
                                    NumberAnimation {
                                        duration: 360
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.22
                                    }
                                }

                                Behavior on implicitHeight {
                                    NumberAnimation {
                                        duration: 240
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Timer {
                                    interval: 5000
                                    running: true
                                    repeat: false
                                    onTriggered: root.expirePopup(uid)
                                }

                                ColumnLayout {
                                    id: toastLayout
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: appName || "Notification"
                                            color: root.colBlue
                                            font.pixelSize: root.fontSize - 1
                                            font.family: root.fontFamily
                                            font.bold: true
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: "✕"
                                            color: root.colMuted
                                            font.pixelSize: root.fontSize
                                            font.family: root.fontFamily

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: root.closeNotification(uid)
                                            }
                                        }
                                    }

                                    Text {
                                        text: summary
                                        color: root.colFg
                                        font.pixelSize: root.fontSize
                                        font.family: root.fontFamily
                                        font.bold: true
                                        wrapMode: Text.Wrap
                                        textFormat: Text.PlainText
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        visible: body !== ""
                                        text: body
                                        color: root.colFg
                                        font.pixelSize: root.fontSize - 1
                                        font.family: root.fontFamily
                                        wrapMode: Text.Wrap
                                        textFormat: Text.PlainText
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
