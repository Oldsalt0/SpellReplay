-- SpellReplay (TBC/WotLK)

local ReplayFrame = CreateFrame("Frame", "ReplayFrame", UIParent)
ReplayFrame:SetPoint("CENTER")
ReplayFrame:SetWidth(40)
ReplayFrame:SetHeight(40)
ReplayFrame:SetClampedToScreen(true)
ReplayFrame:SetMovable(true)

local ReplayBackground = ReplayFrame:CreateTexture(nil, "BACKGROUND")
ReplayBackground:SetAllPoints()
ReplayBackground:SetTexture(0, 0, 0, 0.15)

local spellcache = setmetatable({}, {__index=function(t, v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
	return unpack(spellcache[a])
end
local replayTexture = {}
local replayFont = {}
local replayFailTexture = {}
local replayUpperTexture = {}
local replayUpperFailTexture = {}
local spellTable = {}
local timestampTable = {}
local replaySettings = {}
replaySettings.panel = CreateFrame("Frame", "ReplaySettingsPanel", UIParent)
replaySettings.panel.name = "SpellReplay"
InterfaceOptions_AddCategory(replaySettings.panel)

local SettingsTitle = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsTitle:SetPoint("TOPLEFT", ReplaySettingsPanel, 15, -15)
SettingsTitle:SetFont("Fonts\\FRIZQT__.TTF", 17)
SettingsTitle:SetText("SpellReplay")

local SettingsGeneralTitle = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsGeneralTitle:SetPoint("TOPLEFT", ReplaySettingsPanel, 15, -40)
SettingsGeneralTitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsGeneralTitle:SetTextColor(1, 1, 1)
SettingsGeneralTitle:SetText("General settings")

local SettingsEnableButton = CreateFrame("CheckButton", nil, ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsEnableButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 25, -60)
SettingsEnableButton:SetHitRectInsets(0, -45, 0, 0)
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
SettingsEnableFont:SetTextColor(1, 1, 1)
SettingsEnableFont:SetText("Enable")

local SettingsLockButton = CreateFrame("CheckButton", nil, ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsLockButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 25, -90)
SettingsLockButton:SetHitRectInsets(0, -90, 0, 0)
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
SettingsLockFont:SetTextColor(1, 1, 1)
SettingsLockFont:SetText("Lock position")

local SettingsBackgroundButton = CreateFrame("CheckButton", "SettingsBackgroundButton", ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsBackgroundButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 25, -120)
SettingsBackgroundButton:SetHitRectInsets(0, -120, 0, 0)
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

local SettingsBackgroundFont = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsBackgroundFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 50, -125)
SettingsBackgroundFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsBackgroundFont:SetTextColor(1, 1, 1)
SettingsBackgroundFont:SetText("Show background")

local SettingsScalingFont = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsScalingFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 230, -50)
SettingsScalingFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
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
SettingsDirectionFont:SetText("Scrolling direction")

local SettingsDirectionMenu = CreateFrame("Button", "SettingsDirectionMenu", ReplaySettingsPanel, "UIDropDownMenuTemplate")
SettingsDirectionMenu:ClearAllPoints()
SettingsDirectionMenu:SetPoint("TOPLEFT", ReplaySettingsPanel, 180, -120)
if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
	UIDropDownMenu_SetWidth(SettingsDirectionMenu, 140)
	UIDropDownMenu_JustifyText(SettingsDirectionMenu, "CENTER")
else
	UIDropDownMenu_SetWidth(140, SettingsDirectionMenu)
	UIDropDownMenu_JustifyText("CENTER", SettingsDirectionMenu)
end
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
		if replaySavedSettings ~= nil and replaySavedSettings[5] ~= 1 then
			replaySavedSettings[5] = 1
			if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
				UIDropDownMenu_SetText(SettingsDirectionMenu, "Right")
			else
				UIDropDownMenu_SetText("Right", SettingsDirectionMenu)
			end
			for i=table.maxn(spellTable),0,-1 do
				if replayTexture[i] ~= nil and replayTexture[i]:IsShown() then
					replayTexture[i]:Hide()
					replayTexture[i] = nil
					if replayFont[i] ~= nil then
						replayFont[i]:Hide()
						replayFont[i] = nil
					end
					if replayFailTexture[i] ~= nil then
						replayFailTexture[i]:Hide()
						replayFailTexture[i] = nil
					end
					if replayUpperTexture[i] ~= nil then
						replayUpperTexture[i]:Hide()
						replayUpperTexture[i] = nil
					end
					if replayUpperFailTexture[i] ~= nil then
						replayUpperFailTexture[i]:Hide()
						replayUpperFailTexture[i] = nil
					end
				elseif replayTexture[i] ~= nil then
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
		if replaySavedSettings ~= nil and replaySavedSettings[5] ~= 2 then
			replaySavedSettings[5] = 2
			if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
				UIDropDownMenu_SetText(SettingsDirectionMenu, "Left")
			else
				UIDropDownMenu_SetText("Left", SettingsDirectionMenu)
			end
			for i=table.maxn(spellTable),0,-1 do
				if replayTexture[i] ~= nil and replayTexture[i]:IsShown() then
					replayTexture[i]:Hide()
					replayTexture[i] = nil
					if replayFont[i] ~= nil then
						replayFont[i]:Hide()
						replayFont[i] = nil
					end
					if replayFailTexture[i] ~= nil then
						replayFailTexture[i]:Hide()
						replayFailTexture[i] = nil
					end
					if replayUpperTexture[i] ~= nil then
						replayUpperTexture[i]:Hide()
						replayUpperTexture[i] = nil
					end
					if replayUpperFailTexture[i] ~= nil then
						replayUpperFailTexture[i]:Hide()
						replayUpperFailTexture[i] = nil
					end
				elseif replayTexture[i] ~= nil then
					break
				end
			end
		end
	end
	UIDropDownMenu_AddButton(directionInitMenu)
end)

local SettingsResistsTitle = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsResistsTitle:SetPoint("TOPLEFT", ReplaySettingsPanel, 15, -170)
SettingsResistsTitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsTitle:SetTextColor(1, 1, 1)
SettingsResistsTitle:SetText("Resists settings")

local SettingsDisplayResistsButton = CreateFrame("CheckButton", nil, ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsDisplayResistsButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 25, -190)
SettingsDisplayResistsButton:SetHitRectInsets(0, -100, 0, 0)
SettingsDisplayResistsButton:SetWidth(25)
SettingsDisplayResistsButton:SetHeight(25)
SettingsDisplayResistsButton:SetScript("OnClick", function()
	if SettingsDisplayResistsButton:GetChecked() then
		replaySavedSettings[6] = 1
		SettingsResistsOnFrameButton:Enable()
		SettingsResistsOnFrameFont:SetTextColor(1, 1, 1)
		SettingsResistsOnChatFrameButton:Enable()
		SettingsResistsOnChatFrameFont:SetTextColor(1, 1, 1)
		SettingsResistsOnPartyButton:Enable()
		SettingsResistsOnPartyFont:SetTextColor(1, 1, 1)
		SettingsPartySpellsMenuButton:Enable()
		SettingsPartySpellsMenuText:SetTextColor(1, 1, 1)
		SettingsPartySpellsAddButton:Enable()
		SettingsPartySpellsDelButton:Enable()
	else
		replaySavedSettings[6] = 0
		SettingsResistsOnFrameButton:Disable()
		SettingsResistsOnFrameFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsResistsOnChatFrameButton:Disable()
		SettingsResistsOnChatFrameFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsResistsOnPartyButton:Disable()
		SettingsResistsOnPartyFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsPartySpellsMenuButton:Disable()
		SettingsPartySpellsMenuText:SetTextColor(0.5, 0.5, 0.5)
		SettingsPartySpellsAddButton:Disable()
		SettingsPartySpellsDelButton:Disable()
	end
end)

local SettingsDisplayResistsFont = ReplaySettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsDisplayResistsFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 50, -196)
SettingsDisplayResistsFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsDisplayResistsFont:SetTextColor(1, 1, 1)
SettingsDisplayResistsFont:SetText("Display resists")

local SettingsResistsOnFrameButton = CreateFrame("CheckButton", "SettingsResistsOnFrameButton", ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsResistsOnFrameButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 40, -215)
SettingsResistsOnFrameButton:SetHitRectInsets(0, -80, 0, 0)
SettingsResistsOnFrameButton:SetWidth(25)
SettingsResistsOnFrameButton:SetHeight(25)
SettingsResistsOnFrameButton:SetScript("OnClick", function()
	if SettingsResistsOnFrameButton:GetChecked() then
		replaySavedSettings[7] = 1
	else
		replaySavedSettings[7] = 0
	end
end)

local SettingsResistsOnFrameFont = ReplaySettingsPanel:CreateFontString("SettingsResistsOnFrameFont", "ARTWORK", "GameFontNormal")
SettingsResistsOnFrameFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 65, -220)
SettingsResistsOnFrameFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsOnFrameFont:SetTextColor(1, 1, 1)
SettingsResistsOnFrameFont:SetText("On the frame")

local SettingsResistsOnChatFrameButton = CreateFrame("CheckButton", "SettingsResistsOnChatFrameButton", ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsResistsOnChatFrameButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 40, -235)
SettingsResistsOnChatFrameButton:SetHitRectInsets(0, -105, 0, 0)
SettingsResistsOnChatFrameButton:SetWidth(25)
SettingsResistsOnChatFrameButton:SetHeight(25)
SettingsResistsOnChatFrameButton:SetScript("OnClick", function()
	if SettingsResistsOnChatFrameButton:GetChecked() then
		replaySavedSettings[8] = 1
	else
		replaySavedSettings[8] = 0
	end
end)

local SettingsResistsOnChatFrameFont = ReplaySettingsPanel:CreateFontString("SettingsResistsOnChatFrameFont", "ARTWORK", "GameFontNormal")
SettingsResistsOnChatFrameFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 65, -240)
SettingsResistsOnChatFrameFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsOnChatFrameFont:SetTextColor(1, 1, 1)
SettingsResistsOnChatFrameFont:SetText("On the chat")

local SettingsResistsOnPartyButton = CreateFrame("CheckButton", "SettingsResistsOnPartyButton", ReplaySettingsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsResistsOnPartyButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 40, -255)
SettingsResistsOnPartyButton:SetHitRectInsets(0, -130, 0, 0)
SettingsResistsOnPartyButton:SetWidth(25)
SettingsResistsOnPartyButton:SetHeight(25)
SettingsResistsOnPartyButton:SetScript("OnClick", function()
	if SettingsResistsOnPartyButton:GetChecked() then
		replaySavedSettings[9] = 1
		SettingsPartySpellsMenuButton:Enable()
		SettingsPartySpellsMenuText:SetTextColor(1, 1, 1)
		SettingsPartySpellsAddButton:Enable()
		SettingsPartySpellsDelButton:Enable()
	else
		replaySavedSettings[9] = 0
		SettingsPartySpellsMenuButton:Disable()
		SettingsPartySpellsMenuText:SetTextColor(0.5, 0.5, 0.5)
		SettingsPartySpellsAddButton:Disable()
		SettingsPartySpellsDelButton:Disable()
	end
end)

local SettingsResistsOnPartyFont = ReplaySettingsPanel:CreateFontString("SettingsResistsOnPartyFont", "ARTWORK", "GameFontNormal")
SettingsResistsOnPartyFont:SetPoint("TOPLEFT", ReplaySettingsPanel, 65, -260)
SettingsResistsOnPartyFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsOnPartyFont:SetTextColor(1, 1, 1)
SettingsResistsOnPartyFont:SetText("On /party for the spells listed below:")

local SettingsPartySpellsMenu = CreateFrame("Button", "SettingsPartySpellsMenu", ReplaySettingsPanel, "UIDropDownMenuTemplate")
SettingsPartySpellsMenu:ClearAllPoints()
SettingsPartySpellsMenu:SetPoint("TOPLEFT", ReplaySettingsPanel, 80, -280)
if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
	UIDropDownMenu_SetWidth(SettingsPartySpellsMenu, 140)
	UIDropDownMenu_JustifyText(SettingsPartySpellsMenu, "CENTER")
else
	UIDropDownMenu_SetWidth(140, SettingsPartySpellsMenu)
	UIDropDownMenu_JustifyText("CENTER", SettingsPartySpellsMenu)
end

if displayToPartyTable == nil then
	displayToPartyTable = {"Cheap Shot", "Kidney Shot"}
end
local partySpellsInitMenu = {}
local function partySpellsInitFunc()
	partySpellsInitMenu.checked = nil
	partySpellsInitMenu.func = nil
	for i,value in pairs(displayToPartyTable) do
		partySpellsInitMenu.text = value
		partySpellsInitMenu.func = function()
			if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
				UIDropDownMenu_SetText(SettingsPartySpellsMenu, value)
			else
				UIDropDownMenu_SetText(value, SettingsPartySpellsMenu)
			end
		end
		UIDropDownMenu_AddButton(partySpellsInitMenu)
	end
end
UIDropDownMenu_Initialize(SettingsPartySpellsMenu, partySpellsInitFunc)

local SettingsPartySpellsAddButton = CreateFrame("Button", "SettingsPartySpellsAddButton", ReplaySettingsPanel, "UIPanelButtonTemplate")
SettingsPartySpellsAddButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 100, -305)
SettingsPartySpellsAddButton:SetWidth(75)
SettingsPartySpellsAddButton:SetHeight(25)
SettingsPartySpellsAddButton:SetText("Add new")
SettingsPartySpellsAddButton:SetScript("OnClick", function()
	StaticPopupDialogs["ADDPARTYSPELL_POPUP"] = {
		text = "Type the name of the spell you want to add",
		button1 = "Add",
		button2 = "Cancel",
		OnShow = function()
			StaticPopup1EditBox:SetText("")
		end,
		OnAccept = function()
			if StaticPopup1EditBox:GetText() ~= "" then
				tinsert(displayToPartyTable, StaticPopup1EditBox:GetText())
				UIDropDownMenu_Initialize(SettingsPartySpellsMenu, partySpellsInitFunc)
			end
		end,
		EditBoxOnEscapePressed = function()
			StaticPopup_Hide("ADDPARTYSPELL_POPUP")
		end,
		exclusive = 1,
		hasEditBox = 1,
		hideOnEscape = 1,
		timeout = 0,
		whileDead = 1,
	}
	StaticPopup_Show ("ADDPARTYSPELL_POPUP")
end)

local SettingsPartySpellsDelButton = CreateFrame("Button", "SettingsPartySpellsDelButton", ReplaySettingsPanel, "UIPanelButtonTemplate")
SettingsPartySpellsDelButton:SetPoint("TOPLEFT", ReplaySettingsPanel, 175, -305)
SettingsPartySpellsDelButton:SetWidth(75)
SettingsPartySpellsDelButton:SetHeight(25)
SettingsPartySpellsDelButton:SetText("Delete")
SettingsPartySpellsDelButton:SetScript("OnClick", function()
	local partySpellToDelete = UIDropDownMenu_GetText(SettingsPartySpellsMenu)
	if partySpellToDelete ~= nil then
		for i,value in pairs(displayToPartyTable) do
			if value == partySpellToDelete then
				tremove(displayToPartyTable, i)
				sort(displayToPartyTable)
				if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
					UIDropDownMenu_SetText(SettingsPartySpellsMenu, "")
				else
					UIDropDownMenu_SetText("", SettingsPartySpellsMenu)
				end
				return
			end
		end
	end
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
						replayTexture[0]:SetTexture(spellIcon)
					else
						replayTexture[table.maxn(spellTable)-1]:SetTexture(spellIcon)
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
		if replaySavedSettings == nil or #replaySavedSettings == 0 or replaySavedSettings[6] == nil then
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
			if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
				UIDropDownMenu_SetText(SettingsDirectionMenu, "Right")
			else
				UIDropDownMenu_SetText("Right", SettingsDirectionMenu)
			end
			replaySavedSettings[5] = 1
			replaySavedSettings[6] = 1
			SettingsDisplayResistsButton:SetChecked()
			replaySavedSettings[7] = 1
			SettingsResistsOnFrameButton:SetChecked()
			replaySavedSettings[8] = 1
			SettingsResistsOnChatFrameButton:SetChecked()
			replaySavedSettings[9] = 1
			SettingsResistsOnPartyButton:SetChecked()
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
				if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
					UIDropDownMenu_SetText(SettingsDirectionMenu, "Right")
				else
					UIDropDownMenu_SetText("Right", SettingsDirectionMenu)
				end
			else
				if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 then
					UIDropDownMenu_SetText(SettingsDirectionMenu, "Left")
				else
					UIDropDownMenu_SetText("Left", SettingsDirectionMenu)
				end
			end
			if replaySavedSettings[6] == 1 then
				SettingsDisplayResistsButton:SetChecked()
			else
				SettingsResistsOnFrameButton:Disable()
				SettingsResistsOnFrameFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsResistsOnChatFrameButton:Disable()
				SettingsResistsOnChatFrameFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsResistsOnPartyButton:Disable()
				SettingsResistsOnPartyFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsPartySpellsMenuButton:Disable()
				SettingsPartySpellsMenuText:SetTextColor(0.5, 0.5, 0.5)
				SettingsPartySpellsAddButton:Disable()
				SettingsPartySpellsDelButton:Disable()
			end
			if replaySavedSettings[7] == 1 then
				SettingsResistsOnFrameButton:SetChecked()
			end
			if replaySavedSettings[8] == 1 then
				SettingsResistsOnChatFrameButton:SetChecked()
			end
			if replaySavedSettings[9] == 1 then
				SettingsResistsOnPartyButton:SetChecked()
			else
				SettingsPartySpellsMenuButton:Disable()
				SettingsPartySpellsMenuText:SetTextColor(0.5, 0.5, 0.5)
				SettingsPartySpellsAddButton:Disable()
				SettingsPartySpellsDelButton:Disable()
			end
		end
		if displayToPartyTable == nil then
			displayToPartyTable = {"Cheap Shot", "Kidney Shot"}
		end
		ReplayFrame:UnregisterEvent("PLAYER_LOGIN")
	end

	if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" and arg2 ~= "Attack" and arg2 ~= "Combat Swap (DND)" then
		local spellName = arg2
		if select(3, GetSpellInfo(spellName)) == nil then
			AuraDelayFrame:SetScript("OnUpdate", AuraDelay)
		end
		if table.maxn(spellTable) == 0 then
			replayTexture[0] = ReplayFrame:CreateTexture(nil, "ARTWORK")
			replayTexture[0]:SetPoint("TOPLEFT", 0, 0)
			replayTexture[0]:SetWidth(40)
			replayTexture[0]:SetHeight(40)
			spellTable[1] = spellName
			timestampTable[1] = GetTime()
		elseif spellName ~= spellTable[table.maxn(spellTable)] or spellName == spellTable[table.maxn(spellTable)] and GetTime() - timestampTable[table.maxn(timestampTable)] > 0.5 then
			local i = table.maxn(spellTable)
			replayTexture[i] = ReplayFrame:CreateTexture(nil)
			if replaySavedSettings[5] == 1 or replaySavedSettings[5] == nil then
				if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) >= 140 then
					replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
				else
					replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) - 40, select(5, replayTexture[i-1]:GetPoint()))
				end
			elseif replaySavedSettings[5] == 2 then
				if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) <= -140 then
					replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
				else
					replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) + 40, select(5, replayTexture[i-1]:GetPoint()))
				end
			end
			replayTexture[i]:SetWidth(40)
			replayTexture[i]:SetHeight(40)
			spellTable[i+1] = spellName
			timestampTable[i+1] = GetTime()
		end
		if table.maxn(spellTable) > 0 then
			local i = table.maxn(spellTable) - 1
			if spellName == "PvP Trinket" then
				if UnitFactionGroup("player") == "Alliance" then
					replayTexture[i]:SetTexture(select(10, GetItemInfo(37864)))
				else
					replayTexture[i]:SetTexture(select(10, GetItemInfo(37865)))
				end
			elseif spellName == "Faerie Fire (Feral)" then
				replayTexture[i]:SetTexture(select(3, GetSpellInfo("Faerie Fire")))
			elseif strfind(spellName, "Mangle") then
				replayTexture[i]:SetTexture(select(3, GetSpellInfo(33878)))
			elseif spellName == "Restore Mana" then
				replayTexture[i]:SetTexture(select(10, GetItemInfo(22832)))
			elseif spellName == "Healing Potion" then
				replayTexture[i]:SetTexture(select(10, GetItemInfo(22829)))
			elseif spellName == "Refreshment" then
				replayTexture[i]:SetTexture(select(10, GetItemInfo(34062)))
			elseif spellName == "Replenish Mana" then
				replayTexture[i]:SetTexture(select(10, GetItemInfo(22044)))
			elseif spellName == "Master Spellstone" then
				replayTexture[i]:SetTexture(select(10, GetItemInfo(22646)))
			else
				replayTexture[i]:SetTexture(select(3, GetSpellInfo(spellName)))
			end
		end
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, spellCaster, _, _, _, _, spellID = ...
		if arg12 == "REFLECT" and arg7 == UnitName("player") then -- Shield Reflect
			for i=table.maxn(spellTable),0,-1 do
				if replayTexture[i] ~= nil and replayUpperTexture[i] == nil and select(3, GetSpellInfo(23920)) == replayTexture[i]:GetTexture() then
					replayUpperTexture[i] = ReplayFrame:CreateTexture(nil)
					replayUpperTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperTexture[i]:SetWidth(25)
					replayUpperTexture[i]:SetHeight(25)
					replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(spellID)))
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
							if replayTexture[i] ~= nil and replayUpperTexture[i] == nil and select(3, GetSpellInfo("Cloak of Shadows")) == replayTexture[i]:GetTexture() then
								replayUpperTexture[i] = ReplayFrame:CreateTexture(nil)
								replayUpperTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
								replayUpperTexture[i]:SetWidth(25)
								replayUpperTexture[i]:SetHeight(25)
								replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(spellID)))
								break
							end
						end
					end
				end
			end
		end
		if arg10 ~= nil and strfind(arg10, "Poison") then -- Poisons applied by Shiv
			i = table.maxn(spellTable) - 1
			if replayTexture[i] ~= nil and replayUpperTexture[i] == nil and select(3, GetSpellInfo(5940)) == replayTexture[i]:GetTexture() and GetTime() - timestampTable[table.maxn(timestampTable)] < 0.03 then
				if eventType == "SPELL_MISSED" and arg12 ~= "ABSORB" then
					replayUpperTexture[i] = ReplayFrame:CreateTexture(nil)
					replayUpperTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperTexture[i]:SetWidth(25)
					replayUpperTexture[i]:SetHeight(25)
					replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(spellID)))
					replayUpperFailTexture[i] = ReplayFrame:CreateTexture(nil, "OVERLAY")
					replayUpperFailTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperFailTexture[i]:SetWidth(22)
					replayUpperFailTexture[i]:SetHeight(22)
					replayUpperFailTexture[i]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
				else
					replayUpperTexture[i] = ReplayFrame:CreateTexture(nil)
					replayUpperTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperTexture[i]:SetWidth(25)
					replayUpperTexture[i]:SetHeight(25)
					replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(spellID)))
				end
			end
		elseif replaySavedSettings[6] == 1 and eventType == "SPELL_MISSED" and spellCaster == UnitName("player") and arg12 ~= "ABSORB" then -- Other missed spells
			if replaySavedSettings[7] == 1 and (spellID ~= 64382 or arg12 ~= "IMMUNE" and spellID == 64382) then -- not Shattering Throw immunes (WotLK)
				for i=table.maxn(spellTable),0,-1 do
					if replayTexture[i] ~= nil and replayFont[i] == nil and select(3, GetSpellInfo(spellID)) == replayTexture[i]:GetTexture() and (GetTime() - timestampTable[i+1] < 1 or strfind(arg10, "Effect") and GetTime() - timestampTable[i+1] < 1.5) then
						replayFailTexture[i] = ReplayFrame:CreateTexture(nil, "OVERLAY")
						replayFailTexture[i]:SetPoint("CENTER", replayTexture[i])
						replayFailTexture[i]:SetWidth(35)
						replayFailTexture[i]:SetHeight(35)
						replayFailTexture[i]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
						replayFont[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
						replayFont[i]:SetPoint("CENTER", replayTexture[i], 0, -25)
						replayFont[i]:SetFont("Fonts\\FRIZQT__.TTF", 8)
						replayFont[i]:SetJustifyH("CENTER")
						replayFont[i]:SetText("|cffffa500"..arg12)
						break
					end
				end
			end
			if replaySavedSettings[8] == 1 then
				DEFAULT_CHAT_FRAME:AddMessage("|cffffa500"..arg10.." failed ("..arg12..")") -- chat frame message for failed spells
			end
			if replaySavedSettings[9] == 1 and displayToPartyTable ~= nil then
				for i,value in pairs(displayToPartyTable) do
					if arg10 == value then
						SendChatMessage(arg10.." failed ("..arg12..")", "PARTY") -- /party message for all the failed spells on displayToPartyTable
						return
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
				if replayTexture[i] ~= nil then
					if replayTexture[i-1] ~= nil then
						if select(4, replayTexture[table.maxn(spellTable)-1]:GetPoint()) < 0 then
							movSpeed = 80
						elseif select(4, replayTexture[table.maxn(spellTable)-1]:GetPoint()) < 120 then
							movSpeed = 25
						end
					end
					if select(4, replayTexture[i]:GetPoint()) < 140 then
						replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i]:GetPoint()) + movSpeed * elapsed, select(5, replayTexture[i]:GetPoint()))
					elseif select(4, replayTexture[i]:GetPoint()) < 160 then
						replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i]:GetPoint()) + movSpeed * elapsed, select(5, replayTexture[i]:GetPoint()))
						replayTexture[i]:SetAlpha(abs(160 - select(4, replayTexture[i]:GetPoint())) / 20)
						if replayFont[i] ~= nil then
							replayFont[i]:SetAlpha(abs(160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
						if replayFailTexture[i] ~= nil then
							replayFailTexture[i]:SetAlpha(abs(160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
						if replayUpperTexture[i] ~= nil then
							replayUpperTexture[i]:SetAlpha(abs(160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
						if replayUpperFailTexture[i] ~= nil then
							replayUpperFailTexture[i]:SetAlpha(abs(160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
					elseif replayTexture[i]:IsShown() then
						replayTexture[i]:Hide()
						replayTexture[i] = nil
						if replayFont[i] ~= nil then
							replayFont[i]:Hide()
							replayFont[i] = nil
						end
						if replayFailTexture[i] ~= nil then
							replayFailTexture[i]:Hide()
							replayFailTexture[i] = nil
						end
						if replayUpperTexture[i] ~= nil then
							replayUpperTexture[i]:Hide()
							replayUpperTexture[i] = nil
						end
						if replayUpperFailTexture[i] ~= nil then
							replayUpperFailTexture[i]:Hide()
							replayUpperFailTexture[i] = nil
						end
					end
				else
					break
				end
			end
		elseif replaySavedSettings[5] == 2 then
			for i=table.maxn(spellTable)-1,0,-1 do
				if replayTexture[i] ~= nil then
					if replayTexture[i-1] ~= nil then
						if select(4, replayTexture[table.maxn(spellTable)-1]:GetPoint()) > 0 then
							movSpeed = 80
						elseif select(4, replayTexture[table.maxn(spellTable)-1]:GetPoint()) > -120 then
							movSpeed = 25
						end
					end
					if select(4, replayTexture[i]:GetPoint()) > -140 then
						replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i]:GetPoint()) - movSpeed * elapsed, select(5, replayTexture[i]:GetPoint()))
					elseif select(4, replayTexture[i]:GetPoint()) > -160 then
						replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i]:GetPoint()) - movSpeed * elapsed, select(5, replayTexture[i]:GetPoint()))
						replayTexture[i]:SetAlpha(abs(-160 - select(4, replayTexture[i]:GetPoint())) / 20)
						if replayFont[i] ~= nil then
							replayFont[i]:SetAlpha(abs(-160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
						if replayFailTexture[i] ~= nil then
							replayFailTexture[i]:SetAlpha(abs(-160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
						if replayUpperTexture[i] ~= nil then
							replayUpperTexture[i]:SetAlpha(abs(-160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
						if replayUpperFailTexture[i] ~= nil then
							replayUpperFailTexture[i]:SetAlpha(abs(-160 - select(4, replayTexture[i]:GetPoint())) / 20)
						end
					elseif replayTexture[i]:IsShown() then
						replayTexture[i]:Hide()
						replayTexture[i] = nil
						if replayFont[i] ~= nil then
							replayFont[i]:Hide()
							replayFont[i] = nil
						end
						if replayFailTexture[i] ~= nil then
							replayFailTexture[i]:Hide()
							replayFailTexture[i] = nil
						end
						if replayUpperTexture[i] ~= nil then
							replayUpperTexture[i]:Hide()
							replayUpperTexture[i] = nil
						end
						if replayUpperFailTexture[i] ~= nil then
							replayUpperFailTexture[i]:Hide()
							replayUpperFailTexture[i] = nil
						end
					end
				else
					break
				end
			end
		end
	end
end)