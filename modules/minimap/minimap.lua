local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MINIMAP = P:AddModule("Minimap")

-- Lua
local _G = getfenv(0)
local next = _G.next
local unpack = _G.unpack
local m_floor = _G.math.floor
local s_match = _G.string.match

-- Blizz
local CALENDAR_EVENT_ALARM_MESSAGE = _G.CALENDAR_EVENT_ALARM_MESSAGE
local GAMETIME_TOOLTIP_CALENDAR_INVITES = _G.GAMETIME_TOOLTIP_CALENDAR_INVITES
local GAMETIME_TOOLTIP_TOGGLE_CALENDAR = _G.GAMETIME_TOOLTIP_TOGGLE_CALENDAR
local CalendarGetDate = _G.CalendarGetDate
local GameTooltip = _G.GameTooltip
local GetMinimapZoneText = _G.GetMinimapZoneText
local GetZonePVPInfo = _G.GetZonePVPInfo
local Minimap = _G.Minimap
local Minimap_ZoomIn = _G.Minimap_ZoomIn
local Minimap_ZoomOut = _G.Minimap_ZoomOut

-- Mine
local DELAY = 337.5 -- 256 * 337.5 = 86400 = 24H
local STEP = 0.00390625 -- 1 / 256
local isInit = false

local TEXTURES = {
	BIG = {
		size = {88 / 2, 88 / 2},
		coords = {1 / 256, 89 / 256, 1 / 256, 89 / 256},
	},
	SMALL = {
		size = {72 / 2, 72 / 2},
		coords = {90 / 256, 162 / 256, 1 / 256, 73 / 256},
	},
}

local WIDGETS = {
	GameTimeFrame = {"CENTER", 60, 60},
	GarrisonLandingPageMinimapButton = {"CENTER", -57, -57},
	GuildInstanceDifficulty = {"TOP", "Minimap", "BOTTOM", -2, 8},
	MiniMapChallengeMode = {"TOP", "Minimap", "BOTTOM", 0, 2},
	MiniMapInstanceDifficulty = {"TOP", "Minimap", "BOTTOM", 0, 7},
	MiniMapMailFrame = {"CENTER", -57, 57},
	MiniMapTracking = {"CENTER", 74, 32},
	QueueStatusMinimapButton = {"CENTER", 57, -57},
	TimeManagerClockButton = {"BOTTOM", "Minimap", "TOP", 0, -14},
}

local ZONE_COLORS = {
	["sanctuary"] = M.COLORS.LIGHT_BLUE,
	["arena"] = M.COLORS.RED,
	["combat"] = M.COLORS.RED,
	["hostile"] = M.COLORS.RED,
	["contested"] = M.COLORS.YELLOW,
	["friendly"] = M.COLORS.GREEN,
	["other"] = M.COLORS.YELLOW
}

local function HandleMinimapButton(button, cascade)
	local regions = {button:GetRegions()}
	local children = {button:GetChildren()}
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local pushed = button.GetPushedTexture and button:GetPushedTexture()
	local hl, icon, border, bg, thl, ticon, tborder, tbg, tnormal, tpushed

	-- print("====|cffff0000", button:GetDebugName(), "|r:", #children, #regions,"====")

	for _, region in next, regions do
		if region:IsObjectType("Texture") then
			local name = region:GetDebugName()
			local texture = region:GetTexture()
			local layer = region:GetDrawLayer()
			-- print("|cffffff00", name, "|r:", texture, layer)

			if layer == "HIGHLIGHT" then
				hl = region
			elseif not normal and not pushed then
				if layer == "ARTWORK" or layer == "BACKGROUND" then
					if button.icon and region == button.icon then
						-- print("|cffffff00", name, "|ris |cff00ff00.icon|r", region, button.icon)
						icon = region
					elseif button.Icon and region == button.Icon then
						-- print("|cffffff00", name, "|ris |cff00ff00.Icon|r")
						icon = region
						-- ignore all LDBIcons
					elseif name and not s_match(name, "^LibDBIcon") and s_match(name, "[iI][cC][oO][nN]") then
						-- print("|cffffff00", name, "|ris |cff00ff00icon|r")
						icon = region
					elseif texture and s_match(texture, "[iI][cC][oO][nN]") then
						-- print("|cffffff00", name, "|ris |cff00ff00-icon|r")
						icon = region
					elseif texture and texture == 136467 then
						bg = region
					elseif texture and s_match(texture, "[bB][aA][cC][kK][gG][rR][oO][uU][nN][dD]") then
						-- print("|cffffff00", name, "|ris |cff00ff00-background|r")
						bg = region
					end
				elseif layer == "OVERLAY" or layer == "BORDER" then
					if button.border and button.border == region then
						-- print("|cffffff00", name, "|ris |cff00ff00.border|r")
						border = region
					elseif button.Border and button.Border == region then
						-- print("|cffffff00", name, "|ris |cff00ff00.Border|r")
						border = region
					elseif s_match(name, "[bB][oO][rR][dD][eE][rR]") then
						-- print("|cffffff00", name, "|ris |cff00ff00border|r")
						border = region
					elseif texture and texture == 136430 then
						-- print("|cffffff00", name, "|ris |cff00ff00#136430|r")
						border = region
					elseif texture and s_match(texture, "[bB][oO][rR][dD][eE][rR]") then
						-- print("|cffffff00", name, "|ris |cff00ff00-TrackingBorder|r")
						border = region
					end
				end
			end
		end
	end

	for _, child in next, children do
		local name = child:GetDebugName()
		local oType = child:GetObjectType()
		-- print("|cffffff00", name, "|r:", oType)

		if oType == "Frame" then
			if name and s_match(name, "[iI][cC][oO][nN]") then
				icon = child
			end
		elseif oType == "Button" then
			thl, ticon, tborder, tbg, tnormal, tpushed = HandleMinimapButton(child, true)
		end
	end

	normal = normal or tnormal
	pushed = pushed or tpushed
	hl = hl or thl
	icon = icon or ticon
	border = border or tborder
	bg = bg or tbg

	if not cascade then
		-- These aren't the dro- buttons you're looking for
		if not icon and not (normal and pushed) then return end

		local t = button == _G.GameTimeFrame and "BIG" or "SMALL"
		local offset = button == _G.GarrisonLandingPageMinimapButton and 0 or 9

		button:SetSize(unpack(TEXTURES[t].size))
		button:SetHitRectInsets(0, 0, 0, 0)

		if hl then
			hl:ClearAllPoints()
			hl:SetAllPoints(button)
		end

		if normal and pushed then
			normal:SetDrawLayer("ARTWORK", 0)
			normal:ClearAllPoints()
			normal:SetPoint("TOPLEFT", offset, -offset)
			normal:SetPoint("BOTTOMRIGHT", -offset, offset)
			button.NormalTexture = normal

			pushed:SetDrawLayer("ARTWORK", 0)
			pushed:ClearAllPoints()
			pushed:SetPoint("TOPLEFT", offset, -offset)
			pushed:SetPoint("BOTTOMRIGHT", -offset, offset)
			button.PushedTexture = pushed
		elseif icon then
			if icon:IsObjectType("Texture") then
				icon:SetDrawLayer("ARTWORK", 0)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", offset, -offset)
				icon:SetPoint("BOTTOMRIGHT", -offset, offset)
			else
				icon:SetFrameLevel(4)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", offset, -offset)
				icon:SetPoint("BOTTOMRIGHT", -offset, offset)
			end

			button.Icon = icon
		end

		if not border then
			border = button:CreateTexture()
		end

		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		border:SetTexCoord(unpack(TEXTURES[t].coords))
		border:SetDrawLayer("ARTWORK", 1)
		border:SetAllPoints(button)
		button.Border = border

		if not bg then
			bg = button:CreateTexture()
		end

		bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
		bg:SetVertexColor(M.COLORS.BLACK:GetRGBA(0.8))
		bg:SetDrawLayer("BACKGROUND", 0)
		bg:ClearAllPoints()
		bg:SetPoint("TOPLEFT", 6, -6)
		bg:SetPoint("BOTTOMRIGHT", -6, 6)
		bg:SetAlpha(1)
		button.Background = bg

		return button
	else
		return hl, icon, border, bg, normal, pushed
	end
end

local function UpdateZoneInfo()
	Minimap.ZoneText:SetText(ZONE_COLORS[GetZonePVPInfo() or "other"]:WrapText(GetMinimapZoneText() or L["UNKNOWN"]))
end

-- Horizontal texture scrolling
local function CheckTexPoint(point, base)
	if point then
		return point >= base / 256 + 1 and base / 256 or point
	else
		return base / 256
	end
end

local function ScrollTexture(t, delay, offset)
	t.l = CheckTexPoint(t.l, 64) + offset
	t.r = CheckTexPoint(t.r, 192) + offset

	t:SetTexCoord(t.l, t.r, 0 / 128, 128 / 128)

	_G.C_Timer.After(delay, function() ScrollTexture(t, DELAY, STEP) end)
end

local function Minimap_OnEnter(self)
	self.ZoneText:Show()
end

local function Minimap_OnLeave(self)
	self.ZoneText:Hide()
end

local function Minimap_OnMouseWheel(_, direction)
	if direction > 0 then
		Minimap_ZoomIn()
	else
		Minimap_ZoomOut()
	end
end

local function Minimap_OnEvent(_, event)
	if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
		UpdateZoneInfo()
	end
end

-- Calendar
local function Calendar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT", 4, -4)

	if self.pendingCalendarInvites > 0 then
		GameTooltip:AddLine(GAMETIME_TOOLTIP_CALENDAR_INVITES)
	end

	GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CALENDAR)
	GameTooltip:Show()
end

local function Calendar_OnLeave()
	GameTooltip:Hide()
end

local function Calendar_OnClick(self)
	if self.InvIndicator.Blink and self.InvIndicator.Blink:IsPlaying() then
		E:StopBlink(self.InvIndicator, 1)

		self.pendingCalendarInvites = 0
	end

	_G.ToggleCalendar()
end

local function Calendar_OnEvent(self, event, ...)
	if event == "CALENDAR_UPDATE_PENDING_INVITES" or event == "PLAYER_ENTERING_WORLD" then
		local pendingCalendarInvites = _G.CalendarGetNumPendingInvites()

		if pendingCalendarInvites > self.pendingCalendarInvites then
			if not _G.CalendarFrame or (_G.CalendarFrame and not _G.CalendarFrame:IsShown()) then
				E:Blink(self.InvIndicator, nil, 0, 1)

				self.pendingCalendarInvites = pendingCalendarInvites
			end
		elseif pendingCalendarInvites == 0 then
			E:StopBlink(self.InvIndicator)
		end
	elseif event == "CALENDAR_EVENT_ALARM" then
		local title = ...
		local info = _G.ChatTypeInfo["SYSTEM"]

		_G.DEFAULT_CHAT_FRAME:AddMessage(CALENDAR_EVENT_ALARM_MESSAGE:format(title), info.r, info.g, info.b, info.id)
	end
end

local function Calendar_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 1 then
		local _, _, day = CalendarGetDate()
		self:SetText(day)

		self.elapsed = 0
	end
end

function MINIMAP:IsInit()
	return isInit
end

function MINIMAP:Init()
	if not isInit and C.db.char.minimap.enabled then
		if not _G.IsAddOnLoaded("Blizzard_TimeManager") then
			_G.LoadAddOn("Blizzard_TimeManager")
		end

		local holder = _G.CreateFrame("Frame", "LSMinimapHolder", _G.UIParent)
		holder:SetSize(332 / 2, 332 / 2)
		holder:SetPoint(unpack(C.db.profile.minimap[E.UI_LAYOUT].point))
		E:CreateMover(holder)

		Minimap:EnableMouseWheel()
		Minimap:SetParent(holder)
		Minimap:ClearAllPoints()
		Minimap:SetPoint("CENTER")
		Minimap:SetSize(146, 146)
		Minimap:RegisterEvent("ZONE_CHANGED")
		Minimap:RegisterEvent("ZONE_CHANGED_INDOORS")
		Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		Minimap:HookScript("OnEvent", Minimap_OnEvent)
		Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)

		_G.RegisterStateDriver(Minimap, "visibility", "[petbattle] hide; show")

		local border = Minimap:CreateTexture(nil, "BORDER")
		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap")
		border:SetTexCoord(1 / 512, 333 / 512, 1 / 512, 333 / 512)
		border:SetSize(332 / 2, 332 / 2)
		border:SetPoint("CENTER", 0, 0)

		for name, coords in next, WIDGETS do
			_G[name]:ClearAllPoints()
			_G[name]:SetParent(Minimap)
			_G[name]:SetPoint(unpack(coords))
		end

		for _, name in next, {
			"MinimapCluster",
			"MiniMapWorldMapButton",
			"MinimapZoomIn",
			"MinimapZoomOut",
			"MiniMapRecordingButton",
			"MinimapZoneTextButton",
			"MinimapBorder",
			"MinimapBorderTop",
			"MinimapBackdrop",
			"MiniMapTrackingIconOverlay",
		} do
			E:ForceHide(_G[name])
		end

		-- Garrison
		HandleMinimapButton(_G.GarrisonLandingPageMinimapButton)

		-- Mail
		local mail = HandleMinimapButton(_G.MiniMapMailFrame)
		mail.Icon:SetPoint("TOPLEFT", 8, -8)
		mail.Icon:SetPoint("BOTTOMRIGHT", -8, 8)

		-- Queue
		local queue = HandleMinimapButton(_G.QueueStatusMinimapButton)
		queue.Background:SetTexture("")
		_G.QueueStatusFrame:ClearAllPoints()
		_G.QueueStatusFrame:SetPoint("BOTTOMRIGHT", queue, "TOPLEFT", 8, -8)

		-- Calendar
		local calendar = HandleMinimapButton(_G.GameTimeFrame)
		calendar:SetNormalFontObject("LS16Font_Outline")
		calendar:SetPushedTextOffset(1, -1)
		calendar.NormalTexture:SetTexture("")
		calendar.PushedTexture:SetTexture("")
		calendar.pendingCalendarInvites = 0
		calendar:SetScript("OnEnter", Calendar_OnEnter)
		calendar:SetScript("OnLeave", Calendar_OnLeave)
		calendar:SetScript("OnEvent", Calendar_OnEvent)
		calendar:SetScript("OnClick", Calendar_OnClick)
		calendar:SetScript("OnUpdate", Calendar_OnUpdate)

		local mask = calendar:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetPoint("TOPLEFT", 6, -6)
		mask:SetPoint("BOTTOMRIGHT", -6, 6)

		local indicator = calendar:CreateTexture(nil, "BACKGROUND", nil, 1)
		indicator:SetTexture("Interface\\Minimap\\HumanUITile-TimeIndicator", true)
		indicator:AddMaskTexture(mask)
		indicator:SetPoint("TOPLEFT", 6, -6)
		indicator:SetPoint("BOTTOMRIGHT", -6, 6)
		calendar.DayTimeIndicator = indicator

		local _, mark, glow, _, date = calendar:GetRegions()
		mark:SetDrawLayer("OVERLAY", 2)
		mark:SetTexCoord(7 / 128, 81 / 128, 7 / 128, 109 / 128)
		mark:SetSize(22, 30)
		mark:SetPoint("CENTER", 0, 0)
		mark:Show()
		mark:SetAlpha(0)
		calendar.InvIndicator = mark

		glow:SetTexture("")

		date:ClearAllPoints()
		date:SetPoint("TOPLEFT", 9, -8)
		date:SetPoint("BOTTOMRIGHT", -8, 9)
		date:SetVertexColor(M.COLORS.WHITE:GetRGB())
		date:SetDrawLayer("BACKGROUND")
		date:SetJustifyH("CENTER")
		date:SetJustifyV("MIDDLE")

		-- Zone Text
		local zoneText = _G.MinimapZoneText
		zoneText:SetFontObject("LS12Font_Shadow")
		zoneText:SetParent(Minimap)
		zoneText:SetWidth(0)
		zoneText:ClearAllPoints()
		zoneText:SetPoint("TOPLEFT", 2, 28)
		zoneText:SetPoint("TOPRIGHT", -2, 28)
		zoneText:Hide()
		Minimap.ZoneText = zoneText

		-- Clock
		local clock = _G.TimeManagerClockButton
		clock:SetSize(104/ 2, 56 / 2)
		clock:SetHitRectInsets(0, 0, 0, 0)
		clock:SetScript("OnMouseUp", nil)
		clock:SetScript("OnMouseDown", nil)
		clock:SetHighlightTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons", "ADD")
		clock:GetHighlightTexture():SetTexCoord(106 / 256, 210 / 256, 90 / 256, 146 / 256)
		clock:SetPushedTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		clock:GetPushedTexture():SetBlendMode("ADD")
		clock:GetPushedTexture():SetTexCoord(1 / 256, 105 / 256, 147 / 256, 203 / 256)

		local bg, ticker, glow = clock:GetRegions()

		bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		bg:SetTexCoord(1 / 256, 105 / 256, 90 / 256, 146 / 256)

		ticker:ClearAllPoints()
		ticker:SetPoint("TOPLEFT", 8, -8)
		ticker:SetPoint("BOTTOMRIGHT", -8, 8)
		ticker:SetJustifyH("CENTER")
		ticker:SetJustifyV("MIDDLE")
		clock.Ticker = ticker

		glow:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		glow:SetTexCoord(1 / 256, 105 / 256, 147 / 256, 203 / 256)

		-- Compass
		_G.MinimapCompassTexture:SetParent(Minimap)
		_G.MinimapCompassTexture:ClearAllPoints()
		_G.MinimapCompassTexture:SetPoint("CENTER", 0, 0)

		-- Queue
		_G.QueueStatusMinimapButton.Icon:SetAllPoints()

		-- Misc
		HandleMinimapButton(_G.MiniMapTracking)
		HandleMinimapButton(_G.MiniMapVoiceChatFrame)

		for _, child in next, {Minimap:GetChildren()} do
			child:SetFrameLevel(Minimap:GetFrameLevel() + 1)

			if child:IsObjectType("Button") and not WIDGETS[child:GetName()] then
				if not child:IsShown() then
					child:Show()

					HandleMinimapButton(child)

					child:Hide()
				else
					HandleMinimapButton(child)
				end
			end
		end

		local h, m = _G.GetGameTime()
		local s = (h * 60 + m) * 60
		local mult = m_floor(s / DELAY)

		ScrollTexture(indicator, (mult + 1) * DELAY - s, STEP * mult)

		UpdateZoneInfo()

		isInit = true

		self:Update()
	end
end

function MINIMAP:Update()
	if isInit then
		local config = C.db.profile.minimap[E.UI_LAYOUT]

		if config.zone_text.mode == 0 then
			Minimap:SetScript("OnEnter", nil)
			Minimap:SetScript("OnLeave", nil)

			Minimap.ZoneText:Hide()
		elseif config.zone_text.mode == 1 then
			Minimap:SetScript("OnEnter", Minimap_OnEnter)
			Minimap:SetScript("OnLeave", Minimap_OnLeave)

			Minimap.ZoneText:Hide()
		elseif config.zone_text.mode == 2 then
			Minimap:SetScript("OnEnter", nil)
			Minimap:SetScript("OnLeave", nil)

			Minimap.ZoneText:Show()
		end
	end
end
