import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Repeater {
    required property var theme

    model: 9

    Rectangle {
        Layout.preferredWidth: 20
        Layout.preferredHeight: parent.height
        color: "transparent"

        property var workspace: {
            const match = Hyprland.workspaces.values.find(ws => ws.id === index + 1)
            return match ? match : null
        }
        property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1
        property bool hasWindows: workspace !== null

        Text {
            anchors.centerIn: parent
            text: index + 1
            color: parent.isActive ? theme.colCyan : (parent.hasWindows ? theme.colCyan : theme.colMuted)
            font.pixelSize: theme.fontSize
            font.family: theme.fontFamily
            font.bold: true
        }

        Rectangle {
            width: 20
            height: 3
            color: parent.isActive ? theme.colPurple : theme.colBg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Hyprland.dispatch("workspace " + (index + 1))
        }
    }
}
