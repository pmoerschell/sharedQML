import QtQuick 2.9
import QtQuick.Controls 1.4
import Cadence.Prototyping.Extensions  1.0

Item {
    id: root

    property alias maptable: mtable
    property alias mapmodel: mtable.model
    property bool hideHeader: true

    TableView {
        id: mtable
        anchors.fill: parent
        backgroundVisible: false
        frameVisible: true
        alternatingRowColors: false
        model: ModelMapToTableView {}
        headerVisible: !hideHeader

        property int _currentRow: -1
        property int _currentColumn: -1
        property int headerHight: 0

        headerDelegate: Rectangle {
            height: headerText.implicitHeight * 1.2
            width: headerText.implicitWidth
            border {
                width: 0
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
                leftPadding: 5
                color: "black"
                renderType: Text.NativeRendering
                font {
                    family: "Lato-Regular"
                    pointSize: 10
                }
            }
            Component.onCompleted: {
                mtable.headerHight = height;
            }
        }

        rowDelegate: Item {
            height: mtable.headerHight
        }

        itemDelegate: Rectangle {
            border {
                width: 0
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
                horizontalAlignment: Qt.AlignLeft
                text: styleData.value === undefined ? "" : styleData.value
                elide: styleData.elideMode
                leftPadding: 5
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
                }
            }
        }
    }
}
