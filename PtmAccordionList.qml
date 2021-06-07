import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Item {
    id: container

    // Default width
    width: 360
    // Default height
    height: 640
    // Subitem expansion duration
    property int animationDuration: 100
    // Subitem indentation
    property int indent: 20
    // Scrollbar width
    property int scrollBarWidth: 8
    // Background for list item
    property string bgImage: 'images/accordion_list_item.png'
    // Background image for pressed list item
    property string bgImagePressed: 'images/accordion_list_item_pressed.png'
    // Background image for active list item (currently not used)
    property string bgImageActive: 'images/accordion_list_item_active.png'
    // Background image for subitem
    property string bgImageSubItem: "images/accordion_list_subitem.png"
    // Arrow indicator for item expansion
    property string arrow: 'images/accordion_arrow.png'
    // Font properties for top level items
    property string headerItemFontName: "Lato-Bold"
    property int headerItemFontSize: 10
    property color headerItemFontColor: "black"
    // Font properties for  subitems
    property string subItemFontName: "Lato-Regular"
    property int subItemFontSize: 10
    property color subItemFontColor: "black"

    signal itemClicked(string itemTitle, string subItemTitle)

    property alias model: listView.model
    property string mimeType: "text/plain"

    ListView {
        id: listView
        height: parent.height
        anchors {
            left: parent.left
            right: parent.right
        }
        delegate: listViewDelegate
        focus: true
        spacing: 0
    }

    Component {
        id: listViewDelegate

        Item {
            id: delegate
            property int itemHeight: 24
            property alias expandedItemCount: subItemRepeater.count
            // Flag to indicate if this delegate is expanded
            property bool expanded: false

            x: 0; y: 0;
            width: container.width
            height: headerItemRect.height + subItemsRect.height

            // Top level list item.
            PtmAccordionListItem {
                id: headerItemRect
                x: 0; y: 0
                width: parent.width
                height: parent.itemHeight
                text: itemTitle
                textIndent: headerIcon.width + 8
                onClicked: expanded = !expanded

                bgImage: container.bgImage
                bgImagePressed: container.bgImagePressed
                bgImageActive: container.bgImageActive
                fontName: container.headerItemFontName
                fontSize: container.headerItemFontSize
                fontColor: container.headerItemFontColor
                //fontBold: true

                // Header image.
                Image {
                    id: headerIcon
                    source: iconSource
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                    }
                }

                // Arrow image indicating the state of expansion.
                Image {
                    id: arrow
                    fillMode: "PreserveAspectFit"
                    height: parent.height * 0.3
                    source: container.arrow
                    rotation: expanded ? 90 : 0
                    smooth: true
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 10
                    }
                }
            }

            // Subitems are in a column whose height depends
            // on the expanded status. When not expandend, it is zero.
            Item {
                id: subItemsRect
                property int itemHeight: delegate.itemHeight

                y: headerItemRect.height
                width: parent.width
                height: expanded ? expandedItemCount * itemHeight : 0
                clip: true
                opacity: 1

                Behavior on height {
                    // Animate subitem expansion. After the final height is
                    // reached, ensure that it is visible to the user.
                    SequentialAnimation {
                        NumberAnimation {
                            duration: container.animationDuration;
                            easing.type: Easing.InOutQuad
                        }
                        ScriptAction {
                            script: listView.positionViewAtIndex(
                                        index, ListView.Contain)
                        }
                    }
                }

                Column {
                    width: parent.width

                    // uses attributes from the model.
                    Repeater {
                        id: subItemRepeater
                        model: attributes
                        width: subItemsRect.width

                        PtmAccordionListItem {
                            id: subListItem
                            width: delegate.width
                            height: subItemsRect.itemHeight
                            text: subItemTitle
                            textIndent: container.indent + itemIcon.width + 8
                            userData: itemType + ";" + subItemType + ";" +
                                      subItemData + ";" + subItemPtmType

                            bgImage: container.bgImageSubItem
                            fontName: container.subItemFontName
                            fontSize: container.subItemFontSize
                            fontColor: container.subItemFontColor
                            enabled: subItemState ? subItemState === "enabled" :
                                                    true

                            onClicked: {
                                console.log("Clicked: " + itemTitle + "/" +
                                            subItemTitle)
                                itemClicked(itemTitle, subItemTitle)
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "grey"
                                opacity: 0.3
                                visible: !enabled
                            }

                            // item image.
                            Image {
                                id: itemIcon
                                source: iconSource
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: container.indent + 10
                                }
                            }

                            Drag.dragType: Drag.Automatic
                            Drag.supportedActions: Qt.CopyAction
                            Drag.mimeData: JSON.parse(
                                               '{ "' + container.mimeType +
                                               '" : "' + subListItem + '" }')
                            Drag.source: subListItem

                            // INFO: Needed to manually enable drag.
                            // if we rely on mouseArea by updating
                            // mouseArea.drag.target and binding to
                            // mouseArea.drag.active to enable drag
                            // automatically, dragged item gets moved
                            // after drop. To avoid it we need to bypass
                            // updating mouseArea.drag and enable drag in
                            // the item manually. Drag is usually enabled
                            // after mouse press and move event. This is
                            // the reason whe we still need to use
                            // mouseArea to receive those events.
                            readonly property int dragDelay: 3
                            property var pressedPosition: null

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent

                                onPressed: {
                                    parent.pressedPosition = {
                                        "x" : mouse.x,
                                        "y" : mouse.y
                                    };
                                    parent.grabToImage(function(result) {
                                        parent.Drag.imageSource = result.url;
                                    });
                                }
                                onPositionChanged: {
                                    if (parent.Drag.active)
                                        return;

                                    var xDelta = Math.abs(
                                            mouse.x - parent.pressedPosition.x);
                                    var yDelta = Math.abs(
                                            mouse.y - parent.pressedPosition.y);
                                    if (xDelta > parent.dragDelay ||
                                            yDelta > parent.dragDelay) {
                                        parent.Drag.active = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
