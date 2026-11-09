pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "Status.js" as Status

Item {
    id: svc

    property var pluginApi
    readonly property var settings: pluginApi ? pluginApi.pluginSettings : null
    readonly property int pollSeconds: Math.max(5, Math.min(300, settings?.pollSeconds ?? 15))
    property var battery: Status.unavailable("Waiting for HyperFlux", false)
    readonly property bool busy: poll.running

    function refresh() {
        if (svc.pluginApi && !poll.running)
            poll.running = true;
    }

    function fail(message) {
        svc.battery = Status.unavailable(message, true);
        console.warn("hyperflux-battery: " + message);
    }

    onPluginApiChanged: svc.refresh()

    Timer {
        interval: svc.pollSeconds * 1000
        running: !!svc.pluginApi
        repeat: true
        triggeredOnStart: true
        onTriggered: svc.refresh()
    }

    Process {
        id: poll
        command: ["timeout", "--kill-after=1s", "5s", "hyperfluxctl", "status", "--json"]
        stdout: StdioCollector {
            id: output
            waitForEnd: true
        }
        stderr: StdioCollector {
            id: errors
            waitForEnd: true
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                svc.fail(exitCode === 124 || exitCode === 137
                    ? "HyperFlux request timed out"
                    : "hyperfluxctl failed: " + (errors.text.trim() || "exit " + exitCode));
                return;
            }
            try {
                svc.battery = Status.parse(output.text);
            } catch (error) {
                svc.fail("Invalid HyperFlux response: " + error.message);
            }
        }
    }
}
