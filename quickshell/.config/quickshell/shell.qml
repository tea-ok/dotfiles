import Quickshell
import QtQuick
import "modules/bar"
import "services"

ShellRoot {
    id: root

    Theme {
        id: theme
    }

    SystemStats {
        id: stats
    }

    HyprState {
        id: hyprState
    }

    Notifications {
        id: notifications
    }

    Bar {
        theme: theme
        hyprState: hyprState
        stats: stats
        notifications: notifications
    }
}
