const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const { test } = require("node:test");
const vm = require("node:vm");

const logic = vm.createContext({});
vm.runInContext(readFileSync(join(__dirname, "../service/Status.js"), "utf8"), logic);

function status(changes = {}, extra = {}) {
    return logic.parse(JSON.stringify({
        bridge: "running",
        devices: [{
            kind: "mouse",
            name: "Razer Cobra Pro",
            presence: "online",
            battery_level: 53,
            battery_charge: "charging",
            battery_stale: false,
            battery_age_ms: 65000,
            ...changes,
        }],
        ...extra,
    }));
}

test("shows the live percentage and charging state", () => {
    const result = status();
    assert.equal(result.value, "53%");
    assert.equal(result.charging, true);
    assert.equal(result.name, "Razer Cobra Pro");
    assert.equal(result.detail, "Hardware reading: 1 min ago");
});

test("discharging and full do not show a charging bolt", () => {
    assert.equal(status({ battery_charge: "discharging" }).message, "Discharging");
    assert.equal(status({ battery_charge: "discharging" }).charging, false);
    assert.equal(status({ battery_charge: "full", battery_level: 100 }).message, "Fully charged");
});

test("zero is a valid battery level; missing and invalid levels are not zero", () => {
    assert.equal(status({ battery_level: 0 }).value, "0%");
    for (const value of [null, undefined, "53", -1, 101]) {
        const result = status({ battery_level: value });
        assert.equal(result.value, "--");
        assert.equal(result.level, -1);
    }
});

test("stale and offline readings never imply current charging", () => {
    assert.equal(status({ battery_stale: true }).value, "~53%");
    assert.equal(status({ battery_stale: true }).charging, false);
    assert.equal(status({ presence: "offline" }).value, "offline");
    assert.equal(status({ presence: "offline" }).charging, false);
});

test("unknown charging state is explicit", () => {
    const result = status({ battery_charge: null });
    assert.equal(result.value, "53%");
    assert.equal(result.charging, false);
    assert.equal(result.message, "Charging state not reported");
});

test("no mouse, stopped bridge, and malformed responses are distinct", () => {
    assert.equal(status({}, { devices: [{ kind: "keyboard" }] }).value, "--");
    assert.equal(status({}, { bridge: "stopped" }).error, true);
    assert.throws(() => logic.parse("{}"), /Missing devices array/);
    assert.throws(() => logic.parse("null"), /Missing devices array/);
    assert.throws(() => logic.parse("not json"), /JSON|Unexpected/);
});

test("selects an online mouse instead of an offline mouse or keyboard", () => {
    const result = status({}, { devices: [
        { kind: "keyboard", presence: "online", battery_level: 99 },
        { kind: "mouse", presence: "offline", battery_level: 80 },
        { kind: "mouse", presence: "online", battery_level: 42, name: "Online mouse" },
    ] });
    assert.equal(result.name, "Online mouse");
    assert.equal(result.value, "42%");
});

test("command failure clears percentage and charging", () => {
    const result = logic.unavailable("request failed", true);
    assert.equal(result.value, "!");
    assert.equal(result.charging, false);
    assert.equal(result.level, -1);
    assert.equal(result.error, true);
});
