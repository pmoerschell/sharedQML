import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "Hardware.js" as Hardware
import "Map.js" as Map
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root
    width: 640
    height: 660

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
                    source: "images/s1_board_bg.png"
                    fillMode: Image.PreserveAspectCrop
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // top row of connectors
                    Item {
                        Layout.fillWidth: true
                        anchors.topMargin: 5
                        height: 130

                        Row {
                            anchors.fill: parent
                            anchors.topMargin: 9
                            anchors.leftMargin: 80
                            spacing: 59

                            PtmPtmbcDaughterCardBoardLocationItem {
                                idx: 1
                                location: "C"
                                //connector: "P5-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["C"], ["5"])
                                defaultProgrammingConnector: progConnectorC.fullName

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
                                idx: 2
                                location: "C"
                                //connector: "P6-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["C"], ["6"])
                                defaultProgrammingConnector: progConnectorC.fullName

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

                            // spacer to push the rest right
                            Item {
                                width: 1
                                height: parent.height
                            }

                            PtmPtmbcDaughterCardBoardLocationItem {
                                idx: 3
                                location: "B"
                                //connector: "P7-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["B"], ["7"])
                                defaultProgrammingConnector: progConnectorB.fullName

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
                                idx: 4
                                location: "B"
                                //connector: "P8-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["B"], ["8"])
                                defaultProgrammingConnector: progConnectorB.fullName

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
                            anchors.topMargin: 19
                            anchors.leftMargin: 81
                            anchors.rightMargin: 80
                            spacing: 1

                            Repeater {
                                model: 24
                                PtmPtmbcConnectorItem {
                                    idx: index
                                    label: Hardware.ptmbcConnectorS1Label((index <= 11 ? index : 23 - index), 6, (index <= 11 ? ["C", "C"] : ["B", "B"]), (index <= 11 ? ["5", "6"] : ["8", "7"]))
                                    fullName: Hardware.ptmbcConnectorS1FullName(root.fullName, (index <= 11 ? index : 23 - index), 6, (index <= 11 ? ["C", "C"] : ["B", "B"]), (index <= 11 ? ["5", "6"] : ["8", "7"]))
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

                    // row of FPGAs C and B
                    Item {
                        Layout.fillWidth: true
                        anchors.topMargin: 10
                        height: 130

                        RowLayout {
                            anchors.fill: parent
                            anchors.topMargin: 11
                            anchors.leftMargin: 55
                            anchors.rightMargin: 55
                            spacing: 10

                            PtmPtmtcConnectorItem {
                                idx: 0
                                label: Hardware.ptmtcConnectorLabel(0, "PTMTC", ["C"])
                                fullName: Hardware.ptmtcConnectorFullName(root.fullName, 0, ["C"], ["C"])
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

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                PtmFpgaItem {
                                    label: "C"
                                    fullName: Hardware.fpgaFullName(root.fullName, "C")
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

                            PtmProgrammingConnectorItem {
                                id: progConnectorC
                                label: Hardware.programmingConnectorLabel("C", -1)
                                fullName: Hardware.programmingConnectorFullName(root.fullName, "C", -1)
                                Layout.alignment: Qt.AlignTop
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
                            PtmProgrammingConnectorItem {
                                id: progConnectorB
                                label: Hardware.programmingConnectorLabel("B", -1)
                                fullName: Hardware.programmingConnectorFullName(root.fullName, "B", -1)
                                Layout.alignment: Qt.AlignTop
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

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignTop

                                PtmFpgaItem {
                                    label: "B"
                                    fullName: Hardware.fpgaFullName(root.fullName, "B")
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

                            PtmPtmtcConnectorItem {
                                idx: 2
                                label: Hardware.ptmtcConnectorLabel(0, "PTMTC", ["B"])
                                fullName: Hardware.ptmtcConnectorFullName(root.fullName, 0, ["B"], ["B"])
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

                    // spacer
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // row of FPGAs D and A
                    Item {
                        Layout.fillWidth: true
                        height: 130

                        RowLayout {
                            anchors.fill: parent
                            anchors.bottomMargin: 10
                            anchors.leftMargin: 55
                            anchors.rightMargin: 55
                            spacing: 10

                            PtmPtmtcConnectorItem {
                                idx: 1
                                label: Hardware.ptmtcConnectorLabel(0, "PTMTC", ["D"])
                                fullName: Hardware.ptmtcConnectorFullName(root.fullName, 0, ["D"], ["D"])
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

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignBottom

                                PtmFpgaItem {
                                    label: "D"
                                    fullName: Hardware.fpgaFullName(root.fullName, "D")
                                    anchorLabelToTop: false
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

                            PtmProgrammingConnectorItem {
                                id: progConnectorD
                                label: Hardware.programmingConnectorLabel("D", -1)
                                fullName: Hardware.programmingConnectorFullName(root.fullName, "D", -1)
                                Layout.alignment: Qt.AlignBottom
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
                            PtmProgrammingConnectorItem {
                                id: progConnectorA
                                label: Hardware.programmingConnectorLabel("A", -1)
                                fullName: Hardware.programmingConnectorFullName(root.fullName, "A", -1)
                                Layout.alignment: Qt.AlignBottom
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

                            Item {
                                Layout.fillWidth: true;
                                Layout.fillHeight: true;
                                Layout.alignment: Qt.AlignBottom

                                PtmFpgaItem {
                                    label: "A"
                                    fullName: Hardware.fpgaFullName(root.fullName, "A")
                                    anchorLabelToTop: false
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

                            PtmPtmtcConnectorItem {
                                idx: 3
                                label: Hardware.ptmtcConnectorLabel(0, "PTMTC", ["A"])
                                fullName: Hardware.ptmtcConnectorFullName(root.fullName, 0,["A"], ["A"])
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

                    // bottom row of connectors
                    Item {
                        Layout.fillWidth: true
                        anchors.bottomMargin: 5
                        height: 130

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 80
                            spacing: 59

                            PtmPtmbcDaughterCardBoardLocationItem {
                                idx: 1
                                location: "D"
                                //connector: "P1-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["D"], ["1"])
                                defaultProgrammingConnector: progConnectorD.fullName

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
                                idx: 2
                                location: "D"
                                //connector: "P2-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["D"], ["2"])
                                defaultProgrammingConnector: progConnectorD.fullName

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

                            // spacer to push the rest right
                            Item {
                                width: 1
                                height: parent.height
                            }

                            PtmPtmbcDaughterCardBoardLocationItem {
                                idx: 3
                                location: "A"
                                //connector: "P3-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["A"], ["3"])
                                defaultProgrammingConnector: progConnectorA.fullName

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
                                idx: 4
                                location: "A"
                                //connector: "P4-1"
                                connector: Hardware.ptmbcConnectorS1FullName(root.fullName, 0, 6, ["A"], ["4"])
                                defaultProgrammingConnector: progConnectorA.fullName

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
                            anchors.topMargin: 10
                            anchors.leftMargin: 81
                            anchors.rightMargin: 80
                            spacing: 1

                            Repeater {
                                model: 24
                                PtmPtmbcConnectorItem {
                                    idx: 24 + index
                                    label: Hardware.ptmbcConnectorS1Label((index <= 11 ? index : 23 - index), 6, (index <= 11 ? ["D", "D"] : ["A", "A"]), (index <= 11 ? ["1", "2"] : ["4", "3"]))
                                    fullName: Hardware.ptmbcConnectorS1FullName(root.fullName, (index <= 11 ? index : 23 - index), 6, (index <= 11 ? ["D", "D"] : ["A", "A"]), (index <= 11 ? ["1", "2"] : ["4", "3"]))
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

            // spacer
            Item {
                width: 1
                height: 5
            }

            // QSFP ports panel
            Rectangle {
                width: parent.width
                height: 110
                radius: 5
                color: "#4a4a4a"

                GridLayout {
                    // replace width and height with anchor.fill when adding more ports
                    width: 480
                    height: 55 //parent.height
                    //anchors.fill: parent
                    anchors.margins: 5
                    columns: 5
                    rows: 2
                    rowSpacing: 0
                    columnSpacing: 0

                    Repeater {
                        model: 5
                        PtmQsfpPortItem {
                            labelColor: "#ffffff"
                            idx: index
                            label: Hardware.qsfpS1BoardPortLabel(4, index)
                            fullName: Hardware.qsfpS1BoardPortFullName(root.fullName, 4, index)
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
