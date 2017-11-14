import QtQuick 2.5
import QtQuick.Layouts 1.1

import org.kde.plasma.components 2.0 as PlasmaComponents

import "../../code/soundicon.js" as Icon

ColumnLayout {
    id: content
    spacing: 4

    VolumeController {
        id: globalController
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        pulseObject: sinkModelProxy.defaultSink
        iconName: sinkModelProxy.defaultSink ? Icon.outputName(
                                                   sinkModelProxy.defaultSink.volume,
                                                   sinkModelProxy.defaultSink.muted) : "undefined"
    }

    PlasmaComponents.Label {
        Layout.leftMargin: 6
        text: i18n("Outputs")
    }

    PlasmaComponents.ComboBox {
        id: outputsComboBox
        Layout.fillWidth: true
        textRole: "text"
        model: sinkModelProxy
        currentIndex: sinkModelProxy.defaultSinkIndex
        onCurrentIndexChanged: sinkModelProxy.defaultSinkIndex = currentIndex
    }

    PlasmaComponents.ComboBox {
        id: outputsPortsComboBox
        Layout.fillWidth: true
        model: sinkModel.defaultSink.ports
        onModelChanged: currentIndex = sinkModel.defaultSink.activePortIndex
        textRole: "description"
        currentIndex: sinkModel.defaultSink.activePortIndex
        onActivated: sinkModel.defaultSink.activePortIndex = index
    }
}
