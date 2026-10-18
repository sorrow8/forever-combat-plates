local _, ns = ...

ns.LOCALES.itIT = {

	ENABLED = "Addon attivo",
	ENABLED_HELP = "Disattivato: vengono ripristinate le tue impostazioni delle barre.",

	MODE = "Mostra le barre dei nemici",
	MODE_COMBAT = "In combatt.",
	MODE_ALWAYS = "Sempre",
	MODE_NEVER = "Mai",

	GROUP = "Quando il mio gruppo combatte",
	GROUP_HELP = "Compaiono appena qualcuno del gruppo o dell'incursione combatte, prima che tu venga colpito.",
	INSTANCES = "Sempre in spedizioni e incursioni",
	INSTANCES_HELP = "Dentro un'istanza le barre restano sempre visibili.",
	FRIENDLY = "Anche gli alleati seguono il combattimento",
	FRIENDLY_HELP = "Le barre dei giocatori alleati compaiono e spariscono insieme a quelle nemiche.",

	DELAY = "Nascondi dopo il combattimento",
	DELAY_HELP = "Tiene le barre ancora un attimo dopo lo scontro, così non lampeggiano tra un pull e l'altro.",
	SECONDS = "%.1f s",
	NOW = "subito",

	RESET = "Ripristina",
	CMD_HINT = "Apri questa finestra:",
	MINIMAP = "Pulsante della minimappa",
	MINIMAP_HELP = "Mostra il pulsante dell'addon sul bordo della minimappa.",
	MM_LEFT = "Clic sinistro: impostazioni",
	MM_RIGHT = "Clic destro: attiva o disattiva",
	MM_DRAG = "Trascina: sposta intorno alla minimappa",
	FOOTER = "/fcp apre questa finestra.\nV le mostra o nasconde a mano fino al prossimo combattimento.",

	STATUS_OFF = "Addon disattivato",
	STATUS_OFF_HINT = "Sono in uso le tue impostazioni delle barre.",
	STATUS_MANUAL_ON = "Mostrate a mano (V)",
	STATUS_MANUAL_HINT = "Il prossimo combattimento restituisce il controllo all'addon.",
	STATUS_ALWAYS = "Sempre visibili",
	STATUS_NEVER = "Sempre nascoste",
	STATUS_INSTANCE = "Visibili in questa istanza",
	STATUS_COMBAT = "In combattimento: visibili",
	STATUS_GROUP = "Gruppo in combattimento: visibili",
	STATUS_HOLD = "Nascoste tra %.1f s",
	STATUS_IDLE = "Fuori combattimento: nascoste",
	STATUS_PENDING = "Si applica dopo il combattimento",
	MODE_HINT_COMBAT = "Compaiono all'inizio dello scontro e spariscono alla fine.",
	MODE_HINT_STATIC = "In questa modalità il combattimento non le cambia.",

	MSG_WELCOME = "installato. Le barre dei nemici ora compaiono solo in combattimento. Impostazioni: |cffebbd61/fcp|r",
	MSG_LOADED = "caricato. Impostazioni: |cffebbd61/fcp|r",
	MSG_HELP = "/fcp apre la finestra, /fcp on, /fcp off, /fcp toggle, /fcp status, /fcp mode combat/always/never, /fcp lang auto/en/ru/de/fr/es/pt/it, /fcp reset",
	MSG_ON = "attivo.",
	MSG_OFF = "disattivato, le tue impostazioni delle barre sono state ripristinate.",
	MSG_RESET = "impostazioni ripristinate.",
	MSG_NOGROUP = "il controllo del combattimento di gruppo non è disponibile su questo client ed è stato disattivato.",

	BIND_WINDOW = "Apri la finestra delle impostazioni",
	BIND_TOGGLE = "Attiva o disattiva l'addon",
	OPTIONS_OPEN = "Apri la finestra delle impostazioni",
	OPTIONS_TEXT = "Tutte le impostazioni sono nella finestra dell'addon.",
}
