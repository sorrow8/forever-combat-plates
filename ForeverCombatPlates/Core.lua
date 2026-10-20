local ADDON, ns = ...
local L = ns.L

-- Forever Combat Plates: enemy nameplates follow combat.
--
-- The game's own "(combat)" nameplate mode in Forever still shows some units
-- near you out of combat, so the addon drives nameplateShowEnemies itself:
-- on when the fight starts, off a moment after it ends. nameplateShowAll is
-- kept at 1 so that whatever is switched on is really shown.
--
-- PLAYER_REGEN_DISABLED fires just before combat lockdown, so the CVar can
-- still be changed there. Anything asked for during lockdown waits for
-- PLAYER_REGEN_ENABLED. V keeps working as a manual switch out of combat; the
-- next fight hands control back to the addon.

local DEFAULTS = {
	enabled = true,
	mode = "combat", -- combat | always | never
	group = true,
	instances = false,
	friendly = false,
	hostileNames = false, -- names over hostile mobs, never over neutral ones
	hideTrivial = false, -- with hostileNames: no names over grey mobs
	delay = 2,
	minimapShow = true,
	minimapAngle = 210,
}

-- Driven whenever the addon is on. Friendly player nameplates are a separate
-- case: the addon only drives them while that option is on, so their value is
-- saved when the addon first takes them over and put back when it lets go.
local MANAGED = { "nameplateShowAll", "nameplateShowEnemies" }
local FRIENDLY = "nameplateShowFriendlyPlayers"
-- Names of hostile mobs: the game's own "hostile NPC names" switch on (the
-- misspelling is Blizzard's) and its "all NPC names" switch off, so neutral
-- mobs stay without a name whatever the game's NPC names setting was. Red
-- names, at the game's own distance.
-- Someone who had the game show all NPC names keeps the names of friendly and
-- quest NPCs (the game's "Interactive" choice), only neutral mobs lose theirs.
-- With grey mobs left out, the names come from the enemy nameplates
-- out of combat (see Plates below): the addon writes the names on the
-- nameplates. The game's hostile names stay on: it draws no name over a mob
-- that has a nameplate, so those get the addon's name or none, and red mobs
-- past nameplate range keep the game's own far names. The plates' forced
-- names that 1.3.3 switched on are only put back.
local FORCE_NAMES = "nameplateForceShowUnitName"
local NAMES = { "UnitNameHostleNPC", "UnitNameNPC", "UnitNameFriendlySpecialNPCName", "UnitNameInteractiveNPC", FORCE_NAMES }
local PREFIX = "|cffebbd61Forever Combat Plates|r: "
-- Group combat is noticed from UNIT_FLAGS at once; this slow check only
-- catches what the event may miss (a member far away).
local GROUP_POLL = 2

local db
local state = {
	player = false,   -- the player is in combat
	group = false,    -- someone in the group is in combat
	engaged = false,  -- last evaluated combat state
	holdUntil = nil,  -- GetTime() the after-combat hold ends
	manual = nil,     -- true/false: set by hand with V out of combat
	inInstance = nil, -- whether the last zone was a dungeon or raid
	pending = false,  -- a change waits for combat to end
	hostilePending = false, -- the hostile names switch waits for combat to end
	friendlyRestore = false, -- friendly plates were let go in combat, restore them after it
	namesOnly = false, -- enemy plates show only names (hideTrivial out of combat)
	flying = false,   -- on a flight path: no enemy plates at all
	expect = {},      -- CVar values the addon itself just wrote
}
ns.state = state

local holdTimer, groupTicker
local listeners = {}

function ns.Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
end

function ns.OnChange(fn)
	listeners[#listeners + 1] = fn
end

local function Notify()
	for _, fn in ipairs(listeners) do pcall(fn) end
end
ns.Notify = Notify

function ns.DB() return db end
ns.DEFAULTS = DEFAULTS

-- CVars ------------------------------------------------------------------

local function GetCVarString(name)
	local ok, v = pcall(C_CVar.GetCVar, name)
	if ok then return v end
end

local function SetCVarString(name, value)
	value = tostring(value)
	if GetCVarString(name) == value then return end
	local key = name:lower()
	state.expect[key] = value
	pcall(C_CVar.SetCVar, name, value)
	-- a write the game refused sends no update: don't wait for one, or the
	-- player's next V to that value would be taken for ours
	if GetCVarString(name) ~= value then state.expect[key] = nil end
end

local function SaveOriginals()
	if db.orig then return end
	db.orig = {}
	for _, name in ipairs(MANAGED) do
		db.orig[name] = GetCVarString(name)
	end
end

local function RestoreOriginal(name)
	if db.orig and db.orig[name] ~= nil then
		SetCVarString(name, db.orig[name])
	end
end

local function SaveFriendly()
	if db.origFriendly == nil then db.origFriendly = GetCVarString(FRIENDLY) end
end

-- The addon stops driving friendly nameplates: give the player's value back.
local function RestoreFriendly()
	if InCombatLockdown() then
		state.friendlyRestore = true
		return
	end
	state.friendlyRestore = false
	if db.origFriendly ~= nil then SetCVarString(FRIENDLY, db.origFriendly) end
	db.origFriendly = nil
end

-- Hostile mob names: on while the addon and the option are on, off when the
-- player turns the option off (see ReleasedName). A change in combat waits for
-- the fight to end.
local function NamesWanted()
	return db.enabled and db.hostileNames
end

-- What each name CVar should be while the option is on (nil: left alone).
local function NamesTarget(name)
	if name == "UnitNameHostleNPC" then return "1" end
	if name == "UnitNameNPC" then return "0" end
	-- 1.3.3 switched it on; the addon writes the names itself now
	if name == FORCE_NAMES then return db.origNames and db.origNames[name] end
	if db.origNames and db.origNames.UnitNameNPC == "1" then return "1" end
end

-- What a name CVar goes back to when the option lets go. The player turning
-- the option off means no hostile names in the game itself either, so they
-- don't have to go to the game's settings for that; the rest of the game's NPC
-- names choice comes back. "All NPC names" can't leave hostile mobs out, so it
-- turns into the names of friendly and quest NPCs. Switching the whole addon
-- off gives the game's choice back as it was.
local function ReleasedName(origNames, name)
	local orig = origNames[name]
	if not db.enabled or db.hostileNames or name == FORCE_NAMES then return orig end
	if name == "UnitNameHostleNPC" or name == "UnitNameNPC" then return "0" end
	if origNames.UnitNameNPC == "1" then return "1" end
	return orig
end

-- Whether the name CVars differ from what they should be right now.
local function NamesDiffer()
	for _, name in ipairs(NAMES) do
		local want
		if NamesWanted() then want = NamesTarget(name) elseif db.origNames then want = ReleasedName(db.origNames, name) end
		if want ~= nil and GetCVarString(name) ~= want then return true end
	end
	return false
end

local function UpdateHostileNames()
	if InCombatLockdown() then
		state.hostilePending = NamesDiffer()
		return
	end
	state.hostilePending = false
	if NamesWanted() then
		-- every value saved once, also the ones a saved set from 1.3.0 lacks
		db.origNames = db.origNames or {}
		for _, name in ipairs(NAMES) do
			if db.origNames[name] == nil then db.origNames[name] = GetCVarString(name) end
		end
		for _, name in ipairs(NAMES) do
			local want = NamesTarget(name)
			if want ~= nil then SetCVarString(name, want) end
		end
	elseif db.origNames then
		-- let go of the saved set first: a write the game reports twice must
		-- not be saved as the player's choice halfway through
		local origNames = db.origNames
		db.origNames = nil
		for _, name in ipairs(NAMES) do
			local orig = ReleasedName(origNames, name)
			if orig ~= nil then SetCVarString(name, orig) end
		end
	end
end

local function RestoreOriginals()
	if InCombatLockdown() then
		state.pending = true
		state.friendlyRestore = db.origFriendly ~= nil
		return
	end
	for _, name in ipairs(MANAGED) do RestoreOriginal(name) end
	db.orig = nil
	RestoreFriendly()
	UpdateHostileNames()
	state.pending = false
end

-- Combat state -----------------------------------------------------------

local function InPveInstance()
	local inside, kind = IsInInstance()
	return inside and (kind == "party" or kind == "raid")
end

-- A member fighting far away (another zone, the other end of a raid) is not
-- your fight: only one near enough for the game to show counts.
local function Near(unit)
	local visible = UnitIsVisible(unit)
	if issecretvalue and issecretvalue(visible) then return true end
	return visible and true or false
end

local function GroupInCombat()
	if not IsInGroup() then return false end
	local prefix = IsInRaid() and "raid" or "party"
	for i = 1, GetNumGroupMembers() do
		local unit = prefix .. i
		if UnitExists(unit) and UnitAffectingCombat(unit) and Near(unit) then
			return true
		end
	end
	return false
end

local function CancelHold()
	if holdTimer then
		holdTimer:Cancel()
		holdTimer = nil
	end
	state.holdUntil = nil
end

local Evaluate

local function StartHold()
	CancelHold()
	local delay = tonumber(db.delay) or 0
	if delay <= 0 then return end
	state.holdUntil = GetTime() + delay
	holdTimer = C_Timer.NewTimer(delay, function()
		holdTimer = nil
		state.holdUntil = nil
		Evaluate()
	end)
end

-- On a flight path the mobs below are only clutter, so their plates and
-- names stay off whatever the mode, V or a fight. The flight starts and ends
-- with PLAYER_CONTROL_LOST / GAINED; nothing runs in between.
local function OnTaxi()
	local ok, taxi = pcall(UnitOnTaxi, "player")
	return ok and taxi and true or false
end

local function CheckTaxi()
	local flying = OnTaxi()
	if flying ~= state.flying then
		state.flying = flying
		if Evaluate then Evaluate() end
	end
end

-- What the enemy nameplates should be right now. V out of combat wins over
-- "always on in dungeons" until the next fight, as the window promises.
local function Wanted()
	if state.flying then return false end
	if db.mode == "always" then return true end
	if db.mode == "never" then return false end
	if state.engaged then return true end
	if state.holdUntil then return true end
	if state.manual ~= nil then return state.manual end
	if db.instances and InPveInstance() then return true end
	return false
end

-- Whether the CVars differ from what they should be. Enemy plates stay on
-- while they show only names.
local function Differs(v, enemies)
	return GetCVarString("nameplateShowAll") ~= "1" or GetCVarString("nameplateShowEnemies") ~= enemies
		or (db.friendly and GetCVarString(FRIENDLY) ~= v)
end

local function Apply(show)
	local v = show and "1" or "0"
	local enemies = (show or state.namesOnly) and "1" or "0"
	if InCombatLockdown() then
		-- only a real change waits; the group check re-evaluates every 2 s
		state.pending = Differs(v, enemies) and true or false
		return
	end
	state.pending = false
	SetCVarString("nameplateShowAll", "1")
	SetCVarString("nameplateShowEnemies", enemies)
	if db.friendly then
		SaveFriendly()
		SetCVarString(FRIENDLY, v)
	end
end

-- Plates -------------------------------------------------------------------

-- The game draws mob names itself and can't leave out a single mob, so with
-- grey mobs left out the names come from the enemy nameplates out
-- of combat instead: each plate shows only its name, and the plates of
-- neutral mobs and of grey ones are hidden. A mob of an active
-- quest always keeps its red name. In combat the plates are whole again.
-- Only alpha is changed, Blizzard's own fields are never written.
-- selectionHighlight ignores the plate's alpha, so it is hidden by itself.
local PARTS = {
	"HealthBarsContainer", "CastBarsContainer", "AurasFrame", "ClassificationFrame",
	"PlayerLevelDiffFrame", "LevelFrame", "SoftTargetFrame", "selectionHighlight", "behindCameraIcon",
}
local styled = {} -- unit frames shown as names only, true: name shown in red
local alphas = {} -- unit frame -> the alpha of the frame and its parts before styling
local plateFrames = {} -- nameplate unit -> its unit frame (the game takes it away before REMOVED)

-- Grey the way the game colours a mob's level: further below the player than
-- the player's green range (UnitQuestTrivialLevelRange, which grows with the
-- player's level). Green mobs keep their names. The game compares effective
-- levels, which differ from UnitLevel in level-scaled places.
local function Grey(unit)
	local level = UnitEffectiveLevel(unit)
	if level <= 0 then return false end -- "??"
	local below = UnitEffectiveLevel("player") - level
	local ok, range = pcall(UnitQuestTrivialLevelRange, "player")
	if not ok or type(range) ~= "number" then range = 4 end -- the game gave no range
	return below > range
end

local function QuestMob(unit)
	return C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest(unit)
end

local function ShowsName(unit)
	if QuestMob(unit) then return true end
	if UnitIsPlayer(unit) then return true end
	local reaction = UnitReaction(unit, "player")
	if not reaction or reaction > 3 then return false end -- neutral
	return not Grey(unit)
end

-- The plate's own name is hidden and the addon writes the name the way the
-- game writes it over a mob, with the title (<Cult of the Damned>) under it,
-- so nothing changes to the eye when a mob comes into nameplate range.
-- UNIT_NAME_FONT is the font the game draws names over units with.
local NAME_SIZE = 13
local NAME_COLOR = { 1, 0, 0 }
local labels = {} -- unit frame -> { name = FontString, title = FontString }

-- One font for every alphabet, built the way the game builds its own: the
-- name font alone has no Korean, Chinese or (on most clients) Russian
-- letters, and such names came out as boxes. Chinese letters are drawn a
-- little bigger, as in the game's fonts.
local nameFont
local function NameFont()
	if nameFont then return nameFont end
	local function Member(alphabet, file, height)
		return { alphabet = alphabet, file = file, height = height, flags = "" }
	end
	local ok, font = pcall(CreateFontFamily, "ForeverCombatPlatesNameFont", {
		Member("roman", UNIT_NAME_FONT or STANDARD_TEXT_FONT, NAME_SIZE),
		Member("korean", "Fonts\\2002.TTF", NAME_SIZE),
		Member("simplifiedchinese", "Fonts\\ARKai_T.ttf", NAME_SIZE + 3),
		Member("traditionalchinese", "Fonts\\blei00d.TTF", NAME_SIZE + 3),
		Member("russian", "Fonts\\FRIZQT___CYR.TTF", NAME_SIZE),
	})
	if not ok or not font then
		font = CreateFont("ForeverCombatPlatesNameFontLatin")
		font:SetFont(UNIT_NAME_FONT or STANDARD_TEXT_FONT, NAME_SIZE, "")
	end
	nameFont = font
	return font
end

local function Label(frame)
	local l = labels[frame]
	if l then return l end
	l = {}
	for _, key in ipairs({ "name", "title" }) do
		local fs = frame:CreateFontString(nil, "OVERLAY")
		fs:SetFontObject(NameFont())
		fs:SetShadowColor(0, 0, 0, 1)
		fs:SetShadowOffset(1, -1)
		fs:SetTextColor(NAME_COLOR[1], NAME_COLOR[2], NAME_COLOR[3])
		fs:SetWordWrap(false)
		-- the game fades plates that aren't targeted; its own names stay bright
		fs:SetIgnoreParentAlpha(true)
		l[key] = fs
	end
	l.title:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)
	labels[frame] = l
	return l
end

-- A mob's title (Cult of the Damned) is the tooltip's second line, written
-- without brackets; mobs without one have the level line there instead.
local function Title(unit)
	local data = C_TooltipInfo and C_TooltipInfo.GetUnit(unit)
	local line = data and data.lines and data.lines[2]
	local text = line and line.leftText
	if type(text) ~= "string" or text == "" or text:find("%d") or text:find("%?%?") then return end
	if not text:find("^<") then text = "<" .. text .. ">" end
	return text
end

local function ShowLabel(frame, unit)
	local l = Label(frame)
	l.name:SetText(UnitName(unit))
	local ok, title = pcall(Title, unit)
	title = ok and title or nil
	l.title:SetText(title or "")
	l.name:ClearAllPoints()
	if title then
		l.name:SetPoint("BOTTOM", l.title, "TOP", 0, 1)
	else
		l.name:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)
	end
	l.name:Show()
	l.title:SetShown(title ~= nil)
end

local function HideLabel(frame)
	local l = labels[frame]
	if l then
		l.name:Hide()
		l.title:Hide()
	end
end

-- The alphas a plate had before styling, put back as they were.
local function SaveAlphas(frame)
	if alphas[frame] then return end
	local saved = { frame = frame:GetAlpha(), name = frame.name and frame.name:GetAlpha() }
	for _, key in ipairs(PARTS) do
		if frame[key] then saved[key] = frame[key]:GetAlpha() end
	end
	alphas[frame] = saved
end

local function Unstyle(frame)
	local saved = alphas[frame] or {}
	frame:SetAlpha(saved.frame or 1)
	for _, key in ipairs(PARTS) do
		if frame[key] then frame[key]:SetAlpha(saved[key] or 1) end
	end
	if frame.name then frame.name:SetAlpha(saved.name or 1) end
	alphas[frame] = nil
	HideLabel(frame)
	styled[frame] = nil
end

local function StylePlate(unit)
	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	local frame = plate and plate.UnitFrame
	if not frame then return end
	plateFrames[unit] = frame
	if not state.namesOnly or UnitIsFriend("player", unit) then
		if styled[frame] ~= nil then Unstyle(frame) end
		return
	end
	-- a level or reaction hidden in combat counts as shown
	local ok, show = pcall(ShowsName, unit)
	show = not ok or show
	SaveAlphas(frame)
	frame:SetAlpha(show and 1 or 0)
	for _, key in ipairs(PARTS) do
		if frame[key] then frame[key]:SetAlpha(0) end
	end
	if frame.name then frame.name:SetAlpha(0) end
	styled[frame] = show
	if show then ShowLabel(frame, unit) else HideLabel(frame) end
end

function ns.StylePlates()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		local unit = plate.UnitFrame and plate.UnitFrame.unit
		if unit then pcall(StylePlate, unit) end
	end
end

function Evaluate()
	-- nothing is written before login: the player's own values are saved then
	if not state.loggedIn then return end
	if not db or not db.enabled then
		Notify()
		return
	end
	local engaged = state.player or (db.group and state.group) or false
	if engaged and not state.engaged then
		state.manual = nil -- a fight takes the nameplates back from V
		CancelHold()
	elseif not engaged and state.engaged then
		StartHold()
	end
	state.engaged = engaged
	local show = Wanted()
	state.namesOnly = NamesWanted() and db.hideTrivial and not show and not state.flying or false
	-- "always" and "never" are set once; a fight then doesn't undo the player's V
	if db.mode == "combat" then
		state.appliedMode = nil
		Apply(show)
	elseif state.appliedMode ~= db.mode or state.appliedNames ~= state.namesOnly or state.appliedFlying ~= state.flying then
		Apply(show)
		if not InCombatLockdown() then
			state.appliedMode, state.appliedNames, state.appliedFlying = db.mode, state.namesOnly, state.flying
		end
	end
	UpdateHostileNames()
	ns.StylePlates()
	Notify()
end
ns.Evaluate = Evaluate

-- Group polling ----------------------------------------------------------

local function StopGroupTicker()
	if groupTicker then
		groupTicker:Cancel()
		groupTicker = nil
	end
	if state.group then
		state.group = false
		Evaluate()
	end
end

local function GroupTick()
	local ok, inCombat = pcall(GroupInCombat)
	if not ok then
		-- Unit combat state can be hidden from addons on some clients: the check
		-- stops for this session, the saved option stays as the player set it
		state.groupBroken = true
		StopGroupTicker()
		ns.Print(L.MSG_NOGROUP)
		Notify()
		return
	end
	if inCombat ~= state.group then
		state.group = inCombat
		Evaluate()
	end
end

local function UpdateGroupTicker()
	if not state.loggedIn then return end
	local want = db.enabled and db.group and db.mode == "combat" and IsInGroup() and not state.groupBroken
	if want and not groupTicker then
		groupTicker = C_Timer.NewTicker(GROUP_POLL, GroupTick)
		GroupTick()
	elseif not want and groupTicker then
		StopGroupTicker()
	end
end

-- Public API used by the window and slash commands -----------------------

function ns.SetEnabled(on)
	on = on and true or false
	if db.enabled == on then return end
	db.enabled = on
	if on then
		SaveOriginals()
		state.manual = nil
		UpdateGroupTicker()
		Evaluate()
		ns.Print(L.MSG_ON)
	else
		CancelHold()
		state.engaged = false
		state.namesOnly = false
		ns.StylePlates()
		UpdateGroupTicker()
		RestoreOriginals()
		-- in combat the settings come back after the fight; say it then
		if InCombatLockdown() then state.offMessage = true else ns.Print(L.MSG_OFF) end
		Notify()
	end
end

function ns.Set(key, value)
	if db[key] == value then return end
	local wasFriendly = db.friendly
	db[key] = value
	if key == "friendly" then
		if wasFriendly and not value then
			RestoreFriendly() -- in combat it waits for the fight to end
		elseif value then
			state.friendlyRestore = false
		end
	end
	if key == "mode" then state.manual = nil end
	if key == "delay" and state.holdUntil then StartHold() end
	UpdateGroupTicker()
	Evaluate()
end

-- Switches on the spot: the texts change and the window is built again.
-- (ReloadUI is blocked for addons on Forever.)
function ns.SetLanguage(code)
	if db.locale == code then return end
	db.locale = code
	ns.ApplyLocale(code)
	if ns.RebuildWindow then ns.RebuildWindow() end
	if ns.RefreshOptionsText then ns.RefreshOptionsText() end
	Notify()
end

function ns.Reset()
	local wasFriendly = db.friendly
	for k, v in pairs(DEFAULTS) do
		if k ~= "enabled" then db[k] = v end
	end
	if wasFriendly and not db.friendly then RestoreFriendly() end
	state.manual = nil
	UpdateGroupTicker()
	Evaluate()
	ns.Print(L.MSG_RESET)
end

-- Status for the window: text, hint, colour key.
function ns.Status()
	local hint = db.mode == "combat" and L.MODE_HINT_COMBAT or L.MODE_HINT_STATIC
	local waiting = state.pending or state.hostilePending or state.friendlyRestore
	if not db.enabled then
		if waiting then return L.STATUS_PENDING, L.STATUS_OFF_HINT, "warn" end
		return L.STATUS_OFF, L.STATUS_OFF_HINT, "off"
	end
	if waiting then return L.STATUS_PENDING, hint, "warn" end
	if db.mode == "always" then return L.STATUS_ALWAYS, hint, "danger" end
	if db.mode == "never" then return L.STATUS_NEVER, hint, "off" end
	if state.namesOnly then return L.STATUS_NAMES, hint, "on" end
	-- V out of combat wins over "always on in dungeons" until the next fight
	if state.manual == false and not state.engaged and not state.holdUntil then return L.STATUS_IDLE, hint, "on" end
	if db.instances and InPveInstance() and state.manual == nil then return L.STATUS_INSTANCE, hint, "on" end
	if state.player then return L.STATUS_COMBAT, hint, "on" end
	if state.engaged then return L.STATUS_GROUP, hint, "on" end
	if state.holdUntil then
		return L.STATUS_HOLD:format(math.max(0, state.holdUntil - GetTime())), hint, "warn"
	end
	if state.manual then return L.STATUS_MANUAL_ON, L.STATUS_MANUAL_HINT, "accent" end
	return L.STATUS_IDLE, hint, "on" -- "in combat" mode is working as intended: green
end

-- Events -----------------------------------------------------------------

local frame = CreateFrame("Frame")
local events = {}

function events.ADDON_LOADED(name)
	if name ~= ADDON then return end
	ForeverCombatPlatesDB = ForeverCombatPlatesDB or {}
	db = ForeverCombatPlatesDB
	for k, v in pairs(DEFAULTS) do
		if db[k] == nil then db[k] = v end
	end
	-- Up to 1.2.1 the friendly value was saved with the others even when the
	-- addon didn't drive it; keep it only if the option is on.
	if db.orig and db.orig[FRIENDLY] ~= nil then
		if db.friendly and db.origFriendly == nil then db.origFriendly = db.orig[FRIENDLY] end
		db.orig[FRIENDLY] = nil
	end
	-- 1.3.0 saved only the hostile names value
	if db.origHostile ~= nil then
		db.origNames = db.origNames or { UnitNameHostleNPC = db.origHostile }
		db.origHostile = nil
	end
	-- 1.3.3 could save its own forced plate names ("1") as yours; the game's
	-- default goes back in once. 1.3.4's test build left a name size behind.
	if not db.forceNamesFixed then
		if db.origNames and db.origNames[FORCE_NAMES] == "1" then
			local ok, default = pcall(C_CVar.GetCVarDefault, FORCE_NAMES)
			if ok and default then db.origNames[FORCE_NAMES] = default end
		end
		db.forceNamesFixed = true
	end
	db.nameSize = nil
	ns.ApplyLocale(db.locale) -- every locale file is loaded by now
	frame:UnregisterEvent("ADDON_LOADED")
end

function events.PLAYER_LOGIN()
	state.loggedIn = true
	if db.enabled then
		SaveOriginals()
	elseif db.orig or db.origFriendly or db.origNames then
		-- switched off in combat and the game was left before the fight ended
		RestoreOriginals()
	end
	state.player = InCombatLockdown() and true or false
	state.flying = OnTaxi()
	UpdateGroupTicker()
	Evaluate()
	if ns.InitUI then ns.InitUI() end
	-- First run: say how to reach the settings and open them once.
	if not db.welcomed then
		db.welcomed = true
		ns.Print(L.MSG_WELCOME)
		C_Timer.After(3, function()
			if ns.ToggleWindow and not (ForeverCombatPlatesWindow and ForeverCombatPlatesWindow:IsShown()) then
				ns.ToggleWindow()
			end
		end)
	else
		ns.Print(L.MSG_LOADED)
	end
end

-- the taxi flag is set a moment after control goes
function events.PLAYER_CONTROL_LOST() C_Timer.After(0.2, CheckTaxi) end
function events.PLAYER_CONTROL_GAINED() C_Timer.After(0.2, CheckTaxi) end

function events.PLAYER_REGEN_DISABLED()
	state.player = true
	Evaluate()
end

function events.PLAYER_REGEN_ENABLED()
	state.player = false
	if state.friendlyRestore then
		state.friendlyRestore = false
		if not (db.enabled and db.friendly) then RestoreFriendly() end
	end
	if not db.enabled then
		if state.pending then RestoreOriginals() end
		if state.hostilePending then UpdateHostileNames() end
		if state.offMessage then
			state.offMessage = false
			ns.Print(L.MSG_OFF)
		end
		Notify()
		return
	end
	state.offMessage = false
	Evaluate()
end

function events.PLAYER_ENTERING_WORLD()
	-- V belongs to the place it was pressed in: entering or leaving a dungeon
	-- hands the nameplates back to the settings
	local inside = InPveInstance()
	if state.inInstance ~= nil and inside ~= state.inInstance then state.manual = nil end
	state.inInstance = inside
	UpdateGroupTicker()
	Evaluate()
end
events.ZONE_CHANGED_NEW_AREA = events.PLAYER_ENTERING_WORLD

function events.GROUP_ROSTER_UPDATE()
	UpdateGroupTicker()
end

-- Plates come and go and are reused for other mobs.
function events.NAME_PLATE_UNIT_ADDED(unit)
	pcall(StylePlate, unit)
end

function events.NAME_PLATE_UNIT_REMOVED(unit)
	local frame = plateFrames[unit]
	plateFrames[unit] = nil
	if frame and styled[frame] ~= nil then Unstyle(frame) end
end

-- A mob turned hostile, levels changed or a quest moved on.
local function Restyle()
	if state.namesOnly then ns.StylePlates() end
end

-- UNIT_FACTION fires for every unit around: only its own plate is redone.
function events.UNIT_FACTION(unit)
	if state.namesOnly and type(unit) == "string" and unit:find("^nameplate%d") then
		pcall(StylePlate, unit)
	end
end

-- UnitEffectiveLevel("player") can still be the old level during the event.
function events.PLAYER_LEVEL_UP()
	C_Timer.After(0, Restyle)
end

-- Quest updates come in bursts; one restyle half a second later covers them.
local questRestyle = false
function events.QUEST_LOG_UPDATE()
	if questRestyle or not state.namesOnly then return end
	questRestyle = true
	C_Timer.After(0.5, function()
		questRestyle = false
		Restyle()
	end)
end

-- A group member's flags changed (entering or leaving combat among them).
function events.UNIT_FLAGS(unit)
	if not groupTicker or type(unit) ~= "string" then return end
	if unit:find("^party%d") or unit:find("^raid%d") then GroupTick() end
end

-- V (or the game's settings) changed the enemy nameplates by hand.
function events.CVAR_UPDATE(name)
	if type(name) ~= "string" then return end
	local key = name:lower()
	for _, cvarName in ipairs(NAMES) do
		if key == cvarName:lower() then
			local value = GetCVarString(cvarName)
			if state.expect[key] ~= nil then
				local expected = state.expect[key]
				state.expect[key] = nil
				if expected == value then return end
			end
			-- the game can report one change twice: a value the addon itself
			-- wants right now is never taken for the player's
			if db and NamesWanted() and value == NamesTarget(cvarName) then return end
			-- the player picked NPC names in the game's settings: that whole choice
			-- (the game sets all four values, a value that stays the same may send
			-- no event) is what comes back when the option lets go. The forced
			-- plate names are no part of that menu.
			if db and db.origNames then
				for _, n in ipairs(NAMES) do
					if n ~= FORCE_NAMES then db.origNames[n] = GetCVarString(n) end
				end
			end
			return
		end
	end
	if key ~= "nameplateshowenemies" then return end
	local value = GetCVarString("nameplateShowEnemies")
	if state.expect[key] ~= nil then
		local expected = state.expect[key]
		state.expect[key] = nil
		if expected == value then return end
	end
	if not db or not db.enabled or db.mode ~= "combat" then return end
	if state.engaged or InCombatLockdown() then return end
	-- the game can report the addon's own write twice; that is no V press
	if value == ((Wanted() or state.namesOnly) and "1" or "0") then return end
	CancelHold()
	-- plates showing only names: V turns them into whole plates
	if state.namesOnly and value == "0" then value = "1" end
	state.manual = value == "1"
	Evaluate() -- friendly plates follow V too
end

-- Leaving the game (or /reload): the player's own values go back, and the
-- next login sets the addon's again. Turned off in the AddOns list, it then
-- leaves the game as the player had it. The saved values stay for that login.
function events.PLAYER_LOGOUT()
	if not db or not db.enabled or InCombatLockdown() then return end
	local function Put(name, value)
		if value ~= nil then pcall(C_CVar.SetCVar, name, value) end
	end
	if db.orig then
		for _, name in ipairs(MANAGED) do Put(name, db.orig[name]) end
	end
	Put(FRIENDLY, db.origFriendly)
	if db.origNames then
		for _, name in ipairs(NAMES) do Put(name, db.origNames[name]) end
	end
end

frame:SetScript("OnEvent", function(_, event, ...)
	local fn = events[event]
	if fn then fn(...) end
end)
for event in pairs(events) do
	frame:RegisterEvent(event)
end

-- Slash commands, key bindings, addon compartment ------------------------

-- A language this client can show (CJK fonts exist only on CJK clients).
local function Usable(code)
	for _, lang in ipairs(ns.LANGUAGES) do
		if lang.code == code then return ns.LanguageAvailable(lang) end
	end
	return false
end

local function Command(msg)
	local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(%S*)")
	if cmd == "" then
		if ns.ToggleWindow then ns.ToggleWindow() end
	elseif cmd == "on" then
		ns.SetEnabled(true)
	elseif cmd == "off" then
		ns.SetEnabled(false)
	elseif cmd == "toggle" then
		ns.SetEnabled(not db.enabled)
	elseif cmd == "mode" and (arg == "combat" or arg == "always" or arg == "never") then
		ns.Set("mode", arg)
		ns.Print((ns.Status()))
	elseif cmd == "lang" and (arg == "auto" or Usable(ns.LanguageCode(arg))) then
		local code = arg ~= "auto" and ns.LanguageCode(arg) or nil
		if code == ns.ClientLocale() then code = nil end -- the client's own: keep following it
		ns.SetLanguage(code)
	elseif cmd == "reset" then
		ns.Reset()
	elseif cmd == "status" then
		ns.Print((ns.Status()))
	else
		ns.Print(L.MSG_HELP)
	end
end

SLASH_FOREVERCOMBATPLATES1 = "/fcp"
SLASH_FOREVERCOMBATPLATES2 = "/combatplates"
SlashCmdList.FOREVERCOMBATPLATES = Command

function ForeverCombatPlates_ToggleWindow()
	if ns.ToggleWindow then ns.ToggleWindow() end
end

function ForeverCombatPlates_Toggle()
	if db then ns.SetEnabled(not db.enabled) end
end

function ForeverCombatPlates_OnCompartmentClick()
	ForeverCombatPlates_ToggleWindow()
end
