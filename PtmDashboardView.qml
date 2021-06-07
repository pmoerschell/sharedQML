import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: root

    readonly property alias elements: repeater.model
    // margin around dashboard component
    readonly property int outerMargin: 3
    // orientation of dashboard panel
    property bool horizontalOrientation: true
    // default dashboard element height in vertical orientation, if not set
    property int preferredHeight: 46
    // default dashboard element width in horizontal orientation, if not set
    property int preferredWidth: 160
    // default spacing between elements
    property int preferredSpacing: 3
    // default text color
    property string preferredTextColor: "white"
    // default background color
    property string preferredBackgroundColor: "black"
    // font family
    property string fontFamily: "Lato-Bold"
    // bold font style of title
    property bool boldTitle: true
    // title line font size
    property int titleFontSize: 10
    // value line font size
    property int valueFontSize: 10
    // dashboard elements
    property var modelElements: [
        {
            title: "ITEM 1",
            value: "1000.78",
            width: 160,
            height: 46,
            textColor: "white",
            bgColor: "black",
            icon: "images/check_icon_white.svg"
        },
        {
            title: "ITEM 2",
            value: "finished",
            width: 160,
            height: 46,
            textColor: "red",
            bgColor: "black",
            icon: "images/check_icon_white.svg"
        }
    ]

    function update()
    {
        elements.clear();
        modelElements.forEach(function(element) {
            elements.append(element);
        });
        height = calcHeight();
        width = calcWidth();
    }

    GridLayout {
        anchors.fill: parent
        flow: horizontalOrientation ? GridLayout.LeftToRight
                                    : GridLayout.TopToBottom
        rows: horizontalOrientation ? 1 : elements.count
        columns: horizontalOrientation ? elements.count : 1
        rowSpacing: horizontalOrientation ? preferredSpacing : 0
        columnSpacing: horizontalOrientation ? 0 : preferredSpacing

        Repeater {
            id: repeater
            model: ListModel {}
            Component.onCompleted: {
                update();
            }

            Rectangle {
                Layout.fillWidth: horizontalOrientation
                Layout.fillHeight: !horizontalOrientation
                Layout.margins: outerMargin
                color: model.bgColor ? model.bgColor : preferredBackgroundColor
                width: model.width ? model.width : preferredWidth
                height: model.height ? model.height : preferredHeight

                Column {
                    anchors.fill: parent
                    Layout.margins: 3
                    spacing: 2

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Layout.fillWidth: true
                        height: parent.height / 2
                        spacing: model.icon ? 5 : 0

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                            source: model.icon ? model.icon : ""
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.title
                            color: model.textColor ? model.textColor
                                                   : preferredBackgroundColor
                            font {
                                family: fontFamily
                                pointSize: titleFontSize
                                bold: boldTitle
                            }
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.value
                        color: model.textColor ? model.textColor
                                               : preferredBackgroundColor
                        font {
                            family: fontFamily
                            pointSize: valueFontSize
                        }
                    }
                }
            }
        }
    }

    function calcHeight()
    {
        if (horizontalOrientation)
            return (root.height === 0 ? preferredHeight + outerMargin * 2
                                      : root.height);

        var h = 0;
        for (var i = 0; i < modelElements.length; i++) {
            h += (modelElements[i].height ? modelElements[i].height
                                          : root.preferredHeight);
        }
        if (modelElements.length > 1) {
            h += preferredSpacing * (modelElements.length - 1);
        }
        return h;
    }

    function calcWidth()
    {
        if (!horizontalOrientation)
            return (root.width === 0 ? preferredWidth + outerMargin * 2
                                     : root.width);

        var w = 0;
        for (var i = 0; i < modelElements.length; i++) {
            w += (modelElements[i].width ? modelElements[i].width
                                         : root.preferredWidth);
        }
        if (modelElements.length > 1) {
            w += preferredSpacing * (modelElements.length - 1);
        }
        return w;
    }
}
