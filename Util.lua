local addonName, CUI = ...

CUI.Util = {}
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function Util.AddBorder(frame, useLines)
    frame.Borders = {}
    if useLines then
        local pixel = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1)

        for i=1, 4 do
            frame.Borders[i] = frame:CreateLine(nil, "OVERLAY", nil, 0)
            local l = frame.Borders[i]
            l:SetThickness(pixel)
            l:SetColorTexture(0, 0, 0, 1)
            if i==1 then
                l:SetStartPoint("TOPLEFT", frame, -pixel/2, 0)
                l:SetEndPoint("TOPRIGHT", frame, pixel/2, 0)
            elseif i==2 then
                l:SetStartPoint("TOPRIGHT")
                l:SetEndPoint("BOTTOMRIGHT")
            elseif i==3 then
                l:SetStartPoint("BOTTOMRIGHT", frame, pixel/2, 0)
                l:SetEndPoint("BOTTOMLEFT", frame, -pixel/2, 0)
            else
                l:SetStartPoint("BOTTOMLEFT")
                l:SetEndPoint("TOPLEFT")
            end
        end
    else
        local backdropInfo = {
            edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorder.blp",
            edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) * 3,
            bgFile = nil
        }

        local offset = 1
        local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        backdrop:SetParentKey("BackdropBorder")
        backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -offset, offset)
        backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offset, -offset)
        backdrop:SetBackdrop(backdropInfo)
    end
end

function Util.SetBorderColor(borders, r, g, b, a)
    for _, line in ipairs(borders) do
        line:SetColorTexture(r, g, b, a)
    end
end

function Util.AddStatusBarBackground(frame)
    local r, g, b = frame:GetStatusBarColor()

    local v = 0.2
    r, g, b = r*v, g*v, b*v

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetParentKey("Background")
    bg:SetAllPoints(frame)
    bg:SetTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    bg:SetVertexColor(r, g, b, 1)
end

function Util.GetUnitColor(unit, prioClass)
    local r, g, b = 0, 0, 0

    if unit == "pet" then unit = "player" end

    local _, class = UnitClass(unit)
    if class and (prioClass or UnitIsPlayer(unit)) then
        local color = C_ClassColor.GetClassColor(class)
        r, g, b = color.r, color.g, color.b
    else
        local reaction = UnitReaction(unit, "player")

        if not reaction then return 0, 0, 0 end

        if reaction <= 3 then     -- Hostile
            r, g, b = 0.8, 0, 0
        elseif reaction == 4 then -- Neutral
            r, g, b = 1, 1, 0
        else                      -- Friendly
            r, g, b = 0, 0.8, 0
        end
    end

    return r, g, b
end

function Util.GetUnitPowerColor(unit)
    local _, powerType = UnitPowerType(unit)
    if powerType == "MANA" or powerType == nil then powerType = "MAELSTROM" end

    local color = PowerBarColor[powerType]
    if color == nil then
        color = PowerBarColor["MAELSTROM"]
    end

    return color.r, color.g, color.b
end

function Util.UnitHealthPercent(unit)
    return string.format("%0.0f", UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)).."%"
end

function Util.UnitPowerPercent(unit, powerType)
    return string.format("%0.0f", UnitPowerPercent(unit, 0, true, CurveConstants.ScaleTo100)).."%"
end

function Util.SetUnitHealthText(text, unit)
    text:SetFormattedText("%s", AbbreviateNumbers(UnitHealth(unit)))
end

function Util.UnitPowerText(unit)
    local power = UnitPower(unit)
    local rounded = AbbreviateLargeNumbers(power)
    return rounded
end

local frameFadeManager = CreateFrame("Frame")

local function UIFrameFadeContains(frame)
	for i, fadeFrame in ipairs(FADEFRAMES) do
		if ( fadeFrame == frame ) then
			return true;
		end
	end

	return false;
end

function Util.FadeFrame(frame, inOut, endAlpha, fadeTime)
    if not fadeTime then fadeTime = 0.5 end
	local fadeInfo = {}
	fadeInfo.mode = inOut -- "IN" or "OUT"
	fadeInfo.timeToFade = fadeTime
	fadeInfo.startAlpha = frame:GetAlpha()
	fadeInfo.endAlpha = endAlpha

    frame.fadeInfo = fadeInfo

	if securecallfunction(UIFrameFadeContains, frame) then
		return
	end
	tinsert(FADEFRAMES, frame)
	frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate)
end

function Util.PositionFromIndex(index, frame, anchorFrame, point, relativePoint, dirH, dirV, frameWidth, frameHeight, padding, offsetX, offsetY, rowLength)
    local x, y
    local level = math.floor(index/rowLength)

    if dirH == "LEFT" then
        x = -(index*(frameWidth+padding))+(level*rowLength*(frameWidth+padding))+offsetX
    elseif dirH == "RIGHT" then
        x = (index*(frameWidth+padding))-(level*rowLength*(frameWidth+padding))+offsetX
    end

    if dirV == "UP" then
        y = (level*(frameHeight+padding))+offsetY
    elseif dirV == "DOWN" then
        y = -(level*(frameHeight+padding))+offsetY
    end

    frame:ClearAllPoints()
    frame:SetPoint(point, anchorFrame, relativePoint, x, y)
end

function Util.CheckAnchorFrame(frame, dbEntry)
    local anchorFrame = _G[dbEntry.AnchorFrame]
    if not anchorFrame then
        print(frame:GetName().." could not anchor to "..dbEntry.AnchorFrame.." because it does not exist, resetting anchor to center of UIParent")
        dbEntry.AnchorFrame = "UIParent"
        dbEntry.AnchorPoint = "CENTER"
        dbEntry.AnchorRelativePoint = "CENTER"
        dbEntry.PosX = 0
        dbEntry.PosY = 0
    end
end