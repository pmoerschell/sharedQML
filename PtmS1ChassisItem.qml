import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "Hardware.js" as Hardware
import "Map.js" as Map
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root
    width: 140
    height: 290

    /*
      Supported types: chassis, board
      */
    signal mouseLeftClicked(string type, string name)
    signal mouseDoubleClicked(string type, string name)
    signal mouseRightClicked(string type, string name)

    property alias label: chassisLabel.text
    property string fullName
    property bool used: true
    property var boards: []

    function updateUnitStatus(name, enabled, used, userData, connectedItems)
    {
        console.log("Chassis child unit " + name + " status (" + enabled + ":" +
                    used + "), user data: " + userData + " updated");
        var item = Map.value(name);
        if (!item) {
            var fname = "";
            // find the first empty slot
            for (var i = 0; i < boardRepeater.model; i++) {
                // discard alien units
                fname = Hardware.boardFullName(root.fullName, i, boards);
                if (fname !== name)
                    continue;

                item = Map.value(i);
                if (item)
                    break;
            }
        }
        if (item) {
            console.log("found item : " + item.label);
            item.enabled = enabled || used;
            item.used = used;
        }
    }

    Component.onCompleted: {
        Map.setValue(fullName, this);
    }

    MouseArea {
        id: rootMouseArea
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        onClicked: {
            if (mouse.button === Qt.RightButton)
                mouseRightClicked("chassis", fullName);
            else if (mouse.button === Qt.LeftButton)
                mouseLeftClicked("chassis", fullName);
        }
        onDoubleClicked: mouseDoubleClicked("chassis", fullName)

        Item {
            anchors.fill: parent

            // chassis background
            Image {
                anchors.fill: parent
                source: "images/s1_chassis_bg.png"
                fillMode: Image.PreserveAspectCrop
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    height: 40

                    Text {
                        id: chassisLabel
                        color: used ? "white" : "#7f7f7f"
                        font {
                            family: "Lato-Black"
                            pointSize: 14
                            bold: true
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Row {
                        anchors.fill: parent
                        spacing: 10

                        Repeater {
                            anchors.fill: parent
                            id: boardRepeater
                            model: 2
                            Item {
                                // wrapper item is needed to resize layout after
                                // rotating of wrapped item
                                implicitWidth: 40
                                implicitHeight: 220

                                PtmChassisBoardItem {
                                    // TODO: find a better way to position,
                                    // when item is rotated
                                    x: -65
                                    y: 90

                                    rotation: 270
                                    idx: index

                                    onUsedChanged: {
                                        if (used) {
                                            Map.remove(idx);
                                            label = Hardware.boardLabel(idx, boards);
                                            fullName = Hardware.boardFullName(
                                                        root.fullName, idx, boards);
                                            Map.setValue(fullName, this);
                                        } else {
                                            Map.remove(fullName);
                                            label = Hardware.boardLabel(idx, boards);
                                            fullName = Hardware.boardFullName(
                                                        root.fullName, idx, boards);
                                            Map.setValue(idx, this);
                                        }
                                    }

                                    onMouseLeftClicked: {
                                        root.mouseLeftClicked("board", fullName);
                                    }
                                    onMouseRightClicked: {
                                        root.mouseRightClicked("board", fullName);
                                    }
                                    onMouseDoubleClicked: {
                                        root.mouseDoubleClicked("board", fullName)
                                    }
                                    Component.onCompleted: {
                                        label = Hardware.boardLabel(index, boards);
                                        fullName = Hardware.boardFullName(
                                                    root.fullName, index, boards);
                                        used = (fullName !== "");

                                        Map.setValue((used ? fullName : idx), this);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
