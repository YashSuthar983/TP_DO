import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Window {
    id: root
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint
        | Qt.Tool
        | (stayOnTop ? Qt.WindowStaysOnTopHint : 0)

    width: expanded ? expandedWidth : collapsedWidth
    height: winheight
    x: Screen.width - width
    y: 0

    property bool expanded: false
    property bool stayOnTop: true
    property int expandedWidth: 360
    property int winheight : Screen.height/3
    property int collapsedWidth:8

    Component.onCompleted: {
        root.expandedWidth = settingsModel.expandedWidth
        root.winheight = settingsModel.winHeight
    }

    SystemPalette { id: systemPalette; colorGroup: SystemPalette.Active }

    HoverHandler {
        id: panelHover
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onHoveredChanged: root.expanded = hovered
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        opacity: 0.96

        color: systemPalette.window
        border.color: Qt.rgba(0.5, 0.5, 0.5, 0.2)
        border.width: 1
    }

    Column {
        anchors {
            top: parent.top; topMargin: 10
            left: parent.left; right: parent.right
            leftMargin: 20; rightMargin: 20
        }
        spacing: 8
        visible: root.expanded

        Label {
            text: "TP_DO"
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
        }

        TabBar {
            id: tabBar
            width: parent.width
            TabButton { text: "Tasks" }
            TabButton { text: "History" }
            TabButton { text: "Settings" }
        }

        SwipeView {
            id: pages
            width: parent.width
            height: root.winheight - 100
            currentIndex: tabBar.currentIndex
            interactive: false
            clip: true

            // Tasks
            Item {
                Column {
                    anchors.fill: parent
                    spacing: 10
                    
                    Row {
                        spacing: 6
                        width: parent.width
                        TextField {
                            id: input
                            width: parent.width - addBtn.width - 6
                            placeholderText: "Add a task and press +"
                            selectByMouse: true
                            onAccepted: addBtn.clicked()
                        }
                        Button {
                            id: addBtn
                            text: "+"
                            enabled: input.text.length > 0
                            onClicked: {
                                tasksModel.addTask(input.text)
                                tasksModel.saveToFile("tasks.json")
                                input.text = ""
                            }
                        }
                    }

                    ListView {
                        id: list
                        width: parent.width
                        height: pages.height - 50
                        model: tasksModel
                        clip: true
                        interactive: true
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            id: taskItem
                            width: list.width
                            height: rowLayout.implicitHeight
                            color: dropArea.containsDrag ? "#d0ffd0" : (ListView.isCurrentItem ? "#f3f3f3" : "transparent")
                            property int myIndex: index

                            RowLayout {
                                id: rowLayout
                                anchors.fill: parent
                                anchors.leftMargin: 25
                                spacing: 8

                                CheckBox {
                                    id: checkBox
                                    checked: done
                                    onToggled: {
                                        tasksModel.setDone(index, checked)
                                        tasksModel.saveToFile("tasks.json")
                                    }
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Label {
                                    id: taskLabel
                                    text: model.text
                                    wrapMode: Text.WordWrap
                                    font.strikeout: done
                                    opacity: done ? 0.5 : 1.0
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter

                                    height: Math.max(paintedHeight, implicitHeight)
                                }

                                Column {
                                    spacing: 2
                                    Layout.alignment: Qt.AlignVCenter
                                    
                                    Button {
                                        id: upBtn
                                        text: "↑"
                                        width: 30
                                        height: 20
                                        enabled: myIndex > 0
                                        onClicked: {
                                            tasksModel.moveTask(myIndex, myIndex - 1)
                                            tasksModel.saveToFile("tasks.json")
                                        }
                                    }
                                    
                                    Button {
                                        id: downBtn
                                        text: "↓"
                                        width: 30
                                        height: 20
                                        enabled: myIndex < tasksModel.count() - 1
                                        onClicked: {
                                            tasksModel.moveTask(myIndex, myIndex + 1)
                                            tasksModel.saveToFile("tasks.json")
                                        }
                                    }
                                }

                                Button {
                                    id: deleteBtn
                                    text: "✕"
                                    onClicked: {
                                        historyModel.addTask(model.text, true)
                                        historyModel.saveToFile("history.json")
                                        tasksModel.removeTask(index)
                                        tasksModel.saveToFile("tasks.json")
                                    }
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // drag handle
                            Rectangle {
                                id: dragHandle
                                width: 20
                                height: parent.height
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                                color: "transparent"
                                
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 12
                                    height: parent.height - 10
                                    color: "#cccccc"
                                    radius: 2
                                    
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 2
                                        Repeater {
                                            model: 3
                                            Rectangle {
                                                width: 8
                                                height: 2
                                                color: "#888888"
                                                radius: 1
                                            }
                                        }
                                    }
                                }
                                
                                property int dragIndex: myIndex
                                
                                MouseArea {
                                    id: dragMouseArea
                                    anchors.fill: parent
                                    drag.target: dragProxy
                                    
                                    onPressed: {
                                        taskItem.z = 10
                                        taskItem.opacity = 0.8
                                        dragProxy.Drag.start()
                                    }
                                    
                                    onReleased: {
                                        taskItem.z = 0
                                        taskItem.opacity = 1.0
                                        dragProxy.Drag.drop()
                                        // Reset proxy position
                                        dragProxy.x = dragHandle.x
                                        dragProxy.y = dragHandle.y
                                    }
                                }
                            }
                            
                            // Invisible drag proxy that moves with mouse
                            Rectangle {
                                id: dragProxy
                                width: 20
                                height: 20
                                color: "blue"
                                opacity: 0.3
                                visible: dragMouseArea.drag.active
                                
                                Drag.active: dragMouseArea.drag.active
                                Drag.source: dragHandle
                                Drag.keys: ["taskitem"]
                                Drag.hotSpot.x: width / 2
                                Drag.hotSpot.y: height / 2
                            }
                            
                            DropArea {
                                id: dropArea
                                anchors.fill: parent
                                keys: ["taskitem"]
                                
                                onEntered: {
                                    console.log("Drag entered item", myIndex)
                                }
                                
                                onExited: {
                                    console.log("Drag exited item", myIndex)
                                }
                                
                                onDropped: {
                                    var fromIndex = drag.source.dragIndex
                                    var toIndex = myIndex
                                    console.log("DROPPED: Moving from", fromIndex, "to", toIndex)
                                    if (fromIndex !== toIndex && fromIndex !== undefined) {
                                        tasksModel.moveTask(fromIndex, toIndex)
                                        tasksModel.saveToFile("tasks.json")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // History
            Item {
                Column {
                    anchors.fill: parent
                    spacing: 10

                    Label {
                        text: "Archived Tasks"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ListView {
                        width: parent.width
                        height: pages.height - 50
                        model: historyModel
                        clip: true

                        delegate: Label {
                            width: parent.width
                            text: model.text
                            wrapMode: Text.WordWrap
                            opacity: 0.7
                            font.strikeout: true
                        }
                    }
                }
            }

            // settings
            Item {
                Column {
                    anchors.fill: parent
                    spacing: 10
                    
                    // Width
                    Row {
                        spacing: 6
                        width: parent.width

                        Text {
                            text: "Width"
                            font.pixelSize: 18
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextField {
                            id: input_width
                            width: 100
                            text: root.expandedWidth.toString()
                            validator: IntValidator { bottom: 360 }
                            placeholderText: "width"
                            selectByMouse: true
                            onAccepted: btn_save_setting.clicked()
                        }
                    }

                    // Height
                    Row {
                        spacing: 6
                        width: parent.width

                        Text {
                            text: "Height"
                            font.pixelSize: 18
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextField {
                            id: input_heigth
                            width: 100
                            text: root.winheight.toString()
                            validator: IntValidator { bottom: 100 }
                            placeholderText: "height"
                            selectByMouse: true
                            onAccepted: btn_save_setting.clicked()
                        }
                    }
                }
                // Save Button
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 20

                        Button {
                            id: btn_save_setting
                            text: "SAVE"
                            enabled: input_width.acceptableInput && input_heigth.acceptableInput && input_width.text.length > 0 && input_heigth.text.length > 0
                            onClicked: {
                                root.expandedWidth = parseInt(input_width.text)
                                root.winheight = parseInt(input_heigth.text)
                                settingsModel.expandedWidth = parseInt(input_width.text)
                                settingsModel.winHeight = parseInt(input_heigth.text)
                                settingsModel.saveToFile("settings.json")
                            }
                        }
                    }
            }
        }
    }
}