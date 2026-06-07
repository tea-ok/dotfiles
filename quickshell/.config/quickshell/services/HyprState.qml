import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Item {
    id: hyprState

    property string activeWindow: "Window"
    property string currentLayout: "Tiled"
    property string primaryMonitorName: "DP-4"

    function barScreens() {
        const fallback = []

        for (let i = 0; i < Quickshell.screens.length; i++) {
            const screen = Quickshell.screens[i]
            if (i === 0) {
                fallback.push(screen)
            }
            if (screen.name === primaryMonitorName) {
                return [screen]
            }
        }

        return fallback
    }

    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    hyprState.activeWindow = data.trim()
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: layoutProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    hyprState.currentLayout = data.trim()
                }
            }
        }
        Component.onCompleted: running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent() {
            windowProc.running = true
            layoutProc.running = true
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true
            layoutProc.running = true
        }
    }
}
