local addonID, addonEnv = ...
--print("FFXIV UI Player Cast Bar (Empowered) loaded")
if PlayerCastingBarFrame then
    PlayerCastingBarFrame:UnregisterAllEvents()
    PlayerCastingBarFrame:Hide()
end

local SCALE = 100
local function s(x)
    return x * SCALE / 100
end


local frame = CreateFrame("Frame", "PlayerCastBarFrame", UIParent)
frame:SetSize(s(232), s(230))
frame:SetPoint("CENTER", UIParent, "CENTER", s(0), s(0))
frame:SetFrameStrata("MEDIUM")
 
frame:Hide()


local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Background")

local castBar = CreateFrame("StatusBar", nil, frame)
castBar:SetPoint("TOPLEFT", s(4), s(-4))
castBar:SetPoint("BOTTOMRIGHT", s(-4), s(4))
castBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Default") 
castBar:SetMinMaxValues(0,1)
castBar:SetValue(0)
castBar:Hide()

local outlineFrame = CreateFrame("Frame", nil, frame)
outlineFrame:SetFrameStrata("MEDIUM")
outlineFrame:SetFrameLevel(frame:GetFrameLevel() + 5)
outlineFrame:SetSize(frame:GetWidth(), frame:GetHeight())
outlineFrame:SetPoint("CENTER", frame, "CENTER")
outlineFrame:EnableMouse(false)

local outline = outlineFrame:CreateTexture(nil, "OVERLAY")
outline:SetAllPoints()
outline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Frame")
outline:SetDrawLayer("OVERLAY", 3)


local spellButton = CreateFrame("Button", nil, outlineFrame)
spellButton:SetSize(s(63), s(63))
spellButton:SetPoint("LEFT", outlineFrame, "LEFT", s(-65), s(-10))
spellButton:Hide()

spellButton.icon = spellButton:CreateTexture(nil, "ARTWORK")
spellButton.icon:SetAllPoints()
spellButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

spellButton.cooldown = CreateFrame("Cooldown", nil, spellButton, "CooldownFrameTemplate")
spellButton.cooldown:SetAllPoints()
spellButton.cooldown:SetDrawSwipe(true)

local Masque = LibStub and LibStub("Masque", true)
local MasqueGroup
if Masque then
	MasqueGroup = Masque:Group("FFXIV UI Player Cast Bar", "Player Cast Bar (Empowered)")
	MasqueGroup:AddButton(spellButton, { Icon = spellButton.icon, Cooldown = spellButton.cooldown })
end


local spellText = outlineFrame:CreateFontString(nil, "OVERLAY")
spellText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-65-Medium.otf", s(18))
spellText:SetPoint("LEFT", outlineFrame, "LEFT", s(3), s(15))
spellText:SetJustifyH("RIGHT")
spellText:SetDrawLayer("OVERLAY", 7)
spellText:SetTextColor(252/255, 251/255, 250/255)
spellText:SetShadowColor(0.8196, 0.7804, 0.6980)
spellText:SetShadowOffset(0, -1)

local hpLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
hpLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MiedingerMedium.ttf", s(18))
hpLabel:SetPoint("BOTTOMLEFT", outlineFrame, "BOTTOMLEFT", s(2), s(75))
hpLabel:SetJustifyH("LEFT")
hpLabel:SetDrawLayer("OVERLAY", 7)
hpLabel:SetText("CASTING")
hpLabel:SetTextColor(252/255, 251/255, 250/255)
hpLabel:SetShadowColor(0.8196, 0.7804, 0.6980)
hpLabel:SetShadowOffset(0, -1)

local castTimeText = outlineFrame:CreateFontString(nil, "OVERLAY")
castTimeText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtended.ttf", s(32))
castTimeText:SetPoint("LEFT", hpLabel, "RIGHT", s(8), -3)
castTimeText:SetJustifyH("LEFT")
castTimeText:SetDrawLayer("OVERLAY", 7)
castTimeText:SetTextColor(252/255, 251/255, 250/255)
castTimeText:SetShadowColor(0.8196, 0.7804, 0.6980)
castTimeText:SetShadowOffset(0, -1)
castTimeText:SetText("00.00")

castBar.displayedProgress = 0
castBar.isEmpowered = false
castBar.numStages = 0
castBar.startTime = nil
castBar.endTime = nil



local FONT_OF_POWER_SPELLID = 411212

local function PlayerHasFontOfPower()

    if C_Traits and C_Traits.GetKnownTreeIDs then
        for _, treeID in ipairs(C_Traits.GetKnownTreeIDs()) do
            local nodes = C_Traits.GetTreeNodes(treeID)
            for _, nodeID in ipairs(nodes) do
                local nodeInfo = C_Traits.GetNodeInfo(nodeID)
                if nodeInfo and nodeInfo.spellID == FONT_OF_POWER_SPELLID and nodeInfo.active then
                    return true
                end
            end
        end
    end


    if IsPlayerSpell(FONT_OF_POWER_SPELLID) then
        return true
    end

    return false
end


castBar:SetScript("OnUpdate", function(self, elapsed)
    if not self.startTime or not self.endTime then return end

    local now = GetTime()
    local total = self.endTime - self.startTime
    if total <= 0 then total = 0.001 end

    local progress = (now - self.startTime) / total
    progress = math.max(0, math.min(1, progress))


    self.displayedProgress = self.displayedProgress + (progress - self.displayedProgress) * math.min(elapsed * 10, 1)
    self:SetValue(self.displayedProgress)


    local remaining = math.max(0, self.endTime - now)
    local sec = math.floor(remaining)
    local centi = math.floor((remaining - sec) * 100)
    castTimeText:SetText(string.format("%02d.%02d", sec, centi))

    if self.isEmpowered and self.empoweredColorCurve then
        local color = self.empoweredColorCurve:Evaluate(progress)
        local r, g, b = color:GetRGB()
        self:GetStatusBarTexture():SetVertexColor(r, g, b, 1)
    else
        self:GetStatusBarTexture():SetVertexColor(1, 1, 1, 1)
    end


    if progress >= 1 and self.displayedProgress >= 0.999 then
        self:Hide()
        frame:Hide()
        spellButton:Hide()
        spellText:SetText("")
        castTimeText:SetText("00.00")
        self.startTime, self.endTime = nil, nil
        self.displayedProgress = 0
        self.isEmpowered = false
    end
end)


frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

frame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    if unit ~= "player" then return end

    if event == "UNIT_SPELLCAST_EMPOWER_START" then
   
        local name, icon
        if C_Spell and C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                name = spellInfo.name
                icon = spellInfo.iconID or 136243
            end
        end
        if not name or not icon then
            name, _, icon = GetSpellInfo(spellID)
        end
        if not name then name = "Empowered Cast" end
        if not icon then icon = 136243 end


        local _, _, _, startTimeMS, endTimeMS = UnitCastingInfo("player")
        if startTimeMS and endTimeMS then
            castBar.startTime = startTimeMS / 1000
            castBar.endTime = endTimeMS / 1000
        else
            castBar.startTime = GetTime()
            castBar.endTime = castBar.startTime + 3
        end

        castBar.displayedProgress = 0
        castBar.isEmpowered = true
        spellText:SetText(name)
        spellButton.icon:SetTexture(icon)
        castBar:Show()
        frame:Show()
        spellButton:Show()


local curve = C_CurveUtil.CreateColorCurve()
curve:SetType(Enum.LuaCurveType.Step)
curve:AddPoint(0.0, CreateColor(1, 1, 1, 1))   
curve:AddPoint(0.25, CreateColor(0, 1, 0, 1))  
curve:AddPoint(0.5, CreateColor(1, 1, 0, 1))   

curve:AddPoint(0.75, CreateColor(1, 0, 0, 1))
curve:AddPoint(1.0, CreateColor(1, 0, 0, 1))  


if PlayerHasFontOfPower() then

    curve:AddPoint(0.6, CreateColor(1, 0.5, 0, 1))

end

castBar.empoweredColorCurve = curve


    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
     
        castBar.startTime, castBar.endTime = nil, nil
        castBar.isEmpowered = false
        castBar.displayedProgress = 0
        frame:Hide()
        castBar:Hide()
        spellButton:Hide()
        spellText:SetText("")
        castTimeText:SetText("00.00")
    end
end)

local anchor = FFXIV_UI_Anchors.PlayerCast
frame:SetParent(anchor)
frame:ClearAllPoints()
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)