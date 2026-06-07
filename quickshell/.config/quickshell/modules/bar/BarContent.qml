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

    Item {
        Layout.fillWidth: true
        implicitHeight: windowRow.implicitHeight

        Row {
            id: windowRow
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                id: activeWindowLabel
                width: Math.min(implicitWidth, Math.max(0, parent.parent.width - (magicLabel.visible ? magicLabel.implicitWidth + windowRow.spacing + windowRow.anchors.leftMargin : windowRow.anchors.leftMargin)))
                text: hyprState.activeWindow
                color: theme.colPurple
                font.pixelSize: theme.fontSize
                font.family: theme.fontFamily
                font.bold: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                id: magicLabel
                visible: hyprState.magicVisible
                text: "MAGIC"
                color: theme.colBlue
                font.pixelSize: theme.fontSize
                font.family: theme.fontFamily
                font.bold: true
            }
        }
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
