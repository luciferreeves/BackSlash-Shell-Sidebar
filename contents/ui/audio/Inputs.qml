import QtQuick 2.5
import QtQuick.Layouts 1.1

import org.kde.plasma.components 2.0 as PlasmaComponents

import "../../code/soundicon.js" as Icon

ColumnLayout {
    id: content
    spacing: 4

    RowLayout {
        id: controller
        Layout.fillWidth: true

        VolumeController {
            id: globalController
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            pulseObject: sourceModelProxy.defaultSource
            iconName: sourceModelProxy.defaultSource ? Icon.inputName(
                                                           sourceModelProxy.defaultSource.volume,
                                                           sourceModelProxy.defaultSource.muted) : "undefined"
        }
    }

    PlasmaComponents.Label {
        Layout.leftMargin: 6
        text: i18n("Inputs")
    }

    PlasmaComponents.ComboBox {
        id: inputsComboBox
        Layout.fillWidth: true
        textRole: "text"
        model: sourceModelProxy
        currentIndex: sourceModelProxy.defaultSourceIndex
        onCurrentIndexChanged: sourceModelProxy.defaultSourceIndex = currentIndex
    }

    PlasmaComponents.ComboBox {
        id: inputsPortsComboBox
        Layout.fillWidth: true
        model: sourceModel.defaultSource.ports
        onModelChanged: currentIndex = sourceModel.defaultSource.activePortIndex
        textRole: "description"
        currentIndex: sourceModel.defaultSource.activePortIndex
        onActivated: sourceModel.defaultSource.activePortIndex = index
    }
}
