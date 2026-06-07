import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var theme
    required property var notifications
    required property var screenRef

    Layout.preferredWidth: notifications.unreadCount > 0 ? 54 : 28
    Layout.preferredHeight: 22
    Layout.alignment: Qt.AlignVCenter
    Layout.rightMargin: 8
    radius: 6
    color: notifications.centerOpen && notifications.centerScreen === screenRef
        ? theme.colSurface
        : "transparent"

    Text {
        anchors.centerIn: parent
        text: notifications.unreadCount > 0 ? " " + notifications.unreadCount : ""
        color: theme.colFg
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: notifications.toggleCenter(screenRef)
    }
}
