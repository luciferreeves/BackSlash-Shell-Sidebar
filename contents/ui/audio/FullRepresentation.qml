import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

ColumnLayout {
    RowLayout {
        Layout.fillWidth: true
        PlasmaExtras.Heading {
            text: i18n("Audio")
            level: 4

            Layout.fillWidth: true
        }

        PlasmaComponents.ToolButton {
            id: openSettingsButton

            iconSource: "configure"
            tooltip: i18n("Configure Audio Volume...")

            onClicked: {
                KCMShell.open(["pulseaudio"])
            }
        }
    }

    PlasmaExtras.ScrollArea {
        id: scrollView
        Layout.fillWidth: true
        Layout.fillHeight: true

        Flickable {
            ColumnLayout {
                spacing: 22
                width: scrollView.width

                Outputs {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                }

                Inputs {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                }

                Applications {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                }
            }
        }
    }


    Loader {
        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true
        sourceComponent: mediaController.fullRepresentation
    }
}
