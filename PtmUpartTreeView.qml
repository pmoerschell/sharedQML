import Cadence.Prototyping.Extensions 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick 2.7
import QtQml.Models 2.3
import QtQuick.Controls.Private 1.0

Item {
    id: root

    property alias model: utree.model
    property alias headerVisible: utree.headerVisible

    signal itemMouseRightClick(var index, string fname)
    signal activatedItemFullName(string fname)
    signal propertyRequestedPartitionGroup(int partnum)
    signal propertyRequestedHardwareItem(string fname)

    function nameByIndex(index)
    {
        return root.model.dataByRoleName(index, "name");
    }

    function fullNameByIndex(index)
    {
        return root.model.dataByRoleName(index, "fullName");
    }

    function expandFirst()
    {
        var index = root.model.index(0, 0);
        utree.expand(index);
    }

    function processUserMouseAction(index, useraction)
    {
        var x = fullNameByIndex(index);
        switch (useraction) {
        case 1:
            root.model.setHighlightContainer(index);
            if (x.length > 0)
                propertyRequestedHardwareItem(x);
            break;
        case 2:
            if (x.length > 0)
                activatedItemFullName(x);
            break;
        case 3:
            if (x.length > 0)
                propertyRequestedPartitionGroup(parseInt(x.substring(4), 10));
            break;
        case 4:
            if (x.length > 0) {
                root.model.setHighlightContainer(index);
                itemMouseRightClick(index, x);
            }
            break;
        case 5:
            if (x.length > 0) {
                utree.selection.select(index, ItemSelectionModel.Select);
                itemMouseRightClick(index, x);
            }
            break;
        default:
            break;
        }
    }

    function ensureVisible(index)
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
            while (utree.__model.mapRowToModelIndex(row) !== targetIndex) {
                if (!utree.__model.mapRowToModelIndex(row).valid) {
                    console.warn("Row not found")
                    return;
                }
                row++;
            }
            if (indexList.length > 0)
                utree.expand(utree.__model.mapRowToModelIndex(row));
        }

        //Found code in TableView source i could use for TreeView:
       // function positionViewAtRow(row, mode) { __listView.positionViewAtIndex(row, mode) }
    }

    TreeView {
        id: utree
        anchors.fill: parent
        frameVisible: true
        alternatingRowColors: false
        selection: ItemSelectionModel {
            id: utreesel
            model: root.model
        }
        selectionMode: SelectionMode.ExtendedSelection

        TableViewColumn { title: "Name"; role: "name"; width: 200 }
    
        style: TreeViewStyle {
            id: style1
            __indentation: 12
            rowDelegate: Rectangle {
                color: styleData.selected ?
                       "steelblue" :
                       (root.model.highlightContainer ===
                        style1.control.__model.mapRowToModelIndex(styleData.row)
                        ? "darkgray" : "transparent")
            }

            branchDelegate: StyleItem {
               id: si
               elementType: "itembranchindicator"
               properties: {
                   "hasChildren": styleData.hasChildren,
                   "hasSibling": styleData.hasSibling && !styleData.isExpanded
               }
               on: styleData.isExpanded
               selected: styleData.selected
               hasFocus: style1.control.activeFocus

               Component.onCompleted: {
                   style1.__indentation = si.pixelMetric("treeviewindentation");
                   implicitWidth = style1.__indentation;
                   implicitHeight = implicitWidth;
                   var rect = si.subControlRect("dummy");
                   width = rect.width;
                   height = rect.height;
               }
           }
        }

        itemDelegate: DragableViewItem {
            displayText: styleData.value
            cellIndex: styleData.index
            dragable: root.model.dataByRoleName(styleData.index, "DragAbleRole")
            enabled: root.model.dataByRoleName(styleData.index, "EnabledRole")
            iconImage: root.model.dataByRoleName(styleData.index, "DecorationImage")
            allSelection: utreesel
            dropTargeted: root.model.dataByRoleName(styleData.index, "DropTargetRole")
            Component.onCompleted:{
                userMouseAction.connect(processUserMouseAction);
            }
        }

        Keys.onEscapePressed: {
            utreesel.clear();
            event.accepted = true;
        }
    }

    DropArea {
        anchors.fill: parent
        onDropped: {
            var pgs = drop.getDataAsString("application/ptmgui-part-group");
            if (pgs.length > 0) {
                drop.accept(root.model.processDropEvent(
                                utree.indexAt(drop.x, drop.y), pgs));
            }
        }
        onPositionChanged: {
            root.model.setDropTarget(utree.indexAt(drag.x, drag.y));
        }
        onExited: {
            root.model.setDropTarget();
        }
    }
}    
