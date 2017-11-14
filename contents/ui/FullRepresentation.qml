// TODO: ADD LICENCE HEADER
import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0

ColumnLayout {
    StackView {
        id: stackView
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: units.smallSpacing

        initialItem: Component {
            id: statusView
            ColumnLayout {
                objectName: "statusView"
                Loader {
                    id: noficationsLayout

                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: units.smallSpacing

                    sourceComponent: activities.panel
                }
            }
        }

        Component.onCompleted: {
            push()
        }
    }

    function showStatusView() {
        stackView.pop({
                          item: statusView,
                          immediate: true
                      })
    }

    function showNetworkingView() {
        if (stackView.currentItem.objectName == "networkingView") {
            return
        }
        showStatusView()
        stackView.push({
                           item: networking.panel,
                           properties: {
                               objectName: "networkingView"
                           }
                       })
    }

    function showAudioView() {
        if (stackView.currentItem.objectName == "audioView") {
            return
        }

        showStatusView()
        stackView.push({
                           item: audio.panel,
                           properties: {
                               objectName: "audioView"
                           }
                       })
    }
}
