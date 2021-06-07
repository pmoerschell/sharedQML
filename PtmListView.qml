import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: root
    border {
        width: 1
        color: 'lightgrey'
    }

    property alias currentIndex: listView.currentIndex
    property alias model: listView.model
    property bool enableAlias: false
    property string aliasSuffix: "_alias"

    signal selectionChanged()
    signal selectionActivated()

    Component {
        id: rowDelegate

        Rectangle {
            width: parent.width
            height: rowItemText.height + (enableAlias ? 5 : 0)
            color: listView.currentIndex === index ? "#308dc6" : "white"

            Text {
                id: rowItemText
                anchors.left: parent.left
                anchors.leftMargin: 2
                text: itemText
                color: listView.currentIndex === index ? "white" : "black"
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {
                    mouse.accepted = false;
                    listView.currentIndex = index;
                    listView.forceActiveFocus();
                    console.log("selected " + index + ": " +
                                listView.model.get(index).itemText);
                }
                onDoubleClicked: {
                    mouse.accepted = false;
                    listView.currentIndex = index;
                    listView.forceActiveFocus();
                    console.log("double clicked " + index + ": " +
                                listView.model.get(index).itemText);
                    root.selectionActivated();
                }

                TextField {
                    id: rowItemAlias
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    width: 200
                    height: parent.height
                    visible: enableAlias
                    placeholderText: qsTr("Type text to use as an alias")
                    onTextChanged: {
                        //var index = listView.currentIndex;
                        listView.model.get(index).itemAlias = text;
                    }
                    Component.onCompleted: {
                        text = rowItemText.text + aliasSuffix
                        listView.model.get(index).itemAlias = text;
                    }
                }
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 2

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            delegate: rowDelegate
            model: ListModel {}

            Keys.onUpPressed: decrementCurrentIndex()
            Keys.onDownPressed: incrementCurrentIndex()
            onCurrentIndexChanged: selectionChanged()
        }
    }
}
