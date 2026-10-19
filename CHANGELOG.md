# 1.3.7

- The minimap button stays where a minimap button collector (like Leatrix Plus) put it: it was put back on the minimap's edge at every fight.
- Hide names of grey and green mobs: levels are compared the way the game colours them (effective level), so level-scaled places are right too.
- Hidden plates of grey, green and neutral mobs no longer show the target highlight or the soft target and behind-camera marks.
- The status line says "Out of combat: names only" while the plates show only names.
- Turning the option off gives your NPC name settings back even when the game reports a change twice; a value 1.3.3 could save as yours is put back to the game's default once.
- A plate the game takes back is cleaned up at once; mobs changing faction and quest updates restyle only what they need.

# 1.3.6

- The minimap button is made with LibDBIcon now, so minimap button collectors (like Leatrix Plus) take it in with its own tooltip instead of a placeholder. The tooltip is shorter: the addon's name, left-click and right-click.

# 1.3.5

- Hide names of grey and green mobs: the name near a mob sits right over its head like the game's own, no longer higher by the hidden health bar.

# 1.3.4

- Hide names of grey and green mobs: near a mob the name now looks like the game's own: the game's unit name font, its red, and the mob's title (<Cult of the Damned>) under the name. The plates are no longer told to force their names (1.3.3 did), and that setting goes back to yours.
- Fix: when the game reported a name setting change twice, the addon could save its own values as yours, so turning the option off didn't give your settings back.

# 1.3.3

- Hide names of grey and green mobs: a new switch under Names of hostile mobs. Out of combat the names come from the enemy nameplates, shown as names only, and mobs with a grey or green level get none. Mobs of your active quests always keep their red name. In combat the plates are whole again, and V out of combat switches between names only and whole plates.

# 1.3.2

- A group pull is noticed at once from the game's UNIT_FLAGS event instead of a check twice a second; a slow check every 2 s stays as a safety net.
- A nameplate setting the game refuses to change no longer makes the addon ignore your next V press.

# 1.3.1

- Names of hostile mobs also turns off the game's "all NPC names", so neutral mobs really stay without a name whatever the game's NPC names setting is. Both values come back when the option is off.
- A change you make to NPC names in the game's settings while the option is on is the one that comes back when you turn it off.
- The status line says when a hostile names change waits for the fight to end.
- If the game showed all NPC names, friendly and quest NPCs keep their names with the option on; only neutral mobs lose theirs. Settings saved by 1.3.0 are completed instead of losing the all-NPC names value.
- Picking NPC names in the game's settings while the option is on saves that whole choice for later.
- With "Friendly players follow combat" on, V moves friendly plates together with the enemy ones.
- The status line tells the truth when V hid the plates in a dungeon, while a change waits after turning the addon off in combat, and while friendly plates wait to come back; "settings restored" is said once they really are.
- Turning the addon back on long after a fight no longer flashes the plates for the hold delay.
- Nothing is changed before login, so the saved values are always the player's own.
- A saved Korean or Chinese language is ignored on a client without those fonts; /fcp lang with the client's own language keeps following the client.

# 1.3.0

- Names of hostile mobs: a switch in the window shows red names over hostile mobs only (neutral ones stay without a name), at the game's own distance. Turned off, your own setting comes back.

# 1.2.2

- V pressed outside no longer carries into a dungeon (or back out): changing between the open world and a dungeon hands the nameplates back to your settings.
- Friendly player nameplates are only touched while "Friendly players follow combat" is on: their value is saved when the option takes them over and put back when it lets go. A value you change in the game settings meanwhile is no longer overwritten when the addon is turned off.
- Reset settings puts your friendly nameplates back instead of leaving them hidden.
- Turned off during a fight and left the game before it ended: your nameplate settings come back at the next login.
- The status no longer says "change applies after combat" during group fights when nothing is waiting.
- V hides the nameplates in a dungeon with "Always on in dungeons" until the next fight, as the window says.
- /fcp lang only accepts Korean and Chinese on clients that have those fonts.
- The game's Options page follows the language picked in the window.
- /fcp help lists toggle and status in every language.

# 1.2.1

- Settings line on every login: "loaded. Settings: /fcp".
- Fix: switching "Friendly players follow combat" off during a fight now puts your own friendly nameplate setting back once the fight ends.

# 1.2.0

- Minimap button: left-click opens the settings, right-click turns the addon on or off, drag to move it; can be hidden in the window.
- Compact window: on/off in the header, help in tooltips, the same size in every language.

# 1.1.0

- Translations: German, French, Spanish, Portuguese, Italian, Korean, Simplified and Traditional Chinese.
- Language menu in the window corner and /fcp lang.
- First run: chat line with /fcp and the window opens once.
- Status colours: in combat green, always red, never grey.
- Fixes: close button, missing glyphs.

# 1.0.0

- First release: enemy nameplates only in combat, group combat, hide delay, instance and friendly options, settings window (ru/en).
