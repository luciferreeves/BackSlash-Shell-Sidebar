
import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: root

    property var currentMetadata: mpris2Source.currentData ? mpris2Source.currentData.Metadata : undefined
    
    property string track: {
        if (!currentMetadata) {
            return ""
        }
        var xesamTitle = currentMetadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle
        }
        // if no track title is given, print out the file name
        var xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
        if (!xesamUrl) {
            return ""
        }
        var lastSlashPos = xesamUrl.lastIndexOf('/')
        if (lastSlashPos < 0) {
            return ""
        }
        var lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
        return decodeURIComponent(lastUrlPart)
    }
    
    property string artist: currentMetadata ? currentMetadata["xesam:artist"] || "" : ""
    property string albumArt: currentMetadata ? currentMetadata["mpris:artUrl"] || "" : ""
    property int length: currentMetadata ? currentMetadata["mpris:length"] || 0 : 0

    property bool noPlayer: mpris2Source.sources.length <= 1

    readonly property bool canRaise: !root.noPlayer && mpris2Source.currentData.CanRaise
    readonly property bool canQuit: !root.noPlayer && mpris2Source.currentData.CanQuit

    readonly property bool canControl: !root.noPlayer && mpris2Source.currentData.CanControl
    readonly property bool canGoPrevious: canControl && mpris2Source.currentData.CanGoPrevious
    readonly property bool canGoNext: canControl && mpris2Source.currentData.CanGoNext


    PlasmaCore.DataSource {
        id: mpris2Source

        readonly property string multiplexSource: "@multiplex"
        property string current: multiplexSource

        readonly property var currentData: data[current]

        engine: "mpris2"
        connectedSources: current

        onSourceRemoved: {
            // if player is closed, reset to multiplex source
            if (source === current) {
                current = multiplexSource
            }
        }
    }

    property Component fullRepresentation: Component {
        ExpandedRepresentation {
        }
    }


    function action_open() {
        serviceOp(mpris2Source.current, "Raise");
    }
    function action_quit() {
        serviceOp(mpris2Source.current, "Quit");
    }

    function action_play() {
        serviceOp(mpris2Source.current, "Play");
    }

    function action_pause() {
        serviceOp(mpris2Source.current, "Pause");
    }

    function action_playPause() {
        serviceOp(mpris2Source.current, "PlayPause");
    }

    function action_previous() {
        serviceOp(mpris2Source.current, "Previous");
    }

    function action_next() {
        serviceOp(mpris2Source.current, "Next");
    }

    function action_stop() {
        serviceOp(mpris2Source.current, "Stop");
    }

    function serviceOp(src, op) {
        var service = mpris2Source.serviceForSource(src);
        var operation = service.operationDescription(op);
        return service.startOperationCall(operation);
    }

    states: [
        State {
            name: "playing"
            when: !root.noPlayer && mpris2Source.currentData.PlaybackStatus === "Playing"

//            PropertyChanges {
//                target: plasmoid
//                icon: albumArt ? albumArt : "media-playback-start"
//                toolTipMainText: track
//                toolTipSubText: artist ? i18nc("Artist of the song", "by %1", artist) : ""
//            }
        },
        State {
            name: "paused"
            when: !root.noPlayer && mpris2Source.currentData.PlaybackStatus === "Paused"

//            PropertyChanges {
//                target: plasmoid
//                icon: albumArt ? albumArt : "media-playback-pause"
//                toolTipMainText: track
//                toolTipSubText: artist ? i18nc("Artist of the song", "by %1 (paused)", artist) : i18n("Paused")
//            }
        }
    ]
}
