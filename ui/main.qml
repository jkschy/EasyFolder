import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 700
    height: 480
    title: "EasyFolder File Sorter"
    color: "#f0f0f3" // soft modern background

    property bool processing: backend.processing
    property string toastMessage: backend.toastMessage
    property bool showToast: toastMessage !== ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header / description
        ColumnLayout {
            spacing: 5
            Label {
                text: "File Sorter"
                font.pixelSize: 28
                font.bold: true
                color: "#333333"
            }
            Label {
                text: "Select a directory, enter file names, and separate them into 'found' and 'other' folders automatically."
                font.pixelSize: 14
                wrapMode: Text.Wrap
                color: "#555555"
            }
        }

        // Directory picker
        RowLayout {
            spacing: 8
            Label {
                text: "Select Directory"
                font.bold: true
                color: "#333333"
            }

            TextField {
                id: directoryInput
                objectName: "directoryInput"
                Layout.fillWidth: true
                placeholderText: "Click Browse or enter path"
                background: Rectangle {
                    radius: 8
                    color: "white"
                    border.color: "#cccccc"
                }
                padding: 8
                color: "#222222"
            }

            Button {
                text: "Browse"
                hoverEnabled: true
                onClicked: backend.browseDirectory()

                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#43a047" : "#4caf50"
                    border.color: "#388e3c"
                    border.width: 1
                }
                contentItem: Text {
                    text: qsTr("Browse")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Text area for file names
        ColumnLayout {
            spacing: 5
            Label {
                text: "Files to Separate (one per line):"
                font.bold: true
                color: "#333333"
            }

            TextArea {
                id: fileListArea
                objectName: "fileListArea"
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Enter file names here..."
                background: Rectangle {
                    radius: 8
                    color: "white"
                    border.color: "#cccccc"
                }
                padding: 8
                color: "#222222"
                font.pixelSize: 14
            }
        }

        // Action button with spinner
        Button {
            id: separateButton
            Layout.alignment: Qt.AlignHCenter
            font.bold: true
            hoverEnabled: true
            enabled: !processing
            padding: 12

            background: Rectangle {
                id: btnBg
                radius: 10
                border.color: "#1565c0"
                border.width: 1
                color: separateButton.hovered ? "#1565c0" : "#1976d2"
            }

            contentItem: Row {
                anchors.centerIn: parent
                spacing: 8

                // Spinner
                Rectangle {
                    id: spinner
                    visible: processing
                    width: 16
                    height: 16
                    radius: 8
                    color: "white"

                    transform: Rotation {
                        id: spinnerRot
                        origin.x: spinner.width / 2
                        origin.y: spinner.height / 2
                        angle: 0

                        Behavior on angle {
                            NumberAnimation { duration: 600; loops: Animation.Infinite }
                        }
                    }

                    onVisibleChanged: {
                        if (visible)
                            spinnerRot.angle = 360
                        else
                            spinnerRot.angle = 0
                    }
                }

                Text {
                    text: processing ? "Processing..." : qsTr("Separate Files")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            onClicked: backend.separateFiles(directoryInput.text, fileListArea.text)
        }
    }

    // Toast notification
    Rectangle {
        id: toast
        width: parent.width * 0.8
        height: 40
        radius: 8
        color: "#323232"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        visible: showToast
        opacity: showToast ? 0.9 : 0.0

        Text {
            anchors.centerIn: parent
            text: toastMessage
            color: "white"
            font.pixelSize: 14
        }

        // Auto-hide toast
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Timer {
            id: toastTimer
            interval: 3000 // 3 seconds
            repeat: false
            onTriggered: {
                toast.opacity = 0
            }
        }

        // When toastMessage changes, show toast and start timer
        onVisibleChanged: {
            if (visible) {
                toastTimer.restart()
            }
        }
    }
}
