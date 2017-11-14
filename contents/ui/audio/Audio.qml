import QtQuick 2.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.volume 0.1

import "../../code/soundicon.js" as Icon

Item {
    id: main

//    property bool volumeFeedback: Plasmoid.configuration.volumeFeedback
//    property int maxVolumePercent: Plasmoid.configuration.maximumVolume
    property int maxVolumeValue: Math.round(
                                     maxVolumePercent * PulseAudio.NormalVolume / 100.0)
//    property int volumeStep: Math.round(Plasmoid.configuration.volumeStep
//                                        * PulseAudio.NormalVolume / 100.0)

    property bool volumeFeedback:true
    property int maxVolumePercent: 100
    property int volumeStep: Math.round(4
                                        * PulseAudio.NormalVolume / 100.0)

    property QtObject draggedStream: null

    function boundVolume(volume) {
        return Math.max(PulseAudio.MinimalVolume, Math.min(volume,
                                                           maxVolumeValue))
    }

    function volumePercent(volume, max) {
        if (!max) {
            max = PulseAudio.NormalVolume
        }
        return Math.round(volume / max * 100.0)
    }

    function increaseVolume() {
        if (!sinkModel.preferredSink) {
            return
        }
        var volume = boundVolume(sinkModel.preferredSink.volume + volumeStep)
        sinkModel.preferredSink.muted = false
        sinkModel.preferredSink.volume = volume
        osd.show(volumePercent(volume, maxVolumeValue))
        playFeedback()
    }

    function decreaseVolume() {
        if (!sinkModel.preferredSink) {
            return
        }
        var volume = boundVolume(sinkModel.preferredSink.volume - volumeStep)
        sinkModel.preferredSink.muted = false
        sinkModel.preferredSink.volume = volume
        osd.show(volumePercent(volume, maxVolumeValue))
        playFeedback()
    }

    function muteVolume() {
        if (!sinkModel.preferredSink) {
            return
        }
        var toMute = !sinkModel.preferredSink.muted
        sinkModel.preferredSink.muted = toMute
        osd.show(toMute ? 0 : volumePercent(sinkModel.preferredSink.volume,
                                            maxVolumeValue))
        playFeedback()
    }

    function increaseMicrophoneVolume() {
        if (!sourceModel.defaultSource) {
            return
        }
        var volume = boundVolume(sourceModel.defaultSource.volume + volumeStep)
        sourceModel.defaultSource.muted = false
        sourceModel.defaultSource.volume = volume
        osd.showMicrophone(volumePercent(volume))
    }

    function decreaseMicrophoneVolume() {
        if (!sourceModel.defaultSource) {
            return
        }
        var volume = boundVolume(sourceModel.defaultSource.volume - volumeStep)
        sourceModel.defaultSource.muted = false
        sourceModel.defaultSource.volume = volume
        osd.showMicrophone(volumePercent(volume))
    }

    function muteMicrophone() {
        if (!sourceModel.defaultSource) {
            return
        }
        var toMute = !sourceModel.defaultSource.muted
        sourceModel.defaultSource.muted = toMute
        osd.showMicrophone(toMute ? 0 : volumePercent(
                                        sourceModel.defaultSource.volume))
    }

    function beginMoveStream(type, stream) {
        if (type == "sink") {
            sourceView.visible = false
            sourceViewHeader.visible = false
        } else if (type == "source") {
            sinkView.visible = false
            sinkViewHeader.visible = false
        }

        tabBar.currentTab = devicesTab
    }

    function endMoveStream() {
        tabBar.currentTab = streamsTab

        sourceView.visible = true
        sourceViewHeader.visible = true
        sinkView.visible = true
        sinkViewHeader.visible = true
    }

    function playFeedback(sinkIndex) {
        if (!volumeFeedback) {
            return
        }
        if (!sinkIndex) {
            sinkIndex = sinkModel.preferredSink.cardIndex
        }
        feedback.play(sinkIndex)
    }

    property Component statusIcon: Component {
        PlasmaCore.IconItem {
            source: sinkModel.preferredSink ? Icon.outputName(sinkModel.preferredSink.volume, sinkModel.preferredSink.muted) : undefined
            active: mouseArea.containsMouse
            colorGroup: PlasmaCore.ColorScope.colorGroup

            MouseArea {
                id: mouseArea

                property int wheelDelta: 0
                property bool wasExpanded: false

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.MiddleButton
                propagateComposedEvents: true

                onWheel: {
                    var delta = wheel.angleDelta.y || wheel.angleDelta.x
                    wheelDelta += delta
                    // Magic number 120 for common "one click"
                    // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                    while (wheelDelta >= 120) {
                        wheelDelta -= 120
                        increaseVolume()
                    }
                    while (wheelDelta <= -120) {
                        wheelDelta += 120
                        decreaseVolume()
                    }
                }
            }
        }
    }

    GlobalActionCollection {
        // KGlobalAccel cannot transition from kmix to something else, so if
        // the user had a custom shortcut set for kmix those would get lost.
        // To avoid this we hijack kmix name and actions. Entirely mental but
        // best we can do to not cause annoyance for the user.
        // The display name actually is updated to whatever registered last
        // though, so as far as user visible strings go we should be fine.
        // As of 2015-07-21:
        //   componentName: kmix
        //   actions: increase_volume, decrease_volume, mute
        name: "kmix"
        // displayName: main.displayName
        GlobalAction {
            objectName: "increase_volume"
            text: i18n("Increase Volume")
            shortcut: Qt.Key_VolumeUp
            onTriggered: increaseVolume()
        }
        GlobalAction {
            objectName: "decrease_volume"
            text: i18n("Decrease Volume")
            shortcut: Qt.Key_VolumeDown
            onTriggered: decreaseVolume()
        }
        GlobalAction {
            objectName: "mute"
            text: i18n("Mute")
            shortcut: Qt.Key_VolumeMute
            onTriggered: muteVolume()
        }
        GlobalAction {
            objectName: "increase_microphone_volume"
            text: i18n("Increase Microphone Volume")
            shortcut: Qt.Key_MicVolumeUp
            onTriggered: increaseMicrophoneVolume()
        }
        GlobalAction {
            objectName: "decrease_microphone_volume"
            text: i18n("Decrease Microphone Volume")
            shortcut: Qt.Key_MicVolumeDown
            onTriggered: decreaseMicrophoneVolume()
        }
        GlobalAction {
            objectName: "mic_mute"
            text: i18n("Mute Microphone")
            shortcut: Qt.Key_MicMute
            onTriggered: muteMicrophone()
        }
    }

    VolumeOSD {
        id: osd
    }

    VolumeFeedback {
        id: feedback
    }

    property Component panel: Component {
        FullRepresentation {
        }
    }

    SinkModel {
        id: sinkModel

        onDataChanged: syncProxyModel()

        function syncProxyModel() {
            // print("syncSinkProxyModel ")
            sinkModelProxy.clear()
            for (var i = 0; i < rowCount(); i++) {
                var idx = index(i, 0)
                var sink = data(idx, role("PulseObject"))
                // print (sink, sink.description);
                sinkModelProxy.append({
                                          text: sink.description,
                                          sink: sink
                                      })
                var isDefault = data(idx, role("Default"))
                if (isDefault && sinkModelProxy.defaultSinkIndex !== i)
                    sinkModelProxy.defaultSinkIndex = i
            }
        }

        function setDefaultSink(i) {
            // print ("setDefaultSink", i)
            if (i < rowCount()) {
                var idx = index(i, 0)
                setData(idx, 1, role("Default"))
            }
        }
    }
    ListModel {
        id: sinkModelProxy
        property var defaultSink: sinkModel.defaultSink
        property int defaultSinkIndex: -1

        onDefaultSinkIndexChanged: sinkModel.setDefaultSink(defaultSinkIndex)
    }

    SourceModel {
        id: sourceModel

        onDataChanged: syncProxyModel()

        function syncProxyModel() {
            // print("syncSourceProxyModel ")
            sourceModelProxy.clear()
            for (var i = 0; i < rowCount(); i++) {
                var idx = index(i, 0)
                var sink = data(idx, role("PulseObject"))
                // print (sink, sink.description);
                sourceModelProxy.append({
                                            text: sink.description,
                                            sink: sink
                                        })
                var isDefault = data(idx, role("Default"))
                if (isDefault && sourceModelProxy.defaultSourceIndex !== i)
                    sourceModelProxy.defaultSourceIndex = i
            }
        }

        function setDefaultSource(i) {
            // print ("setDefaultSink", i)
            if (i < rowCount()) {
                var idx = index(i, 0)
                setData(idx, 1, role("Default"))
            }
        }
    }

    ListModel {
        id: sourceModelProxy
        property var defaultSource: sourceModel.defaultSource
        property int defaultSourceIndex: -1

        onDefaultSourceIndexChanged: sourceModel.setDefaultSource(
                                         defaultSourceIndex)
    }
}
