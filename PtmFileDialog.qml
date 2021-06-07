import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

FileDialog {

    property int fileType: -1
    property url startFolder

    signal closed()
    signal selected(int fileType, url fileUrl)

    onRejected: closed()
    onAccepted: {
        selected(fileType, fileUrl);
        closed();
    }

    Component.onCompleted: visible = true
    // ATTN: setting folder directly with Loader.setSource does not work
    onVisibleChanged: if (visible) folder = startFolder
}
