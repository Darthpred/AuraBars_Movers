local E, L, V, P, G, _ = unpack(ElvUI);--Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local ReplaceInsert = false

UF.Update_FocusFrameABM = UF.Update_FocusFrame
function UF:Update_FocusFrame(frame, db)
	if not ReplaceInsert then --Checking if we replaced the smart aura thing
		table.insert(frame.__elements, UF.SmartAuraDisplay)
		ReplaceInsert = true
	end
	UF:Update_FocusFrameABM(frame, db)
	
	frame.db = db
	local POWERBAR_OFFSET = db.power.offset
	
	--AuraBars
	do
		local auraBars = frame.AuraBars
		
		--Set size of mover
		auraBars.Holder:Width(db.width)
		auraBars.Holder:Height(20)
		auraBars.Holder:GetScript('OnSizeChanged')(auraBars.Holder)
		
		if db.aurabar.enable then
			if not frame:IsElementEnabled('AuraBars') then
				frame:EnableElement('AuraBars')
			end
			
			auraBars:Show()
			auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
			auraBars.enemyAuraType = db.aurabar.enemyAuraType
			
			local healthColor = UF.db.colors.health
			
			local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
			if db.aurabar.anchorPoint == 'BELOW' then
				anchorPoint, anchorTo = 'TOP', 'BOTTOM'
			end
			
			auraBars:ClearAllPoints()
			auraBars:SetPoint(anchorPoint..'LEFT', auraBars.Holder, anchorTo..'LEFT', POWERBAR_OFFSET, 0)
			auraBars:SetPoint(anchorPoint..'RIGHT', auraBars.Holder, anchorTo..'RIGHT', -POWERBAR_OFFSET, 0)
			auraBars.buffColor = {healthColor.r, healthColor.b, healthColor.g}
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