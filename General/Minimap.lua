local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_LOGIN")

local function MoveZoomButtons()
    local zoomIn  = Minimap.ZoomIn
    local zoomOut = Minimap.ZoomOut
    if not zoomIn or not zoomOut then return end


    zoomIn:SetParent(FFXIV_MinimapFrame)
    zoomOut:SetParent(FFXIV_MinimapFrame)

    zoomIn:ClearAllPoints()
    zoomOut:ClearAllPoints()
    zoomIn:SetPoint("RIGHT", Minimap, "RIGHT", 9, 20)
    zoomOut:SetPoint("RIGHT", Minimap, "RIGHT", 9, -18)
    zoomIn:SetScale(1.2)
    zoomOut:SetScale(1.2)

    local overlayLevel = FFXIV_MinimapFrame:GetFrameLevel()
    zoomIn:SetFrameLevel(overlayLevel + 2)
    zoomOut:SetFrameLevel(overlayLevel + 2)
end

addon:SetScript("OnEvent", function()

    if FFXIV_MinimapFrame then return end

 
    local elements = {
        MinimapBorder, MinimapBorderTop, MiniMapTracking, 
        MiniMapMailFrame, MinimapZoneTextButton, TimeManagerClockButton
    }
    for _, el in pairs(elements) do if el then el:Hide() end end


    local frame = CreateFrame("Frame", "FFXIV_MinimapFrame", Minimap)
    frame:SetSize(245, 245)
    frame:SetPoint("CENTER", Minimap, "CENTER", -5, 0)
    frame:SetFrameStrata("MEDIUM")
    frame:Show()


    local texture = frame:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints(frame)
    texture:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Minimap\\FFMap.tga")
    texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

   
    local texture2 = frame:CreateTexture(nil, "BACKGROUND")
    texture2:SetPoint("BOTTOM", frame, "BOTTOM", 0, -20)
       texture2:SetSize(245, 245)
    texture2:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\Minimap\\FFCoordsBG.tga")
    texture2:SetDrawLayer("BACKGROUND", 0)

    local coordsText = frame:CreateFontString(nil, "OVERLAY")
    coordsText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-75-SemiBold.otf", 14 )
    coordsText:SetPoint("BOTTOM", frame, "BOTTOM", 0, -6)
    coordsText:SetTextColor(1, 1, 1)


local coordsFrame = CreateFrame("Frame", nil, frame)
coordsFrame:SetSize(120, 20)
coordsFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, -8)


local xInt = coordsFrame:CreateFontString(nil, "OVERLAY")
xInt:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-75-SemiBold.otf", 12)
xInt:SetTextColor(221/255, 216/255, 202/255)
xInt:SetPoint("LEFT", coordsFrame, "LEFT", 15, 0)


local xDec = coordsFrame:CreateFontString(nil, "OVERLAY")
xDec:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-75-SemiBold.otf", 10)
xDec:SetTextColor(221/255, 216/255, 202/255)
xDec:SetPoint("LEFT", xInt, "RIGHT", 0, 0)


local yInt = coordsFrame:CreateFontString(nil, "OVERLAY")
yInt:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-75-SemiBold.otf", 12)
yInt:SetTextColor(221/255, 216/255, 202/255)
yInt:SetPoint("LEFT", xDec, "RIGHT", 8, 0)  


local yDec = coordsFrame:CreateFontString(nil, "OVERLAY")
yDec:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AlibabaPuHuiTi-3-75-SemiBold.otf", 10)
yDec:SetTextColor(221/255, 216/255, 202/255)
yDec:SetPoint("LEFT", yInt, "RIGHT", 0, 0)


local function splitCoord(val)
    local total = val * 100
    local intPart = math.floor(total)
    local decPart = math.floor((total - intPart) * 10)
    return intPart, decPart
end


local function UpdateCoords()
    if UnitIsDeadOrGhost("player") then
        texture2:Hide()
        xInt:SetText("")
        xDec:SetText("")
        yInt:SetText("")
        yDec:SetText("")
        return
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        texture2:Hide()
        xInt:SetText("")
        xDec:SetText("")
        yInt:SetText("")
        yDec:SetText("")
        return
    end

    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if pos then
        local x, y = pos:GetXY()
        local xI, xD = splitCoord(x)
        local yI, yD = splitCoord(y)

        xInt:SetText("X: "..xI)
        xDec:SetText("."..xD)
        yInt:SetText("Y: "..yI)
        yDec:SetText("."..yD)
        texture2:Show()
    else
        xInt:SetText("")
        xDec:SetText("")
        yInt:SetText("")
        yDec:SetText("")
        texture2:Hide()
    end
end



C_Timer.NewTicker(0.2, UpdateCoords)



    MoveZoomButtons()
end)



