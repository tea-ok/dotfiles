import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var theme
    required property var notifications
    required property bool expanded
    required property var modelData

    property var notif: modelData

    Layout.fillWidth: true
    radius: 8
    color: expanded ? theme.colBg : "transparent"
    border.width: expanded ? 1 : 0
    border.color: theme.colOverlay
    implicitHeight: notifLayout.implicitHeight + (expanded ? 16 : 0)
    clip: true

    ColumnLayout {
        id: notifLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: expanded ? 8 : 0
        spacing: expanded ? 6 : 2

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: notif.summary || "Notification"
                color: theme.colFg
                font.pixelSize: theme.fontSize - (expanded ? 0 : 1)
                font.family: theme.fontFamily
                font.bold: true
                elide: expanded ? Text.ElideNone : Text.ElideRight
                wrapMode: expanded ? Text.WordWrap : Text.NoWrap
                maximumLineCount: expanded ? 3 : 1
            }

            Text {
                visible: expanded
                text: "✕"
                color: theme.colMuted
                font.pixelSize: theme.fontSize
                font.family: theme.fontFamily

                MouseArea {
                    anchors.fill: parent
                    onClicked: notifications.close(notif.uid)
                }
            }
        }

        Text {
            visible: expanded && notif.body !== ""
            Layout.fillWidth: true
            text: notif.body
            color: theme.colMuted
            font.pixelSize: theme.fontSize - 1
            font.family: theme.fontFamily
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
        }

        RowLayout {
            visible: expanded && notif.actions.length > 0
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                radius: 6
                color: theme.colSurface
                implicitWidth: closeActionText.implicitWidth + 14
                implicitHeight: closeActionText.implicitHeight + 8

                Text {
                    id: closeActionText
                    anchors.centerIn: parent
                    text: "Close"
                    color: theme.colFg
                    font.pixelSize: theme.fontSize - 2
                    font.family: theme.fontFamily
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: notifications.close(notif.uid)
                }
            }

            Repeater {
                model: notif.actions

                Rectangle {
                    required property var modelData
                    property var action: modelData

                    radius: 6
                    color: theme.colPurple
                    implicitWidth: actionText.implicitWidth + 14
                    implicitHeight: actionText.implicitHeight + 8

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: action.text
                        color: theme.colBg
                        font.pixelSize: theme.fontSize - 2
                        font.family: theme.fontFamily
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
