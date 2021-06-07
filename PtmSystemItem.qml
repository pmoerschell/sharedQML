import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "Map.js" as Map
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root

    /*
      Supported types: chassis, board, switch
      */
    signal mouseLeftClicked(string type, string name, string chassis)
    signal mouseDoubleClicked(string type, string name, string chassis)
    signal mouseRightClicked(string type, string name, string chassis)

    // number of rows and columns in the view; 256 * 4 = 1024
    property int preferredRows: 256
    property int preferredColumns: 4
    // spacing between items
    property int preferredSpacing: 20
    // can be either S1 or X1
    property string systemType: ""
    // system chassis
    property var modelElements: [
        {
            label: "chassis0",
            fullname: "chassis0",
            used: true,
            boards: []
        },
        {
            label: "chassis1",
            fullname: "chassis1",
            used: true,
            boards: []
        }
    ]

    function updateUnitStatus(name, enabled, used, userData, connectedItems)
    {
        console.log("System child unit " + name + " status (" + enabled + ":" +
                    used + "), user data: " + userData + " updated");

        var items = Map.keys();
        for (var i = 0; i < items.length; i++) {
            var item = Map.value(items[i]);
            if (item) {
                item.updateUnitStatus(name, enabled, used, userData,
                                      connectedItems);
            }
        }
    }

    function update()
    {
        console.log("Updating system model..");
        // clear current displayed items
        for (var i = gridLayout.children.length; i > 0 ; i--)
            gridLayout.children[i - 1].destroy();
        // add new items to display
        modelElements.forEach(function(element) {
            var c = Qt.createComponent("qrc:///pluginext/Ptm" + systemType +
                                       "ChassisItem.qml");
            var chassisItem = c.createObject(gridLayout,
                                             {
                                                  "label" : element.label,
                                                  "fullName" : element.fullName,
                                                  "boards" : element.boards
                                             });
            chassisItem.visible = true;
            resizer.itemWidth = chassisItem.width;
            resizer.itemHeight = chassisItem.height;
            console.log("chassis item size=(" + resizer.itemWidth + "," +
                        resizer.itemHeight + ")")
            // connect chassis signals
            chassisItem.mouseLeftClicked.connect(function(type, name) {
                mouseLeftClicked(type, name, chassisItem.fullName);
            });
            chassisItem.mouseDoubleClicked.connect(function(type, name) {
                mouseDoubleClicked(type, name, chassisItem.fullName);
            });
            chassisItem.mouseRightClicked.connect(function(type, name) {
                mouseRightClicked(type, name, chassisItem.fullName);
            });
            Map.setValue(chassisItem.fullName, chassisItem);
        });
        height = resizer.calcHeight();
        width = resizer.calcWidth();
    }

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        flow: GridLayout.LeftToRight
        rows: preferredRows > 0 ? preferredRows : 256
        columns: preferredColumns > 0 ? preferredColumns : 4
        rowSpacing: preferredSpacing
        columnSpacing: preferredSpacing
    }

    QtObject {
        id: resizer

        property int itemHeight: 0
        property int itemWidth: 0

        function calcHeight()
        {
            var rows = (modelElements.length <= preferredColumns ?
                            1 : modelElements.length / preferredColumns + 1);
            var h = rows * (itemHeight + preferredSpacing);
            return h;
        }

        function calcWidth()
        {
            var cols = (modelElements.length <= preferredColumns ?
                            modelElements.length : preferredColumns);
            var w = cols * (itemWidth + preferredSpacing);
            return w;
        }
    }

    Component.onCompleted: {
        update();
    }
}
