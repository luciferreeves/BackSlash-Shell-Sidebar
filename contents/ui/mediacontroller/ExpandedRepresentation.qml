/***************************************************************************
 *   Copyright 2016  FrederickSalazar <frederick_sanchez@nitrux.in>        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                  *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/


import QtQml 2.2
import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ColumnLayout {
    id: expandedRepresentation

    readonly property int buttonSize: units.iconSizes.large
    readonly property int controlSize: Math.min(height, width) / 4
    readonly property int length: currentMetadata ? currentMetadata["mpris:length"]
                                                    || 0 : 0

    property bool keyPressed: false
    property bool disablePositionUpdate: false
    property bool isExpanded: visible
    property int position: mpris2Source.currentData.Position || 0

    function retrievePosition() {
        var service = mpris2Source.serviceForSource(mpris2Source.current)
        var operation = service.operationDescription("GetPosition")
        service.startOperationCall(operation)
    }

    onIsExpandedChanged: {
        if (isExpanded) {
            retrievePosition()
            seekTimer.start()
        } else
            seekTimer.stop()
    }

    onPositionChanged: {
        // we don't want to interrupt the user dragging the slider
        if (!seekSlider.pressed && !keyPressed
                && !queuedPositionUpdate.running) {
            // we also don't want passive position updates
            disablePositionUpdate = true
            seekSlider.value = position
            disablePositionUpdate = false
        }
    }

    onLengthChanged: {
        disablePositionUpdate = true
        // When reducing maximumValue, value is clamped to it, however
        // when increasing it again it gets its old value back.
        // To keep us from seeking to the end of the track when moving
        // to a new track, we'll reset the value to zero and ask for the position again
        seekSlider.value = 0
        seekSlider.maximumValue = length
        retrievePosition()
        disablePositionUpdate = false
    }

    Keys.onPressed: keyPressed = true

    Keys.onReleased: {
        keyPressed = false

        if (!event.modifiers) {
            event.accepted = true

            if (event.key === Qt.Key_Space || event.key === Qt.Key_K) {
                // K is YouTube's key for "play/pause" :)
                root.action_playPause()
            } else if (event.key === Qt.Key_P) {
                root.action_previous()
            } else if (event.key === Qt.Key_N) {
                root.action_next()
            } else if (event.key === Qt.Key_S) {
                root.action_stop()
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_J) {
                // TODO ltr languages
                // seek back 5s
                seekSlider.value = Math.max(
                            0, seekSlider.value - 5000000) // microseconds
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                // seek forward 5s
                seekSlider.value = Math.min(seekSlider.maximumValue,
                                            seekSlider.value + 5000000)
            } else if (event.key === Qt.Key_Home) {
                seekSlider.value = 0
            } else if (event.key === Qt.Key_End) {
                seekSlider.value = seekSlider.maximumValue
            } else if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                // jump to percentage, ie. 0 = beginnign, 1 = 10% of total length etc
                seekSlider.value = seekSlider.maximumValue * (event.key - Qt.Key_0) / 10
            } else {
                event.accepted = false
            }
        }
    }

    // spacing: units.smallSpacing

    PlasmaComponents.ComboBox {
        id: playerCombo
        Layout.fillWidth: true
        visible: model.length > 2 // more than one player, @multiplex is always there
        model: {
            var model = [{
                             text: i18n("Choose player automatically"),
                             source: mpris2Source.multiplexSource
                         }]

            var sources = mpris2Source.sources
            for (var i = 0, length = sources.length; i < length; ++i) {
                var source = sources[i]
                if (source === mpris2Source.multiplexSource) {
                    continue
                }

                // we could show the pretty player name ("Identity") here but then we
                // would have to connect all sources just for this
                model.push({
                               text: source,
                               source: source
                           })
            }

            return model
        }

        onModelChanged: {
            // if model changes, ComboBox resets, so we try to find the current player again...
            for (var i = 0, length = model.length; i < length; ++i) {
                if (model[i].source === mpris2Source.current) {
                    currentIndex = i
                    break
                }
            }
        }

        onActivated: {
            disablePositionUpdate = true
            // ComboBox has currentIndex and currentText, why doesn't it have currentItem/currentModelValue?
            mpris2Source.current = model[index].source
            disablePositionUpdate = false
        }
    }

    RowLayout {
        id: titleRow
        Layout.fillWidth: true
        Layout.minimumHeight: albumArt.Layout.preferredHeight
        spacing: units.largeSpacing

        PlasmaCore.IconItem {
            id: albumArt
            readonly property int size: 96
//            readonly property int size: Math.round(
//                                            expandedRepresentation.height / 2
//                                            - (playerCombo.count > 2 ? playerCombo.height : 0))

            source: root.albumArt == "" ? "nocover" : root.albumArt
            Layout.preferredHeight: size
            Layout.preferredWidth: size
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: units.smallSpacing / 2

            PlasmaExtras.Heading {
                id: song
                Layout.fillWidth: true
                level: 3
                opacity: 0.6

                maximumLineCount: 3
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                text: root.track ? root.track : i18n("No media playing")
            }

            PlasmaExtras.Heading {
                id: artist
                Layout.fillWidth: true
                level: 4
                opacity: 0.4
                maximumLineCount: 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: text !== ""

                elide: Text.ElideRight
                text: root.artist || ""
            }
        }
    }

    RowLayout {
        id: playerControls
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        property bool enabled: root.canControl
        property int controlsSize: theme.mSize(theme.defaultFont).height * 3

        spacing: units.largeSpacing

        //especificamos el boton para previous playback
        PlasmaComponents.ToolButton {
            Layout.preferredWidth: expandedRepresentation.buttonSize
            Layout.preferredHeight: Layout.preferredWidth
            enabled: playerControls.enabled && root.canGoPrevious
            onClicked: {
                seekSlider.value = 0 // Let the media start from beginning. Bug 362473
                root.action_previous()
            }

            style: ButtonStyle {
                background: PlasmaCore.IconItem {
                    width: parent.width
                    height: parent.height
                    source: "media-skip-backward"
                }
            }
        }

        //especificamos button para play-pause playback
        PlasmaComponents.ToolButton {
            Layout.preferredWidth: expandedRepresentation.buttonSize
            Layout.preferredHeight: Layout.preferredWidth
            enabled: playerControls.enabled
            //iconSource: root.state == "playing" ? "media-playback-pause" : "media-playback-start"
            onClicked: root.action_playPause()

            // opacity: 0.7
            style: ButtonStyle {
                background: PlasmaCore.IconItem {
                    width: parent.width
                    height: parent.height
                    source: root.state
                            == "playing" ? "media-playback-pause" : "media-playback-start"
                }
            }
        }

        //especificamos el button next para next-playback
        PlasmaComponents.ToolButton {
            Layout.preferredWidth: expandedRepresentation.buttonSize
            Layout.preferredHeight: Layout.preferredWidth
            enabled: playerControls.enabled && root.canGoNext

            onClicked: {
                seekSlider.value = 0 // Let the media start from beginning. Bug 362473
                root.action_next()
            }

            style: ButtonStyle {
                background: PlasmaCore.IconItem {
                    width: parent.width
                    height: parent.height
                    source: "media-skip-forward"
                }
            }
        }
    }

    RowLayout {
        id: progreso
        Layout.fillWidth: true
        spacing: 20
        visible: root.track

        // anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: trackMin
            readonly property int miliseconds: Math.abs(seekSlider.value / 1000)
            readonly property date lenght: new Date(miliseconds)
            Layout.leftMargin: 12
            text: lenght.toISOString().substr(
                      11, 2) == "00" ? lenght.toISOString().substr(
                                           14, 5) : lenght.toISOString(
                                           ).substr(11, 8)
        }

        //vamos entonces a ajustar la barra de progeso del reproductor
        ProgressBar {
            id: seekSlider
            Layout.fillWidth: true

            z: 999
            value: 0

            // if there's no "mpris:length" in teh metadata, we cannot seek, so hide it in that case
            enabled: !root.noPlayer && root.track && currentMetadata
                     && root.length
                     && mpris2Source.currentData.CanSeek ? true : false
            opacity: enabled ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: units.longDuration
                }
            }

            onValueChanged: {
                if (!disablePositionUpdate) {
                    // delay setting the position to avoid race conditions
                    queuedPositionUpdate.restart()
                }
            }

            Timer {
                id: seekTimer
                interval: 1000
                repeat: true
                running: root.state == "playing" && visible && !keyPressed
                onTriggered: {
                    if (!seekSlider.pressed) {
                        disablePositionUpdate = true
                        retrievePosition()

                        disablePositionUpdate = false
                    }
                }
            }
        }

        Label {
            id: trackMaxim
            Layout.rightMargin: 12
            readonly property int miliseconds: Math.abs(root.length / 1000)
            readonly property date lenght: new Date(miliseconds)
            text: lenght.toISOString().substr(
                      11, 2) == "00" ? lenght.toISOString().substr(
                                           14, 5) : lenght.toISOString(
                                           ).substr(11, 8)
        }
    }

    Timer {
        id: queuedPositionUpdate
        interval: 100
        onTriggered: {
            var service = mpris2Source.serviceForSource(mpris2Source.current)
            var operation = service.operationDescription("SetPosition")
            operation.microseconds = seekSlider.value
            service.startOperationCall(operation)
        }
    }
}
