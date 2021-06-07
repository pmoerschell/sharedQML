import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: root
    color: "transparent"
    width: 24
    height: biggerSize ? 90 : 64
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

    readonly property string itemType: "programming_connector"

    property int idx: -1
    property string label
    property string fullName
    property bool used: false
    /* supported:
        ""      - available
        "dc"    - Daughter card
        "io"    - I/O board
    */
    property string usedType: ""
    property string usedLabel: ""
    property int usedIdx: -1
    property string usedData: ""
    property bool selected: false
    property bool biggerSize: false

    QtObject {
        id: res

        function background()
        {
            var img = "images/prog_connector" + (biggerSize ? "_big" : "") +
                    ".png"
            if (!root.used)
                return img;

            var uType = root.usedType;
            if (uType.length === 0)
                return img;

            img = "images/prog_connector" + (biggerSize ? "_big" : "") +
                    "_used_" + uType + ".png"
            return img;
        }
    }

    Item {
        anchors.centerIn: parent
        width: root.width - 4
        height: root.height - 4

        // connector background
        Image {
            anchors.fill: parent
            anchors.centerIn: parent
            source: res.background()
            fillMode: Image.PreserveAspectCrop
        }
        Text {
            text: label
            anchors.centerIn: parent
            rotation: root.rotation * 2 + 90
            color: "white"
            font {
                family: "Lato-Bold"
                pointSize: 7
                bold: bgMouseArea.containsMouse ||
                      dropArea.containsValidDrag || selected
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
                return (type === "dcard" || type === "io");
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent

            property bool containsValidDrag: false

            onEntered: {
                console.log("Prog: dragged item (" + drag.source.text +
                            ") above drop area");
                containsValidDrag = dropAreaEx.isValidObject(
                            drag.source.userData);
            }
            onExited: {
                console.log("Prog: dragged item (" + drag.source.text +
                            ") exited drop area");
                containsValidDrag = false;
            }
            onDropped: {
                console.log("Prog: item (" + drag.source.text + ") dropped: " +
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
