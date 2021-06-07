import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "ModelUtils.js" as ModelUtils

Window {
    width: 1600
    height: 800
    visible: true
    title: qsTr("Improbable Race Console")

    // TODO: instead of using a constant gate length, we could make it variable based on average times for each gate.
    property int gateLength: width / 32
    property int totalGates: trackListModel.count
    property real courseRecord: trackListModel.get(totalGates-1).record
    property real courseAverage: trackListModel.get(totalGates-1).average
    property real finishWarningLimit: 32   // anyone predicted at over 32 hours warning (currently displays progress in red)

    // connection from python Improbable Race Server
    signal raceData(string name, real elapsed, int id, int gate)
    onRaceData: { updateRunners(name, id, gate, elapsed); }
    Component.onCompleted: {
        runnersListModel.clear();
        Receiver.raceData.connect(raceData);
    }

    function updateRunners(name, id, gate, elapsed) {
        // look for the runner's id in the current list
        var index = ModelUtils.indexOfModel(runnersListModel, function(item) {
            return (item.id === id)
        });

        var gateAverage = trackListModel.get(gate-1).average;
        var predictedFinish = (elapsed / gateAverage) * courseAverage;
        // if the id of the runner is not in the List, append it
        if (index === -1) {
            runnersListModel.append({"name": name, "id": id, "gate": gate, "elapsed": elapsed, "predictedFinish": predictedFinish});
        // otherwise, update the runner's info
        } else {
            runnersListModel.get(index).gate = gate;
            runnersListModel.get(index).elapsed = elapsed;
            runnersListModel.get(index).predictedFinish = predictedFinish;
        }
        // sort the list on gate + elapsed
        ModelUtils.listModelSort(runnersListModel, (a, b) => ((b.gate !== a.gate) ? (b.gate - a.gate) : (a.elapsed - b.elapsed)) );
        // Display predicted winner, or winner if crossed the last gate
        predictedWinner.text = (runnersListModel.get(0).gate === totalGates ? "Winner: " : "Predicted Winner: ") + runnersListModel.get(0).name + " (" + runnersListModel.get(0).id + ")"
    }

    // static ListModels
    TrackListModel { id: trackListModel }
    // dynamic ListModels
    ListModel { id: runnersListModel }

    // current status/info
    Rectangle {
        id: status
        anchors.top: parent.top
        width: parent.width
        height: 20
        color: "yellow"
        Row {
            Text { id: predictedWinner; width: 230; color: "black"; }

            Rectangle {
                height: parent.height * .90
                width: height
                anchors.verticalCenter: parent.verticalCenter
                border.color: "black"
                border.width: 1
                color: "green"
            }
            Text { width: 180; color: "black"; text: " On pace to beat course record"; }

            Rectangle {
                height: parent.height * .90
                width: height
                anchors.verticalCenter: parent.verticalCenter
                border.color: "black"
                border.width: 1
                color: "red"
            }
            Text { width: 890; color: "black"; text: " On pace to take more than " + finishWarningLimit + " hours to finish"; }
            Text { width: 100; color: "black"; text: "Course record: " + courseRecord; }
        }
    }

    Rectangle {
        id: titles
        anchors.top: status.bottom
        width: parent.width
        height: 20
        color: "white"
        Row {
            Text { width: 150; text: "Runner"; color: "black"; }
            Text { width: 80; text: "Gate:"; color: "black"; }
            Repeater {
                model: totalGates
                Text { width: gateLength; text: index+1; color: "black"; }
            }

        }
    }

    Component {
        id: runnerDelegate
        Row {
            width: runnersScrollView.width
            height: 15
            Text{ width: 180; text: name + " (" + id + ")"; }
            ProgressBar {
                maximumValue: totalGates * gateLength
                orientation: Qt.Horizontal
                value: gate * gateLength
                style: ProgressBarStyle {
                    background: Rectangle {
                        radius: 2
                        color: "lightgray"
                        border.color: "gray"
                        border.width: 1
                        implicitWidth: totalGates * gateLength
                        implicitHeight: 15
                    }
                    progress: Rectangle {
                        color: predictedFinish > finishWarningLimit ? "red" :
                               predictedFinish < courseRecord       ? "green" : "lightsteelblue"
                        border.color: "steelblue"
                    }
                }
            }
            Text{ width: gateLength;  text: 'Gate: ' + gate; }
            Text{ width: 100; text: 'Elapsed: ' + Math.round(elapsed*100)/100; }
            Text{ width: 100; text: (gate === totalGates ? 'Finish: ' : 'Predicted finish: ') + Math.round(predictedFinish*100)/100; }
        }
    }

    ScrollView {
        id: runnersScrollView
        anchors.top: titles.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        ListView {
            model: runnersListModel
            delegate: runnerDelegate
        }
    }
}
