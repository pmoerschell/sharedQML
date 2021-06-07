import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {
    id: root

    property int minimumWidth: 80
    property int minimumHeight: 20
    property int horizontalMargin: 20
    property int verticalMargin: 10

    style: ButtonStyle {
        background: Rectangle {
            radius: 3
            gradient: Gradient {
                GradientStop { color: "#ffffff"; position: 0 }
                GradientStop {
                    color: isPressed() ? "#edfcff" : (enabled ? "#ffffff"
                                                              : "#d7d7d7")
                    position: 1
                }
            }
            border {
                width: isFocused() ? 2 : 1
                color: isFocused() ? '#2da7df'
                                   : (control.enabled ? (isPressed() ? '#b0c1ca'
                                                                     : '#999999')
                                                      : '#e4e4e4')
            }
            implicitWidth: configure.buttonWidth()
            implicitHeight: configure.buttonHeight()
        }
        label: Item {
            Row {
                anchors.centerIn: parent
                spacing: 7

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: control.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: control.enabled ? 'black' : '#828282'
                    font {
                        family: 'Lato-Regular'
                        pixelSize: 12
                    }
                }
                Image {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    source: control.iconSource
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        property bool newEntry: false
        // There's a bug in QT - When you bring up a button initially not
        // visible and then make it visible, the mouseArea.containsMouse is
        // erroneaously set to true no matter whether is really true or not.
        // so when the visibility changes, we set another var to find out
        // whether entry into the MouseArea has happened.
        onEntered: newEntry = true;
        onVisibleChanged: newEntry = false;
    }

    function progclick() {
        if (root.enabled)
            root.clicked()
    }

    function isPressed() {
        return root.pressed || mouseArea.pressed;
    }

    function isFocused() {
        return root.activeFocus || (mouseArea.containsMouse &&
                                    mouseArea.newEntry);
    }

    QtObject {
        id: configure

        function buttonWidth()
        {
            return Math.max(configure.tempTextObject().width +
                            root.horizontalMargin, minimumWidth);
        }

        function buttonHeight()
        {
            return Math.max(configure.tempTextObject().height +
                            root.verticalMargin, minimumHeight);
        }

        function tempTextObject() {
            return Qt.createQmlObject('import QtQuick 2.0;' +
                          'Row { visible: false; spacing: ' +
                          (root.text.length > 0 ? '5' : '0') +
                          '; Image { source: "' +
                          root.iconSource + '" } Text { text: "' +
                          root.text + '"} }', root, "tmpObject");
        }
    }
}
