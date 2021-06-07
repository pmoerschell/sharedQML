import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

TabView {
    id: root
    tabPosition: Qt.BottomEdge
    style: TabViewStyle {
        frameOverlap: 0
        frame: Rectangle {
            color: "white"
            border {
                width: 1
                color: "#e7e7e7"
            }
        }
        tabBar : Rectangle {
            color: "#ffffff"
        }
        tab : Rectangle {
            implicitHeight: 24
            implicitWidth: Math.max(tabTitle.width + 20, 80)
            color: styleData.selected ? "#ffffff" : "#e7e7e7"
            radius: 2
            border {
                width: 1
                color: "#e7e7e7"
            }

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 2
                border {
                    width: 1
                    color: "#2da7df"
                }
                visible: styleData.selected
            }

            Text {
                id: tabTitle
                text: styleData.title
                anchors.centerIn: parent
                color: styleData.enabled ? "black" : "grey"
            }
        }
    }
}
