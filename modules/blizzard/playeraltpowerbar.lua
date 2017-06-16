local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Mine
local isInit = false

function BLIZZARD:HasAltPowerBar()
	return isInit
end

function BLIZZARD:SetUpAltPowerBar()
	if not isInit and C.db.char.blizzard.player_alt_power_bar.enabled then
		_G.PlayerPowerBarAlt.ignoreFramePositionManager = true
		_G.UIPARENT_ALTERNATE_FRAME_POSITIONS["PlayerPowerBarAlt_Top"] = nil
		_G.UIPARENT_ALTERNATE_FRAME_POSITIONS["PlayerPowerBarAlt_Bottom"] = nil
		_G.UIPARENT_MANAGED_FRAME_POSITIONS["PlayerPowerBarAlt"] = nil

		local holder = _G.CreateFrame("Frame", "LSPowerBarAltHolder", _G.UIParent)
		holder:SetSize(64, 64)
		holder:SetPoint("BOTTOM", 0, 230)
		E:CreateMover(holder)

		_G.PlayerPowerBarAlt:SetMovable(true)
		_G.PlayerPowerBarAlt:SetUserPlaced(true)
		_G.PlayerPowerBarAlt:SetParent(holder)
		_G.PlayerPowerBarAlt:ClearAllPoints()
		_G.PlayerPowerBarAlt:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)

		isInit = true

		self.SetUpAltPowerBar = E.NOOP
	end
end
