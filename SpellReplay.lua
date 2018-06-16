-- SpellReplay (TBC/WotLK)

local ReplayFrame = CreateFrame("Frame", "ReplayFrame", UIParent)
ReplayFrame:SetPoint("CENTER")
ReplayFrame:SetWidth(40)
ReplayFrame:SetHeight(40)
ReplayFrame:SetClampedToScreen(true)
ReplayFrame:SetMovable(true)

local ReplayBackground = ReplayFrame:CreateTexture(nil, "BACKGROUND")
ReplayBackground:SetAllPoints()
ReplayBackground:SetTexture(0, 0, 0, 0.3)

local spellTable = {}
local timestampTable = {}
local replaySettings = {}
replaySettings.panel = CreateFrame("Frame", "ReplaySettingsPanel", UIParent)
replaySettings.panel.name = "SpellReplay"
InterfaceOptions_AddCategory(replaySettings.panel)

local SettingsTitle = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsTitle:SetPoint("TOPLEFT", ReplaySettingsPanel, 15, -15)
SettingsTitle:SetFont("Fonts\\FRIZQT__.TTF", 17)
SettingsTitle:SetJustifyH("LEFT")
SettingsTitle:SetText("SpellReplay")

local SettingsGeneralTitle = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsGeneralTitle:SetPoint("TOPLEFT", ReplaySettingsPanel, 15, -40)
SettingsGeneralTitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsGeneralTitle:SetJustifyH("LEFT")
SettingsGeneralTitle:SetTextColor(1, 1, 1)
SettingsGeneralTitle:SetText("General settings")

local SettingsEnableButton = CreateFrame("CheckButton", "SettingsEnableButton", ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsEnableButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 25, -60)
SettingsEnableButton:SetHitRectInsets(0, -100, 0, 0)
SettingsEnableButton:SetWidth(25)
SettingsEnableButton:SetHeight(25)
SettingsEnableButton:SetScript("OnClick", function()
	if SettingsEnableButton:GetChecked() then
		replaySavedSettings[1] = 1
		if not ReplayFrame:IsShown() then
			ReplayFrame:Show()
		end
	else
		replaySavedSettings[1] = 0
		if ReplayFrame:IsShown() then
			ReplayFrame:Hide()
		end
	end
end)

local SettingsEnableFont = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsEnableFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 50, -65)
SettingsEnableFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsEnableFont:SetJustifyH("LEFT")
SettingsEnableFont:SetTextColor(1, 1, 1)
SettingsEnableFont:SetText("Enable")

local SettingsLockButton = CreateFrame("CheckButton", "SettingsLockButton", ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsLockButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 25, -90)
SettingsLockButton:SetHitRectInsets(0, -150, 0, 0)
SettingsLockButton:SetWidth(25)
SettingsLockButton:SetHeight(25)
SettingsLockButton:SetScript("OnClick", function()
	if SettingsLockButton:GetChecked() then
		replaySavedSettings[2] = 1
		ReplayFrame:SetScript("OnMouseDown", nil)
		ReplayFrame:SetScript("OnMouseUp", nil)
		if not SettingsBackgroundButton:GetChecked() then
			ReplayFrame:EnableMouse(false)
		end
	else
		replaySavedSettings[2] = 0
		ReplayFrame:SetScript("OnMouseDown", function(self, button) ReplayFrame:StartMoving() end)
		ReplayFrame:SetScript("OnMouseUp", function(self, button) ReplayFrame:StopMovingOrSizing() end)
		ReplayFrame:EnableMouse(true)
	end
end)

local SettingsLockFont = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsLockFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 50, -95)
SettingsLockFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsLockFont:SetJustifyH("LEFT")
SettingsLockFont:SetTextColor(1, 1, 1)
SettingsLockFont:SetText("Lock position")

local SettingsBackgroundButton = CreateFrame("CheckButton", "SettingsBackgroundButton", ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsBackgroundButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 25, -120)
SettingsBackgroundButton:SetHitRectInsets(0, -150, 0, 0)
SettingsBackgroundButton:SetWidth(25)
SettingsBackgroundButton:SetHeight(25)
SettingsBackgroundButton:SetScript("OnClick", function()
	if SettingsBackgroundButton:GetChecked() then
		replaySavedSettings[3] = 1
		ReplayBackground:Show()
		ReplayFrame:SetScript("OnEnter", nil)
		ReplayFrame:SetScript("OnLeave", nil)
	else
		replaySavedSettings[3] = 0
		ReplayBackground:Hide()
		ReplayFrame:SetScript("OnEnter", function() ReplayBackground:Show() end)
		ReplayFrame:SetScript("OnLeave", function() ReplayBackground:Hide() end)
		if SettingsLockButton:GetChecked() then
			ReplayFrame:EnableMouse(false)
		end
	end
end)

local SettingsBackgroundFont = ReplaySettingsPanel:CreateFontString("SettingsBackgroundFont", "ARTWORK", "GameFontNormal")
SettingsBackgroundFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 50, -125)
SettingsBackgroundFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsBackgroundFont:SetJustifyH("LEFT")
SettingsBackgroundFont:SetTextColor(1, 1, 1)
SettingsBackgroundFont:SetText("Show background")

local SettingsScalingFont = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsScalingFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 230, -50)
SettingsScalingFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsScalingFont:SetJustifyH("LEFT")
SettingsScalingFont:SetText("Frame scaling")

local SettingsScalingSlider = CreateFrame("Slider", "SettingsScalingSlider", ReplaySettingsPanel, "OptionsSliderTemplate")
SettingsScalingSlider:ClearAllPoints()
SettingsScalingSlider:SetPoint("TOPLEFT", 200, -65)
SettingsScalingSlider:SetMinMaxValues(0, 7)
SettingsScalingSlider:SetWidth(150)
SettingsScalingSliderLow:SetText(" |cffffffff0.8")
SettingsScalingSliderHigh:SetText("|cffffffff1.5 ")
SettingsScalingSlider:SetValueStep(1)
SettingsScalingSlider:SetHitRectInsets(0, 0, -5, -5)
SettingsScalingSlider:SetScript("OnMouseUp", function(self, button)
	if SettingsScalingSlider:GetValue() > 0 then
		replaySavedSettings[4] = 0.8 + SettingsScalingSlider:GetValue() / 10
	else
		replaySavedSettings[4] = 0.8
	end
	ReplayFrame:SetScale(replaySavedSettings[4])
end)
SettingsScalingSlider:SetScript("OnValueChanged", function()
	if SettingsScalingSlider:GetValue() > 0 then
		replaySavedSettings[4] = 0.8 + SettingsScalingSlider:GetValue() / 10
	else
		replaySavedSettings[4] = 0.8
	end
	ReplayFrame:SetScale(replaySavedSettings[4])
	GameTooltip:SetOwner(SettingsScalingSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Scaling: x"..replaySavedSettings[4])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)
SettingsScalingSlider:SetScript("OnEnter", function()
	if SettingsScalingSlider:GetValue() > 0 then
		replaySavedSettings[4] = 0.8 + SettingsScalingSlider:GetValue() / 10
	else
		replaySavedSettings[4] = 0.8
	end
	ReplayFrame:SetScale(replaySavedSettings[4])
	GameTooltip:SetOwner(SettingsScalingSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Scaling: x"..replaySavedSettings[4])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)

local SettingsDirectionFont = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsDirectionFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 200, -105)
SettingsDirectionFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsDirectionFont:SetJustifyH("LEFT")
SettingsDirectionFont:SetTextColor(1, 1, 1)
SettingsDirectionFont:SetText("Scrolling direction")

local SettingsDirectionMenu = CreateFrame("Button", "SettingsDirectionMenu", ReplaySettingsPanel, "UIDropDownMenuTemplate")
SettingsDirectionMenu:ClearAllPoints()
SettingsDirectionMenu:SetPoint("TOPLEFT", ReplaySettingsPanel, 180, -120)
UIDropDownMenu_SetWidth(140, SettingsDirectionMenu)
UIDropDownMenu_JustifyText("CENTER", SettingsDirectionMenu)
local directionInitMenu = {}
UIDropDownMenu_Initialize(SettingsDirectionMenu, function()
	directionInitMenu.checked = nil
	directionInitMenu.func = nil
	directionInitMenu.text = "Right"
	directionInitMenu.value = 1
	directionInitMenu.checked = function()
		if replaySavedSettings ~= nil and replaySavedSettings[5] == 1 then
			return true
		else
			return nil
		end
	end
	directionInitMenu.func = function()
		if replaySavedSettings ~= nil and replaySavedSettings[5] == 2 then
			replaySavedSettings[5] = 1
			UIDropDownMenu_SetText("Right", SettingsDirectionMenu)
			for i=table.maxn(spellTable),0,-1 do
				if _G["ReplayTexture"..i] ~= nil and _G["ReplayTexture"..i]:IsShown() then
					_G["ReplayTexture"..i]:Hide()
					_G["ReplayTexture"..i] = nil
					if _G["ReplayFont"..i] ~= nil then
						_G["ReplayFont"..i]:Hide()
						_G["ReplayFont"..i] = nil
					end
					if _G["ReplayFailTexture"..i] ~= nil then
						_G["ReplayFailTexture"..i]:Hide()
						_G["ReplayFailTexture"..i] = nil
					end
					if _G["ReplayUpperTexture"..i] ~= nil then
						_G["ReplayUpperTexture"..i]:Hide()
						_G["ReplayUpperTexture"..i] = nil
					end
					if _G["ReplayUpperFailTexture"..i] ~= nil then
						_G["ReplayUpperFailTexture"..i]:Hide()
						_G["ReplayUpperFailTexture"..i] = nil
					end
				elseif _G["ReplayTexture"..i] ~= nil then
					break
				end
			end
		end
	end
	UIDropDownMenu_AddButton(directionInitMenu)
	directionInitMenu.text = "Left"
	directionInitMenu.value = 1
	directionInitMenu.checked = function()
		if replaySavedSettings ~= nil and replaySavedSettings[5] == 2 then
			return true
		else
			return nil
		end
	end
	directionInitMenu.func = function()
		if replaySavedSettings ~= nil and replaySavedSettings[5] == 1 then
			replaySavedSettings[5] = 2
			UIDropDownMenu_SetText("Left", SettingsDirectionMenu)
			for i=table.maxn(spellTable),0,-1 do
				if _G["ReplayTexture"..i] ~= nil and _G["ReplayTexture"..i]:IsShown() then
					_G["ReplayTexture"..i]:Hide()
					_G["ReplayTexture"..i] = nil
					if _G["ReplayFont"..i] ~= nil then
						_G["ReplayFont"..i]:Hide()
						_G["ReplayFont"..i] = nil
					end
					if _G["ReplayFailTexture"..i] ~= nil then
						_G["ReplayFailTexture"..i]:Hide()
						_G["ReplayFailTexture"..i] = nil
					end
					if _G["ReplayUpperTexture"..i] ~= nil then
						_G["ReplayUpperTexture"..i]:Hide()
						_G["ReplayUpperTexture"..i] = nil
					end
					if _G["ReplayUpperFailTexture"..i] ~= nil then
						_G["ReplayUpperFailTexture"..i]:Hide()
						_G["ReplayUpperFailTexture"..i] = nil
					end
				elseif _G["ReplayTexture"..i] ~= nil then
					break
				end
			end
		end
	end
	UIDropDownMenu_AddButton(directionInitMenu)
end)

local total = 0
local AuraDelayFrame = CreateFrame("Frame")
local function AuraDelay(self, elapsed)
	total = total + elapsed
	if total > 0.05 then
		for i=1,40 do
			if select(1, UnitBuff("player", i)) ~= nil then
				local spellName, _, spellIcon = UnitBuff("player", i)
				if spellName == spellTable[table.maxn(spellTable)] then
					if table.maxn(spellTable) <= 1 then
						ReplayTexture0:SetTexture(spellIcon)
					else
						_G["ReplayTexture"..table.maxn(spellTable)-1]:SetTexture(spellIcon)
					end
					break
				end
			else
				break
			end
		end
		total = 0
		AuraDelayFrame:SetScript("OnUpdate", nil)
	end
end

ReplayFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ReplayFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ReplayFrame:RegisterEvent("PLAYER_LOGIN")
ReplayFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if replaySavedSettings == nil or #replaySavedSettings == 0 then
			replaySavedSettings = {}
			replaySavedSettings[1] = 1
			SettingsEnableButton:SetChecked()
			replaySavedSettings[2] = 0
			ReplayFrame:SetScript("OnMouseDown", function(self, button) ReplayFrame:StartMoving() end)
			ReplayFrame:SetScript("OnMouseUp", function(self, button) ReplayFrame:StopMovingOrSizing() end)
			ReplayFrame:EnableMouse(true)
			replaySavedSettings[3] = 1
			SettingsBackgroundButton:SetChecked()
			replaySavedSettings[4] = 1
			SettingsScalingSlider:SetValue(2)
			UIDropDownMenu_SetText("Right", SettingsDirectionMenu)
			replaySavedSettings[5] = 1
		else
			if replaySavedSettings[1] == 0 then
				ReplayFrame:Hide()
			else
				SettingsEnableButton:SetChecked()
			end
			if replaySavedSettings[2] == 1 then
				SettingsLockButton:SetChecked()
				ReplayFrame:SetScript("OnMouseDown", nil)
				ReplayFrame:SetScript("OnMouseUp", nil)
				if replaySavedSettings[3] == 0 then
					ReplayFrame:EnableMouse(false)
				end
			else
				ReplayFrame:SetScript("OnMouseDown", function(self, button) ReplayFrame:StartMoving() end)
				ReplayFrame:SetScript("OnMouseUp", function(self, button) ReplayFrame:StopMovingOrSizing() end)
				ReplayFrame:EnableMouse(true)
			end
			if replaySavedSettings[3] == 1 then
				SettingsBackgroundButton:SetChecked()
				ReplayFrame:SetScript("OnEnter", nil)
				ReplayFrame:SetScript("OnLeave", nil)
			else
				ReplayBackground:Hide()
				ReplayFrame:SetScript("OnEnter", function() ReplayBackground:Show() end)
				ReplayFrame:SetScript("OnLeave", function() ReplayBackground:Hide() end)
				if replaySavedSettings[2] == 1 then
					ReplayFrame:EnableMouse(false)
				end
			end
			SettingsScalingSlider:SetValue((replaySavedSettings[4] - 0.8) * 10)
			ReplayFrame:SetScale(replaySavedSettings[4])
			if replaySavedSettings[5] == 1 then
				UIDropDownMenu_SetText("Right", SettingsDirectionMenu)
			else
				UIDropDownMenu_SetText("Left", SettingsDirectionMenu)
			end
		end
		ReplayFrame:UnregisterEvent("PLAYER_LOGIN")
	end

	if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" and arg2 ~= "Attack" and arg2 ~= "Combat Swap (DND)" then
		local spellName = arg2
		if select(3, GetSpellInfo(spellName)) == nil then
			AuraDelayFrame:SetScript("OnUpdate", AuraDelay)
		end
		if table.maxn(spellTable) == 0 then
			ReplayTexture0 = ReplayFrame:CreateTexture(nil, "ARTWORK")
			ReplayTexture0:SetPoint("TOPLEFT", 0, 0)
			ReplayTexture0:SetWidth(40)
			ReplayTexture0:SetHeight(40)
			spellTable[1] = spellName
			timestampTable[1] = GetTime()
		elseif spellName ~= spellTable[table.maxn(spellTable)] or spellName == spellTable[table.maxn(spellTable)] and GetTime() - timestampTable[table.maxn(timestampTable)] > 0.5 then
			local i = table.maxn(spellTable)
			_G["ReplayTexture"..i] = ReplayFrame:CreateTexture(_G["ReplayTexture"..i])
			if replaySavedSettings[5] == 1 or replaySavedSettings[5] == nil then
				if _G["ReplayTexture"..(i-1)] == nil or select(4, _G["ReplayTexture"..(i-1)]:GetPoint()) >= 140 then
					_G["ReplayTexture"..i]:SetPoint("TOPLEFT", 0, 0)
				else
					_G["ReplayTexture"..i]:SetPoint("TOPLEFT", select(4, _G["ReplayTexture"..(i-1)]:GetPoint()) - 40, select(5, _G["ReplayTexture"..(i-1)]:GetPoint()))
				end
			elseif replaySavedSettings[5] == 2 then
				if _G["ReplayTexture"..(i-1)] == nil or select(4, _G["ReplayTexture"..(i-1)]:GetPoint()) <= -140 then
					_G["ReplayTexture"..i]:SetPoint("TOPLEFT", 0, 0)
				else
					_G["ReplayTexture"..i]:SetPoint("TOPLEFT", select(4, _G["ReplayTexture"..(i-1)]:GetPoint()) + 40, select(5, _G["ReplayTexture"..(i-1)]:GetPoint()))
				end
			end
			_G["ReplayTexture"..i]:SetWidth(40)
			_G["ReplayTexture"..i]:SetHeight(40)
			spellTable[i+1] = spellName
			timestampTable[i+1] = GetTime()
		end
		if table.maxn(spellTable) > 0 then
			local i = table.maxn(spellTable) - 1
			if spellName == "PvP Trinket" then
				if UnitFactionGroup("player") == "Alliance" then
					_G["ReplayTexture"..i]:SetTexture(select(10, GetItemInfo(18854)))
				else
					_G["ReplayTexture"..i]:SetTexture(select(10, GetItemInfo(18834)))
				end
			elseif spellName == "Faerie Fire (Feral)" then
				_G["ReplayTexture"..i]:SetTexture(select(3, GetSpellInfo("Faerie Fire")))
			elseif strfind(spellName, "Mangle") then
				_G["ReplayTexture"..i]:SetTexture(select(3, GetSpellInfo(33878)))
			elseif spellName == "Restore Mana" then
				_G["ReplayTexture"..i]:SetTexture(select(10, GetItemInfo(22832)))
			elseif spellName == "Healing Potion" then
				_G["ReplayTexture"..i]:SetTexture(select(10, GetItemInfo(22829)))
			elseif spellName == "Refreshment" then
				_G["ReplayTexture"..i]:SetTexture(select(10, GetItemInfo(34062)))
			elseif spellName == "Replenish Mana" then
				_G["ReplayTexture"..i]:SetTexture(select(10, GetItemInfo(22044)))
			elseif spellName == "Master Spellstone" then
				_G["ReplayTexture"..i]:SetTexture(select(10, GetItemInfo(22646)))
			else
				_G["ReplayTexture"..i]:SetTexture(select(3, GetSpellInfo(spellName)))
			end
		end
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, spellCaster, _, _, _, _, spellID = ...
		if arg12 == "REFLECT" and arg7 == UnitName("player") then -- Shield Reflect
			for i=table.maxn(spellTable),0,-1 do
				if _G["ReplayTexture"..i] ~= nil and _G["ReplayUpperTexture"..i] == nil and select(3, GetSpellInfo(23920)) == _G["ReplayTexture"..i]:GetTexture() then
					_G["ReplayUpperTexture"..i] = ReplayFrame:CreateTexture(_G["ReplayUpperTexture"..i])
					_G["ReplayUpperTexture"..i]:SetPoint("CENTER", _G["ReplayTexture"..i], 0, 35)
					_G["ReplayUpperTexture"..i]:SetWidth(25)
					_G["ReplayUpperTexture"..i]:SetHeight(25)
					_G["ReplayUpperTexture"..i]:SetTexture(select(3, GetSpellInfo(spellID)))
					break
				end
			end
		end
		if arg12 == "RESIST" and arg7 == UnitName("player") then -- Cloak of Shadows first resist
			for i=1,40 do
				if select(1, UnitBuff("player", i)) ~= nil then
					local spellName = UnitBuff("player", i)
					if spellName == "Cloak of Shadows" then
						for i=table.maxn(spellTable),0,-1 do
							if _G["ReplayTexture"..i] ~= nil and _G["ReplayUpperTexture"..i] == nil and select(3, GetSpellInfo("Cloak of Shadows")) == _G["ReplayTexture"..i]:GetTexture() then
								_G["ReplayUpperTexture"..i] = ReplayFrame:CreateTexture(_G["ReplayUpperTexture"..i])
								_G["ReplayUpperTexture"..i]:SetPoint("CENTER", _G["ReplayTexture"..i], 0, 35)
								_G["ReplayUpperTexture"..i]:SetWidth(25)
								_G["ReplayUpperTexture"..i]:SetHeight(25)
								_G["ReplayUpperTexture"..i]:SetTexture(select(3, GetSpellInfo(spellID)))
								break
							end
						end
					end
				end
			end
		end
		if arg10 ~= nil and strfind(arg10, "Poison") then -- Poisons applied by Shiv
			i = table.maxn(spellTable) - 1
			if _G["ReplayTexture"..i] ~= nil and _G["ReplayUpperTexture"..i] == nil and select(3, GetSpellInfo(5940)) == _G["ReplayTexture"..i]:GetTexture() and GetTime() - timestampTable[table.maxn(timestampTable)] < 0.03 then
				if eventType == "SPELL_MISSED" and arg12 ~= "ABSORB" then
					_G["ReplayUpperTexture"..i] = ReplayFrame:CreateTexture(_G["ReplayUpperTexture"..i])
					_G["ReplayUpperTexture"..i]:SetPoint("CENTER", _G["ReplayTexture"..i], 0, 35)
					_G["ReplayUpperTexture"..i]:SetWidth(25)
					_G["ReplayUpperTexture"..i]:SetHeight(25)
					_G["ReplayUpperTexture"..i]:SetTexture(select(3, GetSpellInfo(spellID)))
					_G["ReplayUpperFailTexture"..i] = ReplayFrame:CreateTexture(_G["ReplayUpperFailTexture"..i], "OVERLAY")
					_G["ReplayUpperFailTexture"..i]:SetPoint("CENTER", _G["ReplayTexture"..i], 0, 35)
					_G["ReplayUpperFailTexture"..i]:SetWidth(22)
					_G["ReplayUpperFailTexture"..i]:SetHeight(22)
					_G["ReplayUpperFailTexture"..i]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
				else
					_G["ReplayUpperTexture"..i] = ReplayFrame:CreateTexture(_G["ReplayUpperTexture"..i])
					_G["ReplayUpperTexture"..i]:SetPoint("CENTER", _G["ReplayTexture"..i], 0, 35)
					_G["ReplayUpperTexture"..i]:SetWidth(25)
					_G["ReplayUpperTexture"..i]:SetHeight(25)
					_G["ReplayUpperTexture"..i]:SetTexture(select(3, GetSpellInfo(spellID)))
				end
			end
		elseif eventType == "SPELL_MISSED" and spellCaster == UnitName("player") and arg12 ~= "ABSORB" then -- Other missed spells
			if arg10 == "Blind" or arg10 == "Cheap Shot" or arg10 == "Gouge" or arg10 == "Kick" or arg10 == "Kidney Shot" or arg10 == "Counterspell" or arg10 == "Polymorph" or arg10 == "Pummel" or arg10 == "Shield Bash" or arg10 == "Psychic Scream" or arg10 == "Silence" or arg10 == "Bash" or arg10 == "Cyclone" or arg10 == "Entangling Roots" or arg10 == "Maim" or arg10 == "Earth Shock" or arg10 == "Scatter Shot" or arg10 == "Wyvern Sting" then
				SendChatMessage(arg10.." failed ("..arg12..")", "PARTY")
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffffa500"..arg10.." failed ("..arg12..")")
			end
			if arg12 ~= "IMMUNE" and spellID ~= 64382 then -- not Shattering Throw immunes (WotLK)
				for i=table.maxn(spellTable),0,-1 do
					if _G["ReplayTexture"..i] ~= nil and _G["ReplayFont"..i] == nil and select(3, GetSpellInfo(spellID)) == _G["ReplayTexture"..i]:GetTexture() and (GetTime() - timestampTable[i+1] < 1 or strfind(arg10, "Effect") and GetTime() - timestampTable[i+1] < 1.5) then
						_G["ReplayFailTexture"..i] = ReplayFrame:CreateTexture(_G["ReplayFailTexture"..i], "OVERLAY")
						_G["ReplayFailTexture"..i]:SetPoint("CENTER", _G["ReplayTexture"..i])
						_G["ReplayFailTexture"..i]:SetWidth(35)
						_G["ReplayFailTexture"..i]:SetHeight(35)
						_G["ReplayFailTexture"..i]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
						_G["ReplayFont"..i] = ReplayFrame:CreateFontString(_G["ReplayFont"..i], "ARTWORK", "GameFontNormal")
						_G["ReplayFont"..i]:SetPoint("CENTER", _G["ReplayTexture"..i], 0, -25)
						_G["ReplayFont"..i]:SetFont("Fonts\\FRIZQT__.TTF", 8)
						_G["ReplayFont"..i]:SetJustifyH("CENTER")
						_G["ReplayFont"..i]:SetText("|cffffa500"..arg12)
						break
					end
				end
			end
		end
	end
end)

local movSpeed = 25
local ReplayUpdateFrame = CreateFrame("Frame")
ReplayUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
	if spellTable ~= nil and #spellTable > 0 then
		if replaySavedSettings[5] == 1 or replaySavedSettings[5] == nil then
			for i=table.maxn(spellTable)-1,0,-1 do
				if _G["ReplayTexture"..i] ~= nil then
					if _G["ReplayTexture"..(i-1)] ~= nil then
						if select(4, _G["ReplayTexture"..table.maxn(spellTable)-1]:GetPoint()) < 0 then
							movSpeed = 80
						elseif select(4, _G["ReplayTexture"..table.maxn(spellTable)-1]:GetPoint()) < 120 then
							movSpeed = 25
						end
					end
					if select(4, _G["ReplayTexture"..i]:GetPoint()) < 140 then
						_G["ReplayTexture"..i]:SetPoint("TOPLEFT", select(4, _G["ReplayTexture"..i]:GetPoint()) + movSpeed * elapsed, select(5, _G["ReplayTexture"..i]:GetPoint()))
					elseif select(4, _G["ReplayTexture"..i]:GetPoint()) < 160 then
						_G["ReplayTexture"..i]:SetPoint("TOPLEFT", select(4, _G["ReplayTexture"..i]:GetPoint()) + movSpeed * elapsed, select(5, _G["ReplayTexture"..i]:GetPoint()))
						_G["ReplayTexture"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						if _G["ReplayFont"..i] ~= nil then
							_G["ReplayFont"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
						if _G["ReplayFailTexture"..i] ~= nil then
							_G["ReplayFailTexture"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
						if _G["ReplayUpperTexture"..i] ~= nil then
							_G["ReplayUpperTexture"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
						if _G["ReplayUpperFailTexture"..i] ~= nil then
							_G["ReplayUpperFailTexture"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
					elseif _G["ReplayTexture"..i]:IsShown() then
						_G["ReplayTexture"..i]:Hide()
						_G["ReplayTexture"..i] = nil
						if _G["ReplayFont"..i] ~= nil then
							_G["ReplayFont"..i]:Hide()
							_G["ReplayFont"..i] = nil
						end
						if _G["ReplayFailTexture"..i] ~= nil then
							_G["ReplayFailTexture"..i]:Hide()
							_G["ReplayFailTexture"..i] = nil
						end
						if _G["ReplayUpperTexture"..i] ~= nil then
							_G["ReplayUpperTexture"..i]:Hide()
							_G["ReplayUpperTexture"..i] = nil
						end
						if _G["ReplayUpperFailTexture"..i] ~= nil then
							_G["ReplayUpperFailTexture"..i]:Hide()
							_G["ReplayUpperFailTexture"..i] = nil
						end
					end
				else
					break
				end
			end
		elseif replaySavedSettings[5] == 2 then
			for i=table.maxn(spellTable)-1,0,-1 do
				if _G["ReplayTexture"..i] ~= nil then
					if _G["ReplayTexture"..(i-1)] ~= nil then
						if select(4, _G["ReplayTexture"..table.maxn(spellTable)-1]:GetPoint()) > 0 then
							movSpeed = 80
						elseif select(4, _G["ReplayTexture"..table.maxn(spellTable)-1]:GetPoint()) > -120 then
							movSpeed = 25
						end
					end
					if select(4, _G["ReplayTexture"..i]:GetPoint()) > -140 then
						_G["ReplayTexture"..i]:SetPoint("TOPLEFT", select(4, _G["ReplayTexture"..i]:GetPoint()) - movSpeed * elapsed, select(5, _G["ReplayTexture"..i]:GetPoint()))
					elseif select(4, _G["ReplayTexture"..i]:GetPoint()) > -160 then
						_G["ReplayTexture"..i]:SetPoint("TOPLEFT", select(4, _G["ReplayTexture"..i]:GetPoint()) - movSpeed * elapsed, select(5, _G["ReplayTexture"..i]:GetPoint()))
						_G["ReplayTexture"..i]:SetAlpha(abs(-160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						if _G["ReplayFont"..i] ~= nil then
							_G["ReplayFont"..i]:SetAlpha(abs(-160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
						if _G["ReplayFailTexture"..i] ~= nil then
							_G["ReplayFailTexture"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
						if _G["ReplayUpperTexture"..i] ~= nil then
							_G["ReplayUpperTexture"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
						if _G["ReplayUpperFailTexture"..i] ~= nil then
							_G["ReplayUpperFailTexture"..i]:SetAlpha(abs(160 - select(4, _G["ReplayTexture"..i]:GetPoint())) / 20)
						end
					elseif _G["ReplayTexture"..i]:IsShown() then
						_G["ReplayTexture"..i]:Hide()
						_G["ReplayTexture"..i] = nil
						if _G["ReplayFont"..i] ~= nil then
							_G["ReplayFont"..i]:Hide()
							_G["ReplayFont"..i] = nil
						end
						if _G["ReplayFailTexture"..i] ~= nil then
							_G["ReplayFailTexture"..i]:Hide()
							_G["ReplayFailTexture"..i] = nil
						end
						if _G["ReplayUpperTexture"..i] ~= nil then
							_G["ReplayUpperTexture"..i]:Hide()
							_G["ReplayUpperTexture"..i] = nil
						end
						if _G["ReplayUpperFailTexture"..i] ~= nil then
							_G["ReplayUpperFailTexture"..i]:Hide()
							_G["ReplayUpperFailTexture"..i] = nil
						end
					end
				else
					break
				end
			end
		end
	end
end)