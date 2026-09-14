-- 中文缺字复用字体。只选择字体，不检查或转换游戏传入的文本。
local addonName, ns = ...
local locale = GetLocale()
local useChineseFont = locale == "zhCN" or locale == "zhTW"
local drawnFont = "Interface\\AddOns\\" .. addonName .. "\\Media\\Fonts\\AxisRegular-CJKDrawn.ttf"
local reuseFont = "Interface\\AddOns\\" .. addonName .. "\\Media\\Fonts\\AxisRegular-CJKReuse.ttf"
local warned = false

function ns.ApplyTextFont(fontString, originalFont, size, flags)
    if useChineseFont then
        if fontString:SetFont(drawnFont, size, flags) then
            return true
        end
        if fontString:SetFont(reuseFont, size, flags) then
            return true
        end
        if not warned then
            print("FFXIV UI: 中文补绘及复用字体未加载，已尝试使用客户端字体。请按 README 生成字体并完全重启游戏。")
            warned = true
        end
        if STANDARD_TEXT_FONT and fontString:SetFont(STANDARD_TEXT_FONT, size, flags) then
            return true
        end
    end
    return fontString:SetFont(originalFont, size, flags)
end
