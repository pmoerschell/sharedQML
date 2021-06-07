import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import Cadence.Prototyping.Extensions 1.0

Rectangle {
    id: root
    color: "transparent"
    width: 19
    height: 99
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

    readonly property string itemType: "ptmbc_connector"

    property int idx: -1
    property string label
    property string fullName
    property bool used: false
    /* supported:
        ""      - available
        "cable" - PTMBC cable
        "dc"    - Daughter card
        "io"    - I/O board
    */
    property string usedType: ""
    property string usedLabel: ""
    property int usedIdx: -1
    property string usedData: ""
    property bool selected: false
    property bool anchorLabelToTop: true /* otherwise, anchor to bottom */

    QtObject {
        id: res

        function usedBackground(pType)
        {
            if (pType.length === 0)
                return "";

            if (!root.used)
                return "";

            var uType = root.usedType;
            if (uType.length === 0)
                return "";

            return "images/ptmbc_connector_" + pType + "_" + uType + ".png";
        }

        property string usedLabelColor: "#0048ff"
        property string usedLabelAlternativeColor: "red"
        property int labelFontSize: 8
        property int longLabelFontSize: 6
    }

    Item {
        anchors.centerIn: parent
        width: 15
        height: 95

        Item {
            id: connectorLabel
            width: 15
            height: 15
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: anchorLabelToTop ? 0 : 80

            Image {
                id: bgLabel
                anchors.centerIn: parent
                source: "images/ptmbc_connector_label.png"
            }
            Image {
                id: bgLabelUsed
                anchors.centerIn: parent
                source: res.usedBackground("head")
                visible: used
            }
            Text {
                text: usedIdx >= 0 ? usedIdx : idx
                color: usedIdx >= 0 ? res.usedLabelAlternativeColor : "black"
                anchors.centerIn: parent
                font {
                    family: "Lato-Bold"
                    pointSize: text.length > 2 ? res.longLabelFontSize :
                                                 res.labelFontSize
                    italic: usedIdx >= 0
                }
            }
        }

        Item {
            id: connectorBody
            width: 15
            height: 80
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: anchorLabelToTop ? 15 : 0

            Column {
                anchors.fill: connectorBody
                spacing: 0

                Item {
                    width: 15
                    height: 15

                    Image {
                        id: topTrim
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "images/ptmbc_connector_trim.png"
                    }

                    // connected to label
                    Item {
                        anchors.fill: parent
                        visible: !anchorLabelToTop && used &&
                                 usedLabel.length > 0

                        Image {
                            anchors.centerIn: parent
                            source: "images/ptmbc_connector_label.png"
                        }
                        Text {
                            text: usedLabel
                            anchors.centerIn: parent
                            font {
                                family: "Lato-Bold"
                                pointSize: text.length > 2 ?
                                               res.longLabelFontSize :
                                               res.labelFontSize
                                italic: usedIdx >= 0
                            }
                            color: usedIdx >= 0 ? res.usedLabelAlternativeColor
                                                : res.usedLabelColor
                        }
                    }

                    Image {
                        id: topTrimUsed
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: res.usedBackground((anchorLabelToTop ? "icon" :
                                                                       "head"))
                        visible: used
                    }
                }

                Item {
                    width: 15
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: bgBody
                        anchors.centerIn: parent
                        source: "images/ptmbc_connector_body_unused.png"
                    }

                    Image {
                        id: bgBodyUsed
                        anchors.centerIn: parent
                        source: res.usedBackground("body")
                        visible: used
                    }

                    Text {
                        text: label
                        anchors.centerIn: parent
                        rotation: 90
                        font {
                            family: "Lato-Bold"
                            pointSize: 8
                            bold: bgMouseArea.containsMouse ||
                                  dropArea.containsValidDrag || selected
                        }
                    }
                }

                Item {
                    width: 15
                    height: 15

                    Image {
                        id: bottomTrim
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "images/ptmbc_connector_trim.png"
                    }

                    // connected to label
                    Item {
                        anchors.fill: parent
                        visible: anchorLabelToTop && used &&
                                 usedLabel.length > 0

                        Image {
                            anchors.centerIn: parent
                            source: "images/ptmbc_connector_label.png"
                        }
                        Text {
                            text: usedLabel
                            anchors.centerIn: parent
                            font {
                                family: "Lato-Bold"
                                pointSize: text.length > 2 ?
                                               res.longLabelFontSize :
                                               res.labelFontSize
                                italic: usedIdx >= 0
                            }
                            color: usedIdx >= 0 ? res.usedLabelAlternativeColor
                                                : res.usedLabelColor
                        }
                    }

                    Image {
                        id: bottomTrimUsed
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: res.usedBackground((anchorLabelToTop ? "tail" :
                                                                       "icon"))
                        visible: used
                    }
                }
            }
        }

        MouseArea {
            id: bgMouseArea
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
                return ((type === "dcard" || type === "io" || type === "cable")
                        && subtype === "ptmbc");
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent

            property bool containsValidDrag: false

            onEntered: {
                console.log("Ptmbc: dragged item (" + drag.source.text +
                            ") above drop area");
                containsValidDrag = dropAreaEx.isValidObject(
                            drag.source.userData);
            }
            onExited: {
                console.log("Ptmbc: dragged item (" + drag.source.text +
                            ") exited drop area");
                containsValidDrag = false;
            }
            onDropped: {
                console.log("Ptmbc: item (" + drag.source.text + ") dropped: " +
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
        anchors.centerIn: parent
        width: 15
        height: 95
        border {
            width: 1
            color: "#7f7f7f"
        }
        color: "#999999"
        opacity: 0.8
        visible: !enabled
    }
}
