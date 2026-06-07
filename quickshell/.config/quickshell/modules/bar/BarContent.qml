import QtQuick
import QtQuick.Layouts
import "../../components"

RowLayout {
    required property var theme
    required property var hyprState
    required property var stats
    required property var notifications
    required property var screenRef

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

    Workspaces {
        theme: parent.theme
    }

    VSeparator {
        theme: parent.theme
        Layout.leftMargin: 8
        Layout.rightMargin: 8
    }

    Text {
        text: hyprState.currentLayout
        color: theme.colFg
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.leftMargin: 5
        Layout.rightMargin: 5
    }

    VSeparator {
        theme: parent.theme
        Layout.leftMargin: 2
        Layout.rightMargin: 8
    }

    Text {
        text: hyprState.activeWindow
        color: theme.colPurple
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.fillWidth: true
        Layout.leftMargin: 8
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    SystemIndicators {
        theme: parent.theme
        stats: parent.stats
    }

    NotificationButton {
        theme: parent.theme
        notifications: parent.notifications
        screenRef: parent.screenRef
    }

    Clock {
        theme: parent.theme
    }

    Item { width: 8 }
}
