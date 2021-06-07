import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 as Q2
import Cadence.Prototyping.Extensions 1.0

Rectangle {
    id: root
    height: 72
    width: 70
    gradient: Gradient {
        GradientStop { color: "#e2e2e2"; position: 0 }
        GradientStop { color: "#ffffff"; position: 1 }
    }
    border {
        width: mouseArea.containsMouse || mouseArea.pressed ||
               arrowMouseArea.containsMouse || arrowMouseArea.pressed ||
               optionsPopup.visible ? 1 : 0
        color: mouseArea.containsPress || arrowMouseArea.pressed ||
               optionsPopup.visible ?
                   '#2da7df' : (mouseArea.containsMouse ||
                                arrowMouseArea.containsMouse ? '#999999' : '')
    }

    signal clicked
    signal optionClicked(string value)

    property string iconSource: ""
    property string iconDisabledSource: iconSource
    property string iconHoverSource: ""
    property alias title: title.text
    property alias tooltip: tooltip.text
    property var options: []

    QtObject {
        id: configure

        function dropdownPopupWidth()
        {
            var max = 0
            for (var i = 0; i < options.length; i++) {
                textMetrics.text = options[i].title;
                max = Math.max(max, textMetrics.width);
            }
            return max + 40;
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: root.clicked()
    }

    Row {
        id: iconRow
        anchors.topMargin: 2
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: childrenRect.width
        height: iconItem.height
        spacing: 5

        Item {
            id: iconItem
            width: 36
            height: 36

            Image {
                anchors.centerIn: parent
                source: iconSrc()
                smooth: mouseArea.containsMouse

                function iconSrc()
                {
                    if (iconHoverSource.length === 0)
                        return (root.enabled ? iconSource : iconDisabledSource);

                    return (mouseArea.containsMouse || mouseArea.containsPress ||
                            arrowMouseArea.containsMouse || arrowMouseArea.pressed ||
                            optionsPopup.visible ? iconHoverSource :
                                   (root.enabled ? iconSource : iconDisabledSource));
                }
            }
        }

        Item {
            id: dropdownArrow
            anchors.verticalCenter: parent.verticalCenter
            visible: options.length !== 0
            width: 8
            height: 6

            Image {
                anchors.centerIn: parent
                source: arrowSrc()
                smooth: mouseArea.containsMouse

                function arrowSrc()
                {
                    if (options.length === 0)
                        return "";

                    return (arrowMouseArea.containsPress ||
                            arrowMouseArea.pressed || optionsPopup.visible ?
                                     "images/dropdown_arrow_pressed.png" :
                                (mouseArea.containsMouse ||
                                 arrowMouseArea.containsMouse ?
                                     "images/dropdown_arrow_hover.png" :
                                (root.enabled ? "images/dropdown_arrow_idle.png"
                                              : "images/dropdown_arrow_disabled.png")));
                }
            }

            MouseArea {
                id: arrowMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                onClicked: optionsPopup.open();
            }
        }
    }

    Text {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 1
        anchors.top: iconRow.bottom
        anchors.rightMargin: 2
        anchors.leftMargin: 2
        width: parent.width - 4
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        color: enabled ? 'black' : '#4a4a4a'
        horizontalAlignment: Text.AlignHCenter | Text.AlignTop
        font {
            family: "Lato-Regular"
            pointSize: 8
        }
    }

    PtmToolTip {
        id: tooltip
        parent: parent
        x: mouseArea.mouseX
        visible: text.length > 0 && mouseArea.containsMouse
    }

    TextMetrics {
        id: textMetrics
        font {
            family: title.font.family
            pointSize: title.font.pointSize
            bold: title.font.bold
        }
    }

    // TODO: convert it to component to create dynamically
    Q2.Popup {
        id: optionsPopup
        x: 0
        y: iconRow.height
        implicitHeight: contentItem.implicitHeight + 2
        leftPadding: 1
        rightPadding: 0
        topPadding: 6
        bottomPadding: 6
        contentItem: ListView {
            id: optionsListView
            clip: true
            implicitHeight: contentHeight + 10
            model: options
            currentIndex: -1
            Q2.ScrollIndicator.vertical: Q2.ScrollIndicator {}
            delegate: Rectangle {
                height: 20
                width: parent.width - 1
                color: optionsListView.currentIndex === index ? "#308dc6"
                                                              : "#fbfbfb"

                Row {
                    spacing: 5

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        height: 1
                    }
                    Image {
                        id: optionIcon
                        anchors.verticalCenter: parent.verticalCenter
                        source: modelData.icon
                    }
                    Text {
                        id: nameText
                        anchors.verticalCenter: parent.verticalCenter
                        color: optionsListView.currentIndex === index ? "white"
                                                                      : "black"
                        text: modelData.title
                    }
                    PtmToolTip {
                        parent: nameText
                        x: popupMouseArea.width
                        y: popupMouseArea.height
                        visible: popupMouseArea.containsMouse
                        text: modelData.desc
                    }
                }

                MouseArea {
                    id: popupMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    acceptedButtons: Qt.LeftButton
                    onContainsMouseChanged: {
                        if (popupMouseArea.containsMouse)
                            optionsListView.currentIndex = index;
                    }
                    onClicked: {
                        mouse.accepted = true;
                        var value = modelData.value;
                        optionsPopup.close();
                        optionClicked(value);
                    }
                }
            }
        }
        background: Rectangle {
            border.color: "#d8d8d8"
            color: "#fbfbfb"
            radius: 4

//            DropShadow {
//                anchors.fill: parent
//                horizontalOffset: 0
//                verticalOffset: 2
//                radius: 4.0
//                samples: 9
//                color: "#999999"
//                spread: 0
//                source: parent
//            }
        }
        onOpened: {
            optionsListView.currentIndex = -1;
        }
        onClosed: {
            optionsListView.currentIndex = -1;
        }
        Component.onCompleted: {
            width = configure.dropdownPopupWidth();
        }
    }
}
