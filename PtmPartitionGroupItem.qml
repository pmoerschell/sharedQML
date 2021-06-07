import Cadence.Prototyping.Extensions 1.0
import QtQuick 2.0

PtmPartitionGroupItem {
    id: partgroupv1
    width: 100
    height: 30
    z: mouseArea.drag.active ||  mouseArea.pressed ? 2 : 1
    Drag.active: mouseArea.drag.active

    property point beginDrag
    property bool caught: false

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: parent
        onPressed: {
            partgroupv1.beginDrag = Qt.point(partgroupv1.x, partgroupv1.y);
        }
        onReleased: {
            if (!partgroupv1.caught) {
                backAnimX.from = partgroupv1.x;
                backAnimX.to = beginDrag.x;
                backAnimY.from = partgroupv1.y;
                backAnimY.to = beginDrag.y;
                backAnim.start()
            }
        }
    }

    ParallelAnimation {
        id: backAnim

        SpringAnimation {
            id: backAnimX;
            target: partgroupv1;
            property: "x";
            duration: 500;
            spring: 2;
            damping: 0.2
        }

        SpringAnimation {
            id: backAnimY;
            target: partgroupv1;
            property: "y";
            duration: 500;
            spring: 2;
            damping: 0.2
        }
    }

    Component.onCompleted:
    {
        //console.log("PG created " );
    }
}
