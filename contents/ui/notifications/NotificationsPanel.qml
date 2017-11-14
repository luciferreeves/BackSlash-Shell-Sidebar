import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.notifications 1.0

import "../../code/uiproperties.js" as UiProperties

Item {
    id: notificationsApplet

    property int toolIconSize: UiProperties.toolIconSize
    property int layoutSpacing: UiProperties.layoutSpacing

    property real globalProgress: 0

    property Item notifications: NotificationsModel {
        property QtObject notificationPositioner: notificationPositioner
    }
    property Item jobs: JobsModel {
    }

    //notifications + jobs
    property int totalCount: (notifications ? notifications.count : 0) + (jobs ? jobs.count : 0)

    property Component statusIcon: Component {
        NotificationIcon {
            id: notificationIcon
        }
    }

    state: "default"

    onTotalCountChanged: {
        print(" totalCountChanged " + totalCount)
        if (totalCount > 0) {
            state = "new-notifications"
        } else {
            state = "default"
        }

        var data = new Object
        data["image"] = "preferences-desktop-notification"
        data["mainText"] = i18n("Notifications and Jobs")

        if (totalCount == 0) {
            data["subText"] = i18n("No notifications or jobs")
        } else if (!notifications.count) {
            data["subText"] = i18np("%1 running job", "%1 running jobs",
                                    jobs.count)
        } else if (!jobs.count) {
            data["subText"] = i18np("%1 notification", "%1 notifications",
                                    notifications.count)
        } else {
            data["subText"] = i18np("%1 running job", "%1 running jobs",
                                    jobs.count) + "<br/>" + i18np(
                        "%1 notification", "%1 notifications",
                        notifications.count)
        }
    }

    property Component panel: Component {
        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                PlasmaExtras.Heading {
                    text: i18n("Notifications")
                    level: 4

                    Layout.fillWidth: true
                }

                PlasmaComponents.ToolButton {
                    iconName: "edit-clear-all-symbolic"
                    text: i18n("Clear all")
                    Layout.alignment: Qt.AlignRight

                    onClicked: notifications.clearAll();
                }

                PlasmaComponents.ToolButton {
                    iconName: "adjustlevels"
                    tooltip: i18n("Configure Event Notifications and Actions...")
                    Layout.alignment: Qt.AlignRight

                    onClicked: ProcessRunner.runNotificationsKCM();
                }
            }

            PlasmaExtras.ScrollArea {
                id: mainScrollArea

                Layout.fillWidth: true
                Layout.fillHeight: true

                implicitWidth: theme.mSize(theme.defaultFont).width * 40
                implicitHeight: Math.min(
                                    theme.mSize(theme.defaultFont).height * 40,
                                    Math.max(theme.mSize(
                                                 theme.defaultFont).height * 6,
                                             contentsColumn.height))
                state: ""

                Flickable {
                    id: popupFlickable
                    anchors.fill: parent

                    contentWidth: width
                    contentHeight: contentsColumn.height
                    clip: true

                    ColumnLayout {
                        id: contentsColumn
                        width: popupFlickable.width

                        PlasmaExtras.Heading {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            level: 3
                            opacity: 0.6
                            visible: notificationsApplet.totalCount == 0
                            text: i18n("Nothing new.")
                        }

                        Loader {
                            id: jobsLoader
                            width: parent.width
                            // source: "Jobs.qml"
                            sourceComponent: Component {
                                Column {
                                    Item {
                                        visible: jobs.count > 3

                                        PlasmaComponents.ProgressBar {
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                left: parent.left
                                                right: parent.right
                                            }

                                            minimumValue: 0
                                            maximumValue: 100
                                            value: notificationsApplet.globalProgress * 100
                                        }
                                    }

                                    Repeater {
                                        model: jobs.model
                                        delegate: JobDelegate {
                                            property QtObject jobsSource: jobs.jobsSource
                                        }
                                    }
                                }
                            }
                        }

                        Loader {
                            id: notificationsLoader
                            width: parent.width
                            sourceComponent: Component {
                                ColumnLayout {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                    }
                                    Repeater {
                                        id: notificationsRepeater
                                        model: notifications.model
                                        delegate: NotificationDelegate {
                                            toolIconSize: notificationsApplet.toolIconSize
                                            property ListModel notificationsModel: notifications.model
                                            property QtObject idleTimeSource: notifications.idleTimeSource

                                            // Forward calls to the model
                                            function executeAction(source, id) {
                                                notifications.executeAction(
                                                            source, id)
                                            }
                                            function closeNotification(source) {
                                                notifications.closeNotification(
                                                            source)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                states: [
                    State {
                        name: "underMouse"
                        when: notificationsApplet.containsMouse
                        PropertyChanges {
                            target: mainScrollArea
                            implicitHeight: implicitHeight
                        }
                    },
                    State {
                        name: ""
                        when: !notificationsApplet.containsMouse
                        PropertyChanges {
                            target: mainScrollArea
                            implicitHeight: Math.min(
                                                theme.mSize(
                                                    theme.defaultFont).height * 40,
                                                Math.max(
                                                    theme.mSize(
                                                        theme.defaultFont).height * 6,
                                                    contentsColumn.height))
                        }
                    }
                ]
            }
        }
    }

    Connections {
        target: plasmoid.nativeInterface
        onAvailableScreenRectChanged: {
            notificationPositioner.setPlasmoidScreenGeometry(
                        availableScreenRect)
        }
    }

    NotificationsHelper {
        id: notificationPositioner

        popupLocation: plasmoid.nativeInterface.screenPosition
        Component.onCompleted: {
            notificationPositioner.setPlasmoidScreenGeometry(
                        plasmoid.nativeInterface.availableScreenRect)
        }
    }
}
