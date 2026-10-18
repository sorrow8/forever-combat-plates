# Forever Combat Plates

Enemy nameplates only in combat, the classic way — for **World of Warcraft: Forever** (interface 16001).

Forever's own "(combat)" nameplate mode still shows some units near you out of combat. This addon takes over the enemy nameplate switch: they appear when the fight starts and hide a moment after it ends.

**Nothing to set up.** It doesn't matter whether your enemy nameplates are on or off with V: on login the addon sets them itself (hidden out of combat, shown in combat) and turns on "Always show nameplates" so the game's "(combat)" mode can't show extra units. V keeps working as a manual switch out of combat. Turn the addon off and your previous settings come back.

## Features

- **Show enemy nameplates:** in combat / always / never.
- **Group combat:** nameplates appear as soon as anyone in your party or raid is fighting, before you are hit.
- **Hide delay:** keep them up 0–10 s after combat so they don't blink between pulls.
- **Always on in dungeons and raids** (optional).
- **Friendly players follow combat too** (optional).
- **V still works:** out of combat it shows or hides them by hand; the next fight hands control back to the addon.
- Changes made during combat are applied as soon as it ends (Blizzard locks these settings in combat).
- Turning the addon off puts your own nameplate settings back.
- Settings window in the addon's own style, with a language menu: English, Русский, Deutsch, Français, Español, Português, Italiano, 한국어, 简体中文, 繁體中文. The game's language is used by default; translations beyond English and Russian are machine-made, fixes are welcome.

## Usage

- `/fcp` — open the settings window (also from the addon compartment, Options → AddOns, or a key binding).
- `/fcp on` · `/fcp off` · `/fcp mode combat|always|never` · `/fcp lang auto|en|ru|de|fr|es|pt|it` · `/fcp reset` · `/fcp status`

## Install

Copy the `ForeverCombatPlates` folder into `World of Warcraft/_forever_/Interface/AddOns/` (`_classic_beta_` on the beta client), then restart the game — `/reload` does not load a new addon folder.

## License

MIT, see [LICENSE](LICENSE).

---

# Forever Combat Plates (RU)

Индикаторы здоровья противников только в бою, как в классике, для **World of Warcraft: Forever**.

Встроенный режим «(бой)» в Forever всё равно показывает индикаторы у некоторых мобов рядом вне боя. Аддон сам управляет индикаторами противников: они появляются в начале боя и прячутся чуть позже его окончания.

**Настраивать ничего не нужно.** Неважно, включены у тебя индикаторы противников на V или выключены: при входе в игру аддон выставляет их сам (вне боя скрыты, в бою показаны) и включает «Всегда показывать индикаторы», чтобы встроенный режим «(бой)» не показывал лишних мобов. V работает как ручной переключатель вне боя. Выключишь аддон — вернутся твои прежние настройки.

- Режимы: в бою / всегда / никогда.
- Появляются, когда в бою твоя группа, ещё до того, как ударили тебя.
- Задержка скрытия 0–10 с, чтобы не мигали между пулами.
- По желанию: всегда в подземельях и рейдах, союзные игроки тоже по бою.
- V работает как раньше: вне боя показывает или прячет вручную, следующий бой возвращает управление аддону.
- Выключишь аддон — вернутся твои прежние настройки.

Окно настроек: `/fcp`. Язык берётся из клиента игры, в углу окна есть меню выбора языка.
