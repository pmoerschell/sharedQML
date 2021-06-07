import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQml.Models 2.3
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root
    property alias treeview: rppView
    property alias hasSelection: rppviewsel.hasSelection
    property alias model: rppView.model

    signal itemMouseRightClick(var index)

    Keys.onPressed: {
        if ((event.key === Qt.Key_Space) &&
                (event.modifiers & Qt.ControlModifier))
            itemMouseRightClick(rppView.currentIndex);
    }

    TreeView {
        id: rppView
        anchors.fill: parent
        frameVisible: true
        alternatingRowColors: false
        backgroundVisible: false
        clip: true
        style: PtmTreeViewStyle {}

//      onActivated: {
//          var x = fullNameByIndex(index);
//          if (x.length > 0) activatedItemFullName(x)
//      }

        selection: ItemSelectionModel {
            id: rppviewsel
            model: rppView.model
        }
        selectionMode: SelectionMode.ExtendedSelection

        TableViewColumn {
            title: qsTr("Job")
            role: "decorationName"
            width: rppView.width * 0.28

            delegate: Item {
                property string label: styleData.value === undefined ||
                                     styleData.value.indexOf(";") === -1 ?
                                     styleData.value : styleData.value.split(";")[0]

                Row {
                    spacing: 3

                    Image {
                        id: nameImg
                        anchors.verticalCenter: parent.verticalCenter
                        source: styleData.value === undefined ||
                                styleData.value.indexOf(";") === -1 ?
                                    "" : styleData.value.split(";")[1]
                    }
                    Text {
                        text: label
                        color: rppView.model.flags(styleData.index) & Qt.ItemIsEnabled ?
                                   (styleData.selected  ? "white" : "black") : "gray"
                        font {
                            family: 'Lato-Regular'
                            pixelSize: 12
                        }
                    }
                }
            }
        }

        TableViewColumn {
            title: qsTr("Run type")
            role: "pnrJobTypeForCombobox"
            width: rppView.width * 0.15
            delegate: ComboBox {
                property var controlSelected: styleData.selected
                property var arrayvalue: (styleData.value === undefined ) ?
                                             [0,0] : styleData.value
                property var controlLabels: [
                    qsTrId("No Run"),
                    qsTrId("Standard"),
                    qsTrId("Lite Effort"),
                    qsTrId("High Effort")
                ]
                property var myflag: rppView.model.flags(styleData.index)
                model: controlLabels
                currentIndex: (arrayvalue[0] === undefined ? 0 : arrayvalue[0])
                onActivated: root.model.setData(styleData.index, index)
                enabled: (!arrayvalue[1]) & ((myflag & Qt.ItemIsEnabled) > 0 )
                style: ComboBoxStyle {
                    background: Rectangle {
                        color: (controlSelected && rppView.activeFocus) ?
                                   "steelblue" : (controlSelected) ?
                                       "darkgray" : "transparent";
                        Image {
                            visible: control.enabled
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.margins: 2
                            source: control.pressed ?
                                "images/combobox_arrow_down_white.svg" :
                                        controlSelected ?
                                       "images/combobox_arrow_right_white.svg" :
                                       "images/combobox_arrow_right_black.svg"
                        }
                    }
                    font {
                        family: 'Lato-Regular'
                        pixelSize: 12
                    }
                    label: Text {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        text: (arrayvalue[0] === undefined ? controlLabels[0] : controlLabels[arrayvalue[0]])
                        color: myflag & Qt.ItemIsEnabled ?
                                   (controlSelected ? "white" : "black") : "gray"
                    }
                }
            }
        }

        TableViewColumn {
            title: qsTr("Job ID")
            role: "pnrJobId"
            width: rppView.width * 0.10
            delegate: Item {
                Text {
                    text: styleData.value
                    color: rppView.model.flags(styleData.index) & Qt.ItemIsEnabled ?
                               (styleData.selected  ? "white" : "black") : "gray"
                    font {
                        family: 'Lato-Regular'
                        pixelSize: 12
                    }
                }
            }
        }

        TableViewColumn {
            title: qsTr("Status")
            role: "pnrJobStatus"
            width: rppView.width * 0.15
            delegate: Item {
                Text {
                    text: styleData.value
                    color: rppView.model.flags(styleData.index) & Qt.ItemIsEnabled ?
                               (styleData.selected  ? "white" : "black") : "gray"
                    font {
                        family: 'Lato-Regular'
                        pixelSize: 12
                    }
                }
            }
        }

        TableViewColumn {
            title: qsTr("Launch")
            role: "pnrJobLaunchTime"
            width: rppView.width * 0.10
            delegate: Item {
                Text {
                    text: styleData.value === undefined ? "" : styleData.value
                    color: rppView.model.flags(styleData.index) & Qt.ItemIsEnabled ?
                               (styleData.selected  ? "white" : "black") : "gray"
                    font {
                        family: 'Lato-Regular'
                        pixelSize: 12
                    }
                }
            }
        }

        TableViewColumn {
            title: qsTr("Start")
            role: "pnrJobStartTime"
            width: rppView.width * 0.10
            delegate: Item {
                Text {
                    text: styleData.value === undefined ? "" : styleData.value
                    color: rppView.model.flags(styleData.index) & Qt.ItemIsEnabled ?
                               (styleData.selected  ? "white" : "black") : "gray"
                    font {
                        family: 'Lato-Regular'
                        pixelSize: 12
                    }
                }
            }
        }

        TableViewColumn {
            title: qsTr("Finish")
            role: "pnrJobFinishTime"
            width: rppView.width * 0.10
            delegate: Item {
                Text {
                    text: styleData.value === undefined ? "" : styleData.value
                    color: rppView.model.flags(styleData.index) & Qt.ItemIsEnabled ?
                               (styleData.selected  ? "white" : "black") : "gray"
                    font {
                        family: 'Lato-Regular'
                        pixelSize: 12
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                var index = parent.indexAt(mouse.x, mouse.y)
                if (index.valid) {
                    itemMouseRightClick(index)
                }
            }
        }

        Keys.onEscapePressed: {
            rppView.selection.clear();
            event.accepted = true;
        }
    }
}
