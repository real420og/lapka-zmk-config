/*
 * Copyright (c) 2026 The ZMK Contributors
 * SPDX-License-Identifier: MIT
 */

#define DT_DRV_COMPAT zmk_behavior_tap_repeat

#include <zephyr/device.h>
#include <zephyr/kernel.h>
#include <drivers/behavior.h>
#include <zephyr/logging/log.h>

#include <zmk/behavior.h>
#include <zmk/keymap.h> /* ZMK_KEYMAP_EXTRACT_BINDING */

LOG_MODULE_DECLARE(zmk, CONFIG_ZMK_LOG_LEVEL);

#if DT_HAS_COMPAT_STATUS_OKAY(DT_DRV_COMPAT)

struct behavior_tap_repeat_config {
    struct zmk_behavior_binding binding; /* the wrapped behavior */
    uint32_t wait_ms;                    /* delay before first repeat */
    uint32_t tap_ms;                     /* interval between repeats */
};

struct behavior_tap_repeat_data {
    const struct device *dev;
    struct k_work_delayable work;
    struct zmk_behavior_binding_event event; /* saved invoking event */
    bool active;
};

/* One full tap of the wrapped behavior (press immediately followed by release). */
static void tap_once(const struct behavior_tap_repeat_config *cfg,
                     struct zmk_behavior_binding_event event) {
    struct zmk_behavior_binding binding = cfg->binding;
    zmk_behavior_invoke_binding(&binding, event, true);
    zmk_behavior_invoke_binding(&binding, event, false);
}

static void tap_repeat_work_cb(struct k_work *work) {
    struct k_work_delayable *d = k_work_delayable_from_work(work);
    struct behavior_tap_repeat_data *data =
        CONTAINER_OF(d, struct behavior_tap_repeat_data, work);
    const struct behavior_tap_repeat_config *cfg = data->dev->config;

    if (!data->active) {
        return;
    }

    tap_once(cfg, data->event);
    k_work_schedule(&data->work, K_MSEC(cfg->tap_ms));
}

static int on_tap_repeat_binding_pressed(struct zmk_behavior_binding *binding,
                                         struct zmk_behavior_binding_event event) {
    const struct device *dev = zmk_behavior_get_binding(binding->behavior_dev);
    struct behavior_tap_repeat_data *data = dev->data;
    const struct behavior_tap_repeat_config *cfg = dev->config;

    data->event = event;
    data->active = true;

    tap_once(cfg, event);                               /* fire once now */
    k_work_schedule(&data->work, K_MSEC(cfg->wait_ms)); /* then start repeating */

    return ZMK_BEHAVIOR_OPAQUE;
}

static int on_tap_repeat_binding_released(struct zmk_behavior_binding *binding,
                                          struct zmk_behavior_binding_event event) {
    const struct device *dev = zmk_behavior_get_binding(binding->behavior_dev);
    struct behavior_tap_repeat_data *data = dev->data;

    data->active = false;
    k_work_cancel_delayable(&data->work);

    return ZMK_BEHAVIOR_OPAQUE;
}

static const struct behavior_driver_api behavior_tap_repeat_driver_api = {
    .binding_pressed = on_tap_repeat_binding_pressed,
    .binding_released = on_tap_repeat_binding_released,
#if IS_ENABLED(CONFIG_ZMK_BEHAVIOR_METADATA)
    .get_parameter_metadata = zmk_behavior_get_empty_param_metadata,
#endif
};

static int behavior_tap_repeat_init(const struct device *dev) {
    struct behavior_tap_repeat_data *data = dev->data;
    data->dev = dev;
    data->active = false;
    k_work_init_delayable(&data->work, tap_repeat_work_cb);
    return 0;
}

#define TR_INST(n)                                                                                 \
    static struct behavior_tap_repeat_data behavior_tap_repeat_data_##n;                           \
    static const struct behavior_tap_repeat_config behavior_tap_repeat_config_##n = {              \
        .binding = ZMK_KEYMAP_EXTRACT_BINDING(0, DT_DRV_INST(n)),                                  \
        .wait_ms = DT_INST_PROP(n, wait_ms),                                                       \
        .tap_ms = DT_INST_PROP(n, tap_ms),                                                         \
    };                                                                                             \
    BEHAVIOR_DT_INST_DEFINE(n, behavior_tap_repeat_init, NULL, &behavior_tap_repeat_data_##n,      \
                            &behavior_tap_repeat_config_##n, POST_KERNEL,                          \
                            CONFIG_KERNEL_INIT_PRIORITY_DEFAULT, &behavior_tap_repeat_driver_api);

DT_INST_FOREACH_STATUS_OKAY(TR_INST)

#endif /* DT_HAS_COMPAT_STATUS_OKAY(DT_DRV_COMPAT) */
