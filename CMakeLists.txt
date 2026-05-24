# SPDX-License-Identifier: MIT
if(CONFIG_ZMK_BEHAVIOR_TAP_REPEAT)
  zephyr_library()
  zephyr_library_sources(src/behavior_tap_repeat.c)
  # ZMK's app/include is PRIVATE to the app target (app/CMakeLists.txt), so
  # external modules must add it to reach drivers/behavior.h, zmk/behavior.h, etc.
  zephyr_library_include_directories(${ZEPHYR_BASE}/../zmk/app/include)
endif()
