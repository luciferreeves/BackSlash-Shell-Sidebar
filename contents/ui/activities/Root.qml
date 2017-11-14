import QtQuick 2.0
import QtQuick.Layouts 1.1

Item {
    property Component panel: Component {
        ColumnLayout {
            anchors.fill: parent

            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 300;

                sourceComponent: notifications.panel

            }

            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.maximumHeight: parent.height * 2/5
                // Layout.maximumHeight: item.implicitHeight
                sourceComponent: devices.fullRepresentation
            }
        }
    }
}
