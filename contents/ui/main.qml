// TODO: ADD LICENCE HEADER
import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "notifications" as Notifications
import "devices" as Devices
import "networking" as Networking
import "audio" as Audio
import "activities" as Activities
import "mediacontroller" as MediaController

Item {
    id: root


    MediaController.Root {
        id: mediaController
    }

    Notifications.NotificationsPanel {
        id: notifications;
    }

    Devices.Root {
        id: devices
    }

    Activities.Root {
        id: activities
    }

    Networking.Networking {
        id: networking
    }

    Audio.Audio {
        id: audio
    }

    Plasmoid.compactRepresentation : CompactRepresentation {
        id: compactRepresentation

        Connections {
            target: expandedView
            onVisibleChanged: compactRepresentation.showHightlight = expandedView.visible
        }
    }


    SidePanel {
        id: expandedView
        FullRepresentation { id : fullRepresentation }
    }

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
}
