local addonName, CUI = ...

CUI.CB = {}
local CB = CUI.CB
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.UnregisterChildren(PlayerCastingBarFrame)
    Hide.HideFrame(PlayerCastingBarFrame)
end

---------------------------------------------------------------------------------------------------

function CB.UpdateFrame(frame)
    local dbEntry = CUI.DB.profile.PlayerCastBar

    frame:ClearAllPoints()
    frame:SetSize(dbEntry.Width, dbEntry.Height)
    frame:SetStatusBarTexture(dbEntry.Texture)
    frame.Background:SetTexture(dbEntry.Texture)

    local r, g, b, a = dbEntry.Color.r, dbEntry.Color.g, dbEntry.Color.b, dbEntry.Color.a
    frame:SetStatusBarColor(r, g, b, a)

    local v = 0.2
    frame.Background:SetVertexColor(r*v, g*v, b*v, 1)
    frame:SetReverseFill(false)

    Util.CheckAnchorFrame(frame, dbEntry)

    if dbEntry.MatchWidth then
        frame:SetPoint("BOTTOMLEFT", dbEntry.AnchorFrame, "TOPLEFT", 0, dbEntry.PosY)
        frame:SetPoint("BOTTOMRIGHT", dbEntry.AnchorFrame, "TOPRIGHT", 0, dbEntry.PosY)
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end
end

---------------------------------------------------------------------------------------------------

local function UpdateCastBar(castBar, isChannel, isEmpower)
    local duration

    if isChannel or isEmpower then
        duration = UnitChannelDuration("player")
    else
        duration = UnitCastingDuration("player")
    end

    local direction
    if isChannel then
        direction = 1
    else
        direction = 0
    end

    castBar:SetTimerDuration(duration, 0, direction)

    castBar.startTime = startTime
    castBar.endTime = endTime
    castBar:Show()
end

---------------------------------------------------------------------------------------------------

local castBar = CreateFrame("Statusbar", "CUI_CastBar", UIParent)

local function SetupCastBar()
    castBar:SetStatusBarTexture(CUI.DB.profile.PlayerCastBar.Texture)
    castBar:Hide()

    Util.AddStatusBarBackground(castBar)
    Util.AddBorder(castBar)

    CB.UpdateFrame(castBar)

    castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")
    castBar:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_START" then
            UpdateCastBar(self, false)
        elseif event == "UNIT_SPELLCAST_EMPOWER_START" then
            UpdateCastBar(self, false, true)
        elseif event == "UNIT_SPELLCAST_CHANNEL_START"
            or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            UpdateCastBar(self, true)
        elseif event == "UNIT_SPELLCAST_STOP"
            or event == "UNIT_SPELLCAST_CHANNEL_STOP"
            or event == "UNIT_SPELLCAST_INTERRUPTED"
            or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
            self:Hide()
        end
    end)
end

---------------------------------------------------------------------------------------------------

function CB.Load()
    HideBlizzard()
    SetupCastBar()
end