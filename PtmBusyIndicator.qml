import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4

Popup {
    id: root
    modal: true
    dim: false
    closePolicy: Popup.NoAutoClose
    x: 0
    y: 0
    width: parent.width
    height: parent.height

    Connections {
        target: parent
        onWaitFinished: close()
    }

    onOpened: indicator.running = true
    onClosed: indicator.running = false

    background: Rectangle {
        anchors.fill: parent
        color: 'transparent'
    }

    BusyIndicator {
        id: indicator
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: 50
        height: 50

//        style: BusyIndicatorStyle {
//            indicator: Image {
//                visible: indicator.running
//                source: "busy.png"
//                RotationAnimator on rotation {
//                    running: indicator.running
//                    loops: Animation.Infinite
//                    duration: 5000
//                    from: 0 ; to: 360
//                }
//            }
//        }
    }
}
