local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');



local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_TargetFrame(frame)	
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Health.frequentUpdates = true;
	
	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT', false)
	frame.Power.frequentUpdates = true;
	
	frame.Name = self:Construct_NameText(frame)
	
	frame.Portrait = self:Construct_Portrait(frame)
	
	frame.Buffs = self:Construct_Buffs(frame)

	frame.Debuffs = self:Construct_Debuffs(frame)

	frame.Castbar = self:Construct_Castbar(frame, 'RIGHT', 'Target Castbar')
	frame.Castbar.SafeZone = nil
	frame.Castbar.LatencyTexture:Hide()
	frame.RaidIcon = UF:Construct_RaidIcon(frame)		
	frame.CPoints = self:Construct_Combobar(frame)
	frame.HealPrediction = self:Construct_HealComm(frame)
	frame.DebuffHighlight = self:Construct_DebuffHighlight(frame)
	
	table.insert(frame.__elements, UF.SmartAuraDisplay)
	frame:RegisterEvent('PLAYER_TARGET_CHANGED', UF.SmartAuraDisplay)
	
	frame.AuraBars = self:Construct_AuraBarHeader(frame, "Target Aura Bars")
	
	frame:Point('BOTTOMRIGHT', E.UIParent, 'BOTTOM', 417, 75)
	E:CreateMover(frame, frame:GetName()..'Mover', 'Target Frame', nil, nil, nil, 'ALL,SOLO')
end

function UF:Update_TargetFrame(frame, db)
	frame.db = db
	local BORDER = E:Scale(2)
	local SPACING = E:Scale(1)	
	local UNIT_WIDTH = db.width
	local UNIT_HEIGHT = db.height
	
	local USE_POWERBAR = db.power.enable
	local USE_MINI_POWERBAR = db.power.width ~= 'fill' and USE_POWERBAR
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = db.power.height
	local POWERBAR_WIDTH = db.width - (BORDER*2)
	
	local USE_COMBOBAR = db.combobar.enable
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR
	local COMBOBAR_HEIGHT = db.combobar.height
	local COMBOBAR_WIDTH = db.width - (BORDER*2)
	
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	
	local unit = self.unit
	
	frame.colors = ElvUF.colors
	frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())
	
	--Adjust some variables
	do
		if not USE_POWERBAR then
			POWERBAR_HEIGHT = 0
		end	
	
		if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
			PORTRAIT_WIDTH = 0
			if USE_POWERBAR_OFFSET then
				COMBOBAR_WIDTH = COMBOBAR_WIDTH - POWERBAR_OFFSET
			end			
		elseif USE_PORTRAIT then
			COMBOBAR_WIDTH = math.ceil((UNIT_WIDTH - (BORDER*2)) - PORTRAIT_WIDTH)
			
			if USE_POWERBAR_OFFSET then
				COMBOBAR_WIDTH = COMBOBAR_WIDTH - POWERBAR_OFFSET
			end
		elseif USE_POWERBAR_OFFSET then
			COMBOBAR_WIDTH = COMBOBAR_WIDTH - POWERBAR_OFFSET
		end

		if USE_MINI_COMBOBAR then
			COMBOBAR_WIDTH = COMBOBAR_WIDTH * 4/5
		end	
		
		if USE_MINI_POWERBAR then
			POWERBAR_WIDTH = POWERBAR_WIDTH / 2
		end
	end
	
	--Health
	do
		local health = frame.Health
		health.Smooth = self.db.smoothbars

		--Text
		if db.health.text then
			health.value:Show()
			
			local x, y = self:GetPositionOffset(db.health.position)
			health.value:ClearAllPoints()
			health.value:Point(db.health.position, health, db.health.position, x, y)
		else
			health.value:Hide()
		end
		
		--Colors
		health.colorSmooth = nil
		health.colorHealth = nil
		health.colorClass = nil
		health.colorReaction = nil
		if self.db['colors'].healthclass ~= true then
			if self.db['colors'].colorhealthbyvalue == true then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end		
		else
			health.colorClass = true
			health.colorReaction = true
		end	
		
		--Position
		health:ClearAllPoints()
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER)
		if USE_POWERBAR_OFFSET then			
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER+POWERBAR_OFFSET, BORDER+POWERBAR_OFFSET)
		elseif USE_MINI_POWERBAR then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
		
		health.bg:ClearAllPoints()
		if not USE_PORTRAIT_OVERLAY then
			health:Point("TOPRIGHT", -(PORTRAIT_WIDTH+BORDER), -BORDER)
			health.bg:SetParent(health)
			health.bg:SetAllPoints()
		else
			health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			health.bg:Point('TOPRIGHT', health)		
			health.bg:SetParent(frame.Portrait.overlay)			
		end
	end
	
	--Name
	do
		local name = frame.Name
		if db.name.enable then
			name:Show()
			
			if not db.power.hideonnpc then
				local x, y = self:GetPositionOffset(db.name.position)
				name:ClearAllPoints()
				name:Point(db.name.position, frame.Health, db.name.position, x, y)				
			end
		else
			name:Hide()
		end
	end	
	
	--Power
	do
		local power = frame.Power
		
		if USE_POWERBAR then
			if not frame:IsElementEnabled('Power') then
				frame:EnableElement('Power')
				power:Show()
			end				
			power.Smooth = self.db.smoothbars
			
			--Text
			if db.power.text then
				power.value:Show()
				
				local x, y = self:GetPositionOffset(db.power.position)
				power.value:ClearAllPoints()
				power.value:Point(db.power.position, frame.Health, db.power.position, x, y)			
			else
				power.value:Hide()
			end
			
			--Colors
			power.colorClass = nil
			power.colorReaction = nil	
			power.colorPower = nil
			if self.db['colors'].powerclass then
				power.colorClass = true
				power.colorReaction = true
			else
				power.colorPower = true
			end		
			
			--Position
			power:ClearAllPoints()
			if USE_POWERBAR_OFFSET then
				power:Point("TOPLEFT", frame.Health, "TOPLEFT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:SetFrameStrata("LOW")
				power:SetFrameLevel(2)
			elseif USE_MINI_POWERBAR then
				power:Width(POWERBAR_WIDTH - BORDER*2)
				power:Height(POWERBAR_HEIGHT - BORDER*2)
				power:Point("LEFT", frame, "BOTTOMLEFT", (BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)
			else
				power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -(BORDER + PORTRAIT_WIDTH), BORDER)
			end
		elseif frame:IsElementEnabled('Power') then
			frame:DisableElement('Power')
			power:Hide()
			power.value:Hide()
		end
	end
	
	--Portrait
	do
		local portrait = frame.Portrait
		
		--Set Points
		if USE_PORTRAIT then
			if not frame:IsElementEnabled('Portrait') then
				frame:EnableElement('Portrait')
			end
			
			portrait:ClearAllPoints()
			
			if USE_PORTRAIT_OVERLAY then
				portrait:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
				portrait:SetAllPoints(frame.Health)
				portrait:SetAlpha(0.3)
				portrait:Show()		
			else
				portrait:SetAlpha(1)
				portrait:Show()
				
				portrait.backdrop:ClearAllPoints()
				portrait.backdrop:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
						
				if USE_MINI_POWERBAR or USE_POWERBAR_OFFSET or not USE_POWERBAR then
					portrait.backdrop:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMRIGHT", SPACING, 0)
				else
					portrait.backdrop:Point("BOTTOMLEFT", frame.Power.backdrop, "BOTTOMRIGHT", SPACING, 0)
				end	
							
				portrait:Point('BOTTOMLEFT', portrait.backdrop, 'BOTTOMLEFT', BORDER, BORDER)		
				portrait:Point('TOPRIGHT', portrait.backdrop, 'TOPRIGHT', -BORDER, -BORDER)				
			end
		else
			if frame:IsElementEnabled('Portrait') then
				frame:DisableElement('Portrait')
				portrait:Hide()
			end		
		end
	end

	--Auras Disable/Enable
	--Only do if both debuffs and buffs aren't being used.
	do
		if db.debuffs.enable or db.buffs.enable then
			if not frame:IsElementEnabled('Aura') then
				frame:EnableElement('Aura')
			end	
		else
			if frame:IsElementEnabled('Aura') then
				frame:DisableElement('Aura')
			end			
		end
		
		frame.Buffs:ClearAllPoints()
		frame.Debuffs:ClearAllPoints()
	end
	
	--Buffs
	do
		local buffs = frame.Buffs
		local rows = db.buffs.numrows
		
		if USE_POWERBAR_OFFSET then
			buffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			buffs:SetWidth(UNIT_WIDTH)
		end
		
		buffs.forceShow = frame.forceShowAuras
		buffs.num = db.buffs.perrow * rows
		buffs.size = db.buffs.sizeOverride ~= 0 and db.buffs.sizeOverride or ((((buffs:GetWidth() - (buffs.spacing*(buffs.num/rows - 1))) / buffs.num)) * rows)
		
		if db.buffs.sizeOverride and db.buffs.sizeOverride > 0 then
			buffs:SetWidth(db.buffs.perrow * db.buffs.sizeOverride)
		end
		
		local x, y = E:GetXYOffset(db.buffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.buffs.attachTo)
		
		buffs:Point(E.InversePoints[db.buffs.anchorPoint], attachTo, db.buffs.anchorPoint, x, y)
		buffs:Height(buffs.size * rows)
		buffs["growth-y"] = db.buffs.anchorPoint:find('TOP') and 'UP' or 'DOWN'
		buffs["growth-x"] = db.buffs.anchorPoint == 'LEFT' and 'LEFT' or  db.buffs.anchorPoint == 'RIGHT' and 'RIGHT' or (db.buffs.anchorPoint:find('LEFT') and 'RIGHT' or 'LEFT')
		buffs.initialAnchor = E.InversePoints[db.buffs.anchorPoint]

		if db.buffs.enable then			
			buffs:Show()
		else
			buffs:Hide()
		end
	end
	
	--Debuffs
	do
		local debuffs = frame.Debuffs
		local rows = db.debuffs.numrows
		
		if USE_POWERBAR_OFFSET then
			debuffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			debuffs:SetWidth(UNIT_WIDTH)
		end
		
		debuffs.forceShow = frame.forceShowAuras
		debuffs.num = db.debuffs.perrow * rows
		debuffs.size = db.debuffs.sizeOverride ~= 0 and db.debuffs.sizeOverride or ((((debuffs:GetWidth() - (debuffs.spacing*(debuffs.num/rows - 1))) / debuffs.num)) * rows)
		
		if db.debuffs.sizeOverride and db.debuffs.sizeOverride > 0 then
			debuffs:SetWidth(db.debuffs.perrow * db.debuffs.sizeOverride)
		end
		
		local x, y = E:GetXYOffset(db.debuffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.debuffs.attachTo)
		
		debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], attachTo, db.debuffs.anchorPoint, x, y)
		debuffs:Height(debuffs.size * rows)
		debuffs["growth-y"] = db.debuffs.anchorPoint:find('TOP') and 'UP' or 'DOWN'
		debuffs["growth-x"] = db.debuffs.anchorPoint == 'LEFT' and 'LEFT' or  db.debuffs.anchorPoint == 'RIGHT' and 'RIGHT' or (db.debuffs.anchorPoint:find('LEFT') and 'RIGHT' or 'LEFT')
		debuffs.initialAnchor = E.InversePoints[db.debuffs.anchorPoint]

		if db.debuffs.enable then			
			debuffs:Show()
		else
			debuffs:Hide()
		end
	end	
	
	--Castbar
	do
		local castbar = frame.Castbar
		castbar:Width(db.castbar.width - 4)
		castbar:Height(db.castbar.height)
		castbar.Holder:Width(db.castbar.width)
		castbar.Holder:Height(db.castbar.height + 4)
		castbar.Holder:GetScript('OnSizeChanged')(castbar.Holder)
		
		--Icon
		if db.castbar.icon then
			castbar.Icon = castbar.ButtonIcon
			castbar.Icon.bg:Width(db.castbar.height + 4)
			castbar.Icon.bg:Height(db.castbar.height + 4)
			
			castbar:Width(db.castbar.width - castbar.Icon.bg:GetWidth() - 5)
			castbar.Icon.bg:Show()
		else
			castbar.ButtonIcon.bg:Hide()
			castbar.Icon = nil
		end
		
		if db.castbar.spark then
			castbar.Spark:Show()
		else
			castbar.Spark:Hide()
		end		

		if db.castbar.enable and not frame:IsElementEnabled('Castbar') then
			frame:EnableElement('Castbar')
		elseif not db.castbar.enable and frame:IsElementEnabled('Castbar') then
			frame:DisableElement('Castbar')	
		end			
	end
	
	--Combo Bar
	do
		local CPoints = frame.CPoints
		CPoints:ClearAllPoints()
		if USE_MINI_COMBOBAR then
			CPoints:Point("CENTER", frame.Health.backdrop, "TOP", -(BORDER*3 + 6), -SPACING)
			CPoints:SetFrameStrata("MEDIUM")
		else
			CPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
			CPoints:SetFrameStrata("LOW")
		end

		CPoints:Width(COMBOBAR_WIDTH)
		CPoints:Height(COMBOBAR_HEIGHT - (BORDER*2))			
		
		for i = 1, MAX_COMBO_POINTS do
			CPoints[i]:SetHeight(CPoints:GetHeight())
			CPoints[i]:SetWidth(E:Scale(CPoints:GetWidth() - (MAX_COMBO_POINTS - 1)) / MAX_COMBO_POINTS)	
			if USE_MINI_COMBOBAR then
				CPoints[i].backdrop:Show()
			else
				CPoints[i].backdrop:Hide()	
			end
			
			CPoints[i]:ClearAllPoints()
			if i == 1 then
				CPoints[i]:SetPoint("LEFT", CPoints)
			else
				if USE_MINI_COMBOBAR then
					CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", SPACING+(BORDER*2)+2, 0)
				else
					CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", SPACING, 0)
				end
			end	
			
			if not USE_MINI_COMBOBAR then
				CPoints[i].backdrop:Hide()
			else
				CPoints[i].backdrop:Show()
			end					
		end
		
		if not USE_MINI_COMBOBAR then
			CPoints.backdrop:Show()
		else
			CPoints.backdrop:Hide()
		end		

		if USE_COMBOBAR and not frame:IsElementEnabled('CPoints') then
			frame:EnableElement('CPoints')
		elseif not USE_COMBOBAR and frame:IsElementEnabled('CPoints') then
			frame:DisableElement('CPoints')	
			CPoints:Hide()
		end				
	end
	
	--Debuff Highlight
	do
		local dbh = frame.DebuffHighlight
		if E.db.unitframe.debuffHighlighting then
			if not frame:IsElementEnabled('DebuffHighlight') then
				frame:EnableElement('DebuffHighlight')
			end
		else
			if frame:IsElementEnabled('DebuffHighlight') then
				frame:DisableElement('DebuffHighlight')
			end		
		end
	end
	
	--OverHealing
	do
		local healPrediction = frame.HealPrediction
		
		if db.healPrediction then
			if not frame:IsElementEnabled('HealPrediction') then
				frame:EnableElement('HealPrediction')
			end

			healPrediction.myBar:ClearAllPoints()
			healPrediction.myBar:Width(db.width - (BORDER*2))
			healPrediction.myBar:SetPoint('BOTTOMLEFT', frame.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			healPrediction.myBar:SetPoint('TOPLEFT', frame.Health:GetStatusBarTexture(), 'TOPRIGHT')	

			healPrediction.otherBar:ClearAllPoints()
			healPrediction.otherBar:SetPoint('TOPLEFT', healPrediction.myBar:GetStatusBarTexture(), 'TOPRIGHT')	
			healPrediction.otherBar:SetPoint('BOTTOMLEFT', healPrediction.myBar:GetStatusBarTexture(), 'BOTTOMRIGHT')	
			healPrediction.otherBar:Width(db.width - (BORDER*2))
			
			if not USE_PORTRAIT_OVERLAY then
				healPrediction.myBar:SetParent(frame)
				healPrediction.otherBar:SetParent(frame)
			else	
				healPrediction.myBar:SetParent(frame.Portrait.overlay)		
				healPrediction.otherBar:SetParent(frame.Portrait.overlay)					
			end			
		else
			if frame:IsElementEnabled('HealPrediction') then
				frame:DisableElement('HealPrediction')
			end		
		end
	end	
	
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
			auraBars:SetPoint(anchorPoint..'RIGHT', auraBars.Holder, anchorTo..'RIGHT')
			auraBars.buffColor = {healthColor.r, healthColor.b, healthColor.g}
			auraBars.down = db.aurabar.anchorPoint == 'BELOW'
			auraBars:SetAnchors()
			
			--We do this to prevent the AuraBars being anchored to buffs or debuffs when "Smart Auras" setting is used
			--The code which repositions Aura Bars is in update_elements.lua line 1325 and line 1340
			auraBars.SetPoint = noop
		else
			if frame:IsElementEnabled('AuraBars') then
				frame:DisableElement('AuraBars')
				auraBars:Hide()
			end		
		end
	end
	
	E:SetMoverSnapOffset(frame:GetName()..'Mover', -(12 + db.castbar.height))
	frame:UpdateAllElements()
end

tinsert(UF['unitstoload'], 'target')