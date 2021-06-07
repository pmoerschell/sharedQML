import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

Item {
    id: root
    width: 220
    height: 40

    signal mouseLeftClicked;
    signal mouseRightClicked;
    signal mouseDoubleClicked;

    readonly property string itemType: "switchboard"

    property int idx: -1
    property alias label: qsfpLabel.text
    property string fullName
    property bool used: true

    function unitImage()
    {
        console.log("Switch board " + fullName + " used = " + used);
        if (used) {
            if (bgMouseArea.containsMouse)
                return enabled ? "images/x1_chassis_qsfp_switch_hover.png" :
                                 "images/chassis_board_disabled_hover.png";
            else
                return enabled ? "images/x1_chassis_qsfp_switch.png" :
                                 "images/chassis_board_disabled.png";
        } else {
            if (bgMouseArea.containsMouse)
                return "images/chassis_board_empty_hover.png";
            else
                return "images/chassis_board_empty.png";
        }
    }

    Image {
        id: bg
        anchors.fill: parent
        source: unitImage()

        MouseArea {
            id: bgMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.RightButton)
                    mouseRightClicked();
                else if (mouse.button === Qt.LeftButton)
                    mouseLeftClicked();
            }
            onDoubleClicked: mouseDoubleClicked()
        }
    }

    Text {
        id: qsfpLabel
        anchors.centerIn: parent
        color: used ? "black" : "#7f7f7f"
        font {
            family: "Lato-Bold"
            pointSize: 14
            bold: bgMouseArea.containsMouse
        }
    }
}
