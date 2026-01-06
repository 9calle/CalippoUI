local addonName, CUI = ...

CUI.PA = {}
local PA = CUI.PA
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function PA.UpdateAlpha(frame, inCombat)
    local dbEntry = CUI.DB.profile.PlayerAuras

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
    end
end

---------------------------------------------------------------------------------------------------

local function StyleFrame(frame)
    frame.Icon:SetTexCoord(.08, .92, .08, .92)

    if not frame.Overlay then
        local overlay = CreateFrame("Frame", nil, frame)
        overlay:SetParentKey("Overlay")
        overlay:SetAllPoints(frame.Icon)
        Util.AddBorder(overlay, true)
    end

    frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "Outline")
    frame.Count:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT")

    frame.Duration:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")

    if frame.DebuffBorder then
        frame.DebuffBorder:Hide()
    end
end

local function AddCombatAlpha(frame)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            PA.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            PA.UpdateAlpha(self, true)
        end
    end)

    PA.UpdateAlpha(frame)
end

local function StyleBuffsAndDebuffs()
    for _, frame in pairs({BuffFrame.AuraContainer:GetChildren()}) do
        StyleFrame(frame)
    end

    for _, frame in pairs({DebuffFrame.AuraContainer:GetChildren()}) do
        StyleFrame(frame)
    end
end

local function StyleDebuffs()
    for _, frame in pairs({DebuffFrame.AuraContainer:GetChildren()}) do
        if not frame:IsShown() then return end
        StyleFrame(frame)
    end
end

---------------------------------------------------------------------------------------------------

function PA.Load()
    BuffFrame.CollapseAndExpandButton:SetAlpha(0)

    AddCombatAlpha(BuffFrame)
    AddCombatAlpha(DebuffFrame)

    StyleBuffsAndDebuffs()

    hooksecurefunc(DebuffFrame, "Update", function()
        StyleDebuffs()
    end)
end