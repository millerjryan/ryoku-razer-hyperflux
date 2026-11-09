pragma ComponentBehavior: Bound

import QtQuick
import Ryoku.PluginKit.Singletons

Item {
    id: root

    property var pluginApi
    property string density: "full"
    property real s: 1
    property real widthBudget: 320
    property bool active: false

    readonly property var service: pluginApi ? pluginApi.mainInstance : null
    readonly property var battery: service ? service.battery : null

    implicitWidth: root.widthBudget
    implicitHeight: col.implicitHeight + 24 * root.s

    Column {
        id: col
        x: 12 * root.s
        y: 12 * root.s
        width: root.width - 24 * root.s
        spacing: 10 * root.s

        Text {
            width: parent.width
            text: root.battery ? root.battery.name : "Mouse Battery"
            wrapMode: Text.Wrap
            color: Theme.bright
            font.family: Theme.display
            font.pixelSize: 16 * root.s
        }

        Text {
            text: root.battery ? root.battery.value : "--"
            color: root.battery?.charging ? Theme.accent : Theme.bright
            font.family: Theme.font
            font.pixelSize: 28 * root.s
        }

        Text {
            width: parent.width
            text: root.battery ? root.battery.message : "Waiting for HyperFlux"
            wrapMode: Text.Wrap
            color: root.battery?.error ? Theme.vermDeep : Theme.dim
            font.family: Theme.font
            font.pixelSize: 13 * root.s
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.battery ? root.battery.detail : ""
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 12 * root.s
        }

        Rectangle {
            width: refreshLabel.implicitWidth + 24 * root.s
            height: refreshLabel.implicitHeight + 12 * root.s
            radius: Theme.radius
            color: refreshArea.pressed ? Theme.vermDeep : Theme.accent
            opacity: refreshArea.enabled ? 1 : 0.5

            Text {
                id: refreshLabel
                anchors.centerIn: parent
                text: root.service?.busy ? "REFRESHING..." : "REFRESH"
                color: Theme.cardBot
                font.family: Theme.font
                font.pixelSize: 12 * root.s
            }

            MouseArea {
                id: refreshArea
                anchors.fill: parent
                enabled: root.service !== null && !root.service.busy
                onClicked: root.service.refresh()
            }
        }
    }
}
