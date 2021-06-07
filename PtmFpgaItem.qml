import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import Cadence.Prototyping.Extensions 1.0

Rectangle {
    id: root
    color: "transparent"
    width: 160
    height: 114
    border {
        color: bgMouseArea.containsMouse || labelMouseArea.containsMouse ?
                      "#2da7df" : ""
        width: bgMouseArea.containsMouse || labelMouseArea.containsMouse ?
                      2 : 0
    }

    signal mouseLeftClicked;
    signal mouseRightClicked;
    signal mouseDoubleClicked;

    readonly property string itemType: "fpga"

    property string label
    property string fullName
    property bool used: true
    property string usedType: ""
    property string usedLabel: ""
    property int usedIdx: -1
    property string usedData: ""
    property bool anchorLabelToTop: true /* otherwise, anchor to bottom */

    Image {
        id: bg
        source: used ? "images/fpga.png" : "images/fpga_disabled.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: anchorLabelToTop ? 19.4 : 4

        MaskedMouseArea {
            id: bgMouseArea
            anchors.fill: parent
            alphaThreshold: 0.4
            maskSource: bg.source
            onClicked: {
                if (button === Qt.RightButton)
                    mouseRightClicked();
                else if (button === Qt.LeftButton)
                    mouseLeftClicked();
            }
            onDoubleClicked: mouseDoubleClicked()
        }
    }

    Rectangle {
        width: 24
        height: 24
        color: used ? "#f8de1c" : "#e7e7e7"
        anchors.horizontalCenter: bg.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: anchorLabelToTop ? 4 : 86

        Text {
            text: label
            font {
                family: "Lato-Regular"
                pointSize: 18
                bold: bgMouseArea.containsMouse || labelMouseArea.containsMouse
            }
            color: used ? "#000000" : "#999999"
            anchors.centerIn: parent
        }

        MouseArea {
            id: labelMouseArea
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            onClicked: {
                if (mouse.button === Qt.RightButton)
                    mouseRightClicked();
                else if (mouse.button === Qt.LeftButton)
                    mouseLeftClicked();
            }
            onDoubleClicked: mouseDoubleClicked()
        }
    }
}
