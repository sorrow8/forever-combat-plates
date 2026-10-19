local _, ns = ...

ns.LOCALES.zhTW = {

	ENABLED = "啟用插件",
	ENABLED_HELP = "關閉後會恢復你原本的名條設定。",

	MODE = "顯示敵方名條",
	MODE_COMBAT = "戰鬥中",
	MODE_ALWAYS = "總是",
	MODE_NEVER = "從不",

	GROUP = "隊伍進入戰鬥時",
	GROUP_HELP = "只要小隊或團隊中有人開戰就立即顯示，不必等你被攻擊。",
	INSTANCES = "地城與團隊副本中總是顯示",
	INSTANCES_HELP = "在副本內名條會一直顯示。",
	FRIENDLY = "友方玩家也隨戰鬥顯示",
	FRIENDLY_HELP = "友方玩家的名條與敵方一起顯示和隱藏。",
	HOSTILE = "敵對怪物名字",
	HOSTILE_HELP = "在敵對怪物頭上顯示紅色名字，距離由遊戲決定。中立（黃色）怪物不顯示名字。",
	TRIVIAL = "隱藏灰色和綠色怪物的名字",
	TRIVIAL_HELP = "脫離戰鬥時名字由名條顯示，灰色或綠色等級的怪物不顯示名字。目前任務的怪物始終保留紅色名字。",

	DELAY = "戰鬥結束後隱藏",
	DELAY_HELP = "戰鬥結束後再保留片刻，避免在兩次拉怪之間閃爍。",
	SECONDS = "%.1f 秒",
	NOW = "立即",

	RESET = "重置設定",
	CMD_HINT = "開啟此視窗：",
	MINIMAP = "小地圖按鈕",
	MINIMAP_HELP = "在小地圖邊緣顯示插件按鈕。",
	MM_LEFT = "左鍵：設定",
	MM_RIGHT = "右鍵：啟用或關閉",
	FOOTER = "/fcp 開啟此視窗\nV 在下次戰鬥前手動顯示或隱藏",

	STATUS_OFF = "插件已關閉",
	STATUS_OFF_HINT = "正在使用你自己的名條設定。",
	STATUS_MANUAL_ON = "已手動顯示 (V)",
	STATUS_MANUAL_HINT = "下次戰鬥開始後由插件重新接管。",
	STATUS_ALWAYS = "總是顯示",
	STATUS_NEVER = "總是隱藏",
	STATUS_INSTANCE = "在此副本中顯示",
	STATUS_COMBAT = "戰鬥中：顯示",
	STATUS_GROUP = "隊伍戰鬥中：顯示",
	STATUS_HOLD = "%.1f 秒後隱藏",
	STATUS_IDLE = "非戰鬥：隱藏",
	STATUS_PENDING = "戰鬥結束後生效",
	MODE_HINT_COMBAT = "戰鬥開始時出現，結束後隱藏。",
	MODE_HINT_STATIC = "此模式下不受戰鬥影響。",

	MSG_WELCOME = "已安裝。現在敵方名條只在戰鬥中顯示。設定：|cffebbd61/fcp|r",
	MSG_LOADED = "已載入。設定：|cffebbd61/fcp|r",
	MSG_HELP = "/fcp 開啟視窗，/fcp on，/fcp off，/fcp toggle，/fcp status，/fcp mode combat/always/never，/fcp lang auto/en/tw，/fcp reset",
	MSG_ON = "已啟用。",
	MSG_OFF = "已關閉，已恢復你的名條設定。",
	MSG_RESET = "設定已重置。",
	MSG_NOGROUP = "此用戶端無法偵測隊伍戰鬥狀態，已關閉該選項。",

	BIND_WINDOW = "開啟設定視窗",
	BIND_TOGGLE = "啟用或關閉插件",
	OPTIONS_OPEN = "開啟設定視窗",
	OPTIONS_TEXT = "所有設定都在插件自己的視窗中。",
}
