import QtQuick 2.9
import QtQuick.Controls 1.4
import Cadence.Prototyping.Extensions  1.0

/* How to use this commponent?
  Genrally put inside Layout, since the size various by content, it will be
  hard to position this without a layout manager.

PtmListsToTableView {
    id: table1
    Layout.preferredHeight: table1.height
    Layout.preferredWidth: table1.width
    Connections {
        target: PlaceAndRouteController
        onUpdateTable1: table1.listsmodel.resetLists(data, h);
    }
}
*/

Rectangle {
    id: root

    property int fontsize: 14
    property bool autoResizeColtoContent : false

    //signal activatedTableCell(int row, int col)

    Component{
        id: c0
        TableViewColumn{width: 120; elideMode: Text.ElideMiddle; resizable: true }
    }

    function resetTableView() {

        width = lists2tablemodel.columnCount() * 120 + 16 // pre allocate some space for scrollbar, 16
        height = (lists2tablemodel.maxRowCount() + 1) * (fontsize + 6 + 1) + 16
        for (var index=lists2table.columnCount-1; index>=0; index--)
            lists2table.removeColumn(index)

        for(var i = 0; i< lists2tablemodel.columnCount(); i++) {
            var column = lists2table.addColumn(c0)
            column.title = lists2tablemodel.headerData(i, 1).toString();
            column.role = "ListDataCol" + i;
        }

        if (autoResizeColtoContent) {
            Qt.callLater(lists2table.resizeColToContents)
        }
    }

    ModelListsToTableView {
        id: lists2tablemodel
        onModelReset: resetTableView()
    }

    TableView {
        id: lists2table
        frameVisible: true
        alternatingRowColors: true
        anchors.fill: parent
        model: lists2tablemodel
        selectionMode: SelectionMode.NoSelection

        rowDelegate: Rectangle {
           height: fontsize + 6
           SystemPalette {
              id: myPalette;
              colorGroup: SystemPalette.Active
           }
           color: {
              var baseColor = styleData.alternate?myPalette.alternateBase:myPalette.base
              return styleData.selected?myPalette.highlight:baseColor
           }
        }

        property int  _currentRow: -1
        property int  _currentColumn: -1

        Keys.onEscapePressed: {
            lists2table._currentRow = -1
            lists2table._currentColumn = -1
        }

        //Arrowkeys navigation
        Keys.onRightPressed: {
            _currentColumn = (_currentColumn < columnCount - 1) ?
                        _currentColumn + 1 : 0;
            if (_currentRow == -1)
                _currentRow = 0;
        }

        Keys.onLeftPressed: {
            _currentColumn = (_currentColumn > 0) ?
                        _currentColumn - 1 : 0;
            if (_currentRow == -1)
                _currentRow = 0;
        }

        Keys.onUpPressed: {
            _currentRow = (_currentRow > 0) ?
                        _currentRow - 1 : 0;
            if (_currentColumn == -1)
                _currentColumn = 0;
        }

        Keys.onDownPressed: {
            _currentRow = (_currentRow < rowCount - 1) ?
                        _currentRow + 1 : 0;
            if (_currentColumn == -1)
                _currentColumn = 0;
        }

        itemDelegate: Rectangle {
            id: tablecell
            color: "transparent"
            border {
                width: (styleData.row === lists2table._currentRow
                        && styleData.column === lists2table._currentColumn
                        && lists2table.activeFocus) ?
                           2 :  1
                color: (styleData.row === lists2table._currentRow
                        && styleData.column === lists2table._currentColumn
                           && lists2table.activeFocus) ?
                                '#2da7df' :  "transparent"
            }
            implicitWidth: textItem.implicitWidth + textItem.leftPadding + textItem.rightPadding
            Text {
                id: textItem
                anchors.fill: parent
                color: styleData.textColor
                elide: styleData.elideMode
                leftPadding: 6
                rightPadding: 6
                text:  (styleData.value === undefined ) ? "" : styleData.value
                font.pixelSize: fontsize
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: {
                    lists2table.forceActiveFocus();
                    lists2table._currentRow = styleData.row
                    lists2table._currentColumn = styleData.column
                    //activatedConnectivity(styleData.row, styleData.column)
                }
            }
        }

        function resizeColToContents() {
            var w=0;
            for (var i = 0; i < lists2tablemodel.columnCount(); ++i) {
                var col = lists2table. getColumn(i)
                var header = lists2table.__listView.headerItem.headerRepeater.itemAt(i)
                if (col) {
                    col.__index = i
                    col.resizeToContents()
                    if (col.width < header.implicitWidth)
                        col.width = header.implicitWidth
                }
                w+=col.width;
            }
            root.width = (w+6);
        }
    }

    property alias liststable: lists2table
    property alias listsmodel: lists2table.model
}




