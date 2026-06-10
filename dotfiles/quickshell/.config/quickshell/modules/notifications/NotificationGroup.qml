import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../components"

MouseArea {
    id: groupWrapper

    required property var theme
    required property var notifications
    required property var listView
    required property var modelData

    property var group: modelData

    property string appName: group && typeof group.appName === "string" && group.appName !== "" ? group.appName : "Notifications"
    property var items: group && group.items ? group.items : []
    property bool expanded: notifications.isGroupExpanded(appName)
    property real startY: 0

    width: listView.width
    implicitHeight: groupCard.implicitHeight
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    preventStealing: true
    drag.target: groupWrapper
    drag.axis: Drag.XAxis

    onPressed: event => {
        startY = event.y
        if (event.button === Qt.RightButton) {
            notifications.toggleGroup(appName)
        } else if (event.button === Qt.MiddleButton) {
            notifications.clearGroup(appName)
        }
    }

    onPositionChanged: event => {
        if (pressed && Math.abs(event.y - startY) > 28) {
            const shouldExpand = event.y > startY
            if (shouldExpand !== notifications.isGroupExpanded(appName)) {
                notifications.toggleGroup(appName)
            }
        }
    }

    onReleased: {
        if (Math.abs(x) > width * 0.35) {
            notifications.clearGroup(appName)
        }
        x = 0
    }

    Behavior on x {
        SpatialAnim { theme: groupWrapper.theme }
    }

    Rectangle {
        id: groupCard

        width: parent.width
        radius: 12
        color: theme.colSurface
        border.width: 1
        border.color: groupWrapper.expanded ? theme.colPurple : theme.colOverlay
        implicitHeight: groupContent.implicitHeight + 18
        clip: true

        Behavior on implicitHeight {
            SpatialAnim { theme: groupWrapper.theme }
        }

        Behavior on border.color {
            ColorAnim { theme: groupWrapper.theme }
        }

        ColumnLayout {
            id: groupContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 9
            spacing: groupWrapper.expanded ? 8 : 3

            Behavior on spacing {
                SpatialAnim { theme: groupWrapper.theme }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 9

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 999
                    color: notifications.groupIcon(group) !== "" ? theme.colOverlay : theme.colBg

                    Loader {
                        anchors.centerIn: parent
                        active: notifications.groupIcon(group) !== ""

                        sourceComponent: IconImage {
                            implicitSize: 20
                            source: Quickshell.iconPath(notifications.groupIcon(group))
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: notifications.groupIcon(group) === ""
                        text: ""
                        color: theme.colPurple
                        font.pixelSize: theme.fontSize
                        font.family: theme.fontFamily
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: appName
                        color: theme.colFg
                        font.pixelSize: theme.fontSize
                        font.family: theme.fontFamily
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: items.length > 0 && items[0] && items[0].summary ? items[0].summary : "Notification"
                        color: theme.colMuted
                        font.pixelSize: theme.fontSize - 2
                        font.family: theme.fontFamily
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    Layout.preferredWidth: countLabel.implicitWidth + 16
                    Layout.preferredHeight: 26
                    radius: 999
                    color: theme.colOverlay

                    Text {
                        id: countLabel
                        anchors.centerIn: parent
                        text: items.length
                        color: theme.colFg
                        font.pixelSize: theme.fontSize - 2
                        font.family: theme.fontFamily
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: notifications.toggleGroup(appName)
                    }
                }

                Text {
                    text: "⌄"
                    color: theme.colMuted
                    font.pixelSize: theme.fontSize + 2
                    font.family: theme.fontFamily
                    rotation: groupWrapper.expanded ? 180 : 0

                    Behavior on rotation {
                        SpatialAnim { theme: groupWrapper.theme }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: notifications.toggleGroup(appName)
                    }
                }
            }

            Repeater {
                model: groupWrapper.expanded ? items : (items && items.slice ? items.slice(0, 2) : [])

                delegate: NotificationItem {
                    theme: groupWrapper.theme
                    notifications: groupWrapper.notifications
                    expanded: groupWrapper.expanded

                    Behavior on implicitHeight {
                        SpatialAnim { theme: groupWrapper.theme }
                    }
                }
            }
        }
    }
}
