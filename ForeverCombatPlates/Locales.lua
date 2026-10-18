local _, ns = ...

-- English is the base; a locale file (Locales/*.lua) only overrides what it
-- translates. The game's language is used unless one is picked in the
-- window's language menu or with /fcp lang.
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
	CMD_HINT = "Open this window:",
	FOOTER = "/fcp opens this window.\nV shows or hides them by hand until the next fight.",
	LANG_AUTO = "Auto",

	STATUS_OFF = "Addon is off",
	STATUS_OFF_HINT = "Your own nameplate settings are in use.",
	STATUS_MANUAL_ON = "Shown by hand (V)",
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

	MSG_WELCOME = "installed. Enemy nameplates now show only in combat. Settings: type |cffebbd61/fcp|r",
	MSG_ON = "on.",
	MSG_OFF = "off, your nameplate settings are restored.",
	MSG_RESET = "settings reset.",
	MSG_HELP = "/fcp: window, /fcp on, /fcp off, /fcp mode combat/always/never, /fcp lang auto/en/ru/de/fr/es/pt/it, /fcp reset",
	MSG_NOGROUP = "group combat check is not available on this client, it is switched off.",

	BIND_HEADER = "Forever Combat Plates",
	BIND_WINDOW = "Open settings window",
	BIND_TOGGLE = "Turn the addon on or off",
	OPTIONS_OPEN = "Open the settings window",
	OPTIONS_TEXT = "Every setting lives in the addon's own window.",
}

ns.LOCALES = {}

-- The language menu. CJK fonts exist only on CJK clients, so those entries
-- are offered only on their own client; everything else reads on all of them.
ns.LANGUAGES = {
	{ code = "enUS", short = "en", name = "English" },
	{ code = "ruRU", short = "ru", name = "Русский" },
	{ code = "deDE", short = "de", name = "Deutsch" },
	{ code = "frFR", short = "fr", name = "Français" },
	{ code = "esES", short = "es", name = "Español" },
	{ code = "ptBR", short = "pt", name = "Português" },
	{ code = "itIT", short = "it", name = "Italiano" },
	{ code = "koKR", short = "ko", name = "한국어", cjk = true },
	{ code = "zhCN", short = "zh", name = "简体中文", cjk = true },
	{ code = "zhTW", short = "tw", name = "繁體中文", cjk = true },
}

function ns.LanguageAvailable(lang)
	return not lang.cjk or GetLocale() == lang.code
end

-- "deDE" or "de" -> "deDE"; nil, "auto" or anything unknown -> nil.
function ns.LanguageCode(choice)
	if type(choice) ~= "string" then return nil end
	choice = choice:lower()
	for _, lang in ipairs(ns.LANGUAGES) do
		if choice == lang.short or choice == lang.code:lower() then return lang.code end
	end
end

local EN = {}
for k, v in pairs(L) do EN[k] = v end

-- The game's language as one of ns.LANGUAGES' codes.
function ns.ClientLocale()
	local code = GetLocale()
	if code == "esMX" then return "esES" end
	if code == "enGB" then return "enUS" end
	return code
end

-- The table stays the same object, so every file holding ns.L sees the change.
function ns.ApplyLocale(choice)
	local code = ns.LanguageCode(choice) or ns.ClientLocale()
	for k, v in pairs(EN) do L[k] = v end
	local over = ns.LOCALES[code]
	if over then
		for k, v in pairs(over) do L[k] = v end
	end
	ns.activeLocale = over and code or "enUS"
	BINDING_HEADER_FOREVERCOMBATPLATES = L.BIND_HEADER
	BINDING_NAME_FOREVERCOMBATPLATES_WINDOW = L.BIND_WINDOW
	BINDING_NAME_FOREVERCOMBATPLATES_TOGGLE = L.BIND_TOGGLE
end

ns.L = L
