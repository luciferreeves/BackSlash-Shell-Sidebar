import QtQuick 2.5
import QtQuick.Layouts 1.1

import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.volume 0.1

ColumnLayout {

    Repeater {
        delegate: sinkInputView
        model: PulseObjectFilterModel {
            filters: [{
                    role: "VirtualStream",
                    value: false
                }]
            sourceModel: SinkInputModel {
            }
        }
    }

    Component {
        id: sinkInputView

        ColumnLayout {
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true

                VolumeController {
                    id: globalController
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    pulseObject: PulseObject
                    iconName: IconName
                    shadeIconWhileMuted: true
                }
            }

            PlasmaComponents.Label {
                Layout.leftMargin: 6
                text: Client.name
                elide: Text.ElideRight
            }

            DeviceComboBox {
                Layout.fillWidth: true
                model: sinkModel
            }
        }
    }
}
