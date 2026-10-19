local _, ns = ...

ns.LOCALES.frFR = {

	ENABLED = "Addon activé",
	ENABLED_HELP = "Désactivé : vos propres réglages des barres de vie sont rétablis.",

	MODE = "Afficher les barres de vie ennemies",
	MODE_COMBAT = "En combat",
	MODE_ALWAYS = "Toujours",
	MODE_NEVER = "Jamais",

	GROUP = "Quand mon groupe est en combat",
	GROUP_HELP = "Elles apparaissent dès qu'un membre du groupe ou du raid combat, avant même que vous soyez touché.",
	INSTANCES = "Toujours en donjon et en raid",
	INSTANCES_HELP = "Dans une instance, les barres de vie restent affichées en permanence.",
	FRIENDLY = "Les joueurs alliés suivent aussi le combat",
	FRIENDLY_HELP = "Les barres de vie des joueurs alliés apparaissent et disparaissent avec celles des ennemis.",
	HOSTILE = "Noms des monstres hostiles",
	HOSTILE_HELP = "Noms rouges au-dessus des monstres hostiles, à la distance du jeu. Les monstres neutres (jaunes) restent sans nom.",
	TRIVIAL = "Masquer les noms des monstres gris et verts",
	TRIVIAL_HELP = "Hors combat, les noms viennent des barres de nom et les monstres de niveau gris ou vert n'en ont pas. Les monstres de vos quêtes actives gardent toujours leur nom rouge.",

	DELAY = "Masquer après le combat",
	DELAY_HELP = "Garde les barres un peu après le combat pour qu'elles ne clignotent pas entre les pulls.",
	SECONDS = "%.1f s",
	NOW = "aussitôt",

	RESET = "Réinitialiser",
	CMD_HINT = "Ouvrir cette fenêtre :",
	MINIMAP = "Bouton de la minicarte",
	MINIMAP_HELP = "Affiche le bouton de l'addon au bord de la minicarte.",
	MM_LEFT = "Clic gauche : réglages",
	MM_RIGHT = "Clic droit : activer ou désactiver",
	FOOTER = "/fcp ouvre cette fenêtre.\nV les affiche ou les masque à la main jusqu'au prochain combat.",

	STATUS_OFF = "Addon désactivé",
	STATUS_OFF_HINT = "Vos propres réglages des barres de vie sont utilisés.",
	STATUS_MANUAL_ON = "Affichées à la main (V)",
	STATUS_MANUAL_HINT = "Le prochain combat rend la main à l'addon.",
	STATUS_ALWAYS = "Toujours affichées",
	STATUS_NEVER = "Toujours masquées",
	STATUS_INSTANCE = "Affichées dans cette instance",
	STATUS_COMBAT = "En combat : affichées",
	STATUS_GROUP = "Groupe en combat : affichées",
	STATUS_HOLD = "Masquées dans %.1f s",
	STATUS_IDLE = "Hors combat : masquées",
	STATUS_PENDING = "Appliqué après le combat",
	MODE_HINT_COMBAT = "Apparaissent au début du combat, disparaissent à la fin.",
	MODE_HINT_STATIC = "Le combat ne les change pas dans ce mode.",

	MSG_WELCOME = "installé. Les barres de vie ennemies n'apparaissent plus qu'en combat. Réglages : |cffebbd61/fcp|r",
	MSG_LOADED = "chargé. Réglages : |cffebbd61/fcp|r",
	MSG_HELP = "/fcp ouvre la fenêtre, /fcp on, /fcp off, /fcp toggle, /fcp status, /fcp mode combat/always/never, /fcp lang auto/en/ru/de/fr/es/pt/it, /fcp reset",
	MSG_ON = "activé.",
	MSG_OFF = "désactivé, vos réglages des barres de vie sont rétablis.",
	MSG_RESET = "réglages réinitialisés.",
	MSG_NOGROUP = "la détection du combat de groupe n'est pas disponible sur ce client, elle est désactivée.",

	BIND_WINDOW = "Ouvrir la fenêtre des réglages",
	BIND_TOGGLE = "Activer ou désactiver l'addon",
	OPTIONS_OPEN = "Ouvrir la fenêtre des réglages",
	OPTIONS_TEXT = "Tous les réglages sont dans la fenêtre de l'addon.",
}
