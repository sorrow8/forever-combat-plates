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
local NAMES = { "UnitNameHostleNPC", "UnitNameNPC", "UnitNameFriendlySpecialNPCName", "UnitNameInteractiveNPC" }
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

-- Hostile mob names: on while the addon and the option are on, the player's
-- own values back otherwise. A change in combat waits for the fight to end.
local function NamesWanted()
	return db.enabled and db.hostileNames
end

-- What each name CVar should be while the option is on (nil: left alone).
local function NamesTarget(name)
	if name == "UnitNameHostleNPC" then return "1" end
	if name == "UnitNameNPC" then return "0" end
	if db.origNames and db.origNames.UnitNameNPC == "1" then return "1" end
end

-- Whether the name CVars differ from what they should be right now.
local function NamesDiffer()
	for _, name in ipairs(NAMES) do
		local want
		if NamesWanted() then want = NamesTarget(name) elseif db.origNames then want = db.origNames[name] end
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
		for _, name in ipairs(NAMES) do
			local orig = db.origNames[name]
			if orig ~= nil then SetCVarString(name, orig) end
		end
		db.origNames = nil
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

local function GroupInCombat()
	if not IsInGroup() then return false end
	local prefix = IsInRaid() and "raid" or "party"
	for i = 1, GetNumGroupMembers() do
		local unit = prefix .. i
		if UnitExists(unit) and UnitAffectingCombat(unit) then
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

-- What the enemy nameplates should be right now. V out of combat wins over
-- "always on in dungeons" until the next fight, as the window promises.
local function Wanted()
	if db.mode == "always" then return true end
	if db.mode == "never" then return false end
	if state.engaged then return true end
	if state.holdUntil then return true end
	if state.manual ~= nil then return state.manual end
	if db.instances and InPveInstance() then return true end
	return false
end

-- Whether the CVars differ from what they should be.
local function Differs(v)
	return GetCVarString("nameplateShowAll") ~= "1" or GetCVarString("nameplateShowEnemies") ~= v
		or (db.friendly and GetCVarString(FRIENDLY) ~= v)
end

local function Apply(show)
	local v = show and "1" or "0"
	if InCombatLockdown() then
		-- only a real change waits; the group check re-evaluates every half second
		state.pending = Differs(v) and true or false
		return
	end
	state.pending = false
	SetCVarString("nameplateShowAll", "1")
	SetCVarString("nameplateShowEnemies", v)
	if db.friendly then
		SaveFriendly()
		SetCVarString(FRIENDLY, v)
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
	Apply(Wanted())
	UpdateHostileNames()
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
		-- Unit combat state can be hidden from addons on some clients.
		db.group = false
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
	local want = db.enabled and db.group and db.mode == "combat" and IsInGroup()
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
			-- the player picked NPC names in the game's settings: that whole choice
			-- (the game sets all four values, a value that stays the same may send
			-- no event) is what comes back when the option lets go
			if db and db.origNames then
				for _, n in ipairs(NAMES) do db.origNames[n] = GetCVarString(n) end
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
	CancelHold()
	state.manual = value == "1"
	Apply(Wanted()) -- friendly plates follow V too
	Notify()
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
