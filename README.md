# My Battery Now — build guide

## What's in here
- `MyBatteryNowPrefs.bundle/` — the Settings page (Root/About/Credits/Help.plist +
  `MBNRootListController.m`). Edit the `.plist` files directly to reorder or add
  rows — no compiling needed, just re-copy the bundle and respring.
- `Tweak.xm` — injects into SpringBoard, reads your chosen percentage/colour from
  prefs, and overrides them.
- `control` / `Makefile` — packaging.

## Requirements
You need a real Theos environment (macOS or Linux) with an iOS 15 SDK. This can't
be compiled in a plain chat sandbox — it needs the iOS cross-compiler toolchain,
`ldid`, and `dpkg-deb`.

1. Install Theos: https://github.com/theos/theos/wiki/Installation
2. Grab an iOS 15.x SDK and drop it in `$THEOS/sdks/`
3. `export THEOS=/path/to/theos`

## The one thing to fix before building
Open `Tweak.xm` and replace `ExampleBatteryController` /
`exampleBatteryLevel` / `ExampleBatteryTextLabel` with the real SpringBoard
class/method names for iOS 15.8.8. These change between iOS versions, so:

- On your jailbroken device, dump SpringBoard's Objective-C classes
  (class-dump, or a runtime browser tweak like RootlessJB's "Cycript"/"Choicy"
  helpers, or Flex/Filza's built-in class browser).
- Search for classes with "Battery" in the name.
- Find the getter that returns the current level (0.0–1.0 float) — hook that
  one, not just a label, so Control Center/lock screen/status bar all follow it.

This is the only part that's version-specific; everything else in this project
will work as-is.

## Build & install
```
make package        # produces a .deb in packages/
make install         # if your device is reachable over SSH (edit Makefile THEOS_DEVICE_IP)
```
Or copy the `.deb` to the device and install it from Filza, or drop it into a
local Sileo repo folder and add it as a repo source — Sileo will pick it up.

After install, respring once. From then on, Settings → My Battery Now → slide
the percentage / pick a colour → changes apply live via the Darwin notification,
no more resprings needed.

## Editing the design later
Everything about the Settings page's look/order lives in the `.plist` files —
add, remove, or reorder `dict` entries in the `items` array of `Root.plist` the
same way you'd rearrange rows in a list. Re-copy the bundle to
`/Library/PreferenceBundles/MyBatteryNowPrefs.bundle` and respring to see changes,
no rebuild of `Tweak.xm` required unless you're changing the hook itself.
