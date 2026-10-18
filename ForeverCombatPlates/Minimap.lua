local ADDON, ns = ...
local L = ns.L

-- A button on the edge of the minimap, in the usual minimap-button style.
-- Left-click opens the window, right-click turns the addon on or off, and
-- dragging moves it around the minimap (round or square). The icon goes
-- grey while the addon is off.

local ICON = "Interface\\Icons\\Ability_Warrior_BattleShout"
local button

local function Angle()
	return math.rad(tonumber(ns.DB().minimapAngle) or 210)
end

local function UpdatePosition()
	local a = Angle()
	local x, y = math.cos(a), math.sin(a)
	local w = Minimap:GetWidth() / 2 + 5
	local h = Minimap:GetHeight() / 2 + 5
	local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
	if shape == "SQUARE" then
		-- On a square minimap the button runs along the edge, not a circle.
		x = math.max(-1, math.min(1, x * 1.4142)) * w
		y = math.max(-1, math.min(1, y * 1.4142)) * h
	else
		x, y = x * w, y * h
	end
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function atan2(y, x)
	if math.atan2 then return math.atan2(y, x) end
	return math.atan(y, x)
end

local function OnDragUpdate()
	local mx, my = Minimap:GetCenter()
	local scale = Minimap:GetEffectiveScale()
	local cx, cy = GetCursorPosition()
	cx, cy = cx / scale, cy / scale
	ns.DB().minimapAngle = math.deg(atan2(cy - my, cx - mx)) % 360
	UpdatePosition()
end

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(L.TITLE, 1, 1, 1)
	local text = ns.Status()
	GameTooltip:AddLine(text, 0.92, 0.74, 0.38)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.MM_LEFT, 0.8, 0.8, 0.8)
	GameTooltip:AddLine(L.MM_RIGHT, 0.8, 0.8, 0.8)
	GameTooltip:AddLine(L.MM_DRAG, 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

local function Build()
	button = CreateFrame("Button", "ForeverCombatPlatesMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local bg = button:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	bg:SetSize(20, 20)
	bg:SetPoint("CENTER", 0, 1)

	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetTexture(ICON)
	button.icon:SetSize(18, 18)
	button.icon:SetPoint("CENTER", 0, 1)
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetSize(53, 53)
	border:SetPoint("TOPLEFT")

	button:SetScript("OnClick", function(_, mouse)
		if mouse == "RightButton" then
			ns.SetEnabled(not ns.DB().enabled)
		else
			ns.ToggleWindow()
		end
		if GameTooltip:IsOwned(button) then ShowTooltip(button) end
	end)
	button:SetScript("OnDragStart", function(self)
		GameTooltip:Hide()
		self:SetScript("OnUpdate", OnDragUpdate)
	end)
	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	button:SetScript("OnEnter", ShowTooltip)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Shown or hidden by the setting, grey while the addon is off.
function ns.UpdateMinimapButton()
	local db = ns.DB()
	if not db.minimapShow then
		if button then button:Hide() end
		return
	end
	if not button then Build() end
	button.icon:SetDesaturated(not db.enabled)
	UpdatePosition()
	button:Show()
end
