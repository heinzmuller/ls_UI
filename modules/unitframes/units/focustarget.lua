local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:CreateFocusTargetFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.db.profile.units[E.UI_LAYOUT].focustarget

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-bg", true)
	bg:SetHorizTile(true)

	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 7)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	local text_parent = _G.CreateFrame("Frame", nil, frame)
	text_parent:SetFrameLevel(level + 9)
	text_parent:SetAllPoints()
	frame.TextParent = text_parent

	frame.Insets = self:CreateInsets(frame, fg_parent)

	local health = self:CreateHealth(frame, true, "LS12Font_Shadow", text_parent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("LEFT", frame, "LEFT", 0, 0)
	health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = self:CreateHealthPrediction(health)

	local power = self:CreatePower(frame, true, "LS12Font_Shadow", text_parent)
	power:SetFrameLevel(level + 1)
	power:SetPoint("LEFT", frame, "LEFT", 0, 0)
	power:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	power:SetPoint("TOP", frame.Insets.Bottom, "TOP", 0, -2)
	power:SetPoint("BOTTOM", frame.Insets.Bottom, "BOTTOM", 0, 0)
	frame.Power = power

	power.UpdateContainer = function(_, shouldShow)
		if shouldShow then
			if not frame.Insets.Bottom:IsExpanded() then
				frame.Insets.Bottom:Expand()
			end
		else
			if frame.Insets.Bottom:IsExpanded() then
				frame.Insets.Bottom:Collapse()
			end
		end
	end

	frame.Name = self:CreateName(text_parent, "LS12Font_Shadow")

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(text_parent)

	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	local status = text_parent:CreateFontString(nil, "ARTWORK", "LSStatusIcon16Font")
	status:SetJustifyH("RIGHT")
	status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
	frame:Tag(status, "[ls:questicon][ls:sheepicon][ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")

	E:CreateBorder(fg_parent, true)

	local glass = fg_parent:CreateTexture(nil, "OVERLAY")
	glass:SetAllPoints(health)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-glass", true)
	glass:SetHorizTile(true)

	self:CreateClassIndicator(frame)
end

function UF:UpdateFocusTargetFrame(frame)
	frame._config = C.db.profile.units[E.UI_LAYOUT].focustarget

	frame:SetSize(frame._config.width, frame._config.height)

	self:UpdateInsets(frame)
	self:UpdateHealth(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdatePower(frame)
	self:UpdateName(frame)
	self:UpdateRaidTargetIndicator(frame)
	self:UpdateThreatIndicator(frame)
	self:UpdateClassIndicator(frame)

	frame:UpdateAllElements("LSUI_ToFFrameUpdate")
end
