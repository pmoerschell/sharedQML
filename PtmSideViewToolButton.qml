import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Cadence.Prototyping.Extensions 1.0

/*
  How to use this component:
  Attach an actiont to it which will handle the button behavior.
  Tooltip displayed will be the tooltip or the text set by corresponding action.
  Example:
    PtmSideViewToolButton { action: myCustomAction }
*/

Rectangle {
    id: root
    height: 20
    width: 20
    color: "transparent"

    property alias action: activeButton.action

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        ToolButton {
            id: activeButton
            anchors.fill: parent
            tooltip: "" // tooltip will be handled by PtmToolTip
        }
    }

    PtmToolTip {
        id: toolTip
        parent: root
        x: mouseArea.mouseX
        visible: mouseArea.containsMouse &&
                 text.length > 0
        text: (root.action.tooltip !== "") ?
                  root.action.tooltip : root.action.text
    }
}
