import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "Common.js" as Common

TabView {
    id: tabWidget
    tabsVisible: count > 0

    // show or not close button
    property bool closable: true
    // tab background images
    property url tabBackground: "images/tabview_tab.png"
    property url tabActiveBackground: "images/tabview_tab_active.png"
    property int tabBackgroundBorderLeft: 10
    property int tabBackgroundBorderRight: 10
    // tab icon
    property bool tabIconUpdated: false
    property url tabIcon: ""

    // for private use
    // left/right navigation arrows
    property int _scrollControlWidth: 20
    // title text
    property int _textLeftMargin: 5
    // close icon
    property int _iconCloseMargin: 15
    property int _iconCloseRightMargin: 0
    property int _iconCloseWidth: 10  // 0 - calc. using tab button title width
    property int _iconCloseHeight: 10 // 0 - calc. using tabBackground height
    // tab icon
    property int _iconTabLeftMargin: 7
    property int _iconTabMargin: 9
    property int _iconTabWidth: 16  // 0 - calc. using tab button title width
    property int _iconTabHeight: 16 // 0 - calc. using tabBackground height
    // tab list of tree view
    property var _tabRow
    property real _tabsWidth: _tabRow ? _tabRow.contentWidth : 0
    property bool _allTabsVisible: width > _tabsWidth
    property bool _leftScrollEnabled: leftScrollEnabled()
    property bool _rightScrollEnabled: rightScrollEnabled()

    // avoiding binding
    Component.onCompleted: _tabRow = Common.findChild(tabWidget, "tabrow")

    // separate functions so that properties change event also triggers them
    function leftScrollEnabled()
    {
        if (!_tabRow)
            return false;
        if (_tabRow.atXBeginning)
            return false;
        return !_allTabsVisible;
    }
    function rightScrollEnabled()
    {
        if (!_tabRow)
            return false;
        if (_tabRow.atXEnd)
            return false;
        return !_allTabsVisible;
    }

    style: TabViewStyle {
        tabOverlap: 0
        frameOverlap: 0
        tabsMovable: true

        frame: Rectangle {
            color: "#ffffff"
        }

        tabBar : Rectangle {
            color: "#ffffff" //"#e7e7e7"
        }

        leftCorner : Rectangle {
            id: leftScroll
            implicitWidth: tabWidget._scrollControlWidth
            implicitHeight: 30

            function leftArrowIcon()
            {
                if (tabWidget._leftScrollEnabled) {
                    if (leftScrollMouseArea.containsMouse)
                        return "images/tab_left_arrow_hover.png";
                    else
                        return "images/tab_left_arrow.png";
                } else {
                    return "images/tab_left_arrow_disabled.png";
                }
            }

            Image {
                id: leftArrowImage
                anchors.fill: parent
                source: leftArrowIcon()

                MouseArea {
                    id: leftScrollMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        var scrollEnabled = tabWidget._leftScrollEnabled;
                        console.log("tab left scroll control (" +
                                    scrollEnabled + ") clicked...");
                        if (!scrollEnabled)
                            return;

                        if (!tabWidget._tabRow)
                            return;
                        if (tabWidget._tabRow.contentX <= 0)
                            return;

                        var delta = 0;
                        var w = 0;
                        var i = 0;
                        while (i < tabWidget.count) {
                            var tab = tabWidget.getTab(i);
                            delta = Common.propertyValue(tab, "tabButtonWidth",
                                                         tab.width);
                            w += delta
                            if (w === tabWidget._tabRow.contentX) {
                                break;
                            } else if (w > tabWidget._tabRow.contentX) {
                                var m = w - tabWidget._tabRow.contentX;
                                if (m / delta > 0.5 && i > 0) {
                                    tab = tabWidget.getTab(i - 1);
                                    delta = (delta - m) +
                                            Common.propertyValue(
                                                tab, "tabButtonWidth",
                                                tab.width);
                                } else {
                                    delta = delta - m;
                                }
                                break;
                            }
                            i++;
                        }
                        if (i == tabWidget.count)
                            delta = 100;
                        delta = Math.min(delta, tabWidget._tabRow.contentX);
                        console.log("tab left scroll by " + delta);
                        var tmp = tabWidget._tabRow.flickDeceleration;
                        tabWidget._tabRow.flickDeceleration = 0;
                        tabWidget._tabRow.contentX -= delta;
                        tabWidget._tabRow.flickDeceleration = tmp;
                    }
                }
            }
        }

        rightCorner : Rectangle {
            id: rightScroll
            implicitWidth: tabWidget._scrollControlWidth
            implicitHeight: 30

            function rightArrowIcon()
            {
                if (tabWidget._rightScrollEnabled) {
                    if (rightScrollMouseArea.containsMouse)
                        return "images/tab_right_arrow_hover.png";
                    else
                        return "images/tab_right_arrow.png";
                } else {
                    return "images/tab_right_arrow_disabled.png";
                }
            }

            Image {
                id: rightArrowImage
                anchors.fill: parent
                source: rightArrowIcon()

                MouseArea {
                    id: rightScrollMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        var scrollEnabled = tabWidget._rightScrollEnabled;
                        console.log("tab right scroll control (" +
                                    scrollEnabled + ") clicked...");
                        if (!scrollEnabled)
                            return;

                        if (!tabWidget._tabRow)
                            return;
                        if (tabWidget._tabRow.contentX >=
                                tabWidget._tabRow.contentWidth)
                            return;

                        var leftTabsWidth =
                                tabWidget._tabRow.contentX + tabWidget.width -
                                tabWidget._scrollControlWidth * 2;
                        var delta = 0;
                        var w = 0;
                        var i = 0;
                        while (i < tabWidget.count) {
                            var tab = tabWidget.getTab(i);
                            delta = Common.propertyValue(tab, "tabButtonWidth",
                                                         tab.width);
                            w += delta
                            if (w > leftTabsWidth) {
                                var m = w - leftTabsWidth;
                                if (m / delta < 0.5 &&
                                        i < tabWidget.count - 1) {
                                    tab = tabWidget.getTab(i + 1);
                                    delta = m + Common.propertyValue(
                                                tab, "tabButtonWidth",
                                                tab.width);
                                } else {
                                    delta = m;
                                }
                                break;
                            }
                            i++;
                        }
                        if (i == tabWidget.count)
                            delta = 100;
                        delta = Math.min(delta, tabWidget._tabRow.contentWidth -
                                         leftTabsWidth);

                        console.log("tab left scroll by " + delta);
                        var tmp = tabWidget._tabRow.flickDeceleration;
                        tabWidget._tabRow.flickDeceleration = 0;
                        tabWidget._tabRow.contentX += delta;
                        tabWidget._tabRow.flickDeceleration = tmp;
                    }
                }
            }
        }

        tab: Item {
            clip: true
            implicitHeight: tabBgImage.sourceSize.height
            implicitWidth: getTabButtonWidth(styleData.title)

            BorderImage {
                id: tabBgImage
                anchors.fill: parent
                source: styleData.selected ? tabWidget.tabActiveBackground :
                                             tabWidget.tabBackground
                smooth: false
                border.left: tabWidget.tabBackgroundBorderLeft
                border.right: tabWidget.tabBackgroundBorderRight
            }

            function tabIcon()
            {
                if (tabWidget.tabIconUpdated)
                    console.log("tab icon update...");

                return Common.propertyValue(tabWidget.getTab(styleData.index),
                                            "tabButtonIcon", tabWidget.tabIcon);
            }

            Image {
                id: tabImage
                source: tabIcon()
                visible: source !== ""
                width: tabIconWidth()
                height: tabIconHeight()
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: tabIconLeftMargin()
            }

            Text {
                text: styleData.title
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: tabImage.right
                anchors.leftMargin: tabWidget._textLeftMargin
            }

            function closeIcon()
            {
                if (closeMouseArea.containsMouse)
                    return "images/tab_close_hover.png";
                else
                    return "images/tab_close.png";
            }

            Image {
                id: closeImage
                source: closeIcon()
                visible: Common.propertyValue(tabWidget.getTab(styleData.index),
                                              "closable", tabWidget.closable)
                width: closeImgWidth()
                height: closeImgHeight()
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: closeImgRightMargin()

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: tabWidget.removeTab(styleData.index)
                }
            }

            Component.onCompleted: {
                // create tab property dynamically to get tab button width
                // when scrolling tab list with left and right arrows
                var obj = Object.defineProperty(
                            tabWidget.getTab(styleData.index), 'tabButtonWidth',
                            {enumerable: false,
                             configurable: false,
                             writable: false,
                             value: getTabButtonWidth(styleData.title)});
            }

            function closeImgWidth()
            {
                return tabWidget._iconCloseWidth ? tabWidget._iconCloseWidth
                  : (tabBgImage.sourceSize.height - tabWidget._iconCloseMargin);
            }
            function closeImgHeight()
            {
                return tabWidget._iconCloseHeight ? tabWidget._iconCloseHeight
                  : (tabBgImage.sourceSize.height - tabWidget._iconCloseMargin);
            }
            function closeImgRightMargin()
            {
                return tabWidget._iconCloseRightMargin ?
                            tabWidget._iconCloseRightMargin :
                            tabWidget.tabBackgroundBorderRight;
            }

            function tabIconWidth()
            {
                if (tabIcon() === "")
                    return 0;

                return tabWidget._iconTabWidth ? tabWidget._iconTabWidth
                  : (tabBgImage.sourceSize.height - tabWidget._iconTabMargin);
            }
            function tabIconHeight()
            {
                return tabWidget._iconTabHeight ? tabWidget._iconTabHeight
                  : (tabBgImage.sourceSize.height - tabWidget._iconTabMargin);
            }
            function tabIconLeftMargin()
            {
                return tabWidget._iconTabLefttMargin ?
                            tabWidget._iconTabLefttMargin :
                            tabWidget.tabBackgroundBorderLeft;
            }

            function getTabButtonWidth(text)
            {
                var t = Qt.createQmlObject(
                           'import QtQuick 2.0; Text {visible: false; text: "' +
                           text + '"}', tabWidget, "dynamicSnippet1");
                return tabWidget.tabBackgroundBorderLeft + tabIconLeftMargin() +
                        tabIconWidth() + tabWidget._textLeftMargin + t.width +
                        closeImgWidth() + closeImgRightMargin();
            }
        }
    }
}
