local addonName, CUI = ...

CUI.NP = {}
local NP = CUI.NP
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

local function UpdateAuras(unitFrame)
    for index, frame in ipairs({unitFrame.AurasFrame.DebuffListFrame:GetChildren()}) do
        frame.CountFrame.Count:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "OUTLINE")
        frame.Cooldown:GetRegions():SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "OUTLINE")

        local _, mask = frame:GetRegions()
        if mask then 
            frame.Icon:RemoveMaskTexture(mask)
        end

        if not frame.Borders then
            frame.Icon:SetTexCoord(.08, .92, .08, .92)
            Util.AddBorder(frame)
        end
    end
end

local function GetCastBarColor(castBar, blizzardCastBar)
    local color = {}

    if not blizzardCastBar.barType then 
        castBar.shouldUpdateColor = true 
        color.r = 0
        color.g = 1
        color.b = 0
        color.a = 1
        return color
    end

    castBar.shouldUpdateColor = false

    if blizzardCastBar.barType == "uninterruptable" then
        color.r = 0.9
        color.g = 0.9
        color.b = 0.9
        color.a = 1
        return color
    else
        color.r = 0.9
        color.g = 0.9
        color.b = 0
        color.a = 1
        return color
    end
end

local function UpdateCastBarColor(castBar, isChannel)
    if isChannel then
        local castBarColor = GetCastBarColor(castBar, castBar:GetParent().castBar)
        castBar.Background:SetVertexColor(castBarColor.r, castBarColor.g, castBarColor.b, castBarColor.a, 1)
        
        local v = 0.2
        castBar:SetStatusBarColor(castBarColor.r*v, castBarColor.g*v, castBarColor.b*v)
        castBar:SetReverseFill(true)
    else
        local castBarColor = GetCastBarColor(castBar, castBar:GetParent().castBar)
        castBar:SetStatusBarColor(castBarColor.r, castBarColor.g, castBarColor.b, castBarColor.a)

        local v = 0.2
        castBar.Background:SetVertexColor(castBarColor.r*v, castBarColor.g*v, castBarColor.b*v, 1)
        castBar:SetReverseFill(false)
    end
end

local function GetCastOrChannelInfo(unit)
    local nameCast, _, _, startTimeMSCast, endTimeMSCast = UnitCastingInfo(unit)
    local nameChannel, _, _, startTimeMSChannel, endTimeMSChannel = UnitChannelInfo(unit)

    if startTimeMSCast then
        return nameCast, false, startTimeMSCast, endTimeMSCast
    elseif startTimeMSChannel then
        return nameChannel, true, startTimeMSChannel, endTimeMSChannel
    else
        return nil, nil
    end
end

local function UpdateCastBar(castBar)
    local name, isChannel, startTime, endTime = GetCastOrChannelInfo(castBar.unit)

    if not startTime then 
        castBar.isCasting = false
        castBar:Hide() 
        return
    end
    
    UpdateCastBarColor(castBar, isChannel)

    castBar.Text:SetText(name, isChannel)

    local currentTime = GetTime()
    castBar:SetMinMaxValues(startTime, endTime)
    castBar:SetValue(currentTime)
    
    castBar.isCasting = true
    castBar:Show()
end

---------------------------------------------------------------------------------------------------

local function SetupNamePlate(unitToken)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unitToken)
    local unitFrame = namePlate.UnitFrame

    unitFrame.name:Hide()
    unitFrame.name:HookScript("OnShow", function(self)
        self:Hide()
    end)

    unitFrame.myHealPrediction:Hide()
    unitFrame.myHealPrediction:HookScript("OnShow", function(self)
        self:Hide()
    end)

    if not unitFrame.CUI_Name then
        local name = unitFrame:CreateFontString(nil, "OVERLAY")
        name:SetParentKey("CUI_Name")
        name:SetPoint("LEFT", unitFrame.healthBar, "LEFT", 3, 0)
        name:SetPoint("RIGHT", unitFrame.healthBar, "RIGHT", -30, 0)
        name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
        name:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 10, "")
    end
    unitFrame.CUI_Name:SetText(UnitName(unitToken))

    if not unitFrame.CUI_HealthText then
        local health = unitFrame:CreateFontString(nil, "OVERLAY")
        health:SetParentKey("CUI_HealthText")
        health:SetPoint("RIGHT", unitFrame.healthBar, "RIGHT", -3, 0)
        health:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 10, "")
    end
    unitFrame.CUI_HealthText:SetText(Util.UnitHealthPercent(unitToken))

    unitFrame.healthBar.bgTexture:Hide()
    unitFrame.healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

    if not unitFrame.healthBar.Borders then
        Util.AddBorder(unitFrame.healthBar)
    end

    unitFrame.healthBar.deselectedOverlay:Hide()

    unitFrame.healthBar.selectedBorder:HookScript("OnShow", function(self)
        self:Hide()
    end)

    if not unitFrame.CUI_Background then
        local background = unitFrame:CreateTexture(nil, "BACKGROUND")
        background:SetParentKey("CUI_Background")
        background:SetAllPoints(unitFrame.healthBar)
        background:SetColorTexture(0, 0, 0, 1)
    end

    unitFrame.AurasFrame.DebuffListFrame:ClearAllPoints()
    unitFrame.AurasFrame.DebuffListFrame:SetPoint("BOTTOMLEFT", unitFrame.HealthBarsContainer, "TOPLEFT", 0, 2)

    local blizzardCastBar = unitFrame.castBar
    blizzardCastBar:Hide()
    blizzardCastBar:HookScript("OnShow", function(self)
        self:Hide()
    end)

    if not unitFrame.CUI_CastBar then
        local castBar = CreateFrame("Statusbar", nil, unitFrame)
        castBar:SetParentKey("CUI_CastBar")
        castBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
        castBar:SetStatusBarColor(0.8, 0.8, 0, 1)
        castBar:SetPoint("TOPLEFT", unitFrame.healthBar, "BOTTOMLEFT", 0, -1)
        castBar:SetPoint("TOPRIGHT", unitFrame.healthBar, "BOTTOMRIGHT", 0, -1)
        castBar:SetHeight(10)

        Util.AddStatusBarBackground(castBar)
        Util.AddBorder(castBar)

        castBar.isCasting = false
        castBar.unit = unitToken

        local castBarText = castBar:CreateFontString(nil, "OVERLAY")
        castBarText:SetParentKey("Text")
        castBarText:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 8, "")
        castBarText:SetPoint("LEFT", castBar, "LEFT", 3, 0)

        castBar:SetScript("OnUpdate", function(self)
            if not self.isCasting then return end
            self:SetValue(GetTime() * 1000)
            if self.shouldUpdateColor then
                local _, isChannel = GetCastOrChannelInfo(castBar.unit)
                UpdateCastBarColor(castBar, isChannel)
            end
        end)
    end
    unitFrame.CUI_CastBar.unit = unitToken
    UpdateCastBar(unitFrame.CUI_CastBar)

    unitFrame:RegisterUnitEvent("UNIT_HEALTH", unitToken)
    unitFrame:RegisterUnitEvent("UNIT_AURA", unitToken)
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", unitToken)
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unitToken)
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unitToken)
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unitToken)
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unitToken)
    unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    unitFrame:HookScript("OnEvent", function(self, event, unit)
        if event == "UNIT_AURA" then
            UpdateAuras(self)
        elseif event == "UNIT_HEALTH" then
            unitFrame.CUI_HealthText:SetText(Util.UnitHealthPercent(unit))
        elseif event == "PLAYER_TARGET_CHANGED" then
            if UnitIsUnit("target", self.unit) then 
                Util.SetBorderColor(self.healthBar.Borders, 1, 1, 1, 1)
            else
                Util.SetBorderColor(self.healthBar.Borders, 0, 0, 0, 1)
            end
        elseif event == "PLAYER_FOCUS_CHANGED" then
            -- TODO
        elseif event == "UNIT_SPELLCAST_START" or 
                event == "UNIT_SPELLCAST_CHANNEL_START" or
                event == "UNIT_SPELLCAST_STOP" or
                event == "UNIT_SPELLCAST_CHANNEL_STOP" or
                event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            UpdateCastBar(self.CUI_CastBar)
        end
    end)
end

---------------------------------------------------------------------------------------------------

function NP.Load()
    local frame = CreateFrame("Frame", "CUI_NamePlateTracker", UIParent)
    frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    frame:SetScript("OnEvent", function(self, event, unitToken)
        if event == "NAME_PLATE_UNIT_ADDED" then
            SetupNamePlate(unitToken)
        end
    end)
end