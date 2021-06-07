import QtQuick.Controls 1.4
import QtQuick 2.7
import QtQml.Models 2.3
import "Common.js" as Common
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root

    property alias currentIndex: xtree.currentIndex
    property alias model: xtree.model
    property bool draggable: false
    property var columns: [
            { title: "Name", role: "displayName", width: 300 }
    ]

    signal activatedItemLink(string link)
    signal itemMouseRightClick(var index)

    Keys.onPressed: {
        if ((event.key === Qt.Key_Space) &&
                (event.modifiers & Qt.ControlModifier))
            itemMouseRightClick(xtree.currentIndex);
    }

    function nameByIndex(index)
    {
        return root.model.data(index, "name");
    }

    function linkByIndex(index)
    {
        return root.model.data(index, "link");
    }

    function dataModelByIndex(index)
    {
        return root.model.data(index, "dataModel");
    }

    function updateSelectionByIndex(index)
    {
        if (!index.valid)
            return;

        // get row index (int)
        var row = 0;
        var indexList = [];
        while (index.valid) {
            indexList.push(index);
            index = index.parent;
        }
        while (indexList.length > 0) {
            var targetIndex = indexList.pop();
            while (xtree.__model.mapRowToModelIndex(row) !== targetIndex) {
                if (!xtree.__model.mapRowToModelIndex(row).valid) {
                    console.warn("Row not found")
                    return;
                }
                row++;
            }
            if (indexList.length > 0)
                xtree.expand(xtree.__model.mapRowToModelIndex(row));
        }
        xtree.__currentRow = row;
    }

    function expandFirst()
    {
        var index = root.model.index(0, 0);
        updateSelectionByIndex(index);
        xtree.expand(index);
    }

    Component {
        id: columnComponent
        TableViewColumn { width: 30 }
    }

    Component {
        id: nameWithIconDelegate
        Item {
            id: delItem
            objectName: "dragAvatar" + styleData.index.row

            property string label: styleData.value === undefined ||
                                 styleData.value.indexOf(";") === -1 ?
                                 styleData.value : styleData.value.split(";")[0]

            Row {
                spacing: 3

                Image {
                    id: nameImg
                    anchors.verticalCenter: parent.verticalCenter
                    source: styleData.value === undefined ||
                            styleData.value.indexOf(";") === -1 ?
                                "" : styleData.value.split(";")[1]
                }
                Text {
                    id: nameText
                    text: delItem.label
                    color: currentIndex === styleData.index ? "white" : "black"
                    width: xtree.width - nameImg.width - 20
                    elide: Text.ElideMiddle
                }

                PtmToolTip {
                    parent: nameText
                    x: deledateMouseArea.mouseX
                    visible: deledateMouseArea.containsMouse
                    text: delItem.label
                }
            }

            MouseArea {
                id: deledateMouseArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onPressed: mouse.accepted = false
                onClicked: mouse.accepted = false
            }
        }
    }

    onColumnsChanged:{
        var i;
        // clear existing
        for (i = 0; i < xtree.columnCount; i++)
            xtree.removeColumn(i);
        _columns = [];
        // add new
        for (i = 0; i < columns.length; i++) {
            if (_columns.indexOf(columns[i].title) === -1) {
                var column = xtree.addColumn(columnComponent)
                column.title = columns[i].title;
                column.role = columns[i].role;
                if (column.role === "decorationName")
                    column.delegate = nameWithIconDelegate;
                column.width = columns[i].width;
                _columns.push(column.title);
            }
        }
    }

    TreeView {
        id: xtree
        anchors.fill: parent
        frameVisible: true
        alternatingRowColors: false
        headerVisible: false
        style: PtmTreeViewStyle {}

        onActivated: {
            var x = linkByIndex(index);
            if (x.length > 0) activatedItemLink(x)
        }

        //onPressAndHold: { - it's taking longer on hold to create thumbnail
        on__CurrentRowChanged: {
            if (root.draggable) {
                var index = xtree.__model.mapRowToModelIndex(xtree.__currentRow);
                var dragAvatar = Common.findChild(xtree.contentItem,
                                                  "dragAvatar" + index.row);
                if (dragAvatar) {
                    xtree.__mouseArea.drag.target = dragAvatar
                    dragAvatar.grabToImage(function(result) {
                        Drag.imageSource = result.url
                    });
                    Drag.source = dataModelByIndex(index);
                }
            }
        }

        Drag.active: xtree.__mouseArea.drag.active;
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.CopyAction
        Drag.mimeData: root.model.mimeDataToMap(xtree.currentIndex)

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true

            onPressed: {
                var pressedRow = xtree.__listView.indexAt(
                            0, mouseY + xtree.__listView.contentY);
                xtree.__mouseArea.pressedIndex =
                        xtree.__model.mapRowToModelIndex(pressedRow);
                xtree.__mouseArea.pressedColumn =
                        xtree.__listView.columnAt(mouseX);
                xtree.__mouseArea.selectOnRelease = false;
                xtree.__listView.forceActiveFocus();
                if (xtree.__mouseArea.branchDecorationContains(mouse.x, mouse.y)
                        || pressedRow === -1) {
                    return;
                }
                if (xtree.__mouseArea.selectionMode ===
                        SelectionMode.ExtendedSelection
                    && xtree.__mouseArea.selection.isSelected(
                            xtree.__mouseArea.pressedIndex)) {
                    xtree.__mouseArea.selectOnRelease = true;
                    return;
                }
                xtree.__listView.currentIndex = pressedRow;
                if (!xtree.__mouseArea.clickedIndex)
                    xtree.__mouseArea.clickedIndex =
                            xtree.__mouseArea.pressedIndex;
                xtree.__mouseArea.mouseSelect(xtree.__mouseArea.pressedIndex,
                                              mouse.modifiers, false);
                if (!mouse.modifiers)
                    xtree.__mouseArea.clickedIndex =
                            xtree.__mouseArea.pressedIndex;
            }

            onClicked: {
                var index = xtree.indexAt(mouse.x, mouse.y);
                if (!index.valid)
                    return;

                itemMouseRightClick(index);
            }
        }
    }
    // for private use
    property var _columns: []
}
