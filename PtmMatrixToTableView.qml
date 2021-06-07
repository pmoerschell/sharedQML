import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Cadence.Prototyping.Extensions  1.0

Item {
    id: root

    signal activatedTableCell(int row, int col)

    property alias model: mtable.model

    Component {
        id: columnComponent

        TableViewColumn {
            width: 150
            horizontalAlignment: Qt.AlignHCenter
        }
    }

    TableView {
        id: mtable
        anchors.fill: parent
        backgroundVisible: false
        frameVisible: true
        alternatingRowColors: false
        selectionMode: SelectionMode.NoSelection
        model: ModelMatrixToTableView {
            onModelReset: {
                for (var index = mtable.columnCount - 1; index >= 0 ; index--)
                    mtable.removeColumn(index);

                var colWidth = (root.width - 150) /
                        (root.model.columnCount() - 1);
                for (var i = 0; i < root.model.columnCount(); i++) {
                    var column = mtable.addColumn(columnComponent);
                    if (i === 0) {
                        column.title = "";
                        column.role = "Key";
                        column.width = column.width - root.model.columnCount() +
                                2;
                    } else {
                        column.title = root.model.headerData(i, 1).toString();
                        column.role = "Col" + (i - 1);
                        column.width = colWidth;
                    }
                }
            }
        }
        Component.onCompleted: {
            var column = addColumn(columnComponent);
            column.title = "";
            column.role = "Key";
            column.width = root.width - 2;
        }

        property int _currentRow: -1
        property int _currentColumn: -1
        property int headerHight: 0

        headerDelegate: Rectangle {
            height: headerText.implicitHeight * 1.2
            width: headerText.implicitWidth
            border {
                width: 1
                color: "#e7e7e7"
            }
            color: "#fafafa"

            Text {
                id: headerText
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: styleData.textAlignment
                anchors.leftMargin: 12
                text: styleData.value
                elide: Text.ElideRight
                color: "black"
                renderType: Text.NativeRendering
                font {
                    family: "Lato-Regular"
                    pointSize: 10
                }
            }
            Component.onCompleted: mtable.headerHight = height
        }

        rowDelegate: Item {
            height: mtable.headerHight
        }

        itemDelegate: Rectangle {
            border {
                width: 1
                color: "#e7e7e7"
            }
            color: styleData.column === 0 ? "#fafafa" :
                       (styleData.row === mtable._currentRow &&
                        styleData.column === mtable._currentColumn ?
                            "#e7e7e7" : "#ffffff")

            Text {
                id: textItem
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                text: styleData.value === undefined ? "" : styleData.value
                elide: styleData.elideMode
                color: styleData.textColor
                renderType: Text.NativeRendering
                font {
                    family: "Lato-Regular"
                    pointSize: 10
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: {
                    mtable._currentRow = styleData.row;
                    mtable._currentColumn = styleData.column;
                    activatedTableCell(styleData.row, styleData.column);
                }
            }
        }
    }
}
