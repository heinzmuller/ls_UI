local _, ns = ...
local oUF = ns.oUF

local DEFAULT_CONFIG = {
	units = {
		enabled =  true,
		player = {
			enabled = true,
			point = {"BOTTOM", "UIParent", "BOTTOM", -306 , 80},
		},
		pet = {
			enabled = true,
			point = {"RIGHT", "lsPlayerFrame" , "LEFT"},
		},
		target = {
			enabled = true,
			point = {"BOTTOMLEFT", "UIParent", "BOTTOM", 166, 336},
			long = true,
		},
		targettarget = {
			enabled = true,
			point = { "LEFT", "lsTargetFrame", "RIGHT", 14, 0 },
		},
		focus = {
			enabled = true,
			point = { "BOTTOMRIGHT", "UIParent", "BOTTOM", -166, 336},
			long = true,
		},
		focustarget = {
			enabled = true,
			point = { "RIGHT", "lsFocusFrame", "LEFT", -14, 0 },
		},
		party = {
			enabled = true,
			point = {"TOPLEFT", "CompactRaidFrameManager", "TOPRIGHT", 6, 0},
			attributes = {"showPlayer", true, "showParty", true, "showRaid", false, "point", "BOTTOM", "yOffset", 40},
			visibility = "custom [group:raid] hide; [group:party] show; hide",
		},
		boss1 = {
			enabled = true,
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -84, -240},
		},
		boss2 = {
			enabled = true,
			point = {"TOP", "lsBoss1Frame", "BOTTOM", 0, -46},
		},
		boss3 = {
			enabled = true,
			point = {"TOP", "lsBoss2Frame", "BOTTOM", 0, -46},
		},
		boss4 = {
			enabled = true,
			point = {"TOP", "lsBoss3Frame", "BOTTOM", 0, -46},
		},
		boss5 = {
			enabled = true,
			point = {"TOP", "lsBoss4Frame", "BOTTOM", 0, -46},
		},
	},
	auratracker = {
		enabled = true,
		locked = false,
		showHeader = true,
		HELPFUL = {},
		HARMFUL = {},
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		["0"] = { -- for level < 10 and buffer
			HELPFUL = {},
			HARMFUL = {},
		},
		["1"] = {
			HELPFUL = {},
			HARMFUL = {},
		},
		["2"] = {
			HELPFUL = {},
			HARMFUL = {},
		},
		["3"] = {
			HELPFUL = {},
			HARMFUL = {},
		},
		["4"] = {
			HELPFUL = {},
			HARMFUL = {},
		},
	},
	minimap = {
		enabled = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", 306, 86},
	},
	objectivetracker = {
		point = {"RIGHT", "UIParent", "RIGHT", -100, 0},
		locked = false,
	},
	infobars = {
		enabled = true,
		location = {
			enabled = true,
			point = {"TOPLEFT", "UIParent", "TOPLEFT", 4, -4},
		},
		memory = {
			enabled = true,
			point = {"LEFT", "lsLocationInfoBar", "RIGHT", 24, 0},
		},
		fps = {
			enabled = true,
			point = {"LEFT", "lsMemoryInfoBar", "RIGHT", 4, 0},
		},
		latency = {
			enabled = true,
			point = {"LEFT", "lsFPSInfoBar", "RIGHT", 4, 0},
		},
		bag = {
			enabled = true,
			point = {"LEFT", "lsLatencyInfoBar", "RIGHT", 24, 0},
		},
		clock = {
			enabled = true,
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -4, -4},
		},
	},
	nameplates = {
		enabled = true,
		showText = false,
	},
	bars = {
		enabled = true,
		bar1 = { -- MainMenuBar
			point = {"BOTTOM", 0, 15},
			button_size = 28,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar2 = { -- MultiBarBottomLeft
			point = {"BOTTOM", 0, 62},
			button_size = 28,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar3 = { -- MultiBarBottomRight
			point = {"BOTTOM", 0, 94},
			button_size = 28,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar4 = { -- MultiBarLeft
			point = {"BOTTOMRIGHT", -32, 300},
			button_size = 28,
			button_gap = 4,
			orientation = "VERTICAL",
		},
		bar5 = { -- MultiBarRight
			point = {"BOTTOMRIGHT", 0, 300},
			button_size = 28,
			button_gap = 4,
			orientation = "VERTICAL",
		},
		bar6 = { --PetAction
			-- point = {}, -- NYI
			button_size = 24,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar7 = { -- Stance
			-- point = {}, -- NYI
			button_size = 24,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar8 = { -- Bags
			point = {"TOPLEFT", "lsBagInfoBar", "BOTTOM", 0, -4},
			button_size = 28,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar9 = { -- ExtraAction
			point = {"BOTTOM", -171, 154},
			button_size = 40,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar10 = { -- VehicleExit
			point = {"BOTTOM", 171, 154},
			button_size = 40,
			button_gap = 4,
		},
		bar11 = { -- PetBattle
			point = {"BOTTOM", 0, 15},
			button_size = 28,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
		bar12 = { --PlayerPowerBarAlt
			point = {"BOTTOM", 0, 240},
			button_size = 128,
			button_gap = 4,
			orientation = "HORIZONTAL",
		},
	},
	auras = {
		enabled = true,
		buff = {
			point = {"TOPRIGHT", -4, -42},
		},
		debuff = {
			point = {"TOPRIGHT", -4, -122},
		},
		tempench = {
			point = {"TOPRIGHT", -4, -162},
		},
		aura_size = 28,
		aura_gap = 4,
	},
	mail = {
		enabled = true,
	},
	width = 0,
	height = 0,
	playerclass = "",
}

local ConfigLoader = CreateFrame("Frame")
ConfigLoader:RegisterEvent("ADDON_LOADED")
ConfigLoader:RegisterEvent("PLAYER_LOGOUT")

local function lsConfigLoader_OnEvent(...)
	local _, event, arg3 = ...
	if event == "ADDON_LOADED" then
		if arg3 ~= "oUF_LS" then return end

		local function initDB(db, defaults)
			if type(db) ~= "table" then db = {} end
			if type(defaults) ~= "table" then return db end
			for k, v in pairs(defaults) do
				if type(v) == "table" then
					db[k] = initDB(db[k], v)
				elseif type(v) ~= type(db[k]) then
					db[k] = v
				end
			end
			return db
		end

		-- use bar manager with default settings only
		local enableActionBarManager = true
		if oUF_LS_CONFIG and oUF_LS_CONFIG.bars and (oUF_LS_CONFIG.bars.bar1
			or oUF_LS_CONFIG.bars.bar2 or oUF_LS_CONFIG.bars.bar3
			or oUF_LS_CONFIG.bars.bar6 or oUF_LS_CONFIG.bars.bar7) then
			enableActionBarManager = false
		end

		oUF_LS_CONFIG = initDB(oUF_LS_CONFIG, DEFAULT_CONFIG)
		ns.C = oUF_LS_CONFIG

		ns.C.width, ns.C.height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")
		ns.C.playerclass = select(2, UnitClass("player"))

		-- Minimap
		if ns.C.minimap.enabled then
			LoadAddOn("Blizzard_TimeManager")
			ns.lsMinimap_Initialize()
		end

		-- Player buffs/debuffs/tempenchants
		if ns.C.auras.enabled then
			ns.lsBuffFrame_Initialize()
		end

		-- Infobars
		if ns.C.infobars.enabled then
			ns.lsInfobars_Initialize()
		end

		-- Actionbars & MicroMenu
		if ns.C.bars.enabled then
			ns.lsActionBars_Initialize(enableActionBarManager)
			ns.lsMicroMenu_Initialize()
		end

		-- NamePlates
		if ns.C.nameplates.enabled then
			ns.lsNamePlates_Initialize()
		end

		-- AuraTracker
		ns.lsAuraTracker_Initialize()

		-- ObjectiveTracker
		ns.lsOTDragHeader_Initialize()

		--Mail
		ns.Mail:Initialize()

		if ns.C.units.enabled then
			oUF:Factory(ns.lsFactory)
		end
	elseif event == "PLAYER_LOGOUT" then
		local function cleanDB(db, defaults)
			if type(db) ~= "table" then return {} end
			if type(defaults) ~= "table" then return db end
			for k, v in pairs(db) do
				if type(v) == "table" then
					if not next(cleanDB(v, defaults[k])) then
						db[k] = nil
					end
				elseif v == defaults[k] then
					db[k] = nil
				end
			end
			return db
		end

		oUF_LS_CONFIG = cleanDB(oUF_LS_CONFIG, DEFAULT_CONFIG)
	end
end

ConfigLoader:SetScript("OnEvent", lsConfigLoader_OnEvent)