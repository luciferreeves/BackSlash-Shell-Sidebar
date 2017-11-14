import QtQuick 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.networkmanagement 0.2 as PlasmaNM


FocusScope {

    PlasmaNM.AvailableDevices {
        id: availableDevices
    }

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    PlasmaNM.AppletProxyModel {
        id: appletProxyModel

        sourceModel: connectionModel
    }

    Toolbar {
        id: toolbar

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    PlasmaExtras.ScrollArea {
        id: scrollView

        anchors {
            bottom: actions.top
            left: parent.left
            right: parent.right
            top: toolbar.bottom
        }

        ListView {
            id: connectionView

            property bool availableConnectionsVisible: false
            property int currentVisibleButtonIndex: -1

            anchors.fill: parent
            clip: true
            model: appletProxyModel
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds
            section.property: showSections ? "Section" : ""
            section.delegate: Header { text: section }
            delegate: ConnectionItem { }
        }
    }

    GridLayout {
        id: actions
        columns: 2
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        PlasmaComponents.ToolButton {
            iconSource: "preferences-system-network"
            tooltip: i18n("Configure system proxy...")

            text: i18n("Proxy")
            onClicked: {
                KCMShell.open(["proxy"])
            }
        }
        PlasmaComponents.ToolButton {
            iconSource: "emblem-shared-symbolic"
            tooltip: i18n("Configure shared resources...")

            text: i18n("Shared resources")
            onClicked: {
                KCMShell.open(["smb"])
            }
        }

        PlasmaComponents.ToolButton {
            iconSource: "preferences-web-browser-ssl"
            tooltip: i18n("Configure ssl certificates...")

            text: i18n("SSL Certificates")
            onClicked: {
                KCMShell.open(["kcm_ssl"])
            }
        }
        PlasmaComponents.ToolButton {
            iconSource: "network-card"
            tooltip: i18n("View network interfaces...")

            text: i18n("Network Interfaces")
            onClicked: {
                KCMShell.open(["nic"])
            }
        }
    }

    Connections {
        target: plasmoid
        onExpandedChanged: connectionView.currentVisibleButtonIndex = -1
    }
}
