

    FFXIV_UI_Anchors = FFXIV_UI_Anchors or {}
    FFXIV_UI_DB = FFXIV_UI_DB or {}

    local anchorConfigs = {
        { key = "ExpBar",        label = "Experience Bar",     w = 800, h = 25,  scale = 1.0, pos = {"BOTTOM", 0, 30} },
        { key = "JobGauge",      label = "Job Gauge",          w = 150, h = 100,  scale = 1.0, pos = {"CENTER", 400, -150} },
        { key = "PlayerCast",    label = "Player Castbar",     w = 360, h = 100, scale = 1.0, pos = {"CENTER", 0, -170} },
        { key = "PlayerHP",      label = "Player Health",      w = 240, h = 86,  scale = 1.0, pos = {"BOTTOM", -120, 55} },
        { key = "PlayerPower",   label = "Player Power",       w = 240, h = 86,  scale = 1.0, pos = {"BOTTOM", 120, 55} },
        { key = "PlayerPowerSec",label = "Secondary Power",    w = 240, h = 86,  scale = 1.0, pos = {"BOTTOM", 360, 55} },
        { key = "TargetAuras",   label = "Target Buffs",       w = 850, h = 45,  scale = 1.0, pos = {"TOP", 90, -70} },
        { key = "TargetDebuffs", label = "Target Debuffs",     w = 850, h = 45,  scale = 1.0, pos = {"TOP", 90, -115} },
        { key = "TargetCast",    label = "Target Castbar",     w = 350, h = 30,  scale = 1.0, pos = {"TOP", 180, 0} },
        { key = "TargetHP",      label = "Target Health",      w = 670, h = 50,  scale = 1.0, pos = {"TOP", 0, -25} },
        { key = "TargetOfTarget",label = "Target of Target",   w = 340, h = 50,  scale = 1.0, pos = {"TOP", 505, -25} },
        { key = "FocusTarget",   label = "Focus Target",       w = 340, h = 50,  scale = 1.0, pos = {"TOP", -505, -25} },
    }

    local visualBoxes = {}
    anchorsUnlocked = false  


    local soundOn  = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Open_Window.mp3"
    local soundOff = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Close_Window.mp3"



    function FFXIV_UI_SetAnchorsUnlocked(unlocked)
        anchorsUnlocked = unlocked
        for _, box in ipairs(visualBoxes) do
            box:SetShown(unlocked)
            box:EnableMouse(unlocked)
            box:EnableMouseWheel(unlocked)
        end
    end

    local function ClampToScreen(anchor)
        local scale = anchor:GetScale()
        local width, height = anchor:GetWidth() * scale, anchor:GetHeight() * scale
        local uiWidth, uiHeight = UIParent:GetWidth(), UIParent:GetHeight()
        local point, _, relativePoint, x, y = anchor:GetPoint()
        local halfW, halfH = width / 2, height / 2
        x = math.max(-uiWidth/2 + halfW, math.min(uiWidth/2 - halfW, x))
        y = math.max(-uiHeight/2 + halfH, math.min(uiHeight/2 - halfH, y))
        anchor:ClearAllPoints()
        anchor:SetPoint(point, UIParent, relativePoint, x, y)
    end

    local function SaveAnchorState(anchor, key)
        local point, _, relativePoint, x, y = anchor:GetPoint()
        FFXIV_UI_DB[key] = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
            scale = anchor:GetScale()
        }
    end



    local function CreateAnchor(data)
        local anchor = CreateFrame("Frame", "FFXIV_Anchor_" .. data.key, UIParent)
        anchor:SetSize(data.w, data.h)
        anchor:SetMovable(true)
        anchor:SetPoint(data.pos[1], UIParent, data.pos[1], data.pos[2], data.pos[3])
    
        anchor.key = data.key
        anchor.defaultData = data

        local visual = CreateFrame("Frame", nil, anchor, "BackdropTemplate")
        visual:SetPoint("CENTER", anchor, "CENTER")
        visual:SetFrameStrata("TOOLTIP")
        visual:SetBackdrop({ 
            bgFile = "Interface\\Buttons\\WHITE8X8", 
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
            edgeSize = 14 
        })
        visual:SetBackdropColor(0.2, 0.2, 0.2, 0.25)
        visual:SetBackdropBorderColor(1, 1, 1, 1)

  
        visual.nameText = visual:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        visual.nameText:SetPoint("TOPLEFT", visual, 4, -4)
        visual.nameText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-65-Medium.otf", 14, "OUTLINE")
        visual.nameText:SetTextColor(1,1,1)
        visual.nameText:SetText(data.label)


        visual.percentText = visual:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        visual.percentText:SetPoint("TOPRIGHT", visual, -4, -4)
        visual.percentText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-65-Medium.otf", 14, "OUTLINE")
        visual.percentText:SetTextColor(1,1,1)
        visual.percentText:SetText("100%")


        local btnInc = CreateFrame("Button", nil, visual)
        btnInc:SetSize(25, 25)
        btnInc:SetPoint("CENTER", visual, "CENTER", -14, 0)
        btnInc:SetNormalTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Menu\\Plus.tga")
        btnInc:SetPushedTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Menu\\Plus.tga")
        btnInc:SetHighlightTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Menu\\Plus.tga", "ADD")

        local btnDec = CreateFrame("Button", nil, visual)
        btnDec:SetSize(25, 25)
        btnDec:SetPoint("CENTER", visual, "CENTER", 14, 0)
        btnDec:SetNormalTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Menu\\Minus.tga")
        btnDec:SetPushedTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Menu\\Minus.tga")
        btnDec:SetHighlightTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Menu\\Minus.tga", "ADD")

        visual:RegisterForDrag("LeftButton")
        visual:Hide()
        table.insert(visualBoxes, visual)

        local function RefreshVisualLayout()
            local s = anchor:GetScale()
            visual:SetSize(data.w * s, data.h * s)
            visual:SetScale(1 / s)
        end

        local function UpdateScale(newScale)
            local oldScale = anchor:GetScale()
            local point, relativeTo, relativePoint, x, y = anchor:GetPoint()
            local ratio = oldScale / newScale
            anchor:SetScale(newScale)
            anchor:ClearAllPoints()
            anchor:SetPoint(point, relativeTo, relativePoint, x * ratio, y * ratio)
            RefreshVisualLayout()
            visual.percentText:SetText(math.floor(newScale * 100 + 0.5) .. "%")
            SaveAnchorState(anchor, data.key)
        end

        btnInc:SetScript("OnClick", function() UpdateScale(math.min(2.5, anchor:GetScale() + 0.05)) end)
        btnDec:SetScript("OnClick", function() UpdateScale(math.max(0.4, anchor:GetScale() - 0.05)) end)

        visual:SetScript("OnDragStart", function() if anchorsUnlocked then anchor:StartMoving() end end)
        visual:SetScript("OnDragStop", function() anchor:StopMovingOrSizing(); ClampToScreen(anchor); SaveAnchorState(anchor, data.key) end)
        visual:SetScript("OnMouseWheel", function(_, delta) if anchorsUnlocked then UpdateScale(math.max(0.4, math.min(2.5, anchor:GetScale() + (delta * 0.05)))) end end)


        visual:SetScript("OnEnter", function() visual:SetBackdropColor(1, 1, 0, 0.3) end) 
        visual:SetScript("OnLeave", function() visual:SetBackdropColor(0.2, 0.2, 0.2, 0.25) end)

        anchor.RefreshVisual = RefreshVisualLayout
        return anchor
    end



    for _, data in ipairs(anchorConfigs) do
        FFXIV_UI_Anchors[data.key] = CreateAnchor(data)
    end

    local loader = CreateFrame("Frame")
    loader:RegisterEvent("ADDON_LOADED")
    loader:SetScript("OnUpdate", function(self)
        if EditModeManager then
            SetupEditMode()
            self:SetScript("OnUpdate", nil)
        end
    end)

    loader:HookScript("OnEvent", function(self, event, addonName)
        if addonName == "FFXIV_UI" then
            for key, anchor in pairs(FFXIV_UI_Anchors) do
                local saved = FFXIV_UI_DB[key]
                if saved and saved.point then
                    anchor:SetScale(saved.scale or 1.0)
                    anchor:ClearAllPoints()
                    anchor:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
                end
                anchor.RefreshVisual()
            end
        end
    end)





    SLASH_FFXIVUI1 = "/ffxivtoggle"
    SlashCmdList["FFXIVUI"] = function() 
        anchorsUnlocked = not anchorsUnlocked
        FFXIV_UI_SetAnchorsUnlocked(anchorsUnlocked) 
        if anchorsUnlocked then
            PlaySoundFile(soundOn, "Master")
        else
            PlaySoundFile(soundOff, "Master")
        end
    end

    SLASH_FFXIVUIRESET1 = "/ffxivreset"
    SlashCmdList["FFXIVUIRESET"] = function()
        for key, anchor in pairs(FFXIV_UI_Anchors) do
            local d = anchor.defaultData
            anchor:SetScale(d.scale)
            anchor:ClearAllPoints()
            anchor:SetPoint(d.pos[1], UIParent, d.pos[1], d.pos[2], d.pos[3])
            anchor.RefreshVisual()
            SaveAnchorState(anchor, key)
        end
    end

 
   --Options--
local options = CreateFrame("Frame")
options.name = "FFXIV UI"

local title = options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("FFXIV UI")

local soundOn  = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Open_Window.mp3"
local soundOff = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Close_Window.mp3"

local QuestAcceptSoundNames = {
    "None",
    "A Realm Reborn",
    "Heavensward",
    "Stormblood",
    "Shadowbringers",
    "Endwalker",
    "Dawntrail",
    "Island Sanctuary",
    "Tribal"
}

local QuestCompleteSoundNames = {
    "None",
    "A Realm Reborn",
    "Heavensward",
    "Stormblood",
    "Shadowbringers",
    "Endwalker",
    "Dawntrail",
    "Island Sanctuary"
}


local toggleAnchors = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
toggleAnchors:SetSize(160, 22)
toggleAnchors:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)

local function UpdateToggleButtonText()
    toggleAnchors:SetText(anchorsUnlocked and "Hide Anchors" or "Show Anchors")
end

UpdateToggleButtonText()

toggleAnchors:SetScript("OnClick", function()
    anchorsUnlocked = not anchorsUnlocked
    FFXIV_UI_SetAnchorsUnlocked(anchorsUnlocked)

    if anchorsUnlocked then
        PlaySoundFile(soundOn, "Master")
    else
        PlaySoundFile(soundOff, "Master")
    end

    UpdateToggleButtonText()
end)


local reset = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
reset:SetSize(160, 22)
reset:SetPoint("TOPLEFT", toggleAnchors, "BOTTOMLEFT", 0, -12)
reset:SetText("Reset All Anchors")
reset:SetScript("OnClick", function()
    SlashCmdList["FFXIVUIRESET"]()
end)


local cb = CreateFrame("CheckButton", "FFXIV_UI_SoundCheck", options, "InterfaceOptionsCheckButtonTemplate")
cb:SetPoint("TOPLEFT", reset, "BOTTOMLEFT", 0, -16)
cb.Text:SetText("Enable Sound Effects")
cb.Text:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-65-Medium.otf", 12)

cb:SetScript("OnShow", function(self)
    self:SetChecked(FFXIV_UI_DB.sfxEnabled)
end)

cb:SetScript("OnClick", function(self)
    FFXIV_UI_DB.sfxEnabled = self:GetChecked()
end)


FFXIV_UI_DB.errorSfxEnabled = FFXIV_UI_DB.errorSfxEnabled ~= false
local errorCB = CreateFrame("CheckButton", "FFXIV_UI_ErrorSoundCheck", options, "InterfaceOptionsCheckButtonTemplate")
errorCB:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 0, -8)
errorCB.Text:SetText("Enable Error Sound")
errorCB.Text:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-65-Medium.otf", 12)

errorCB:SetScript("OnShow", function(self)
    self:SetChecked(FFXIV_UI_DB.errorSfxEnabled)
end)

errorCB:SetScript("OnClick", function(self)
    FFXIV_UI_DB.errorSfxEnabled = self:GetChecked()
end)


-- Quest Accept Dropdown

local acceptLabel = options:CreateFontString(nil, "ARTWORK", "GameFontNormal")
acceptLabel:SetPoint("TOPLEFT", errorCB, "BOTTOMLEFT", 0, -20)
acceptLabel:SetText("Quest Accept Sound")

local acceptDropdown = CreateFrame("Frame", "FFXIV_UI_QuestAcceptDropdown", options, "UIDropDownMenuTemplate")
acceptDropdown:SetPoint("TOPLEFT", acceptLabel, "BOTTOMLEFT", -16, -6)

UIDropDownMenu_SetWidth(acceptDropdown, 180)

UIDropDownMenu_Initialize(acceptDropdown, function(self, level)

    for i, name in ipairs(QuestAcceptSoundNames) do

        local info = UIDropDownMenu_CreateInfo()
        info.text = name

        info.func = function()
            FFXIV_UI_DB.questAcceptSFX = i - 1
            UIDropDownMenu_SetSelectedID(acceptDropdown, i)
        end

        info.checked = (FFXIV_UI_DB.questAcceptSFX == (i - 1))

        UIDropDownMenu_AddButton(info)
    end

end)

acceptDropdown:SetScript("OnShow", function(self)

    local current = (FFXIV_UI_DB.questAcceptSFX or 1) + 1
    UIDropDownMenu_SetSelectedID(self, current)
    UIDropDownMenu_SetText(self, QuestAcceptSoundNames[current])

end)


-- Quest Complete Dropdown

local completeLabel = options:CreateFontString(nil, "ARTWORK", "GameFontNormal")
completeLabel:SetPoint("TOPLEFT", acceptDropdown, "BOTTOMLEFT", 16, -16)
completeLabel:SetText("Quest Complete Sound")

local completeDropdown = CreateFrame("Frame", "FFXIV_UI_QuestCompleteDropdown", options, "UIDropDownMenuTemplate")
completeDropdown:SetPoint("TOPLEFT", completeLabel, "BOTTOMLEFT", -16, -6)

UIDropDownMenu_SetWidth(completeDropdown, 180)

UIDropDownMenu_Initialize(completeDropdown, function(self, level)

    for i, name in ipairs(QuestCompleteSoundNames) do

        local info = UIDropDownMenu_CreateInfo()
        info.text = name

        info.func = function()
            FFXIV_UI_DB.questCompleteSFX = i - 1
            UIDropDownMenu_SetSelectedID(completeDropdown, i)
        end

        info.checked = (FFXIV_UI_DB.questCompleteSFX == (i - 1))

        UIDropDownMenu_AddButton(info)
    end

end)

completeDropdown:SetScript("OnShow", function(self)

    local current = (FFXIV_UI_DB.questCompleteSFX or 1) + 1
    UIDropDownMenu_SetSelectedID(self, current)
    UIDropDownMenu_SetText(self, QuestCompleteSoundNames[current])

end)
local function UpdateAudioOptionsState()
    local enabled = FFXIV_UI_DB.sfxEnabled
    cb:SetChecked(enabled)

    -- Disable/enable the other audio options based on main SFX checkbox
    errorCB:SetEnabled(enabled)
    acceptDropdown:EnableMouse(enabled)
    completeDropdown:EnableMouse(enabled)
    
 
    errorCB.Text:SetTextColor(enabled and 1 or 0.5, enabled and 1 or 0.5, enabled and 1 or 0.5)
    acceptLabel:SetTextColor(enabled and 1 or 0.5, enabled and 1 or 0.5, enabled and 1 or 0.5)
    completeLabel:SetTextColor(enabled and 1 or 0.5, enabled and 1 or 0.5, enabled and 1 or 0.5)
end

 
cb:SetScript("OnClick", function(self)
    FFXIV_UI_DB.sfxEnabled = self:GetChecked()
    UpdateAudioOptionsState()
end)

 
cb:SetScript("OnShow", function(self)
    UpdateAudioOptionsState()
end)

 
acceptDropdown:SetScript("OnShow", function(self)
    self:EnableMouse(FFXIV_UI_DB.sfxEnabled)
    local current = (FFXIV_UI_DB.questAcceptSFX or 1) + 1
    UIDropDownMenu_SetSelectedID(self, current)
    UIDropDownMenu_SetText(self, QuestAcceptSoundNames[current])
end)

completeDropdown:SetScript("OnShow", function(self)
    self:EnableMouse(FFXIV_UI_DB.sfxEnabled)
    local current = (FFXIV_UI_DB.questCompleteSFX or 1) + 1
    UIDropDownMenu_SetSelectedID(self, current)
    UIDropDownMenu_SetText(self, QuestCompleteSoundNames[current])
end)

-- Quest Accept Preview Button
local acceptPreview = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
acceptPreview:SetSize(60, 22)
acceptPreview:SetPoint("LEFT", acceptDropdown, "RIGHT", 8, 0)
acceptPreview:SetText("Preview")
acceptPreview:SetScript("OnClick", function()
    if FFXIV_UI_DB.sfxEnabled then
        local idx = FFXIV_UI_DB.questAcceptSFX or 0
        local soundFile
        if idx == 0 then
            print("|cff00ff00[FFXIV UI]|r No sound selected for Quest Accept.")
            return
        elseif idx == 1 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted.ogg" 
        elseif idx == 2 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted_HW.ogg"
        elseif idx == 3 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted_SB.ogg"
        elseif idx == 4 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted_ShB.ogg"
        elseif idx == 5 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted_EW.ogg"
        elseif idx == 6 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted_DT.mp3"
        elseif idx == 7 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted_Island.ogg"
        elseif idx == 8 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Accepted_Tribal.ogg"
        end
        if soundFile then PlaySoundFile(soundFile, "Master") end
    end
end)

-- Quest Complete Preview Button
local completePreview = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
completePreview:SetSize(60, 22)
completePreview:SetPoint("LEFT", completeDropdown, "RIGHT", 8, 0)
completePreview:SetText("Preview")
completePreview:SetScript("OnClick", function()
    if FFXIV_UI_DB.sfxEnabled then
        local idx = FFXIV_UI_DB.questCompleteSFX or 0
        local soundFile
               if idx == 0 then
            print("|cff00ff00[FFXIV UI]|r No sound selected for Quest Accept.")
            return
        elseif idx == 1 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Complete.ogg"  
        elseif idx == 2 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Complete_HW.ogg"
        elseif idx == 3 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Complete_SB.ogg"
        elseif idx == 4 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Complete_ShB.ogg"
        elseif idx == 5 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Complete_EW.ogg"
        elseif idx == 6 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Complete_DT.mp3"
        elseif idx == 7 then
            soundFile = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Quest_Complete_Island.ogg"
        end
        if soundFile then PlaySoundFile(soundFile, "Master") end
    end
end)

--Options end--







    local category = Settings.RegisterCanvasLayoutCategory(options, options.name)
    Settings.RegisterAddOnCategory(category)


    local font = CreateFont("CustomActionbarFont")
    font:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtendedBlack.ttf", 14, "")
    _G["NumberFontNormalSmallGray"]:SetFontObject(font)
    _G["NumberFontNormalSmallGray"]:SetTextColor(1, 1, 1)
    _G["NumberFontNormalSmallGray"]:SetShadowColor(0.2,0.2,0.2)
    _G["NumberFontNormalSmallGray"]:SetShadowOffset(1, -1)



    local escapeListener = CreateFrame("Frame", nil, UIParent)
    escapeListener:SetPropagateKeyboardInput(true)
    escapeListener:EnableKeyboard(true)

    escapeListener:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" and anchorsUnlocked then
            anchorsUnlocked = false
            FFXIV_UI_SetAnchorsUnlocked(false)
            PlaySoundFile(soundOff, "Master")
  
        end
    end)




    local combatListener = CreateFrame("Frame")
    combatListener:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatListener:RegisterEvent("PLAYER_REGEN_ENABLED")

    combatListener:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
      
            if anchorsUnlocked then
                anchorsUnlocked = false
                FFXIV_UI_SetAnchorsUnlocked(false)
                PlaySoundFile(soundOff, "Master")
             
            end

        elseif event == "PLAYER_REGEN_ENABLED" then

        end
    end)



    local minimapButton = CreateFrame("Button", "FFXIVUIMinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 12, 32)

    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Minimap\\MinimapButton.tga")
    icon:SetSize(70, 70)
    icon:SetPoint("CENTER")


    local mask = minimapButton:CreateMaskTexture()
    mask:SetTexture("Interface\\Buttons\\WHITE8x8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)


    minimapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(minimapButton, "ANCHOR_LEFT")
        GameTooltip:SetText("FFXIV UI Options")
        GameTooltip:AddLine("Left-click: Open Settings", 1,1,1)
        GameTooltip:AddLine("Right-click: Toggle Anchors", 1,1,1)
        GameTooltip:AddLine("Shift Right-click: Reset Anchors", 1,1,1)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)


    minimapButton:SetScript("OnClick", function(self, button)

    
        if InCombatLockdown() then
            print("|cff00ff00[FFXIV UI]|r Cannot use minimap button while in combat.")

            local f = CreateFrame("Frame")
            f:RegisterEvent("PLAYER_REGEN_ENABLED")
            f:SetScript("OnEvent", function(self)
                print("|cff00ff00[FFXIV UI]|r Combat ended. You may now use the minimap button.")
                self:UnregisterAllEvents()
                self:SetScript("OnEvent", nil)
            end)

            return
        end

  
        if button == "LeftButton" then
            Settings.OpenToCategory(category.ID)
 
        elseif button == "RightButton" then

       
            if IsShiftKeyDown() then
                SlashCmdList["FFXIVUIRESET"]()
                print("|cff00ff00[FFXIV UI]|r All anchors reset.")
 
            else
                anchorsUnlocked = not anchorsUnlocked
                FFXIV_UI_SetAnchorsUnlocked(anchorsUnlocked)

                if anchorsUnlocked then
                    PlaySoundFile(soundOn, "Master")
                else
                    PlaySoundFile(soundOff, "Master")
                end
            end
        end
    end)




minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
local highlight = minimapButton:GetHighlightTexture()
highlight:SetBlendMode("ADD")
highlight:SetAlpha(0.8)
highlight:SetVertexColor(1,0.8,0)
highlight:ClearAllPoints()
highlight:SetPoint("CENTER", minimapButton, "CENTER")
highlight:SetSize(28,28)
