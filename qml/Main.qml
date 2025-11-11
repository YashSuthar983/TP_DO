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
                                tasksModel.append({ text: input.text, done: false })
                                input.text = ""
                            }
                        }
                    }

                    ListView {
                        id: list
                        width: parent.width
                        height: pages.height - 50
                        model: ListModel { id: tasksModel }
                        clip: true

                        delegate: Row {
                            width: list.width
                            spacing: 8
                            CheckBox {
                                checked: done
                                onToggled: tasksModel.setProperty(index, "done", checked)
                            }
                            Label {
                                text: model.text
                                wrapMode: Text.WordWrap
                                opacity: done ? 0.5 : 1.0
                                font.strikeout: done
                            }
                            Button {
                                text: "✕"
                                onClicked: tasksModel.remove(index, 1)
                            }
                        }
                    }
                }
            }

            Item {
                Label {
                    anchors.centerIn: parent
                    text: "History (Coming Soon)"
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
                            }
                        }
                    }
            }
        }
    }
}