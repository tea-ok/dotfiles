import Quickshell
import Quickshell.Wayland
import QtQuick
import "../notifications"

Variants {
    id: barRoot

    required property var theme
    required property var hyprState
    required property var stats
    required property var notifications

    model: hyprState.barScreens()

    PanelWindow {
        id: panelWindow
        required property var modelData
        property var themeRef: barRoot.theme
        property var hyprStateRef: barRoot.hyprState
        property var statsRef: barRoot.stats
        property var notificationsRef: barRoot.notifications

        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 30
        color: theme.colBg

        margins {
            top: 0
            bottom: 0
            left: 0
            right: 0
        }

        Rectangle {
            anchors.fill: parent
            color: panelWindow.themeRef.colBg

            BarContent {
                theme: panelWindow.themeRef
                hyprState: panelWindow.hyprStateRef
                stats: panelWindow.statsRef
                notifications: panelWindow.notificationsRef
                screenRef: panelWindow.screen
            }
        }

        NotificationCenter {
            theme: panelWindow.themeRef
            notifications: panelWindow.notificationsRef
            screenRef: panelWindow.screen
            anchorWindow: panelWindow
        }

        NotificationPopups {
            theme: panelWindow.themeRef
            notifications: panelWindow.notificationsRef
            anchorWindow: panelWindow
        }
    }
}
