local _, ns = ...

local targetFrame = CreateFrame("Frame", nil, UIParent)
local f = targetFrame


local ORIGINAL_WIDTH, ORIGINAL_HEIGHT = 650, 650
local NEW_WIDTH = 650         
local NEW_HEIGHT = 650
f:SetSize(NEW_WIDTH, NEW_HEIGHT)


if _G["FFTargetFrame"] then
    f:SetPoint("LEFT", _G["FFTargetFrame"], "RIGHT", -150 , 0)
    FocusFrame:Hide()
    FocusFrame:UnregisterAllEvents()
    FocusFrame.Show = function() end
else
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)        
end

f:SetFrameStrata("MEDIUM")


local COLORS = {
    hostile  = {200/255, 50/255, 8/255},
    friendly = {228/255,255/255,204/255},
    neutral  = {1.0, 0.87, 0.0},
    player   = {0.6, 0.8, 1.0},
    dead     = {0.35, 0.35, 0.35},
}


local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetPoint("TOPLEFT", 215, -4)
bg:SetPoint("BOTTOMRIGHT", -215, 0)
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Background")
bg:SetVertexColor(unpack(COLORS.neutral))


local bar = CreateFrame("StatusBar", nil, f)
bar:SetPoint("TOPLEFT", 215, -4)
bar:SetPoint("BOTTOMRIGHT", -215, 0)
bar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Health")
local tex = bar:GetStatusBarTexture()
tex:SetDrawLayer("ARTWORK", 0)
tex:SetTexCoord(0, 1, 0, 1)


local outlineFrame = CreateFrame("Frame", nil, f)
outlineFrame:SetFrameStrata("MEDIUM")
outlineFrame:SetFrameLevel(f:GetFrameLevel() + 5)
outlineFrame:SetAllPoints(f)
outlineFrame:EnableMouse(false)


local outline = outlineFrame:CreateTexture(nil, "OVERLAY")
outline:SetAllPoints()
outline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\FocusTarget")
outline:SetDrawLayer("OVERLAY", 3)
outline:SetVertexColor(unpack(COLORS.neutral))


local nameText = outlineFrame:CreateFontString(nil, "OVERLAY")
ns.ApplyTextFont(nameText, "Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisMedium.ttf", 15)
nameText:SetPoint("LEFT", outlineFrame, "LEFT", 220, 16)
nameText:SetJustifyH("LEFT")
nameText:SetDrawLayer("OVERLAY", 7)
nameText:SetShadowOffset(1, -1)


local CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT = 700 / 3, 68
local clickFrame = CreateFrame("Button", nil, outlineFrame, "SecureUnitButtonTemplate")
clickFrame:SetFrameStrata(f:GetFrameStrata())
clickFrame:SetFrameLevel(f:GetFrameLevel() - 1)
clickFrame:SetSize(CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT)
clickFrame:SetPoint("CENTER", outlineFrame, "CENTER", 0, 5)
clickFrame:EnableMouse(true)
clickFrame:RegisterForClicks("AnyUp")
clickFrame:SetAttribute("unit", "focus")
clickFrame:SetAttribute("type1", "target")
clickFrame:SetAttribute("type2", "togglemenu")


local function ShowFrame() f:SetAlpha(1) end
local function HideFrame() f:SetAlpha(0) end

local function DarkenColor(r, g, b, factor)
    factor = factor or 0.6
    return r * factor, g * factor, b * factor
end

local function SetBarAndTextColor(r, g, b)
    bar:SetStatusBarColor(r, g, b, 1)
    local sr, sg, sb = DarkenColor(r, g, b, 0.6)
    nameText:SetTextColor(r, g, b)
    nameText:SetShadowColor(sr, sg, sb)
end


local function UpdateColors()
    if not UnitExists("focus") then return end

  
if UnitIsUnit("focus", "player")
    or UnitInParty("focus")
    or UnitInRaid("focus") then


    bg:SetVertexColor(unpack(COLORS.player))
    outline:SetVertexColor(unpack(COLORS.player))


    bar:SetStatusBarColor(1, 1, 1, 1)

  
    local r, g, b = unpack(COLORS.player)
    local sr, sg, sb = DarkenColor(r, g, b, 0.6)

    nameText:SetTextColor(r, g, b)
    nameText:SetShadowColor(sr, sg, sb)

    return
end


    local inCombatWithFocusTarget = UnitAffectingCombat("player") and UnitCanAttack("player", "focustarget")

    if UnitIsDeadOrGhost("focus") then
        bg:SetVertexColor(unpack(COLORS.dead))
        outline:SetVertexColor(unpack(COLORS.dead))
        SetBarAndTextColor(0.4, 0.4, 0.4)
        return
    end

    if inCombatWithFocusTarget then
        bg:SetVertexColor(unpack(COLORS.hostile))
        outline:SetVertexColor(unpack(COLORS.hostile))
        SetBarAndTextColor(1.0, 0.8, 0.8)
        return
    end

    if UnitIsPlayer("focus") then
        bg:SetVertexColor(unpack(COLORS.player))
        outline:SetVertexColor(unpack(COLORS.player))
        SetBarAndTextColor(unpack(COLORS.player))
        return
    end

    local reaction = UnitReaction("focus", "player")
    if reaction then
        if reaction <= 3 then
            bg:SetVertexColor(unpack(COLORS.hostile))
            outline:SetVertexColor(unpack(COLORS.hostile))
            SetBarAndTextColor(1.0, 0.8, 0.8)
        elseif reaction == 4 then
            bg:SetVertexColor(unpack(COLORS.neutral))
            outline:SetVertexColor(unpack(COLORS.neutral))
            SetBarAndTextColor(235/255, 222/255, 129/255)
        else



     local r,g,b = unpack(COLORS.friendly)
          
 
             nameText:SetTextColor(228/255,255/255,204/255); nameText:SetShadowColor(113/255, 214/255, 64/255)
             
             bg:SetVertexColor(113/255, 214/255, 64/255)
             outline:SetVertexColor(113/255, 214/255, 64/255)
             bar:SetStatusBarColor(228/255,255/255,204/255)



        end
    else
        bg:SetVertexColor(unpack(COLORS.neutral))
        outline:SetVertexColor(unpack(COLORS.neutral))
        SetBarAndTextColor(235/255, 222/255, 129/255)
    end
end


local function Update()
    if UnitExists("focus") then
   
        ShowFrame()

        local hp = UnitHealth("focus")
        local maxHp = UnitHealthMax("focus")
        local name = UnitName("focus") or ""

        bar:SetMinMaxValues(0, maxHp)
        bar:SetValue(hp, Enum.StatusBarInterpolation.ExponentialEaseOut)

        nameText:SetText(name)

        UpdateColors()
    else
     
        HideFrame()
    end
end


f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_FOCUS_CHANGED")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("UNIT_MAXHEALTH")

f:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_FOCUS_CHANGED"
        or unit == "focus" then
        Update()
    end
end)

HideFrame()
 

local anchor = FFXIV_UI_Anchors.FocusTarget
f:SetParent(anchor)
f:ClearAllPoints()
f:SetPoint("CENTER", anchor, "CENTER", 0, -15)