import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "Hardware.js" as Hardware
import "Map.js" as Map
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root
    width: 1470
    height: 700

    /*
      Supported types: board, fpga, ptmbc, ptmtc, prog, qsfp
      */
    signal mouseLeftClicked(string type, string name)
    signal mouseDoubleClicked(string type, string name)
    signal mouseRightClicked(string type, string name)

    signal ptmbcCableDropped(string title, string data, string connector)
    signal qsfpCableDropped(string title, string data, string connector)
    signal daughterCardDropped(string title, string data, string connector,
                               string defaultProgrammingConnector)
    signal ioBoardDropped(string title, string data, string connector,
                          string defaultProgrammingConnector)

    readonly property string itemType: "board"

    property string fullName
    property bool hasZynqFpga: true

    function updateUnitStatus(name, enabled, used, userData, connectedItems)
    {
        //console.log("Board child unit " + name + " status (" + enabled + ":" +
        //            used + "), user data: " + userData + " updated");
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
                case 1001:
                    item.usedType = "dc";
                    item.usedLabel = (connectedItems.length > 0 ?
                                          connectedItems[0] : "");
                    itemNames = '';
                    for (i = 1; i < connectedItems.length; i++) {
                        otherItem = Map.value(connectedItems[i].fullName);
                        if (otherItem) {
                            itemNames += (itemNames.length === 0 ? "" : ",") +
                                    otherItem.fullName;
                        }
                    }
                    item.usedData = itemNames;
                    item.usedIdx = -1;
                    break;
                case 1002:
                    item.usedType = "io";
                    item.usedLabel = (connectedItems.length > 0 ?
                                          connectedItems[0] : "");
                    itemNames = '';
                    for (i = 1; i < connectedItems.length; i++) {
                        otherItem = Map.value(connectedItems[i].fullName);
                        if (otherItem) {
                            itemNames += (itemNames.length === 0 ? "" : ",") +
                                    otherItem.fullName;
                        }
                    }
                    item.usedData = itemNames;
                    item.usedIdx = -1;
                    break;
                case 1003:
                    item.usedType = "cable";
                    if (connectedItems.length > 1) {
                        var c = connectedItems[1];
                        otherItem = Map.value(c.fullName);
                        if (item.itemType === "qsfp_port") {
                            if (otherItem) {
                                item.usedLabel = otherItem.label;
                                item.usedData = otherItem.fullName;
                                item.usedIdx = -1;
                            } else {
                                var parentName = "";
                                idx = -1;
                                if (c.parent) {
                                    if (c.parent.parent) {
                                        if (c.parent.parent.parent) {
                                            // this is board connector
                                            idx = c.parent.parent.index;
                                            parentName = c.parent.parent.displayName;
                                        } else {
                                            // this is switch board connector
                                            idx = c.parent.index;
                                            parentName = "SW" + idx;
                                        }
                                    }
                                }
                                item.usedIdx = idx;
                                item.usedLabel = parentName + "." + c.displayName;
                                item.usedData = c.fullName;
                            }
                        } else {
                            if (otherItem) {
                                item.usedLabel = otherItem.idx;
                                item.usedData = otherItem.fullName;
                                item.usedIdx = -1;
                            } else {
                                // could be connector on another board
                                item.usedLabel = c.index;
                                item.usedData = c.fullName;
                                // index of the other board
                                idx = -1;
                                if (c.parent) {
                                    if (c.parent.parent)
                                        idx = c.parent.parent.index;
                                }
                                item.usedIdx = idx;
                            }
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
            // main board
            Item {
                width: parent.width
                height: 550

                // board background
                Image {
                    anchors.fill: parent
                    source: "images/x1_board_bg.png"
                    fillMode: Image.PreserveAspectCrop
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // top row of connectors
                    Item {
                        Layout.fillWidth: true
                        height: 123

                        RowLayout {
                            anchors.fill: parent
                            anchors.topMargin: 4
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Item {
                                Layout.fillHeight: true
                                width: 456

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 113
                                    spacing: 74

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 1
                                        location: "A"
                                        //connector: "A-P6"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 6, 24, ["A"])
                                        defaultProgrammingConnector: progConnectorA0.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            console.log(connector)
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 2
                                        location: "A"
                                        //connector: "A-P13"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 13, 24, ["A"])
                                        defaultProgrammingConnector: progConnectorA1.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.topMargin: 9
                                    spacing: 0

                                    Repeater {
                                        model: 24
                                        PtmPtmbcConnectorItem {
                                            idx: index
                                            label: Hardware.ptmbcConnectorX1Label(index, 24, ["A"])
                                            fullName: Hardware.ptmbcConnectorX1FullName(root.fullName, index, 24, ["A"])
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmbc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmbc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmbc", fullName)
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
                                                if (Hardware.isDroppedObjectDaughterCard(type))
                                                    daughterCardDropped(title, data, fullName,
                                                                        defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectIoBoard(type))
                                                    ioBoardDropped(title, data, fullName,
                                                                   defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectCable(type))
                                                    ptmbcCableDropped(title, data, fullName);
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

                            Item {
                                Layout.fillHeight: true
                                width: 456

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 113
                                    spacing: 74

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 0
                                        location: "C"
                                        //connector: "C-P6"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 6, 24, ["C"])
                                        defaultProgrammingConnector: progConnectorC0.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 1
                                        location: "C"
                                        //connector: "C-P13"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 13, 24, ["C"])
                                        defaultProgrammingConnector: progConnectorC1.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.topMargin: 9
                                    spacing: 0

                                    Repeater {
                                        model: 24
                                        PtmPtmbcConnectorItem {
                                            idx: 24 + index
                                            label: Hardware.ptmbcConnectorX1Label(index, 24, ["C"])
                                            fullName: Hardware.ptmbcConnectorX1FullName(root.fullName, index, 24, ["C"])
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmbc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmbc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmbc", fullName)
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
                                                if (Hardware.isDroppedObjectDaughterCard(type))
                                                    daughterCardDropped(title, data, fullName,
                                                                        defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectIoBoard(type))
                                                    ioBoardDropped(title, data, fullName,
                                                                   defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectCable(type))
                                                    ptmbcCableDropped(title, data, fullName);
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

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillHeight: true
                                width: 456

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 113
                                    spacing: 74

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 0
                                        location: "F"
                                        //connector: "F-P6"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 6, 24, ["F"])
                                        defaultProgrammingConnector: progConnectorF0.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 1
                                        location: "F"
                                        //connector: "F-P13"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 13, 24, ["F"])
                                        defaultProgrammingConnector: progConnectorF1.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.topMargin: 9
                                    spacing: 0

                                    Repeater {
                                        model: 24
                                        PtmPtmbcConnectorItem {
                                            idx: 48 + index
                                            label: Hardware.ptmbcConnectorX1Label(index, 24, ["F"])
                                            fullName: Hardware.ptmbcConnectorX1FullName(root.fullName, index, 24, ["F"])
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmbc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmbc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmbc", fullName)
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
                                                if (Hardware.isDroppedObjectDaughterCard(type))
                                                    daughterCardDropped(title, data, fullName,
                                                                        defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectIoBoard(type))
                                                    ioBoardDropped(title, data, fullName,
                                                                   defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectCable(type))
                                                    ptmbcCableDropped(title, data, fullName);
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

                    // row of FPGAs A, C and F
                    Item {
                        Layout.fillWidth: true
                        height: 110

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 103
                            spacing: 10

                            Item {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                height: parent.height
                                width: 70

                                Repeater {
                                    model: 4

                                    PtmProgrammingConnectorItem {
                                        label: Hardware.programmingConnectorLabel("IOAB", 0, index)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "IOAB", 0, index)
                                        biggerSize: true
                                        anchors.top: parent.top
                                        anchors.topMargin: 24 * index
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }

                            // spacer
                            Item {
                                width: 15
                                height: 1
                            }

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorA0
                                        label: Hardware.programmingConnectorLabel("A", 0)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "A", 0)
                                        anchors.top: parent.top
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmFpgaItem {
                                        label: "A"
                                        fullName: Hardware.fpgaFullName(root.fullName, "A")
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("fpga", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("fpga", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("fpga", fullName)
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorA1
                                        label: Hardware.programmingConnectorLabel("A", 1)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "A", 1)
                                        anchors.top: parent.top
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillHeight: true;
                                implicitWidth: 201

                                Item {
                                    Layout.fillHeight: true;
                                    implicitWidth: 90
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: hasZynqFpga
                                    //anchors.top: parent.top
                                    //anchors.topMargin: 40

                                    Row {
                                        anchors.fill: parent
                                        spacing: 5

                                        Repeater {
                                            model: 4
                                            PtmPtmbcConnectorItem {
                                                idx: 144 + index
                                                label: Hardware.ptmbcConnectorX1Label(index, 4, ["G"])
                                                fullName: Hardware.ptmbcConnectorX1FullName(root.fullName, index, 4, ["G"])
                                                anchorLabelToTop: false
                                                onMouseLeftClicked: {
                                                    root.mouseLeftClicked("ptmbc", fullName);
                                                }
                                                onMouseRightClicked: {
                                                    root.mouseRightClicked("ptmbc", fullName);
                                                }
                                                onMouseDoubleClicked: {
                                                    root.mouseDoubleClicked("ptmbc", fullName)
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
                                                    if (Hardware.isDroppedObjectDaughterCard(type))
                                                        daughterCardDropped(title, data, fullName,
                                                                            defaultProgrammingConnector);
                                                    else if (Hardware.isDroppedObjectIoBoard(type))
                                                        ioBoardDropped(title, data, fullName,
                                                                       defaultProgrammingConnector);
                                                    else if (Hardware.isDroppedObjectCable(type))
                                                        ptmbcCableDropped(title, data, fullName);
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

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorC0
                                        label: Hardware.programmingConnectorLabel("C", 0)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "C", 0)
                                        anchors.top: parent.top
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmFpgaItem {
                                        label: "C"
                                        fullName: Hardware.fpgaFullName(root.fullName, "C")
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("fpga", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("fpga", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("fpga", fullName)
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorC1
                                        label: Hardware.programmingConnectorLabel("C", 1)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "C", 1)
                                        anchors.top: parent.top
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                width: 300
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorF0
                                        label: Hardware.programmingConnectorLabel("F", 0)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "F", 0)
                                        anchors.top: parent.top
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmFpgaItem {
                                        label: "F"
                                        fullName: Hardware.fpgaFullName(root.fullName, "F")
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("fpga", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("fpga", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("fpga", fullName)
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorF1
                                        label: Hardware.programmingConnectorLabel("F", 1)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "F", 1)
                                        anchors.top: parent.top
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // row of PTMTC connectors
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 77

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 90
                            anchors.rightMargin: 100
                            spacing: 10

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true

                                Column {
                                    anchors.fill: parent
                                    spacing: 1

                                    Repeater {
                                        model: 3
                                        PtmPtmtcConnectorItem {
                                            idx: index == 0 ? 0 : 3 - index % 3
                                            label: Hardware.ptmtcConnectorLabel(index, "PTMTC", ["A", "A&B", "B"])
                                            fullName: Hardware.ptmtcConnectorFullName(root.fullName, index, ["A", "AB", "B"], ["A", "A", "B"])
                                            horizontalOrientation: true
                                            slot: index < 2 ? 2 : 1
                                            x: 38 * (3 - index)
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmtc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmtc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmtc", fullName)
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
                                                daughterCardDropped(title, data, fullName,
                                                                    defaultProgrammingConnector);
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

                            Item {
                                implicitWidth: 178
                                Layout.fillHeight: true
                                anchors.top: parent.top
                                anchors.topMargin: 60

                                PtmPtmtcConnectorItem {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: hasZynqFpga
                                    idx: 9
                                    label: Hardware.ptmtcConnectorLabel(0, "PTMTC", ["G"])
                                    fullName: Hardware.ptmtcConnectorFullName(root.fullName, 0, ["G"], ["G"])
                                    horizontalOrientation: true
                                    onMouseLeftClicked: {
                                        root.mouseLeftClicked("ptmtc", fullName);
                                    }
                                    onMouseRightClicked: {
                                        root.mouseRightClicked("ptmtc", fullName);
                                    }
                                    onMouseDoubleClicked: {
                                        root.mouseDoubleClicked("ptmtc", fullName)
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
                                        daughterCardDropped(title, data, fullName,
                                                            defaultProgrammingConnector);
                                    }
                                    onDropRejected: {
                                        console.log(fullName + ": object (" + data + ") dropped");
                                    }
                                    Component.onCompleted: {
                                        Map.setValue(fullName, this);
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true

                                Column {
                                    anchors.fill: parent
                                    spacing: 2

                                    Repeater {
                                        model: 3
                                        PtmPtmtcConnectorItem {
                                            idx: index == 0 ? 3 : 6 - index % 6
                                            label: Hardware.ptmtcConnectorLabel(index, "PTMTC", ["C", "C&D", "D"])
                                            fullName: Hardware.ptmtcConnectorFullName(root.fullName, index, ["C", "CD", "D"], ["C", "C", "D"])
                                            horizontalOrientation: true
                                            slot: index < 2 ? 2 : 1
                                            x: 38 * (3 - index)
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmtc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmtc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmtc", fullName)
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
                                                daughterCardDropped(title, data, fullName,
                                                                    defaultProgrammingConnector);
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

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                width: 285
                                Layout.fillHeight: true

                                Column {
                                    anchors.fill: parent
                                    spacing: 2

                                    Repeater {
                                        model: 3
                                        PtmPtmtcConnectorItem {
                                            idx: index == 2 ? 6 : 7 + index
                                            label: Hardware.ptmtcConnectorLabel(index, "PTMTC", ["F", "F&E", "E"])
                                            fullName: Hardware.ptmtcConnectorFullName(root.fullName, index, ["F", "FE", "E"], ["F", "F", "E"])
                                            horizontalOrientation: true
                                            slot: index >= 2 ? 1 : 2
                                            x: 38 * (3 - index)
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmtc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmtc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmtc", fullName)
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
                                                daughterCardDropped(title, data, fullName,
                                                                    defaultProgrammingConnector);
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

                    // row of FPGAs B, G, D and E
                    Item {
                        Layout.fillWidth: true
                        height: 110

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 103
                            spacing: 10

                            Item {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                height: parent.height
                                width: 70

                                Repeater {
                                    model: 4

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorIOAB1
                                        label: Hardware.programmingConnectorLabel("IOAB", 1, index)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "IOAB", 1, index)
                                        biggerSize: true
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 24 * index
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }

                            // spacer
                            Item {
                                width: 15
                                height: 1
                            }

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorB0
                                        label: Hardware.programmingConnectorLabel("B", 0)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "B", 0)
                                        anchors.bottom: parent.bottom
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmFpgaItem {
                                        label: "B"
                                        fullName: Hardware.fpgaFullName(root.fullName, "B")
                                        anchorLabelToTop: false
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("fpga", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("fpga", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("fpga", fullName)
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorB1
                                        label: Hardware.programmingConnectorLabel("B", 1)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "B", 1)
                                        anchors.bottom: parent.bottom
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillHeight: true;
                                implicitWidth: 201

                                PtmFpgaItem {
                                    visible: hasZynqFpga
                                    label: "G"
                                    fullName: Hardware.fpgaFullName(root.fullName, "G")
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    onMouseLeftClicked: {
                                        root.mouseLeftClicked("fpga", fullName);
                                    }
                                    onMouseRightClicked: {
                                        root.mouseRightClicked("fpga", fullName);
                                    }
                                    onMouseDoubleClicked: {
                                        root.mouseDoubleClicked("fpga", fullName)
                                    }
                                    Component.onCompleted: {
                                        Map.setValue(fullName, this);
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorD0
                                        label: Hardware.programmingConnectorLabel("D", 0)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "D", 0)
                                        anchors.bottom: parent.bottom
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmFpgaItem {
                                        label: "D"
                                        fullName: Hardware.fpgaFullName(root.fullName, "D")
                                        anchorLabelToTop: false
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("fpga", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("fpga", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("fpga", fullName)
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorD1
                                        label: Hardware.programmingConnectorLabel("D", 1)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "D", 1)
                                        anchors.bottom: parent.bottom
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                width: 300
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorE0
                                        label: Hardware.programmingConnectorLabel("E", 0)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "E", 0)
                                        anchors.bottom: parent.bottom
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmFpgaItem {
                                        label: "E"
                                        fullName: Hardware.fpgaFullName(root.fullName, "E")
                                        anchorLabelToTop: false
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("fpga", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("fpga", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("fpga", fullName)
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }

                                    PtmProgrammingConnectorItem {
                                        id: progConnectorE1
                                        label: Hardware.programmingConnectorLabel("E", 1)
                                        fullName: Hardware.programmingConnectorFullName(root.fullName, "E", 1)
                                        anchors.bottom: parent.bottom
                                        rotation: 90
                                        onMouseLeftClicked: {
                                            root.mouseLeftClicked("prog", fullName);
                                        }
                                        onMouseRightClicked: {
                                            root.mouseRightClicked("prog", fullName);
                                        }
                                        onMouseDoubleClicked: {
                                            root.mouseDoubleClicked("prog", fullName)
                                        }
                                        onMouseEntered: {
                                            root.updateSelection(usedData, true);
                                        }
                                        onMouseExited: {
                                            root.updateSelection(usedData, false);
                                        }
                                        Component.onCompleted: {
                                            Map.setValue(fullName, this);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // bottom row of connectors
                    Item {
                        Layout.fillWidth: true
                        height: 124

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Item {
                                Layout.fillHeight: true
                                width: 456

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 151
                                    spacing: 74

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 0
                                        location: "B"
                                        //connector: "B-P13"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 13, 24, ["B"])
                                        defaultProgrammingConnector: progConnectorB0.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 1
                                        location: "B"
                                        //connector: "B-P6"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 6, 24, ["B"])
                                        defaultProgrammingConnector: progConnectorB1.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.topMargin: 9
                                    spacing: 0

                                    Repeater {
                                        model: 24
                                        PtmPtmbcConnectorItem {
                                            idx: 72 + index /*23 - index*/
                                            label: Hardware.ptmbcConnectorX1Label(23 - index, 24, ["B"])
                                            fullName: Hardware.ptmbcConnectorX1FullName(root.fullName, 23 - index, 24, ["B"])
                                            anchorLabelToTop: false
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmbc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmbc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmbc", fullName)
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
                                                if (Hardware.isDroppedObjectDaughterCard(type))
                                                    daughterCardDropped(title, data, fullName,
                                                                        defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectIoBoard(type))
                                                    ioBoardDropped(title, data, fullName,
                                                                   defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectCable(type))
                                                    ptmbcCableDropped(title, data, fullName);
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

                            Item {
                                Layout.fillHeight: true
                                width: 456

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 151
                                    spacing: 74

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 0
                                        location: "D"
                                        //connector: "D-P13"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 13, 24, ["D"])
                                        defaultProgrammingConnector: progConnectorD0.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 1
                                        location: "D"
                                        //connector: "D-P6"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 6, 24, ["D"])
                                        defaultProgrammingConnector: progConnectorD1.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.topMargin: 9
                                    spacing: 0

                                    Repeater {
                                        model: 24
                                        PtmPtmbcConnectorItem {
                                            idx: 96 + index /*23 - index*/
                                            label: Hardware.ptmbcConnectorX1Label(23 - index, 24, ["D"])
                                            fullName: Hardware.ptmbcConnectorX1FullName(root.fullName, 23 - index, 24, ["D"])
                                            anchorLabelToTop: false
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmbc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmbc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmbc", fullName)
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
                                                if (Hardware.isDroppedObjectDaughterCard(type))
                                                    daughterCardDropped(title, data, fullName,
                                                                        defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectIoBoard(type))
                                                    ioBoardDropped(title, data, fullName,
                                                                   defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectCable(type))
                                                    ptmbcCableDropped(title, data, fullName);
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

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillHeight: true
                                width: 456

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 151
                                    spacing: 74

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 0
                                        location: "E"
                                        //connector: "E-P13"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 13, 24, ["E"])
                                        defaultProgrammingConnector: progConnectorE0.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }

                                    PtmPtmbcDaughterCardBoardLocationItem {
                                        width: 59
                                        idx: 1
                                        location: "E"
                                        //connector: "E-P6"
                                        connector: Hardware.ptmbcConnectorX1FullName(root.fullName, 6, 24, ["E"])
                                        defaultProgrammingConnector: progConnectorE1.fullName

                                        onMouseRightClicked: {
                                            console.log(location + "." + idx + ": RIGHT MOUSE CLICK");
                                        }
                                        onMouseLeftClicked: {
                                            console.log(location + "." + idx + ": LEFT MOUSE CLICK");
                                        }
                                        onMouseDoubleClicked: {
                                            console.log(location + "." + idx + ": MOUSE DOUBLE CLICK");
                                        }
                                        onDropAccepted: {
                                            console.log(location + "." + idx + ": dcard (" + data + ") dropped");
                                            daughterCardDropped(title, data, connector, defaultProgrammingConnector);
                                        }
                                        onDropRejected: {
                                            console.log(location + "." + idx + ": object (" + data + ") dropped");
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.topMargin: 9
                                    spacing: 0

                                    Repeater {
                                        model: 24
                                        PtmPtmbcConnectorItem {
                                            idx: 120 + index /*23 - index*/
                                            label: Hardware.ptmbcConnectorX1Label(23 - index, 24, ["E"])
                                            fullName: Hardware.ptmbcConnectorX1FullName(root.fullName, 23 - index, 24, ["E"])
                                            anchorLabelToTop: false
                                            onMouseLeftClicked: {
                                                root.mouseLeftClicked("ptmbc", fullName);
                                            }
                                            onMouseRightClicked: {
                                                root.mouseRightClicked("ptmbc", fullName);
                                            }
                                            onMouseDoubleClicked: {
                                                root.mouseDoubleClicked("ptmbc", fullName)
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
                                                if (Hardware.isDroppedObjectDaughterCard(type))
                                                    daughterCardDropped(title, data, fullName,
                                                                        defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectIoBoard(type))
                                                    ioBoardDropped(title, data, fullName,
                                                                   defaultProgrammingConnector);
                                                else if (Hardware.isDroppedObjectCable(type))
                                                    ptmbcCableDropped(title, data, fullName);
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
            }

            // spacer
            Item {
                width: 1
                height: 5
            }

            TabView {
                width: parent.width
                height: 150

                style: TabViewStyle {
                    frameOverlap: 0
                    frame: Rectangle {
                        color: "white"
                        border {
                            width: 1
                            color: "#e7e7e7"
                        }
                    }
                    tabBar : Rectangle {
                        color: "#ffffff"
                    }
                    tab : Rectangle {
                        implicitHeight: 24
                        implicitWidth: Math.max(tabTitle.width + 20, 80)
                        color: styleData.selected ? "#ffffff" : "#e7e7e7"
                        radius: 2
                        border {
                            width: 1
                            color: "#e7e7e7"
                        }

                        Text {
                            id: tabTitle
                            text: qsTr(styleData.title)
                            anchors.centerIn: parent
                            color: styleData.enabled ? "black" : "grey"
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            border {
                                width: 1
                                color: "#2da7df"
                            }
                            visible: styleData.selected
                        }
                    }
                }

                Tab {
                    active: true
                    title: qsTr("On-Board")

                    // QSFP ports panel
                    Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: "#4a4a4a"

                        GridLayout {
                            // replace width and height with anchor.fill when adding more ports
                            width: 840
                            height: parent.height
                            //anchors.fill: parent
                            anchors.margins: 5
                            columns: 9
                            rows: 2
                            rowSpacing: 0
                            columnSpacing: 0

                            Repeater {
                                model: 17

                                PtmQsfpPortItem {
                                    labelColor: "#ffffff"
                                    idx: index
                                    label: Hardware.qsfpX1BoardPortLabel(index)
                                    fullName: Hardware.qsfpX1BoardPortFullName(root.fullName, index)
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
                                        else if (Hardware.isDroppedObjectDaughterCard(type))
                                            daughterCardDropped(title, data, fullName,
                                                                defaultProgrammingConnector);
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

                Repeater {
                    id: auxQsfpRepeater
                    model: [ "A & B", "C & D", "E & F" ]

                    Tab {
                        id: auxQsfpTab
                        active: true
                        title: "Auxiliary FPGA " + modelData
                        //enabled: enabledCount > 0

                        property var group: modelData
                        property int enabledCount: 0

                        // QSFP ports panel
                        Rectangle {
                            anchors.fill: parent
                            radius: 5
                            color: "#4a4a4a"

                            GridLayout {
                                // replace width and height with anchor.fill when adding more ports
                                width: 840
                                height: parent.height
                                //anchors.fill: parent
                                anchors.margins: 5
                                columns: 6
                                rows: 2
                                rowSpacing: 0
                                columnSpacing: 0

                                Repeater {
                                    model: 12

                                    PtmQsfpPortItem {
                                        labelColor: "#ffffff"
                                        idx: index
                                        label: Hardware.qsfpX1BoardAuxPortLabel(index, auxQsfpTab.group)
                                        fullName: Hardware.qsfpX1BoardAuxPortFullName(root.fullName, index, auxQsfpTab.group)
                                        onEnabledChanged: {
                                            auxQsfpTab.enabledCount += (enabled ? 1 : -1);
                                        }
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
                                            else if (Hardware.isDroppedObjectDaughterCard(type))
                                                daughterCardDropped(title, data, fullName,
                                                                    defaultProgrammingConnector);
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
        }
    }
}
