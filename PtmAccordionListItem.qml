import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Item {
    id: container

    property string fontName: "Lato-Regular"
    property int fontSize: 12
    property color fontColor: "black"
    property bool fontBold: false
    property string text: "NOT SET"
    property string userData: ""
    property string bgImage: 'images/accordion_list_item.png'

    property string bgImageSelected: 'images/accordion_list_item_selected.png'
    property string bgImagePressed: 'images/accordion_list_item_pressed.png'
    property string bgImageActive: 'images/accordion_list_item_active.png'
    property bool selected: false
    property bool selectable: false
    property int textIndent: 0
    signal clicked

    width: 360
    height: 64
    clip: true
    onSelectedChanged: selected ? state = 'selected' : state = ''

    BorderImage {
        id: background
        border { top: 9; bottom: 36; left: 35; right: 35; }
        source: bgImage
        anchors.fill: parent
    }

    Text {
        id: itemText
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            topMargin: 4
            bottomMargin: 4
            leftMargin: 8 + textIndent
            rightMargin: 8
            verticalCenter: container.verticalCenter
        }
        font {
            family: container.fontName
            pointSize: container.fontSize
            bold: container.fontBold
        }
        color: container.fontColor
        elide: Text.ElideRight
        text: container.text
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: container.clicked();
        onReleased: selectable && !selected ? selected = true : selected = false
    }

    states: [
        State {
            name: 'pressed'; when: mouseArea.pressed
            PropertyChanges {
                target: background;
                source: bgImagePressed;
                border { left: 35; top: 35; right: 35; bottom: 10 }
            }
        },
        State {
            name: 'selected'
            PropertyChanges {
                target: background;
                source: bgImageSelected;
                border { left: 35; top: 35; right: 35; bottom: 10 }
            }
        },
        State {
            name: 'active';
            PropertyChanges { target: background; source: bgImageActive; }
        }
    ]
}
