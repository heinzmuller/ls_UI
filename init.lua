local name, ns = ...

-- Lua
local _G = getfenv(0)

-- Mine
local E = _G.LibStub("AceAddon-3.0"):NewAddon(name) -- engine
local C, D, M, L, P = {}, {}, {}, {}, {} -- config, defaults, media, locales, private
ns.E, ns.C, ns.D, ns.M, ns.L, ns.P = E, C, D, M, L, P

_G[name] = {
	[1] = ns.E,
	[2] = ns.M,
	[3] = ns.C,
}

local function ConvertConfig(old, base)
	local temp = {}

	for k, v in next, base do
		if old[k] ~= nil then
			if type(v) == "table" then
				if next(v) then
					temp[k] = ConvertConfig(old[k], v)
				else
					temp[k] = old[k]
				end
			else
				if old[k] ~= v then
					temp[k] = old[k]
				end

				old[k] = nil
			end
		end
	end

	return temp
end

local function UpdateAll()
	P:UpdateModules()
end

function E:OnInitialize()
	C.db = _G.LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	_G.LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	-- layout type change shouldn't affect anything after SVs are loaded
	E.UI_LAYOUT = C.db.char.layout

	-- -> 70200.07
	-- old config conversion
	if _G.LS_UI_CONFIG then
		_G.LS_UI_CONFIG.version = nil

		self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG, D.char), C.db.char)

		if _G.LS_UI_CONFIG.auras then
			self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG.auras, D.profile.auras.ls), C.db.profile.auras.ls)

			_G.LS_UI_CONFIG.auras = nil
		end

		if _G.LS_UI_CONFIG.units then
			self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG.units, D.profile.units.ls), C.db.profile.units.ls)

			_G.LS_UI_CONFIG.units = nil
		end

		if _G.LS_UI_CONFIG.minimap then
			self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG.minimap, D.profile.minimap.ls), C.db.profile.minimap.ls)

			_G.LS_UI_CONFIG.minimap = nil
		end

		if _G.LS_UI_CONFIG.movers then
			_G.LS_UI_CONFIG.movers.LSPetFrameMover = nil
			_G.LS_UI_CONFIG.movers.LSFocusTargetFrameMover = nil
			_G.LS_UI_CONFIG.movers.LSTargetTargetFrameMover = nil

			self:CopyTable(_G.LS_UI_CONFIG.movers, C.db.profile.movers.ls)

			_G.LS_UI_CONFIG.movers = nil
		end

		if _G.LS_UI_CONFIG.auratracker then
			if _G.LS_UI_CONFIG.auratracker.HELPFUL then
				self:CopyTable(_G.LS_UI_CONFIG.auratracker.HELPFUL, C.db.char.auratracker.filter.HELPFUL)

				for k in next, C.db.char.auratracker.filter.HELPFUL do
					C.db.char.auratracker.filter.HELPFUL[k] = true
				end
			end

			if _G.LS_UI_CONFIG.auratracker.HARMFUL then
				self:CopyTable(_G.LS_UI_CONFIG.auratracker.HARMFUL, C.db.char.auratracker.filter.HARMFUL)

				for k in next, C.db.char.auratracker.filter.HARMFUL do
					C.db.char.auratracker.filter.HARMFUL[k] = true
				end
			end

			_G.LS_UI_CONFIG.auratracker = nil
		end

		self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG, D.profile), C.db.profile)
	end

	-- -> 70200.08
	if not C.db.profile.version or C.db.profile.version < 7020008 then
		if C.db.profile.auratracker then
			if C.db.profile.auratracker.HELPFUL then
				self:CopyTable(C.db.profile.auratracker.HELPFUL, C.db.char.auratracker.filter.HELPFUL)

				for k in next, C.db.char.auratracker.filter.HELPFUL do
					C.db.char.auratracker.filter.HELPFUL[k] = true
				end
			end

			if C.db.profile.auratracker.HARMFUL then
				self:CopyTable(C.db.profile.auratracker.HARMFUL, C.db.char.auratracker.filter.HARMFUL)

				for k in next, C.db.char.auratracker.filter.HARMFUL do
					C.db.char.auratracker.filter.HARMFUL[k] = true
				end
			end

			C.db.profile.auratracker = nil
		end

		C.db.profile.tooltips.show_id = nil
		C.db.profile.tooltips.unit = nil

		for i = 1, 7 do
			C.db.profile.bars["bar"..i].button_gap = nil
			C.db.profile.bars["bar"..i].button_size = nil
			C.db.profile.bars["bar"..i].buttons_per_row = nil
			C.db.profile.bars["bar"..i].init_anchor = nil
		end

		C.db.profile.bars.bags.visible = nil
		C.db.profile.bars.bags.button_gap = nil
		C.db.profile.bars.bags.button_size = nil
		C.db.profile.bars.bags.buttons_per_row = nil
		C.db.profile.bars.bags.init_anchor = nil

		C.db.profile.bars.extra.visible = nil
		C.db.profile.bars.extra.button_size = nil

		C.db.profile.bars.zone.visible = nil
		C.db.profile.bars.zone.button_size = nil

		C.db.profile.bars.vehicle.visible = nil
		C.db.profile.bars.vehicle.button_size = nil

		C.db.profile.bars.garrison = nil

		C.db.profile.bars.micromenu.visible = nil

		for _, v in next, C.db.profile.units.ls do
			if v.auras then
				v.auras.show_boss = nil
				v.auras.show_mount = nil
				v.auras.show_selfcast = nil
				v.auras.show_selfcast_permanent = nil
				v.auras.show_blizzard = nil
				v.auras.show_player = nil
				v.auras.show_dispellable = nil
				v.auras.y_grwoth = nil
				v.auras.init_anchor = nil
			end
		end

		for _, v in next, C.db.profile.units.traditional do
			if v.auras then
				v.auras.show_boss = nil
				v.auras.show_mount = nil
				v.auras.show_selfcast = nil
				v.auras.show_selfcast_permanent = nil
				v.auras.show_blizzard = nil
				v.auras.show_player = nil
				v.auras.show_dispellable = nil
				v.auras.y_grwoth = nil
				v.auras.init_anchor = nil
			end
		end
	end

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.char.version = E.VER.number
		C.db.profile.version = E.VER.number

		E:CleanUpMoverConfig()
	end)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = E.VER.number

		E:CleanUpMoverConfig()
	end)

	C.db:RegisterCallback("OnProfileChanged", UpdateAll)
	C.db:RegisterCallback("OnProfileCopied", UpdateAll)
	C.db:RegisterCallback("OnProfileReset", UpdateAll)

	self:RegisterEvent("PLAYER_LOGIN", function()
		E:UpdateConstants()

		P:InitModules()
	end)

	-- No one needs to see these
	ns.C, ns.D, ns.L, ns.P = nil, nil, nil, nil
end
