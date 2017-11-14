import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kquickcontrolsaddons 2.0

MouseArea {
    Layout.minimumWidth: units.gridUnit * 18
    Layout.minimumHeight: units.gridUnit * 22
    implicitHeight: heading.height + (filterModel.count
                                      > 0 ? notifierDialog.height : noDevicesLabel.implicitHeight)

    hoverEnabled: true

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }

    RowLayout {
        id: heading
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        PlasmaExtras.Heading {
            width: parent.width
            level: 4
            text: i18n("Devices")
        }

        PlasmaComponents.ToolButton {
            id: openSettingsButton

            Layout.alignment: Qt.AlignRight
            iconSource: "configure"
            tooltip: i18n("Configure Removable Devices...")

            onClicked: {
                KCMShell.open(["device_automounter_kcm"])
            }
        }
    }

    PlasmaExtras.Heading {
        id: noDevicesLabel
        anchors.top: heading.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        width: parent.width
        level: 3
        opacity: 0.6
        text: i18n("No Devices Available")
        visible: filterModel.count == 0
    }

    PlasmaCore.DataSource {
        id: statusSource
        engine: "devicenotifications"
        property string last
        onSourceAdded: {
            console.debug("Source added " + last)
            last = source
            disconnectSource(source)
            connectSource(source)
        }
        onSourceRemoved: {
            console.debug("Source removed " + last)
            disconnectSource(source)
        }
        onDataChanged: {
            console.debug("Data changed for " + last)
            console.debug("Error:" + data[last]["error"])
            if (last != "") {
                statusBar.setData(data[last]["error"],
                                  data[last]["errorDetails"], data[last]["udi"])
                // plasmoid.expanded = true
            }
        }
    }

    ColumnLayout {
        anchors.top: heading.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        PlasmaExtras.ScrollArea {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: notifierDialog
                focus: true
                boundsBehavior: Flickable.StopAtBounds

                model: filterModel

                property int currentExpanded: -1
                property bool itemClicked: true
                delegate: deviceItem
                highlight: PlasmaComponents.Highlight {
                }
                highlightMoveDuration: 0
                highlightResizeDuration: 0

                //this is needed to make SectionScroller actually work
                //acceptable since one doesn't have a billion of devices
                cacheBuffer: 1000

                section {
                    property: "Type Description"
                    delegate: Item {
                        height: childrenRect.height
                        width: notifierDialog.width
                        PlasmaExtras.Heading {
                            level: 4
                            opacity: 0.6
                            text: section
                        }
                    }
                }
            }
        }

        PlasmaCore.SvgItem {
            id: statusBarSeparator
            Layout.fillWidth: true
            svg: lineSvg
            elementId: "horizontal-line"
            height: lineSvg.elementSize("horizontal-line").height

            visible: statusBar.height > 0
            anchors.bottom: statusBar.top
        }

        StatusBar {
            id: statusBar
            Layout.fillWidth: true
            anchors.bottom: parent.bottom
        }
    }

    Component {
        id: deviceItem

        DeviceItem {
            id: wrapper
            width: notifierDialog.width
            udi: DataEngineSource
            icon: sdSource.data[udi] ? sdSource.data[udi]["Icon"] : ""
            deviceName: sdSource.data[udi] ? sdSource.data[udi]["Description"] : ""
            // emblemIcon: Emblems[0]
            state: sdSource.data[udi]["State"]

            percentUsage: {
                if (!sdSource.data[udi]) {
                    return 0
                }
                var freeSpace = new Number(sdSource.data[udi]["Free Space"])
                var size = new Number(sdSource.data[udi]["Size"])
                var used = size - freeSpace
                return used * 100 / size
            }
            freeSpaceText: sdSource.data[udi]
                           && sdSource.data[udi]["Free Space Text"] ? sdSource.data[udi]["Free Space Text"] : ""

            leftActionIcon: {
                if (mounted) {
                    return "media-eject"
                } else {
                    return "emblem-mounted"
                }
            }
            mounted: devicenotifier.isMounted(udi)

            onLeftActionTriggered: {
                var operationName = mounted ? "unmount" : "mount"
                var service = sdSource.serviceForSource(udi)
                var operation = service.operationDescription(operationName)
                service.startOperationCall(operation)
            }
            property bool isLast: (expandedDevice == udi)
            property int operationResult: (model["Operation result"])

            onIsLastChanged: {
                if (isLast) {
                    devicenotifier.currentExpanded = index
                }
            }
            onOperationResultChanged: {
                if (operationResult == 1) {
                    devicenotifier.popupIcon = "dialog-ok"
                    popupIconTimer.restart()
                } else if (operationResult == 2) {
                    devicenotifier.popupIcon = "dialog-error"
                    popupIconTimer.restart()
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: units.shortDuration * 3
                }
            }
        }
    }
} // MouseArea
