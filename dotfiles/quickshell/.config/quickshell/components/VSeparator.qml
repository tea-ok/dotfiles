import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var theme

    Layout.preferredWidth: 1
    Layout.preferredHeight: 16
    Layout.alignment: Qt.AlignVCenter
    color: theme.colMuted
}
