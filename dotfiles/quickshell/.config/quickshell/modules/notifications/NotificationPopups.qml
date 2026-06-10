import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../components"

PopupWindow {
    id: popupRoot

    required property var theme
    required property var notifications
    required property var anchorWindow

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow.width - implicitWidth - 12
    anchor.rect.y: anchorWindow.height + 8
    implicitWidth: 360
    implicitHeight: Math.min(toastList.contentHeight + 12, 320)
    visible: notifications.popupItems.length > 0
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
            model: notifications.popupItems

            move: Transition {
                SpatialAnim {
                    theme: popupRoot.theme
                    property: "y"
                }
            }

            displaced: Transition {
                SpatialAnim {
                    theme: popupRoot.theme
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
                property bool shouldAnimateEntry: notifications.animatedPopupUids.indexOf(uid) < 0

                width: toastList.width
                implicitHeight: toastCard.implicitHeight

                Component.onCompleted: {
                    if (shouldAnimateEntry) {
                        notifications.animatedPopupUids = [uid].concat(notifications.animatedPopupUids)
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
                        SpatialAnim {
                            theme: popupRoot.theme
                            target: toastCard
                            property: "x"
                            to: toastCard.width * 2
                        }
                        SpatialAnim {
                            theme: popupRoot.theme
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
                    color: theme.colSurface
                    border.width: 1
                    border.color: theme.colMuted
                    implicitHeight: toastLayout.implicitHeight + 16
                    x: 0

                    SpatialAnim {
                        id: toastEnterAnim
                        theme: popupRoot.theme
                        target: toastCard
                        property: "x"
                        to: 0
                    }

                    Behavior on implicitHeight {
                        SpatialAnim { theme: popupRoot.theme }
                    }

                    Timer {
                        interval: 5000
                        running: true
                        repeat: false
                        onTriggered: notifications.expirePopup(uid)
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
                                color: theme.colBlue
                                font.pixelSize: theme.fontSize - 1
                                font.family: theme.fontFamily
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "✕"
                                color: theme.colMuted
                                font.pixelSize: theme.fontSize
                                font.family: theme.fontFamily

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: notifications.close(uid)
                                }
                            }
                        }

                        Text {
                            text: summary
                            color: theme.colFg
                            font.pixelSize: theme.fontSize
                            font.family: theme.fontFamily
                            font.bold: true
                            wrapMode: Text.Wrap
                            textFormat: Text.PlainText
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: body !== ""
                            text: body
                            color: theme.colFg
                            font.pixelSize: theme.fontSize - 1
                            font.family: theme.fontFamily
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
