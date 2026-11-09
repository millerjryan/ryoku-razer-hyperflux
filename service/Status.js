function unavailable(message, error) {
    return {
        name: "Mouse Battery",
        level: -1,
        online: false,
        charging: false,
        stale: false,
        error: error,
        value: error ? "!" : "--",
        message: message,
        detail: ""
    };
}

function parse(text) {
    var status = JSON.parse(text);
    if (!status || !Array.isArray(status.devices))
        throw new Error("Missing devices array");
    if (status.bridge !== "running")
        return unavailable("HyperFlux bridge is not running", true);

    var mice = status.devices.filter(function(device) {
        return device && device.kind === "mouse";
    });
    var mouse = mice.find(function(device) {
        return device.presence === "online";
    }) || mice[0];
    if (!mouse)
        return unavailable("No mouse connected to HyperFlux", false);

    var online = mouse.presence === "online";
    var level = mouse.battery_level;
    var known = typeof level === "number" && isFinite(level) && level >= 0 && level <= 100;
    var stale = mouse.battery_stale === true;
    var charging = online && !stale && mouse.battery_charge === "charging";
    var message;
    if (!online)
        message = "Mouse offline or asleep";
    else if (!known)
        message = "Battery level not reported";
    else if (stale)
        message = "Stale battery reading";
    else if (charging)
        message = "Charging";
    else if (mouse.battery_charge === "discharging")
        message = "Discharging";
    else if (mouse.battery_charge === "full")
        message = "Fully charged";
    else
        message = "Charging state not reported";

    var age = mouse.battery_age_ms;
    return {
        name: mouse.name || "Razer mouse",
        level: known ? Math.round(level) : -1,
        online: online,
        charging: charging,
        stale: stale,
        error: false,
        value: !online ? "offline" : !known ? "--" : (stale ? "~" : "") + Math.round(level) + "%",
        message: message,
        detail: typeof age === "number" && isFinite(age) && age >= 0
            ? "Hardware reading: " + Math.floor(age / 60000) + " min ago" : ""
    };
}
