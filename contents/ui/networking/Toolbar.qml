import QtQuick 2.2
import QtQuick.Layouts 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Item {
    id: toolbar

    height: wifiSwitchButton.height

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections

        onWirelessEnabledChanged: {
            wifiSwitchButton.checked = wifiSwitchButton.enabled && enabled
        }

        onWirelessHwEnabledChanged: {
            wifiSwitchButton.enabled = enabled && availableDevices.wirelessDeviceAvailable && !planeModeSwitchButton.airplaneModeEnabled
        }

        onWwanEnabledChanged: {
            wwanSwitchButton.checked = wwanSwitchButton.enabled && enabled
        }

        onWwanHwEnabledChanged: {
            wwanSwitchButton.enabled = enabled && availableDevices.modemDeviceAvailable && !planeModeSwitchButton.airplaneModeEnabled
        }
    }

    RowLayout {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: parent.top
        }
        PlasmaExtras.Heading {
            text: i18n("Networking")
            level: 4

            Layout.fillWidth: true
        }

        SwitchButton {
            id: wifiSwitchButton

            checked: enabled && enabledConnections.wirelessEnabled
            enabled: enabledConnections.wirelessHwEnabled && availableDevices.wirelessDeviceAvailable && !planeModeSwitchButton.airplaneModeEnabled
            icon: enabled ? "network-wireless-on" : "network-wireless-off"
            visible: availableDevices.wirelessDeviceAvailable

            onClicked: {
                handler.enableWireless(checked);
            }
        }

        SwitchButton {
            id: wwanSwitchButton

            checked: enabled && enabledConnections.wwanEnabled
            enabled: enabledConnections.wwanHwEnabled && availableDevices.modemDeviceAvailable && !planeModeSwitchButton.airplaneModeEnabled
            icon: enabled ? "network-mobile-on" : "network-mobile-off"
            visible: availableDevices.modemDeviceAvailable

            onClicked: {
                handler.enableWwan(checked);
            }
        }

        SwitchButton {
            id: planeModeSwitchButton

            property bool airplaneModeEnabled: false

            checked: airplaneModeEnabled
            icon: airplaneModeEnabled ? "network-flightmode-on" : "network-flightmode-off"

            onClicked: {
                handler.enableAirplaneMode(checked);
                airplaneModeEnabled = !airplaneModeEnabled;
            }

            Binding {
                target: connectionIconProvider
                property: "airplaneMode"
                value: planeModeSwitchButton.airplaneModeEnabled
            }
        }

        PlasmaComponents.ToolButton {
            id: openEditorButton

            anchors {
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }

            iconSource: "configure"
            tooltip: i18n("Configure network connections...")

            onClicked: {
                handler.openEditor();
            }
        }
    }
}
