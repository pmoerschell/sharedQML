import QtQuick 2.9
import QtQuick.Controls 2.2

ToolSeparator {
    id: root
    padding: vertical ? 5  : 2
    topPadding: vertical ? (parent.height - contentHeight) / 2 :
                           (parent.width - contentWidth) / 2
    bottomPadding: vertical ? (parent.height - contentHeight) / 2 :
                              (parent.width - contentWidth) / 2

    readonly property int contentWidth: vertical ? 1 : parent.width - 10
    readonly property int contentHeight: vertical ? parent.height - 10 : 1

    contentItem: Rectangle {
        implicitWidth: contentWidth
        implicitHeight: contentHeight
        color: "#d8d8d8"
    }
}
