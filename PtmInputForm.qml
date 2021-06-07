import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2 as Q2
import QtQuick.Controls.Styles 1.4

Item {
    id: root

    signal inputActivated(string name, var value)

    property alias title: titleText.text
    property alias model: repeater.model
    property bool autoHideToolTip: true
    property int columnMinimumWidth: 260
    property int rowHeight: 70
    property int maxColumns: 3
    property int maxRows: 10
    property font titleFont: Qt.font({
        family: "Lato-Regular",
        pointSize: 9
    })
    property font itemFont: Qt.font({
        family: "Lato-Bold",
        bold: true,
        pointSize: 8,
    })
    property font itemDescFont: Qt.font({
        family: "Lato-Regular",
        pointSize: 8
    })

    /*! Model example:

    ListModel {
        ListElement {
            itemTitle: "dumpShadows"
            itemName: "dumpShadows"
            itemDesc: "Checkbox with tooltip"
            itemExtDesc: "Description\nthis is second line\nthis is third line"
            itemDefaultValue: "false"
            itemGuiType: "checkbox"
            itemType: "bool"
            itemNameHintEnabled: false
            attributes: []
        }
        ListElement {
            itemTitle: "Spin Input 0"
            itemName: "Spin0"
            itemDesc: "Spiner with min value 0 and max value 10, default value 4"
            itemMinValue: "0"
            itemMaxValue: "10"
            itemStepSize: 2
            itemDefaultValue: "4"
            itemGuiType: "spinbox"
            itemType: "int"
            itemNameHintEnabled: true
            attributes: []
        }
        ListElement {
            itemTitle: "Text Input 1"
            itemName: "Text1"
            itemDesc: "Simple text input with default value"
            itemPlaceholderText: ""
            itemDefaultValue: "long text....."
            itemGuiType: "input"
            itemType: "string"
            itemNameHintEnabled: true
            attributes: []
        }
        ListElement {
            itemTitle: "Text Input 2"
            itemName: "Text2"
            itemDesc: "Integer value input with RegExp validator of input and placeholder text"
            itemPlaceholderText: "Enter value"
            itemDefaultValue: ""
            itemGuiType: "input"
            itemType: "int"
            itemRegExp: "[0-9]|[1-9][0-9]|[1-9][0-9][0-9]|1000"
            itemNameHintEnabled: true
            attributes: []
        }
        ListElement {
            itemTitle: "Text Input 3"
            itemName: "tieSourcelessRandom"
            itemDesc: "Hybrid checkbox and text input with placeholder text and default value"
            itemPlaceholderText: "Enter optional seed value"
            itemDefaultValue: "long text....."
            itemGuiType: "input"
            itemType: "string"
            itemToggleable: true
            itemNameHintEnabled: true
            attributes: []
        }
        ListElement {
            itemTitle: "Combobox Input 3"
            itemName: "Combo0"
            itemDesc: "Combo box input"
            itemDefaultValue: "1"
            itemGuiType: "combobox"
            itemType: "string"
            itemNameHintEnabled: true
            attributes:[
                ListElement {
                    text: "F-1"
                    value: "1"
                },
                ListElement {
                    text: "F-2"
                    value: "2"
                }
            ]
        }
        ListElement {
            itemTitle: "Multi-Choice Combobox Input 3"
            itemName: "MultiCombo0"
            itemDesc: "Multi-choice combo box input"
            itemExtDesc: "1<br>2<br>3<br>"
            itemDefaultValue: "1"
            itemGuiType: "multicombobox"
            itemGuiWidth: 160
            itemType: "string"
            itemNameHintEnabled: true
            attributes:[
                ListElement {
                    text: "F-1"
                    value: "1"
                    checked: false
                },
                ListElement {
                    text: "F-2"
                    value: "2"
                    checked: false
                },
                ListElement {
                    text: "F-3"
                    value: "3"
                    checked: false
                },
                ListElement {
                    text: "F-4"
                    value: "4"
                    checked: false
                }
            ]
        }
    }
    */

    /*! Parameter 'func' is a function return a value to display in input
        control. The function accepts input control name as an input parameter.
    */
    function update(func)
    {
        configure.update(func);
    }

    function setEnabled(enabled)
    {
        configure.enabledChanged(enabled);
    }

    QtObject {
        id: configure

        readonly property string defaultValueIcon: "images/button_default_value.png"
        readonly property string defaultValueDisabledIcon: "images/button_default_value_disabled.png"

        signal update(var func)
        signal enabledChanged(bool enabled)

        function dim(value, base, max)
        {
            var n = ~~(value / base);
            var rem = value % base;
            return (n == 0 ? max : (n >= max ? max : (rem > 0 ? n + 1 : n)));
        }

        function cellWidth()
        {
            return Math.max(columnMinimumWidth, (root.childrenRect.width - 25 -
                    (gridLayout.columnSpacing * (gridLayout.columns + 1))) /
                    gridLayout.columns);
        }

        function descLeftMargin()
        {
            return 18;
        }

        function descRightMargin()
        {
            return 5;
        }

        function decoractionByIndex(tooltip, index)
        {
            var idx = index + 1;
            var n = ~~(idx / gridLayout.rows);
            var rem = idx % gridLayout.rows;
            if (n === gridLayout.columns)
                return tooltip.arrowRightTopStyle;
            else if (n === gridLayout.columns - 1 && rem !== 0)
                return tooltip.arrowRightTopStyle;
            else
                return tooltip.arrowLeftTopStyle;
        }

        function regExpByType(type)
        {
            switch (type) {
            case "string":
                return /.*/;
            case "int":
                return /\d*/;
            case "bool":
                return /[01]/;
            }
            return null;
        }

        function parseNumber(value)
        {
            var val;
            if (typeof value !== 'undefined') {
                var v = String(value);
                if (v.length > 0) {
                    if (!isNaN(value))
                        val = Number(value);
                }
            }
            return val;
        }
    }

    Text {
        id: textSingleton
    }

    Component {
        id: checkBoxStyle

        CheckBoxStyle {
            label: Text {
                text: control.text
                color: '#000000'
                font: itemFont
            }
            indicator: Rectangle {
                width: 16
                height: 16
                color: control.checked ? '#425381' : '#ffffff'
                border {
                    color: (control.hovered || control.activeFocus) ?
                               '#2da7df' : '#d0dde8'
                    width: control.checked ?
                               0 : (control.hovered || control.activeFocus) ?
                                   2 : 1
                }
                Image {
                    anchors.centerIn: parent
                    source: "images/checkbox_checked_white.png"
                    visible: control.checked
                }
            }
        }
    }

    Component {
        id: checkboxComponent

        FocusScope {
            id: checkboxScope
            width: controlFrame.width
            height: controlFrame.height

            Rectangle {
                id: controlFrame
                width: configure.cellWidth()
                height: rowHeight
                color: checkboxScope.activeFocus ? '#fafbfc' : '#ffffff'
                border {
                    width: (checkBoxMouseArea.containsMouse || checkboxScope.activeFocus) ?
                               2 : 1
                    color: checkboxScope.activeFocus ?
                               '#2da7df' : checkBoxMouseArea.containsMouse ?
                                   '#dae5ee' : '#edf1f5'
                }

                property bool controlEnabled: checkBox.enabled

                MouseArea {
                    id: checkBoxMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onClicked: checkBox.forceActiveFocus()

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3

                        CheckBox {
                            id: checkBox
                            text: ""
                            style: checkBoxStyle
                            onClicked: {
                                forceActiveFocus()
                                inputActivated(modelData.itemName, checked)
                            }
                            onFocusChanged: {
                                if (focus)
                                    scrollView.ensureVisible(repeater.itemAt(modelIndex));
                            }
                            Connections {
                                target: configure
                                onUpdate: {
                                    var value = func(modelData.itemName);
                                    if (typeof value !== 'undefined') {
                                        checkBox.checked =
                                                Boolean(func(modelData.itemName));
                                    }
                                }
                                onEnabledChanged: {
                                    checkBox.enabled = enabled;
                                    checkBoxDesc.enabled = enabled;
                                }
                            }
                            Component.onCompleted: {
                                // avoiding binding
                                var hintEnabled =
                                  typeof modelData.itemNameHintEnabled === 'boolean'
                                        ? modelData.itemNameHintEnabled : false;
                                text = (typeof modelData.itemTitle !== 'undefined' ?
                                  qsTr(modelData.itemTitle) : "") + (hintEnabled &&
                                  typeof modelData.itemName !== 'undefined' ?
                                  " (" + modelData.itemName + ")" : "");
                                checked = Boolean(modelData.itemDefaultValue);
                            }
                        }
                        Text {
                            id: checkBoxDesc
                            anchors.left: parent.left
                            anchors.leftMargin: configure.descLeftMargin()
                            anchors.rightMargin: configure.descRightMargin()
                            width: parent.width - configure.descRightMargin() -
                                   configure.descLeftMargin()
                            textFormat: Text.StyledText
                            wrapMode: Text.Wrap
                            color: "#384959"
                            Component.onCompleted: {
                                text = typeof modelData.itemDesc !== 'undefined' ?
                                            qsTr(modelData.itemDesc) : "";
                                font = itemDescFont;
                            }
                        }
                    }
                    PtmToolTip {
                        parent: controlFrame
                        visible: enabled && checkBoxMouseArea.containsMouse

                        property bool enabled: true

                        Component.onCompleted: {
                            text = typeof modelData.itemExtDesc !== 'undefined' ?
                                      qsTr(modelData.itemExtDesc) : "";
                            title = (typeof modelData.itemTitle !== 'undefined' ?
                                         qsTr(modelData.itemTitle) : "");
                            enabled = typeof modelData.itemExtDesc !== 'undefined' &&
                                    text.length > 0;
                            decoration = configure.decoractionByIndex(this,
                                                                      modelIndex);
                            if (!autoHideToolTip)
                                timeout = -1;
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    opacity: 0.7
                    visible: !controlFrame.controlEnabled
                }
            }
        }
    }

    Component {
        id: textComponent

        FocusScope {
            id: textScope
            width: controlFrame.width
            height: controlFrame.height

            Rectangle {
                id: controlFrame
                width: configure.cellWidth()
                height: rowHeight
                color: textScope.activeFocus ? '#fafbfc' : '#ffffff'
                border {
                    width: (textFieldMouseArea.containsMouse || textScope.activeFocus) ?
                               2 : 1
                    color: textScope.activeFocus ?
                               '#2da7df' : textFieldMouseArea.containsMouse ?
                                   '#dae5ee' : '#edf1f5'
                }

                property bool controlEnabled: (textFieldCheckBox.visible ?
                                                   textFieldCheckBox.enabled :
                                                   textField.enabled)

                MouseArea {
                    id: textFieldMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onClicked: textField.forceActiveFocus()

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3

                        RowLayout {
                            width: parent.width
                            spacing: 0

                            CheckBox {
                                id: textFieldCheckBox
                                anchors.verticalCenter: parent.verticalCenter
                                style: checkBoxStyle
                                text: ""
                                onClicked: {
                                    forceActiveFocus();
                                    textField.enabled = checked;
                                    var val;
                                    if (checked) {
                                        val = (textField.text.length > 0 ?
                                                   textField.text : true);
                                    }
                                    inputActivated(modelData.itemName, val);
                                }
                                Component.onCompleted: {
                                    visible =
                                      typeof modelData.itemToggleable !== 'undefined'
                                           ? Boolean(modelData.itemToggleable) : false;
                                    if (visible) {
                                        if (typeof modelData.itemDefaultValue !== 'undefined') {
                                            var val = String(modelData.itemDefaultValue);
                                            if (val.length > 0)
                                                checked = true;
                                        }
                                    }
                                }
                            }
                            Text {
                                id: textFieldTitle
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#000000"
                                text: ""
                                Component.onCompleted: {
                                    // avoiding binding
                                    var hintEnabled =
                                      typeof modelData.itemNameHintEnabled === 'boolean'
                                            ? modelData.itemNameHintEnabled : false;
                                    text = (typeof modelData.itemTitle !== 'undefined' ?
                                      qsTr(modelData.itemTitle) : "") + (hintEnabled &&
                                      typeof modelData.itemName !== 'undefined' ?
                                      " (" + modelData.itemName + ")" : "") + ":";
                                    font = itemFont;
                                }
                            }
                            // spacer
                            Item {
                                width: 6
                                height: 1
                            }
                            TextField {
                                id: textField
                                Layout.fillWidth: true
                                enabled: textFieldCheckBox.visible ?
                                             textFieldCheckBox.checked : true
                                validator: RegExpValidator {
                                    Component.onCompleted: {
                                        regExp =
                                          typeof modelData.itemRegExp !== 'undefined' ?
                                             RegExp(modelData.itemRegExp) :
                                             configure.regExpByType(modelData.itemType);
                                    }
                                }

                                property bool hasTextChanged: false

                                onTextChanged: hasTextChanged = true
                                onEditingFinished: inputFinished()
                                onFocusChanged: {
                                    if (focus)
                                        scrollView.ensureVisible(repeater.itemAt(modelIndex));
                                }

                                function inputFinished()
                                {
                                    if (hasTextChanged) {
                                        var val;
                                        if (textFieldCheckBox.visible)
                                            val = (text.length > 0 ? text : true);
                                        else if (text.length > 0)
                                            val = text;
                                        inputActivated(modelData.itemName, val);
                                        hasTextChanged = false;
                                    }
                                }

                                Connections {
                                    target: configure
                                    onUpdate: {
                                        var val = func(modelData.itemName);
                                        if (!val) {
                                            if (typeof modelData.itemDefaultValue !== 'undefined') {
                                                var v = String(modelData.itemDefaultValue);
                                                if (v.length > 0)
                                                    val = v;
                                            }
                                        }
                                        if (textFieldCheckBox.visible) {
                                            textFieldCheckBox.checked =
                                                    (typeof val !== 'undefined');
                                        }
                                        if (typeof val === 'undefined')
                                            val = "";
                                        else if (typeof val === 'boolean')
                                            val = "";
                                        else
                                            val = String(val);
                                        textField.text = val;
                                    }
                                    onEnabledChanged: {
                                        textFieldCheckBox.enabled = enabled;
                                        var val = (textFieldCheckBox.visible ?
                                                       textFieldCheckBox.checked &&
                                                       textFieldCheckBox.enabled :
                                                       enabled);
                                        textFieldTitle.enabled = val;
                                        textField.enabled = val;
                                        textFieldDesc.enabled = val;
                                    }
                                }
                                Component.onCompleted: {
                                    text =
                                      typeof modelData.itemDefaultValue !== 'undefined'
                                            ? modelData.itemDefaultValue : "";
                                    placeholderText =
                                      typeof modelData.itemPlaceholderText !== 'undefined'
                                            ? qsTr(modelData.itemPlaceholderText) : "";
                                    if (typeof modelData.itemGuiWidth !== 'undefined') {
                                        if (modelData.itemGuiWidth > 0)
                                            width = modelData.itemGuiWidth;
                                    }
                                }
                            }
                            // spacer
                            Item {
                                width: 2
                                height: 1
                            }
                            PtmTextButton {
                                minimumWidth: textField.implicitHeight
                                minimumHeight: textField.implicitHeight
                                horizontalMargin: verticalMargin
                                iconSource: enabled ? configure.defaultValueIcon :
                                                      configure.defaultValueDisabledIcon
                                enabled: textField.enabled
                                onClicked: {
                                    forceActiveFocus();
                                    textField.text =
                                        typeof modelData.itemDefaultValue !== 'undefined'
                                            ? modelData.itemDefaultValue : "";
                                    // need to force the event because TextField
                                    // does not emit editingFinished in such case
                                    textField.inputFinished();
                                }
                                Component.onCompleted: {
                                    visible =
                                       typeof modelData.itemDefaultValue !== 'undefined';
                                }
                            }
                        }
                        Text {
                            id: textFieldDesc
                            anchors.left: parent.left
                            anchors.leftMargin: configure.descLeftMargin()
                            anchors.rightMargin: configure.descRightMargin()
                            width: parent.width - configure.descRightMargin() -
                                   configure.descLeftMargin()
                            textFormat: Text.StyledText
                            wrapMode: Text.Wrap
                            color: "#384959"
                            Component.onCompleted: {
                                text = typeof modelData.itemDesc !== 'undefined' ?
                                            qsTr(modelData.itemDesc) : "";
                                font = itemDescFont;
                            }
                        }
                    }
                    PtmToolTip {
                        parent: controlFrame
                        visible: enabled && textFieldMouseArea.containsMouse

                        property bool enabled: true

                        Component.onCompleted: {
                            text = typeof modelData.itemExtDesc !== 'undefined' ?
                                      qsTr(modelData.itemExtDesc) : "";
                            title = (typeof modelData.itemTitle !== 'undefined' ?
                                         qsTr(modelData.itemTitle) : "");
                            enabled = typeof modelData.itemExtDesc !== 'undefined' &&
                                    text.length > 0;
                            decoration = configure.decoractionByIndex(this,
                                                                      modelIndex);
                            if (!autoHideToolTip)
                                timeout = -1;
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    opacity: 0.7
                    visible: !controlFrame.controlEnabled
                }
            }
        }
    }

    Component {
        id: comboboxComponent

        FocusScope {
            id: comboboxScope
            width: controlFrame.width
            height: controlFrame.height

            Rectangle {
                id: controlFrame
                width: configure.cellWidth()
                height: rowHeight
                color: comboboxScope.activeFocus ? '#fafbfc' : '#ffffff'
                border {
                    width: (comboBoxMouseArea.containsMouse || comboboxScope.activeFocus) ?
                               2 : 1
                    color: comboboxScope.activeFocus ?
                               '#2da7df' : comboBoxMouseArea.containsMouse ?
                                   '#dae5ee' : '#edf1f5'
                }

                property bool controlEnabled: (comboBoxCheckBox.visible ?
                                                   comboBoxCheckBox.enabled :
                                                   comboBox.enabled)
                MouseArea {
                    id: comboBoxMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onClicked: comboBox.forceActiveFocus()

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3

                        RowLayout {
                            width: parent.width
                            spacing: 0

                            CheckBox {
                                id: comboBoxCheckBox
                                anchors.verticalCenter: parent.verticalCenter
                                style: checkBoxStyle
                                text: ""
                                onClicked: {
                                    forceActiveFocus();
                                    comboBox.enabled = checked;
                                    var val;
                                    if (checked) {
                                        var value = (comboBox.currentIndex < 0 ? "" :
                                           comboBox.model.get(comboBox.currentIndex).value);
                                        val = (value.length > 0 ? value : true);
                                    }
                                    inputActivated(modelData.itemName, val);
                                }
                                Component.onCompleted: {
                                    visible =
                                      typeof modelData.itemToggleable !== 'undefined'
                                           ? Boolean(modelData.itemToggleable) : false;
                                    if (visible) {
                                        if (typeof modelData.itemDefaultValue !== 'undefined') {
                                            var m = modelData.attributes;
                                            for (var i = 0; i < m.count; i++) {
                                                var item = m.get(i);
                                                if (item.value === modelData.itemDefaultValue) {
                                                    checked = true;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Text {
                                id: comboBoxTitle
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#000000"
                                text: ""
                                Component.onCompleted: {
                                    // avoiding binding
                                    var hintEnabled =
                                      typeof modelData.itemNameHintEnabled === 'boolean'
                                            ? modelData.itemNameHintEnabled : false;
                                    text = (typeof modelData.itemTitle !== 'undefined' ?
                                      qsTr(modelData.itemTitle) : "") + (hintEnabled &&
                                      typeof modelData.itemName !== 'undefined' ?
                                      " (" + modelData.itemName + ")" : "") + ":";
                                    font = itemFont;
                                }
                            }
                            // spacer
                            Item {
                                width: 6
                                height: 1
                            }
                            ComboBox {
                                id: comboBox
                                Layout.fillWidth: true
                                enabled: comboBoxCheckBox.visible ?
                                             comboBoxCheckBox.checked : true
                                onActivated: inputFinished(index)
                                onFocusChanged: {
                                    if (focus)
                                        scrollView.ensureVisible(repeater.itemAt(modelIndex));
                                }

                                function inputFinished(index)
                                {
                                    var value = model.get(index).value;
                                    var val;
                                    if (comboBoxCheckBox.visible)
                                        val = (value.length > 0 ? value : true);
                                    else if (value.length > 0)
                                        val = value;
                                    inputActivated(modelData.itemName, val);
                                }

                                Connections {
                                    target: configure
                                    onUpdate: {
                                        var val = func(modelData.itemName);
                                        if (!val) {
                                            if (typeof modelData.itemDefaultValue !== 'undefined')
                                                val = modelData.itemDefaultValue;
                                        }
                                        if (comboBoxCheckBox.visible) {
                                            comboBoxCheckBox.checked =
                                                    (typeof val !== 'undefined');
                                        }
                                        if (typeof val === 'undefined')
                                            ;//val = "";
                                        else if (typeof val === 'boolean')
                                            val = "";
                                        else
                                            val = String(val);
                                        var index = -1;
                                        if (val !== undefined) {
                                            for (var i = 0; i < comboBox.model.count; i++) {
                                                if (comboBox.model.get(i).value === val) {
                                                    index = i;
                                                    break;
                                                }
                                            }
                                        }
                                        comboBox.currentIndex = index;
                                    }
                                    onEnabledChanged: {
                                        comboBoxCheckBox.enabled = enabled;
                                        var val = (comboBoxCheckBox.visible ?
                                                       comboBoxCheckBox.checked &&
                                                       comboBoxCheckBox.enabled :
                                                       enabled);
                                        comboBoxTitle.enabled = val;
                                        comboBox.enabled = val;
                                        comboBoxDesc.enabled = val;
                                    }
                                }
                                Component.onCompleted: {
                                    model = modelData.attributes;
                                    if (typeof modelData.itemDefaultValue !== 'undefined') {
                                        var val = modelData.itemDefaultValue;
                                        for (var i = 0; i < comboBox.model.count; i++) {
                                            if (comboBox.model.get(i).value === val) {
                                                comboBox.currentIndex = i;
                                                break;
                                            }
                                        }
                                    }
                                    if (typeof modelData.itemGuiWidth !== 'undefined') {
                                        if (modelData.itemGuiWidth > 0)
                                            width = modelData.itemGuiWidth;
                                    }
                                }
                            }
                            // spacer
                            Item {
                                width: 2
                                height: 1
                            }
                            PtmTextButton {
                                minimumWidth: comboBox.implicitHeight
                                minimumHeight: comboBox.implicitHeight
                                horizontalMargin: verticalMargin
                                iconSource: enabled ? configure.defaultValueIcon :
                                                      configure.defaultValueDisabledIcon
                                enabled: comboBox.enabled
                                onClicked: {
                                    forceActiveFocus();
                                    if (typeof modelData.itemDefaultValue !== 'undefined') {
                                        var val = modelData.itemDefaultValue;
                                        for (var i = 0; i < comboBox.model.count; i++) {
                                            if (comboBox.model.get(i).value === val) {
                                                comboBox.currentIndex = i;
                                                // need to force the event because
                                                // ComboBox does not emit activated
                                                // if currentIndex is changed programmatically
                                                comboBox.inputFinished(i);
                                                break;
                                            }
                                        }
                                    }
                                }
                                Component.onCompleted: {
                                    visible =
                                       typeof modelData.itemDefaultValue !== 'undefined';
                                }
                            }
                        }
                        Text {
                            id: comboBoxDesc
                            anchors.left: parent.left
                            anchors.leftMargin: configure.descLeftMargin()
                            anchors.rightMargin: configure.descRightMargin()
                            width: parent.width - configure.descRightMargin() -
                                   configure.descLeftMargin()
                            textFormat: Text.StyledText
                            wrapMode: Text.Wrap
                            color: "#384959"
                            Component.onCompleted: {
                                text = typeof modelData.itemDesc !== 'undefined' ?
                                            qsTr(modelData.itemDesc) : "";
                                font = itemDescFont;
                            }
                        }
                    }
                    PtmToolTip {
                        parent: controlFrame
                        visible: enabled && comboBoxMouseArea.containsMouse

                        property bool enabled: true

                        Component.onCompleted: {
                            text = typeof modelData.itemExtDesc !== 'undefined' ?
                                      qsTr(modelData.itemExtDesc) : "";
                            title = (typeof modelData.itemTitle !== 'undefined' ?
                                         qsTr(modelData.itemTitle) : "");
                            enabled = typeof modelData.itemExtDesc !== 'undefined' &&
                                    text.length > 0;
                            decoration = configure.decoractionByIndex(this,
                                                                      modelIndex);
                            if (!autoHideToolTip)
                                timeout = -1;
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    opacity: 0.7
                    visible: !controlFrame.controlEnabled
                }
            }
        }
    }

    Component {
        id: multiComboboxComponent

        FocusScope {
            id: multiComboboxScope
            width: controlFrame.width
            height: controlFrame.height

            Rectangle {
                id: controlFrame
                width: configure.cellWidth()
                height: rowHeight
                color: multiComboboxScope.activeFocus ? '#fafbfc' : '#ffffff'
                border {
                    width: (comboBoxMouseArea.containsMouse || multiComboboxScope.activeFocus) ?
                               2 : 1
                    color: multiComboboxScope.activeFocus ?
                               '#2da7df' : comboBoxMouseArea.containsMouse ?
                                   '#dae5ee' : '#edf1f5'
                }

                property bool controlEnabled: (comboBoxCheckBox.visible ?
                                                   comboBoxCheckBox.enabled :
                                                   comboBox.enabled)
                MouseArea {
                    id: comboBoxMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onClicked: comboBox.forceActiveFocus()

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3

                        RowLayout {
                            width: parent.width
                            spacing: 0

                            CheckBox {
                                id: comboBoxCheckBox
                                anchors.verticalCenter: parent.verticalCenter
                                style: checkBoxStyle
                                text: ""
                                onClicked: {
                                    forceActiveFocus();
                                    comboBox.enabled = checked;
                                    var val;
                                    if (checked) {
                                        var value = "";
                                        for (var i = 0; i < comboBox.model.count; i++) {
                                            var item = comboBox.model.get(i);
                                            if (item.checked) {
                                                value += (value.length > 0 ? " " : "") +
                                                        item.value;
                                            }
                                        }
                                        val = (value.length > 0 ? value : true);
                                    }
                                    inputActivated(modelData.itemName, val);
                                }
                                Component.onCompleted: {
                                    visible =
                                      typeof modelData.itemToggleable !== 'undefined'
                                           ? Boolean(modelData.itemToggleable) : false;
                                    if (visible) {
                                        if (typeof modelData.itemDefaultValue !== 'undefined') {
                                            var m = modelData.attributes;
                                            for (var i = 0; i < m.count; i++) {
                                                var item = m.get(i);
                                                if (item.value === modelData.itemDefaultValue) {
                                                    checked = true;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Text {
                                id: comboBoxTitle
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#000000"
                                text: ""
                                Component.onCompleted: {
                                    // avoiding binding
                                    var hintEnabled =
                                      typeof modelData.itemNameHintEnabled === 'boolean'
                                            ? modelData.itemNameHintEnabled : false;
                                    text = (typeof modelData.itemTitle !== 'undefined' ?
                                      qsTr(modelData.itemTitle) : "") + (hintEnabled &&
                                      typeof modelData.itemName !== 'undefined' ?
                                      " (" + modelData.itemName + ")" : "") + ":";
                                    font = itemFont;
                                }
                            }
                            // spacer
                            Item {
                                width: 6
                                height: 1
                            }
                            Q2.ComboBox {
                                id: comboBox
                                Layout.fillWidth: true
                                enabled: comboBoxCheckBox.visible ?
                                             comboBoxCheckBox.checked : true
                                onFocusChanged: {
                                    if (focus)
                                        scrollView.ensureVisible(repeater.itemAt(modelIndex));
                                }
                                background: Rectangle {
                                    implicitWidth: Math.round(
                                                     textSingleton.implicitHeight * 4.5)
                                    implicitHeight: Math.max(25, Math.round(
                                                    textSingleton.implicitHeight * 1.2))
                                    gradient: Gradient {
                                        GradientStop {
                                            color: comboBox.pressed ? "#bababa" : "#fefefe"
                                            position: 0
                                        }
                                        GradientStop {
                                            color: comboBox.pressed ? "#ccc" : "#e3e3e3"
                                            position: 1
                                        }
                                    }
                                    radius: textSingleton.implicitHeight * 0.16
                                    border.color: comboBox.activeFocus ? "#47b" : "#999"
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: comboBox.activeFocus ? "#47b" : "white"
                                        opacity: comboBox.hovered ||
                                                 comboBox.activeFocus ? 0.1 : 0
                                        Behavior on opacity {
                                            NumberAnimation{ duration: 100 }
                                        }
                                    }
                                }
                                indicator: Canvas {
                                    id: canvas
                                    x: comboBox.width - width - comboBox.rightPadding
                                    y: comboBox.topPadding +
                                       (comboBox.availableHeight - height) / 2
                                    width: 8.5
                                    height: 4.5
                                    contextType: "2d"

                                    Connections {
                                        target: comboBox
                                        onPressedChanged: canvas.requestPaint()
                                    }

                                    onPaint: {
                                        context.reset();
                                        context.moveTo(0, 0);
                                        context.lineTo(width, 0);
                                        context.lineTo(width / 2, height);
                                        context.closePath();
                                        context.fillStyle = "#5b5b5a";
                                        context.fill();
                                    }
                                }
                                contentItem: Item {
                                    width: comboBox.width
                                    height: comboBox.height

                                    TextField {
                                        anchors.margins: 1
                                        width: parent.width - (comboBox.indicator.width +
                                                               comboBox.spacing + 5)
                                        height: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        textColor: textSingleton.color
                                        font: comboBox.font
                                        text: comboBox.displayText
                                        readOnly: true
                                        focus: comboBox.activeFocus
                                    }
                                }
                                delegate: Q2.ItemDelegate {
                                    width: parent.width
                                    height: (parent ? parent.contentHeight : 0) + 2
                                    contentItem: CheckBox {
                                        onClicked: {
                                            forceActiveFocus();
                                            var value = "";
                                            for (var i = 0; i < comboBox.model.count; i++) {
                                                var item = comboBox.model.get(i);
                                                if (item.text === model.text) {
                                                    // update delegate model
                                                    //model.checked = checked;
                                                    // update combobox model
                                                    item.checked = checked;
                                                }
                                                if (item.checked) {
                                                    value += (value.length > 0 ? ", " : "") +
                                                            item.text;
                                                }
                                            }
                                            // update combobox text
                                            comboBox.displayText = value;
                                        }
                                        Component.onCompleted: {
                                            text = model.text;
                                            checked = typeof model.checked !== 'undefined' ?
                                                        model.checked : false;
                                        }
                                    }
                                }
                                popup: Q2.Popup {
                                    y: comboBox.height - 1
                                    width: comboBox.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1
                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: comboBox.popup.visible ?
                                                   comboBox.delegateModel : null
                                        currentIndex: comboBox.highlightedIndex
                                        Q2.ScrollIndicator.vertical: Q2.ScrollIndicator {}
                                    }
                                    background: Rectangle {
                                        border.color: "#999"
                                        radius: 2
                                    }
                                    onClosed: comboBox.inputFinished()
                                }

                                function inputFinished()
                                {
                                    var value = "";
                                    for (var i = 0; i < comboBox.model.count; i++) {
                                        var item = comboBox.model.get(i);
                                        if (item.checked) {
                                            value += (value.length > 0 ? " " : "") +
                                                    item.value;
                                        }
                                    }
                                    var val;
                                    if (comboBoxCheckBox.visible)
                                        val = (value.length > 0 ? value : true);
                                    else if (value.length > 0)
                                        val = value;
                                    inputActivated(modelData.itemName, val);
                                }

                                Connections {
                                    target: configure
                                    onUpdate: {
                                        var val = func(modelData.itemName);
                                        if (!val) {
                                            if (typeof modelData.itemDefaultValue !== 'undefined')
                                                val = modelData.itemDefaultValue;
                                        }
                                        var checkBoxChecked = false;
                                        if (typeof val === 'undefined') {
                                            val = "";
                                        } else if (typeof val === 'boolean') {
                                            checkBoxChecked = val;
                                            val = "";
                                        } else {
                                            val = String(val);
                                        }
                                        if (val !== undefined) {
                                            var value = "";
                                            var values = val.split(" ");
                                            values.forEach(function(listItem) {
                                                for (var i = 0; i < comboBox.model.count; i++) {
                                                    var item = comboBox.model.get(i);
                                                    if (item.value === listItem) {
                                                        item.checked = true;
                                                        if (item.checked) {
                                                            value += (value.length > 0 ? ", " : "") +
                                                                    item.text;
                                                            if (comboBoxCheckBox.visible)
                                                                checkBoxChecked = true;
                                                        }
                                                        break;
                                                    }
                                                }
                                            });
                                            comboBox.displayText = value;
                                            var index = -1;
                                            for (var i = 0; i < comboBox.model.count; i++) {
                                                if (comboBox.model.get(i).value === val) {
                                                    index = i;
                                                    break;
                                                }
                                            }
                                            comboBox.currentIndex = index;
                                        }
                                        comboBoxCheckBox.checked = checkBoxChecked;
                                    }
                                    onEnabledChanged: {
                                        comboBoxCheckBox.enabled = enabled;
                                        var val = (comboBoxCheckBox.visible ?
                                                       comboBoxCheckBox.checked &&
                                                       comboBoxCheckBox.enabled :
                                                       enabled);
                                        comboBoxTitle.enabled = val;
                                        comboBox.enabled = val;
                                        comboBoxDesc.enabled = val;
                                    }
                                }
                                Component.onCompleted: {
                                    var defValues;
                                    if (typeof modelData.itemDefaultValue !== 'undefined')
                                        defValues = String(modelData.itemDefaultValue).split(", ");
                                    var value = "";
                                    var m = modelData.attributes;
                                    for (var i = 0; i < m.count; i++) {
                                        var item = m.get(i);
                                        if (defValues) {
                                            for (var j = 0; j < defValues.length; j++) {
                                                if (item.value === defValues[j]) {
                                                    item.checked = true;
                                                    break;
                                                }
                                            }
                                        }
                                        if (item.checked) {
                                            value += (value.length > 0 ? ", " : "") +
                                                    item.text;
                                        }
                                    }
                                    model = m;
                                    displayText = value;
                                    if (typeof modelData.itemGuiWidth !== 'undefined') {
                                        if (modelData.itemGuiWidth > 0)
                                            width = modelData.itemGuiWidth;
                                    }
                                }
                            }
                            // spacer
                            Item {
                                width: 2
                                height: 1
                            }
                            PtmTextButton {
                                minimumWidth: comboBox.implicitHeight
                                minimumHeight: comboBox.implicitHeight
                                horizontalMargin: verticalMargin
                                iconSource: enabled ? configure.defaultValueIcon :
                                                      configure.defaultValueDisabledIcon
                                enabled: comboBox.enabled
                                onClicked: {
                                    forceActiveFocus();
                                    var defValues;
                                    if (typeof modelData.itemDefaultValue !== 'undefined')
                                        defValues = String(modelData.itemDefaultValue).split(", ");
                                    var value = "";
                                    var m = modelData.attributes;
                                    for (var i = 0; i < m.count; i++) {
                                        var item = m.get(i);
                                        if (defValues) {
                                            for (var j = 0; j < defValues.length; j++) {
                                                if (item.value === defValues[j]) {
                                                    item.checked = true;
                                                    break;
                                                }
                                            }
                                        }
                                        if (item.checked) {
                                            value += (value.length > 0 ? ", " : "") +
                                                    item.text;
                                        }
                                    }
                                    comboBox.model = m;
                                    comboBox.displayText = value;
                                    // need to force the event because
                                    // ComboBox does not emit activated
                                    // if currentIndex is changed programmatically
                                    comboBox.inputFinished();
                                }
                                Component.onCompleted: {
                                    visible =
                                       typeof modelData.itemDefaultValue !== 'undefined';
                                }
                            }
                        }
                        Text {
                            id: comboBoxDesc
                            anchors.left: parent.left
                            anchors.leftMargin: configure.descLeftMargin()
                            anchors.rightMargin: configure.descRightMargin()
                            width: parent.width - configure.descRightMargin() -
                                   configure.descLeftMargin()
                            textFormat: Text.StyledText
                            wrapMode: Text.Wrap
                            color: "#384959"
                            Component.onCompleted: {
                                text = typeof modelData.itemDesc !== 'undefined' ?
                                            qsTr(modelData.itemDesc) : "";
                                font = itemDescFont;
                            }
                        }
                    }
                    PtmToolTip {
                        parent: controlFrame
                        visible: enabled && comboBoxMouseArea.containsMouse &&
                                 !comboBox.popup.visible

                        property bool enabled: true

                        Component.onCompleted: {
                            text = typeof modelData.itemExtDesc !== 'undefined' ?
                                      qsTr(modelData.itemExtDesc) : "";
                            title = (typeof modelData.itemTitle !== 'undefined' ?
                                         qsTr(modelData.itemTitle) : "");
                            enabled = typeof modelData.itemExtDesc !== 'undefined' &&
                                    text.length > 0;
                            decoration = configure.decoractionByIndex(this,
                                                                      modelIndex);
                            if (!autoHideToolTip)
                                timeout = -1;
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    opacity: 0.7
                    visible: !controlFrame.controlEnabled
                }
            }
        }
    }

    Component {
        id: spinComponent

        FocusScope {
            id: spinScope
            width: controlFrame.width
            height: controlFrame.height

            Rectangle {
                id: controlFrame
                width: configure.cellWidth()
                height: rowHeight
                color: spinScope.activeFocus ? '#fafbfc' : '#ffffff'
                border {
                    width: (spinBoxMouseArea.containsMouse || spinScope.activeFocus) ?
                               2 : 1
                    color: spinScope.activeFocus ?
                               '#2da7df' : spinBoxMouseArea.containsMouse ?
                                   '#dae5ee' : '#edf1f5'
                }

                property bool controlEnabled: (spinBoxCheckBox.visible ?
                                                   spinBoxCheckBox.enabled :
                                                   spinBox.enabled)

                MouseArea {
                    id: spinBoxMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onClicked: spinBox.forceActiveFocus()

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3

                        RowLayout {
                            width: parent.width
                            spacing: 0

                            CheckBox {
                                id: spinBoxCheckBox
                                anchors.verticalCenter: parent.verticalCenter
                                style: checkBoxStyle
                                text: ""
                                onClicked: {
                                    forceActiveFocus();
                                    spinBox.enabled = checked;
                                    var val;
                                    if (checked)
                                        val = (spinBox.value >= 0 ? spinBox.value : true);
                                    inputActivated(modelData.itemName, val);
                                }
                                Component.onCompleted: {
                                    visible =
                                      typeof modelData.itemToggleable !== 'undefined'
                                           ? Boolean(modelData.itemToggleable) : false;
                                    if (visible) {
                                        var val = configure.parseNumber(modelData.itemDefaultValue);
                                        if (val)
                                            checked = true;
                                    }
                                }
                            }
                            Text {
                                id: spinBoxTitle
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#000000"
                                text: ""
                                font: itemFont
                                Component.onCompleted: {
                                    // avoiding binding
                                    var hintEnabled =
                                      typeof modelData.itemNameHintEnabled === 'boolean'
                                            ? modelData.itemNameHintEnabled : false;
                                    text = (typeof modelData.itemTitle !== 'undefined' ?
                                      qsTr(modelData.itemTitle) : "") + (hintEnabled &&
                                      typeof modelData.itemName !== 'undefined' ?
                                      " (" + modelData.itemName + ")" : "") + ":";
                                }
                            }
                            // spacer
                            Item {
                                width: 6
                                height: 1
                            }
                            SpinBox {
                                id: spinBox
                                Layout.fillWidth: true
                                enabled: spinBoxCheckBox.visible ?
                                             spinBoxCheckBox.checked : true

                                property bool toggable: false
                                property bool allowActivate: false

                                onFocusChanged: {
                                    if (focus)
                                        scrollView.ensureVisible(repeater.itemAt(modelIndex));
                                }
                                onValueChanged: {
                                    // don't report event when control is being initialized
                                    if (!allowActivate)
                                        return;

                                    var val;
                                    if (toggable) {
                                        if (spinBoxCheckBox.checked)
                                            val = (value >= 0 ? value : true);
                                    } else if (value >= 0) {
                                        val = value;
                                    }
                                    inputActivated(modelData.itemName, val);
                                }
                                Connections {
                                    target: configure
                                    onUpdate: {
                                        spinBox.allowActivate = false;
                                        var val = func(modelData.itemName);
                                        // fallback to default value
                                        if (!val)
                                            val = configure.parseNumber(modelData.itemDefaultValue);
                                        if (spinBoxCheckBox.visible) {
                                            spinBoxCheckBox.checked =
                                                    (typeof val !== 'undefined');
                                        }
                                        if (typeof val !== 'undefined')
                                            spinBox.value = val;
                                        spinBox.allowActivate = true;
                                    }
                                    onEnabledChanged: {
                                        spinBoxCheckBox.enabled = enabled;
                                        var val = (spinBoxCheckBox.visible ?
                                                       spinBoxCheckBox.checked &&
                                                       spinBoxCheckBox.enabled :
                                                       enabled);
                                        spinBoxTitle.enabled = val;
                                        spinBox.enabled = val;
                                        spinBoxDesc.enabled = val;
                                    }
                                }
                                Component.onCompleted: {
                                    // setting minimal value will trigger value
                                    // change event before spinBoxCheckBox is ready
                                    toggable = typeof modelData.itemToggleable !== 'undefined'
                                           ? Boolean(modelData.itemToggleable) : false;
                                    minimumValue =
                                         typeof modelData.itemMinValue !== 'undefined' ?
                                                modelData.itemMinValue : 0;
                                    maximumValue =
                                         typeof modelData.itemMaxValue !== 'undefined' ?
                                                modelData.itemMaxValue : 99;
                                    stepSize =
                                         typeof modelData.itemStepSize !== 'undefined' ?
                                                modelData.itemStepSize : 1;
                                    var val = configure.parseNumber(modelData.itemDefaultValue);
                                    if (val)
                                        value = val;
                                    allowActivate = true;
                                }
                            }
                            // spacer
                            Item {
                                width: 2
                                height: 1
                            }
                            PtmTextButton {
                                minimumWidth: spinBox.implicitHeight
                                minimumHeight: spinBox.implicitHeight
                                horizontalMargin: verticalMargin
                                iconSource: enabled ? configure.defaultValueIcon :
                                                      configure.defaultValueDisabledIcon
                                enabled: spinBox.enabled
                                onClicked: {
                                    forceActiveFocus();
                                    var val = configure.parseNumber(modelData.itemDefaultValue);
                                    if (val)
                                        spinBox.value = val;
                                }
                                Component.onCompleted: {
                                    visible =
                                       typeof configure.parseNumber(modelData.itemDefaultValue) !==
                                            'undefined';
                                }
                            }
                        }
                        Text {
                            id: spinBoxDesc
                            anchors.left: parent.left
                            anchors.leftMargin: configure.descLeftMargin()
                            anchors.rightMargin: configure.descRightMargin()
                            width: parent.width - configure.descRightMargin() -
                                   configure.descLeftMargin()
                            textFormat: Text.StyledText
                            wrapMode: Text.Wrap
                            color: "#384959"
                            Component.onCompleted: {
                                text = typeof modelData.itemDesc !== 'undefined' ?
                                            qsTr(modelData.itemDesc) : "";
                                font = itemDescFont;
                            }
                        }
                    }
                    PtmToolTip {
                        parent: controlFrame
                        visible: enabled && spinBoxMouseArea.containsMouse

                        property bool enabled: true

                        Component.onCompleted: {
                            text = typeof modelData.itemExtDesc !== 'undefined' ?
                                      qsTr(modelData.itemExtDesc) : "";
                            title = (typeof modelData.itemTitle !== 'undefined' ?
                                         qsTr(modelData.itemTitle) : "");
                            enabled = typeof modelData.itemExtDesc !== 'undefined' &&
                                    text.length > 0;
                            decoration = configure.decoractionByIndex(this,
                                                                      modelIndex);
                            if (!autoHideToolTip)
                                timeout = -1;
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    opacity: 0.7
                    visible: !controlFrame.controlEnabled
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Text {
            id: titleText
            color: "black"
            font: titleFont
            visible: text.length > 0
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#fcfcfc"
            border {
                width: 1
                color: '#e4e4e4'
            }

            ScrollView {
                id: scrollView
                anchors.centerIn: parent
                width: parent.width - 20
                height: parent.height - 20

                function ensureVisible(option) {
                    if (flickableItem.contentX >= option.x)
                        flickableItem.contentX = option.x;
                    else if (flickableItem.contentX + flickableItem.width <= option.x + option.width)
                        flickableItem.contentX = option.x + option.width - flickableItem.width;

                    if (flickableItem.contentY >= option.y)
                        flickableItem.contentY = option.y;
                    else if (flickableItem.contentY + flickableItem.height <= option.y + option.height)
                        flickableItem.contentY = option.y + option.height - flickableItem.height;
                }

                Grid {
                    id: gridLayout
                    flow: Flow.TopToBottom
                    rows: configure.dim(repeater.model.count, maxColumns, maxRows)
                    columns: configure.dim(repeater.model.count, rows, maxColumns)
                    rowSpacing: 6
                    columnSpacing: 10
                    width: childrenRect.width + 10
                    height: childrenRect.height + 10

                    Repeater {
                        id: repeater
                        delegate: Loader {
                            sourceComponent: {
                                if (itemGuiType === "checkbox")
                                    return checkboxComponent;
                                if (itemGuiType === "input")
                                    return textComponent;
                                if (itemGuiType === "combobox")
                                    return comboboxComponent;
                                if (itemGuiType === "multicombobox")
                                    return multiComboboxComponent;
                                if (itemGuiType === "spinbox")
                                    return spinComponent;
                            }
                            property int modelIndex: index
                            property var modelData: repeater.model.get(index)
                        }
                    }
                }
            }
        }
    }
}
