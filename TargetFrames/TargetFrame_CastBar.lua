--print("FFXIV UI Target Cast Bar with Interrupt GIF loaded")

local SCALE = 103
local function s(x) return x * SCALE / 100 end


local NORMAL_OUTLINE_COLOR      = { 0.822, 0.629, 0.225 }
local INTERRUPT_OUTLINE_COLOR   = { 1.0, 0.2, 0.2 }

local NORMAL_GIF_COLOR          = { 1, 1, 1 }
local INTERRUPT_GIF_COLOR       = { 1, 0.7, 0.3 }


local castBar = CreateFrame("StatusBar", nil, UIParent)
castBar:SetPoint("CENTER", UIParent, "CENTER", 175, s(375))
castBar:SetSize(s(285), s(630))
castBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Health")
castBar:SetMinMaxValues(0, 1)
castBar:SetStatusBarColor(1, 1, 1)
castBar:Hide()


local bg = castBar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Health")
bg:SetVertexColor(0.259, 0.188, 0.024, 1)


local outlineFrame = CreateFrame("Frame", nil, castBar)
outlineFrame:SetAllPoints()
outlineFrame:SetFrameLevel(castBar:GetFrameLevel() + 5)

local staticOutline = outlineFrame:CreateTexture(nil, "OVERLAY")
staticOutline:SetPoint("CENTER", castBar, "CENTER", 0, 2)
staticOutline:SetSize(castBar:GetWidth() * 3, castBar:GetHeight())
staticOutline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\TargetTarget")
staticOutline:SetVertexColor(unpack(NORMAL_OUTLINE_COLOR))
staticOutline:Hide()

local textFrame = CreateFrame("Frame", nil, castBar)
textFrame:SetAllPoints()
textFrame:SetFrameLevel(outlineFrame:GetFrameLevel() + 1)

local text = textFrame:CreateFontString(nil, "OVERLAY")
text:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-75-SemiBold.otf", s(20))
text:SetPoint("RIGHT", castBar, "RIGHT", 0, -s(4))
text:SetShadowOffset(0, -1)
text:SetShadowColor(0.631, 0.514, 0.318, 1)
text:SetTextColor(1, 0.976, 0.839, 1)


local gifFrame = CreateFrame("Frame", nil, castBar)
gifFrame:SetFrameStrata("HIGH")
gifFrame:SetFrameLevel(castBar:GetFrameLevel() + 20)
gifFrame:SetSize(castBar:GetWidth() * 1.3, castBar:GetHeight() * 0.5)
gifFrame:SetPoint("CENTER", castBar, "CENTER")

local gifTexture = gifFrame:CreateTexture(nil, "OVERLAY")
gifTexture:SetAllPoints()
gifTexture:SetBlendMode("BLEND")
gifTexture:SetVertexColor(unpack(NORMAL_GIF_COLOR))
gifTexture:Hide()

textFrame:SetFrameStrata("HIGH")
textFrame:SetFrameLevel(gifFrame:GetFrameLevel() + 5)

local anchor = FFXIV_UI_Anchors.TargetCast
castBar:SetParent(anchor)
castBar:ClearAllPoints()
castBar:SetPoint("CENTER", anchor, "CENTER", 0, -15)

local frames = {}
local FRAME_COUNT = 14 

for i = 1, FRAME_COUNT do
    frames[i] =
        ("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Interruptable\\Layer %d.tga"):format(i)
end




local gifTicker
local frameIndex = 1
local gifPlaying = false

local function StartGif()
    if gifPlaying or not frames[1] then return end
    gifPlaying = true
    frameIndex = 1

    gifTexture:SetTexture(frames[1])
    gifTexture:Show()

    gifTicker = C_Timer.NewTicker(0.05, function()
        frameIndex = frameIndex + 1
        if frameIndex > #frames then frameIndex = 1 end
        gifTexture:SetTexture(frames[frameIndex])
    end)
end

local function StopGif()
    gifPlaying = false
    gifTexture:Hide()

    if gifTicker then
        gifTicker:Cancel()
        gifTicker = nil
    end
end

 

local function StopCast()
    castBar:Hide()
    outlineFrame:Hide()
    staticOutline:Hide()
    StopGif()
     
end

local function UpdateCast()

    local name, _, texture, start, endTime, isTradeSkill, castID, notInterruptible, spellid = UnitCastingInfo("target");
           

    if name then
        castBar:SetTimerDuration(UnitCastingDuration("target"), 0, 0)

        castBar:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, CreateColor(1.0, 1.0, 1.0, 1), CreateColor(1.0, 1.0, 1.0, 1))

        staticOutline:SetVertexColorFromBoolean(notInterruptible,  CreateColor(0.822, 0.629, 0.225, 1), CreateColor(1.0, 0.2, 0.2, 1))

        gifTexture:SetVertexColorFromBoolean(notInterruptible, CreateColor(0.0, 0.0, 0.0, 0), CreateColor(1, 0.7, 0.3, 1))
     
        bg:SetVertexColorFromBoolean(notInterruptible, CreateColor(0.259, 0.188, 0.024, 1, 1), CreateColor(0.23, 0.10, 0.0, 1))

        if not UnitCanAttack("player", "target") then
            gifTexture:SetVertexColor(0.0, 0.0, 0.0, 0)
            staticOutline:SetVertexColor(unpack(NORMAL_OUTLINE_COLOR))
            castBar:SetStatusBarColor(1, 1, 1)
            bg:SetVertexColor(0.259, 0.188, 0.024, 1)
        end 

        text:SetText(name)
        castBar:Show()
        outlineFrame:Show()
        staticOutline:Show()
        return
    end


    name, _, texture, start, endTime, isTradeSkill, notInterruptible, spellid = UnitChannelInfo("target");
         
 
    if name then
        castBar:SetTimerDuration(UnitChannelDuration("target"), 0, 1)

        castBar:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, CreateColor(1.0, 1.0, 1.0, 1), CreateColor(1.0, 1.0, 1.0, 1))

        staticOutline:SetVertexColorFromBoolean(notInterruptible,  CreateColor(0.822, 0.629, 0.225, 1), CreateColor(1.0, 0.2, 0.2, 1))

        gifTexture:SetVertexColorFromBoolean(notInterruptible, CreateColor(0.0, 0.0, 0.0, 0), CreateColor(1, 0.7, 0.3, 1))

        bg:SetVertexColorFromBoolean(notInterruptible, CreateColor(0.259, 0.188, 0.024, 1), CreateColor(0.23, 0.10, 0.0, 1))

        if not UnitCanAttack("player", "target") then
            gifTexture:SetVertexColor(0.0, 0.0, 0.0, 0)
            staticOutline:SetVertexColor(unpack(NORMAL_OUTLINE_COLOR))
            castBar:SetStatusBarColor(1, 1, 1)
            bg:SetVertexColor(0.259, 0.188, 0.024, 1)
        end 

        text:SetText(name)
        castBar:Show()
        outlineFrame:Show()
        staticOutline:Show()
        return
    end

    StopCast()

end

local function OnCastStart()
    UpdateCast()    
    StartGif()

end



local function OnChannelStart(unit)
       UpdateCast()    
       StartGif()
end


local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_SPELLCAST_START")
f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
f:RegisterEvent("UNIT_SPELLCAST_STOP")
f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
f:RegisterEvent("UNIT_SPELLCAST_FAILED")
f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
f:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

f:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateCast()
        
        if castBar:IsShown() then
            StartGif()
        else
            StopGif()
        end
        return
    end

    if unit == "target" then
        if event == "UNIT_SPELLCAST_CHANNEL_START" then
            C_Timer.After(0.01, OnCastStart)
        elseif event == "UNIT_SPELLCAST_START" then
            OnCastStart()
        elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_FAILED" then
            StopCast()
        elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
            UpdateCast()
        end
    end
end)




castBar:SetScript("OnUpdate", UpdateCast)
