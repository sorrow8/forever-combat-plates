local _, ns = ...

ns.LOCALES.deDE = {
	SUBTITLE = "Gegnerische Namensplaketten nur im Kampf",

	ENABLED = "Addon aktiviert",
	ENABLED_HELP = "Aus: Deine eigenen Namensplaketten-Einstellungen werden wiederhergestellt.",

	MODE = "Gegnerische Namensplaketten anzeigen",
	MODE_COMBAT = "Im Kampf",
	MODE_ALWAYS = "Immer",
	MODE_NEVER = "Nie",

	GROUP = "Wenn meine Gruppe kämpft",
	GROUP_HELP = "Erscheinen, sobald jemand in deiner Gruppe oder deinem Schlachtzug kämpft, noch bevor du getroffen wirst.",
	INSTANCES = "In Dungeons und Schlachtzügen immer an",
	INSTANCES_HELP = "In einer Instanz bleiben die Namensplaketten die ganze Zeit sichtbar.",
	FRIENDLY = "Freundliche Spieler folgen auch dem Kampf",
	FRIENDLY_HELP = "Namensplaketten freundlicher Spieler erscheinen und verschwinden zusammen mit den gegnerischen.",

	DELAY = "Nach dem Kampf ausblenden",
	DELAY_HELP = "Hält die Namensplaketten nach dem Kampf etwas länger sichtbar, damit sie zwischen Pulls nicht flackern.",
	SECONDS = "%.1f s",
	NOW = "sofort",

	RESET = "Zurücksetzen",
	CMD_HINT = "Dieses Fenster öffnen:",
	MINIMAP = "Minikarten-Button",
	MINIMAP_HELP = "Zeigt den Button des Addons am Rand der Minikarte.",
	MM_LEFT = "Linksklick: Einstellungen",
	MM_RIGHT = "Rechtsklick: ein- oder ausschalten",
	MM_DRAG = "Ziehen: um die Minikarte verschieben",
	FOOTER = "/fcp öffnet dieses Fenster.\nV blendet sie bis zum nächsten Kampf manuell ein oder aus.",
	LANG_AUTO = "Auto",

	STATUS_OFF = "Addon ist aus",
	STATUS_OFF_HINT = "Deine eigenen Namensplaketten-Einstellungen sind aktiv.",
	STATUS_MANUAL_ON = "Manuell eingeblendet (V)",
	STATUS_MANUAL_HINT = "Der nächste Kampf gibt die Kontrolle an das Addon zurück.",
	STATUS_ALWAYS = "Immer sichtbar",
	STATUS_NEVER = "Immer ausgeblendet",
	STATUS_INSTANCE = "In dieser Instanz sichtbar",
	STATUS_COMBAT = "Im Kampf: sichtbar",
	STATUS_GROUP = "Gruppe im Kampf: sichtbar",
	STATUS_HOLD = "Ausblenden in %.1f s",
	STATUS_IDLE = "Außerhalb des Kampfes: ausgeblendet",
	STATUS_PENDING = "Wird nach dem Kampf übernommen",
	MODE_HINT_COMBAT = "Erscheinen, wenn der Kampf beginnt, und verschwinden, wenn er endet.",
	MODE_HINT_STATIC = "In diesem Modus ändert der Kampf nichts.",

	MSG_WELCOME = "installiert. Gegnerische Namensplaketten jetzt nur im Kampf. Einstellungen: |cffebbd61/fcp|r",
	MSG_LOADED = "geladen. Einstellungen: |cffebbd61/fcp|r",
	MSG_ON = "an.",
	MSG_OFF = "aus, deine Namensplaketten-Einstellungen sind wiederhergestellt.",
	MSG_RESET = "Einstellungen zurückgesetzt.",
	MSG_NOGROUP = "die Prüfung auf Gruppenkampf ist auf diesem Client nicht verfügbar und wurde ausgeschaltet.",

	BIND_WINDOW = "Einstellungsfenster öffnen",
	BIND_TOGGLE = "Addon ein- oder ausschalten",
	OPTIONS_OPEN = "Einstellungsfenster öffnen",
	OPTIONS_TEXT = "Alle Einstellungen sind im eigenen Fenster des Addons.",
}
