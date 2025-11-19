# Wellum 36 для клавиатуры Lapka

Реализация раскладки [Wellum 36](https://github.com/braindefender/wellum) для клавиатуры [Lapka](https://github.com/braindefender/lapka)

Эта версия использует Dongle и состоит из трёх частей:
- `lapka_wellum36_left`
- `lapka_wellum36_right`
- `lapka_wellum36_dongle`

Чтобы перевести половинку в режим прошивки, нажмите кнопку Reset дважды.
Чтобы перевести донгл в режим прошивки, замкните пины RST и GND дважды.

Если вы редактировали настройки или раскладку и хотите обновить прошивку,
существует стабильный способ обнаружения донглом двух половинок:
1. Подключите донгл и прошейте в него `settings_reset` файл.
2. Отключите донгл от провода и отложите в сторону.
3. Подключите левую половинку и прошейте в неё сначала `settings_reset`, затем `lapka_wellum36_left`
4. Подключите правую половинку и прошейте в неё сначала `settings_reset`, затем `lapka_wellum36_right`
5. Подключите донгл и прошейте в него `lapka_wellum36_dongle`

Донгл должен быть прошит в последнюю очередь!

# Wellum 36 for Lapka keyboard

This is implementation of [Wellum 36](https://github.com/braindefender/wellum) for [Lapka](https://github.com/braindefender/lapka) keyboard.

This version uses Dongle and consists of three parts:
- `lapka_wellum36_left`
- `lapka_wellum36_right`
- `lapka_wellum36_dongle`

To turn half into bootloader mode, press reset button twice.
To turn dongle into bootloader mode, short RST and GND pins twice.

If you edit layout and want to flash new firmware, there is a stable way to get both halves to pair with the dongle:
1. Connect the dongle and flash `settings_reset` file.
2. Disconnect and turn off the dongle.
3. Connect left half and flash `settings_reset` first, then `lapka_wellum36_left`
4. Connect right half and flash `settings_reset` first, then `lapka_wellum36_right`
5. Connect the dongle and flash `lapka_wellum36_dongle` file.

So, the dongle must be flashed in the very end!
