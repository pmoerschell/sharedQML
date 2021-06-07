import QtQuick 2.9
import QtQuick.Controls 1.4
import Cadence.Prototyping.Extensions 1.0

FocusScope {
    id: root

    signal editingFinished()
    signal loadFinished(bool result);
    signal saveFinished(bool result);

    property alias textFormat: textArea.textFormat
    property alias readOnly: textArea.readOnly
    property alias font: textArea.font

    function openFile(furl)
    {
        document.loadFile(furl);
    }

    function loadText(text)
    {
        document.loadText(text);
    }

    DocumentHandler {
        id: document
        //document: textArea.textDocument
        //cursorPosition: textArea.cursorPosition
        selectionStart: textArea.selectionStart
        selectionEnd: textArea.selectionEnd
        onLoaded: {
            root.loadFinished(text.length > 0);
            textArea.setText(text)
        }
    }

    PtmLargeTextArea {
        id: textArea
        anchors.fill: parent
        anchors.margins: 1
        wordWrap: PtmLargeTextArea.WrapAnywhere
        cursorVisible: true
        readOnly: true
        focus: true
        font: Qt.font({
            family: "Lato-Regular",
            pointSize: 10
        })
        // needed to grab focus on user mouse events
        PtmGrabFocusMouseArea { anchors.fill: parent }
    }
}
