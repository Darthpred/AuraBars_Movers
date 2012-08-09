local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local ABM = E:NewModule('AuraMover', 'AceHook-3.0', 'AceEvent-3.0');
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

function ABM:PlayerABmove()
	local auraBar = ElvUF_Player.AuraBars
	--Create Holder frame for our AuraBar Mover
	local holder = CreateFrame('Frame', nil, auraBar)
	holder:Point("BOTTOM", ElvUF_Player, "TOP", 0, 0)
	auraBar:SetPoint("BOTTOM", holder, "TOP", 0, 0)
	auraBar.Holder = holder
	
	E:CreateMover(auraBar.Holder, 'ElvUF_PlayerAuraMover',  "Player Aura Bars", nil, nil, nil, 'ALL,SOLO')
	UF:CreateAndUpdateUF('player')
end

function ABM:TargetABmove()
	local auraBar = ElvUF_Target.AuraBars
	--Create Holder frame for our AuraBar Mover
	local holder = CreateFrame('Frame', nil, auraBar)
	holder:Point("BOTTOM", ElvUF_Target, "TOP", 0, 0)
	auraBar:SetPoint("BOTTOM", holder, "TOP", 0, 0)
	auraBar.Holder = holder
	
	E:CreateMover(auraBar.Holder, 'ElvUF_TargetAuraMover',  "Target Aura Bars", nil, nil, nil, 'ALL,SOLO')
	UF:CreateAndUpdateUF('target')
end

function ABM:FocusABmove()
	local auraBar = ElvUF_Focus.AuraBars
	--Create Holder frame for our AuraBar Mover
	local holder = CreateFrame('Frame', nil, auraBar)
	holder:Point("BOTTOM", ElvUF_Focus, "TOP", 0, 0)
	auraBar:SetPoint("BOTTOM", holder, "TOP", 0, 0)
	auraBar.Holder = holder
	
	E:CreateMover(auraBar.Holder, 'ElvUF_FocusAuraMover',  "Focus Aura Bars", nil, nil, nil, 'ALL,SOLO')
	--UF:CreateAndUpdateUF('focus')
end


function ABM:Initialize()
	ABM:PlayerABmove()
	ABM:TargetABmove()
	ABM:FocusABmove()
end


E:RegisterModule(ABM:GetName())

--[[function UF:Construct_AuraBarHeader(frame)
	local auraBar = CreateFrame('Frame', nil, frame)
	auraBar.PostCreateBar = UF.Construct_AuraBars
	auraBar.gap = 1
	auraBar.spacing = 1
	auraBar.spark = true
	auraBar.sort = true
	auraBar.debuffColor = {0.8, 0.1, 0.1}
	auraBar.filter = UF.AuraBarFilter

	--Create Holder frame for our AuraBar Mover
	local holder = CreateFrame('Frame', nil, auraBar)
	holder:Point("BOTTOM", frame, "TOP", 0, 0)
	auraBar:SetPoint("BOTTOM", holder, "TOP", 0, 0)
	auraBar.Holder = holder
	
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
		if self.auraBarLine and self.numLines ~= self:NumLines() then
			self:AddLine(L['Hold shift + right click to blacklist this aura.'])
			if not self.numLines then
				self.numLines = self:NumLines()
			end
		end
	end)	
	
	--Create the AuraBar Mover
	if MovName then
		E:CreateMover(auraBar.Holder, frame:GetName()..'AuraMover',  MovName, nil, nil, nil, 'ALL,SOLO')
	end
	print("1")
	return auraBar
end]]