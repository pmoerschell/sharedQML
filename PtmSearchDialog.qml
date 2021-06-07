import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4

Dialog {
    id: root
    modality: Qt.WindowModal
    width: 600
    height: 300

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
                onSelectionChanged: {
                    var index = searchResult.currentIndex;
                    if (index < 0) {
                        infotext.text = "";
                        return;
                    }
                    highlighted(searchResult.model.get(index).itemText);
                }
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
                    enabled: searchResult.currentIndex >= 0
                    onClicked: {
                        var index = searchResult.currentIndex;
                        if (index >= 0) {
                            var fname = searchResult.model.get(index).itemText;
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
