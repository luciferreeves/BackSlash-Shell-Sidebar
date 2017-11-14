import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
Item {
    property Component fullRepresentation: Component {
        FullRepresentation {
        }
    }

    id: devicenotifier
    property string devicesType: "removable"
    property string expandedDevice
    property string popupIcon: "device-notifier"

    property bool itemClicked: false
    property int currentExpanded: -1
    property int currentIndex: -1


    PlasmaCore.DataSource {
        id: hpSource
        engine: "hotplug"
        connectedSources: sources
        interval: 0

        onSourceAdded: {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: {
            disconnectSource(source);
        }
    }

    PlasmaCore.DataSource {
        id: sdSource
        engine: "soliddevice"
        connectedSources: hpSource.sources
        interval: plasmoid.expanded ? 5000 : 0
        property string last
        onSourceAdded: {
            disconnectSource(source);
            connectSource(source);
            last = source;
            processLastDevice(true);
        }

        onSourceRemoved: {
            if (expandedDevice == source) {
                devicenotifier.currentExpanded = -1;
                expandedDevice = "";
            }
            disconnectSource(source);
        }

        onDataChanged: {
            processLastDevice(true);
        }

        onNewData: {
            last = sourceName;
            processLastDevice(false);
        }

        function processLastDevice(expand) {
            if (last != "") {
                if (devicesType == "all" ||
                    (devicesType == "removable" && data[last] && data[last]["Removable"] == true) ||
                    (devicesType == "nonRemovable" && data[last] && data[last]["Removable"] == false)) {
                    if (expand && hpSource.data[last]["added"]) {
                        expandDevice(last)
                    }
                    last = "";
                }
            }
        }
    }

    PlasmaCore.SortFilterModel {
        id: filterModel
        sourceModel: PlasmaCore.DataModel {
            dataSource: sdSource
        }
        filterRole: "Removable"
        filterRegExp: {
            var all = false // devicenotifier.Plasmoid.configuration.allDevices;
            var removable =  true //devicenotifier.Plasmoid.configuration.removableDevices;

            if (all == true) {
                devicesType = "all";
                return "";
            } else if (removable == true) {
                devicesType = "removable";
                return "true";
            } else {
                devicesType = "nonRemovable";
                return "false";
            }
        }
        sortRole: "Timestamp"
        sortOrder: Qt.DescendingOrder
    }

    function popupEventSlot(popped) {
        if (!popped) {
            // reset the property that lets us remember if an item was clicked
            // (versus only hovered) for autohide purposes
            devicenotifier.itemClicked = true;
            expandedDevice = "";
            devicenotifier.currentExpanded = -1;
            devicenotifier.currentIndex = -1;
        }
    }

    function expandDevice(udi)
    {
        if (hpSource.data[udi]["actions"].length > 1) {
            expandedDevice = udi
        }

        // reset the property that lets us remember if an item was clicked
        // (versus only hovered) for autohide purposes
        devicenotifier.itemClicked = false;

        devicenotifier.popupIcon = "preferences-desktop-notification";
        //plasmoid.expanded = true;
        // expandTimer.restart();
        popupIconTimer.restart()
    }

    function isMounted (udi) {
        var types = sdSource.data[udi]["Device Types"];
        if (types.indexOf("Storage Access")>=0) {
            if (sdSource.data[udi]["Accessible"]) {
                return true;
            }
            else {
                return false;
            }
        }
        else if (types.indexOf("Storage Volume")>=0 && types.indexOf("OpticalDisc")>=0) {
            return true;
        }
        else {
            return false;
        }
    }

    Timer {
        id: popupIconTimer
        interval: 2500
        onTriggered: devicenotifier.popupIcon  = "device-notifier";
    }
}
