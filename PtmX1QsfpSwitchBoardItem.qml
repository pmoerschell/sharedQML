import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "Hardware.js" as Hardware
import "Map.js" as Map
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root
    width: 919
    height: 500

    /*
      Supported types: switchboard, switchboard_port
      */
    signal mouseLeftClicked(string type, string name)
    signal mouseDoubleClicked(string type, string name)
    signal mouseRightClicked(string type, string name)

    signal qsfpCableDropped(string title, string data, string connector)

    readonly property string itemType: "switchboard"

    property string fullName

    function updateUnitStatus(name, enabled, used, userData, connectedItems)
    {
        //console.log("QSFP switch child unit " + name + " status (" + enabled +
        //            ":" + used + "), user data: " + userData + " updated");
        var i;
        var itemNames;
        var idx;
        var otherItem;
        var item = Map.value(name);
        if (item) {
            //console.log("found item : " + item.label);
            item.enabled = enabled;
            item.used = used;
            switch (userData) {
                case 1003:
                    item.usedType = "cable";
                    if (connectedItems.length > 1) {
                        var c = connectedItems[1];
                        otherItem = Map.value(c.fullName);
                        if (otherItem) {
                            item.usedLabel = otherItem.label;
                            item.usedData = otherItem.fullName;
                            item.usedIdx = -1;
                        } else {
                            // could be connector on another board
                            // index of the other board
                            idx = -1;
                            if (c.parent) {
                                if (c.parent.parent)
                                    idx = c.parent.parent.index;
                            }
                            item.usedIdx = idx;
                            item.usedLabel = idx + "." + c.displayName;
                            item.usedData = c.fullName;
                        }
                    }
                    break;
                default:
                    item.usedType = "";
                    item.usedLabel = "";
                    item.usedData = "";
                    item.usedIdx = -1;
                    break;
            }
        }
    }

    function updateSelection(itemNames, selected)
    {
        var item;
        var items = itemNames.split(",");
        for (var i = 0; i < items.length; i++) {
            item = Map.value(items[i]);
            if (item)
                item.selected = selected;
        }
    }

    MouseArea {
        id: rootMouseArea
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        onClicked: {
            if (mouse.button === Qt.RightButton)
                mouseRightClicked(itemType, fullName);
            else if (mouse.button === Qt.LeftButton)
                mouseLeftClicked(itemType, fullName);
        }
        onDoubleClicked: mouseDoubleClicked(itemType, fullName)

        Column {
            anchors.margins: 5
            anchors.fill: parent
            spacing: 0

            // board name/title
            Label {
                text: fullName
                font {
                    family: "Lato-Bold"
                    pointSize: 16
                    bold: false
                }
            }
            // front
            Text {
                text: qsTr("Front")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.rightMargin: 10
                font {
                    family: "Lato-Bold"
                    pointSize: 10
                    bold: true
                }
            }
            // front ports
            Rectangle {
                width: parent.width
                height: 224
                color: "#4a4a4a"

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 2
                    columns: 10
                    rows: 4
                    rowSpacing: 0
                    columnSpacing: 0

                    Repeater {
                        model: 40
                        PtmQsfpPortItem {
                            labelColor: "#ffffff"
                            idx: index
                            label: Hardware.qsfpSwitchPortLabel(index)
                            fullName: Hardware.qsfpSwitchPortFullName(root.fullName, index)
                            onMouseLeftClicked: {
                                root.mouseLeftClicked("qsfp", fullName);
                            }
                            onMouseRightClicked: {
                                root.mouseRightClicked("qsfp", fullName);
                            }
                            onMouseDoubleClicked: {
                                root.mouseDoubleClicked("qsfp", fullName)
                            }
                            onMouseEntered: {
                                root.updateSelection(usedData, true);
                            }
                            onMouseExited: {
                                root.updateSelection(usedData, false);
                            }
                            onDropAccepted: {
                                console.log(fullName + ": unit (" + data + ") dropped");
                                var defaultProgrammingConnector = "";
                                var type = Hardware.droppedHardwareUnitType(data);
                                if (Hardware.isDroppedObjectCable(type))
                                    qsfpCableDropped(title, data, fullName);
                            }
                            onDropRejected: {
                                console.log(fullName + ": object (" + data + ") dropped");
                            }
                            Component.onCompleted: {
                                Map.setValue(fullName, this);
                            }
                        }
                    }
                }
            }

            // spacer
            Item {
                width: 1
                height: 5
            }

            // back
            Text {
                text: qsTr("Back")
                anchors.horizontalCenter: parent.horizontalCenter
                font {
                    family: "Lato-Bold"
                    pointSize: 10
                    bold: true
                }
            }
            // back ports
            Rectangle {
                width: parent.width
                height: 224
                color: "#4a4a4a"

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 2
                    columns: 10
                    rows: 4
                    rowSpacing: 0
                    columnSpacing: 0

                    Repeater {
                        model: 40
                        PtmQsfpPortItem {
                            labelColor: "#ffffff"
                            idx: 40 + index
                            label: Hardware.qsfpSwitchPortLabel(40 + index)
                            fullName: Hardware.qsfpSwitchPortFullName(root.fullName, 40 + index)
                            onMouseLeftClicked: {
                                root.mouseLeftClicked("qsfp", fullName);
                            }
                            onMouseRightClicked: {
                                root.mouseRightClicked("qsfp", fullName);
                            }
                            onMouseDoubleClicked: {
                                root.mouseDoubleClicked("qsfp", fullName)
                            }
                            onMouseEntered: {
                                root.updateSelection(usedData, true);
                            }
                            onMouseExited: {
                                root.updateSelection(usedData, false);
                            }
                            onDropAccepted: {
                                console.log(fullName + ": unit (" + data + ") dropped");
                                var defaultProgrammingConnector = "";
                                var type = Hardware.droppedHardwareUnitType(data);
                                if (Hardware.isDroppedObjectCable(type))
                                    qsfpCableDropped(title, data, fullName);
                            }
                            onDropRejected: {
                                console.log(fullName + ": object (" + data + ") dropped");
                            }
                            Component.onCompleted: {
                                Map.setValue(fullName, this);
                            }
                        }
                    }
                }
            }
        }
    }
}
