local _, ns = ...
hooksecurefunc(PlayerFrame, "Show", function(self)
    self:SetAlpha(0)
end)

local SCALE = 100
local function s(x) return x * SCALE / 100 end

PetFrame_HP = CreateFrame("Frame", nil, UIParent)
local f = PetFrame_HP

f:SetSize(s(232), s(230))
f:SetFrameStrata("MEDIUM")
f:SetAlpha(0)

local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Background")

local bar = CreateFrame("StatusBar", nil, f)
bar:SetPoint("TOPLEFT", s(4), s(-4))
bar:SetPoint("BOTTOMRIGHT", s(-4), s(4))
bar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Health")
bar:SetFrameLevel(f:GetFrameLevel() + 2)

local cutawayBar = CreateFrame("StatusBar", nil, f)
cutawayBar:SetPoint("TOPLEFT", s(4), s(-4))
cutawayBar:SetPoint("BOTTOMRIGHT", s(-4), s(4))
cutawayBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Cutaway")
cutawayBar:SetFrameLevel(f:GetFrameLevel() + 1)

local outlineFrame = CreateFrame("Frame", nil, f)
outlineFrame:SetFrameStrata("MEDIUM")
outlineFrame:SetFrameLevel(f:GetFrameLevel() + 5)
outlineFrame:SetSize(f:GetWidth(), f:GetHeight())
outlineFrame:SetPoint("CENTER", f, "CENTER")
outlineFrame:EnableMouse(false)

local outline = outlineFrame:CreateTexture(nil, "OVERLAY")
outline:SetAllPoints()
outline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Frame")
outline:SetDrawLayer("OVERLAY", 3)

local text = outlineFrame:CreateFontString(nil, "OVERLAY")
text:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtended.ttf", s(30))
text:SetPoint("BOTTOMRIGHT", outlineFrame, "BOTTOMRIGHT", s(-4), s(76))
text:SetJustifyH("RIGHT")
text:SetDrawLayer("OVERLAY", 7)
text:SetTextColor(252/255, 251/255, 250/255)
text:SetShadowColor(0.8196, 0.7804, 0.6980)
text:SetShadowOffset(0, -1)

local hpLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
hpLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MiedingerMedium.ttf", s(18))
hpLabel:SetPoint("BOTTOMLEFT", outlineFrame, "BOTTOMLEFT", s(2), s(80))
hpLabel:SetJustifyH("LEFT")
hpLabel:SetDrawLayer("OVERLAY", 7)
hpLabel:SetText("HP")
hpLabel:SetTextColor(252/255, 251/255, 250/255)
hpLabel:SetShadowColor(0.8196, 0.7804, 0.6980)
hpLabel:SetShadowOffset(0, -1)

local nameText = outlineFrame:CreateFontString(nil, "OVERLAY")
ns.ApplyTextFont(nameText, "Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtended.ttf", s(20))
nameText:SetPoint("RIGHT", outlineFrame, "RIGHT", -10, s(10))
nameText:SetJustifyH("RIGHT")
nameText:SetDrawLayer("OVERLAY", 7)
nameText:SetTextColor(252/255, 251/255, 250/255)
nameText:SetShadowColor(0.8196, 0.7804, 0.6980)
nameText:SetShadowOffset(0, -1)

local CLICK_RECT_WIDTH  = s(240)
local CLICK_RECT_HEIGHT = s(48)
local clickFrame = CreateFrame("Button", nil, outlineFrame, "SecureUnitButtonTemplate")
clickFrame:SetFrameStrata("HIGH")
clickFrame:SetFrameLevel(outlineFrame:GetFrameLevel() + 10)
clickFrame:SetSize(CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT)
clickFrame:SetPoint("CENTER", outlineFrame, "CENTER", 0, s(-10))
clickFrame:EnableMouse(true)
clickFrame:RegisterForClicks("AnyUp")
clickFrame:SetAttribute("unit", "pet")
clickFrame:SetAttribute("type1", "target")
clickFrame:SetAttribute("type2", "togglemenu")

local anchor = FFXIV_UI_Anchors.PlayerPowerSec
f:SetParent(anchor)
f:ClearAllPoints()
f:SetPoint("CENTER", anchor, "CENTER", 0, 0)

local function Update()
    if UnitExists("pet") then
        f:SetAlpha(1)

        local hp = UnitHealth("pet")
        local maxHp = UnitHealthMax("pet")
        local name = GetUnitName("pet", true)

        if not name or name == "" or name == UNKNOWN then
            name = PET
        end

        bar:SetMinMaxValues(0, maxHp)
        bar:SetValue(hp)
        text:SetText(hp)
        nameText:SetText(name)

        cutawayBar:SetMinMaxValues(0, maxHp)
        cutawayBar:SetValue(hp, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        f:SetAlpha(0)
    end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("UNIT_MAXHEALTH")
f:RegisterEvent("UNIT_PET")
f:RegisterEvent("UNIT_NAME_UPDATE")

f:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_PET" then
        C_Timer.After(0.1, Update)
    elseif not unit or unit == "pet" then
        Update()
    end
end)

Update()