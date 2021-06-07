import QtQuick 2.7

MouseArea {
    id: root
    propagateComposedEvents: true

    property var control: parent

    onClicked: { mouse.accepted = false; }
    onDoubleClicked: { mouse.accepted = false; }
    onPositionChanged: { mouse.accepted = false; }
    onPressed: {
        if (control)
            control.focus = true;
        mouse.accepted = false;
    }
    onReleased: { mouse.accepted = false; }
    onWheel: { wheel.accepted = false; }
    onPressAndHold: { mouse.accepted = false; }
}
