local addonName, CUI = ...

CUI.UF = {}
local UF = CUI.UF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

function HideBlizzard()
    Hide.UnregisterChildren(PlayerFrame)
    Hide.HideFrame(PlayerFrame)

    Hide.UnregisterChildren(TargetFrame)
    Hide.HideFrame(TargetFrame)

    Hide.UnregisterChildren(FocusFrame)
    Hide.HideFrame(FocusFrame)

    Hide.UnregisterChildren(PetFrame)
    Hide.HideFrame(PetFrame)

    Hide.UnregisterChildren(Boss1TargetFrame)
    Hide.HideFrame(Boss1TargetFrame, true)

    Hide.UnregisterChildren(Boss2TargetFrame)
    Hide.HideFrame(Boss2TargetFrame, true)

    Hide.UnregisterChildren(Boss3TargetFrame)
    Hide.HideFrame(Boss3TargetFrame, true)

    Hide.UnregisterChildren(Boss4TargetFrame)
    Hide.HideFrame(Boss4TargetFrame, true)

    Hide.UnregisterChildren(Boss5TargetFrame)
    Hide.HideFrame(Boss5TargetFrame, true)

    Hide.UnregisterChildren(BossTargetFrameContainer)
    Hide.HideFrame(BossTargetFrameContainer)
end

---------------------------------------------------------------------------------------------------

local function UpdateBossFrameAlpha()
    for i=1, 5 do
        UF.UpdateAlpha(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrames()
    for i=1, 5 do
        UF.UpdateFrame(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrameTexts()
    for i=1, 5 do
        UF.UpdateTexts(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrameCastBarFrame()
    for i=1, 5 do
        UF.UpdateCastBarFrame(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrameCastBarTexts()
    for i=1, 5 do
        UF.UpdateCastBarTexts(_G["CUI_BossFrame"..i])
    end
end

---------------------------------------------------------------------------------------------------

function UF.ToggleBossTest(active)
    for i=1, 5 do
        local frame = _G["CUI_BossFrame"..i]

        local unit
        if active then
            unit = "player"
            frame:SetAttribute("unit", unit)
            frame.unit = unit
            frame.CastBar.unit = unit
        else
            unit = "boss"..i
            frame:SetAttribute("unit", unit)
            frame.unit = unit
            frame.CastBar.unit = unit
        end

        UF.UpdateAuras(frame)

        frame:RegisterUnitEvent("UNIT_AURA", unit)
        frame:RegisterUnitEvent("UNIT_HEALTH", unit)
        frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
        frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
        frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)

        local castBar = frame.CastBar
        if CUI.DB.profile.UnitFrames.BossFrame.CastBar.Enabled then
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
        else
            castBar:UnregisterAllEvents()
        end
    end
end

function UF.UpdateAlpha(frame, inCombat)
    if frame == "BossFrame" then UpdateBossFrameAlpha() return end
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
    end
end

function UF.UpdateTexts(frame)
    if frame == "BossFrame" then UpdateBossFrameTexts() return end

    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]
    frame.Overlay.UnitName:SetWidth(dbEntry.Name.Width)

    if dbEntry.Name.Enabled then
        frame.Overlay.UnitName:Show()
        frame.Overlay.UnitName:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
        frame.Overlay.UnitName:ClearAllPoints()
        frame.Overlay.UnitName:SetPoint(dbEntry.Name.AnchorPoint, frame.Overlay, dbEntry.Name.AnchorRelativePoint,
            dbEntry.Name.PosX, dbEntry.Name.PosY)
    else
        frame.Overlay.UnitName:Hide()
    end

    if dbEntry.HealthText.Enabled then
        frame.Overlay.UnitHealth:Show()
        frame.Overlay.UnitHealth:SetFont(dbEntry.HealthText.Font, dbEntry.HealthText.Size, dbEntry.HealthText.Outline)
        frame.Overlay.UnitHealth:ClearAllPoints()
        frame.Overlay.UnitHealth:SetPoint(dbEntry.HealthText.AnchorPoint, frame.Overlay, dbEntry.HealthText.AnchorRelativePoint,
            dbEntry.HealthText.PosX, dbEntry.HealthText.PosY)
    else
        frame.Overlay.UnitHealth:Hide()
    end
end

function UF.UpdateCastBarFrame(frame)
    if frame == "BossFrame" then UpdateBossFrameCastBarFrame() return end

    local dbEntryUF = CUI.DB.profile.UnitFrames
    local dbEntry = dbEntryUF[frame.name].CastBar
    local castBarContainer = frame.CastBar
    local castBar = castBarContainer.Bar

    if frame.name == "BossFrame" then dbEntry.AnchorFrame = frame:GetName() end

    castBarContainer:SetSize(dbEntry.Width, dbEntry.Height)

    if dbEntry.ShowIcon then
        castBarContainer.IconContainer:Show()
        castBarContainer.IconContainer:SetWidth(dbEntry.Height)
        castBar:SetPoint("TOPLEFT", castBarContainer.IconContainer, "TOPRIGHT")
    else
        castBarContainer.IconContainer:Hide()
        castBar:SetPoint("TOPLEFT", castBarContainer, "TOPLEFT")
    end

    castBar:SetStatusBarTexture(dbEntryUF.CastBar.Texture)
    castBar.Background:SetTexture(dbEntryUF.CastBar.Texture)

    Util.CheckAnchorFrame(castBarContainer, dbEntry)
    castBarContainer:ClearAllPoints()
    if dbEntry.MatchWidth then
        castBarContainer:SetPoint("TOPLEFT", dbEntry.AnchorFrame, "BOTTOMLEFT", 0, dbEntry.PosY)
        castBarContainer:SetPoint("TOPRIGHT", dbEntry.AnchorFrame, "BOTTOMRIGHT", 0, dbEntry.PosY)
    else
        castBarContainer:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end

    if dbEntry.Enabled then
        local unit = frame.unit
        castBarContainer:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
        castBarContainer:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
        castBarContainer:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
        castBarContainer:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
        castBarContainer:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
        castBarContainer:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
        castBarContainer:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
        if unit == "focus" then
            castBarContainer:RegisterEvent("PLAYER_FOCUS_CHANGED")
        elseif unit == "target" then
            castBarContainer:RegisterEvent("PLAYER_TARGET_CHANGED")
        end
    else
        castBarContainer:Hide()
        castBarContainer:UnregisterAllEvents()
    end
end

function UF.UpdateCastBarTexts(frame)
    if frame == "BossFrame" then UpdateBossFrameCastBarTexts() return end

    local dbEntryUF = CUI.DB.profile.UnitFrames.CastBar
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name].CastBar
    local name = frame.CastBar.Bar.Name
    local time = frame.CastBar.Bar.Time

    name:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
    local c = dbEntryUF.NameColor
    name:SetTextColor(c.r, c.g, c.b, c.a)
    name:SetPoint(dbEntry.Name.AnchorPoint, frame.CastBar.Bar, dbEntry.Name.AnchorRelativePoint, dbEntry.Name.PosX, dbEntry.Name.PosY)
    name:SetWidth(dbEntry.Name.Width)

    time:SetFont(dbEntry.Time.Font, dbEntry.Time.Size, dbEntry.Time.Outline)
    c = dbEntryUF.TimeColor
    time:SetTextColor(c.r, c.g, c.b, c.a)
    time:SetPoint(dbEntry.Time.AnchorPoint, frame.CastBar.Bar, dbEntry.Time.AnchorRelativePoint, dbEntry.Time.PosX, dbEntry.Time.PosY)
end

---------------------------------------------------------------------------------------------------

local DEBUFF_DISPLAY_COLOR_INFO = {
    [0] = CreateColor(0, 0, 0, 1),
    [1] = DEBUFF_TYPE_MAGIC_COLOR,
    [2] = DEBUFF_TYPE_CURSE_COLOR,
    [3] = DEBUFF_TYPE_DISEASE_COLOR,
    [4] = DEBUFF_TYPE_POISON_COLOR,
    [9] = DEBUFF_TYPE_BLEED_COLOR,
    [11] = DEBUFF_TYPE_BLEED_COLOR,
}

local dispelColorCurve = C_CurveUtil.CreateColorCurve()
dispelColorCurve:SetType(Enum.LuaCurveType.Step)

for i, c in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
    dispelColorCurve:AddPoint(i, c)
end

local function UpdateBossFrameAuras()
    for i=1, 5 do
        UF.UpdateAuras(_G["CUI_BossFrame"..i])
    end
end

local buffFilter = "HELPFUL"
local debuffFilter = "HARMFUL"
local debuffFilterPlayerOnly = "PLAYER|HARMFUL"

local function IterateAuras(frame, auraTable, pool, type)
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name][type]
    local anchorPoint = dbEntry.AnchorPoint
    local anchorRelativePoint = dbEntry.AnchorRelativePoint
    local dirH = dbEntry.DirH
    local dirV = dbEntry.DirV
    local size = dbEntry.Size
    local padding = dbEntry.Padding
    local posX = dbEntry.PosX
    local posY = dbEntry.PosY
    local rowLength = dbEntry.RowLength
    local maxShown = dbEntry.MaxShown

    local stacksEnabled = dbEntry.Stacks.Enabled
    local stacksAP = dbEntry.Stacks.AnchorPoint
    local stacksARP = dbEntry.Stacks.AnchorRelativePoint
    local stacksPX = dbEntry.Stacks.PosX
    local stacksPY = dbEntry.Stacks.PosY
    local stacksFont = dbEntry.Stacks.Font
    local stacksOutline = dbEntry.Stacks.Outline
    local stacksSize = dbEntry.Stacks.Size

    pool:ReleaseAll()

    local index = 0
	for id, aura in pairs(auraTable) do
        if index >= maxShown then return end

        local auraFrame = pool:Acquire()
        auraFrame:Show()

        auraFrame.unit = frame.unit
        auraFrame.type = type
        auraFrame.showTooltip = true
        auraFrame.auraInstanceID = id

        auraFrame:SetSize(size, size)

        local c = aura.borderColor
        auraFrame.Overlay.Backdrop:SetBackdropBorderColor(c.r, c.g, c.b, c.a)

        auraFrame.Icon:SetTexture(aura.icon)
        auraFrame.Icon:SetTexCoord(.08, .92, .08, .92)

        local stacksFrame = auraFrame.Overlay.Count
        if stacksEnabled then
            stacksFrame:Show()
            stacksFrame:ClearAllPoints()
            stacksFrame:SetPoint(stacksAP, auraFrame.Overlay, stacksARP, stacksPX, stacksPY)
            stacksFrame:SetFont(stacksFont, stacksSize, stacksOutline)
            stacksFrame:SetText(C_StringUtil.TruncateWhenZero(aura.applications))
        else
            stacksFrame:Hide()
        end

        auraFrame.Cooldown:SetCooldownFromExpirationTime(aura.expirationTime, aura.duration)

        Util.PositionFromIndex(index, auraFrame, frame, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        index = index + 1
	end
end

local function ProcessAura(unit, aura)
    if not aura then return end

    local color = C_UnitAuras.GetAuraDispelTypeColor(unit, aura.auraInstanceID, dispelColorCurve)

    if color then
        aura.borderColor = color
    else
        aura.borderColor = CreateColor(0, 0, 0, 1)
    end
end

local function AddAllAuras(frame)
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]
    local unit = frame.unit
    table.wipe(frame.buffs)
    table.wipe(frame.debuffs)

    local function AddBuff(aura)
        ProcessAura(unit, aura)
		frame.buffs[aura.auraInstanceID] = aura
	end

    local function AddDebuff(aura)
        ProcessAura(unit, aura)
        frame.debuffs[aura.auraInstanceID] = aura
	end

    if dbEntry.Buffs.Enabled then
	    AuraUtil.ForEachAura(unit, buffFilter, nil, AddBuff, true)
    end

    if dbEntry.Debuffs.Enabled then
        if UnitIsFriend("player", unit) then
            AuraUtil.ForEachAura(unit, debuffFilter, nil, AddDebuff, true)
        else
            AuraUtil.ForEachAura(unit, debuffFilterPlayerOnly, nil, AddDebuff, true)
        end
    end
end

function UF.UpdateAuras(frame, updateInfo)
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]
    local buffsEnabled = dbEntry.Buffs.Enabled
    local debuffsEnabled = dbEntry.Debuffs.Enabled
    local unit = frame.unit
	local buffsChanged = false
    local debuffsChanged = false

    if not buffsEnabled and not debuffsEnabled then return end

    if not updateInfo or updateInfo.isFullUpdate then
        AddAllAuras(frame)
        buffsChanged = true
        debuffsChanged = true
    else
        if updateInfo.addedAuras then
            for i=1, #updateInfo.addedAuras do
                local aura = updateInfo.addedAuras[i]
                if buffsEnabled and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, buffFilter) then
                    ProcessAura(unit, aura)
                    frame.buffs[aura.auraInstanceID] = aura
                    buffsChanged = true
                elseif debuffsEnabled then
                    if UnitIsFriend("player", unit) then
                        if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, debuffFilter) then
                            ProcessAura(unit, aura)
                            frame.debuffs[aura.auraInstanceID] = aura
                            debuffsChanged = true
                        end
                    else
                        if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, debuffFilterPlayerOnly) then
                            ProcessAura(unit, aura)
                            frame.debuffs[aura.auraInstanceID] = aura
                            debuffsChanged = true
                        end
                    end
                end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            for i=1, #updateInfo.updatedAuraInstanceIDs do
                local id = updateInfo.updatedAuraInstanceIDs[i]
				if frame.buffs[id] then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id)
                    ProcessAura(unit, newAura)
                    frame.buffs[id] = newAura
                    buffsChanged = true
                elseif frame.debuffs[id] then
                    local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id)
                    ProcessAura(unit, newAura)
                    frame.debuffs[id] = newAura
                    debuffsChanged = true
				end 
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for i=1, #updateInfo.removedAuraInstanceIDs do
                local id = updateInfo.removedAuraInstanceIDs[i]
                if frame.buffs[id] then
                    frame.buffs[id] = nil
                    buffsChanged = true
                elseif frame.debuffs[id] then
                    frame.debuffs[id] = nil
                    debuffsChanged = true
                end
            end
        end
    end

    if buffsChanged then
        IterateAuras(frame, frame.buffs, frame.buffPool, "Buffs")
    end

    if debuffsChanged then
        IterateAuras(frame, frame.debuffs, frame.debuffPool, "Debuffs")
    end
end

---------------------------------------------------------------------------------------------------

local function UpdateTextColor(frame)
    local dbEntry = CUI.DB.profile.UnitFrames.Name

    if dbEntry.CustomColor then
        local c = dbEntry.Color
        frame.Overlay.UnitName:SetTextColor(c.r, c.g, c.b, c.a)
        frame.Overlay.UnitHealth:SetTextColor(c.r, c.g, c.b, c.a)
    else
        frame.Overlay.UnitName:SetTextColor(Util.GetUnitColor(frame.unit))
        frame.Overlay.UnitHealth:SetTextColor(Util.GetUnitColor(frame.unit))
    end
end

local function UpdateHealthColor(frame)
    local dbEntry = CUI.DB.profile.UnitFrames

    if frame.dead then
        local dc = dbEntry.HealthBar.DeadColor
        frame.HealthBar:SetStatusBarColor(dc.r, dc.g, dc.b, dc.a)
    elseif dbEntry.HealthBar.CustomColor then
        local hc = dbEntry.HealthBar.Color
        frame.HealthBar:SetStatusBarColor(hc.r, hc.g, hc.b, hc.a)

        local bc = dbEntry.HealthBar.BackgroundColor
        frame.Background:SetVertexColor(bc.r, bc.g, bc.b, bc.a)

        local hpc = dbEntry.HealthBar.HealPredictionColor
        frame.HealPredictionBar:SetStatusBarColor(hpc.r, hpc.g, hpc.b, hpc.a)
    else
        local r, g, b = Util.GetUnitColor(frame.unit)
        frame.HealthBar:SetStatusBarColor(r, g, b)

        local v = 0.2
        frame.Background:SetVertexColor(r*v, g*v, b*v)

        local v2 = 0.5
        frame.HealPredictionBar:SetStatusBarColor(r*v2, g*v2, b*v2)
    end
end

local function UpdateAbsorbColor(frame)
    local dbEntry = CUI.DB.profile.UnitFrames

    local hac = dbEntry.HealAbsorbBar.Color
    frame.HealAbsorbBar:SetStatusBarColor(hac.r, hac.g, hac.b, hac.a)

    local dac = dbEntry.DamageAbsorbBar.Color
    frame.DamageAbsorbBar:SetStatusBarColor(dac.r, dac.g, dac.b, dac.a)
end

local function UpdatePowerColor(frame)
    local r, g, b = Util.GetUnitPowerColor(frame.unit)
    frame.PowerBar:SetStatusBarColor(r, g, b)

    local v = 0.2
    frame.PowerBar.Background:SetVertexColor(r*v, g*v, b*v)
end

local function UpdateDamageAbsorb(frame)
    local shieldAbsorb = UnitGetTotalAbsorbs(frame.unit)
    frame.DamageAbsorbBar:SetValue(shieldAbsorb)
end

local function UpdateHealAbsorb(frame)
    UnitGetDetailedHealPrediction(frame.unit, "player", frame.calc)
    local healAbsorb = frame.calc:GetHealAbsorbs()
    frame.HealAbsorbBar:SetValue(healAbsorb)
end

local function UpdateHealPrediction(frame)
    UnitGetDetailedHealPrediction(frame.unit, "player", frame.calc)
    local incoming = frame.calc:GetIncomingHeals()
    frame.HealPredictionBar:SetMinMaxValues(0, UnitHealthMissing(frame.unit))
    frame.HealPredictionBar:SetValue(incoming)
end

local function UpdateHealth(frame)
    local unit = frame.unit

    frame.Overlay.UnitHealth:SetText(AbbreviateNumbers(UnitHealth(unit)))
    frame.HealthBar:SetValue(UnitHealth(unit))
end

local function UpdateMaxHealth(frame)
    local unit = frame.unit
    local maxHealth = UnitHealthMax(frame.unit)
    local health = UnitHealth(frame.unit)

    frame.Overlay.UnitHealth:SetText(AbbreviateNumbers(UnitHealth(unit)))
    frame.HealthBar:SetMinMaxValues(0, maxHealth)
    frame.HealthBar:SetValue(health)

    frame.HealAbsorbBar:SetMinMaxValues(0, maxHealth)
    UpdateHealAbsorb(frame)
    frame.DamageAbsorbBar:SetMinMaxValues(0, maxHealth)
    UpdateDamageAbsorb(frame)
end

local function UpdatePower(frame)
    frame.PowerBar:SetValue(UnitPower(frame.unit))
end

local function UpdateMaxPower(frame)
    local unit = frame.unit

    frame.PowerBar:SetMinMaxValues(0, UnitPowerMax(unit))
    frame.PowerBar:SetValue(UnitPower(unit))
end

local function UpdateName(frame)
    frame.Overlay.UnitName:SetText(UnitName(frame.unit))
end

local function UpdateIsDead(frame)
    if UnitIsDeadOrGhost(frame.unit) then
        local _, max = frame.HealthBar:GetMinMaxValues()
        frame.HealthBar:SetValue(max)
        frame.dead = true
        UpdateHealthColor(frame)
    elseif frame.dead == true then
        frame.dead = false
        UpdateHealthColor(frame)
    end
end

local function UpdateLeaderAssist(frame)
    if not frame.Overlay.LeaderIcon then return end

    local dbEntry = CUI.DB.profile.UnitFrames[frame.name].LeaderIcon
    if not dbEntry.Enabled then frame.Overlay.LeaderIcon:Hide() return end

    local leaderFrame = frame.Overlay.LeaderIcon
    local unit = frame.unit

    if UnitIsGroupLeader(unit) then
        leaderFrame:SetAtlas("UI-HUD-UnitFrame-Player-Group-LeaderIcon")
        leaderFrame:Show()
    elseif UnitIsGroupAssistant(unit) then
        leaderFrame:SetAtlas("UI-HUD-UnitFrame-Player-Group-GuideIcon")
        leaderFrame:Show()
    else
        leaderFrame:Hide()
    end
end

local function UpdateAll(frame)
    UpdateMaxHealth(frame)
    UpdateMaxPower(frame)
    UpdateName(frame)
    UpdateLeaderAssist(frame)
    UpdateHealPrediction(frame)
    UpdateIsDead(frame)

    UpdateHealthColor(frame)
    UpdateAbsorbColor(frame)
    UpdatePowerColor(frame)
    UpdateTextColor(frame)

    UF.UpdateAlpha(frame)
end

-------------------------------------------------------------------------------------------------

local frames = {}

function UF.UpdateAllFrames()
    for i=1, #frames do
        local frame = frames[i]
        UpdateTextColor(frame)
        UpdateHealthColor(frame)
        UpdateAbsorbColor(frame)
        UF.UpdateCastBarTexts(frame)
        UF.UpdateCastBarFrame(frame)
        UF.UpdateFrame(frame)
    end
end

function UF.UpdateFrame(frame)
    if frame == "BossFrame" then UpdateBossFrames() return end

    local dbEntryUF = CUI.DB.profile.UnitFrames
    local dbEntry = dbEntryUF[frame.name]

    Util.CheckAnchorFrame(frame, dbEntry)

    frame:ClearAllPoints()
    if frame.name == "BossFrame" then
        if frame.number == 1 then
            frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
        else
            frame:SetPoint("TOPLEFT", "CUI_BossFrame"..(frame.number-1), "BOTTOMLEFT", 0, -dbEntry.Padding)
        end
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    frame.HealthBar:SetStatusBarTexture(dbEntryUF.HealthBar.Texture)
    frame.Background:SetTexture(dbEntryUF.HealthBar.Texture)
    frame.HealPredictionBar:SetStatusBarTexture(dbEntryUF.HealthBar.Texture)
    frame.DamageAbsorbBar:SetStatusBarTexture(dbEntryUF.DamageAbsorbBar.Texture)
    frame.HealAbsorbBar:SetStatusBarTexture(dbEntryUF.HealAbsorbBar.Texture)

    if dbEntry.PowerBar.Enabled then
        frame.PowerBar:Show()
        frame.PowerBar:SetHeight(dbEntry.PowerBar.Height)
        frame.PowerBar:SetStatusBarTexture(dbEntryUF.PowerBar.Texture)
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame.PowerBar, "TOPRIGHT")
        frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", frame.unit)
        frame:RegisterUnitEvent("UNIT_MAXPOWER", frame.unit)
    else
        frame.PowerBar:Hide()
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
        frame:UnregisterEvent("UNIT_POWER_FREQUENT")
        frame:UnregisterEvent("UNIT_MAXPOWER")
    end

    local leaderIcon = frame.Overlay.LeaderIcon
    if leaderIcon then
        local dbEntryLead = dbEntry.LeaderIcon
        if dbEntryLead.Enabled then
            UpdateLeaderAssist(frame)
            leaderIcon:ClearAllPoints()
            leaderIcon:SetPoint(dbEntryLead.AnchorPoint, frame.Overlay, dbEntryLead.AnchorRelativePoint, dbEntryLead.PosX, dbEntryLead.PosY)
            leaderIcon:SetSize(dbEntryLead.Size, dbEntryLead.Size)
        else
            leaderIcon:Hide()
        end
    end
end

-------------------------------------------------------------------------------------------------

local function GetCastingOrChannelInfo(unit)
    local name

    name = UnitCastingInfo(unit)
    if name then return false, false end

    local isEmpower
    name, _, _, _, _, _, _, _, _, isEmpower = UnitChannelInfo(unit)
    if name then return true, isEmpower end
end

local function UpdateCastBar(castBarContainer, isChannel, isEmpower)
    local duration, name, icon, notInterruptible
    local castBar = castBarContainer.Bar
    local unit = castBarContainer.unit

    if isChannel == nil then
        isChannel, isEmpower = GetCastingOrChannelInfo(unit)
    end

    if isChannel or isEmpower then
        name, _, icon, _, _, _, notInterruptible = UnitChannelInfo(unit)
        duration = UnitChannelDuration(unit)
    else
        name, _, icon, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
        duration = UnitCastingDuration(unit)
    end

    if not duration then castBarContainer:Hide() return end

    castBarContainer.IconContainer.Icon:SetTexture(icon)
    castBar.Name:SetText(name)

    local dbEntry = CUI.DB.profile.UnitFrames.CastBar
    local color = dbEntry.Color
    local colorNotInt = dbEntry.ColorNotInterruptiple

    castBar:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible,
        CreateColor(colorNotInt.r, colorNotInt.g, colorNotInt.b), CreateColor(color.r, color.g, color.b))

    castBar.Background:SetVertexColorFromBoolean(notInterruptible,
        CreateColor(colorNotInt.r*0.2, colorNotInt.g*0.2, colorNotInt.b*0.2), CreateColor(color.r*0.2, color.g*0.2, color.b*0.2))

    local direction
    if isChannel then
        direction = 1
    else
        direction = 0
    end

    castBar:SetTimerDuration(duration, 0, direction)

    if castBarContainer.Ticker then castBarContainer.Ticker:Cancel() end
    castBarContainer.Ticker = C_Timer.NewTicker(0.1, function()
        castBar.Time:SetText(string.format("%.1f", duration:GetRemainingDuration()))
    end)

    castBarContainer:Show()
end

function SetupCastBar(unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name].CastBar
    local unit = unitFrame.unit

    local castBarContainer = CreateFrame("Frame", nil, unitFrame)
    castBarContainer:SetParentKey("CastBar")
    castBarContainer:Hide()

    castBarContainer.name = unitFrame.name
    castBarContainer.unit = unit

    local iconContainer = CreateFrame("Frame", nil, castBarContainer)
    iconContainer:SetParentKey("IconContainer")
    iconContainer:SetPoint("TOPLEFT", castBarContainer, "TOPLEFT")
    iconContainer:SetPoint("BOTTOMLEFT", castBarContainer, "BOTTOMLEFT")
    Util.AddBorder(iconContainer)

    local icon = iconContainer:CreateTexture(nil, "ARTWORK")
    icon:SetParentKey("Icon")
    icon:SetAllPoints(iconContainer)
    icon:SetTexCoord(.08, .92, .08, .92)

    local castBar = CreateFrame("Statusbar", nil, castBarContainer)
    castBar:SetParentKey("Bar")
    castBar:SetPoint("BOTTOMRIGHT", castBarContainer, "BOTTOMRIGHT")
    castBar:SetStatusBarTexture(dbEntry.Texture)

    Util.AddStatusBarBackground(castBar)
    Util.AddBorder(castBar)
    UF.UpdateCastBarFrame(unitFrame)

    local castBarName = castBar:CreateFontString(nil, "OVERLAY")
    castBarName:SetParentKey("Name")
    castBarName:SetJustifyH("LEFT")
    castBarName:SetWordWrap(false)

    local castBarTime = castBar:CreateFontString(nil, "OVERLAY")
    castBarTime:SetParentKey("Time")

    UF.UpdateCastBarTexts(unitFrame)

    castBarContainer:SetScript("OnEvent", function(self, event)            
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
            self.Ticker:Cancel()
            self:Hide()
        elseif event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
            if self.Ticker then self.Ticker:Cancel() end
            UpdateCastBar(self, nil, nil)
        end
    end)
end

-------------------------------------------------------------------------------------------------

table.insert(frames, CreateFrame("Button", "CUI_PlayerFrame", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_TargetFrame", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_FocusFrame", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_PetFrame", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_BossFrame1", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_BossFrame2", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_BossFrame3", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_BossFrame4", UIParent, "CUI_UnitFrameTemplate"))
table.insert(frames, CreateFrame("Button", "CUI_BossFrame5", UIParent, "CUI_UnitFrameTemplate"))

function SetupUnitFrame(frameName, unit, number)
    local dbEntry = CUI.DB.profile.UnitFrames[frameName]

    local frame
    if frameName == "BossFrame" then
        frame = _G["CUI_"..frameName..number]
        dbEntry.CastBar.AnchorFrame = "CUI_"..frameName..number
    else
        frame = _G["CUI_"..frameName]
    end
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    Util.CheckAnchorFrame(frame, dbEntry)
    if frameName == "BossFrame" then
        if number == 1 then
            frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
        else
            frame:SetPoint("TOPLEFT", "CUI_BossFrame"..(number-1), "BOTTOMLEFT", 0, -dbEntry.Padding)
        end
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end

    frame:SetAttribute("unit", unit)
    frame:RegisterForClicks("AnyDown")
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("ping-receiver", true)

    frame.unit = unit
    frame.name = frameName
    frame.number = number
    frame.buffs = {}
    frame.debuffs = {}
    frame.calc = CreateUnitHealPredictionCalculator()
    frame.calc:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
    frame.calc:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)

    if unit == "target" then
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit == "focus" then
        frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    elseif unit == "pet" or frameName == "BossFrame" then
        frame:HookScript("OnShow", function(self)
            if EditModeManagerFrame:IsShown() then return end
            UpdateAll(self)
        end)
    end

    local powerBar = CreateFrame("StatusBar", nil, frame)
    powerBar:SetParentKey("PowerBar")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    powerBar:SetFrameLevel(frame:GetFrameLevel()+5)
    Util.AddStatusBarBackground(powerBar)
    Util.AddBorder(powerBar)

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetStatusBarTexture("")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    healthBar:SetPoint("BOTTOMRIGHT", powerBar, "TOPRIGHT")

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetParentKey("Background")
    background:SetTexture("")
    background:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

    local healPredictionBar = CreateFrame("StatusBar", nil, frame)
    healPredictionBar:SetParentKey("HealPredictionBar")
    healPredictionBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    healPredictionBar:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT")
    healPredictionBar:SetFrameLevel(healthBar:GetFrameLevel()+1)
    healPredictionBar:SetStatusBarTexture("")

    local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
    healAbsorbBar:SetParentKey("HealAbsorbBar")
    healAbsorbBar:SetFrameLevel(healPredictionBar:GetFrameLevel()+1)
    healAbsorbBar:SetAllPoints(healthBar)
    healAbsorbBar:SetStatusBarTexture("")
    healAbsorbBar:SetReverseFill(false)
    local absorbTexture = healAbsorbBar:GetStatusBarTexture()
    absorbTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Striped.tga", "REPEAT", "REPEAT")
    absorbTexture:SetHorizTile(true)

    local damageAbsorbBar = CreateFrame("StatusBar", nil, frame)
    damageAbsorbBar:SetParentKey("DamageAbsorbBar")
    damageAbsorbBar:SetAllPoints(healthBar)
    damageAbsorbBar:SetFrameLevel(healAbsorbBar:GetFrameLevel()+1)
    damageAbsorbBar:SetStatusBarTexture("")
    local shieldTexture = damageAbsorbBar:GetStatusBarTexture()
    shieldTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Striped.tga", "REPEAT", "REPEAT")
    shieldTexture:SetHorizTile(true)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetFrameLevel(frame:GetFrameLevel()+10)
    overlayFrame:SetAllPoints(frame)
    Util.AddBorder(overlayFrame)

    frame.buffPool = CreateFramePool("Frame", overlayFrame, "CUI_AuraFrameTemplate")
    frame.debuffPool = CreateFramePool("Frame", overlayFrame, "CUI_AuraFrameTemplate")

    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
    unitName:SetJustifyH("LEFT")
    unitName:SetWordWrap(false)

    local unitHealth = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitHealth:SetParentKey("UnitHealth")
    unitHealth:SetFont(dbEntry.HealthText.Font, dbEntry.HealthText.Size, dbEntry.HealthText.Outline)

    if dbEntry.LeaderIcon then
        local leaderFrame = overlayFrame:CreateTexture(nil, "OVERLAY")
        leaderFrame:SetParentKey("LeaderIcon")
        leaderFrame:SetPoint(dbEntry.LeaderIcon.AnchorPoint, overlayFrame, dbEntry.LeaderIcon.AnchorRelativePoint, dbEntry.LeaderIcon.PosX, dbEntry.LeaderIcon.PosY)
        leaderFrame:SetSize(15, 15)
        leaderFrame:Hide()
    end

    frame:RegisterUnitEvent("UNIT_AURA", unit)
    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
    frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
    frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("GROUP_FORMED")
    frame:RegisterEvent("GROUP_LEFT")
    frame:HookScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
            local unit, updateInfo = ...
            UF.UpdateAuras(self, updateInfo)
        elseif event == "UNIT_HEALTH" then
            UpdateHealth(self)
            UpdateHealPrediction(self)
            UpdateIsDead(self)
        elseif event == "UNIT_MAXHEALTH" then
            UpdateMaxHealth(self)
        elseif event == "UNIT_POWER_FREQUENT" then
            UpdatePower(self)
        elseif event == "UNIT_MAXPOWER" then
            UpdateMaxPower(self)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UpdateDamageAbsorb(self)
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UpdateHealAbsorb(self)
        elseif event == "UNIT_HEAL_PREDICTION" then
            UpdateHealPrediction(self)
        elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
            if not UnitExists(self.unit) then return end
            UpdateAll(self)
            if EditModeManagerFrame:IsShown() then return end
            UF.UpdateAuras(self)
        elseif event == "PLAYER_REGEN_ENABLED" then
            UF.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            UF.UpdateAlpha(self, true)
        elseif event == "PARTY_LEADER_CHANGED" or event == "GROUP_FORMED" or event == "GROUP_LEFT" then
            UpdateLeaderAssist(self)
        elseif event == "UNIT_DISPLAYPOWER" then
            UpdateMaxPower(frame)
            UpdatePowerColor(frame)
        end
    end)

    SetupCastBar(frame)

    UF.UpdateAuras(frame)
    UF.UpdateFrame(frame)
    UF.UpdateTexts(frame)
    UpdateAll(frame)

    RegisterUnitWatch(frame, false)
end

---------------------------------------------------------------------------------------------------

function UF.Load()
    HideBlizzard()

    SetupUnitFrame("PlayerFrame", "player")
    SetupUnitFrame("TargetFrame", "target")
    SetupUnitFrame("FocusFrame", "focus")
    SetupUnitFrame("PetFrame", "pet")

    SetupUnitFrame("BossFrame", "boss1", 1)
    SetupUnitFrame("BossFrame", "boss2", 2)
    SetupUnitFrame("BossFrame", "boss3", 3)
    SetupUnitFrame("BossFrame", "boss4", 4)
    SetupUnitFrame("BossFrame", "boss5", 5)
end
