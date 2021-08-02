-- SpellReplay (TBC Classic)
local LibSharedMedia = LibStub("LibSharedMedia-3.0")
local ReplayFrame = CreateFrame("Frame", "ReplayFrame", UIParent)
ReplayFrame:SetPoint("CENTER")
ReplayFrame:SetWidth(40)
ReplayFrame:SetHeight(40)
ReplayFrame:SetClampedToScreen(true)
ReplayFrame:SetMovable(true)

local ReplayBackground = ReplayFrame:CreateTexture(nil, "BACKGROUND")
ReplayBackground:SetAllPoints()
ReplayBackground:SetColorTexture(0, 0, 0, 0.15)

local InterfaceOptionsFrame_OpenToFrame = InterfaceOptionsFrame_OpenToFrame	InterfaceOptionsFrame_OpenToFrame = InterfaceOptionsFrame_OpenToCategory
local ReplayButton = CreateFrame("Button", "ReplayButton", ReplayFrame)
ReplayButton:SetAllPoints()
ReplayButton:SetScript("OnMouseDown", function(self, button)
	if replaySavedSettings[12] == 0 then
		if not InterfaceOptionsFrame:IsShown() and not GameMenuFrame:IsShown() and button == "RightButton" then
			InterfaceOptionsFrame_OpenToFrame("SpellReplay")
		elseif InterfaceOptionsFrame:IsShown() and button == "RightButton" then
			InterfaceOptionsFrame:Hide()
		else
			ReplayFrame:StartMoving()
		end
	end
end)
ReplayButton:SetScript("OnMouseUp", function(self, button) if replaySavedSettings[12] == 0 then ReplayFrame:StopMovingOrSizing() end end)
ReplayButton:SetScript("OnEnter", function() if replaySavedSettings[13] == 0 then ReplayBackground:Show() end end)
ReplayButton:SetScript("OnLeave", function() if replaySavedSettings[13] == 0 then ReplayBackground:Hide() end end)

local spellcache = setmetatable({}, {__index=function(t, v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end}) -- caching GetSpellInfo() outputs
local function GetSpellInfo(a)
		return unpack(spellcache[a])
end
local replayTexture = {}
local replayRank = {}
local replayDamage = {}
local replayFont = {}
local replayFailTexture = {}
local replayUpperTexture = {}
local replayUpperFailTexture = {}
local spellTable = {}
local timestampTable = {}
local movSpeed = 0
local endPos = 0
local replaySettings = {}
replaySettings.panel = CreateFrame("Frame", "ReplaySettingsPanel", UIParent)
replaySettings.panel.name = "SpellReplay"
InterfaceOptions_AddCategory(replaySettings.panel)
replaySettings.childpanel = CreateFrame( "Frame", "ReplaySettingsGeneralPanel", replaySettings.panel)
replaySettings.childpanel.name = "General settings"
replaySettings.childpanel.parent = replaySettings.panel.name
InterfaceOptions_AddCategory(replaySettings.childpanel)
replaySettings.childpanel = CreateFrame( "Frame", "ReplaySettingsResistsPanel", replaySettings.panel)
replaySettings.childpanel.name = "Resists settings"
replaySettings.childpanel.parent = replaySettings.panel.name
InterfaceOptions_AddCategory(replaySettings.childpanel)
replaySettings.childpanel = CreateFrame( "Frame", "ReplaySettingsOptionalPanel", replaySettings.panel)
replaySettings.childpanel.name = "Optional settings"
replaySettings.childpanel.parent = replaySettings.panel.name
InterfaceOptions_AddCategory(replaySettings.childpanel)
replaySettings = nil

ReplaySettingsPanel:SetScript("OnShow", function() -- fixing ugly panel/childpanels behaviour
	for i=1,50 do
		if _G["InterfaceOptionsFrameAddOnsButton"..i]:GetText() == "SpellReplay" then
			if _G["InterfaceOptionsFrameAddOnsButton"..(i+1)]:GetText() == "General settings" then
				if ReplaySettingsPanel:IsShown() then
					_G["InterfaceOptionsFrameAddOnsButton"..(i+1)]:Click()
				end
			else
				_G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
				_G["InterfaceOptionsFrameAddOnsButton"..(i+1)]:Click()
			end
			break
		end
	end
	ReplayResetButton:Show()
end)
ReplaySettingsPanel:SetScript("OnHide", function()
	if InterfaceOptionsFrame:IsShown() then
		ReplaySettingsPanel:Hide()
	end
	ReplayResetButton:Hide()
end)
ReplaySettingsGeneralPanel:SetScript("OnShow", function()
	for i=1,50 do
		if _G["InterfaceOptionsFrameAddOnsButton"..i]:GetText() == "SpellReplay" then
			if _G["InterfaceOptionsFrameAddOnsButton"..(i+1)]:GetText() == "General settings" and _G["InterfaceOptionsFrameAddOnsButton"..(i+1)]:IsShown() then
				_G["InterfaceOptionsFrameAddOnsButton"..(i+1)]:Click()
			else
				_G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
			end
			break
		end
	end
	ReplayResetButton:Show()
end)
ReplaySettingsGeneralPanel:SetScript("OnHide", function()
	if InterfaceOptionsFrame:IsShown() then
		ReplaySettingsGeneralPanel:Hide()
	end
	ReplayResetButton:Hide()
end)
ReplaySettingsResistsPanel:SetScript("OnShow", function() ReplayResetButton:Show() end)
ReplaySettingsResistsPanel:SetScript("OnHide", function() ReplayResetButton:Hide() end)
ReplaySettingsOptionalPanel:SetScript("OnShow", function() ReplayResetButton:Show() end)
ReplaySettingsOptionalPanel:SetScript("OnHide", function() ReplayResetButton:Hide() end)

--

local SettingsGeneralTitle = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal") -- General settings
SettingsGeneralTitle:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 15, -15)
SettingsGeneralTitle:SetFont("Fonts\\FRIZQT__.TTF", 17)
SettingsGeneralTitle:SetText("SpellReplay")

local SettingsGeneralSubtitle = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsGeneralSubtitle:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 15, -40)
SettingsGeneralSubtitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsGeneralSubtitle:SetTextColor(1, 1, 1)
SettingsGeneralSubtitle:SetText("General settings")

local SettingsEnableButton = CreateFrame("CheckButton", nil, ReplaySettingsGeneralPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsEnableButton:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 25, -60)
SettingsEnableButton:SetHitRectInsets(0, -45, 0, 0)
SettingsEnableButton:SetWidth(25)
SettingsEnableButton:SetHeight(25)
SettingsEnableButton:SetScript("OnClick", function()
	if SettingsEnableButton:GetChecked() then
		replaySavedSettings[11] = 1
		if not ReplayFrame:IsShown() then
			ReplayFrame:Show()
		end
	else
		replaySavedSettings[11] = 0
		if ReplayFrame:IsShown() then
			ReplayFrame:Hide()
		end
	end
end)

local SettingsEnableFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsEnableFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 50, -65)
SettingsEnableFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsEnableFont:SetTextColor(1, 1, 1)
SettingsEnableFont:SetText("Enable")

local SettingsLockButton = CreateFrame("CheckButton", nil, ReplaySettingsGeneralPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsLockButton:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 25, -90)
SettingsLockButton:SetHitRectInsets(0, -90, 0, 0)
SettingsLockButton:SetWidth(25)
SettingsLockButton:SetHeight(25)
SettingsLockButton:SetScript("OnClick", function()
	if SettingsLockButton:GetChecked() then
		replaySavedSettings[12] = 1
	else
		replaySavedSettings[12] = 0
	end
end)

local SettingsLockFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsLockFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 50, -95)
SettingsLockFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsLockFont:SetTextColor(1, 1, 1)
SettingsLockFont:SetText("Lock position")

local SettingsBackgroundButton = CreateFrame("CheckButton", "SettingsBackgroundButton", ReplaySettingsGeneralPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsBackgroundButton:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 25, -120)
SettingsBackgroundButton:SetHitRectInsets(0, -120, 0, 0)
SettingsBackgroundButton:SetWidth(25)
SettingsBackgroundButton:SetHeight(25)
SettingsBackgroundButton:SetScript("OnClick", function()
	if SettingsBackgroundButton:GetChecked() then
		replaySavedSettings[13] = 1
		ReplayBackground:Show()
	else
		replaySavedSettings[13] = 0
		ReplayBackground:Hide()
	end
end)

local SettingsBackgroundFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsBackgroundFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 50, -125)
SettingsBackgroundFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsBackgroundFont:SetTextColor(1, 1, 1)
SettingsBackgroundFont:SetText("Show background")

local SettingsScalingFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsScalingFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 230, -50)
SettingsScalingFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsScalingFont:SetText("Frame scaling")

local SettingsScalingSlider = CreateFrame("Slider", "SettingsScalingSlider", ReplaySettingsGeneralPanel, "OptionsSliderTemplate")
SettingsScalingSlider:ClearAllPoints()
SettingsScalingSlider:SetPoint("TOPLEFT", 200, -65)
SettingsScalingSlider:SetMinMaxValues(0, 7)
SettingsScalingSlider:SetWidth(150)
SettingsScalingSliderLow:SetText(" |cffffffff0.8")
SettingsScalingSliderHigh:SetText("|cffffffff1.5 ")
SettingsScalingSlider:SetValueStep(1)
SettingsScalingSlider:SetObeyStepOnDrag(true)
SettingsScalingSlider:SetHitRectInsets(0, 0, -5, -5)
SettingsScalingSlider:SetScript("OnMouseUp", function(self, button)
	if SettingsScalingSlider:GetValue() > 0 then
		replaySavedSettings[14] = 0.8 + SettingsScalingSlider:GetValue() / 10
	else
		replaySavedSettings[14] = 0.8
	end
	ReplayFrame:SetScale(replaySavedSettings[14])
end)
SettingsScalingSlider:SetScript("OnValueChanged", function()
	if SettingsScalingSlider:GetValue() > 0 then
		replaySavedSettings[14] = 0.8 + SettingsScalingSlider:GetValue() / 10
	else
		replaySavedSettings[14] = 0.8
	end
	ReplayFrame:SetScale(replaySavedSettings[14])
	GameTooltip:SetOwner(SettingsScalingSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Scaling: x"..replaySavedSettings[14])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)
SettingsScalingSlider:SetScript("OnEnter", function()
	if SettingsScalingSlider:GetValue() > 0 then
		replaySavedSettings[14] = 0.8 + SettingsScalingSlider:GetValue() / 10
	else
		replaySavedSettings[14] = 0.8
	end
	ReplayFrame:SetScale(replaySavedSettings[14])
	GameTooltip:SetOwner(SettingsScalingSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Scaling: x"..replaySavedSettings[14])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)

local SettingsDirectionFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsDirectionFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 200, -105)
SettingsDirectionFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsDirectionFont:SetText("Scrolling direction")

local SettingsDirectionMenu = CreateFrame("Button", "SettingsDirectionMenu", ReplaySettingsGeneralPanel, "UIDropDownMenuTemplate")
SettingsDirectionMenu:ClearAllPoints()
SettingsDirectionMenu:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 180, -120)
UIDropDownMenu_SetWidth(SettingsDirectionMenu, 140)
UIDropDownMenu_JustifyText(SettingsDirectionMenu, "CENTER")

--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
local function createDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local dropdown_width = 0
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end


local fonts, newFonts = LibSharedMedia:List("font"), {}
for k, v in pairs(fonts) do
	newFonts[v] = v
end

local directionInitMenu = {}
UIDropDownMenu_Initialize(SettingsDirectionMenu, function()
	directionInitMenu.checked = nil
	directionInitMenu.func = nil
	directionInitMenu.text = "Right"
	directionInitMenu.checked = function()
		if replaySavedSettings ~= nil and replaySavedSettings[15] == 1 then
			return true
		else
			return nil
		end
	end
	directionInitMenu.func = function()
		if replaySavedSettings ~= nil and replaySavedSettings[15] ~= 1 then
			replaySavedSettings[15] = 1
			UIDropDownMenu_SetText(SettingsDirectionMenu, "Right")
			for i=table.maxn(spellTable)-1,0,-1 do
				if replayTexture[i] == nil then
					break
				else
					replayTexture[i]:Hide()
					replayTexture[i] = nil
					if replayRank[i] ~= nil then
						replayRank[i]:Hide()
						replayRank[i] = nil
					end
					if replayDamage[i] ~= nil then
						replayDamage[i]:Hide()
						replayDamage[i] = nil
					end
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
			end
		end
	end
	UIDropDownMenu_AddButton(directionInitMenu)
	directionInitMenu.text = "Left"
	directionInitMenu.checked = function()
		if replaySavedSettings ~= nil and replaySavedSettings[15] == 2 then
			return true
		else
			return nil
		end
	end
	directionInitMenu.func = function()
		if replaySavedSettings ~= nil and replaySavedSettings[15] ~= 2 then
			replaySavedSettings[15] = 2
			UIDropDownMenu_SetText(SettingsDirectionMenu, "Left")
			for i=table.maxn(spellTable)-1,0,-1 do
				if replayTexture[i] == nil then
					break
				else
					replayTexture[i]:Hide()
					replayTexture[i] = nil
					if replayRank[i] ~= nil then
						replayRank[i]:Hide()
						replayRank[i] = nil
					end
					if replayDamage[i] ~= nil then
						replayDamage[i]:Hide()
						replayDamage[i] = nil
					end
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
			end
		end
	end
	UIDropDownMenu_AddButton(directionInitMenu)
end)

local SettingsCropTexButton = CreateFrame("CheckButton", "SettingsCropTexButton", ReplaySettingsGeneralPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsCropTexButton:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 25, -150)
SettingsCropTexButton:SetHitRectInsets(0, -120, 0, 0)
SettingsCropTexButton:SetWidth(25)
SettingsCropTexButton:SetHeight(25)
SettingsCropTexButton:SetScript("OnClick", function()
	if SettingsCropTexButton:GetChecked() then
		replaySavedSettings[16] = 1
		for i=table.maxn(spellTable)-1,0,-1 do
			if replayTexture[i] ~= nil then
				replayTexture[i]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
			else
				break
			end
		end
	else
		replaySavedSettings[16] = 0
		for i=table.maxn(spellTable)-1,0,-1 do
			if replayTexture[i] ~= nil then
				replayTexture[i]:SetTexCoord(0, 1, 0, 1)
			else
				break
			end
		end
	end
end)

local SettingsCropTexFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsCropTexFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 50, -155)
SettingsCropTexFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsCropTexFont:SetTextColor(1, 1, 1)
SettingsCropTexFont:SetText("Crop spell borders")

local SettingsSpeedSubtitle = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsSpeedSubtitle:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 15, -210)
SettingsSpeedSubtitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsSpeedSubtitle:SetTextColor(1, 1, 1)
SettingsSpeedSubtitle:SetText("Scrolling speed settings")

local SettingsPushSpeedFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsPushSpeedFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 60, -235)
SettingsPushSpeedFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsPushSpeedFont:SetText("Push speed |cffffffff(i)")

local SettingsPushSpeedInfoFrame = CreateFrame("Frame", "SettingsPushSpeedInfoFrame", ReplaySettingsGeneralPanel)
SettingsPushSpeedInfoFrame:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 136, -235)
SettingsPushSpeedInfoFrame:SetWidth(15)
SettingsPushSpeedInfoFrame:SetHeight(15)
SettingsPushSpeedInfoFrame:EnableMouse(true)
SettingsPushSpeedInfoFrame:SetScript("OnEnter", function()
	GameTooltip:SetOwner(SettingsPushSpeedInfoFrame, "ANCHOR_RIGHT", 10, -10)
	GameTooltip:SetText("high amount of spells in quick succession")
	GameTooltip:Show()
end)
SettingsPushSpeedInfoFrame:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

local SettingsPushSpeedSlider = CreateFrame("Slider", "SettingsPushSpeedSlider", ReplaySettingsGeneralPanel, "OptionsSliderTemplate")
SettingsPushSpeedSlider:ClearAllPoints()
SettingsPushSpeedSlider:SetPoint("TOPLEFT", 20, -250)
SettingsPushSpeedSlider:SetMinMaxValues(0, 24)
SettingsPushSpeedSlider:SetWidth(150)
SettingsPushSpeedSliderLow:SetText(" |cffffffff30")
SettingsPushSpeedSliderHigh:SetText("|cffffffff150 ")
SettingsPushSpeedSlider:SetValueStep(1)
SettingsPushSpeedSlider:SetObeyStepOnDrag(true)
SettingsPushSpeedSlider:SetHitRectInsets(0, 0, -5, -5)
SettingsPushSpeedSlider:SetScript("OnMouseUp", function(self, button)
	replaySavedSettings[17] = 30 + SettingsPushSpeedSlider:GetValue() * 5
end)
SettingsPushSpeedSlider:SetScript("OnValueChanged", function()
	replaySavedSettings[17] = 30 + SettingsPushSpeedSlider:GetValue() * 5
	GameTooltip:SetOwner(SettingsPushSpeedSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Push speed: "..replaySavedSettings[17])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)
SettingsPushSpeedSlider:SetScript("OnEnter", function()
	replaySavedSettings[17] = 30 + SettingsPushSpeedSlider:GetValue() * 5
	GameTooltip:SetOwner(SettingsPushSpeedSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Push speed: "..replaySavedSettings[17])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)

local SettingsBaseSpeedFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsBaseSpeedFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 60, -285)
SettingsBaseSpeedFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsBaseSpeedFont:SetText("Base speed")

local SettingsBaseSpeedSlider = CreateFrame("Slider", "SettingsBaseSpeedSlider", ReplaySettingsGeneralPanel, "OptionsSliderTemplate")
SettingsBaseSpeedSlider:ClearAllPoints()
SettingsBaseSpeedSlider:SetPoint("TOPLEFT", 20, -300)
SettingsBaseSpeedSlider:SetMinMaxValues(0, 20)
SettingsBaseSpeedSlider:SetWidth(150)
SettingsBaseSpeedSliderLow:SetText("  |cffffffff0")
SettingsBaseSpeedSliderHigh:SetText("|cffffffff100 ")
SettingsBaseSpeedSlider:SetValueStep(1)
SettingsBaseSpeedSlider:SetObeyStepOnDrag(true)
SettingsBaseSpeedSlider:SetHitRectInsets(0, 0, -5, -5)
SettingsBaseSpeedSlider:SetScript("OnMouseUp", function(self, button)
	replaySavedSettings[18] = SettingsBaseSpeedSlider:GetValue() * 5
end)
SettingsBaseSpeedSlider:SetScript("OnValueChanged", function()
	replaySavedSettings[18] = SettingsBaseSpeedSlider:GetValue() * 5
	GameTooltip:SetOwner(SettingsBaseSpeedSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Base speed "..replaySavedSettings[18])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)
SettingsBaseSpeedSlider:SetScript("OnEnter", function()
	replaySavedSettings[18] = SettingsBaseSpeedSlider:GetValue() * 5
	GameTooltip:SetOwner(SettingsBaseSpeedSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Base speed: "..replaySavedSettings[18])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)

local SettingsCastingSpeedFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsCastingSpeedFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 51, -335)
SettingsCastingSpeedFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsCastingSpeedFont:SetText("Casting speed")

local SettingsCastingSpeedSlider = CreateFrame("Slider", "SettingsCastingSpeedSlider", ReplaySettingsGeneralPanel, "OptionsSliderTemplate")
SettingsCastingSpeedSlider:ClearAllPoints()
SettingsCastingSpeedSlider:SetPoint("TOPLEFT", 20, -350)
SettingsCastingSpeedSlider:SetMinMaxValues(0, 20)
SettingsCastingSpeedSlider:SetWidth(150)
SettingsCastingSpeedSliderLow:SetText("  |cffffffff0")
SettingsCastingSpeedSliderHigh:SetText("|cffffffff100 ")
SettingsCastingSpeedSlider:SetValueStep(1)
SettingsCastingSpeedSlider:SetObeyStepOnDrag(true)
SettingsCastingSpeedSlider:SetHitRectInsets(0, 0, -5, -5)
SettingsCastingSpeedSlider:SetScript("OnMouseUp", function(self, button)
	replaySavedSettings[19] = SettingsCastingSpeedSlider:GetValue() * 5
end)
SettingsCastingSpeedSlider:SetScript("OnValueChanged", function()
	replaySavedSettings[19] = SettingsCastingSpeedSlider:GetValue() * 5
	GameTooltip:SetOwner(SettingsCastingSpeedSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Casting speed: "..replaySavedSettings[19])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)
SettingsCastingSpeedSlider:SetScript("OnEnter", function()
	replaySavedSettings[19] = SettingsCastingSpeedSlider:GetValue() * 5
	GameTooltip:SetOwner(SettingsCastingSpeedSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Casting speed: "..replaySavedSettings[19])
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)

local SettingsSpellNbFont = ReplaySettingsGeneralPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsSpellNbFont:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 202, -165)
SettingsSpellNbFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsSpellNbFont:SetText("Nb. of spells to display")

local SettingsSpellNbSlider = CreateFrame("Slider", "SettingsSpellNbSlider", ReplaySettingsGeneralPanel, "OptionsSliderTemplate")
SettingsSpellNbSlider:ClearAllPoints()
SettingsSpellNbSlider:SetPoint("TOPLEFT", 200, -180)
SettingsSpellNbSlider:SetMinMaxValues(0, 4)
SettingsSpellNbSlider:SetWidth(150)
SettingsSpellNbSliderLow:SetText("  |cffffffff2")
SettingsSpellNbSliderHigh:SetText("|cffffffff6  ")
SettingsSpellNbSlider:SetValueStep(1)
SettingsSpellNbSlider:SetObeyStepOnDrag(true)
SettingsSpellNbSlider:SetHitRectInsets(0, 0, -5, -5)
SettingsSpellNbSlider:SetScript("OnMouseUp", function(self, button)
	replaySavedSettings[20] = SettingsSpellNbSlider:GetValue() + 2
end)
SettingsSpellNbSlider:SetScript("OnValueChanged", function()
	replaySavedSettings[20] = SettingsSpellNbSlider:GetValue() + 2
	GameTooltip:SetOwner(SettingsSpellNbSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Displayed: "..replaySavedSettings[20].." spells")
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)
SettingsSpellNbSlider:SetScript("OnEnter", function()
	replaySavedSettings[20] = SettingsSpellNbSlider:GetValue() + 2
	GameTooltip:SetOwner(SettingsSpellNbSlider, "ANCHOR_TOP", 120, 20)
	GameTooltip:SetText("Displayed: "..replaySavedSettings[20].." spells")
	GameTooltip:Show()
	GameTooltip:FadeOut()
end)

--

local SettingsResistsTitle = ReplaySettingsResistsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal") -- Resists settings
SettingsResistsTitle:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 15, -15)
SettingsResistsTitle:SetFont("Fonts\\FRIZQT__.TTF", 17)
SettingsResistsTitle:SetText("SpellReplay")

local SettingsResistsSubtitle = ReplaySettingsResistsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsResistsSubtitle:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 15, -40)
SettingsResistsSubtitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsSubtitle:SetTextColor(1, 1, 1)
SettingsResistsSubtitle:SetText("Resists settings")

local SettingsDisplayResistsButton = CreateFrame("CheckButton", nil, ReplaySettingsResistsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsDisplayResistsButton:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 25, -60)
SettingsDisplayResistsButton:SetHitRectInsets(0, -100, 0, 0)
SettingsDisplayResistsButton:SetWidth(25)
SettingsDisplayResistsButton:SetHeight(25)
SettingsDisplayResistsButton:SetScript("OnClick", function()
	if SettingsDisplayResistsButton:GetChecked() then
		replaySavedSettings[21] = 1
		SettingsResistsOnFrameButton:Enable()
		SettingsResistsOnFrameFont:SetTextColor(1, 1, 1)
		SettingsResistsOnChatFrameButton:Enable()
		SettingsResistsOnChatFrameFont:SetTextColor(1, 1, 1)
		SettingsResistsOnPartyButton:Enable()
		SettingsResistsOnPartyFont:SetTextColor(1, 1, 1)
		if SettingsResistsOnPartyButton:GetChecked() then
			DisplayToPartyAddButton:Enable()
			DisplayToPartyDelButton:Enable()
			for i,value in pairs(displayToPartyTable) do
				if _G["SettingsListContentButton"..i] ~= nil then
					_G["SettingsListContentButton"..i]:Enable()
					_G["SettingsListContentFont"..i]:SetTextColor(1, 1, 1)
				end
			end
		end
	else
		replaySavedSettings[21] = 0
		SettingsResistsOnFrameButton:Disable()
		SettingsResistsOnFrameFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsResistsOnChatFrameButton:Disable()
		SettingsResistsOnChatFrameFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsResistsOnPartyButton:Disable()
		SettingsResistsOnPartyFont:SetTextColor(0.5, 0.5, 0.5)
		DisplayToPartyAddButton:Disable()
		DisplayToPartyDelButton:Disable()
		for i,value in pairs(displayToPartyTable) do
			if _G["SettingsListContentButton"..i] ~= nil then
				_G["SettingsListContentFont"..i]:SetTextColor(0.5, 0.5, 0.5)
				_G["SettingsListContentButton"..i]:Disable()
			end
		end
	end
end)

local SettingsDisplayResistsFont = ReplaySettingsResistsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsDisplayResistsFont:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 50, -65)
SettingsDisplayResistsFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsDisplayResistsFont:SetTextColor(1, 1, 1)
SettingsDisplayResistsFont:SetText("Display resists")

local SettingsResistsOnFrameButton = CreateFrame("CheckButton", "SettingsResistsOnFrameButton", ReplaySettingsResistsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsResistsOnFrameButton:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 40, -85)
SettingsResistsOnFrameButton:SetHitRectInsets(0, -80, 0, 0)
SettingsResistsOnFrameButton:SetWidth(25)
SettingsResistsOnFrameButton:SetHeight(25)
SettingsResistsOnFrameButton:SetScript("OnClick", function()
	if SettingsResistsOnFrameButton:GetChecked() then
		replaySavedSettings[22] = 1
	else
		replaySavedSettings[22] = 0
	end
end)

local SettingsResistsOnFrameFont = ReplaySettingsResistsPanel:CreateFontString("SettingsResistsOnFrameFont", "ARTWORK", "GameFontNormal")
SettingsResistsOnFrameFont:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 65, -90)
SettingsResistsOnFrameFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsOnFrameFont:SetTextColor(1, 1, 1)
SettingsResistsOnFrameFont:SetText("On the frame")

local SettingsResistsOnChatFrameButton = CreateFrame("CheckButton", "SettingsResistsOnChatFrameButton", ReplaySettingsResistsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsResistsOnChatFrameButton:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 40, -105)
SettingsResistsOnChatFrameButton:SetHitRectInsets(0, -105, 0, 0)
SettingsResistsOnChatFrameButton:SetWidth(25)
SettingsResistsOnChatFrameButton:SetHeight(25)
SettingsResistsOnChatFrameButton:SetScript("OnClick", function()
	if SettingsResistsOnChatFrameButton:GetChecked() then
		replaySavedSettings[23] = 1
	else
		replaySavedSettings[23] = 0
	end
end)

local SettingsResistsOnChatFrameFont = ReplaySettingsResistsPanel:CreateFontString("SettingsResistsOnChatFrameFont", "ARTWORK", "GameFontNormal")
SettingsResistsOnChatFrameFont:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 65, -110)
SettingsResistsOnChatFrameFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsOnChatFrameFont:SetTextColor(1, 1, 1)
SettingsResistsOnChatFrameFont:SetText("On the chat")

local SettingsResistsOnPartyButton = CreateFrame("CheckButton", "SettingsResistsOnPartyButton", ReplaySettingsResistsPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsResistsOnPartyButton:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 40, -125)
SettingsResistsOnPartyButton:SetHitRectInsets(0, -130, 0, 0)
SettingsResistsOnPartyButton:SetWidth(25)
SettingsResistsOnPartyButton:SetHeight(25)
SettingsResistsOnPartyButton:SetScript("OnClick", function()
	if SettingsResistsOnPartyButton:GetChecked() then
		replaySavedSettings[24] = 1
		DisplayToPartyAddButton:Enable()
		DisplayToPartyDelButton:Enable()
		for i,value in pairs(displayToPartyTable) do
			if _G["SettingsListContentButton"..i] ~= nil then
				_G["SettingsListContentButton"..i]:Enable()
				_G["SettingsListContentFont"..i]:SetTextColor(1, 1, 1)
			end
		end
	else
		replaySavedSettings[24] = 0
		DisplayToPartyAddButton:Disable()
		DisplayToPartyDelButton:Disable()
		for i,value in pairs(displayToPartyTable) do
			if _G["SettingsListContentButton"..i] ~= nil then
				_G["SettingsListContentFont"..i]:SetTextColor(0.5, 0.5, 0.5)
				_G["SettingsListContentButton"..i]:Disable()
			end
		end
	end
end)

local SettingsResistsOnPartyFont = ReplaySettingsResistsPanel:CreateFontString("SettingsResistsOnPartyFont", "ARTWORK", "GameFontNormal")
SettingsResistsOnPartyFont:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 65, -130)
SettingsResistsOnPartyFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsResistsOnPartyFont:SetTextColor(1, 1, 1)
SettingsResistsOnPartyFont:SetText("On /party for the spells listed below:")

local SettingsListBorder = CreateFrame("Frame", "SettingsListBorder", ReplaySettingsResistsPanel)
SettingsListBorder:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 80, -150)
SettingsListBorder:SetWidth(160)
SettingsListBorder:SetHeight(150)


local SettingsListFrame = CreateFrame("Frame", nil, SettingsListBorder)
SettingsListFrame:SetPoint("CENTER")
SettingsListFrame:SetWidth(160)
SettingsListFrame:SetHeight(150)

local SettingsListTexture = SettingsListFrame:CreateTexture()
SettingsListTexture:SetWidth(156)
SettingsListTexture:SetHeight(146)
SettingsListTexture:SetPoint("CENTER")
SettingsListTexture:SetColorTexture(0, 0, 0, 0.5)

local SettingsListScrollFrame = CreateFrame("ScrollFrame", "SettingsListScrollFrame", SettingsListFrame)
SettingsListScrollFrame:SetPoint("TOPLEFT", 4, -5)
SettingsListScrollFrame:SetPoint("BOTTOMRIGHT", 4, 4)
SettingsListScrollFrame:SetWidth(160)
SettingsListScrollFrame:SetHeight(150)

local SettingsListScrollBar = CreateFrame("Slider", nil, SettingsListScrollFrame, "UIPanelScrollBarTemplate")
SettingsListScrollBar:SetPoint("TOPRIGHT", SettingsListFrame, "TOPRIGHT", -4, -20)
SettingsListScrollBar:SetPoint("BOTTOMRIGHT", SettingsListFrame, "BOTTOMRIGHT", -4, 19)
SettingsListScrollBar:SetMinMaxValues(0, 0)
SettingsListScrollBar:SetValueStep(20)
SettingsListScrollBar:SetObeyStepOnDrag(true)
SettingsListScrollBar.scrollStep = 1
SettingsListScrollBar:SetValue(0)
SettingsListScrollBar:SetWidth(16)
SettingsListScrollBar:SetScript("OnValueChanged", function(self, value)
	local scrollBarMin, scrollBarMax = SettingsListScrollBar:GetMinMaxValues()
	if SettingsListScrollBar:GetValue() == scrollBarMin then
		SettingsListScrollFrameScrollUpButton:Disable()
	elseif SettingsListScrollFrameScrollUpButton:IsEnabled() == 0 then
		SettingsListScrollFrameScrollUpButton:Enable()
	end
	if SettingsListScrollBar:GetValue() == scrollBarMax then
		SettingsListScrollFrameScrollDownButton:Disable()
	elseif SettingsListScrollFrameScrollDownButton:IsEnabled() == 0 then
		SettingsListScrollFrameScrollDownButton:Enable()
	end
	self:GetParent():SetVerticalScroll(value)
end)
SettingsListScrollFrameScrollUpButton:Disable()
SettingsListScrollFrameScrollUpButton:SetScript("OnClick", function()
	SettingsListScrollBar:SetValue(SettingsListScrollBar:GetValue() - 20)
end)
SettingsListScrollFrameScrollDownButton:Disable()
SettingsListScrollFrameScrollDownButton:SetScript("OnClick", function()
	SettingsListScrollBar:SetValue(SettingsListScrollBar:GetValue() + 20)
end)
SettingsListScrollFrame.SettingsListScrollBar = SettingsListScrollBar

local SettingsListScrollBarBackground = SettingsListScrollBar:CreateTexture(nil,"BACKGROUND")
SettingsListScrollBarBackground:SetAllPoints()
SettingsListScrollBarBackground:SetColorTexture(0,0,0,0.6)

local SettingsListContentFrame = CreateFrame("Frame", nil, SettingsListScrollFrame)
SettingsListContentFrame:SetWidth(160)
SettingsListContentFrame:SetHeight(150)

SettingsListScrollFrame.SettingsListContentFrame = SettingsListContentFrame
SettingsListScrollFrame:SetScrollChild(SettingsListContentFrame)

SettingsListScrollFrame:EnableMouseWheel(true)
SettingsListScrollFrame:SetScript("OnMouseWheel", function(self, delta)
	local scrollBarMin, scrollBarMax = SettingsListScrollBar:GetMinMaxValues()
	if delta < 0 and SettingsListScrollBar:GetValue() < scrollBarMax then
		SettingsListScrollBar:SetValue(SettingsListScrollBar:GetValue() + 20)
	elseif delta > 0 and SettingsListScrollBar:GetValue() > scrollBarMin then
		SettingsListScrollBar:SetValue(SettingsListScrollBar:GetValue() - 20)
	end
end)

local displayToPartySelection = 0
local function DisplayToPartyListing()
	for i,value in pairs(displayToPartyTable) do
		if _G["SettingsListContentButton"..i] == nil then
			_G["SettingsListContentButton"..i] = CreateFrame("Button", "SettingsListContentButton"..i, SettingsListContentFrame, "FriendsFrameIgnoreButtonTemplate")
			_G["SettingsListContentButton"..i]:SetPoint("TOPLEFT", 0, -20 * (i-1))
			_G["SettingsListContentButton"..i]:SetWidth(140)
			_G["SettingsListContentButton"..i]:SetHeight(20)
			_G["SettingsListContentFont"..i] = SettingsListContentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			_G["SettingsListContentFont"..i]:SetPoint("LEFT", _G["SettingsListContentButton"..i], 12, 0)
			_G["SettingsListContentFont"..i]:SetTextColor(1, 1, 1)
			_G["SettingsListContentButton"..i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			_G["SettingsListContentButton"..i]:SetScript("OnClick", function()
				for k=1,#displayToPartyTable do
					if k == tonumber(select(3, strfind(_G["SettingsListContentButton"..i]:GetName(), "(%d+)"))) then
						_G["SettingsListContentButton"..i]:LockHighlight()
						displayToPartySelection = i
					else
						_G["SettingsListContentButton"..k]:UnlockHighlight()
					end
				end
			end)
		end
		_G["SettingsListContentFont"..i]:SetText(value)
		_G["SettingsListContentButton"..i]:Show()
		if i == #displayToPartyTable then
			SettingsListScrollBar:SetMinMaxValues(0, max(0,(i-7)*20))
			if i > 7 then
				SettingsListScrollFrameScrollDownButton:Enable()
			else
				SettingsListScrollFrameScrollDownButton:Disable()
			end
		end
	end
end

local DisplayToPartyAddButton = CreateFrame("Button", "DisplayToPartyAddButton", ReplaySettingsResistsPanel, "UIPanelButtonTemplate")
DisplayToPartyAddButton:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 85, -300)
DisplayToPartyAddButton:SetWidth(75)
DisplayToPartyAddButton:SetHeight(25)
DisplayToPartyAddButton:SetText("Add new")
DisplayToPartyAddButton:SetScript("OnClick", function()
	StaticPopupDialogs["ADDPARTYSPELL_POPUP"] = {
		text = "Type the name of the spell you want to add\n(Capital letters are important)",
		button1 = "Add",
		button2 = "Cancel",
		OnShow = function()
			StaticPopup1EditBox:SetText("")
		end,
		OnAccept = function()
			if StaticPopup1EditBox:GetText() ~= "" then
				tinsert(displayToPartyTable, StaticPopup1EditBox:GetText())
				sort(displayToPartyTable)
				DisplayToPartyListing()
			end
		end,
		EditBoxOnEnterPressed = function()
			if StaticPopup1EditBox:GetText() ~= "" then
				tinsert(displayToPartyTable, StaticPopup1EditBox:GetText())
				sort(displayToPartyTable)
				DisplayToPartyListing()
				StaticPopup_Hide("ADDPARTYSPELL_POPUP")
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

local DisplayToPartyDelButton = CreateFrame("Button", "DisplayToPartyDelButton", ReplaySettingsResistsPanel, "UIPanelButtonTemplate")
DisplayToPartyDelButton:SetPoint("TOPLEFT", ReplaySettingsResistsPanel, 160, -300)
DisplayToPartyDelButton:SetWidth(75)
DisplayToPartyDelButton:SetHeight(25)
DisplayToPartyDelButton:SetText("Delete")
DisplayToPartyDelButton:SetScript("OnClick", function()
	if displayToPartySelection ~= 0 and displayToPartyTable[displayToPartySelection] ~= nil then
		_G["SettingsListContentButton"..displayToPartySelection]:UnlockHighlight()
		for i,value in pairs(displayToPartyTable) do
			_G["SettingsListContentFont"..i]:SetText("")
			_G["SettingsListContentButton"..i]:Hide()
		end
		tremove(displayToPartyTable, displayToPartySelection)
		sort(displayToPartyTable)
		displayToPartySelection = 0
		DisplayToPartyListing()
	end
end)

--

local SettingsOptionalTitle = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsOptionalTitle:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 15, -15)
SettingsOptionalTitle:SetFont("Fonts\\FRIZQT__.TTF", 17)
SettingsOptionalTitle:SetText("SpellReplay")

local SettingsOptionalSubtitle = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsOptionalSubtitle:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 15, -40)
SettingsOptionalSubtitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsOptionalSubtitle:SetTextColor(1, 1, 1)
SettingsOptionalSubtitle:SetText("Optional settings")

local SettingsRanksButton = CreateFrame("CheckButton", nil, ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate") -- Optional settings
SettingsRanksButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 25, -60)
SettingsRanksButton:SetHitRectInsets(0, -100, 0, 0)
SettingsRanksButton:SetWidth(25)
SettingsRanksButton:SetHeight(25)
SettingsRanksButton:SetScript("OnClick", function()
	if SettingsRanksButton:GetChecked() then
		SettingsAllRanksButton:Enable()
		SettingsAllRanksFont:SetTextColor(1, 1, 1)
		SettingsRankOneButton:Enable()
		SettingsRankOneFont:SetTextColor(1, 1, 1)
		if SettingsAllRanksButton:GetChecked() then
			replaySavedSettings[31] = 1
		else
			SettingsRankOneButton:SetChecked(true)
			replaySavedSettings[31] = 2
		end
	else
		replaySavedSettings[31] = 0
		SettingsAllRanksButton:Disable()
		SettingsAllRanksFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsRankOneButton:Disable()
		SettingsRankOneFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsRanksFont = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsRanksFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 50, -65)
SettingsRanksFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsRanksFont:SetTextColor(1, 1, 1)
SettingsRanksFont:SetText("Display spell ranks")

local SettingsAllRanksButton = CreateFrame("CheckButton", "SettingsAllRanksButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsAllRanksButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -85)
SettingsAllRanksButton:SetHitRectInsets(0, -80, 0, 0)
SettingsAllRanksButton:SetWidth(25)
SettingsAllRanksButton:SetHeight(25)
SettingsAllRanksButton:SetScript("OnClick", function()
	if SettingsAllRanksButton:GetChecked() then
		replaySavedSettings[31] = 1
		SettingsAllRanksButton:SetChecked(true)
		SettingsRankOneButton:SetChecked(false)
	else
		replaySavedSettings[31] = 0
		SettingsRanksButton:SetChecked(false)
		SettingsAllRanksButton:SetChecked(false)
		SettingsAllRanksButton:SetButtonState("NORMAL")
		SettingsAllRanksButton:Disable()
		SettingsAllRanksFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsRankOneButton:Disable()
		SettingsRankOneFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsAllRanksFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsAllRanksFont", "ARTWORK", "GameFontNormal")
SettingsAllRanksFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -90)
SettingsAllRanksFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsAllRanksFont:SetTextColor(1, 1, 1)
SettingsAllRanksFont:SetText("All ranks")

local SettingsRankOneButton = CreateFrame("CheckButton", "SettingsRankOneButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsRankOneButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -105)
SettingsRankOneButton:SetHitRectInsets(0, -105, 0, 0)
SettingsRankOneButton:SetWidth(25)
SettingsRankOneButton:SetHeight(25)
SettingsRankOneButton:SetScript("OnClick", function()
	if SettingsRankOneButton:GetChecked() then
		replaySavedSettings[31] = 2
		SettingsAllRanksButton:SetChecked(false)
		SettingsRankOneButton:SetChecked(true)
	else
		replaySavedSettings[31] = 0
		SettingsRanksButton:SetChecked(false)
		SettingsAllRanksButton:SetChecked(false)
		SettingsRankOneButton:SetButtonState("NORMAL")
		SettingsAllRanksButton:Disable()
		SettingsAllRanksFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsRankOneButton:Disable()
		SettingsRankOneFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsRankOneFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsRankOneFont", "ARTWORK", "GameFontNormal")
SettingsRankOneFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -110)
SettingsRankOneFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsRankOneFont:SetTextColor(1, 1, 1)
SettingsRankOneFont:SetText("Rank 1 only")

local SettingsWhiteHitsButton = CreateFrame("CheckButton", nil, ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsWhiteHitsButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 25, -135)
SettingsWhiteHitsButton:SetHitRectInsets(0, -100, 0, 0)
SettingsWhiteHitsButton:SetWidth(25)
SettingsWhiteHitsButton:SetHeight(25)
SettingsWhiteHitsButton:SetScript("OnClick", function()
	if SettingsWhiteHitsButton:GetChecked() then
		SettingsMeleeWhiteHitsButton:Enable()
		SettingsMeleeWhiteHitsFont:SetTextColor(1, 1, 1)
		SettingsRangedWhiteHitsButton:Enable()
		SettingsRangedWhiteHitsFont:SetTextColor(1, 1, 1)
		if SettingsMeleeWhiteHitsButton:GetChecked() and SettingsRangedWhiteHitsButton:GetChecked() then
			replaySavedSettings[32] = 3
		elseif SettingsMeleeWhiteHitsButton:GetChecked() then
			replaySavedSettings[32] = 1
		else
			replaySavedSettings[32] = 2
			SettingsRangedWhiteHitsButton:SetChecked(true)
		end
	else
		replaySavedSettings[32] = 0
		SettingsMeleeWhiteHitsButton:Disable()
		SettingsMeleeWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsRangedWhiteHitsButton:Disable()
		SettingsRangedWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsWhiteHitsFont = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsWhiteHitsFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 50, -140)
SettingsWhiteHitsFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsWhiteHitsFont:SetTextColor(1, 1, 1)
SettingsWhiteHitsFont:SetText("Display white hits")

local SettingsMeleeWhiteHitsButton = CreateFrame("CheckButton", "SettingsMeleeWhiteHitsButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsMeleeWhiteHitsButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -160)
SettingsMeleeWhiteHitsButton:SetHitRectInsets(0, -80, 0, 0)
SettingsMeleeWhiteHitsButton:SetWidth(25)
SettingsMeleeWhiteHitsButton:SetHeight(25)
SettingsMeleeWhiteHitsButton:SetScript("OnClick", function()
	if SettingsMeleeWhiteHitsButton:GetChecked() then
		if SettingsRangedWhiteHitsButton:GetChecked() then
			replaySavedSettings[32] = 3
		else
			replaySavedSettings[32] = 1
		end
	else
		if SettingsRangedWhiteHitsButton:GetChecked() then
			replaySavedSettings[32] = 2
		else
			replaySavedSettings[32] = 0
			SettingsWhiteHitsButton:SetChecked(false)
			SettingsMeleeWhiteHitsButton:SetButtonState("NORMAL")
			SettingsMeleeWhiteHitsButton:Disable()
			SettingsMeleeWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
			SettingsRangedWhiteHitsButton:Disable()
			SettingsRangedWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
		end
	end
end)

local SettingsMeleeWhiteHitsFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsMeleeWhiteHitsFont", "ARTWORK", "GameFontNormal")
SettingsMeleeWhiteHitsFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -165)
SettingsMeleeWhiteHitsFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsMeleeWhiteHitsFont:SetTextColor(1, 1, 1)
SettingsMeleeWhiteHitsFont:SetText("Melee white hits")

local SettingsRangedWhiteHitsButton = CreateFrame("CheckButton", "SettingsRangedWhiteHitsButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsRangedWhiteHitsButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -180)
SettingsRangedWhiteHitsButton:SetHitRectInsets(0, -105, 0, 0)
SettingsRangedWhiteHitsButton:SetWidth(25)
SettingsRangedWhiteHitsButton:SetHeight(25)
SettingsRangedWhiteHitsButton:SetScript("OnClick", function()
	if SettingsRangedWhiteHitsButton:GetChecked() then
		if SettingsMeleeWhiteHitsButton:GetChecked() then
			replaySavedSettings[32] = 3
		else
			replaySavedSettings[32] = 2
		end
	else
		if SettingsMeleeWhiteHitsButton:GetChecked() then
			replaySavedSettings[32] = 1
		else
			replaySavedSettings[32] = 0
			SettingsWhiteHitsButton:SetChecked(false)
			SettingsRangedWhiteHitsButton:SetButtonState("NORMAL")
			SettingsMeleeWhiteHitsButton:Disable()
			SettingsMeleeWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
			SettingsRangedWhiteHitsButton:Disable()
			SettingsRangedWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
		end
	end
end)

local SettingsRangedWhiteHitsFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsRangedWhiteHitsFont", "ARTWORK", "GameFontNormal")
SettingsRangedWhiteHitsFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -185)
SettingsRangedWhiteHitsFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsRangedWhiteHitsFont:SetTextColor(1, 1, 1)
SettingsRangedWhiteHitsFont:SetText("Ranged white hits")

local SettingsDamagesButton = CreateFrame("CheckButton", nil, ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsDamagesButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 25, -210)
SettingsDamagesButton:SetHitRectInsets(0, -100, 0, 0)
SettingsDamagesButton:SetWidth(25)
SettingsDamagesButton:SetHeight(25)
SettingsDamagesButton:SetScript("OnClick", function()
	if SettingsDamagesButton:GetChecked() then
		SettingsAllDamagesButton:Enable()
		SettingsAllDamagesFont:SetTextColor(1, 1, 1)
		SettingsCritDamagesButton:Enable()
		SettingsCritDamagesFont:SetTextColor(1, 1, 1)
		if SettingsCritDamagesButton:GetChecked() then
			replaySavedSettings[33] = 2
		else
			SettingsAllDamagesButton:SetChecked(true)
			replaySavedSettings[33] = 1
		end
	else
		replaySavedSettings[33] = 0
		SettingsAllDamagesButton:Disable()
		SettingsAllDamagesFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsCritDamagesButton:Disable()
		SettingsCritDamagesFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsDamagesFont = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsDamagesFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 50, -215)
SettingsDamagesFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsDamagesFont:SetTextColor(1, 1, 1)
SettingsDamagesFont:SetText("Display damages")

local SettingsAllDamagesButton = CreateFrame("CheckButton", "SettingsAllDamagesButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsAllDamagesButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -235)
SettingsAllDamagesButton:SetHitRectInsets(0, -80, 0, 0)
SettingsAllDamagesButton:SetWidth(25)
SettingsAllDamagesButton:SetHeight(25)
SettingsAllDamagesButton:SetScript("OnClick", function()
	if SettingsAllDamagesButton:GetChecked() then
		replaySavedSettings[33] = 1
		SettingsAllDamagesButton:SetChecked(true)
		SettingsCritDamagesButton:SetChecked(false)
	else
		replaySavedSettings[33] = 0
		SettingsDamagesButton:SetChecked(false)
		SettingsAllDamagesButton:SetChecked(false)
		SettingsAllDamagesButton:SetButtonState("NORMAL")
		SettingsAllDamagesButton:Disable()
		SettingsAllDamagesFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsCritDamagesButton:Disable()
		SettingsCritDamagesFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsAllDamagesFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsAllDamagesFont", "ARTWORK", "GameFontNormal")
SettingsAllDamagesFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -240)
SettingsAllDamagesFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsAllDamagesFont:SetTextColor(1, 1, 1)
SettingsAllDamagesFont:SetText("All damages")

local SettingsCritDamagesButton = CreateFrame("CheckButton", "SettingsCritDamagesButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsCritDamagesButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -255)
SettingsCritDamagesButton:SetHitRectInsets(0, -105, 0, 0)
SettingsCritDamagesButton:SetWidth(25)
SettingsCritDamagesButton:SetHeight(25)
SettingsCritDamagesButton:SetScript("OnClick", function()
	if SettingsCritDamagesButton:GetChecked() then
		replaySavedSettings[33] = 2
		SettingsAllDamagesButton:SetChecked(false)
		SettingsCritDamagesButton:SetChecked(true)
	else
		replaySavedSettings[33] = 0
		SettingsDamagesButton:SetChecked(false)
		SettingsCritDamagesButton:SetChecked(false)
		SettingsCritDamagesButton:SetButtonState("NORMAL")
		SettingsAllDamagesButton:Disable()
		SettingsAllDamagesFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsCritDamagesButton:Disable()
		SettingsCritDamagesFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsCritDamagesFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsCritDamagesFont", "ARTWORK", "GameFontNormal")
SettingsCritDamagesFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -260)
SettingsCritDamagesFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsCritDamagesFont:SetTextColor(1, 1, 1)
SettingsCritDamagesFont:SetText("Critical damages only")

local SettingsHealsButton = CreateFrame("CheckButton", nil, ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsHealsButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 25, -285)
SettingsHealsButton:SetHitRectInsets(0, -100, 0, 0)
SettingsHealsButton:SetWidth(25)
SettingsHealsButton:SetHeight(25)
SettingsHealsButton:SetScript("OnClick", function()
	if SettingsHealsButton:GetChecked() then
		SettingsAllHealsButton:Enable()
		SettingsAllHealsFont:SetTextColor(1, 1, 1)
		SettingsCritHealsButton:Enable()
		SettingsCritHealsFont:SetTextColor(1, 1, 1)
		if SettingsCritHealsButton:GetChecked() then
			replaySavedSettings[34] = 2
		else
			SettingsAllHealsButton:SetChecked(true)
			replaySavedSettings[34] = 1
		end
	else
		replaySavedSettings[34] = 0
		SettingsAllHealsButton:Disable()
		SettingsAllHealsFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsCritHealsButton:Disable()
		SettingsCritHealsFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsHealsFont = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsHealsFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 50, -290)
SettingsHealsFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsHealsFont:SetTextColor(1, 1, 1)
SettingsHealsFont:SetText("Display heals")

local SettingsAllHealsButton = CreateFrame("CheckButton", "SettingsAllHealsButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsAllHealsButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -310)
SettingsAllHealsButton:SetHitRectInsets(0, -80, 0, 0)
SettingsAllHealsButton:SetWidth(25)
SettingsAllHealsButton:SetHeight(25)
SettingsAllHealsButton:SetScript("OnClick", function()
	if SettingsAllHealsButton:GetChecked() then
		replaySavedSettings[34] = 1
		SettingsAllHealsButton:SetChecked(true)
		SettingsCritHealsButton:SetChecked(false)
	else
		replaySavedSettings[34] = 0
		SettingsHealsButton:SetChecked(false)
		SettingsAllHealsButton:SetChecked(false)
		SettingsAllHealsButton:SetButtonState("NORMAL")
		SettingsAllHealsButton:Disable()
		SettingsAllHealsFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsCritHealsButton:Disable()
		SettingsCritHealsFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsAllHealsFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsAllHealsFont", "ARTWORK", "GameFontNormal")
SettingsAllHealsFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -315)
SettingsAllHealsFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsAllHealsFont:SetTextColor(1, 1, 1)
SettingsAllHealsFont:SetText("All heals")

local SettingsCritHealsButton = CreateFrame("CheckButton", "SettingsCritHealsButton", ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsCritHealsButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 40, -330)
SettingsCritHealsButton:SetHitRectInsets(0, -105, 0, 0)
SettingsCritHealsButton:SetWidth(25)
SettingsCritHealsButton:SetHeight(25)
SettingsCritHealsButton:SetScript("OnClick", function()
	if SettingsCritHealsButton:GetChecked() then
		replaySavedSettings[34] = 2
		SettingsAllHealsButton:SetChecked(false)
		SettingsCritHealsButton:SetChecked(true)
	else
		replaySavedSettings[34] = 0
		SettingsHealsButton:SetChecked(false)
		SettingsCritHealsButton:SetChecked(false)
		SettingsCritHealsButton:SetButtonState("NORMAL")
		SettingsAllHealsButton:Disable()
		SettingsAllHealsFont:SetTextColor(0.5, 0.5, 0.5)
		SettingsCritHealsButton:Disable()
		SettingsCritHealsFont:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local SettingsCritHealsFont = ReplaySettingsOptionalPanel:CreateFontString("SettingsCritHealsFont", "ARTWORK", "GameFontNormal")
SettingsCritHealsFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 65, -335)
SettingsCritHealsFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
SettingsCritHealsFont:SetTextColor(1, 1, 1)
SettingsCritHealsFont:SetText("Critical heals only")

local SettingsManaButton = CreateFrame("CheckButton", nil, ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsManaButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 25, -360)
SettingsManaButton:SetHitRectInsets(0, -100, 0, 0)
SettingsManaButton:SetWidth(25)
SettingsManaButton:SetHeight(25)
SettingsManaButton:SetScript("OnClick", function()
	if SettingsManaButton:GetChecked() then
		replaySavedSettings[35] = 1
	else
		replaySavedSettings[35] = 0
	end
end)

local SettingsManaFont = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsManaFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 50, -365)
SettingsManaFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsManaFont:SetTextColor(1, 1, 1)
SettingsManaFont:SetText("Display mana gains")

local SettingsPetSpellsButton = CreateFrame("CheckButton", nil, ReplaySettingsOptionalPanel, "InterfaceOptionsCheckButtonTemplate")
SettingsPetSpellsButton:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 200, -60)
SettingsPetSpellsButton:SetHitRectInsets(0, -100, 0, 0)
SettingsPetSpellsButton:SetWidth(25)
SettingsPetSpellsButton:SetHeight(25)
SettingsPetSpellsButton:SetScript("OnClick", function()
	if SettingsPetSpellsButton:GetChecked() then
		replaySavedSettings[36] = 1
	else
		replaySavedSettings[36] = 0
	end
end)

local SettingsPetSpellsFont = ReplaySettingsOptionalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
SettingsPetSpellsFont:SetPoint("TOPLEFT", ReplaySettingsOptionalPanel, 225, -65)
SettingsPetSpellsFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
SettingsPetSpellsFont:SetTextColor(1, 1, 1)
SettingsPetSpellsFont:SetText("Display pet spells")

-- RESET DIALOGUE

StaticPopupDialogs["REPLAYRESET_POPUP"] = {
	text = "",
	button1 = "Yes",
	button2 = "Cancel",
	OnShow = function()
		if ReplaySettingsGeneralPanel:IsShown() then
			StaticPopup1Text:SetText("Reset General settings to default?")
		elseif ReplaySettingsResistsPanel:IsShown() then
			StaticPopup1Text:SetText("Reset Resists settings to default?")
		elseif ReplaySettingsOptionalPanel:IsShown() then
			StaticPopup1Text:SetText("Reset Optional settings to default?")
		end
	end,
	OnAccept = function()
		if ReplaySettingsGeneralPanel:IsShown() then
			replaySavedSettings[11] = 1
			SettingsEnableButton:SetChecked(true)
			ReplayFrame:ClearAllPoints()
			ReplayFrame:SetPoint("CENTER")
			ReplayFrame:Show()
			replaySavedSettings[12] = 0
			replaySavedSettings[13] = 1
			SettingsBackgroundButton:SetChecked(true)
			ReplayBackground:Show()
			replaySavedSettings[14] = 1
			SettingsScalingSlider:SetValue(2)
			ReplayFrame:SetScale(1)
			replaySavedSettings[15] = 1
			UIDropDownMenu_SetText(SettingsDirectionMenu, "Right")
			for i=table.maxn(spellTable)-1,0,-1 do
				if replayTexture[i] ~= nil then
					replayTexture[i]:Hide()
					replayTexture[i] = nil
					if replayRank[i] ~= nil then
						replayRank[i]:Hide()
						replayRank[i] = nil
					end
					if replayDamage[i] ~= nil then
						replayDamage[i]:Hide()
						replayDamage[i] = nil
					end
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
				else
					break
				end
			end
			replaySavedSettings[16] = 1
			SettingsCropTexButton:SetChecked(true)
			replaySavedSettings[17] = 100
			SettingsPushSpeedSlider:SetValue(14)
			replaySavedSettings[18] = 30
			SettingsBaseSpeedSlider:SetValue(6)
			replaySavedSettings[19] = 30
			SettingsCastingSpeedSlider:SetValue(6)
			replaySavedSettings[20] = 4
			SettingsSpellNbSlider:SetValue(2)
		elseif ReplaySettingsResistsPanel:IsShown() then
			replaySavedSettings[21] = 1
			SettingsDisplayResistsButton:SetChecked(true)
			replaySavedSettings[22] = 1
			SettingsResistsOnFrameButton:SetChecked(true)
			replaySavedSettings[23] = 1
			SettingsResistsOnChatFrameButton:SetChecked(true)
			replaySavedSettings[24] = 1
			SettingsResistsOnPartyButton:SetChecked(true)
			for i,value in pairs(displayToPartyTable) do
				_G["SettingsListContentButton"..i]:UnlockHighlight()
				_G["SettingsListContentButton"..i]:SetText("")
				_G["SettingsListContentButton"..i]:Hide()
			end
			displayToPartyTable = {}
			SettingsListScrollBar:SetMinMaxValues(0, 0)
			SettingsListScrollBar:SetValue(0)
			SettingsListScrollFrameScrollUpButton:Disable()
			SettingsListScrollFrameScrollDownButton:Disable()
			SettingsResistsOnFrameButton:Enable()
			SettingsResistsOnFrameFont:SetTextColor(1, 1, 1)
			SettingsResistsOnChatFrameButton:Enable()
			SettingsResistsOnChatFrameFont:SetTextColor(1, 1, 1)
			SettingsResistsOnPartyButton:Enable()
			SettingsResistsOnPartyFont:SetTextColor(1, 1, 1)
			DisplayToPartyAddButton:Enable()
			DisplayToPartyDelButton:Enable()
		elseif ReplaySettingsOptionalPanel:IsShown() then
			replaySavedSettings[31] = 2
			SettingsRanksButton:SetChecked(true)
			SettingsAllRanksButton:SetChecked(false)
			SettingsRankOneButton:SetChecked(true)
			replaySavedSettings[32] = 2
			SettingsWhiteHitsButton:SetChecked(true)
			SettingsMeleeWhiteHitsButton:SetChecked(false)
			SettingsRangedWhiteHitsButton:SetChecked(true)
			replaySavedSettings[33] = 1
			SettingsDamagesButton:SetChecked(true)
			SettingsAllDamagesButton:SetChecked(true)
			SettingsCritDamagesButton:SetChecked(false)
			replaySavedSettings[34] = 1
			SettingsHealsButton:SetChecked(true)
			SettingsAllHealsButton:SetChecked(true)
			SettingsCritHealsButton:SetChecked(false)
			replaySavedSettings[35] = 1
			SettingsManaButton:SetChecked(true)
			replaySavedSettings[36] = 1
			SettingsPetSpellsButton:SetChecked(true)
			SettingsAllRanksButton:Enable()
			SettingsAllRanksFont:SetTextColor(1, 1, 1)
			SettingsRankOneButton:Enable()
			SettingsRankOneFont:SetTextColor(1, 1, 1)
			SettingsMeleeWhiteHitsButton:Enable()
			SettingsMeleeWhiteHitsFont:SetTextColor(1, 1, 1)
			SettingsRangedWhiteHitsButton:Enable()
			SettingsRangedWhiteHitsFont:SetTextColor(1, 1, 1)
			SettingsAllDamagesButton:Enable()
			SettingsAllDamagesFont:SetTextColor(1, 1, 1)
			SettingsCritDamagesButton:Enable()
			SettingsCritDamagesFont:SetTextColor(1, 1, 1)
			SettingsAllHealsButton:Enable()
			SettingsAllHealsFont:SetTextColor(1, 1, 1)
			SettingsCritHealsButton:Enable()
			SettingsCritHealsFont:SetTextColor(1, 1, 1)
		end
	end,
	exclusive = 1,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}
local ReplayResetButton = CreateFrame("Button", "ReplayResetButton", InterfaceOptionsFrame, "UIPanelButtonGrayTemplate")
ReplayResetButton:SetPoint("TOPRIGHT", -32, -413)
ReplayResetButton:SetText("Reset to default")
ReplayResetButton:SetWidth(120)
ReplayResetButton:SetHeight(25)
ReplayResetButton:Hide()
ReplayResetButton:SetScript("OnClick", function()
	StaticPopup_Show ("REPLAYRESET_POPUP")
end)

--

local total = 0
local AuraDelayFrame = CreateFrame("Frame")
local function AuraDelay(self, elapsed)
	total = total + elapsed
	for i=1,40 do
		if select(1, UnitBuff("player", i)) ~= nil then
			local spellName, _, spellIcon = UnitBuff("player", i)
			if spellName == spellTable[table.maxn(spellTable)] then
				if table.maxn(spellTable) <= 1 then
					replayTexture[0]:SetTexture(spellIcon)
				else
					replayTexture[table.maxn(spellTable)-1]:SetTexture(spellIcon)
				end
				total = 0
				AuraDelayFrame:SetScript("OnUpdate", nil)
				break
			end
		else
			break
		end
	end
	if total > 1 then
		total = 0
		AuraDelayFrame:SetScript("OnUpdate", nil)
	end
end



ReplayFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ReplayFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ReplayFrame:RegisterEvent("PLAYER_LOGIN")
ReplayFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if replaySavedSettings == nil or replaySavedSettings[1] ~= nil then
			replaySavedSettings = {}
			replaySavedSettings[25] = "Arial Narrow"
			replaySavedSettings[11] = 1
			SettingsEnableButton:SetChecked(true)
			replaySavedSettings[12] = 0
			replaySavedSettings[13] = 1
			SettingsBackgroundButton:SetChecked(true)
			replaySavedSettings[14] = 1
			SettingsScalingSlider:SetValue(2)
			replaySavedSettings[15] = 1
			UIDropDownMenu_SetText(SettingsDirectionMenu, "Right")
			replaySavedSettings[16] = 1
			SettingsCropTexButton:SetChecked(true)
			replaySavedSettings[17] = 100
			SettingsPushSpeedSlider:SetValue(14)
			replaySavedSettings[18] = 30
			SettingsBaseSpeedSlider:SetValue(6)
			replaySavedSettings[19] = 30
			SettingsCastingSpeedSlider:SetValue(6)
			replaySavedSettings[20] = 4
			SettingsSpellNbSlider:SetValue(2)
			replaySavedSettings[21] = 1
			SettingsDisplayResistsButton:SetChecked(true)
			replaySavedSettings[22] = 1
			SettingsResistsOnFrameButton:SetChecked(true)
			replaySavedSettings[23] = 1
			SettingsResistsOnChatFrameButton:SetChecked(true)
			replaySavedSettings[24] = 1
			SettingsResistsOnPartyButton:SetChecked(true)
			replaySavedSettings[31] = 2
			SettingsRanksButton:SetChecked(true)
			SettingsRankOneButton:SetChecked(true)
			replaySavedSettings[32] = 2
			SettingsWhiteHitsButton:SetChecked(true)
			SettingsRangedWhiteHitsButton:SetChecked(true)
			replaySavedSettings[33] = 1
			SettingsDamagesButton:SetChecked(true)
			SettingsAllDamagesButton:SetChecked(true)
			replaySavedSettings[34] = 1
			SettingsHealsButton:SetChecked(true)
			SettingsAllHealsButton:SetChecked(true)
			replaySavedSettings[35] = 1
			SettingsManaButton:SetChecked(true)
			replaySavedSettings[36] = 1
			SettingsPetSpellsButton:SetChecked(true)
			displayToPartyTable = {}
		else
			if replaySavedSettings[11] == 1 then -- Enable (on/off)
				SettingsEnableButton:SetChecked(true)
			else
				ReplayFrame:Hide()
			end
			if replaySavedSettings[12] == 1 then -- Lock position (on/off)
				SettingsLockButton:SetChecked(true)
			end
			if replaySavedSettings[13] == 1 then -- Show background (on/off)
				SettingsBackgroundButton:SetChecked(true)
			else
				ReplayBackground:Hide()
			end
			ReplayFrame:SetScale(replaySavedSettings[14]) -- Frame scaling (0.8 - 1.5)
			SettingsScalingSlider:SetValue((replaySavedSettings[14] - 0.8) * 10)
			if replaySavedSettings[15] == 1 or replaySavedSettings[15] == nil then -- Scrolling direction (Right/Left)
				UIDropDownMenu_SetText(SettingsDirectionMenu, "Right")
			else
				UIDropDownMenu_SetText(SettingsDirectionMenu, "Left")
			end
			if replaySavedSettings[16] == 1 then -- Crop spell borders (on/off)
				SettingsCropTexButton:SetChecked(true)
			end
			if replaySavedSettings[17] == nil then -- Scrolling speed (30 - 150 / 0 - 100)
				replaySavedSettings[17] = 100
				SettingsPushSpeedSlider:SetValue(14)
				replaySavedSettings[18] = 30
				SettingsBaseSpeedSlider:SetValue(6)
				replaySavedSettings[19] = 30
				SettingsCastingSpeedSlider:SetValue(6)
			else
				SettingsPushSpeedSlider:SetValue((replaySavedSettings[17] - 30) / 5)
				SettingsBaseSpeedSlider:SetValue(replaySavedSettings[18] / 5)
				SettingsCastingSpeedSlider:SetValue(replaySavedSettings[19] / 5)
			end
			if replaySavedSettings[20] == nil then -- Number of spells to display (2 - 6)
				replaySavedSettings[20] = 4
				SettingsSpellNbSlider:SetValue(2)
			else
				SettingsSpellNbSlider:SetValue(replaySavedSettings[20] - 2)
			end
			if replaySavedSettings[21] == 1 then -- Display resists (on/off)
				SettingsDisplayResistsButton:SetChecked(true)
			else
				SettingsResistsOnFrameButton:Disable()
				SettingsResistsOnFrameFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsResistsOnChatFrameButton:Disable()
				SettingsResistsOnChatFrameFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsResistsOnPartyButton:Disable()
				SettingsResistsOnPartyFont:SetTextColor(0.5, 0.5, 0.5)
				DisplayToPartyAddButton:Disable()
				DisplayToPartyDelButton:Disable()
				for i,value in pairs(displayToPartyTable) do
					if _G["SettingsListContentButton"..i] ~= nil then
						_G["SettingsListContentFont"..i]:SetTextColor(0.5, 0.5, 0.5)
						_G["SettingsListContentButton"..i]:Disable()
					end
				end
			end
			if replaySavedSettings[22] == 1 then -- Display resists on the frame (on/off)
				SettingsResistsOnFrameButton:SetChecked(true)
			end
			if replaySavedSettings[23] == 1 then -- Display resists on the chat (on/off)
				SettingsResistsOnChatFrameButton:SetChecked(true)
			end
			if replaySavedSettings[24] == 1 then -- Display resists on /party (on/off)
				SettingsResistsOnPartyButton:SetChecked(true)
			else
				DisplayToPartyAddButton:Disable()
				DisplayToPartyDelButton:Disable()
				for i,value in pairs(displayToPartyTable) do
					if _G["SettingsListContentButton"..i] ~= nil then
						_G["SettingsListContentFont"..i]:SetTextColor(0.5, 0.5, 0.5)
						_G["SettingsListContentButton"..i]:Disable()
					end
				end
			end
			if replaySavedSettings[31] == 0 then -- Display spell ranks (none/all/rank one)
				SettingsAllRanksButton:SetChecked(true)
				SettingsAllRanksButton:Disable()
				SettingsAllRanksFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsRankOneButton:Disable()
				SettingsRankOneFont:SetTextColor(0.5, 0.5, 0.5)
			elseif replaySavedSettings[31] == 1 then
				SettingsRanksButton:SetChecked(true)
				SettingsAllRanksButton:SetChecked(true)
			else
				SettingsRanksButton:SetChecked(true)
				SettingsRankOneButton:SetChecked(true)
			end
			if replaySavedSettings[32] == 0 then -- Display white hits (none/melee+-ranged)
				SettingsMeleeWhiteHitsButton:Disable()
				SettingsMeleeWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsRangedWhiteHitsButton:Disable()
				SettingsRangedWhiteHitsFont:SetTextColor(0.5, 0.5, 0.5)
			elseif replaySavedSettings[32] == 1 then
				SettingsWhiteHitsButton:SetChecked(true)
				SettingsMeleeWhiteHitsButton:SetChecked(true)
			elseif replaySavedSettings[32] == 2 then
				SettingsWhiteHitsButton:SetChecked(true)
				SettingsRangedWhiteHitsButton:SetChecked(true)
			else
				SettingsWhiteHitsButton:SetChecked(true)
				SettingsMeleeWhiteHitsButton:SetChecked(true)
				SettingsRangedWhiteHitsButton:SetChecked(true)
			end
			if replaySavedSettings[33] == 0 then -- Display damages (none/all/crits)
				SettingsAllDamagesButton:SetChecked(true)
				SettingsAllDamagesButton:Disable()
				SettingsAllDamagesFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsCritDamagesButton:Disable()
				SettingsCritDamagesFont:SetTextColor(0.5, 0.5, 0.5)
			elseif replaySavedSettings[33] == 1 then
				SettingsDamagesButton:SetChecked(true)
				SettingsAllDamagesButton:SetChecked(true)
			else
				SettingsDamagesButton:SetChecked(true)
				SettingsCritDamagesButton:SetChecked(true)
			end
			if replaySavedSettings[34] == 0 then -- Display heals (none/all/crits)
				SettingsAllHealsButton:SetChecked(true)
				SettingsAllHealsButton:Disable()
				SettingsAllHealsFont:SetTextColor(0.5, 0.5, 0.5)
				SettingsCritHealsButton:Disable()
				SettingsCritHealsFont:SetTextColor(0.5, 0.5, 0.5)
			elseif replaySavedSettings[34] == 1 then
				SettingsHealsButton:SetChecked(true)
				SettingsAllHealsButton:SetChecked(true)
			else
				SettingsHealsButton:SetChecked(true)
				SettingsCritHealsButton:SetChecked(true)
			end
			if replaySavedSettings[35] == 1 then -- Display mana gains (on/off)
				SettingsManaButton:SetChecked(true)
			end
			if replaySavedSettings[36] == nil or replaySavedSettings[36] == 1 then -- Display pet spells (on/off)
				SettingsPetSpellsButton:SetChecked(true)
				replaySavedSettings[36] = 1
			end
		end
		if displayToPartyTable == nil then
			displayToPartyTable = {}
		else
			DisplayToPartyListing()
		end
		local raid_opts = {
			['name']='font',
			['parent']=ReplaySettingsGeneralPanel,
			['title']='Font Selection',
			['items']= newFonts,
			['defaultVal']=replaySavedSettings[25], 
			['changeFunc']=function(dropdown_frame, dropdown_val)
				replaySavedSettings[25] = dropdown_val -- Custom logic goes here, when you change your dropdown option.
			end
		}
		
		fontDD = createDropdown(raid_opts)
		-- Don't forget to set your dropdown's points, we don't do this in the creation method for simplicities sake.
		fontDD:SetPoint("TOPLEFT", ReplaySettingsGeneralPanel, 180, -240);
		systemFont = replaySavedSettings[25]
		ReplayFrame:UnregisterEvent("PLAYER_LOGIN")
	end




	if event == "UNIT_SPELLCAST_SUCCEEDED" and select(1,...) == "player" and GetSpellInfo(select(3,...)) ~= "Attack" and GetSpellInfo(select(3,...)) ~= "Throw" and GetSpellInfo(select(3,...)) ~= "Shoot" and GetSpellInfo(select(3,...)) ~= "Auto Shot" and GetSpellInfo(select(3,...)) ~= "Combat Swap (DND)" then
		local spellName = GetSpellInfo(select(3,...))
		local spellRank = GetSpellSubtext(select(3,...))
		if table.maxn(spellTable) == 0 then
			replayTexture[0] = ReplayFrame:CreateTexture(nil, "ARTWORK")
			replayTexture[0]:SetPoint("TOPLEFT", 0, 0)
			replayTexture[0]:Hide()
			replayTexture[0]:SetWidth(40)
			replayTexture[0]:SetHeight(40)
			if replaySavedSettings[16] == 1 then
				replayTexture[0]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
			end
			spellTable[1] = spellName
			timestampTable[1] = GetTime()
		elseif spellName ~= spellTable[table.maxn(spellTable)] or spellName == spellTable[table.maxn(spellTable)] and GetTime() - timestampTable[table.maxn(timestampTable)] > 0.5 then
			local i = table.maxn(spellTable)
			replayTexture[i] = ReplayFrame:CreateTexture(nil)
			if replaySavedSettings[15] == 1 then
				if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) > 40 then
					replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
				else
					replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) - 40, 0)
				end
			else
				if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) < -40 then
					replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
				else
					replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) + 40, 0)
				end
			end
			replayTexture[i]:Hide()
			replayTexture[i]:SetWidth(40)
			replayTexture[i]:SetHeight(40)
			if replaySavedSettings[16] == 1 then
				replayTexture[i]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
			end
			spellTable[i+1] = spellName
			timestampTable[i+1] = GetTime()
		end
		if table.maxn(spellTable) > 0 and replayTexture[table.maxn(spellTable) - 1]:GetTexture() == nil then
			local i = table.maxn(spellTable) - 1
			spellID = select(3,...)
			if spellName == GetSpellInfo(42292) then -- PvP trinket
				if UnitFactionGroup("player") == "Alliance" then
					replayTexture[i]:SetTexture("Interface\\Icons\\INV_Jewelry_TrinketPVP_01")
				else
					replayTexture[i]:SetTexture("Interface\\Icons\\INV_Jewelry_TrinketPVP_02")
				end
			elseif spellID ~= nil and spellID ~= 836 and spellID ~= 7266 then -- Don't trigger on "LOGINEFFECT" or "Duel" buffs
				replayTexture[i]:SetTexture(select(3, GetSpellInfo(spellID)))
			elseif select(10, GetItemInfo(spellName)) ~= nil then
				replayTexture[i]:SetTexture(select(10, GetItemInfo(spellName)))
			elseif spellName == GetSpellInfo(770) or spellName == GetSpellInfo(16857) then -- Faerie fire
				replayTexture[i]:SetTexture("Interface\\Icons\\Spell_Nature_FaerieFire")
			elseif spellName == GetSpellInfo(33878) or spellName == GetSpellInfo(33876) then -- Mangle
				replayTexture[i]:SetTexture("Interface\\Icons\\Ability_Druid_Mangle2")
			elseif spellName == GetSpellInfo(437) then -- Mana potions
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Potion_137")
			elseif spellName == GetSpellInfo(439) then -- Healing potions
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Potion_131")
			elseif spellName == GetSpellInfo(44166) then -- Refreshment table food and drink
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Misc_Food_100")
			elseif spellName == GetSpellInfo(27089) then -- Drink
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Drink_07")
			elseif spellName == GetSpellInfo(18234) then -- Food
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Misc_Fork&Knife")
			elseif spellName == GetSpellInfo(10052) then -- Mage gems
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Misc_Gem_Stone_01")
			elseif spellName == GetSpellInfo(28170) then -- Spellstone
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Misc_Gem_Sapphire_01")
			elseif spellName == GetSpellInfo(16666) then -- Demonic rune
				replayTexture[i]:SetTexture("Interface\\Icons\\INV_Misc_Rune_04")
			else
				AuraDelayFrame:SetScript("OnUpdate", AuraDelay)
			end
		end
		local i = table.maxn(spellTable) - 1
		if spellRank ~= nil and strfind(spellRank, "(%d+)") and replayTexture[i]:GetTexture() ~= nil and replayTexture[i]:GetTexture() ~= select(3, GetSpellInfo(5940)) then
			local _, _, spellRankNumber = strfind(spellRank, "(%d+)")
			if (replaySavedSettings[31] == 2 and spellRankNumber == "1") or replaySavedSettings[31] == 1 then
				replayRank[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				replayRank[i]:SetPoint("CENTER", replayTexture[i], 0, 28)
				replayRank[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
				replayRank[i]:SetJustifyH("CENTER")
				replayRank[i]:SetText("|cff107be5R"..spellRankNumber)
				replayRank[i]:Hide()
			end
		end
	end



	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		-- arg12: spellID or misstype
		-- arg13: spellname
		local _, eventType, _, sourceGUID, spellCaster, _, _, _, destName, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23 = CombatLogGetCurrentEventInfo()
		spellID = arg12
		if sourceGUID == UnitGUID("pet") and replaySavedSettings[36] == 1 or eventType == "SPELL_AURA_APPLIED" and arg10 == "Seduction" and UnitChannelInfo("pet") and strfind(select(4, UnitChannelInfo("pet")), "Spell_Shadow_MindSteal") then -- pet spells
			if (eventType == "SPELL_DAMAGE" or eventType == "SPELL_MISSED") and select(2, UnitClass("player")) == "MAGE" or eventType == "SPELL_CAST_SUCCESS" and select(2, UnitClass("player")) ~= "MAGE" or eventType == "SPELL_AURA_APPLIED" and arg10 == "Seduction" and sourceGUID == "0x0000000000000000" then
				spellID = arg12
				local spellName = GetSpellInfo(spellID)
				local i = table.maxn(spellTable)
				if table.maxn(spellTable) == 0 then
					replayTexture[0] = ReplayFrame:CreateTexture(nil, "ARTWORK")
					replayTexture[0]:SetPoint("TOPLEFT", 0, 0)
					replayTexture[0]:Hide()
					replayTexture[0]:SetWidth(40)
					replayTexture[0]:SetHeight(40)
					if replaySavedSettings[16] == 1 then
						replayTexture[0]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
					end
					replayRank[0] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
					replayRank[0]:SetPoint("CENTER", replayTexture[0], 0, 28)
					replayRank[0]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
					replayRank[0]:SetJustifyH("CENTER")
					replayRank[0]:SetText("|cff2e8b57PET")
					if replaySavedSettings[15] == 1 and select(4, replayTexture[0]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[0]:GetPoint()) > 0 then
						replayRank[0]:Hide()
					end
					replayTexture[0]:SetTexture(select(3, GetSpellInfo(spellID)))
					spellTable[1] = spellName
					timestampTable[1] = GetTime()
				elseif spellName ~= spellTable[table.maxn(spellTable)] or spellName == spellTable[table.maxn(spellTable)] and GetTime() - timestampTable[table.maxn(timestampTable)] > 0.5 then
					replayTexture[i] = ReplayFrame:CreateTexture(nil)
					if replaySavedSettings[15] == 1 then
						if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) > 40 then
							replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
						else
							replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) - 40, 0)
						end
					else
						if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) < -40 then
							replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
						else
							replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) + 40, 0)
						end
					end
					replayTexture[i]:Hide()
					replayTexture[i]:SetWidth(40)
					replayTexture[i]:SetHeight(40)
					if replaySavedSettings[16] == 1 then
						replayTexture[i]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
					end
					replayRank[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
					replayRank[i]:SetPoint("CENTER", replayTexture[i], 0, 28)
					replayRank[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
					replayRank[i]:SetJustifyH("CENTER")
					replayRank[i]:SetText("|cff2e8b57PET")
					if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
						replayRank[i]:Hide()
					end
					replayTexture[i]:SetTexture(select(3, GetSpellInfo(spellID)))
					spellTable[i+1] = spellName
					timestampTable[i+1] = GetTime()
				end
				local i = table.maxn(spellTable) - 1
				if eventType == "SPELL_DAMAGE" and replaySavedSettings[33] ~= 0 then
					for i=table.maxn(spellTable),0,-1 do
						if arg13 == spellTable[i] and replayTexture[i-1] ~= nil and replayDamage[i-1] == nil and replayFont[i-1] == nil then
							replayDamage[i-1] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
							replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -25)
							replayDamage[i-1]:SetJustifyH("CENTER")
							if replaySavedSettings[15] == 1 and select(4, replayTexture[i-1]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i-1]:GetPoint()) > 0 then
								replayDamage[i-1]:Hide()
							end
							if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 and arg18 == 1 or tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) <= 2 and arg17 == 1 then
								replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -26)
								replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 12)
								replayDamage[i-1]:SetText("|cffffff00"..arg15)
							elseif replaySavedSettings[33] ~= 2 then
								replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
								replayDamage[i-1]:SetText("|cffffff00"..arg15)
							end
							break
						end
					end
				elseif eventType == "SPELL_MISSED" and arg15 ~= "ABSORB" then
					if replaySavedSettings[21] == 1 then
						for i=table.maxn(spellTable),0,-1 do
							if replayTexture[i-1] ~= nil and select(3, GetSpellInfo(spellID)) == replayTexture[i-1]:GetTexture() and replayDamage[i-1] == nil and replayFont[i-1] == nil then
								replayFailTexture[i-1] = ReplayFrame:CreateTexture(nil, "OVERLAY")
								replayFailTexture[i-1]:SetPoint("CENTER", replayTexture[i-1])
								replayFailTexture[i-1]:SetWidth(35)
								replayFailTexture[i-1]:SetHeight(35)
								replayFailTexture[i-1]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
								replayFont[i-1] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
								replayFont[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -26)
								replayFont[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 8)
								replayFont[i-1]:SetJustifyH("CENTER")
								replayFont[i-1]:SetText("|cffffa500"..arg15)
								if replaySavedSettings[15] == 1 and select(4, replayTexture[i-1]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i-1]:GetPoint()) > 0 then
									replayFailTexture[i-1]:Hide()
									replayFont[i-1]:Hide()
								end
								break
							end
						end
					end
					if replaySavedSettings[23] == 1 then
						DEFAULT_CHAT_FRAME:AddMessage("|cffffa500"..arg13.." failed ("..arg15..")")
					end
					if replaySavedSettings[24] == 1 and displayToPartyTable ~= nil then
						for i,value in pairs(displayToPartyTable) do
							if arg13 == value then
								SendChatMessage(arg13.." failed ("..arg15..")", "PARTY")
								return
							end
						end
					end
				end
			end
			if (eventType == "SPELL_DAMAGE" or eventType == "SPELL_MISSED") and select(2, UnitClass("player")) ~= "MAGE" then
				local spellName = GetSpellInfo(spellID)
				local i = table.maxn(spellTable)
				if table.maxn(spellTable) == 0 then
					replayTexture[0] = ReplayFrame:CreateTexture(nil, "ARTWORK")
					replayTexture[0]:SetPoint("TOPLEFT", 0, 0)
					replayTexture[0]:Hide()
					replayTexture[0]:SetWidth(40)
					replayTexture[0]:SetHeight(40)
					if replaySavedSettings[16] == 1 then
						replayTexture[0]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
					end
					replayRank[0] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
					replayRank[0]:SetPoint("CENTER", replayTexture[0], 0, 28)
					replayRank[0]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
					replayRank[0]:SetJustifyH("CENTER")
					replayRank[0]:SetText("|cff2e8b57PET")
					if replaySavedSettings[15] == 1 and select(4, replayTexture[0]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[0]:GetPoint()) > 0 then
						replayRank[0]:Hide()
					end
					replayTexture[0]:SetTexture(select(3, GetSpellInfo(spellID)))
					spellTable[1] = spellName
					timestampTable[1] = GetTime()
				else
					for i=table.maxn(spellTable),0,-1 do
						if replayTexture[i-1] ~= nil and select(3, GetSpellInfo(spellID)) == replayTexture[i-1]:GetTexture() and (GetTime() - timestampTable[i] < 1 or strfind(arg13, "Effect") and GetTime() - timestampTable[i] < 1.5) then
							break
						elseif replayTexture[i-1] == nil then
							local i = table.maxn(spellTable)
							replayTexture[i] = ReplayFrame:CreateTexture(nil)
							if replaySavedSettings[15] == 1 then
								if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) > 40 then
									replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
								else
									replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) - 40, 0)
								end
							else
								if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) < -40 then
									replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
								else
									replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) + 40, 0)
								end
							end
							replayTexture[i]:Hide()
							replayTexture[i]:SetWidth(40)
							replayTexture[i]:SetHeight(40)
							if replaySavedSettings[16] == 1 then
								replayTexture[i]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
							end
							replayRank[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
							replayRank[i]:SetPoint("CENTER", replayTexture[i], 0, 28)
							replayRank[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
							replayRank[i]:SetJustifyH("CENTER")
							replayRank[i]:SetText("|cff2e8b57PET")
							if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
								replayRank[i]:Hide()
							end
							replayTexture[i]:SetTexture(select(3, GetSpellInfo(spellID)))
							spellTable[i+1] = spellName
							timestampTable[i+1] = GetTime()
							break
						end
					end
				end
				if eventType == "SPELL_DAMAGE" and replaySavedSettings[33] ~= 0 then
					for i=table.maxn(spellTable),0,-1 do
						if arg13 == spellTable[i] and replayTexture[i-1] ~= nil and replayDamage[i-1] == nil and replayFont[i-1] == nil then
							replayDamage[i-1] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
							replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -25)
							replayDamage[i-1]:SetJustifyH("CENTER")
							if replaySavedSettings[15] == 1 and select(4, replayTexture[i-1]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i-1]:GetPoint()) > 0 then
								replayDamage[i-1]:Hide()
							end
							if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 and arg18 == 1 or tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) <= 2 and arg17 == 1 then
								replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -26)
								replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 12)
								replayDamage[i-1]:SetText("|cffffff00"..arg12)
							elseif replaySavedSettings[33] ~= 2 then
								replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
								replayDamage[i-1]:SetText("|cffffff00"..arg12)
							end
							break
						end
					end
				elseif eventType == "SPELL_MISSED" and arg15 ~= "ABSORB" then
					if replaySavedSettings[21] == 1 then
						for i=table.maxn(spellTable),0,-1 do
							if replayTexture[i-1] ~= nil and select(3, GetSpellInfo(spellID)) == replayTexture[i-1]:GetTexture() and replayDamage[i-1] == nil and replayFont[i-1] == nil then
								replayFailTexture[i-1] = ReplayFrame:CreateTexture(nil, "OVERLAY")
								replayFailTexture[i-1]:SetPoint("CENTER", replayTexture[i-1])
								replayFailTexture[i-1]:SetWidth(35)
								replayFailTexture[i-1]:SetHeight(35)
								replayFailTexture[i-1]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
								replayFont[i-1] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
								replayFont[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -26)
								replayFont[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 8)
								replayFont[i-1]:SetJustifyH("CENTER")
								replayFont[i-1]:SetText("|cffffa500"..arg15)
								if replaySavedSettings[15] == 1 and select(4, replayTexture[i-1]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i-1]:GetPoint()) > 0 then
									replayFailTexture[i-1]:Hide()
									replayFont[i-1]:Hide()
								end
								break
							end
						end
					end
					if replaySavedSettings[23] == 1 then
						DEFAULT_CHAT_FRAME:AddMessage("|cffffa500"..arg13.." failed ("..arg15..")")
					end
					if replaySavedSettings[24] == 1 and displayToPartyTable ~= nil and GetNumGroupMembers() > 0 and GetNumGroupMembers() <= 5 then
						for i,value in pairs(displayToPartyTable) do
							if arg13 == value then
								SendChatMessage(arg13.." failed ("..arg15..")", "PARTY")
								return
							end
						end
					end
				end
			end
		end
		if spellCaster == UnitName("player") and (((eventType == "RANGE_DAMAGE" or eventType == "RANGE_MISSED") and (replaySavedSettings[32] == 2 or replaySavedSettings[32] == 3)) or ((eventType == "SWING_DAMAGE" or eventType == "SWING_MISSED") and (replaySavedSettings[32] == 1 or replaySavedSettings[32] == 3))) then -- ranged/melee autos
			local spellName = ""
			if eventType == "RANGE_DAMAGE" or eventType == "RANGE_MISSED" then
				spellName = GetItemInfo(GetInventoryItemLink("player", 18))
			else
				spellName = GetItemInfo(GetInventoryItemLink("player", 16))
			end
			local i = table.maxn(spellTable)
			if table.maxn(spellTable) == 0 then
				replayTexture[0] = ReplayFrame:CreateTexture(nil, "ARTWORK")
				replayTexture[0]:SetPoint("TOPLEFT", 0, 0)
				replayTexture[0]:SetWidth(40)
				replayTexture[0]:SetHeight(40)
				if replaySavedSettings[16] == 1 then
					replayTexture[0]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
				end
				spellTable[1] = spellName
				timestampTable[1] = GetTime()
			elseif spellName ~= spellTable[table.maxn(spellTable)] or spellName == spellTable[table.maxn(spellTable)] then
				replayTexture[i] = ReplayFrame:CreateTexture(nil)
				if replaySavedSettings[15] == 1 then
					if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) > 40 then
						replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
					else
						replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) - 40, 0)
					end
				else
					if replayTexture[i-1] == nil or select(4, replayTexture[i-1]:GetPoint()) < -40 then
						replayTexture[i]:SetPoint("TOPLEFT", 0, 0)
					else
						replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i-1]:GetPoint()) + 40, 0)
					end
				end
				replayTexture[i]:SetWidth(40)
				replayTexture[i]:SetHeight(40)
				if replaySavedSettings[16] == 1 then
					replayTexture[i]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
				end
				if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
					replayTexture[i]:Hide()
				end
				spellTable[i+1] = spellName
				timestampTable[i+1] = GetTime()
			end
			if replayTexture[i] ~= nil then
				if eventType == "SWING_DAMAGE" or eventType == "SWING_MISSED" then
					if select(2, UnitClass("player")) == "DRUID" and GetShapeshiftForm() == 3 then
						replayTexture[i]:SetTexture("Interface\\Icons\\Ability_Druid_CatFormAttack")
					elseif select(2, UnitClass("player")) == "DRUID" and GetShapeshiftForm() == 1 then
						replayTexture[i]:SetTexture("Interface\\Icons\\Ability_Druid_Swipe")
					else
						replayTexture[i]:SetTexture(select(10, GetItemInfo(GetInventoryItemLink("player", 16))))
					end
				else
					replayTexture[i]:SetTexture(select(10, GetItemInfo(GetInventoryItemLink("player", 18))))
				end
			end
			if (eventType == "RANGE_MISSED" or eventType == "SWING_MISSED") and replaySavedSettings[21] == 1 and replaySavedSettings[22] == 1 and replayTexture[i] ~= nil then -- damages/misses on ranged/melee white hits
				replayFailTexture[i] = ReplayFrame:CreateTexture(nil, "OVERLAY")
				replayFailTexture[i]:SetPoint("CENTER", replayTexture[i])
				replayFailTexture[i]:SetWidth(35)
				replayFailTexture[i]:SetHeight(35)
				replayFailTexture[i]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
				replayFont[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				replayFont[i]:SetPoint("CENTER", replayTexture[i], 0, -26)
				replayFont[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 8)
				replayFont[i]:SetJustifyH("CENTER")
				if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
					replayFailTexture[i]:Hide()
					replayFont[i]:Hide()
				end
				if eventType == "RANGE_MISSED" then
					replayFont[i]:SetText("|cffffa500"..arg15)
				else
					replayFont[i]:SetText("|cffffa500"..arg15)
				end
			elseif eventType == "SWING_DAMAGE" and arg15 ~= nil and replayDamage[i] == nil and replayTexture[i] ~= nil and replaySavedSettings[33] ~= 0 then
				replayDamage[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				replayDamage[i]:SetPoint("CENTER", replayTexture[i], 0, -25)
				replayDamage[i]:SetJustifyH("CENTER")
				if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
					replayDamage[i]:Hide()
				end
				if tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) > 2 and arg15 == 1 or tonumber(strsub(select(1,GetBuildInfo()), 1, 1)) <= 2 and arg14 == 1 then
					replayDamage[i]:SetPoint("CENTER", replayTexture[i], 0, -26)
					replayDamage[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 12)
					replayDamage[i]:SetText("|cffffffff"..arg15)
				elseif replaySavedSettings[33] ~= 2 then
					replayDamage[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
					replayDamage[i]:SetText("|cffffffff"..arg15)
				end
			elseif eventType == "RANGE_DAMAGE" and arg15 ~= nil and replayDamage[i] == nil and replayTexture[i] ~= nil and replaySavedSettings[33] ~= 0 then
				replayDamage[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				replayDamage[i]:SetPoint("CENTER", replayTexture[i], 0, -25)
				replayDamage[i]:SetJustifyH("CENTER")
				if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
					replayDamage[i]:Hide()
				end
				_critical = arg21
				if _critical == true then
					replayDamage[i]:SetPoint("CENTER", replayTexture[i], 0, -26)
					replayDamage[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 12)
					replayDamage[i]:SetText("|cffffffff"..arg15)
				elseif replaySavedSettings[33] ~= 2 then
					replayDamage[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
					replayDamage[i]:SetText("|cffffffff"..arg15)
				end
			end
		end
		if spellCaster == UnitName("player") and (eventType == "SPELL_DAMAGE" and replaySavedSettings[33] ~= 0 or eventType == "SPELL_HEAL" and replaySavedSettings[34] ~= 0) and spellID ~= 16666 and spellID ~= 33778 then -- damages/heals on spells
			_spellID = arg12
			_spellName = arg13
			_spellAmount = arg15
			_spellCritical = arg21
			for i=table.maxn(spellTable),0,-1 do
				if _spellName == spellTable[i] and replayTexture[i-1] ~= nil and replayDamage[i-1] == nil and replayFont[i-1] == nil and (_spellName ~= spellTable[i-1] or replayTexture[i-2] == nil or replayTexture[i-2] ~= nil and (replayDamage[i-2] ~= nil or replayFont[i-2] ~= nil)) then
					replayDamage[i-1] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
					replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -25)
					replayDamage[i-1]:SetJustifyH("CENTER")
					if replaySavedSettings[15] == 1 and select(4, replayTexture[i-1]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i-1]:GetPoint()) > 0 then
						replayDamage[i-1]:Hide()
					end
					if eventType == "SPELL_DAMAGE" then
						if _spellCritical == true then
							replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -26)
							replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 12)
							replayDamage[i-1]:SetText("|cffffff00".._spellAmount)
						elseif replaySavedSettings[33] ~= 2 then
							replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 10)
							replayDamage[i-1]:SetText("|cffffff00".._spellAmount)
						end
					else
						_spellCritical = arg18
						if _spellCritical == true then
							replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -26)
							replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 12)
							replayDamage[i-1]:SetText("|cff00b200+".._spellAmount)
						elseif replaySavedSettings[34] ~= 2 then
							replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 10)
							replayDamage[i-1]:SetText("|cff00b200+".._spellAmount)
						end
					end
					break
				end
			end
		end
		if eventType == "SPELL_ENERGIZE" and spellCaster == UnitName("player") and arg13 == 0 and replaySavedSettings[35] == 1 then -- mana gains
			local i = table.maxn(spellTable)
			if arg13 == spellTable[i] and replayDamage[i-1] == nil and replayTexture[i-1] ~= nil then
				replayDamage[i-1] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				replayDamage[i-1]:SetPoint("CENTER", replayTexture[i-1], 0, -25)
				replayDamage[i-1]:SetJustifyH("CENTER")
				replayDamage[i-1]:SetFont(LibSharedMedia:Fetch("font", systemFont), 9)
				replayDamage[i-1]:SetText("|cff0080ff+"..arg12)
				if replaySavedSettings[15] == 1 and select(4, replayTexture[i-1]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i-1]:GetPoint()) > 0 then
					replayDamage[i-1]:Hide()
				end
			end
		end
		if arg15 == "REFLECT" and destName == UnitName("player") then -- Shield Reflect
			for i=table.maxn(spellTable),0,-1 do
				if replayTexture[i] ~= nil and replayUpperTexture[i] == nil and select(3, GetSpellInfo(23920)) == replayTexture[i]:GetTexture() then
					replayUpperTexture[i] = ReplayFrame:CreateTexture(nil)
					replayUpperTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperTexture[i]:SetWidth(25)
					replayUpperTexture[i]:SetHeight(25)
					replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(arg12)))
					if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
						replayUpperTexture[i]:Hide()
					end
					break
				end
			end
		end
		if arg15 == "RESIST" and destName == UnitName("player") then -- Cloak of Shadows first resist
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
								replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(arg12)))
								if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
									replayUpperTexture[i]:Hide()
								end
								break
							end
						end
					end
				end
			end
		end
		if arg13 ~= nil and strfind(tostring(arg13), "Poison") then -- Poisons applied by Shiv
			i = table.maxn(spellTable) - 1
			if replayTexture[i] ~= nil and replayUpperTexture[i] == nil and select(3, GetSpellInfo(5940)) == replayTexture[i]:GetTexture() and GetTime() - timestampTable[table.maxn(timestampTable)] < 0.03 then
				if eventType == "SPELL_MISSED" and arg12 ~= "ABSORB" then
					replayUpperTexture[i] = ReplayFrame:CreateTexture(nil)
					replayUpperTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperTexture[i]:SetWidth(25)
					replayUpperTexture[i]:SetHeight(25)
					replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(arg12)))
					replayUpperFailTexture[i] = ReplayFrame:CreateTexture(nil, "OVERLAY")
					replayUpperFailTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperFailTexture[i]:SetWidth(22)
					replayUpperFailTexture[i]:SetHeight(22)
					replayUpperFailTexture[i]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
					if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
						replayUpperTexture[i]:Hide()
						replayUpperFailTexture[i]:Hide()
					end
				else
					replayUpperTexture[i] = ReplayFrame:CreateTexture(nil)
					replayUpperTexture[i]:SetPoint("CENTER", replayTexture[i], 0, 35)
					replayUpperTexture[i]:SetWidth(25)
					replayUpperTexture[i]:SetHeight(25)
					replayUpperTexture[i]:SetTexture(select(3, GetSpellInfo(arg12)))
					if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
						replayUpperTexture[i]:Hide()
					end
				end
			end
		elseif replaySavedSettings[21] == 1 and eventType == "SPELL_MISSED" and spellCaster == UnitName("player") and arg15 ~= "ABSORB" then -- Other missed spells
			if replaySavedSettings[22] == 1 and (spellID ~= 64382 or arg15 ~= "IMMUNE" and spellID == 64382) then -- not Shattering Throw immunes (WotLK)
				for i=table.maxn(spellTable),0,-1 do
					if replayTexture[i] ~= nil and replayFont[i] == nil and select(3, GetSpellInfo(spellID)) == replayTexture[i]:GetTexture() and (GetTime() - timestampTable[i+1] < 1.5 or strfind(tostring(arg13), "Effect") and GetTime() - timestampTable[i+1] < 1.5) then
						replayFailTexture[i] = ReplayFrame:CreateTexture(nil, "OVERLAY")
						replayFailTexture[i]:SetPoint("CENTER", replayTexture[i])
						replayFailTexture[i]:SetWidth(35)
						replayFailTexture[i]:SetHeight(35)
						replayFailTexture[i]:SetTexture("Interface\\AddOns\\SpellReplay\\RedCross")
						replayFont[i] = ReplayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
						replayFont[i]:SetPoint("CENTER", replayTexture[i], 0, -26)
						replayFont[i]:SetFont(LibSharedMedia:Fetch("font", systemFont), 8)
						replayFont[i]:SetJustifyH("CENTER")
						replayFont[i]:SetText("|cffffa500"..arg15)
						if replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > 0 then
							replayFailTexture[i]:Hide()
							replayFont[i]:Hide()
						end
						break
					end
				end
			end
			if replaySavedSettings[23] == 1 then
				DEFAULT_CHAT_FRAME:AddMessage("|cffffa500"..arg13.." failed ("..arg15..")") -- chat frame message for failed spells
			end
			if replaySavedSettings[24] == 1 and displayToPartyTable ~= nil and GetNumGroupMembers() > 0 and GetNumGroupMembers() <= 5 then
				for i,value in pairs(displayToPartyTable) do
					if arg13 == value then
						SendChatMessage(arg13.." failed ("..arg15..")", "PARTY") -- /party message for all the failed spells on displayToPartyTable
						return
					end
				end
			end
		end
	end
end)



local ReplayUpdateFrame = CreateFrame("Frame")
ReplayUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
	if spellTable ~= nil and #spellTable > 0 and replayTexture[table.maxn(spellTable)-1] ~= nil then
		if replaySavedSettings[15] == 1 then
			endPos = replaySavedSettings[20] * 40
			if select(4, replayTexture[table.maxn(spellTable)-1]:GetPoint()) < 0 then
				movSpeed = replaySavedSettings[17]
			elseif UnitChannelInfo("player") or UnitCastingInfo("player") then
				movSpeed = replaySavedSettings[19]
			else
				movSpeed = replaySavedSettings[18]
			end
		else
			endPos = -replaySavedSettings[20] * 40
			if select(4, replayTexture[table.maxn(spellTable)-1]:GetPoint()) > 0 then
				movSpeed = -replaySavedSettings[17]
			elseif UnitChannelInfo("player") or UnitCastingInfo("player") then
				movSpeed = -replaySavedSettings[19]
			else
				movSpeed = -replaySavedSettings[18]
			end
		end
		for i=table.maxn(spellTable)-1,0,-1 do
			if replayTexture[i] == nil then
				break
			else
				if not replayTexture[i]:IsShown() and (replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) > 0 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) < 0) then
					replayTexture[i]:Show()
					if replayRank[i] ~= nil then
						replayRank[i]:Show()
					end
					if replayDamage[i] ~= nil then
						replayDamage[i]:Show()
					end
					if replayFont[i] ~= nil then
						replayFont[i]:Show()
					end
					if replayFailTexture[i] ~= nil then
						replayFailTexture[i]:Show()
					end
					if replayUpperTexture[i] ~= nil then
						replayUpperTexture[i]:Show()
					end
					if replayUpperFailTexture[i] ~= nil then
						replayUpperFailTexture[i]:Show()
					end
				elseif replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < endPos - 20 or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > endPos + 20 then
					replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i]:GetPoint()) + movSpeed * elapsed, 0)
				elseif replaySavedSettings[15] == 1 and select(4, replayTexture[i]:GetPoint()) < endPos or replaySavedSettings[15] == 2 and select(4, replayTexture[i]:GetPoint()) > endPos then
					replayTexture[i]:SetPoint("TOPLEFT", select(4, replayTexture[i]:GetPoint()) + movSpeed * elapsed, 0)
					replayTexture[i]:SetAlpha(abs(endPos - select(4, replayTexture[i]:GetPoint())) / 20)
					if replayRank[i] ~= nil then
						replayRank[i]:SetAlpha(abs(endPos - select(4, replayTexture[i]:GetPoint())) / 20)
					end
					if replayDamage[i] ~= nil then
						replayDamage[i]:SetAlpha(abs(endPos - select(4, replayTexture[i]:GetPoint())) / 20)
					end
					if replayFont[i] ~= nil then
						replayFont[i]:SetAlpha(abs(endPos - select(4, replayTexture[i]:GetPoint())) / 20)
					end
					if replayFailTexture[i] ~= nil then
						replayFailTexture[i]:SetAlpha(abs(endPos - select(4, replayTexture[i]:GetPoint())) / 20)
					end
					if replayUpperTexture[i] ~= nil then
						replayUpperTexture[i]:SetAlpha(abs(endPos - select(4, replayTexture[i]:GetPoint())) / 20)
					end
					if replayUpperFailTexture[i] ~= nil then
						replayUpperFailTexture[i]:SetAlpha(abs(endPos - select(4, replayTexture[i]:GetPoint())) / 20)
					end
				elseif replayTexture[i] ~= nil then
					replayTexture[i]:Hide()
					replayTexture[i] = nil
					if replayRank[i] ~= nil then
						replayRank[i]:Hide()
						replayRank[i] = nil
					end
					if replayDamage[i] ~= nil then
						replayDamage[i]:Hide()
						replayDamage[i] = nil
					end
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
			end
		end
	end
end)
