# USB split battery indicator implementation plan

**Goal:** Show the two Lapka split battery percentages in the macOS menu bar over the existing USB dongle.

**Architecture:** Add a vendor HID input report to the dongle and poll its current values from a native Swift menu bar application. Use `0xFF` for a missing half and preserve 0% as a valid reading.

**Tech Stack:** ZMK v0.2 / Zephyr USB HID, Swift / AppKit / IOKit, Swift Package Manager.

- [x] Add failing Swift tests for decoding, missing halves, invalid packets, and label order.
- [x] Implement the report model and verify its tests pass.
- [x] Add the dongle-only USB HID GET_REPORT handler and config. The user will build firmware through GitHub Actions.
- [x] Implement HID discovery and menu bar display; compile and package the macOS app.
- [x] Document the reusable ZMK changes and installation steps; verify Swift tests and app build.
