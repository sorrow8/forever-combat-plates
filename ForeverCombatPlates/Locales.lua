local _, ns = ...

-- English is the base; a locale table only overrides what it translates.
local L = {
	TITLE = "Forever Combat Plates",
	SUBTITLE = "Enemy nameplates only in combat",

	ENABLED = "Addon enabled",
	ENABLED_HELP = "Off: your own nameplate settings are put back as they were.",

	MODE = "Show enemy nameplates",
	MODE_COMBAT = "In combat",
	MODE_ALWAYS = "Always",
	MODE_NEVER = "Never",

	GROUP = "When my group is in combat",
	GROUP_HELP = "Show them as soon as anyone in your party or raid is fighting, before you are hit.",
	INSTANCES = "Always on in dungeons and raids",
	INSTANCES_HELP = "Inside an instance the nameplates stay on all the time.",
	FRIENDLY = "Friendly players follow combat too",
	FRIENDLY_HELP = "Friendly player nameplates appear and hide together with the enemy ones.",

	DELAY = "Hide after combat",
	DELAY_HELP = "Keeps the nameplates up a little after the fight, so they don't blink between pulls.",
	SECONDS = "%.1f s",
	NOW = "at once",

	RESET = "Reset settings",
	FOOTER = "/fcp opens this window  ·  V shows or hides them by hand until the next fight",

	STATUS_OFF = "Addon is off",
	STATUS_OFF_HINT = "Your own nameplate settings are in use.",
	STATUS_MANUAL_ON = "Shown by hand (V)",
	STATUS_MANUAL_OFF = "Hidden by hand (V)",
	STATUS_MANUAL_HINT = "The next fight hands control back to the addon.",
	STATUS_ALWAYS = "Always shown",
	STATUS_NEVER = "Always hidden",
	STATUS_INSTANCE = "Shown in this instance",
	STATUS_COMBAT = "In combat: shown",
	STATUS_GROUP = "Group in combat: shown",
	STATUS_HOLD = "Hiding in %.1f s",
	STATUS_IDLE = "Out of combat: hidden",
	STATUS_PENDING = "Change applies after combat",
	MODE_HINT_COMBAT = "Appear when the fight starts, hide when it ends.",
	MODE_HINT_STATIC = "Combat does not change them in this mode.",

	MSG_ON = "on.",
	MSG_OFF = "off, your nameplate settings are restored.",
	MSG_RESET = "settings reset.",
	MSG_HELP = "/fcp: window  ·  /fcp on|off  ·  /fcp mode combat|always|never  ·  /fcp reset",
	MSG_NOGROUP = "group combat check is not available on this client, it is switched off.",

	BIND_HEADER = "Forever Combat Plates",
	BIND_WINDOW = "Open settings window",
	BIND_TOGGLE = "Turn the addon on or off",
	OPTIONS_OPEN = "Open the settings window",
	OPTIONS_TEXT = "Every setting lives in the addon's own window.",
}

if GetLocale() == "ruRU" then
	local ru = {
		SUBTITLE = "Индикаторы противников только в бою",

		ENABLED = "Аддон включён",
		ENABLED_HELP = "Выключишь — вернутся твои прежние настройки индикаторов.",

		MODE = "Показывать индикаторы противников",
		MODE_COMBAT = "В бою",
		MODE_ALWAYS = "Всегда",
		MODE_NEVER = "Никогда",

		GROUP = "Когда в бою моя группа",
		GROUP_HELP = "Появляются, как только дерётся кто-то из группы или рейда, ещё до того, как ударили тебя.",
		INSTANCES = "Всегда в подземельях и рейдах",
		INSTANCES_HELP = "Внутри подземелья или рейда индикаторы висят постоянно.",
		FRIENDLY = "Союзные игроки тоже по бою",
		FRIENDLY_HELP = "Индикаторы союзных игроков появляются и прячутся вместе с вражескими.",

		DELAY = "Скрыть после боя через",
		DELAY_HELP = "Индикаторы держатся чуть дольше после боя и не мигают между пулами.",
		SECONDS = "%.1f с",
		NOW = "сразу",

		RESET = "Сбросить настройки",
		FOOTER = "/fcp — это окно  ·  V — показать или скрыть вручную до следующего боя",

		STATUS_OFF = "Аддон выключен",
		STATUS_OFF_HINT = "Работают твои обычные настройки индикаторов.",
		STATUS_MANUAL_ON = "Показаны вручную (V)",
		STATUS_MANUAL_OFF = "Скрыты вручную (V)",
		STATUS_MANUAL_HINT = "Следующий бой вернёт управление аддону.",
		STATUS_ALWAYS = "Показаны всегда",
		STATUS_NEVER = "Скрыты всегда",
		STATUS_INSTANCE = "Показаны в этом подземелье",
		STATUS_COMBAT = "В бою: показаны",
		STATUS_GROUP = "Группа в бою: показаны",
		STATUS_HOLD = "Скрою через %.1f с",
		STATUS_IDLE = "Вне боя: скрыты",
		STATUS_PENDING = "Применится после боя",
		MODE_HINT_COMBAT = "Появляются в начале боя, прячутся после него.",
		MODE_HINT_STATIC = "В этом режиме бой на них не влияет.",

		MSG_ON = "включён.",
		MSG_OFF = "выключен, твои настройки индикаторов возвращены.",
		MSG_RESET = "настройки сброшены.",
		MSG_HELP = "/fcp — окно  ·  /fcp on|off  ·  /fcp mode combat|always|never  ·  /fcp reset",
		MSG_NOGROUP = "проверка боя группы недоступна в этом клиенте, отключил её.",

		BIND_WINDOW = "Открыть окно настроек",
		BIND_TOGGLE = "Включить или выключить аддон",
		OPTIONS_OPEN = "Открыть окно настроек",
		OPTIONS_TEXT = "Все настройки — в собственном окне аддона.",
	}
	for k, v in pairs(ru) do L[k] = v end
end

ns.L = L

BINDING_HEADER_FOREVERCOMBATPLATES = L.BIND_HEADER
BINDING_NAME_FOREVERCOMBATPLATES_WINDOW = L.BIND_WINDOW
BINDING_NAME_FOREVERCOMBATPLATES_TOGGLE = L.BIND_TOGGLE
