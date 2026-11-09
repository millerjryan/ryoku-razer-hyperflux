pragma ComponentBehavior: Bound

import QtQuick
import Ryoku.PluginKit.Singletons

Item {
    id: root

    property var pluginApi
    property var screen
    property bool active: false
    property string density: "glyph"
    property real s: 1
    property real widthBudget: 220

    readonly property var service: pluginApi ? pluginApi.mainInstance : null
    readonly property var battery: service ? service.battery : null
    readonly property color ink: !battery || !battery.online || battery.stale
        ? Theme.dim : battery.level >= 0 && battery.level <= 20 && !battery.charging
        ? Theme.vermDeep : Theme.bright

    implicitWidth: Math.min(row.implicitWidth, root.widthBudget > 0 ? root.widthBudget : 220 * root.s)
    implicitHeight: Math.max(row.implicitHeight, 18 * root.s)
    clip: true

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5 * root.s

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "\ue323"
            color: root.battery?.error ? Theme.vermDeep : root.ink
            font.family: "Material Symbols Rounded"
            font.pixelSize: 17 * root.s
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.battery ? root.battery.value : "--"
            color: root.battery?.error ? Theme.vermDeep : root.ink
            font.family: Theme.font
            font.pixelSize: 13 * root.s
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.battery ? root.battery.charging : false
            text: "\ue3e7"
            color: Theme.accent
            font.family: "Material Symbols Rounded"
            font.pixelSize: 16 * root.s
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (root.pluginApi) root.pluginApi.togglePanel()
    }
}
