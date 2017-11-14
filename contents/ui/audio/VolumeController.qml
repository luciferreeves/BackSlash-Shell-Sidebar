import QtQuick 2.0

import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

MouseArea {
    id: root
    property bool muted: false
    property var pulseObject
    property string iconName: ""
    property bool shadeIconWhileMuted: false

    height: layout.implicitHeight

    ColumnLayout {
        id: layout

        anchors {
            left: parent.left
            right: parent.right
        }

        RowLayout {
            id: controler
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                id: column

                RowLayout {
                    id: contorller
                    Layout.fillWidth: true

                    QIconItem {
                        id: clientIcon

                        Layout.preferredHeight: slider.height
                        Layout.preferredWidth: slider.height

                        icon:  iconName !== "" ? iconName : "undefined"
                        visible: iconName !== ""

                        state: {
                            if (shadeIconWhileMuted)
                                if (pulseObject)
                                    return pulseObject.muted ? QIconItem.DisabledState : QIconItem.DefaultState

                            return QIconItem.DefaultState ;
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed: pulseObject.muted = !pulseObject.muted
                        }
                    }


                    PlasmaComponents.Slider {
                        id: slider

                        // Helper properties to allow async slider updates.
                        // While we are sliding we must not react to value updates
                        // as otherwise we can easily end up in a loop where value
                        // changes trigger volume changes trigger value changes.
                        property int volume: pulseObject? pulseObject.volume : -1
                        property bool ignoreValueChange: false

                        Layout.fillWidth: true
                        minimumValue: 0
                        // FIXME: I do wonder if exposing max through the model would be useful at all
                        maximumValue: 65536
                        stepSize: maximumValue / 100
                        visible: pulseObject? pulseObject.hasVolume : false
                        enabled: {
                            if (pulseObject && typeof pulseObject.volumeWritable === 'undefined') {
                                return !pulseObject.muted
                            }
                            return pulseObject ?  (pulseObject.volumeWritable && !pulseObject.muted) : false
                        }

                        onVolumeChanged: {
                            ignoreValueChange = true
                            value = pulseObject ? pulseObject.volume : -1
                            ignoreValueChange = false
                        }

                        onValueChanged: {
                            if (!ignoreValueChange) {
                                setVolume(value)

                                if (!pressed) {
                                    updateTimer.restart()
                                }
                            }
                        }

                        onPressedChanged: {
                            if (!pressed) {
                                // Make sure to sync the volume once the button was
                                // released.
                                // Otherwise it might be that the slider is at v10
                                // whereas PA rejected the volume change and is
                                // still at v15 (e.g.).
                                updateTimer.restart()
                            }
                        }

                        Timer {
                            id: updateTimer
                            interval: 200
                            onTriggered: slider.value = pulseObject.volume
                        }
                    }

                    PlasmaComponents.Label {
                        id: percentText
                        text: i18nc(
                                  "volume percentage", "%1%", Math.floor(
                                      slider.value / slider.maximumValue * 100.0))
                    }
                }
            }
        }
    }

    function setVolume(volume) {
        var device = pulseObject
        if (volume > 0 && muted) {
            var toMute = !device.Muted
            if (toMute) {
                osd.show(0)
            } else {
                osd.show(volumePercent(volume))
            }
            device.Muted = toMute
        }
        device.volume = volume
    }

    function volumePercent(volume) {
        return 100 * volume / slider.maximumValue
    }
}
