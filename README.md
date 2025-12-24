# Wellum 36 для клавиатуры Lapka

Реализация раскладки [Wellum 36](https://github.com/braindefender/wellum) для клавиатуры [Lapka](https://github.com/braindefender/lapka)

Эта версия не использует Dongle и состоит из двух частей:
- `lapka_wellum36_left`
- `lapka_wellum36_right`

Чтобы перевести половинку в режим прошивки, нажмите кнопку Reset дважды.

Если вы редактировали настройки или раскладку и хотите обновить прошивку,
существует стабильный способ обнаружения друг другом двух половинок:
1. Подключите левую половинку и прошейте в неё сначала `settings_reset`, затем `lapka_wellum36_left`
2. Подключите правую половинку и прошейте в неё сначала `settings_reset`, затем `lapka_wellum36_right`

# Wellum 36 for Lapka keyboard

This is implementation of [Wellum 36](https://github.com/braindefender/wellum) for [Lapka](https://github.com/braindefender/lapka) keyboard.

This version does not use Dongle and consists of two parts:
- `lapka_wellum36_left`
- `lapka_wellum36_right`

To turn half into bootloader mode, press reset button twice.

If you edit layout and want to flash new firmware, there is a stable way to get both halves to pair:
1. Connect left half and flash `settings_reset` first, then `lapka_wellum36_left`
2. Connect right half and flash `settings_reset` first, then `lapka_wellum36_right`
