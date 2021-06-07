import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4

Dialog {
    id: root
    modality: Qt.WindowModal
    width: 600
    height: 600

    signal selected(string itemText)
    signal highlighted(string itemText)
    signal search(string pattern)

    property alias searchResultLabel: searchResultLabel.text
    property string bottomHint: ""

    function updateModel(data)
    {
        var li;
        var list = data.split(",");
        for (var i = 0; i < list.length; ++i) {
            li = list[i].trim();
            if (li === "")
                continue;
            searchResult.model.append({ itemText: li });
        }
    }

    function updateInfo(data)
    {
        infotext.text = bottomHint + data;
    }

    QtObject {
        id: controller

        function search()
        {
            var pattern = searchPattern.text;
            console.log("Search: onClicked: " + pattern);
            searchResult.model.clear()
            root.search(pattern);
            searchResultLabel.text = qsTr("Find results for ") +
                    "'" + pattern + "':";
        }

        function addToResult()
        {
            var index = searchResult.currentIndex;
            if (index < 0)
                return;

            var name = searchResult.model.get(index).itemText;
            for (var i = 0; i < resultlList.model.count; i++) {
                if (name === resultlList.model.get(i).itemText)
                    return;
            }
            resultlList.model.append({ itemText: name, itemAlias: "" });
        }

        function removeFromResult()
        {
            var index = resultlList.currentIndex;
            if (index < 0)
                return;

            resultlList.model.remove(index);
        }
    }

    contentItem: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                TextField {
                    id: searchPattern
                    Layout.fillWidth: true
                    placeholderText: qsTr("Type search pattern")
                    onAccepted: controller.search()
                }

                PtmTextButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Find")
                    onClicked: controller.search()
                }
            }

            Label {
                id: searchResultLabel
                Layout.fillWidth: true
                text: qsTr("Find results:")
            }

            PtmListView {
                id: searchResult
                Layout.fillWidth: true
                Layout.fillHeight: true
                onSelectionActivated: controller.addToResult()
                onSelectionChanged: {
                    var index = searchResult.currentIndex;
                    if (index < 0) {
                        infotext.text = "";
                        return;
                    }
                    highlighted(searchResult.model.get(index).itemText);
                }
            }

            PtmTextButton {
                id: addButton
                text: qsTr("Add")
                onClicked: controller.addToResult()
            }

            Label {
                id: resultLabel
                text: qsTrId("Selected:")
                Layout.fillWidth: true
            }

            PtmListView {
                id: resultlList
                Layout.fillWidth: true
                Layout.fillHeight: true
                onSelectionActivated: controller.removeFromResult()
            }

            PtmTextButton {
                id: removeButton
                text: qsTr("Remove")
                onClicked: controller.removeFromResult()
            }

            Text {
                id: infotext
                Layout.fillWidth: true
                text: qsTr(" ")
                color: '#2da7df'
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: qsTr(" ")
                    color: '#2da7df'
                }

                PtmTextButton {
                    id: cancelButton
                    text: qsTr("Cancel")
                    onClicked: {
                        console.log("search dialog cancelled");
                        root.close();
                    }
                }

                PtmTextButton {
                    id: assignButton
                    text: qsTr("OK")
                    enabled: resultlList.currentIndex >= 0
                    onClicked: {
                        var fname = "";
                        for (var i = 0; i < resultlList.model.count; i++) {
                            fname += (fname.length > 0 ? "," : "") +
                                    resultlList.model.get(i).itemText;
                        }
                        if (fname.length > 0) {
                            console.log("search dialog selected: " + fname);
                            selected(fname);
                        }
                        root.close();
                    }
                }
            }
        }
    }

    onVisibilityChanged: {
        if (visible)
            searchPattern.forceActiveFocus();
    }
}
