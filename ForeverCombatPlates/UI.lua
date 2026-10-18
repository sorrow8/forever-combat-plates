local ADDON, ns = ...
local L = ns.L

-- The settings window: one dark panel with a gold accent, built from plain
-- colour textures so it needs no Blizzard templates. /fcp, the key binding,
-- the addon compartment and the game's Options all open it.

local WIDTH = 380
local PAD = 18
local INNER = WIDTH - PAD * 2

local C = {
	bg = { 0.071, 0.086, 0.133, 0.97 },
	panel = { 0.106, 0.125, 0.192, 1 },
	raised = { 0.145, 0.170, 0.255, 1 },
	hover = { 0.185, 0.215, 0.315, 1 },
	line = { 1, 1, 1, 0.07 },
	text = { 0.96, 0.97, 0.99, 1 },
	dim = { 0.71, 0.74, 0.82, 1 },
	muted = { 0.52, 0.56, 0.65, 1 },
	accent = { 0.92, 0.74, 0.38, 1 },
	onAccent = { 0.06, 0.07, 0.10, 1 },
	on = { 0.42, 0.85, 0.60, 1 },
	warn = { 0.98, 0.75, 0.30, 1 },
	off = { 0.55, 0.59, 0.68, 1 },
	danger = { 0.96, 0.45, 0.45, 1 },
}
local STATUS_COLOR = { on = C.on, warn = C.warn, off = C.off, accent = C.accent, danger = C.danger }

local win
local widgets = {}

-- Helpers ----------------------------------------------------------------

local function Tex(parent, color, layer)
	local t = parent:CreateTexture(nil, layer or "BACKGROUND")
	t:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
	return t
end

local function Paint(t, color)
	t:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
end

local function Border(frame, color)
	local edges = {}
	for i, spec in ipairs({
		{ "TOPLEFT", "TOPRIGHT", true }, { "BOTTOMLEFT", "BOTTOMRIGHT", true },
		{ "TOPLEFT", "BOTTOMLEFT", false }, { "TOPRIGHT", "BOTTOMRIGHT", false },
	}) do
		local t = Tex(frame, color, "BORDER")
		t:SetPoint(spec[1])
		t:SetPoint(spec[2])
		if spec[3] then t:SetHeight(1) else t:SetWidth(1) end
		edges[i] = t
	end
	return edges
end

local function Text(parent, template, color, width)
	local fs = parent:CreateFontString(nil, "OVERLAY", template)
	fs:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	fs:SetJustifyH("LEFT")
	if width then
		fs:SetWidth(width)
		fs:SetWordWrap(true)
	end
	return fs
end

local function SetTextColor(fs, color)
	fs:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

-- Switch -------------------------------------------------------------------

local function Switch(parent, onToggle)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(36, 18)
	b.track = Tex(b, C.raised, "ARTWORK")
	b.track:SetAllPoints()
	b.knob = Tex(b, C.text, "OVERLAY")
	b.knob:SetSize(14, 14)
	b.checked = false

	function b:SetChecked(on)
		self.checked = on and true or false
		self.knob:ClearAllPoints()
		if self.checked then
			self.knob:SetPoint("RIGHT", -2, 0)
			Paint(self.track, C.accent)
			Paint(self.knob, C.onAccent)
		else
			self.knob:SetPoint("LEFT", 2, 0)
			Paint(self.track, self:IsMouseOver() and C.hover or C.raised)
			Paint(self.knob, C.dim)
		end
	end

	b:SetScript("OnClick", function(self)
		if PlaySound and SOUNDKIT then pcall(PlaySound, SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end
		onToggle(not self.checked)
	end)
	b:SetScript("OnEnter", function(self) if not self.checked then Paint(self.track, C.hover) end end)
	b:SetScript("OnLeave", function(self) if not self.checked then Paint(self.track, C.raised) end end)
	return b
end

-- A row: label, help line under it, switch on the right.
local function ToggleRow(parent, y, label, help, key)
	local row = CreateFrame("Frame", nil, parent)
	row:SetPoint("TOPLEFT", PAD, y)
	row:SetWidth(INNER)

	row.label = Text(row, "GameFontHighlight", C.text, INNER - 52)
	row.label:SetPoint("TOPLEFT")
	row.label:SetText(label)

	row.help = Text(row, "GameFontHighlightSmall", C.muted, INNER - 52)
	row.help:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -3)
	row.help:SetText(help)

	row.switch = Switch(row, function(on)
		if key == "enabled" then ns.SetEnabled(on) else ns.Set(key, on) end
	end)
	row.switch:SetPoint("TOPRIGHT", 0, -1)

	local h = row.label:GetStringHeight() + 3 + row.help:GetStringHeight()
	row:SetHeight(math.max(h, 20))
	row.key = key

	function row:SetActive(active)
		self:SetAlpha(active and 1 or 0.4)
		self.switch:EnableMouse(active)
	end
	return row, row:GetHeight()
end

-- Segmented mode picker ----------------------------------------------------

local MODES = { { "combat", "MODE_COMBAT" }, { "always", "MODE_ALWAYS" }, { "never", "MODE_NEVER" } }

local function ModePicker(parent, y)
	local box = CreateFrame("Frame", nil, parent)
	box:SetPoint("TOPLEFT", PAD, y)
	box:SetSize(INNER, 28)
	box.bg = Tex(box, C.panel)
	box.bg:SetAllPoints()
	Border(box, C.line)

	local w = (INNER - 4) / #MODES
	box.buttons = {}
	for i, m in ipairs(MODES) do
		local b = CreateFrame("Button", nil, box)
		b:SetSize(w, 24)
		b:SetPoint("LEFT", 2 + (i - 1) * w, 0)
		b.bg = Tex(b, C.panel, "ARTWORK")
		b.bg:SetAllPoints()
		b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		b.text:SetPoint("CENTER")
		b.text:SetText(L[m[2]])
		b.mode = m[1]
		b:SetScript("OnClick", function(self)
			if PlaySound and SOUNDKIT then pcall(PlaySound, SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end
			ns.Set("mode", self.mode)
		end)
		b:SetScript("OnEnter", function(self) if not self.selected then Paint(self.bg, C.hover) end end)
		b:SetScript("OnLeave", function(self) if not self.selected then Paint(self.bg, C.panel) end end)
		box.buttons[i] = b
	end

	function box:SetMode(mode)
		for _, b in ipairs(self.buttons) do
			b.selected = b.mode == mode
			Paint(b.bg, b.selected and C.accent or C.panel)
			SetTextColor(b.text, b.selected and C.onAccent or C.dim)
		end
	end
	function box:SetActive(active)
		self:SetAlpha(active and 1 or 0.4)
		for _, b in ipairs(self.buttons) do b:EnableMouse(active) end
	end
	return box, 28
end

-- Delay slider -------------------------------------------------------------

local function DelaySlider(parent, y)
	local row = CreateFrame("Frame", nil, parent)
	row:SetPoint("TOPLEFT", PAD, y)
	row:SetWidth(INNER)

	row.label = Text(row, "GameFontHighlight", C.text)
	row.label:SetPoint("TOPLEFT")
	row.label:SetText(L.DELAY)

	row.value = Text(row, "GameFontHighlight", C.accent)
	row.value:SetPoint("TOPRIGHT")
	row.value:SetJustifyH("RIGHT")

	row.help = Text(row, "GameFontHighlightSmall", C.muted, INNER)
	row.help:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -3)
	row.help:SetText(L.DELAY_HELP)

	local s = CreateFrame("Slider", nil, row)
	s:SetOrientation("HORIZONTAL")
	s:SetSize(INNER, 16)
	s:SetPoint("TOPLEFT", row.help, "BOTTOMLEFT", 0, -8)
	s:SetMinMaxValues(0, 10)
	s:SetValueStep(0.5)
	if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
	s:EnableMouseWheel(true)

	s.track = Tex(s, C.raised, "BACKGROUND")
	s.track:SetPoint("LEFT")
	s.track:SetPoint("RIGHT")
	s.track:SetHeight(4)
	s.fill = Tex(s, C.accent, "ARTWORK")
	s.fill:SetPoint("LEFT")
	s.fill:SetHeight(4)
	local thumb = s:CreateTexture(nil, "OVERLAY")
	thumb:SetColorTexture(C.text[1], C.text[2], C.text[3], 1)
	thumb:SetSize(8, 16)
	s:SetThumbTexture(thumb)

	local function Show(v)
		row.value:SetText(v <= 0 and L.NOW or L.SECONDS:format(v))
		local min, max = s:GetMinMaxValues()
		local frac = (max > min) and (v - min) / (max - min) or 0
		s.fill:SetWidth(math.max(1, frac * (INNER - 8) + 4))
	end

	s:SetScript("OnValueChanged", function(self, v, userInput)
		v = math.floor(v * 2 + 0.5) / 2
		Show(v)
		if userInput then ns.Set("delay", v) end
	end)
	s:SetScript("OnMouseWheel", function(self, delta)
		local v = math.min(10, math.max(0, (ns.DB().delay or 0) + delta * 0.5))
		self:SetValue(v)
		ns.Set("delay", v)
	end)

	row.slider = s
	function row:SetDelay(v)
		s:SetValue(v)
		Show(v)
	end
	function row:SetActive(active)
		self:SetAlpha(active and 1 or 0.4)
		s:EnableMouse(active)
		s:EnableMouseWheel(active)
	end

	local h = row.label:GetStringHeight() + 3 + row.help:GetStringHeight() + 8 + 16
	row:SetHeight(h)
	return row, h
end

-- Text button ----------------------------------------------------------------

local function TextButton(parent, label, onClick)
	local b = CreateFrame("Button", nil, parent)
	b.bg = Tex(b, C.raised, "ARTWORK")
	b.bg:SetAllPoints()
	Border(b, C.line)
	b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	b.text:SetPoint("CENTER")
	b.text:SetText(label)
	SetTextColor(b.text, C.dim)
	b:SetSize(b.text:GetStringWidth() + 28, 24)
	b:SetScript("OnClick", function()
		if PlaySound and SOUNDKIT then pcall(PlaySound, SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end
		onClick()
	end)
	b:SetScript("OnEnter", function(self) Paint(self.bg, C.hover); SetTextColor(self.text, C.text) end)
	b:SetScript("OnLeave", function(self) Paint(self.bg, C.raised); SetTextColor(self.text, C.dim) end)
	return b
end

-- Close button: an X drawn from two rotated bars.
local function CloseButton(parent)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(22, 22)
	b.bars = {}
	for i, angle in ipairs({ math.rad(45), math.rad(-45) }) do
		local t = Tex(b, C.dim, "OVERLAY")
		t:SetSize(14, 2)
		t:SetPoint("CENTER")
		t:SetRotation(angle)
		b.bars[i] = t
	end
	local function Color(c) for _, t in ipairs(b.bars) do Paint(t, c) end end
	b:SetScript("OnEnter", function() Color(C.text) end)
	b:SetScript("OnLeave", function() Color(C.dim) end)
	b:SetScript("OnClick", function() parent:Hide() end)
	return b
end

-- Window -------------------------------------------------------------------

local function SavePosition()
	local point, _, relPoint, x, y = win:GetPoint(1)
	ns.DB().win = { point, relPoint, x, y }
end

local function Refresh()
	if not win or not win:IsShown() then return end
	local db = ns.DB()
	local enabled = db.enabled
	local combatMode = db.mode == "combat"

	local text, hint, colorKey = ns.Status()
	local color = STATUS_COLOR[colorKey] or C.off
	widgets.statusText:SetText(text)
	SetTextColor(widgets.statusText, color)
	Paint(widgets.statusDot, color)
	Paint(widgets.statusStripe, color)
	widgets.statusHint:SetText(hint)

	widgets.enabled.switch:SetChecked(enabled)
	widgets.mode:SetMode(db.mode)
	widgets.mode:SetActive(enabled)
	widgets.modeLabel:SetAlpha(enabled and 1 or 0.4)

	widgets.group.switch:SetChecked(db.group)
	widgets.group:SetActive(enabled and combatMode)
	widgets.instances.switch:SetChecked(db.instances)
	widgets.instances:SetActive(enabled and combatMode)
	widgets.friendly.switch:SetChecked(db.friendly)
	widgets.friendly:SetActive(enabled)
	widgets.delay:SetDelay(db.delay or 0)
	widgets.delay:SetActive(enabled and combatMode)
end
ns.RefreshUI = Refresh

local function Build()
	win = CreateFrame("Frame", "ForeverCombatPlatesWindow", UIParent)
	win:SetWidth(WIDTH)
	win:SetFrameStrata("DIALOG")
	win:SetToplevel(true)
	win:SetClampedToScreen(true)
	win:SetMovable(true)
	win:EnableMouse(true)
	win:Hide()
	tinsert(UISpecialFrames, "ForeverCombatPlatesWindow")

	win.bg = Tex(win, C.bg)
	win.bg:SetAllPoints()
	Border(win, C.line)
	local top = Tex(win, C.accent, "ARTWORK")
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetHeight(2)

	-- Header (drag handle)
	local header = CreateFrame("Frame", nil, win)
	header:SetPoint("TOPLEFT")
	header:SetPoint("TOPRIGHT")
	header:SetHeight(58)
	header:EnableMouse(true)
	header:RegisterForDrag("LeftButton")
	header:SetScript("OnDragStart", function() win:StartMoving() end)
	header:SetScript("OnDragStop", function()
		win:StopMovingOrSizing()
		SavePosition()
	end)

	local title = Text(header, "GameFontNormalLarge", C.text)
	title:SetPoint("TOPLEFT", PAD, -16)
	title:SetText(L.TITLE)
	local subtitle = Text(header, "GameFontHighlightSmall", C.muted)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
	local version = (C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata)(ADDON, "Version") or ""
	subtitle:SetText(L.SUBTITLE .. " — v" .. version)

	-- Above the header, which takes the mouse for dragging.
	local close = CloseButton(win)
	close:SetPoint("TOPRIGHT", -10, -12)
	close:SetFrameLevel(header:GetFrameLevel() + 10)

	local y = -58

	-- Status card
	local card = CreateFrame("Frame", nil, win)
	card:SetPoint("TOPLEFT", PAD, y)
	card:SetSize(INNER, 54)
	local cardBg = Tex(card, C.panel)
	cardBg:SetAllPoints()
	Border(card, C.line)
	widgets.statusStripe = Tex(card, C.on, "ARTWORK")
	widgets.statusStripe:SetPoint("TOPLEFT")
	widgets.statusStripe:SetPoint("BOTTOMLEFT")
	widgets.statusStripe:SetWidth(3)
	widgets.statusDot = Tex(card, C.on, "ARTWORK")
	widgets.statusDot:SetSize(8, 8)
	widgets.statusDot:SetPoint("TOPLEFT", 14, -15)
	widgets.statusText = Text(card, "GameFontHighlight", C.on, INNER - 40)
	widgets.statusText:SetPoint("LEFT", widgets.statusDot, "RIGHT", 8, 0)
	widgets.statusHint = Text(card, "GameFontHighlightSmall", C.muted, INNER - 30)
	widgets.statusHint:SetPoint("TOPLEFT", 14, -31)
	y = y - 54 - 18

	local row, h
	row, h = ToggleRow(win, y, L.ENABLED, L.ENABLED_HELP, "enabled")
	widgets.enabled = row
	y = y - h - 16

	local div = Tex(win, C.line, "ARTWORK")
	div:SetPoint("TOPLEFT", PAD, y)
	div:SetSize(INNER, 1)
	y = y - 1 - 14

	widgets.modeLabel = Text(win, "GameFontNormal", C.accent)
	widgets.modeLabel:SetPoint("TOPLEFT", PAD, y)
	widgets.modeLabel:SetText(L.MODE)
	y = y - widgets.modeLabel:GetStringHeight() - 8

	widgets.mode, h = ModePicker(win, y)
	y = y - h - 18

	row, h = ToggleRow(win, y, L.GROUP, L.GROUP_HELP, "group")
	widgets.group = row
	y = y - h - 14
	row, h = ToggleRow(win, y, L.INSTANCES, L.INSTANCES_HELP, "instances")
	widgets.instances = row
	y = y - h - 14
	row, h = ToggleRow(win, y, L.FRIENDLY, L.FRIENDLY_HELP, "friendly")
	widgets.friendly = row
	y = y - h - 16

	widgets.delay, h = DelaySlider(win, y)
	y = y - h - 20

	-- Footer
	local footerLine = Tex(win, C.line, "ARTWORK")
	footerLine:SetPoint("TOPLEFT", 0, y)
	footerLine:SetSize(WIDTH, 1)
	local footerBg = Tex(win, { 0, 0, 0, 0.18 }, "BORDER")
	footerBg:SetPoint("TOPLEFT", 0, y)
	footerBg:SetPoint("BOTTOMRIGHT")
	y = y - 12

	local reset = TextButton(win, L.RESET, function() ns.Reset() end)
	reset:SetPoint("TOPLEFT", PAD, y)
	y = y - 24 - 8

	local hint = Text(win, "GameFontHighlightSmall", C.muted, INNER)
	hint:SetPoint("TOPLEFT", PAD, y)
	hint:SetText(L.FOOTER)
	y = y - hint:GetStringHeight() - 14

	win:SetHeight(-y)

	local pos = ns.DB().win
	if pos then
		win:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
	else
		win:SetPoint("CENTER", 0, 60)
	end

	-- Fade in, and keep the status line live (the after-combat countdown).
	local fade = win:CreateAnimationGroup()
	local alpha = fade:CreateAnimation("Alpha")
	alpha:SetFromAlpha(0)
	alpha:SetToAlpha(1)
	alpha:SetDuration(0.15)
	win:SetScript("OnShow", function()
		fade:Play()
		Refresh()
	end)
	local acc = 0
	win:SetScript("OnUpdate", function(_, elapsed)
		acc = acc + elapsed
		if acc >= 0.2 then
			acc = 0
			if ns.state.holdUntil then Refresh() end
		end
	end)
end

function ns.ToggleWindow()
	if not win then Build() end
	if win:IsShown() then win:Hide() else win:Show() end
end

-- The game's Options: a page with one button that opens the window.
local function RegisterOptions()
	if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
	local panel = CreateFrame("Frame")
	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(L.TITLE)
	local text = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	text:SetText(L.OPTIONS_TEXT)
	local button = TextButton(panel, L.OPTIONS_OPEN, function()
		if SettingsPanel and SettingsPanel:IsShown() then HideUIPanel(SettingsPanel) end
		if not win or not win:IsShown() then ns.ToggleWindow() end
	end)
	button:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -14)
	local category = Settings.RegisterCanvasLayoutCategory(panel, L.TITLE)
	Settings.RegisterAddOnCategory(category)
end

function ns.InitUI()
	pcall(RegisterOptions)
	ns.OnChange(Refresh)
end
