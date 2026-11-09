# Mouse Battery

A Ryoku QS Bar plugin for mice connected through the Razer HyperFlux V2
receiver, using HyperFlux Next V2.

The bar shows a mouse icon and battery percentage, plus a lightning bolt while
charging. Low battery (20% or less, not charging) uses the warning colour.
Click to see the mouse name, charging status, reading age, and a refresh button.

Offline mice show `offline`, missing readings show `--`, stale readings have a
`~` prefix, and command errors show `!` with details in the panel. It never
converts an unknown battery level to zero or preserves a charging indicator
after a failed poll. If more than one mouse is present, the first online mouse
is used, otherwise the first mouse.

## What it runs, reads, and writes

Runs `hyperfluxctl status --json` through GNU `timeout` every 15 seconds,
with a five-second timeout and a one-second kill grace period. Reads only its
JSON status output and declared plugin settings. It does not configure the
receiver or force a fresh hardware query: the HyperFlux bridge owns hardware
polling, so its reported battery percentage can update less often.

No network access, privileged actions, or file writes. Ryoku owns installation,
placement, and settings persistence. Requires `hyperfluxctl` from HyperFlux
Next V2 and `timeout` from coreutils, with the HyperFlux bridge running.

## Settings

QS Bar Settings > Community > Mouse Battery:

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| pollSeconds | int | 15 | Status refresh interval, 5-300 seconds |

## Install and maintain

```sh
ryoku plugin validate .
ryoku plugin add . --bar --yes
ryoku-shell bar move hyperflux-battery --section right --after battery
```

Edit this authoring directory, never the receipt-owned installed copy. To update,
note any changed settings, run `ryoku plugin remove hyperflux-battery`, then
repeat the install and placement commands above (removal resets settings).
Move or remove the plugin in QS Bar Settings under Layout or Community.

Development checks: `node --test tests/status.test.cjs` and
`/usr/lib/qt6/bin/qmllint service/Main.qml content/Widget.qml content/Panel.qml`.
The preview in `assets/preview-widget.png` is captured from the running bar.

## Author and license

Copilot <223556219+Copilot@users.noreply.github.com>. MIT licensed,
community-made (`official` is false); not affiliated with Razer or Ryoku.
