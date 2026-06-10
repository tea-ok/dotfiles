import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Item {
    id: notificationsService

    property int unreadCount: 0
    property bool centerOpen: false
    property bool centerClosing: false
    property var centerScreen: null
    property var notificationItems: []
    property var activeItems: []
    property var popupItems: []
    property var groupedItems: []
    property var expandedGroups: []
    property var animatedPopupUids: []

    function sync() {
        activeItems = notificationItems.filter(item => !item.closed)
        popupItems = notificationItems.filter(item => item.popup && !item.closed)

        const groups = new Map()
        for (const item of activeItems) {
            const key = item.appName && item.appName !== "" ? item.appName : "Notifications"
            if (!groups.has(key)) {
                groups.set(key, [])
            }
            groups.get(key).push(item)
        }

        groupedItems = Array.from(groups, ([appName, items]) => ({
            appName: appName,
            items: items
        }))
    }

    function toggleCenter(screen) {
        if (centerOpen && centerScreen === screen) {
            centerOpen = false
            centerClosing = true
            return
        }

        centerClosing = false
        centerOpen = true
        centerScreen = screen
        unreadCount = 0
    }

    function finishClose() {
        if (!centerOpen) {
            centerClosing = false
            centerScreen = null
        }
    }

    function close(uid) {
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

        sync()
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
        sync()
    }

    function isGroupExpanded(appName) {
        return expandedGroups.indexOf(appName) >= 0
    }

    function toggleGroup(appName) {
        if (isGroupExpanded(appName)) {
            expandedGroups = expandedGroups.filter(name => name !== appName)
        } else {
            expandedGroups = [appName].concat(expandedGroups)
        }
    }

    function clearGroup(appName) {
        for (const item of notificationItems.filter(item => !item.closed && ((item.appName && item.appName !== "" ? item.appName : "Notifications") === appName))) {
            close(item.uid)
        }
    }

    function clearAll() {
        for (const item of notificationItems.filter(item => !item.closed)) {
            close(item.uid)
        }
    }

    function groupIcon(group) {
        const items = group && group.items ? group.items : []
        const item = items.find ? items.find(item => item.appIcon !== "") : null
        return item ? item.appIcon : ""
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

            notificationsService.notificationItems = [item].concat(notificationsService.notificationItems)
            notificationsService.sync()

            if (!notificationsService.centerOpen) {
                notificationsService.unreadCount += 1
            }
        }
    }
}
