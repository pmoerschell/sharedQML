import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: root
    color: "black"
    width: 61
    height: 120
    border.color: bgMouseArea.containsMouse || dropArea.containsValidDrag ?
                      "#2da7df" : "white"
    border.width: bgMouseArea.containsMouse || dropArea.containsValidDrag ?
                      2 : 1

    signal mouseLeftClicked;
    signal mouseRightClicked;
    signal mouseDoubleClicked;

    signal dropAccepted(string title, string data);
    signal dropRejected(string title, string data);

    readonly property string itemType: "ptmbc_dcard_location"

    property int idx: -1
    property string location
    property string connector
    property string defaultProgrammingConnector

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
    }

    QtObject {
        id: dropAreaEx

        function isObjectDaughterCard(userData) {
            var data = userData.split(";");
            if (data.length < 2)
                return false;

            var type = data[0];
            var subtype = data[1];
            return (type === "dcard" && subtype === "ptmbc");
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent

        property bool containsValidDrag: false

        onEntered: {
            console.log("DCard Loc: dragged item (" + drag.source.text +
                        ") above drop area");
            containsValidDrag = dropAreaEx.isObjectDaughterCard(
                        drag.source.userData);
        }
        onExited: {
            console.log("DCard Loc: dragged item (" + drag.source.text +
                        ") exited drop area");
            containsValidDrag = false;
        }
        onDropped: {
            console.log("DCard Loc: item (" + drag.source.text + ") dropped: " +
                        drag.source.userData);

            if (dropAreaEx.isObjectDaughterCard(drag.source.userData))
                dropAccepted(drag.source.text, drag.source.userData);
            else
                dropRejected(drag.source.text, drag.source.userData);
            containsValidDrag = false;
        }
    }
}
