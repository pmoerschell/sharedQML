import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQml.Models 2.2
import Cadence.Prototyping.Extensions 1.0

Item {
    id: root

    property var currentIndex: null
    property alias model: fsview.model

    signal activatedItemLink(string link, bool isDir)
    signal itemMouseRightClick(var index)

    function linkByIndex(index)
    {
        return root.model.data(index, FileSystemModel.UrlStringRole);
    }

    function setDisplayRoot(r)
    {
        fsview.rootIndex = fsview.model.exSetRootPath(r);
    }

    Keys.onPressed: {
        if ((event.key === Qt.Key_Space) &&
                (event.modifiers & Qt.ControlModifier))
            itemMouseRightClick(fsview.currentIndex);
    }

    ItemSelectionModel {
        id: selectionModel
        model: fileSystemModel
    }

    TreeView {
        id: fsview
        anchors.fill: parent
        anchors.margins: 0
        model: fileSystemModel
        rootIndex: rootPathIndex
        selection: selectionModel
        style: PtmTreeViewStyle {}

        TableViewColumn {
            title: qsTr("Name")
            role: "fileName"
            resizable: true
        }

        TableViewColumn {
            title: qsTr("Size")
            role: "size"
            resizable: true
            horizontalAlignment : Text.AlignRight
            width: 70
        }

        TableViewColumn {
            title: qsTr("Permissions")
            role: "displayableFilePermissions"
            resizable: true
            width: 100
        }

        TableViewColumn {
            title: qsTr("Modified")
            role: "lastModified"
            resizable: true
        }

        onActivated : {
            root.currentIndex = index;
            if (index.valid) {
                var isDir = model.isDir(index);
                if (isDir) {
                    if (fsview.isExpanded(index))
                        fsview.collapse(index);
                    else
                        fsview.expand(index);
                }
                activatedItemLink(linkByIndex(index), isDir);
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                var index = parent.indexAt(mouse.x, mouse.y);
                if (index.valid) {
                    fsview.selection.setCurrentIndex(
                                index, ItemSelectionModel.SelectCurrent);
                    fsview.selection.select(
                                index, ItemSelectionModel.SelectCurrent);
                    root.currentIndex = index;
                    itemMouseRightClick(index);
                }
            }
        }
    }
}
