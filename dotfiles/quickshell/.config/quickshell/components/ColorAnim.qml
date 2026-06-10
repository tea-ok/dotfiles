import QtQuick

ColorAnimation {
    required property var theme

    duration: theme.animExpressiveDefaultSpatial
    easing.type: Easing.BezierSpline
    easing.bezierCurve: theme.easingExpressiveDefaultSpatial
}
