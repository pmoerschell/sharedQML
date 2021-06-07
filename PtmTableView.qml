import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQml.Models 2.3
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root

    property alias model: xtable.model
    property alias itemDelegate: xtable.itemDelegate
    property alias frameVisible: xtable.frameVisible
    property alias alternatingRowColors: xtable.alternatingRowColors
    property alias headerVisible: xtable.headerVisible
    property var columns: [
            { title: "Name", role: "displayName", width: 300 }
    ]

    signal itemMouseRightClick(int index)
    signal activatedItemFullName(string fname)

    function currentIndex()
    {
        return xtable.selection.currentIndex;
    }

    function fullNameByIndex(index)
    {
        return root.model.data(index, "fullName");
    }

    Component {
        id: columnComponent
        TableViewColumn { width: 30 }
    }

    onColumnsChanged:{
        var i;
        // clear existing
        for (i = 0; i < xtable.columnCount; i++)
            xtable.removeColumn(i);
        _columns = [];
        // add new
        for (i = 0; i < columns.length; i++) {
            if (_columns.indexOf(columns[i].title) === -1) {
                var column = xtable.addColumn(columnComponent)
                column.title = columns[i].title;
                column.role = columns[i].role;
                column.width = columns[i].width;
                _columns.push(column.title);
            }
        }
    }

    TableView {
        id: xtable
        frameVisible: true
        alternatingRowColors: false
        anchors.fill: parent

        selection: ItemSelectionModel {
             model: root.model
        }

        onActivated: {
            var x = fullNameByIndex(index);
            if (x.length > 0) activatedItemFullName(x)
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                var index = parent.indexAt(mouse.x, mouse.y);
                if (index.valid) {
                    xtable.selection.setCurrentIndex(
                                index, ItemSelectionModel.SelectCurrent);
                    xtable.selection.select(
                                index, ItemSelectionModel.SelectCurrent);
                    itemMouseRightClick(index.row);
                }
            }
        }
    }
    // for private use
    property var _columns: []
}
