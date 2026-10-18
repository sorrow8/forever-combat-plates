local _, ns = ...

ns.LOCALES.ptBR = {
	SUBTITLE = "Placas de nome inimigas só em combate",

	ENABLED = "Addon ativado",
	ENABLED_HELP = "Desligado: suas próprias configurações de placas são restauradas.",

	MODE = "Mostrar placas de nome inimigas",
	MODE_COMBAT = "Em combate",
	MODE_ALWAYS = "Sempre",
	MODE_NEVER = "Nunca",

	GROUP = "Quando meu grupo está em combate",
	GROUP_HELP = "Aparecem assim que alguém do grupo ou da raide entra em luta, antes de você ser atingido.",
	INSTANCES = "Sempre em masmorras e raides",
	INSTANCES_HELP = "Dentro de uma instância as placas ficam visíveis o tempo todo.",
	FRIENDLY = "Aliados também seguem o combate",
	FRIENDLY_HELP = "As placas dos jogadores aliados aparecem e somem junto com as inimigas.",

	DELAY = "Ocultar após o combate",
	DELAY_HELP = "Mantém as placas um pouco depois da luta para não piscarem entre pulls.",
	SECONDS = "%.1f s",
	NOW = "na hora",

	RESET = "Redefinir",
	CMD_HINT = "Abrir esta janela:",
	MINIMAP = "Botão do minimapa",
	MINIMAP_HELP = "Mostra o botão do addon na borda do minimapa.",
	MM_LEFT = "Clique esquerdo: configurações",
	MM_RIGHT = "Clique direito: ligar ou desligar",
	MM_DRAG = "Arrastar: mover ao redor do minimapa",
	FOOTER = "/fcp abre esta janela.\nV mostra ou oculta manualmente até o próximo combate.",
	LANG_AUTO = "Auto",

	STATUS_OFF = "Addon desligado",
	STATUS_OFF_HINT = "Suas próprias configurações de placas estão em uso.",
	STATUS_MANUAL_ON = "Mostradas manualmente (V)",
	STATUS_MANUAL_HINT = "O próximo combate devolve o controle ao addon.",
	STATUS_ALWAYS = "Sempre visíveis",
	STATUS_NEVER = "Sempre ocultas",
	STATUS_INSTANCE = "Visíveis nesta instância",
	STATUS_COMBAT = "Em combate: visíveis",
	STATUS_GROUP = "Grupo em combate: visíveis",
	STATUS_HOLD = "Ocultando em %.1f s",
	STATUS_IDLE = "Fora de combate: ocultas",
	STATUS_PENDING = "Aplica após o combate",
	MODE_HINT_COMBAT = "Aparecem quando a luta começa e somem quando acaba.",
	MODE_HINT_STATIC = "Neste modo o combate não muda nada.",

	MSG_WELCOME = "instalado. As placas inimigas agora só aparecem em combate. Configurações: |cffebbd61/fcp|r",
	MSG_LOADED = "carregado. Configurações: digite |cffebbd61/fcp|r",
	MSG_ON = "ligado.",
	MSG_OFF = "desligado, suas configurações de placas foram restauradas.",
	MSG_RESET = "configurações redefinidas.",
	MSG_NOGROUP = "a verificação de combate do grupo não está disponível neste cliente e foi desligada.",

	BIND_WINDOW = "Abrir janela de configurações",
	BIND_TOGGLE = "Ligar ou desligar o addon",
	OPTIONS_OPEN = "Abrir janela de configurações",
	OPTIONS_TEXT = "Todas as configurações ficam na janela do próprio addon.",
}
