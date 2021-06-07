import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Cadence.Prototyping.Extensions  1.0



Rectangle {
    id: chart
    property alias model: listView.model
    property int targetWidth
    property alias chartHeight: chart.height
    width: Math.max(listView.contentWidth, targetWidth)

    Component {
        id: sectionDelegate

        Rectangle {
            id: section
            width: Math.max(parseFloat(percentage) / 100 * targetWidth, 150)
            height: chartHeight
            color: sectionColor
            border.width: 1
            border.color: 'black'

            Text {
                id: label
                width: parent.width
                height: parent.height
                text: name + "\n" + percentage.toFixed(1) + "%\n" + signals + " signals"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: labelMetrics.tightBoundingRect.width < parent.width
            }

            TextMetrics {
                id: labelMetrics
                font: label.font
                text: label.text
            }

            MouseArea {
                id: delegateMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.border.width = 2
                }

                onExited: {
                    parent.border.width = 1
                }
            }

            PtmToolTip {
                x: delegateMouseArea.mouseX
                visible: delegateMouseArea.containsMouse
                text: name + ": " + percentage.toFixed(1) + "% (" + signals + ")"
            }
        }
    }

    ListView {
        id: listView
        interactive: false
        anchors.fill: parent
        orientation: Qt.Horizontal
        delegate: sectionDelegate
        boundsBehavior: Flickable.StopAtBounds
    }
}


