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

    // Catpuccin frappe.
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
    property var expandedNotificationGroups: []
    property var animatedPopupUids: []

    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    property int animExpressiveDefaultSpatial: 500
    property var easingExpressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]

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

    function isNotificationGroupExpanded(appName) {
        return expandedNotificationGroups.indexOf(appName) >= 0
    }

    function toggleNotificationGroup(appName) {
        if (isNotificationGroupExpanded(appName)) {
            expandedNotificationGroups = expandedNotificationGroups.filter(name => name !== appName)
        } else {
            expandedNotificationGroups = [appName].concat(expandedNotificationGroups)
        }
    }

    function clearNotificationGroup(appName) {
        for (const item of notificationItems.filter(item => !item.closed && ((item.appName && item.appName !== "" ? item.appName : "Notifications") === appName))) {
            closeNotification(item.uid)
        }
    }

    function clearAllNotifications() {
        for (const item of notificationItems.filter(item => !item.closed)) {
            closeNotification(item.uid)
        }
    }

    function notificationGroupIcon(group) {
        const item = group.items.find(item => item.appIcon !== "")
        return item ? item.appIcon : ""
    }

    component CaelestiaSpatialAnim: NumberAnimation {
        duration: root.animExpressiveDefaultSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: root.easingExpressiveDefaultSpatial
    }

    component CaelestiaColorAnim: ColorAnimation {
        duration: root.animExpressiveDefaultSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: root.easingExpressiveDefaultSpatial
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

            notificationItems = [item].concat(notificationItems)
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
                implicitWidth: 390
                implicitHeight: 500
                visible: (root.notificationCenterOpen || root.notificationCenterClosing) && root.notificationCenterScreen === panelWindow.screen
                color: "transparent"

                Rectangle {
                    id: centerCard
                    property bool active: root.notificationCenterOpen && root.notificationCenterScreen === panelWindow.screen
                    property real slideX: width + 5

                    width: parent.width
                    height: parent.height
                    radius: 12
                    color: root.colBg
                    border.width: 1
                    border.color: root.colOverlay
                    clip: true
                    x: slideX

                    Component.onCompleted: {
                        slideX = width + 5
                        if (active) {
                            Qt.callLater(() => {
                                slideX = 0
                            })
                        }
                    }

                    onActiveChanged: {
                        slideX = active ? 0 : width + 5
                    }

                    Behavior on slideX {
                        CaelestiaSpatialAnim {}
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                            Layout.preferredHeight: 28

                            Text {
                                text: root.activeNotificationItems.length > 0
                                    ? root.activeNotificationItems.length + " notification" + (root.activeNotificationItems.length === 1 ? "" : "s")
                                    : "Notifications"
                                color: root.colMuted
                                font.pixelSize: root.fontSize
                                font.family: root.fontFamily
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                visible: root.activeNotificationItems.length > 0
                                Layout.preferredWidth: clearText.implicitWidth + 18
                                Layout.preferredHeight: 26
                                radius: 999
                                color: clearMouse.containsMouse ? root.colOverlay : root.colSurface

                                Text {
                                    id: clearText
                                    anchors.centerIn: parent
                                    text: "Clear"
                                    color: root.colFg
                                    font.pixelSize: root.fontSize - 2
                                    font.family: root.fontFamily
                                    font.bold: true
                                }

                                MouseArea {
                                    id: clearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.clearAllNotifications()
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            Text {
                                anchors.centerIn: parent
                                visible: root.activeNotificationItems.length === 0
                                text: "No notifications"
                                color: root.colMuted
                                font.pixelSize: root.fontSize + 1
                                font.family: root.fontFamily
                                font.bold: true
                            }

                            ListView {
                                id: centerList
                                anchors.fill: parent
                                clip: true
                                spacing: 8
                                interactive: contentHeight > height
                                boundsBehavior: Flickable.StopAtBounds
                                model: root.groupedNotificationItems

                                add: Transition {
                                    CaelestiaSpatialAnim {
                                        property: "x"
                                        from: centerList.width
                                        to: 0
                                    }
                                }

                                remove: Transition {
                                    CaelestiaSpatialAnim {
                                        property: "x"
                                        to: centerList.width
                                    }
                                }

                                move: Transition {
                                    CaelestiaSpatialAnim {
                                        property: "y"
                                    }
                                }

                                displaced: Transition {
                                    CaelestiaSpatialAnim {
                                        property: "y"
                                    }
                                }

                                delegate: MouseArea {
                                    id: groupWrapper

                                    required property var modelData
                                    property var group: modelData
                                    property bool expanded: root.isNotificationGroupExpanded(group.appName)
                                    property real startY: 0

                                    width: centerList.width
                                    implicitHeight: groupCard.implicitHeight
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                    preventStealing: true
                                    drag.target: groupWrapper
                                    drag.axis: Drag.XAxis

                                    onPressed: event => {
                                        startY = event.y
                                        if (event.button === Qt.RightButton) {
                                            root.toggleNotificationGroup(group.appName)
                                        } else if (event.button === Qt.MiddleButton) {
                                            root.clearNotificationGroup(group.appName)
                                        }
                                    }

                                    onPositionChanged: event => {
                                        if (pressed && Math.abs(event.y - startY) > 28) {
                                            const shouldExpand = event.y > startY
                                            if (shouldExpand !== root.isNotificationGroupExpanded(group.appName)) {
                                                root.toggleNotificationGroup(group.appName)
                                            }
                                        }
                                    }

                                    onReleased: {
                                        if (Math.abs(x) > width * 0.35) {
                                            root.clearNotificationGroup(group.appName)
                                        }
                                        x = 0
                                    }

                                    Behavior on x {
                                        CaelestiaSpatialAnim {}
                                    }

                                    Rectangle {
                                        id: groupCard

                                        width: parent.width
                                        radius: 12
                                        color: root.colSurface
                                        border.width: 1
                                        border.color: groupWrapper.expanded ? root.colPurple : root.colOverlay
                                        implicitHeight: groupContent.implicitHeight + 18
                                        clip: true

                                        Behavior on implicitHeight {
                                            CaelestiaSpatialAnim {}
                                        }

                                        Behavior on border.color {
                                            CaelestiaColorAnim {}
                                        }

                                        ColumnLayout {
                                            id: groupContent
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.margins: 9
                                            spacing: groupWrapper.expanded ? 8 : 3

                                            Behavior on spacing {
                                                CaelestiaSpatialAnim {}
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 9

                                                Rectangle {
                                                    Layout.preferredWidth: 34
                                                    Layout.preferredHeight: 34
                                                    radius: 999
                                                    color: root.notificationGroupIcon(group) !== "" ? root.colOverlay : root.colBg

                                                    Loader {
                                                        anchors.centerIn: parent
                                                        active: root.notificationGroupIcon(group) !== ""

                                                        sourceComponent: IconImage {
                                                            implicitSize: 20
                                                            source: Quickshell.iconPath(root.notificationGroupIcon(group))
                                                        }
                                                    }

                                                    Text {
                                                        anchors.centerIn: parent
                                                        visible: root.notificationGroupIcon(group) === ""
                                                        text: ""
                                                        color: root.colPurple
                                                        font.pixelSize: root.fontSize
                                                        font.family: root.fontFamily
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 0

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: group.appName
                                                        color: root.colFg
                                                        font.pixelSize: root.fontSize
                                                        font.family: root.fontFamily
                                                        font.bold: true
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: group.items[0]?.summary ?? "Notification"
                                                        color: root.colMuted
                                                        font.pixelSize: root.fontSize - 2
                                                        font.family: root.fontFamily
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.preferredWidth: countLabel.implicitWidth + 16
                                                    Layout.preferredHeight: 26
                                                    radius: 999
                                                    color: root.colOverlay

                                                    Text {
                                                        id: countLabel
                                                        anchors.centerIn: parent
                                                        text: group.items.length
                                                        color: root.colFg
                                                        font.pixelSize: root.fontSize - 2
                                                        font.family: root.fontFamily
                                                        font.bold: true
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: root.toggleNotificationGroup(group.appName)
                                                    }
                                                }

                                                Text {
                                                    text: "⌄"
                                                    color: root.colMuted
                                                    font.pixelSize: root.fontSize + 2
                                                    font.family: root.fontFamily
                                                    rotation: groupWrapper.expanded ? 180 : 0

                                                    Behavior on rotation {
                                                        CaelestiaSpatialAnim {}
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: root.toggleNotificationGroup(group.appName)
                                                    }
                                                }
                                            }

                                            Repeater {
                                                model: groupWrapper.expanded ? group.items : group.items.slice(0, 2)

                                                delegate: Rectangle {
                                                    id: notifCard

                                                    required property var modelData
                                                    property var notif: modelData

                                                    Layout.fillWidth: true
                                                    radius: 8
                                                    color: groupWrapper.expanded ? root.colBg : "transparent"
                                                    border.width: groupWrapper.expanded ? 1 : 0
                                                    border.color: root.colOverlay
                                                    implicitHeight: notifLayout.implicitHeight + (groupWrapper.expanded ? 16 : 0)
                                                    clip: true

                                                    Behavior on implicitHeight {
                                                        CaelestiaSpatialAnim {}
                                                    }

                                                    ColumnLayout {
                                                        id: notifLayout
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                        anchors.top: parent.top
                                                        anchors.margins: groupWrapper.expanded ? 8 : 0
                                                        spacing: groupWrapper.expanded ? 6 : 2

                                                        RowLayout {
                                                            Layout.fillWidth: true

                                                            Text {
                                                                Layout.fillWidth: true
                                                                text: notif.summary || "Notification"
                                                                color: root.colFg
                                                                font.pixelSize: root.fontSize - (groupWrapper.expanded ? 0 : 1)
                                                                font.family: root.fontFamily
                                                                font.bold: true
                                                                elide: groupWrapper.expanded ? Text.ElideNone : Text.ElideRight
                                                                wrapMode: groupWrapper.expanded ? Text.WordWrap : Text.NoWrap
                                                                maximumLineCount: groupWrapper.expanded ? 3 : 1
                                                            }

                                                            Text {
                                                                visible: groupWrapper.expanded
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
                                                            visible: groupWrapper.expanded && notif.body !== ""
                                                            Layout.fillWidth: true
                                                            text: notif.body
                                                            color: root.colMuted
                                                            font.pixelSize: root.fontSize - 1
                                                            font.family: root.fontFamily
                                                            wrapMode: Text.WordWrap
                                                            textFormat: Text.PlainText
                                                        }

                                                        RowLayout {
                                                            visible: groupWrapper.expanded && notif.actions.length > 0
                                                            Layout.fillWidth: true
                                                            spacing: 6

                                                            Rectangle {
                                                                radius: 6
                                                                color: root.colSurface
                                                                implicitWidth: closeActionText.implicitWidth + 14
                                                                implicitHeight: closeActionText.implicitHeight + 8

                                                                Text {
                                                                    id: closeActionText
                                                                    anchors.centerIn: parent
                                                                    text: "Close"
                                                                    color: root.colFg
                                                                    font.pixelSize: root.fontSize - 2
                                                                    font.family: root.fontFamily
                                                                    font.bold: true
                                                                }

                                                                MouseArea {
                                                                    anchors.fill: parent
                                                                    onClicked: root.closeNotification(notif.uid)
                                                                }
                                                            }

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

                Timer {
                    interval: root.animExpressiveDefaultSpatial
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
                            CaelestiaSpatialAnim {
                                property: "y"
                            }
                        }

                        displaced: Transition {
                            CaelestiaSpatialAnim {
                                property: "y"
                            }
                        }

                        delegate: Item {
                            id: toastWrapper

                            required property int index
                            required property string uid
                            required property string summary
                            required property string body
                            required property string appName
                            property bool shouldAnimateEntry: root.animatedPopupUids.indexOf(uid) < 0

                            width: toastList.width
                            implicitHeight: toastCard.implicitHeight

                            Component.onCompleted: {
                                if (shouldAnimateEntry) {
                                    root.animatedPopupUids = [uid].concat(root.animatedPopupUids)
                                    toastCard.x = toastCard.width
                                    toastEnterAnim.start()
                                } else {
                                    toastCard.x = 0
                                }
                            }

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
                                    property: "z"
                                    value: 1
                                }
                                ParallelAnimation {
                                    CaelestiaSpatialAnim {
                                        target: toastCard
                                        property: "x"
                                        to: toastCard.width * 2
                                    }
                                    CaelestiaSpatialAnim {
                                        target: toastWrapper
                                        property: "implicitHeight"
                                        to: 0
                                    }
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
                                x: 0

                                CaelestiaSpatialAnim {
                                    id: toastEnterAnim
                                    target: toastCard
                                    property: "x"
                                    to: 0
                                }

                                Behavior on implicitHeight {
                                    CaelestiaSpatialAnim {}
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
