import QtQuick
import QtQuick.Layouts

Text {
    required property var theme

    text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    color: theme.colCyan
    font.pixelSize: theme.fontSize
    font.family: theme.fontFamily
    font.bold: true
    Layout.rightMargin: 8

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: parent.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    }
}
