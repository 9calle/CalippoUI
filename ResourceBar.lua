local addonName, CUI = ...

CUI.RB = {}
local RB = CUI.RB
local Hide = CUI.Hide
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function RB.UpdateAlpha(frame, inCombat)
    local frameName = frame:GetName()
    local dbEntry = CUI.DB.profile.ResourceBar
    if frameName == "PersonalResourceDisplayFrame" then
        dbEntry = dbEntry.PersonalResourceBar
    elseif frameName == "CUI_SecondaryPowerBar" then
        dbEntry = dbEntry.SecondaryResourceBar
    end

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
    end
end

function RB.UpdateFrame(frame)
    local dbEntry = CUI.DB.profile.ResourceBar

    frame:SetSize(dbEntry.Width, dbEntry.Height)
    frame:SetStatusBarTexture(dbEntry.Texture)
    frame.Background:SetTexture(dbEntry.Texture)

    Util.CheckAnchorFrame(frame, dbEntry)

    frame:ClearAllPoints()
    if dbEntry.MatchWidth then
        frame:SetPoint("BOTTOMLEFT", dbEntry.AnchorFrame, "TOPLEFT", 0, dbEntry.PosY)
        frame:SetPoint("BOTTOMRIGHT", dbEntry.AnchorFrame, "TOPRIGHT", 0, dbEntry.PosY)
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end
end

function RB.UpdatePersonalBar(frame)
    local dbEntry = CUI.DB.profile.ResourceBar.PersonalResourceBar

    if dbEntry.Enabled then
        if not InCombatLockdown() then
            SetCVar("nameplateShowSelf", 1)
            SetCVar("nameplateHideHealthAndPower", 1)
            SetCVar("NameplatePersonalShowAlways", 1)
        end

        Util.CheckAnchorFrame(frame, dbEntry)

        frame:ClearAllPoints()
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    else
        if not InCombatLockdown() then
            SetCVar("nameplateShowSelf", 0)
        end
    end
end

---------------------------------------------------------------------------------------------------

local function UpdatePower(frame)
    local value = UnitPower("player")

    frame:SetValue(value)
    if frame.powerType == "MANA" and CUI.DB.profile.ResourceBar.Text.ShowManaPercent then
        frame.Text:SetText(Util.UnitPowerPercent("player", frame.powerType))
    else
        frame.Text:SetText(Util.UnitPowerText("player"))
    end
end

local function UpdateMaxPower(frame)
    local _, powerType = UnitPowerType("player")
    frame.powerType = powerType

    frame:SetMinMaxValues(0, UnitPowerMax("player"))
    UpdatePower(frame)
end

local function UpdatePowerColor(frame)
    local r, g, b = Util.GetUnitPowerColor("player")
    frame:SetStatusBarColor(r, g, b)

    local v = 0.2
    frame.Background:SetVertexColor(r*v, g*v, b*v)
end

---------------------------------------------------------------------------------------------------

function RB.UpdateText(frame)
    local dbEntry = CUI.DB.profile.ResourceBar.Text

    if dbEntry.Enabled then
        frame.Text:Show()
        frame.Text:SetFont(dbEntry.Font, dbEntry.Size, dbEntry.Outline)
        frame.Text:ClearAllPoints()
        frame.Text:SetPoint(dbEntry.AnchorPoint, frame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

        UpdatePower(frame)
    else
        frame.Text:Hide()
    end
end

---------------------------------------------------------------------------------------------------

local function SortRunes(a, b)
    local startA, _, runeReadyA = GetRuneCooldown(a)
    local startB, _, runeReadyB = GetRuneCooldown(b)

    if runeReadyA and runeReadyB then
        return a < b
    end

    if runeReadyA then return true end
    if runeReadyB then return false end

    if startA and not startB then return true end
    if startB and not startA then return false end

    return startA < startB
end

local runeOrder = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
}

local function UpdateRunes(frame)
    table.sort(runeOrder, SortRunes)

    local color = frame.Power.Color
    local altColor = frame.Power.AltColor

    for i=1, frame.PowerMax do
        local powerFrame = frame.frames[i]
        local start, duration, runeReady = GetRuneCooldown(runeOrder[i])
        if runeReady then
            powerFrame:SetMinMaxValues(0, 1)
            powerFrame:SetValue(1)
            powerFrame:SetStatusBarColor(color.r, color.g, color.b)
        else
            powerFrame.duration:SetTimeFromStart(start, duration)
            powerFrame:SetTimerDuration(powerFrame.duration)
            powerFrame:SetStatusBarColor(altColor.r, altColor.g, altColor.b)
        end
    end
end

local function UpdateEssence(frame)
    local power = UnitPower("player", frame.Power.Value)
    local basePowerRegen = GetPowerRegenForPowerType(frame.Power.Value)

    local color = frame.Power.Color
    local altColor = frame.Power.AltColor

    if power > frame.LastPower or frame.LastPower == frame.PowerMax then
        frame.LastPowerTime = GetTime()
    end

    frame.LastPower = power
    for i=1, frame.PowerMax do
        local powerFrame = frame.frames[i]
        if i == power + 1 then
            powerFrame.duration:SetTimeFromStart(frame.LastPowerTime, 1/basePowerRegen)
            powerFrame:SetTimerDuration(powerFrame.duration)
            powerFrame:SetStatusBarColor(altColor.r, altColor.g, altColor.b)
        elseif i <= power then
            powerFrame:SetMinMaxValues(0, 1)
            powerFrame:SetValue(1)
            powerFrame:SetStatusBarColor(color.r, color.g, color.b)
        else
            powerFrame:SetMinMaxValues(0, 1)
            powerFrame:SetValue(0)
        end
    end
end

local function UpdateStagger(frame)
    local powerFrame = frame.frames[1]
    local stagger = UnitStagger("player")

    powerFrame:SetMinMaxValues(0, UnitHealthMax("player"))
    powerFrame:SetValue(stagger)
end

local function UpdateSoulShards(frame)
    local power = UnitPower("player", frame.Power.Value, true)
    local wholeShards = math.floor(power/10)
    local partsOfShard = power % 10

    local color = frame.Power.Color
    local altColor = frame.Power.AltColor

    for i=1, frame.PowerMax do
        local powerFrame = frame.frames[i]
        if i == wholeShards + 1 then
            powerFrame:SetValue(partsOfShard)
            powerFrame:SetStatusBarColor(altColor.r, altColor.g, altColor.b)
        elseif i <= wholeShards then
            powerFrame:SetValue(10)
            powerFrame:SetStatusBarColor(color.r, color.g, color.b)
        else
            powerFrame:SetValue(0)
        end
    end
end

local function UpdateRogueComboPoints(frame)
    local power = UnitPower("player", frame.Power.Value)
    local charged = GetUnitChargedPowerPoints("player")

    for i=1, frame.PowerMax do
        local powerFrame = frame.frames[i]
        local isCharged

        if charged then
            for j=1, #charged do
                if i == charged[j] then
                    isCharged = true
                end
            end
        else
            isCharged = false
        end

        if isCharged then
            local c = frame.Power.AltColor
            powerFrame:SetStatusBarColor(c.r, c.g, c.b)
            local v = 0.2
            powerFrame.Background:SetVertexColor(c.r*v, c.g*v, c.b*v)
        else
            local c = frame.Power.Color
            powerFrame:SetStatusBarColor(c.r, c.g, c.b)
            local v = 0.2
            powerFrame.Background:SetVertexColor(c.r*v, c.g*v, c.b*v)
        end

        if i <= power then
            powerFrame:SetValue(1)
        else
            powerFrame:SetValue(0)
        end
    end
end

local function UpdateMalestromWeapon(frame)
    -- TODO
    -- local msw = C_UnitAuras.GetPlayerAuraBySpellID(344179)
end

local function UpdateDevourer(frame)
    -- TODO
end

local function UpdateAugPower(frame)
    -- TODO
end

local function UpdateGeneric(frame)
    if frame.Power.Type == "MultiBar" then
        local power = UnitPower("player", frame.Power.Value)
        for i=1, frame.PowerMax do
            local powerFrame = frame.frames[i]
            if i <= power then
                powerFrame:SetValue(1)
            else
                powerFrame:SetValue(0)
            end
        end
    elseif frame.Power.Type == "SingleBar" then

    end
end

-- TODO : Flytta till DB och lägg till färger i config.
local powerTypes = {
    PALADIN = {
        Value = 9,
        Name = "HOLY_POWER",
        Color = {r = 1, g = 1, b = 0},
        Type = "MultiBar",
        Func = UpdateGeneric,
    },

    Brewmaster = {
        Value = nil,
        Name = "STAGGER",
        Color = {r = 0, g = 1, b = 0.6},
        Type = "SingleBar",
        Func = UpdateStagger,
    },

    Enhancement = {
        Value = nil,
        Name = "MAELSTROM_WEAPON",
        Color = {r = 0, g = 1, b = 0.6},
        Type = "SingleBar",
        Func = UpdateMalestromWeapon,
    },

    Windwalker = {
        Value = 12,
        Name = "CHI",
        Color = {r = 0, g = 1, b = 0.6},
        Type = "MultiBar",
        Func = UpdateGeneric,
    },

    ROGUE = {
        Value = 4,
        Name = "COMBO_POINTS",
        Color = {r = 0.8, g = 0, b = 0},
        AltColor = {r = 0, g = 0.8, b = 1},
        Type = "MultiBar",
        Func = UpdateRogueComboPoints,
    },

    Feral = {
        Value = 4,
        Name = "COMBO_POINTS",
        Color = {r = 0.8, g = 0, b = 0},
        Type = "MultiBar",
        Func = UpdateGeneric,
    },

    Arcane = {
        Value = 16,
        Name = "ARCANE_CHARGES",
        Color = {r = 0.25, g = 0.78, b = 0.92},
        Type = "MultiBar",
        Func = UpdateGeneric,
    },

    EVOKER = {
        Value = 19,
        Name = "ESSENCE",
        Color = {r = 0.2, g = 0.58, b = 0.5},
        AltColor ={ r = 0.12, g = 0.348, b = 0.3 },
        Type = "MultiBar",
        Func = UpdateEssence,
    },

    DEATHKNIGHT = {
        Value = 5,
        Name = "RUNES",
        Color = {r = 0.77, g = 0.12, b = 0.23},
        AltColor = {r = 0.385, g = 0.06, b = 0.115},
        Type = "MultiBar",
        Func = UpdateRunes,
    },

    WARLOCK = {
        Value = 7,
        Name = "SOUL_SHARDS",
        Color = {r = 0.53, g = 0.53, b = 0.93},
        AltColor = {r = 0.265, g = 0.265, b = 0.465},
        Type = "MultiBar",
        Func = UpdateSoulShards,
    },
}

local function UpdateSecondaryPowerFrame(frame)
    local currentSpec = GetSpecialization()
    local currentSpecName
    if currentSpec then
         _, currentSpecName = GetSpecializationInfo(currentSpec)
    end

    local _, class = UnitClass("player")
    local powerType = powerTypes[class]
    if not powerType then
        powerType = powerTypes[currentSpecName]
        if not powerType then
            frame.Power = {}
            frame.Power.PowerType = nil
            for i=1, #frame.frames do
                frame.frames[i]:Hide()
            end
            return
        else
            frame.Power = powerType
            frame.ClassSpec = currentSpecName
            frame.PowerMax = UnitPowerMax("player" , powerType.Value)
        end
    else
        frame.Power = powerType
        frame.ClassSpec = class
        frame.PowerMax = UnitPowerMax("player" , powerType.Value)
     end

     if frame.PowerMax == 0 then
        C_Timer.After(1, function()
            UpdateSecondaryPowerFrame(frame)
        end)
        return
    end

    local dbEntry = CUI.DB.profile.ResourceBar.SecondaryResourceBar
    local height = dbEntry.Height

    local width
    if dbEntry.MatchWidth then
        width = _G[dbEntry.AnchorFrame]:GetWidth()
    else
        width = dbEntry.Width
    end

    local color = frame.Power.Color

    if frame.Power.Type == "MultiBar" then
        local padding = dbEntry.Padding
        local frameWidth = (width/frame.PowerMax) - padding + (padding/frame.PowerMax)
        for i=1, #frame.frames do
            local powerFrame = frame.frames[i]
            if i > frame.PowerMax then
                powerFrame:Hide()
            else
                powerFrame:Show()
                powerFrame:SetSize(frameWidth, height)
                powerFrame:SetStatusBarColor(color.r, color.g, color.b)
                powerFrame.Background:SetVertexColor(color.r*0.2, color.g*0.2, color.b*0.2)
                if frame.Power.Name == "SOUL_SHARDS" then
                    powerFrame:SetMinMaxValues(0, 10)
                else
                    powerFrame:SetMinMaxValues(0, 1)
                end
                Util.PositionFromIndex(i-1, powerFrame, frame, "TOPLEFT", "TOPLEFT", "RIGHT", "DOWN", frameWidth, height, padding, 0, 0, 123)
            end
        end

        if frame.Power.Name == "RUNES" then
            frame:RegisterEvent("RUNE_POWER_UPDATE")
            frame:UnregisterEvent("UNIT_POWER_UPDATE")
        elseif frame.Power.Name == "ESSENCE" then
            frame.LastPower = UnitPower("player", frame.Power.Value)
            frame.LastPowerTime = GetTime()
        elseif frame.Power.Name == "COMBO_POINTS" then
            frame:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player")
        end
    elseif frame.Power.Type == "SingleBar" then
        for i=1, #frame.frames do
            local powerFrame = frame.frames[i]
            if i == 1 then
                powerFrame:Show()
                powerFrame:SetSize(width, height)
                powerFrame:SetPoint("TOPLEFT")
                powerFrame:SetStatusBarColor(color.r, color.g, color.b)
                powerFrame.Background:SetVertexColor(color.r*0.2, color.g*0.2, color.b*0.2)
                powerFrame:SetMinMaxValues(0, 1)
                powerFrame:SetValue(1)
            else
                powerFrame:Hide()
            end
        end

        if frame.Power.Name == "MAELSTROM_WEAPON" then
            frame:RegisterUnitEvent("UNIT_AURA", "player")
            frame:UnregisterEvent("UNIT_POWER_UPDATE")
        end
    end

    frame.Power.Func(frame)
end

function RB.UpdateSecondaryPowerBar(frame)
    local dbEntry = CUI.DB.profile.ResourceBar.SecondaryResourceBar

    if dbEntry.Enabled then
        frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        frame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")

        Util.CheckAnchorFrame(secondaryPowerContainer, dbEntry)

        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

        if dbEntry.MatchWidth then
            frame:SetSize(_G[dbEntry.AnchorFrame]:GetWidth(), dbEntry.Height)
        else
            frame:SetSize(dbEntry.Width, dbEntry.Height)
        end

        for i=1, #frame.frames do
            local powerFrame = frame.frames[i]
            powerFrame:SetStatusBarTexture(dbEntry.Texture)
            powerFrame.Background:SetTexture(dbEntry.Texture)
        end

        UpdateSecondaryPowerFrame(frame)
    else
        frame:UnregisterAllEvents()
        for i=1, #frame.frames do
            frame.frames[i]:Hide()
        end
    end
end

---------------------------------------------------------------------------------------------------

local powerBar = CreateFrame("Statusbar", "CUI_PowerBar", UIParent)

local function SetupPowerBar()
    powerBar:SetStatusBarTexture(CUI.DB.profile.ResourceBar.Texture)

    local _, powerType = UnitPowerType("player")
    powerBar.PowerType = powerType

    Util.AddStatusBarBackground(powerBar)
    Util.AddBorder(powerBar)

    RB.UpdateFrame(powerBar)

    local text = powerBar:CreateFontString(nil, "OVERLAY")
    text:SetParentKey("Text")

    RB.UpdateText(powerBar)

    C_Timer.After(0.5, function()
        UpdateMaxPower(powerBar)
        UpdatePowerColor(powerBar)
    end)

    powerBar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    powerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    powerBar:RegisterEvent("PLAYER_REGEN_ENABLED")
    powerBar:RegisterEvent("PLAYER_REGEN_DISABLED")
    powerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    powerBar:SetScript("OnEvent", function(self, event, unit, powerType)
        if event == "UNIT_POWER_UPDATE" then
            if self.PowerType == powerType then
                UpdatePower(self)
            end
        elseif event == "UNIT_MAXPOWER" then
            UpdateMaxPower(self)
        elseif event == "PLAYER_REGEN_ENABLED" then
            RB.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            RB.UpdateAlpha(self, true)
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function()
                local _, powerType = UnitPowerType("player")
                self.PowerType = powerType
                UpdateMaxPower(self)
                UpdatePowerColor(self)
            end)
        end
    end)

    RB.UpdateAlpha(powerBar)
end

local function SetupSecondaryPowerBar()
    local dbEntry = CUI.DB.profile.ResourceBar.SecondaryResourceBar
    Util.CheckAnchorFrame(secondaryPowerContainer, dbEntry)

    local secondaryPowerContainer = CreateFrame("Frame", "CUI_SecondaryPowerBar", UIParent)
    secondaryPowerContainer.frames = {}

    for i=1, 7 do
        local frame = CreateFrame("StatusBar", nil, secondaryPowerContainer)
        frame:SetStatusBarTexture(dbEntry.Texture)
        frame:SetMinMaxValues(0, 1)
        Util.AddStatusBarBackground(frame)
        frame.Background:SetTexture(dbEntry.Texture)
        Util.AddBorder(frame)
        frame:Hide()
        frame.duration = C_DurationUtil.CreateDuration()
        frame.Index = i
        table.insert(secondaryPowerContainer.frames, frame)
    end

    secondaryPowerContainer:SetScript("OnEvent", function(self, event, _, powerType)
        if event == "UNIT_POWER_UPDATE" then
            if self.Power.Name == powerType then
                self.Power.Func(self)
            end
        elseif event == "UNIT_AURA" then
            self.Power.Func()
        elseif event == "RUNE_POWER_UPDATE" then
            UpdateRunes(self)
        elseif event == "UNIT_POWER_POINT_CHARGE" then
            self.Power.Func(self)
        elseif event == "UNIT_MAXPOWER" then
            if self.Power.Name == powerType then
                UpdateSecondaryPowerFrame(self)
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            RB.UpdateAlpha(self, true)
        elseif event == "PLAYER_REGEN_ENABLED" then
            RB.UpdateAlpha(self)
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function() UpdateSecondaryPowerFrame(self) end)
        end
    end)

    if dbEntry.MatchWidth then
        _G[dbEntry.AnchorFrame]:HookScript("OnSizeChanged", function(self, width)
            CUI_SecondaryPowerBar:SetWidth(_G[dbEntry.AnchorFrame]:GetWidth())
            UpdateSecondaryPowerFrame(CUI_SecondaryPowerBar)
        end)
    end

    RB.UpdateAlpha(secondaryPowerContainer)
    RB.UpdateSecondaryPowerBar(secondaryPowerContainer)
end

local function SetupPersonalResourceBar()
    if CUI.DB.profile.ResourceBar.PersonalResourceBar.Enabled then
        SetCVar("nameplateShowSelf", 1)
        SetCVar("nameplateHideHealthAndPower", 1)
        SetCVar("NameplatePersonalShowAlways", 1)
    else
        SetCVar("nameplateShowSelf", 0)
    end

    PersonalResourceDisplayFrame:SetSize(10, 10)

    Hide.HideFrame(PersonalResourceDisplayFrame.PowerBar)
    Hide.HideFrame(PersonalResourceDisplayFrame.HealthBarsContainer)
    Hide.HideFrame(PersonalResourceDisplayFrame.AlternatePowerBar)

    RB.UpdatePersonalBar(PersonalResourceDisplayFrame)

    EditModeManagerFrame:HookScript("OnHide", function(self)
        RB.UpdatePersonalBar(PersonalResourceDisplayFrame)
    end)

    PersonalResourceDisplayFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    PersonalResourceDisplayFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    PersonalResourceDisplayFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    PersonalResourceDisplayFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    PersonalResourceDisplayFrame:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function() RB.UpdatePersonalBar(self) end)
        elseif event == "PLAYER_REGEN_ENABLED" then
            RB.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            RB.UpdateAlpha(self, true)
        end
    end)

    if not prdClassFrame then return end

    local _, class = UnitClass("player")
    prdClassFrame:ClearAllPoints()
    if class == "PALADIN" then
        prdClassFrame:SetPoint("BOTTOM", PersonalResourceDisplayFrame, "BOTTOM", 0, -7)
    else
        prdClassFrame:SetPoint("BOTTOM", PersonalResourceDisplayFrame, "BOTTOM", 0, 1)
    end

    RB.UpdateAlpha(PersonalResourceDisplayFrame)
end

---------------------------------------------------------------------------------------------------

function RB.Load()
    SetupPowerBar()
    SetupPersonalResourceBar()
    SetupSecondaryPowerBar()
end