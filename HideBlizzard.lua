local addonName, CUI = ...

CUI.Hide = {}
local Hide = CUI.Hide

local hiddenParent = CreateFrame("Frame", nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

function Hide.HideFrame(frame, dontReparent)
    if not frame then return end

    if frame.UnregisterAllEvents then
        frame:UnregisterAllEvents()
    end

    frame:Hide()

    if dontReparent then return end
    frame:SetParent(hiddenParent)
end

function Hide.UnregisterChildren(frame)
    for _, child in ipairs({frame:GetChildren()}) do
        if child.UnregisterAllEvents then
            child:UnregisterAllEvents()
        end
        child:Hide()
        if child:GetObjectType() ~= "Button" then
            child:HookScript("OnShow", function(self)
                self:Hide()
            end)
        end
    end

    for _, child in ipairs({frame:GetRegions()}) do
        if child.UnregisterAllEvents then
            child:UnregisterAllEvents()
        end
        child:Hide()
        child:HookScript("OnShow", function(self)
            self:Hide()
        end)
    end
end

function Hide.HideUnitFrameChildren(frame)
    if frame.Portrait then
        Hide.HideFrame(frame.Portrait)
    end

    if frame.healthbar then
        Hide.HideFrame(frame.healthbar)
    end

    if frame.manabar then
        Hide.HideFrame(frame.manabar)
    end

    if frame.powerBarAlt then
        Hide.HideFrame(frame.powerBarAlt)
    end

    if frame.name then
        Hide.HideFrame(frame.name)
    end
end

function Hide.HideBlizzardParty()
    _G.UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")

    if _G.CompactPartyFrame then
        _G.CompactPartyFrame:UnregisterAllEvents()
    end

    if _G.PartyFrame then
        _G.PartyFrame:UnregisterAllEvents()
        _G.PartyFrame:SetScript("OnShow", nil)
        for frame in _G.PartyFrame.PartyMemberFramePool:EnumerateActive() do
            Hide.HideFrame(frame)
        end
        Hide.HideFrame(_G.PartyFrame)
    else
        for i = 1, 4 do
            Hide.HideFrame(_G["PartyMemberFrame"..i])
            Hide.HideFrame(_G["CompactPartyMemberFrame"..i])
        end
        Hide.HideFrame(_G.PartyMemberBackground)
    end
end

function Hide.HideBlizzardRaid()
    _G.UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")

    if _G.CompactRaidFrameContainer then
        _G.CompactRaidFrameContainer:UnregisterAllEvents()
        _G.CompactRaidFrameContainer:SetParent(hiddenParent)
    end
end

function Hide.HideBlizzardRaidManager()
    if CompactRaidFrameManager_SetSetting then
        CompactRaidFrameManager_SetSetting("IsShown", "0")
    end

    if _G.CompactRaidFrameManager then
        _G.CompactRaidFrameManager:UnregisterAllEvents()
        _G.CompactRaidFrameManager:SetParent(hiddenParent)
    end
end