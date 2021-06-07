import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2 as Quick2

Quick2.ToolTip {
    id: root
    delay: 1000
    timeout: 5000

    property int decoration: simpleStyle
    readonly property int simpleStyle: 0
    readonly property int arrowLeftTopStyle: 1
    readonly property int arrowLeftStyle: 2
    readonly property int arrowLeftBottomStyle: 3
    readonly property int arrowRightTopStyle: 4
    readonly property int arrowRightStyle: 5
    readonly property int arrowRightBottomStyle: 6
    readonly property int arrowTopStyle: 7
    readonly property int arrowBottomStyle: 8

    property alias title: titleText.text
    property font titleFont: Qt.font({
        family: "Lato-Bold",
        bold: true,
        pointSize: 8
    })
    property font textFont: Qt.font({
        family: "Lato-Regular",
        pointSize: 8,
    })

    TextMetrics {
        id: textMetrics
        font: textFont
    }

    QtObject {
        id: configure

        readonly property int arrowWidth: 14
        readonly property int arrowHeight: 17
        property int arrowRectHeight: root.parent ? root.parent.height : 0
        readonly property int textMargin: 9

        function controlWidth()
        {
            var val;
            if (decoration == simpleStyle) {
                textMetrics.text = descText.text;
                val = textMetrics.width + textMargin * 2;
            } else if (decoration == arrowLeftTopStyle ||
                       decoration == arrowLeftStyle ||
                       decoration == arrowLeftBottomStyle ||
                       decoration == arrowRightTopStyle ||
                       decoration == arrowRightStyle ||
                       decoration == arrowRightBottomStyle) {
                val = root.parent.width + arrowWidth;
            }
            return val;
        }

        function controlHeight()
        {
            var val;
            if (decoration == simpleStyle) {
                textMetrics.text = descText.text;
                val = textMetrics.height + textMargin * 2;
            } else if (decoration == arrowLeftTopStyle ||
                       decoration == arrowLeftStyle ||
                       decoration == arrowLeftBottomStyle ||
                       decoration == arrowRightTopStyle ||
                       decoration == arrowRightStyle ||
                       decoration == arrowRightBottomStyle) {
                textMetrics.text = descText.text;
                var lines = textMetrics.width /
                        (controlWidth() - arrowWidth - textMargin * 2) + 1;
                val = Math.max(root.parent.height,
                               (textMetrics.height + textMargin * 0.5) * lines +
                               textMargin * 3);
            }
            return val;
        }
    }

    // since we depend on parent size which may change after tooltip has been
    // created, we need to resize to parent actual size on tooltip showing
    onVisibleChanged: {
        if (!parent)
            return;

        width = configure.controlWidth();
        height = configure.controlHeight();
        if (decoration == arrowLeftTopStyle ||
                decoration == arrowLeftStyle ||
                decoration == arrowLeftBottomStyle) {
            x = parent.width;
            y = parent.y;
        } else if (decoration == arrowRightTopStyle ||
                   decoration == arrowRightStyle ||
                   decoration == arrowRightBottomStyle) {
            x = -width;
            y = parent.y;
        }
    }

    contentItem: Item {
        anchors.fill: parent
        implicitHeight: (titleText.visible) ?
                            (descText.height + titleText.height) :
                            descText.height
        implicitWidth: descText.width

        anchors.leftMargin: decoration == arrowLeftTopStyle ||
                            decoration == arrowLeftStyle ||
                            decoration == arrowLeftBottomStyle ?
                                configure.arrowWidth : 0
        anchors.rightMargin: decoration == arrowRightTopStyle ||
                             decoration == arrowRightStyle ||
                             decoration == arrowRightBottomStyle ?
                                 configure.arrowWidth : 0
        anchors.topMargin: decoration == arrowTopStyle ?
                               configure.arrowWidth : 0
        anchors.bottomMargin: decoration == arrowBottomStyle ?
                                  configure.arrowWidth : 0

        Column {
            anchors.fill: parent
            anchors.margins: configure.textMargin
            spacing: 3

            Text {
                id: titleText
                width: parent.width - configure.textMargin * 2
                wrapMode: decoration == simpleStyle ? Text.NoWrap :
                                                      Text.Wrap
                font: titleFont
                color: "white"
                visible: text.length > 0
            }
            Text {
                id: descText
                width: parent.width - configure.textMargin * 2
                wrapMode: decoration == simpleStyle ? Text.NoWrap :
                                                      Text.Wrap
                textFormat: Text.RichText
                text: root.text
                font: textFont
                color: "white"
            }
        }
    }
    background: Item {
        anchors.fill: parent

        Component {
            id: arrowComponent
            Canvas {
                id: canvas
                contextType: "2d"
                onPaint: {
                    var ctx = getContext(contextType);
                    ctx.reset();
                    if (direction == arrowLeftStyle) {
                        ctx.moveTo(configure.arrowWidth, 0);
                        ctx.lineTo(configure.arrowWidth, configure.arrowHeight);
                        ctx.lineTo(0, configure.arrowHeight / 2);
                    } else if (direction == arrowRightStyle) {
                        ctx.moveTo(0, 0);
                        ctx.lineTo(0, configure.arrowHeight);
                        ctx.lineTo(configure.arrowWidth,
                                   configure.arrowHeight / 2);
                    } else if (direction == arrowTopStyle) {
                        ctx.moveTo(0, configure.arrowWidth);
                        ctx.lineTo(configure.arrowHeight, configure.arrowWidth);
                        ctx.lineTo(configure.arrowHeight / 2, 0);
                    } else if (direction == arrowBottomStyle) {
                        ctx.moveTo(0, 0);
                        ctx.lineTo(configure.arrowHeight, 0);
                        ctx.lineTo(configure.arrowHeight / 2,
                                   configure.arrowWidth);
                    }
                    ctx.closePath();
                    ctx.fillStyle = "#202b36";
                    ctx.fill();
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // left arrow
            Item {
                Layout.fillHeight: true
                visible: decoration == arrowLeftTopStyle ||
                         decoration == arrowLeftStyle ||
                         decoration == arrowLeftBottomStyle
                width: configure.arrowWidth

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // down pusher
                    Item {
                        Layout.fillHeight: true
                        visible: decoration == arrowLeftBottomStyle ||
                                 decoration == arrowLeftStyle
                    }
                    Item {
                        width: configure.arrowWidth
                        height: configure.arrowRectHeight
                        Loader {
                            anchors.centerIn: parent
                            width: configure.arrowWidth
                            height: configure.arrowHeight
                            property int direction: arrowLeftStyle
                            sourceComponent: arrowComponent
                        }
                    }
                    // down up
                    Item {
                        Layout.fillHeight: true
                        visible: decoration == arrowLeftTopStyle ||
                                 decoration == arrowLeftStyle
                    }
                }
            }
            // middle
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // top arrow
                    Item {
                        Layout.fillWidth: true
                        height: configure.arrowWidth
                        visible: decoration == arrowTopStyle

                        Loader {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: configure.arrowHeight
                            height: configure.arrowWidth
                            property int direction: arrowTopStyle
                            sourceComponent: arrowComponent
                        }
                    }
                    // content area
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#202b36"
                    }
                    // bottom arrow
                    Item {
                        Layout.fillWidth: true
                        height: configure.arrowWidth
                        visible: decoration == arrowBottomStyle

                        Loader {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: configure.arrowHeight
                            height: configure.arrowWidth
                            property int direction: arrowBottomStyle
                            sourceComponent: arrowComponent
                        }
                    }
                }
            }
            // right arrow
            Item {
                Layout.fillHeight: true
                visible: decoration == arrowRightTopStyle ||
                         decoration == arrowRightStyle ||
                         decoration == arrowRightBottomStyle
                width: configure.arrowWidth

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    // down pusher
                    Item {
                        Layout.fillHeight: true
                        visible: decoration == arrowRightBottomStyle ||
                                 decoration == arrowRightStyle
                    }
                    Item {
                        width: configure.arrowWidth
                        height: configure.arrowRectHeight
                        Loader {
                            anchors.centerIn: parent
                            width: configure.arrowWidth
                            height: configure.arrowHeight
                            property int direction: arrowRightStyle
                            sourceComponent: arrowComponent
                        }
                    }
                    // down up
                    Item {
                        Layout.fillHeight: true
                        visible: decoration == arrowRightTopStyle ||
                                 decoration == arrowRightStyle
                    }
                }
            }
        }
    }
}
