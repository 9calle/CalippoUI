local addonName, CUI = ...

CUI.MM = {}
local MM = CUI.MM
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function MM.UpdateAlpha(frame, inCombat)
    local dbEntry = CUI.DB.profile.Minimap

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
    end
end

---------------------------------------------------------------------------------------------------

local function SetupMinimap()
    MinimapBackdrop:Hide()
    MinimapCompassTexture:Hide()

    MinimapCluster.MinimapContainer:SetAllPoints(MinimapCluster)

    MinimapCluster.BorderTop:Hide()

    MinimapCluster.Tracking.Button:ClearAllPoints()
    MinimapCluster.Tracking.Button:SetPoint("BOTTOM", Minimap, "BOTTOM", -10, 3)
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Background:Hide()

    MinimapCluster.ZoneTextButton:ClearAllPoints()
    MinimapCluster.ZoneTextButton:SetFrameLevel(10)
    MinimapCluster.ZoneTextButton:SetPoint("TOP", Minimap, "TOP", 0, -5)
    local zoneText = MinimapCluster.ZoneTextButton:GetRegions()
    zoneText:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    zoneText:SetJustifyH("CENTER")

    MinimapCluster.MinimapContainer:SetAllPoints(MinimapCluster)

    MinimapCluster.InstanceDifficulty:ClearAllPoints()
    MinimapCluster.InstanceDifficulty:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 1, 1)

    MinimapCluster.IndicatorFrame:ClearAllPoints()
    MinimapCluster.IndicatorFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2)

    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -3, 13)

    local clockText = TimeManagerClockButton:GetRegions()
    clockText:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")

    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 10, 0)
    GameTimeFrame:SetAlpha(0)

    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
    if not Minimap.Borders then
        Util.AddBorder(Minimap)
    end

    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPRIGHT", MinimapCluster.MinimapContainer, "TOPRIGHT")

    MinimapCluster:RegisterEvent("PLAYER_REGEN_ENABLED")
    MinimapCluster:RegisterEvent("PLAYER_REGEN_DISABLED")
    MinimapCluster:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            MM.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            MM.UpdateAlpha(self, true)
        end
    end)
    MM.UpdateAlpha(MinimapCluster)

    Minimap:HookScript("OnEnter", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(1)
        GameTimeFrame:SetAlpha(1)
    end)

    Minimap:HookScript("OnLeave", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(0)
        GameTimeFrame:SetAlpha(0)
    end)

    ObjectiveTrackerFrame.Header.MinimizeButton:SetAlpha(0.5)
    ObjectiveTrackerFrame.Header.Background:Hide()
    ObjectiveTrackerFrame.Header.Text:Hide()

    FramerateFrame:Show()
    FramerateFrame.Label:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    FramerateFrame.FramerateText:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    FramerateFrame:ClearAllPoints()
    FramerateFrame:SetParent(Minimap)
    FramerateFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 5, 3)
    hooksecurefunc(FramerateFrame, "UpdatePosition", function(self)
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 5, 3)
    end)

    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetPoint("CENTER", Minimap, "BOTTOMLEFT")
    hooksecurefunc(QueueStatusButton, "UpdatePosition", function(self)
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "BOTTOMLEFT")
    end)
end

---------------------------------------------------------------------------------------------------

function MM.Load()
    SetupMinimap()

    EditModeManagerFrame:HookScript("OnHide", function(self)
        SetupMinimap()
    end)
end