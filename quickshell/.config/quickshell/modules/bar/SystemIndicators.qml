import QtQuick
import QtQuick.Layouts
import "../../components"

RowLayout {
    required property var theme
    required property var stats

    spacing: 0

    Text {
        text: "CPU: " + stats.cpuUsage + "%"
        color: theme.colYellow
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.rightMargin: 8
    }

    VSeparator {
        theme: parent.theme
        Layout.rightMargin: 8
    }

    Text {
        text: "Mem: " + stats.memUsage + "%"
        color: theme.colCyan
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.rightMargin: 8
    }

    VSeparator {
        theme: parent.theme
        Layout.rightMargin: 8
    }

    Text {
        text: "Vol: " + stats.volumeLevel + "%"
        color: theme.colPurple
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.rightMargin: 8
    }
}
