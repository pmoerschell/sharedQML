import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {

    // The StandardButton enum is received as a null value over the connection.
    signal dialogButtonClicked(int button)

    function show(icon, message)
    {
        dialog.text = message;
        switch (icon) {
        case 1:
            dialog.title = qsTr("Question");
            dialog.icon = StandardIcon.Question;
            dialog.standardButtons = StandardButton.Yes |
                    StandardButton.No | StandardButton.Cancel;
            break;
        case 2:
            dialog.title = qsTr("Information");
            dialog.icon = StandardIcon.Information;
            dialog.standardButtons = StandardButton.Ok;
            break;
        case 3:
            dialog.title = qsTr("Warning");
            dialog.icon = StandardIcon.Warning;
            dialog.standardButtons = StandardButton.Ok;
            break;
        case 4:
            dialog.title = qsTr("Error");
            dialog.icon = StandardIcon.Critical;
            dialog.standardButtons = StandardButton.Ok;
            break;
        case 0:
        default:
            dialog.title = qsTr("Message");
            dialog.icon = StandardIcon.NoIcon;
            dialog.standardButtons = StandardButton.Ok;
            break;
        }
        dialog.visible = true;
    }

    MessageDialog {
        id: dialog
        modality: Qt.ApplicationModal

        onAccepted: {
            console.log("Message dialog: onAccepted'" + text + "' closed.")
        }
        onYes: {
            dialogButtonClicked(clickedButton)
        }
        onNo: {
            dialogButtonClicked(clickedButton)
        }
        onDiscard: {
            dialogButtonClicked(clickedButton)
        }
    }
}
