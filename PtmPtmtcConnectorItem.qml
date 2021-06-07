import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import Cadence.Prototyping.Extensions 1.0

Rectangle {
    id: root
    color: "transparent"
    width: horizontalOrientation ? 129 : 26
    height: horizontalOrientation ? 26 : 129
    border {
        color: bgMouseArea.containsMouse || dropArea.containsValidDrag ||
               selected ? "#2da7df" : ""
        width: bgMouseArea.containsMouse || dropArea.containsValidDrag ||
               selected ? 2 : 0
    }

    signal mouseLeftClicked;
    signal mouseRightClicked;
    signal mouseDoubleClicked;
    signal mouseEntered;
    signal mouseExited;

    signal dropAccepted(string title, string data);
    signal dropRejected(string title, string data);

    readonly property string itemType: "ptmtc_connector"

    property bool horizontalOrientation: false
    property int slot: 0
    property int idx: -1
    property string label
    property string fullName
    property bool used: false
    /* supported:
        ""      - available
        "cable" - PTMBC cable
        "dc"    - Daughter card
    */
    property string usedType: ""
    property string usedLabel: ""
    property int usedIdx: -1
    property string usedData: ""
    property bool selected: false

    QtObject {
        id: res

        function background()
        {
            var uType = root.usedType;
            return "images/ptmtc_connector_" +
                    (horizontalOrientation ? "horizontal" : "vertical") + "_" +
                    (uType.length > 0 ? uType + "_used" : "unused") + ".png";
        }

        function usedIcon()
        {
            if (!root.used)
                return "";

            var uType = root.usedType;
            if (uType.length === 0)
                return "";

            return "images/ptmbc_connector_icon_" + uType + ".png";
        }

        function usedLabelBackground()
        {
            if (!root.used)
                return "";

            var uType = root.usedType;
            if (uType.length === 0)
                return "";

            return "images/ptmbc_connector_tail_" + uType + ".png";
        }

        property string usedLabelColor: "#0048ff"
        property string usedLabelAlternativeColor: "red"
        property int labelFontSize: 8
        property int longLabelFontSize: 6
    }

    Item {
        anchors.centerIn: parent
        width: parent.width - 4
        height: parent.height - 4

        // connector background
        Image {
            id: bg
            anchors.centerIn: parent
            source: res.background()
        }

        Item {
            anchors.top: bg.top
            anchors.left: bg.left
            height: 20
            width: 20

            Image {
                anchors.centerIn: parent
                anchors.margins: 2.5
                source: res.usedIcon()
                visible: used
            }
        }
        Text {
            text: label
            rotation: horizontalOrientation ? 0 : 90
            anchors.centerIn: parent
            color: "white"
            font {
                family: "Lato-Bold"
                pointSize: 7
                bold: bgMouseArea.containsMouse ||
                      dropArea.containsValidDrag || selected
            }
        }
        Item {
            anchors.bottom: bg.bottom
            anchors.right: bg.right
            height: 20
            width: 20

            Image {
                anchors.centerIn: parent
                anchors.margins: 2.5
                source: "images/ptmbc_connector_label.png"
                visible: used
            }
            Text {
                text: usedLabel.length > 0 ? usedLabel :
                                             (usedIdx >= 0 ? usedIdx : idx)
                anchors.centerIn: parent
                font {
                    family: "Lato-Bold"
                    pointSize: text.length > 2 ? res.longLabelFontSize :
                                                 res.labelFontSize
                    italic: usedIdx >= 0
                }
                color: usedLabel.length > 0 ? res.usedLabelColor :
                      (usedIdx >= 0 ? res.usedLabelAlternativeColor : "black")
            }
            Image {
                anchors.centerIn: parent
                anchors.margins: 2.5
                source: res.usedLabelBackground()
                visible: used
            }
        }

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
            onDoubleClicked: mouseDoubleClicked
            onEntered: mouseEntered()
            onExited: mouseExited()
        }

        QtObject {
            id: dropAreaEx

            function isValidObject(userData) {
                var data = userData.split(";");
                if (data.length < 2)
                    return false;

                var type = data[0];
                var subtype = data[1];
                var allowType = true;
                if (slot > 0) {
                    var d = (data.length >= 3 ? data[2] : "");
                    if (d.length > 0)
                        allowType = (String(slot) === d);
                }
                return (type === "dcard" && subtype === "ptmtc" && allowType);
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent

            property bool containsValidDrag: false

            onEntered: {
                console.log("Ptmtc: dragged item (" + drag.source.text +
                            ") above drop area");
                containsValidDrag = dropAreaEx.isValidObject(
                            drag.source.userData);
            }
            onExited: {
                console.log("Ptmtc: dragged item (" + drag.source.text +
                            ") exited drop area");
                containsValidDrag = false;
            }
            onDropped: {
                console.log("Ptmtc: item (" + drag.source.text + ") dropped: " +
                            drag.source.userData);

                if (dropAreaEx.isValidObject(drag.source.userData))
                    dropAccepted(drag.source.text, drag.source.userData);
                else
                    dropRejected(drag.source.text, drag.source.userData);
                containsValidDrag = false;
            }
        }
    }

    // disabled state
    Rectangle {
        anchors.fill: parent
        border {
            width: 1
            color: "#7f7f7f"
        }
        color: "#999999"
        opacity: 0.8
        visible: !enabled
    }
}
