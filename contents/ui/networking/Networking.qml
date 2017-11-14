import QtQuick 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.networkmanagement 0.2 as PlasmaNM


Item {
    id: mainWindow

    property bool showSections: true

    property Component statusIcon: Component {
        Item {
            anchors.fill: parent

            PlasmaCore.IconItem {
                id: connectionIcon

                anchors.fill: parent
                source: connectionIconProvider.connectionIcon
                colorGroup: PlasmaCore.ColorScope.colorGroup

                PlasmaComponents.BusyIndicator {
                    id: connectingIndicator

                    anchors.fill: parent
                    running: connectionIconProvider.connecting
                    visible: running
                }
            }
        }
    }

    property Component panel: Component {
        Panel {
            id: dialogItem
            Layout.minimumWidth: units.iconSizes.medium * 10
            Layout.minimumHeight: units.gridUnit * 20
            Layout.fillHeight: true
            Layout.fillWidth: true
            focus: true
        }
    }

    function action_openEditor() {
        handler.openEditor()
    }

//    Component.onCompleted: {
//        plasmoid.removeAction("configure")
//        plasmoid.setAction("openEditor",
//                           i18n("&Configure Network Connections..."),
//                           "preferences-system-network")
//    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    PlasmaNM.ConnectionIcon {
        id: connectionIconProvider
    }

    PlasmaNM.Handler {
        id: handler
    }
}
