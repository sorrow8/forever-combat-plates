local _, ns = ...

-- Also used by the Latin American client (esMX).
ns.LOCALES.esES = {
	SUBTITLE = "Placas de nombre enemigas solo en combate",

	ENABLED = "Addon activado",
	ENABLED_HELP = "Desactivado: se restauran tus propios ajustes de placas.",

	MODE = "Mostrar placas de nombre enemigas",
	MODE_COMBAT = "En combate",
	MODE_ALWAYS = "Siempre",
	MODE_NEVER = "Nunca",

	GROUP = "Cuando mi grupo está en combate",
	GROUP_HELP = "Aparecen en cuanto alguien de tu grupo o banda pelea, antes de que te golpeen.",
	INSTANCES = "Siempre en mazmorras y bandas",
	INSTANCES_HELP = "Dentro de una instancia las placas se quedan visibles todo el tiempo.",
	FRIENDLY = "Los aliados también siguen el combate",
	FRIENDLY_HELP = "Las placas de los jugadores aliados aparecen y se ocultan junto con las enemigas.",

	DELAY = "Ocultar tras el combate",
	DELAY_HELP = "Mantiene las placas un poco después del combate para que no parpadeen entre pulls.",
	SECONDS = "%.1f s",
	NOW = "al instante",

	RESET = "Restablecer",
	CMD_HINT = "Abrir esta ventana:",
	FOOTER = "/fcp abre esta ventana.\nV las muestra u oculta a mano hasta el siguiente combate.",
	LANG_AUTO = "Auto",

	STATUS_OFF = "Addon desactivado",
	STATUS_OFF_HINT = "Se usan tus propios ajustes de placas.",
	STATUS_MANUAL_ON = "Mostradas a mano (V)",
	STATUS_MANUAL_HINT = "El siguiente combate devuelve el control al addon.",
	STATUS_ALWAYS = "Siempre visibles",
	STATUS_NEVER = "Siempre ocultas",
	STATUS_INSTANCE = "Visibles en esta instancia",
	STATUS_COMBAT = "En combate: visibles",
	STATUS_GROUP = "Grupo en combate: visibles",
	STATUS_HOLD = "Se ocultan en %.1f s",
	STATUS_IDLE = "Fuera de combate: ocultas",
	STATUS_PENDING = "Se aplicará tras el combate",
	MODE_HINT_COMBAT = "Aparecen al empezar el combate y se ocultan al terminar.",
	MODE_HINT_STATIC = "En este modo el combate no las cambia.",

	MSG_WELCOME = "instalado. Las placas enemigas ahora solo aparecen en combate. Ajustes: |cffebbd61/fcp|r",
	MSG_ON = "activado.",
	MSG_OFF = "desactivado, tus ajustes de placas están restaurados.",
	MSG_RESET = "ajustes restablecidos.",
	MSG_NOGROUP = "la detección del combate de grupo no está disponible en este cliente; se ha desactivado.",

	BIND_WINDOW = "Abrir la ventana de ajustes",
	BIND_TOGGLE = "Activar o desactivar el addon",
	OPTIONS_OPEN = "Abrir la ventana de ajustes",
	OPTIONS_TEXT = "Todos los ajustes están en la ventana propia del addon.",
}
