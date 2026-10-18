local _, ns = ...

ns.LOCALES.zhCN = {

	ENABLED = "启用插件",
	ENABLED_HELP = "关闭后会恢复你原来的姓名板设置。",

	MODE = "显示敌方姓名板",
	MODE_COMBAT = "战斗中",
	MODE_ALWAYS = "总是",
	MODE_NEVER = "从不",

	GROUP = "队伍进入战斗时",
	GROUP_HELP = "只要小队或团队中有人开战就立即显示，不必等你被攻击。",
	INSTANCES = "地下城和团队副本中总是显示",
	INSTANCES_HELP = "在副本内姓名板会一直显示。",
	FRIENDLY = "友方玩家也随战斗显示",
	FRIENDLY_HELP = "友方玩家的姓名板与敌方一起显示和隐藏。",
	HOSTILE = "敌对怪物名字",
	HOSTILE_HELP = "在敌对怪物头上显示红色名字，距离由游戏决定。中立（黄色）怪物不显示名字。",

	DELAY = "战斗结束后隐藏",
	DELAY_HELP = "战斗结束后再保留片刻，避免在两次拉怪之间闪烁。",
	SECONDS = "%.1f 秒",
	NOW = "立即",

	RESET = "重置设置",
	CMD_HINT = "打开此窗口：",
	MINIMAP = "小地图按钮",
	MINIMAP_HELP = "在小地图边缘显示插件按钮。",
	MM_LEFT = "左键：设置",
	MM_RIGHT = "右键：启用或关闭",
	MM_DRAG = "拖动：沿小地图移动",
	FOOTER = "/fcp 打开此窗口\nV 在下次战斗前手动显示或隐藏",

	STATUS_OFF = "插件已关闭",
	STATUS_OFF_HINT = "正在使用你自己的姓名板设置。",
	STATUS_MANUAL_ON = "已手动显示 (V)",
	STATUS_MANUAL_HINT = "下次战斗开始后由插件重新接管。",
	STATUS_ALWAYS = "总是显示",
	STATUS_NEVER = "总是隐藏",
	STATUS_INSTANCE = "在此副本中显示",
	STATUS_COMBAT = "战斗中：显示",
	STATUS_GROUP = "队伍战斗中：显示",
	STATUS_HOLD = "%.1f 秒后隐藏",
	STATUS_IDLE = "非战斗：隐藏",
	STATUS_PENDING = "战斗结束后生效",
	MODE_HINT_COMBAT = "战斗开始时出现，结束后隐藏。",
	MODE_HINT_STATIC = "此模式下不受战斗影响。",

	MSG_WELCOME = "已安装。现在敌方姓名板只在战斗中显示。设置：|cffebbd61/fcp|r",
	MSG_LOADED = "已加载。设置：|cffebbd61/fcp|r",
	MSG_HELP = "/fcp 打开窗口，/fcp on，/fcp off，/fcp toggle，/fcp status，/fcp mode combat/always/never，/fcp lang auto/en/zh，/fcp reset",
	MSG_ON = "已启用。",
	MSG_OFF = "已关闭，已恢复你的姓名板设置。",
	MSG_RESET = "设置已重置。",
	MSG_NOGROUP = "此客户端无法检测队伍战斗状态，已关闭该选项。",

	BIND_WINDOW = "打开设置窗口",
	BIND_TOGGLE = "启用或关闭插件",
	OPTIONS_OPEN = "打开设置窗口",
	OPTIONS_TEXT = "所有设置都在插件自己的窗口中。",
}
