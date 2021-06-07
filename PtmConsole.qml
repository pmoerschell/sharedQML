import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2 as Quick2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0
import Cadence.Prototyping.Extensions 1.0

FocusScope {
    id: root

    property alias cachedLinesSize: commandLog.cachedLinesSize
    property alias commandLineText: commandInput.text
    property url designPath: ""

    property font consoleFont: Qt.font({
        family: "Lucida Console",
        pointSize: 10
    })

    signal commandPosted(string command)
    signal saveToFile(string fileUrl)
    signal saveScriptToFile(string fileUrl)
    signal executeScriptFile(string fileUrl)
    signal clearLog()
    signal previousFromHistoryRequested
    signal nextFromHistoryRequested
    signal consoleLineRequested(int lineNumber)

    function append(message, msgIndex)
    {
        commandLog.append(message, msgIndex);
    }

    function setText(messageList, startIndex)
    {
        commandLog.setText(messageList, startIndex);
    }

    function clear()
    {
        commandLog.clear()
    }

    Loader { id: fdloader }
    Connections {
        target: fdloader.item
        onClosed: {
            fdloader.source = "";
        }
        onSelected: {
            switch (fileType) {
            case 1:
                saveToFile(fileUrl);
                break;
            case 2:
                saveScriptToFile(fileUrl);
                break;
            case 3:
                executeScriptFile(fileUrl);
                break;
            default:
                break;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: "#f6f6f6"

            PtmSideViewToolBar {
                anchors.fill: parent

                Row {
                    spacing: 2

                    PtmSideViewToolButton { action: saveConsoleLogToFile }
                    PtmSideViewToolButton { action: createCommandScriptAndSaveToFile }
                    PtmSideViewToolButton { action: executeCommandScriptFile }
                    PtmSideViewToolButton { action: clearConsoleWindow }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 1
            color: "white"
            border {
                width: 1
                color: "#b8b5b2"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 0

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: 1

                    PtmConsoleTextArea {
                        id: commandLog
                        width: parent.width
                        height: parent.height
                        textFormat: PtmLargeTextArea.RichText
                        wordWrap: PtmLargeTextArea.WrapAnywhere
                        frameVisible: false
                        cursorVisible: true
                        readOnly: true
                        undoRedoEnabled: false
                        font: consoleFont
                        onRequestConsoleLine: consoleLineRequested(lineNumber)
                        // needed to grab focus on user mouse events
                        PtmGrabFocusMouseArea { anchors.fill: parent }
                    }
                }

                Rectangle {
                    color: "lightgray"
                    Layout.fillWidth: true
                    Layout.rightMargin: 16
                    Layout.leftMargin: 16
                    height: 1
                }

                Item {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 20
                    Layout.maximumHeight: 20

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Image {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            source: "images/console_prompt.png"
                        }

                        TextField {
                            id: commandInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            anchors.verticalCenter: parent.verticalCenter
                            placeholderText: qsTr("Type command to execute")
                            focus: true
                            font: consoleFont
                            style: TextFieldStyle {
                                background: Rectangle {
                                    border.width: 0
                                }
                                padding.bottom: 3
                            }

                            Keys.onReturnPressed: {
                                var cmd = commandInput.text;
                                if (cmd.length === 0)
                                    return;

                                commandInput.text = "";
                                commandPosted(cmd);
                            }
                            Keys.onUpPressed: previousFromHistoryRequested()
                            Keys.onDownPressed: nextFromHistoryRequested()
                            // needed to grab focused on use mouse events
                            PtmGrabFocusMouseArea { anchors.fill: parent }
                        }
                    }
                }
            }
        }
    }
    Action {
        id: saveConsoleLogToFile
        text: qsTr("Save console log to file")
        iconSource: "images/console_save.png"
        onTriggered: {
            fdloader.setSource(
                "qrc:///pluginext/PtmFileDialog.qml",
                {"fileType": 1,
                 "startFolder": designPath,
                 "title": qsTr("Select file to save console log to"),
                 "selectFolder": false,
                 "selectMultiple": false,
                 "selectExisting": false});
        }
    }
    Action {
        id: createCommandScriptAndSaveToFile
        text: qsTr("Create command script and save to file")
        iconSource: "images/console_script_save.png"
        onTriggered: {
            fdloader.setSource(
                "qrc:///pluginext/PtmFileDialog.qml",
                {"fileType": 2,
                 "startFolder": designPath,
                 "title": qsTr("Select file to create command script"),
                 "selectFolder": false,
                 "selectMultiple": false,
                 "selectExisting": false});
        }
    }
    Action {
        id: executeCommandScriptFile
        text: qsTr("Execute command script file")
        iconSource: "images/console_execute_script.png"
        onTriggered: {
            fdloader.setSource(
                        "qrc:///pluginext/PtmFileDialog.qml",
                        {"fileType": 3,
                            "startFolder": designPath,
                            "title": qsTr("Select file to execute"),
                            "selectFolder": false,
                            "selectMultiple": false,
                            "selectExisting": true});
        }
    }
    Action {
        id: clearConsoleWindow
        text: qsTr("Clear console window")
        iconSource: "images/console_clear.png"
        onTriggered: clearLog()
    }
}
