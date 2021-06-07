/*******************************************************************************
 * Functions for harwdare unit names and labels
 ******************************************************************************/
function ptmbcConnectorFpga(index, perFpgaCount, fpgas)
{
    if (perFpgaCount === 0 || fpgas.length === 0)
        return "";

    if (index < 0 || index >= fpgas.length * perFpgaCount)
        return "";

    var i = ~~(index / perFpgaCount);
    return fpgas[i];
}

function fpgaFullName(boardName, fpga)
{
    if (fpga === undefined || fpga === "")
        return boardName;

    return boardName + "." + "FPGA_" + fpga;
}

function ptmbcConnectorX1FullName(boardName, index, perFpgaCount, fpgas)
{
    var fpga = ptmbcConnectorFpga(index, perFpgaCount, fpgas);
    return fpgaFullName(boardName, fpga) + ".P" + index % perFpgaCount;
}

function ptmbcConnectorX1Label(index, perFpgaCount, fpgas)
{
    return ptmbcConnectorFpga(index, perFpgaCount, fpgas) + "-P" +
            index % perFpgaCount;
}

function ptmbcConnectorS1FullName(boardName, index, perFpgaCount, fpgas, sections)
{
    var j = ~~(index / perFpgaCount);
    var fpga = ptmbcConnectorFpga(index, perFpgaCount, fpgas);
    return fpgaFullName(boardName, fpga) + ".P" + sections[j] +
            "-" + (index % perFpgaCount + 1);
}

function ptmbcConnectorS1Label(index, perFpgaCount, fpgas, sections)
{
    var j = ~~(index / perFpgaCount);
    return ptmbcConnectorFpga(index, perFpgaCount, fpgas) + ".P" + sections[j] +
            "-" + (index % perFpgaCount + 1);
}

function ptmtcConnectorFullName(boardName, index, names, fpgas)
{
    var fpga = (index < fpgas.length && index >= 0 ? fpgas[index] : "");
    var name = (index < names.length && index >= 0 ? names[index] : "");
    return boardName + ".FPGA_" + fpga + "." + name + "-TC";
}

function ptmtcConnectorLabel(index, name, fpgas)
{
    return name + (fpgas !== undefined && index < fpgas.length && index >= 0 ?
                       " " + fpgas[index] : "");
}

function qsfpSwitchPortFullName(boardName, index)
{
    return boardName + ".Q" + index;
}

function qsfpSwitchPortLabel(index)
{
    return index;
}

function qsfpX1BoardPortNames()
{
    return [
             ["A", "Q0"], ["A", "SQ1"], ["B", "Q1"], ["B", "Q2"], ["B", "SQ0"],
             ["C", "Q1"], ["C", "Q2"], ["C", "SQ0"], ["D", "Q1"], ["D", "SQ0"],
             ["E", "Q1"], ["E", "SQ0"], ["F", "Q0"], ["F", "SQ1"], ["G", "Q0"],
             ["G", "Q1"], ["G", "Q2"]
           ];
}

function qsfpX1BoardPortFullName(boardName, index)
{
    var names = qsfpX1BoardPortNames();
    return qsfpX1BoardPortFullNameByIndex(boardName, index, names);
}

function qsfpX1BoardPortLabel(index)
{
    var names = qsfpX1BoardPortNames();
    return qsfpX1BoardPortLabelByIndex(index, names);
}

function qsfpX1BoardAuxPortNames(group)
{
    var ports = [
                  ["TQ0", "TQ1", "TQ2", "TQ3", "TNQ0", "TNQ1"],
                  ["TQ0", "TQ1", "TQ2", "TQ3", "TFQ0", "TFQ1"]
                ];
    var groups = {
                   "A & B": ["A", "B"],
                   "C & D": ["C", "D"],
                   "E & F": ["F", "E"]
                 };
    var res = [];
    var groupArray = groups[group];
    for (var i = 0; i < groupArray.length; i++) {
        var fpga = groupArray[i];
        var fpgaPorts = ports[i];
        fpgaPorts.forEach(function(item) {
            res.push([fpga, item]);
        });
    }
    return res;
}

function qsfpX1BoardAuxPortFullName(boardName, index, group)
{
    var names = qsfpX1BoardAuxPortNames(group);
    return qsfpX1BoardPortFullNameByIndex(boardName, index, names);
}

function qsfpX1BoardAuxPortLabel(index, group)
{
    var names = qsfpX1BoardAuxPortNames(group);
    return qsfpX1BoardPortLabelByIndex(index, names);
}

function qsfpX1BoardPortFullNameByIndex(boardName, index, names)
{
    if (index < 0 || index >= names.length)
        return "";

    var name = names[index];
    return boardName + ".FPGA_" + name[0] + "." + name[1];
}

function qsfpX1BoardPortLabelByIndex(index, names)
{
    if (index < 0 || index >= names.length)
        return "";

    var name = names[index];
    return name[0] + "-" + name[1];
}

function qsfpS1BoardPortNames()
{
    return [
             [ 1,
               [
                 ["A", "QSFP-A0"], ["A", "QSFP-A1"]
               ]
             ],
             [ 2,
               [
                 ["A", "QSFP-A0"], ["A", "QSFP-A1"],
                 ["B", "QSFP-B0"], ["B", "QSFP-B1"]
               ]
             ],
             [ 4,
               [
                 ["", "JOINT-QSFP"],
                 ["A", "QSFP-A"], ["B", "QSFP-B"],
                 ["D", "QSFP-D"], ["C", "QSFP-C"]
               ]
             ]
           ];
}

function qsfpS1BoardPortFullName(boardName, fpgaCount, index)
{
    var names = null;
    var boardNames = qsfpS1BoardPortNames();
    for (var i = 0; i < boardNames.length; i++) {
        if (boardNames[i][0] === fpgaCount) {
            names = boardNames[i][1];
            break;
        }
    }
    if (!names)
        return "";

    if (index < 0 || index >= names.length)
        return "";

    var name = names[index];
    return boardName + (name[0].length > 0 ? ".FPGA_" + name[0] : "") + "." +
            name[1];
}

function qsfpS1BoardPortLabel(fpgaCount, index)
{
    var names = null;
    var boardNames = qsfpS1BoardPortNames();
    for (var i = 0; i < boardNames.length; i++) {
        if (boardNames[i][0] === fpgaCount) {
            names = boardNames[i][1];
            break;
        }
    }
    if (!names)
        return "";

    if (index < 0 || index >= names.length)
        return "";

    var name = names[index];
    return name[1];
}

function findBoard(index, boards)
{
    // INFO: index 8 is reserved for QSFP switch on X1 system
    if ((index >= 0 && index < boards.length) || index === 8) {
        var i;
        var board;
        if (index === 8) {
            for (i = 0; i < boards.length; i++) {
                board = boards[i];
                // looking for switch board data - see hardware_def.h
                if (board.userData === 10001)
                    return board;
            }
        } else {
            var idx = -1;
            for (i = 0; i < boards.length; i++) {
                board = boards[i];
                // looking for board data - see hardware_def.h
                // need to agjust the index if board array has a switch board
                if (board.userData !== 10001)
                    idx++;
                if (index === idx)
                    return board;
            }
        }
    }
    return null;
}

function boardLabel(index, boards)
{
    var board = findBoard(index, boards);
    if (board)
        return board.displayName;
    return qsTr("empty");
}

function boardFullName(chassisName, index, boards)
{
    var board = findBoard(index, boards);
    if (board)
        return board.fullName;
    return "";
}

function programmingConnectorLabel(symbol, index, pos)
{
    if (symbol === undefined || symbol === "")
        return "";

    var sPos = (typeof pos !== 'undefined' ? "-" + pos : "");
    return "PROG_" + symbol + (index >= 0 ? index : "") + sPos;
}

function programmingConnectorFullName(boardName, symbol, index, pos)
{
    if (symbol === undefined || symbol === "")
        return boardName;

    var sPos = (typeof pos !== 'undefined' ? "-" + pos : "");
    return boardName + "." + "PROG_" + symbol + (index >= 0 ? index : "") + sPos;
}

/*******************************************************************************
 * Functions for drag & drop data of hardware unit
 ******************************************************************************/
function droppedHardwareUnitType(userData)
{
    var data = userData.split(";");
    if (data.length === 0)
        return false;

    return data[0];
}

function isDroppedObjectDaughterCard(type)
{
    return (type === "dcard");
}

function isDroppedObjectIoBoard(type)
{
    return (type === "io");
}

function isDroppedObjectCable(type)
{
    return (type === "cable");
}
