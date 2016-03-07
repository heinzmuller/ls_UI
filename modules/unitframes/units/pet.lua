local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

function UF:ConstructPetFrame(frame)
	tinsert(UF.framesByUnit["pet"], frame)

	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(42, 134)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	bg:SetTexCoord(84 / 256, 126 / 256, 0, 134 / 256)

	local cover = CreateFrame("Frame", "$parentCover", frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local tubes = cover:CreateTexture(nil, "ARTWORK", nil, 0)
	tubes:SetAllPoints()
	tubes:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	tubes:SetTexCoord(0, 42 / 256, 0, 134 / 256)

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fg:SetAllPoints()
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	fg:SetTexCoord(42 / 256, 84 / 256, 0, 134 / 256)

	local health = UF:CreateHealthBar(frame, 12, nil, true)
	health:SetFrameLevel(level + 1)
	health:SetSize(8, 112)
	health:SetPoint("CENTER", -6, 0)
	tinsert(frame.mouseovers, health)
	frame.Health = health

	local healthValue = E:CreateFontString(cover, 12, "$parentHealthValue", true)
	healthValue:SetJustifyH("RIGHT")
	healthValue:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 26)
	frame.Health.Value = healthValue

	frame.HealPrediction = UF:CreateHealPrediction(frame, true)

	frame.Power = UF:CreatePowerBar(frame, 12, nil, true)
	frame.Power:SetFrameLevel(level + 2)
	frame.Power:SetSize(8, 102)
	frame.Power:SetPoint("CENTER", 6, 0)
	frame.Power.Value:SetJustifyH("RIGHT")
	frame.Power.Value:SetParent(cover)
	frame.Power.Value:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 14)
	tinsert(frame.mouseovers, frame.Power)

	local debuffStatus = E:CreateFontString(cover, 12, "$parentDebuffStatus")
	debuffStatus:SetWidth(14)
	debuffStatus:SetWordWrap(true)
	debuffStatus:SetDrawLayer("OVERLAY")
	debuffStatus:SetPoint("CENTER")
	frame:Tag(debuffStatus, "[ls:debuffstatus]")

	if C.units.pet.castbar then
		frame.Castbar = UF:CreateCastBar(frame, 196, nil, nil, true, true)
		frame.Castbar.Holder:SetPoint("BOTTOM", LSPlayerFrameCastBarHolder, "TOP", 0, 4)
		RegisterStateDriver(frame.Castbar.Holder, "visibility", "[possessbar] show; hide")
	end

	local threat = UF:CreateThreat(frame)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	threat:SetTexCoord(126 / 256, 168 / 256, 0 / 256, 100 / 256)
	threat:SetSize(42, 100)
	threat:SetPoint("CENTER", 0, 18)
	frame.Threat = threat
end
