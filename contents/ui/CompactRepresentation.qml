import QtQuick 2.0
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

RowLayout {
    id: root
    property bool showHightlight: false
    property Item selectedItem: notificationsStatusIcon
    property ListModel icons

    property var iconSize: 24

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        property bool wasExpanded: false
        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                wasExpanded = expandedView.visible
            }
        }
        onClicked: {
            if (mouse.button == Qt.LeftButton) {
                if (!wasExpanded) {
                    expandedView.display()
                } else {
                    expandedView.hide()
                }
            }
        }
    }

    Loader {
        id: notificationsStatusIcon
        Layout.alignment: Qt.AlignHCenter
        Layout.minimumWidth: root.height
        Layout.maximumWidth: root.height
        Layout.fillHeight: true

        sourceComponent: notifications.statusIcon

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                print("showing status panel")
                fullRepresentation.showStatusView()
                selectedItem = notificationsStatusIcon
                mouse.accepted = false
            }
        }
    }
    Loader {
        id: netwrokingStatusIcon
        Layout.alignment: Qt.AlignHCenter
        Layout.minimumWidth: root.height
        Layout.maximumWidth: root.height
        Layout.fillHeight: true

        sourceComponent: networking.statusIcon

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                fullRepresentation.showNetworkingView()
                selectedItem = netwrokingStatusIcon
                mouse.accepted = false
            }
        }
    }

    Loader {
        id: audioStatusIcon
        Layout.alignment: Qt.AlignHCenter
        Layout.minimumWidth: root.height
        Layout.maximumWidth: root.height
        Layout.fillHeight: true

        sourceComponent: audio.statusIcon

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                fullRepresentation.showAudioView()
                selectedItem = audioStatusIcon
                mouse.accepted = false
            }
        }
    }

    Rectangle {
        id: higthlight

        height: 3

        Connections {
            target: root
            onSelectedItemChanged: {
                higthlight.y = selectedItem.y
                if (showHightlight) {
                    movingAnimation.from = higthlight.x
                    movingAnimation.to = selectedItem.x
                    movingAnimation.start()
                }
            }
        }

        //opacity: root.showHigthlight ? 1.0 : 0.0
        color: "#3DAEE9" // PlasmaCore.Theme.highlightColor

        NumberAnimation on x {
            id: movingAnimation
            easing.type: Easing.InOutQuad
        }

        NumberAnimation on opacity {
            id: fadeAnimation
            easing.type: Easing.InOutQuad
        }

        NumberAnimation on width {
            id: resizeAnimation
            easing.type: Easing.InOutQuad
        }

        Component.onCompleted: {
            width = root.width
            opacity = 0
            y = root.y
        }
    }

    onShowHightlightChanged: {
        fadeAnimation.complete()
        resizeAnimation.complete()
        movingAnimation.complete()

        higthlight.y = root.y

        if (showHightlight) {
            movingAnimation.to = selectedItem.x
            fadeAnimation.to = 1
            resizeAnimation.to = selectedItem.width
        } else {
            movingAnimation.to = root.x
            fadeAnimation.to = 0
            resizeAnimation.to = root.width
        }

        movingAnimation.start()
        resizeAnimation.start()
        fadeAnimation.start()
    }
}
