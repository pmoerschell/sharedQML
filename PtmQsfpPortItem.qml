import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

Item {
    id: root
    width: 90
    height: 53

    signal mouseLeftClicked;
    signal mouseRightClicked;
    signal mouseDoubleClicked;
    signal mouseEntered;
    signal mouseExited;

    signal dropAccepted(string title, string data);
    signal dropRejected(string title, string data);

    readonly property string itemType: "qsfp_port"

    property int idx: -1
    property string label
    property string fullName
    property bool used: false
    /* supported:
        ""      - available
        "cable" - QSFP cable
    */
    property string usedType: ""
    property string usedLabel: ""
    property int usedIdx: -1
    property string usedData: ""
    property bool selected: false

    property string labelColor: "#000000"

    QtObject {
        id: res

        function usedBackground()
        {
            var uType = root.usedType;
            if (!root.used || uType.length === 0)
                return "#000000";

            return "#e87c1e";
        }

        property string usedLabelColor: "#0048ff"
        property string usedLabelAlternativeColor: "#ffffff"
        property int labelFontSize: 8
    }

    Text {
        id: portLabel
        text: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: enabled ? labelColor : "#999999"
        font {
            family: "Lato-Bold"
            pointSize: 8
            bold: bgMouseArea.containsMouse || dropArea.containsValidDrag ||
                  selected
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 13
        color: "transparent"
        width: parent.width
        height: parent.height - 13
        radius: 5
        border {
            color: bgMouseArea.containsMouse || dropArea.containsValidDrag ||
                   selected ? "#2da7df" : ""
            width: bgMouseArea.containsMouse || dropArea.containsValidDrag ||
                   selected ? 2 : 0
        }

        Rectangle {
            id: portBody
            anchors.centerIn: parent
            width: parent.width - 4
            height: parent.height - 4
            color: "#e7e7e7"
            radius: 5
            border {
                color: "black"
                width: 1
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 15
                height: parent.height - 15
                color: res.usedBackground()
                radius: 5
                border {
                    color: "#979797"
                    width: 0
                }

                Text {
                    text: usedLabel
                    anchors.centerIn: parent
                    color: usedIdx >= 0 ? res.usedLabelAlternativeColor :
                                          res.usedLabelColor
                    font {
                        family: "Lato-Bold"
                        pointSize: 8
                        italic: usedIdx >= 0
                        bold: bgMouseArea.containsMouse || dropArea.containsValidDrag ||
                              selected
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
                return ((type === "cable" || type === "dcard") &&
                          subtype === "qsfp");
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent

            property bool containsValidDrag: false

            onEntered: {
                console.log("Qsfp: dragged item (" + drag.source.text +
                            ") above drop area");
                containsValidDrag = dropAreaEx.isValidObject(
                            drag.source.userData);
            }
            onExited: {
                console.log("Qsfp: dragged item (" + drag.source.text +
                            ") exited drop area");
                containsValidDrag = false;
            }
            onDropped: {
                console.log("Qsfp: item (" + drag.source.text + ") dropped: " +
                            drag.source.userData);

                if (dropAreaEx.isValidObject(drag.source.userData))
                    dropAccepted(drag.source.text, drag.source.userData);
                else
                    dropRejected(drag.source.text, drag.source.userData);
                containsValidDrag = false;
            }
        }

        // disabled state
        Rectangle {
            anchors.centerIn: parent
            width: portBody.width
            height: portBody.height
            border {
                width: 1
                color: "#7f7f7f"
            }
            color: "#999999"
            opacity: 0.8
            visible: !enabled
        }
    }
}
