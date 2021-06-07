import QtQuick.Controls 1.4
import QtQuick 2.7
import QtQml.Models 2.3
import "Common.js" as Common
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root

    signal requestMoreData(var items)
    signal itemMouseRightClick(var index)
    signal activatedItemFullName(string fname)
    signal itemSelected(string fname)

    property alias currentIndex: selectionModel.currentIndex
    property alias model: xtree.model
    property alias itemDelegate: xtree.itemDelegate
    property alias frameVisible: xtree.frameVisible
    property alias alternatingRowColors: xtree.alternatingRowColors
    property alias headerVisible: xtree.headerVisible
    property bool multiSelectionEnabled: false
    property bool draggable: false
    property var columns: [
        {
            title: "Name",
            role: "displayName",
            width: 300,
            elide: Text.ElideMiddle
        }
    ]

    function nameByIndex(index)
    {
        return root.model.dataByRoleName(index, "name");
    }

    function fullNameByIndex(index)
    {
        return root.model.dataByRoleName(index, "fullName");
    }

    function dataModelByIndex(index)
    {
        return root.model.dataByRoleName(index, "dataModel");
    }

    function selectByIndex(index, expanded)
    {
        if (!index.valid)
            return;

        selectionModel.setCurrentIndex(index, ItemSelectionModel.ClearAndSelect);
        selectionModel.select(index, ItemSelectionModel.Current);

        expanded = (typeof expanded != 'undefined' ? expanded : false);
        if (expanded)
            expand(index);
    }

    function selectByFullName(item)
    {
        var index = root.model.indexByFullName(item);
        selectByIndex(index, true);
    }

    function activateFirst()
    {
        var index = root.model.index(0, 0);
        selectByIndex(index, true);
        activatedItemFullName(fullNameByIndex(index));
    }

    function expandFirst()
    {
        var index = root.model.index(0, 0);
        selectByIndex(index, true);
    }

    function expand(index)
    {
        selectionModel.select(index, ItemSelectionModel.Rows);
        selectionModel.select(index, ItemSelectionModel.Columns);
        // expand index and its' parents
        var idx = index;
        while (idx.valid) {
            xtree.expand(idx);
            idx = idx.parent;
        }
    }

    function clearSelection()
    {
        selectionModel.clear()
    }

    Keys.onPressed: {
        if ((event.key === Qt.Key_Space) &&
                (event.modifiers & Qt.ControlModifier))
            itemMouseRightClick(selectionModel.currentIndex);
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
            width: columns[styleData.column].width

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
                    width: Math.min(xtree.width - 15, delItem.width) -
                           nameImg.width - 5
                    elide: typeof columns[styleData.column].elide != 'undefined' ?
                        columns[styleData.column].elide : Text.ElideMiddle
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

    QtObject {
        id: controller

        property var columns: []

        function update()
        {
            var i;
            // clear existing
            for (i = 0; i < xtree.columnCount; i++)
                xtree.removeColumn(i);
            controller.columns = [];
            // add new
            for (i = 0; i < root.columns.length; i++) {
                if (controller.columns.indexOf(root.columns[i].title) === -1) {
                    var column = xtree.addColumn(columnComponent)
                    column.title = root.columns[i].title;
                    column.role = root.columns[i].role;
                    if (column.role === "decorationName")
                        column.delegate = nameWithIconDelegate;
                    column.width = root.columns[i].width;
                    controller.columns.push(column.title);
                }
            }
        }
    }

    onColumnsChanged: controller.update()

    ItemSelectionModel {
        id: selectionModel
        model: xtree.model

        onCurrentChanged: {
            itemSelected(fullNameByIndex(current));

            if (!root.draggable)
                return;

            // TODO: implement drag image for multiple items

            var dragAvatar = Common.findChild(xtree.contentItem,
                                              "dragAvatar" + current.row);
            if (dragAvatar) {
                dragAvatar.grabToImage(function(result) {
                    xtree.Drag.imageSource = result.url;
                });
                xtree.Drag.source = dataModelByIndex(current);
            }
        }
    }

    TreeView {
        id: xtree
        anchors.fill: parent
        frameVisible: true
        alternatingRowColors: false
        selection: selectionModel
        style: PtmTreeViewStyle {}
        selectionMode: multiSelectionEnabled ? SelectionMode.ExtendedSelection :
                                               SelectionMode.SingleSelection

        onActivated: {
            var x = fullNameByIndex(index);
            if (x.length > 0)
                activatedItemFullName(x);
        }

        onExpanded: {
            var x = root.model.children(index);
            if (x.length > 0)
                requestMoreData(x);
        }

        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.CopyAction
        Drag.mimeData: model.mimeDataListToMap(selectionModel.selectedIndexes)

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true

            onClicked: {
                var index = xtree.indexAt(mouse.x, mouse.y);
                selectByIndex(index);
                itemMouseRightClick(index);
            }
        }

        // INFO: Needed to manually enable drag.
        // if we rely on xtree.__mouseArea by updating
        // xtree.__mouseArea.drag.target and binding to
        // xtree.__mouseArea.drag.active to enable drag automatically,
        // dragged item gets moved after drop. To avoid it we need to bypass
        // updating xtree.__mouseArea.drag and enable drag in TreeView manually.
        // Drag is usually enabled after mouse press and move event.
        // This is the reason whe we still need to use xtree.__mouseArea
        // to receive those events.
        readonly property int dragDelay: 3
        property var pressedPosition: null
        Connections {
            target: xtree.__mouseArea
            onPressed: {
                xtree.pressedPosition = { "x" : mouse.x, "y" : mouse.y };
            }
            onPositionChanged: {
                if (xtree.Drag.active)
                    return;

                var xDelta = Math.abs(mouse.x - xtree.pressedPosition.x);
                var yDelta = Math.abs(mouse.y - xtree.pressedPosition.y);
                if (xDelta > xtree.dragDelay || yDelta > xtree.dragDelay)
                    xtree.Drag.active = true;
            }
        }
    }
}
