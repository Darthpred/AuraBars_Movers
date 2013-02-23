local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

local function configTable()
E.Options.args.unitframe.args.player.args.aurabar.args.width = {
	order = 25,
	type = "range",
	name = L['Width'],
	min = 50, max = 500, step = 1,
	get = function(info) return E.db.unitframe.units.player.abw end,
	set = function(info, value) E.db.unitframe.units.player.abw = value; UF:CreateAndUpdateUF('player') end,
}

E.Options.args.unitframe.args.target.args.aurabar.args.width = {
	order = 25,
	type = "range",
	name = L['Width'],
	min = 50, max = 500, step = 1,
	get = function(info) return E.db.unitframe.units.target.abw end,
	set = function(info, value) E.db.unitframe.units.target.abw = value; UF:CreateAndUpdateUF('target') end,
}

E.Options.args.unitframe.args.focus.args.aurabar.args.width = {
	order = 25,
	type = "range",
	name = L['Width'],
	min = 50, max = 500, step = 1,
	get = function(info) return E.db.unitframe.units.focus.abw end,
	set = function(info, value) E.db.unitframe.units.focus.abw = value; UF:CreateAndUpdateUF('focus') end,
}
end

local ConfFrame = CreateFrame('Frame')
ConfFrame:RegisterEvent('ADDON_LOADED')
ConfFrame:SetScript('OnEvent',function(self, event, addon)
    if addon == 'ElvUI_Config' then
        configTable()
        ConfFrame:UnregisterEvent('ADDON_LOADED')
    end
end)