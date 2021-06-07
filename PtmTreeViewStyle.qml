import QtQuick 2.7
import QtQuick.Controls.Styles 1.4

TreeViewStyle {
    backgroundColor: "white"
    alternateBackgroundColor: "white"
    rowDelegate: Rectangle {
        color: (styleData.selected && control.activeFocus) ?
                   "steelblue" : (styleData.selected) ?
                       "darkgray" : "transparent"
    }

    branchDelegate: Item {
        width: 16
        height: 16
        Text {
            visible: styleData.column === 0 && styleData.hasChildren
            text: styleData.isExpanded ? "\u25be" : "\u25b8"
            color: "#404040"
            font.pointSize: 9
            renderType: Text.NativeRendering
            style: Text.PlainText
            anchors.centerIn: parent
        }
    }
}
