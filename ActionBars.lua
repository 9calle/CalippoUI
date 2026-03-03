local addonName, CUI = ...

CUI.AB = {}
local AB = CUI.AB
local Hide = CUI.Hide
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.HideFrame(TalkingHeadFrame)
end

---------------------------------------------------------------------------------------------------

local microMenuButtons = {
    CharacterMicroButton,
    ProfessionMicroButton,
    PlayerSpellsMicroButton,
    AchievementMicroButton,
    QuestLogMicroButton,
    HousingMicroButton,
    GuildMicroButton,
    LFDMicroButton,
    CollectionsMicroButton,
    EJMicroButton,
    StoreMicroButton,
    MainMenuMicroButton,
}

local bagsBarButtons = {
    BagBarExpandToggle,
    CharacterBag0Slot,
    CharacterBag1Slot,
    CharacterBag2Slot,
    CharacterBag3Slot,
    CharacterReagentBag0Slot,
    MainMenuBarBackpackButton,
}

AB.ActionBars = {
    [MainActionBar] = "ActionButton",
    [MultiBarBottomLeft] = "MultiBarBottomLeftButton",
    [MultiBarBottomRight] = "MultiBarBottomRightButton",
    [MultiBarRight] = "MultiBarRightButton",
    [MultiBarLeft] = "MultiBarLeftButton",
    [MultiBar5] = "MultiBar5Button",
    [MultiBar6] = "MultiBar6Button",
    [MultiBar7] = "MultiBar7Button",
    [PetActionBar] = "PetActionButton",
    [StanceBar] = "StanceButton",
}

---------------------------------------------------------------------------------------------------

function AB.UpdateAlpha(frame, inCombat)
    local dbEntry = CUI.DB.profile.ActionBars[frame:GetName()]

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha, 0.2)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha, 0.2)
    end
end

function AB.UpdateBarAnchor(bar)
    local dbEntry = CUI.DB.profile.ActionBars[bar:GetName()]

    if InCombatLockdown() then return end

    local point, anchorFrame = bar:GetPoint()
    if dbEntry.ShouldAnchor and (point ~= dbEntry.AnchorPoint or anchorFrame:GetName() ~= dbEntry.AnchorFrame) then
        Util.CheckAnchorFrame(bar, dbEntry)

        bar.layoutIndex = nil
        bar:SetParent(UIParent)
        bar:SetMovable(true)
        bar:SetUserPlaced(true)
        bar:SetAttribute("ignoreFramePositionManager", true)
        bar:ClearAllPoints()
        bar:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end

    if not dbEntry.CustomPadding then return end

    local numShowable = bar.numButtonsShowable
    if numShowable == 0 then numShowable = 10 end

    local scale = _G[bar:GetName().."ButtonContainer1"]:GetScale()
    local width = _G[bar:GetName().."ButtonContainer1"]:GetWidth()
    local padding = dbEntry.Padding

    if bar.isHorizontal then
        bar:SetWidth(scale * ((math.ceil(numShowable / bar.numRows) * (width + padding)) - padding))
        bar:SetHeight(scale * ((width + padding) * bar.numRows - padding))
    else
        bar:SetHeight(scale * ((math.ceil(numShowable / bar.numRows) * (width + padding)) - padding))
        bar:SetWidth(scale * ((width + padding) * bar.numRows - padding))
    end

    for i=1, 12 do
        local container = _G[bar:GetName().."ButtonContainer"..i]
        if not container then return end

        container:ClearAllPoints()

        if bar.isHorizontal then
            Util.PositionFromIndex(i-1, container, bar, "TOPLEFT", "TOPLEFT", "RIGHT", "DOWN",
                container:GetWidth(), container:GetHeight(), dbEntry.Padding, 0, 0, math.ceil(numShowable / bar.numRows))
        else
            Util.PositionFromIndex(i-1, container, bar, "TOPLEFT", "TOPLEFT", "RIGHT", "DOWN",
                container:GetWidth(), container:GetHeight(), dbEntry.Padding, 0, 0, bar.numRows)
        end
    end
end

function AB.UpdateBar(bar)
    local dbEntry = CUI.DB.profile.ActionBars[bar:GetName()]
    local button = AB.ActionBars[bar]

    for i=1, 12 do
        local frame = _G[button..i]
        if not frame then break end

        local kb = dbEntry.Keybind
        if kb.Enabled then
            frame.TextOverlayContainer.HotKey:SetAlpha(1)
            frame.TextOverlayContainer.HotKey:SetFont(kb.Font, kb.Size, kb.Outline)
            frame.TextOverlayContainer.HotKey:ClearAllPoints()
            frame.TextOverlayContainer.HotKey:SetPoint(kb.AnchorPoint, frame, kb.AnchorRelativePoint, kb.PosX, kb.PosY)
        else
            frame.TextOverlayContainer.HotKey:SetAlpha(0)
        end

        local m = dbEntry.Macro
        if m.Enabled then
            frame.Name:SetAlpha(1)
            frame.Name:SetFont(m.Font, m.Size, m.Outline)
            frame.Name:ClearAllPoints()
            frame.Name:SetPoint(m.AnchorPoint, frame, m.AnchorRelativePoint, m.PosX, m.PosY)
        else
            frame.Name:SetAlpha(0)
        end

        local ch = dbEntry.Charges
        if ch.Enabled then
            frame.Count:SetAlpha(1)
            frame.Count:SetFont(ch.Font, ch.Size, ch.Outline)
            frame.Count:ClearAllPoints()
            frame.Count:SetPoint(ch.AnchorPoint, frame, ch.AnchorRelativePoint, ch.PosX, ch.PosY)
        else
            frame.Count:SetAlpha(0)
        end

        local cd = dbEntry.Cooldown
        if cd.Enabled then
            frame.cooldown:GetRegions():SetAlpha(1)
            local cooldown = frame.cooldown:GetRegions()
            cooldown:SetFont(cd.Font, cd.Size, cd.Outline)
            cooldown:ClearAllPoints()
            cooldown:SetPoint(cd.AnchorPoint, frame, cd.AnchorRelativePoint, cd.PosX, cd.PosY)
        else
            frame.cooldown:GetRegions():SetAlpha(0)
        end
        frame.cooldown:SetAllPoints(frame)

        frame.Border:Hide()
        frame.SlotArt:Hide()
        frame.IconMask:Hide()

        frame.SlotBackground:Hide()
        frame.SlotBackground:HookScript("OnShow", function(self)
            self:Hide()
        end)

        if frame.Arrow then
            frame.Arrow:SetDrawLayer("HIGHLIGHT")
        end

        if not frame.Background then
            local background = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
            background:SetParentKey("Background")
            background:SetAllPoints(frame)
            background:SetColorTexture(0, 0, 0, 0.5)
        end

        frame.NormalTexture:Hide()
        frame.NormalTexture:HookScript("OnShow", function(self)
            self:Hide()
        end)

        if CUI.DB.global then
            frame.icon:SetTexCoord(.08, .92, .08, .92)
        end

        if not frame.BackdropBorder then
            Util.AddBorder(frame)
        end
    end
end

---------------------------------------------------------------------------------------------------

local function StyleButtons()
    for bar, _ in pairs(AB.ActionBars) do
        AB.UpdateBar(bar)
        AB.UpdateBarAnchor(bar)
    end
end

local function AddHooks()
    for bar, button in pairs(AB.ActionBars) do
        for i=1, 12 do
            local frame = _G[button..i]
            if not frame then break end

            frame:HookScript("OnEnter", function() Util.FadeFrame(bar, "IN", 1, 0.3) end)
            frame:HookScript("OnLeave", function() AB.UpdateAlpha(bar) end)
        end

        bar:HookScript("OnEnter", function() Util.FadeFrame(bar, "IN", 1, 0.3) end)
        bar:HookScript("OnLeave", function() AB.UpdateAlpha(bar) end)

        bar:RegisterEvent("PLAYER_REGEN_ENABLED")
        bar:RegisterEvent("PLAYER_REGEN_DISABLED")
        bar:RegisterEvent("PLAYER_ENTERING_WORLD")
        bar:RegisterEvent("TRAIT_CONFIG_UPDATED")
        bar:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
        bar:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
        bar:HookScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                AB.UpdateAlpha(self)
            elseif event == "PLAYER_REGEN_DISABLED" then
                AB.UpdateAlpha(self, true)
            elseif event == "PLAYER_ENTERING_WORLD" or event == "TRAIT_CONFIG_UPDATED" or event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_PVP_TALENT_UPDATE" then
                C_Timer.After(0.1, function()
                    AB.UpdateBarAnchor(self)
                end)
            end
        end)

        AB.UpdateAlpha(bar)
    end

    EditModeManagerFrame:HookScript("OnHide", function(self)
        StyleButtons()
    end)

    MicroMenu:HookScript("OnEnter", function() Util.FadeFrame(MicroMenu, "IN", 1, 0.3) end)
    MicroMenu:HookScript("OnLeave", function() AB.UpdateAlpha(MicroMenu) end)
    for _, button in pairs(microMenuButtons) do
        button:HookScript("OnEnter", function() Util.FadeFrame(MicroMenu, "IN", 1, 0.3) end)
        button:HookScript("OnLeave", function() AB.UpdateAlpha(MicroMenu) end)
    end
    AB.UpdateAlpha(MicroMenu)

    BagsBar:HookScript("OnEnter", function() Util.FadeFrame(BagsBar, "IN", 1, 0.3) end)
    BagsBar:HookScript("OnLeave", function() AB.UpdateAlpha(BagsBar) end)
    for _, button in pairs(bagsBarButtons) do
        button:HookScript("OnEnter", function() Util.FadeFrame(BagsBar, "IN", 1, 0.3) end)
        button:HookScript("OnLeave", function() AB.UpdateAlpha(BagsBar) end)
    end
    AB.UpdateAlpha(BagsBar)
end

local function StyleXPBar()
    MainStatusTrackingBarContainer.BarFrameTexture:Hide()
    Util.AddBorder(MainStatusTrackingBarContainer)
    for _, frame in pairs({MainStatusTrackingBarContainer:GetChildren()}) do
        if frame.StatusBar then
            frame.StatusBar:SetAllPoints(MainStatusTrackingBarContainer)

            frame.StatusBar.Background:SetTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
            frame.StatusBar.Background:SetVertexColor(0, 0, 0, 1)
        end

        if frame.OverlayFrame then
            frame.OverlayFrame:SetAllPoints(MainStatusTrackingBarContainer)
            frame.OverlayFrame.Text:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 10, "")
            frame.OverlayFrame.Text:SetPoint("CENTER", MainStatusTrackingBarContainer, "CENTER", 0, -1)
        end
    end
end

---------------------------------------------------------------------------------------------------

function AB.Load()
    HideBlizzard()

    MainMenuBarVehicleLeaveButton:SetParent(UIParent)

    AddHooks()
    StyleButtons()

    StyleXPBar()
end