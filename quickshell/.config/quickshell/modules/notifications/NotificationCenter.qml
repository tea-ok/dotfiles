import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../components"

PopupWindow {
    id: centerRoot

    required property var theme
    required property var notifications
    required property var screenRef
    required property var anchorWindow

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow.width - implicitWidth - 12
    anchor.rect.y: anchorWindow.height + 8
    implicitWidth: 390
    implicitHeight: 500
    visible: (notifications.centerOpen || notifications.centerClosing) && notifications.centerScreen === screenRef
    color: "transparent"

    Rectangle {
        id: centerCard
        property bool active: notifications.centerOpen && notifications.centerScreen === screenRef
        property real slideX: width + 5

        width: parent.width
        height: parent.height
        radius: 12
        color: theme.colBg
        border.width: 1
        border.color: theme.colOverlay
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
            SpatialAnim { theme: centerRoot.theme }
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
                    text: notifications.activeItems.length > 0
                        ? notifications.activeItems.length + " notification" + (notifications.activeItems.length === 1 ? "" : "s")
                        : "Notifications"
                    color: theme.colMuted
                    font.pixelSize: theme.fontSize
                    font.family: theme.fontFamily
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Rectangle {
                    visible: notifications.activeItems.length > 0
                    Layout.preferredWidth: clearText.implicitWidth + 18
                    Layout.preferredHeight: 26
                    radius: 999
                    color: clearMouse.containsMouse ? theme.colOverlay : theme.colSurface

                    Text {
                        id: clearText
                        anchors.centerIn: parent
                        text: "Clear"
                        color: theme.colFg
                        font.pixelSize: theme.fontSize - 2
                        font.family: theme.fontFamily
                        font.bold: true
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: notifications.clearAll()
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Text {
                    anchors.centerIn: parent
                    visible: notifications.activeItems.length === 0
                    text: "No notifications"
                    color: theme.colMuted
                    font.pixelSize: theme.fontSize + 1
                    font.family: theme.fontFamily
                    font.bold: true
                }

                ListView {
                    id: centerList
                    anchors.fill: parent
                    clip: true
                    spacing: 8
                    interactive: contentHeight > height
                    boundsBehavior: Flickable.StopAtBounds
                    model: notifications.groupedItems

                    add: Transition {
                        SpatialAnim {
                            theme: centerRoot.theme
                            property: "x"
                            from: centerList.width
                            to: 0
                        }
                    }

                    remove: Transition {
                        SpatialAnim {
                            theme: centerRoot.theme
                            property: "x"
                            to: centerList.width
                        }
                    }

                    move: Transition {
                        SpatialAnim {
                            theme: centerRoot.theme
                            property: "y"
                        }
                    }

                    displaced: Transition {
                        SpatialAnim {
                            theme: centerRoot.theme
                            property: "y"
                        }
                    }

                    delegate: NotificationGroup {
                        theme: centerRoot.theme
                        notifications: centerRoot.notifications
                        listView: centerList
                    }
                }
            }
        }
    }

    Timer {
        interval: theme.animExpressiveDefaultSpatial
        running: notifications.centerClosing
        repeat: false
        onTriggered: notifications.finishClose()
    }
}
