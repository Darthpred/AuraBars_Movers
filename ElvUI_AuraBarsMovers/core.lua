local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local ABM = E:NewModule('AuraMover', 'AceHook-3.0', 'AceEvent-3.0');
local UF = E:GetModule('UnitFrames');
local targetInsert = false
local focusInsert = false

P.unitframe.units.player.abw = E.db.unitframe.units.player.width
P.unitframe.units.target.abw = E.db.unitframe.units.target.width
P.unitframe.units.focus.abw = E.db.unitframe.units.focus.width

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

UF.SmartAuraDisplayABM = UF.SmartAuraDisplay
function UF:SmartAuraDisplay()
	UF.SmartAuraDisplayABM(self)
	local db = self.db
	local unit = self.unit
	if not db or not db.smartAuraDisplay or db.smartAuraDisplay == 'DISABLED' or not UnitExists(unit) then return; end
	local buffs = self.Buffs
	local debuffs = self.Debuffs
	local auraBars = self.AuraBars
	local isFriend
	if UnitIsFriend('player', unit) then isFriend = true end

	if isFriend then
		if db.smartAuraDisplay == 'SHOW_DEBUFFS_ON_FRIENDLIES' then
			buffs:Hide()
			debuffs:Show()
		else
			buffs:Show()
			debuffs:Hide()		
		end
	else
		if db.smartAuraDisplay == 'SHOW_DEBUFFS_ON_FRIENDLIES' then
			buffs:Show()
			debuffs:Hide()
		else
			buffs:Hide()
			debuffs:Show()		
		end
	end
	
	if buffs:IsShown() then
		local x, y = E:GetXYOffset(db.buffs.anchorPoint)
		
		buffs:ClearAllPoints()
		buffs:Point(E.InversePoints[db.buffs.anchorPoint], self, db.buffs.anchorPoint, x, y)
		
		local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
		if db.aurabar.anchorPoint == 'BELOW' then
			anchorPoint, anchorTo = 'TOP', 'BOTTOM'
		end		
		auraBars:ClearAllPoints()
		auraBars:SetPoint(anchorPoint..'LEFT', auraBars.Holder, anchorTo..'LEFT', 0, 0)
		auraBars:SetPoint(anchorPoint..'RIGHT', auraBars.Holder, anchorTo..'RIGHT')
	end
	
	if debuffs:IsShown() then
		local x, y = E:GetXYOffset(db.debuffs.anchorPoint)
		
		debuffs:ClearAllPoints()
		debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], self, db.debuffs.anchorPoint, x, y)	

		local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
		if db.aurabar.anchorPoint == 'BELOW' then
			anchorPoint, anchorTo = 'TOP', 'BOTTOM'
		end		
		auraBars:ClearAllPoints()
		auraBars:SetPoint(anchorPoint..'LEFT', auraBars.Holder, anchorTo..'LEFT', 0, 0)
		auraBars:SetPoint(anchorPoint..'RIGHT', auraBars.Holder, anchorTo..'RIGHT')		
	end
end

UF.Update_PlayerFrameABM = UF.Update_PlayerFrame
function UF:Update_PlayerFrame(frame, db)
	UF:Update_PlayerFrameABM(frame, db)
	
	frame.db = db
	local POWERBAR_OFFSET = db.power.offset
		
	--AuraBars
	do
		local auraBars = frame.AuraBars
				
		--Set size of mover
		auraBars.Holder:Width(E.db.unitframe.units.player.abw)
		auraBars.Holder:Height(20)
		auraBars.Holder:GetScript('OnSizeChanged')(auraBars.Holder)
		
		if db.aurabar.enable then
			if not frame:IsElementEnabled('AuraBars') then
				frame:EnableElement('AuraBars')
			end
			auraBars:Show()
			auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
			auraBars.enemyAuraType = db.aurabar.enemyAuraType
			
			local buffColor = UF.db.colors.auraBarBuff
			local debuffColor = UF.db.colors.auraBarDebuff
			
			local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
			if db.aurabar.anchorPoint == 'BELOW' then
				anchorPoint, anchorTo = 'TOP', 'BOTTOM'
			end
			
			auraBars:ClearAllPoints()
			auraBars:SetPoint(anchorPoint..'LEFT', auraBars.Holder, anchorTo..'LEFT')
			auraBars:SetPoint(anchorPoint..'RIGHT', auraBars.Holder, anchorTo..'RIGHT', -POWERBAR_OFFSET, 0)

			auraBars.buffColor = {buffColor.r, buffColor.g, buffColor.b}
			auraBars.debuffColor = {debuffColor.r, debuffColor.g, debuffColor.b}
			auraBars.down = db.aurabar.anchorPoint == 'BELOW'
			auraBars:SetAnchors()
		else
			if frame:IsElementEnabled('AuraBars') then
				frame:DisableElement('AuraBars')
				auraBars:Hide()
			end		
		end
	end

	frame:UpdateAllElements()
end

UF.Update_TargetFrameABM = UF.Update_TargetFrame
function UF:Update_TargetFrame(frame, db)
	if not targetInsert then --Checking if we inserted the smart aura thing
		table.insert(frame.__elements, UF.SmartAuraDisplay)
		frame:RegisterEvent('PLAYER_TARGET_CHANGED', UF.SmartAuraDisplay)
		targetInsert = true
	end
	UF:Update_TargetFrameABM(frame, db)
	
	frame.db = db
	local POWERBAR_OFFSET = db.power.offset
	
	--AuraBars
	do
		local auraBars = frame.AuraBars
		
		--Set size of mover
		auraBars.Holder:Width(E.db.unitframe.units.target.abw)
		auraBars.Holder:Height(20)
		auraBars.Holder:GetScript('OnSizeChanged')(auraBars.Holder)
		
		if db.aurabar.enable then
			if not frame:IsElementEnabled('AuraBars') then
				frame:EnableElement('AuraBars')
			end
			auraBars:Show()
			auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
			auraBars.enemyAuraType = db.aurabar.enemyAuraType			
			
			local buffColor = UF.db.colors.auraBarBuff
			local debuffColor = UF.db.colors.auraBarDebuff
			
			local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
			if db.aurabar.anchorPoint == 'BELOW' then
				anchorPoint, anchorTo = 'TOP', 'BOTTOM'
			end
			
			auraBars:ClearAllPoints()
			auraBars:SetPoint(anchorPoint..'LEFT', auraBars.Holder, anchorTo..'LEFT', POWERBAR_OFFSET, 0)
			auraBars:SetPoint(anchorPoint..'RIGHT', auraBars.Holder, anchorTo..'RIGHT')
			
			auraBars.buffColor = {buffColor.r, buffColor.g, buffColor.b}
			auraBars.debuffColor = {debuffColor.r, debuffColor.g, debuffColor.b}
			auraBars.down = db.aurabar.anchorPoint == 'BELOW'
			auraBars:SetAnchors()
		else
			if frame:IsElementEnabled('AuraBars') then
				frame:DisableElement('AuraBars')
				auraBars:Hide()
			end		
		end
	end
	UF:SmartAuraDisplay()
	frame:UpdateAllElements()
end

UF.Update_FocusFrameABM = UF.Update_FocusFrame
function UF:Update_FocusFrame(frame, db)
	if not focusInsert then --Checking if we inserted the smart aura thing
		table.insert(frame.__elements, UF.SmartAuraDisplay)
		frame:RegisterEvent('PLAYER_FOCUS_CHANGED', UF.SmartAuraDisplay)
		focusInsert = true
	end
	UF:Update_FocusFrameABM(frame, db)
	
	frame.db = db
	local POWERBAR_OFFSET = db.power.offset
	
	--AuraBars
	do
		local auraBars = frame.AuraBars
		
		--Set size of mover
		auraBars.Holder:Width(E.db.unitframe.units.focus.abw)
		auraBars.Holder:Height(20)
		auraBars.Holder:GetScript('OnSizeChanged')(auraBars.Holder)
		
		if db.aurabar.enable then
			if not frame:IsElementEnabled('AuraBars') then
				frame:EnableElement('AuraBars')
			end
			
			auraBars:Show()
			auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
			auraBars.enemyAuraType = db.aurabar.enemyAuraType
			
			local buffColor = UF.db.colors.auraBarBuff
			local debuffColor = UF.db.colors.auraBarDebuff
			
			local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
			if db.aurabar.anchorPoint == 'BELOW' then
				anchorPoint, anchorTo = 'TOP', 'BOTTOM'
			end
			
			auraBars:ClearAllPoints()
			auraBars:SetPoint(anchorPoint..'LEFT', auraBars.Holder, anchorTo..'LEFT', POWERBAR_OFFSET, 0)
			auraBars:SetPoint(anchorPoint..'RIGHT', auraBars.Holder, anchorTo..'RIGHT', -POWERBAR_OFFSET, 0)
			
			auraBars.buffColor = {buffColor.r, buffColor.g, buffColor.b}
			auraBars.debuffColor = {debuffColor.r, debuffColor.g, debuffColor.b}
			auraBars.down = db.aurabar.anchorPoint == 'BELOW'
			auraBars:SetAnchors()
		else
			if frame:IsElementEnabled('AuraBars') then
				frame:DisableElement('AuraBars')
				auraBars:Hide()
			end		
		end
	end
	UF:SmartAuraDisplay()
	frame:UpdateAllElements()
end

function ABM:Initialize()
	ABM:PlayerABmove()
	ABM:TargetABmove()
	ABM:FocusABmove()
end

E:RegisterModule(ABM:GetName())