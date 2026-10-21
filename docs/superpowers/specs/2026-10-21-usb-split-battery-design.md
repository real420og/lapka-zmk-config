# USB split battery indicator design

The Lapka Wellum 36 dongle is the ZMK split central and already fetches two peripheral battery values over BLE. The user wants both values visible in the macOS menu bar while the keyboard remains connected through USB. The product has no separate window.

## Firmware

The dongle exposes a second USB HID interface with vendor usage page `0xFF00`, usage `0x01`, and input report ID `0x04`. A three-byte report contains the ID followed by the battery percentages for split peripheral slots 0 and 1. `0xFF` means a slot is disconnected or has no reading; 0 through 100 are valid charge levels. The HID GET_REPORT handler reads ZMK's current split battery cache and connection state, so the Mac can obtain values immediately after starting. The extra interface is enabled only for the dongle by a Kconfig option. The keyboard HID interface and both peripheral firmwares remain as they are.

ZMK numbers peripherals by pairing slot, not by physical side. The app labels slots left and right by default and offers a swap toggle in its menu.

## macOS app

A small native Swift/AppKit status item polls the HID input report every 15 seconds. It shows `Л 85% · П 72%`, or a dash for missing values. Its menu gives per-side readings, a swap setting, refresh, and quit. The app has `LSUIElement=YES` and opens no window or Dock icon. A build script packages an `.app` bundle without third-party dependencies. The user may add the app to Login Items in macOS settings.

## Verification and limitations

Unit tests exercise report decoding, unknown values, invalid data and label swapping. The firmware build must target the existing pinned ZMK v0.2 environment. A physical device check remains necessary to confirm USB enumeration, pairing-slot order and battery readings. The documentation describes the reusable ZMK patch and the Lapka-specific wiring/configuration.
