/* SPDX-License-Identifier: MIT */

#include <errno.h>
#include <zephyr/device.h>
#include <zephyr/init.h>
#include <zephyr/usb/class/usb_hid.h>
#include <zephyr/usb/usb_device.h>
#include <zmk/split/bluetooth/central.h>

#define BATTERY_REPORT_ID 0x04
#define BATTERY_UNKNOWN 0xFF

/* Vendor page 0xFF00, usage 1; input report: ID, slot 0, slot 1. */
static const uint8_t report_descriptor[] = {
    0x06, 0x00, 0xFF,       /* Usage Page: vendor-defined */
    0x09, 0x01,             /* Usage 1 */
    0xA1, 0x01,             /* Application collection */
    0x85, BATTERY_REPORT_ID,
    0x15, 0x00,             /* Logical minimum: 0 */
    0x26, 0xFF, 0x00,       /* Logical maximum: 255 */
    0x75, 0x08,             /* Report size: 8 bits */
    0x95, 0x02,             /* Report count: 2 */
    0x09, 0x01,             /* Usage: slot 0 */
    0x09, 0x02,             /* Usage: slot 1 */
    0x81, 0x02,             /* Input: data, variable, absolute */
    0xC0,
};

static uint8_t report[3] = {BATTERY_REPORT_ID, BATTERY_UNKNOWN, BATTERY_UNKNOWN};

static int get_report(const struct device *dev, struct usb_setup_packet *setup, int32_t *len,
                      uint8_t **data) {
    ARG_UNUSED(dev);
    if (setup->wValue != (0x100 | BATTERY_REPORT_ID)) {
        return -ENOTSUP;
    }

    for (uint8_t slot = 0; slot < 2; ++slot) {
        uint8_t level;
        int rc = zmk_split_get_peripheral_battery_level(slot, &level);
        report[slot + 1] = rc == 0 && level <= 100 ? level : BATTERY_UNKNOWN;
    }
    *len = sizeof(report);
    *data = report;
    return 0;
}

static const struct hid_ops hid_ops = {.get_report = get_report};

static int split_battery_hid_init(void) {
    const struct device *hid = device_get_binding("HID_1");
    if (!hid) {
        return -ENODEV;
    }
    usb_hid_register_device(hid, report_descriptor, sizeof(report_descriptor), &hid_ops);
    return usb_hid_init(hid);
}

/* Register the extra interface before ZMK enables USB (priority 94). */
SYS_INIT(split_battery_hid_init, APPLICATION, 93);
