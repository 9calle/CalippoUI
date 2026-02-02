local addonName, CUI = ...

CUI.GF = {}
local GF = CUI.GF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.HideBlizzardParty()
    Hide.HideBlizzardRaid()
    Hide.HideBlizzardRaidManager()
end

---------------------------------------------------------------------------------------------------------------------------------

function GF.UpdateAlpha(frame, inCombat)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name]

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local DEBUFF_DISPLAY_COLOR_INFO = {
    [0] = CreateColor(0, 0, 0, 0),
    [1] = DEBUFF_TYPE_MAGIC_COLOR,
    [2] = DEBUFF_TYPE_CURSE_COLOR,
    [3] = DEBUFF_TYPE_DISEASE_COLOR,
    [4] = DEBUFF_TYPE_POISON_COLOR,
    [9] = DEBUFF_TYPE_BLEED_COLOR, -- enrage
    [11] = DEBUFF_TYPE_BLEED_COLOR,
}
local dispelColorCurve = C_CurveUtil.CreateColorCurve()

dispelColorCurve:SetType(Enum.LuaCurveType.Step)
for i, c in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
    dispelColorCurve:AddPoint(i, c)
end

local function UpdateAuras(frame, blizzFrame, type)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name][type]
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

    local dispelColor = nil
    local index = 0
    local function HandleAura(id)
        if id then
            local aura = AuraUtil.GetAuraDataByAuraInstanceID(frame.unit, id)
            if aura then
                if index >= maxShown then return end

                local auraFrame = frame.pool:Acquire()
                auraFrame:Show()

                auraFrame.unit = frame.unit
                auraFrame.type = type
                auraFrame.auraInstanceID = aura.auraInstanceID

                auraFrame:SetSize(size, size)

                local color = C_UnitAuras.GetAuraDispelTypeColor(frame.unit, aura.auraInstanceID, dispelColorCurve)
                if type == "Debuffs" and color then
                    if aura.dispelName then
                        dispelColor = color
                        auraFrame.Overlay.Backdrop:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
                    else
                        auraFrame.Overlay.Backdrop:SetBackdropBorderColor(0, 0, 0, 1)
                    end
                else
                    auraFrame.Overlay.Backdrop:SetBackdropBorderColor(0, 0, 0, 1)
                end

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

                Util.PositionFromIndex(index, auraFrame, frame.Overlay, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

                index = index + 1
            end
        end
    end

    if type == "Buffs" then
        for i=1, #blizzFrame.buffFrames do
            local f = blizzFrame.buffFrames[i]
            if f:IsShown() then
                HandleAura(f.auraInstanceID)
            else
                return
            end
        end
    elseif type == "Debuffs" then
        for i=1, #blizzFrame.debuffFrames do
            local f = blizzFrame.debuffFrames[i]
            if f:IsShown() then
                HandleAura(f.auraInstanceID)
            else
                break
            end
        end

        if dispelColor then
            frame.Overlay.DispelGradient:SetColorTexture(dispelColor.r, dispelColor.g, dispelColor.b, dispelColor.a)
        else
            frame.Overlay.DispelGradient:SetColorTexture(0, 0, 0, 0)
        end
    elseif type == "Defensives" then
        HandleAura(blizzFrame.CenterDefensiveBuff.auraInstanceID)
    end
end

local function UpdateAllAuras(frame)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name]

    if frame.name == "PartyFrame" then
        if (not frame.BlizzFrame) or (frame.BlizzFrame and frame.BlizzFrame.unit ~= frame.unit) then
            for i=1, #CompactPartyFrame.memberUnitFrames do
                local f = CompactPartyFrame.memberUnitFrames[i]
                if f.unit == frame.unit then
                    frame.BlizzFrame = f
                    break
                end
            end
        end
    elseif frame.name == "RaidFrame" then
        if (not frame.BlizzFrame) or (frame.BlizzFrame and frame.BlizzFrame.unit ~= frame.unit) then
            for i=1, 8 do
                local group = _G["CompactRaidGroup"..i]
                if group then
                    local shouldBreak = false
                    for j=1, #group.memberUnitFrames do
                        local f = group.memberUnitFrames[j]
                        if f.unit == frame.unit then
                            frame.BlizzFrame = f
                            shouldBreak = true
                            break
                        end
                    end
                    if shouldBreak then break end
                end
            end
        end
    end

    if not frame.BlizzFrame then return end

    frame.pool:ReleaseAll()
    if dbEntry.Buffs.Enabled then
        UpdateAuras(frame, frame.BlizzFrame, "Buffs")
    end
    if dbEntry.Debuffs.Enabled then
        UpdateAuras(frame, frame.BlizzFrame,  "Debuffs")
    end
    if dbEntry.Defensives.Enabled then
        UpdateAuras(frame, frame.BlizzFrame,  "Defensives")
    end
end

function GF.UpdateAuras(groupFramesContainer)
    for i=1, #groupFramesContainer.frames do
        local frame = groupFramesContainer.frames[i]
        UpdateAllAuras(frame)
    end
end

local function SetupPrivateAnchors(frame)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name].PrivateAuras
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

    for i=1, 6 do
        local container = CreateFrame("Frame", nil, frame.Overlay)
        container:SetParentKey("PrivateAuraContainer"..i)
        container:SetSize(size, size)
        Util.PositionFromIndex(i-1, container, frame.Overlay, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        local anchor = C_UnitAuras.AddPrivateAuraAnchor({
            unitToken = frame.unit,
            auraIndex = i,
            parent = container,
            showCountdownFrame = true,
            showCountdownNumbers = false,
            iconInfo = {
                iconWidth = size,
                iconHeight = size,
                borderScale = 1,
                iconAnchor = {
                    point = "CENTER",
                    relativeTo = container,
                    relativePoint = "CENTER",
                    offsetX = 0,
                    offsetY = 0,
                },
            },
        })
        table.insert(frame.privateAnchors, anchor)
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function UpdateNameColor(frame)
    local dbEntry = CUI.DB.profile.GroupFrames.Name

    if dbEntry.CustomColor then
        local c = dbEntry.Color
        frame.Overlay.UnitName:SetTextColor(c.r, c.g, c.b, c.a)
    else
        frame.Overlay.UnitName:SetTextColor(Util.GetUnitColor(frame.unit, true))
    end
end

local function UpdateHealthColor(frame)
    local dbEntry = CUI.DB.profile.GroupFrames

    if frame.dead then
        local dc = dbEntry.HealthBar.DeadColor
        frame.HealthBar:SetStatusBarColor(dc.r, dc.g, dc.b, dc.a)
    elseif frame.disconnected then
        local dc = dbEntry.HealthBar.DisconnectedColor
        frame.HealthBar:SetStatusBarColor(dc.r, dc.g, dc.b, dc.a)
    elseif dbEntry.HealthBar.CustomColor then
        local hc = dbEntry.HealthBar.Color
        frame.HealthBar:SetStatusBarColor(hc.r, hc.g, hc.b, hc.a)

        local bc = dbEntry.HealthBar.BackgroundColor
        frame.Background:SetVertexColor(bc.r, bc.g, bc.b, bc.a)

        local hpc = dbEntry.HealthBar.HealPredictionColor
        frame.HealPredictionBar:SetStatusBarColor(hpc.r, hpc.g, hpc.b, hpc.a)
    else
        local r, g, b = Util.GetUnitColor(frame.unit, true)
        frame.HealthBar:SetStatusBarColor(r, g, b)

        local v = 0.2
        frame.Background:SetVertexColor(r*v, g*v, b*v)

        local v2 = 0.5
        frame.HealPredictionBar:SetStatusBarColor(r*v2, g*v2, b*v2)
    end
end

local function UpdateAbsorbColor(frame)
    local dbEntry = CUI.DB.profile.GroupFrames

    local hac = dbEntry.HealAbsorbBar.Color
    frame.HealAbsorbBar:SetStatusBarColor(hac.r, hac.g, hac.b, hac.a)

    local dac = dbEntry.DamageAbsorbBar.Color
    frame.DamageAbsorbBar:SetStatusBarColor(dac.r, dac.g, dac.b, dac.a)
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
    local health = UnitHealth(frame.unit)

    frame.HealthBar:SetValue(health)
end

local function UpdateMaxHealth(frame)
    local maxHealth = UnitHealthMax(frame.unit)
    local health = UnitHealth(frame.unit)

    frame.HealthBar:SetMinMaxValues(0, maxHealth)
    frame.HealthBar:SetValue(health)

    frame.HealAbsorbBar:SetMinMaxValues(0, maxHealth)
    UpdateHealAbsorb(frame)
    frame.DamageAbsorbBar:SetMinMaxValues(0, maxHealth)
    UpdateDamageAbsorb(frame)
end

local function UpdateInRange(frame)
    frame:SetAlphaFromBoolean(UnitInRange(frame.unit), 1, 0.5)
end

local function UpdateInPhase(frame)
    local phaseReason = UnitPhaseReason(frame.unit)

    if phaseReason then
        frame.phase = true
    else
        frame.phase = false
    end
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

local function UpdateConnection(frame)
    if UnitIsConnected(frame.unit) then
        local _, max = frame.HealthBar:GetMinMaxValues()
        frame.HealthBar:SetValue(max)
        frame.disconnected = false
        UpdateHealthColor(frame)
    else
        frame.disconnected = true
        UpdateHealthColor(frame)
    end
end

local function UpdateReadyCheck(frame)
    local status = GetReadyCheckStatus(frame.unit)

    if status == "ready" then
        frame.readyCheck = "ready"
    elseif status == "waiting" then
        frame.readyCheck = "waiting"
    elseif status == "notready" then
        frame.readyCheck = "notready"
    else
        frame.readyCheck = nil
    end
end

local function UpdateRole(frame)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name].RoleIcon
    frame.role = UnitGroupRolesAssigned(frame.unit)
    if not dbEntry.Enabled then return end

    local roleIcon = frame.Overlay.RoleIcon

    if frame.role == "TANK" then
        roleIcon:SetTexture("Interface/AddOns/CalippoUI/Media/TANK.tga")
        roleIcon:Show()
    elseif frame.role == "HEALER" then
        roleIcon:SetTexture("Interface/AddOns/CalippoUI/Media/HEALER.tga")
        roleIcon:Show()
    else
        roleIcon:Hide()
    end
end

local function UpdateRess(frame)
    if UnitHasIncomingResurrection(frame.unit) then
        frame.ress = true
    else
        frame.ress = false
    end
end

local function UpdateName(frame)
    UpdateNameColor(frame)
    frame.Overlay.UnitName:SetText(UnitName(frame.unit))
end

local function UpdateSummon(frame)
    local status = C_IncomingSummon.IncomingSummonStatus(frame.unit)

    if status == Enum.SummonStatus.Pending then
        frame.summon = "pending"
    elseif status == Enum.SummonStatus.Accepted then
        frame.summon = "accepted"
    elseif status == Enum.SummonStatus.Declined then
        frame.summon = "declined"
    else
        frame.summon = nil
    end
end

local function UpdateAFK(frame)
    if UnitIsAFK(frame.unit) then
        frame.afk = true
    else
        frame.afk = false
    end
end

local function UpdateCenterIcon(frame)
    local centerTexture = frame.Overlay.CenterTexture

    if frame.disconnected then
    centerTexture:SetSize(50, 50)
    centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Disconnect-Icon.blp")
    elseif frame.readyCheck then
        centerTexture:SetSize(20, 20)
        if frame.readyCheck == "ready" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-ready.tga")
        elseif frame.readyCheck == "waiting" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-waiting.tga")
        elseif frame.readyCheck == "notready" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-notready.tga")
        end
    elseif frame.summon then
        centerTexture:SetSize(30, 30)
        if frame.summon == "pending" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonPending.tga")
        elseif frame.summon == "accepted" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonAccepted.tga")
        elseif frame.summon == "declined" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonDeclined.tga")
        end
    elseif frame.ress then
        centerTexture:SetSize(20, 20)
        centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-Rez.blp")
    elseif frame.afk then
        centerTexture:SetSize(25, 25)
        centerTexture:SetAtlas("questlog-questtypeicon-clockorange")
    elseif frame.phase then
        centerTexture:SetSize(30, 30)
        centerTexture:SetAtlas("Dungeon")
    else
        centerTexture:Hide()
        return
    end

    centerTexture:Show()
end

local function UpdateBorderColor(frame)
    local aggroStatus = UnitThreatSituation(frame.unit)

    if UnitIsUnit("target", frame.unit) then
        frame.Overlay.Border:SetBackdropBorderColor(1, 1, 1, 1)
    elseif frame.role ~= "TANK" and (aggroStatus == 2 or aggroStatus == 3) then
        frame.Overlay.Border:SetBackdropBorderColor(1, 0, 0, 1)
    else
        frame.Overlay.Border:SetBackdropBorderColor(0, 0, 0, 1)
    end
end

local function UpdateAll(frame)
    UpdateMaxHealth(frame)

    UpdateInRange(frame)
    UpdateInPhase(frame)
    UpdateIsDead(frame)
    UpdateConnection(frame)
    UpdateReadyCheck(frame)
    UpdateRole(frame)
    UpdateName(frame)
    UpdateSummon(frame)
    UpdateRess(frame)
    UpdateAFK(frame)

    UpdateNameColor(frame)
    UpdateHealthColor(frame)
    UpdateAbsorbColor(frame)

    UpdateBorderColor(frame)

    UpdateCenterIcon(frame)
end

local function UpdateUnitEvents(frame, unit)
    frame:RegisterUnitEvent("UNIT_AURA", unit)
    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
    frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
    frame:RegisterUnitEvent("UNIT_PHASE", unit)
    frame:RegisterUnitEvent("UNIT_CONNECTION", unit)
    frame:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit)
end

function GF.ToggleGroupTestFrames(type, state)
    if InCombatLockdown() then return end

    if type == "PartyFrame" then
        for i=1, #CUI_PartyFrame.frames do
            local frame = CUI_PartyFrame.frames[i]
            if state then
                UpdateUnitEvents(frame, "player")
                frame.unit = "player"
                frame:SetAttribute("unit", "player")
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "show")
            else
                local unit
                if i == 5 then
                    unit = "player"
                else
                    unit = "party"..i
                end
                UpdateUnitEvents(frame, unit)
                frame.unit = unit
                frame:SetAttribute("unit", unit)
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "[group:raid]hide;[group:party, @"..unit..", exists]show;hide")
            end
        end
        GF.UpdateAuras(CUI_PartyFrame)
        GF.SortGroupFrames(CUI_PartyFrame)
    elseif type == "RaidFrame" then
        for i=1, #CUI_RaidFrame.frames do
            local frame = CUI_RaidFrame.frames[i]
            if state then
                UpdateUnitEvents(frame, "player")
                frame.unit = "player"
                frame:SetAttribute("unit", "player")
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "show")
            else
                local unit = "raid"..i
                UpdateUnitEvents(frame, unit)
                frame.unit = unit
                frame:SetAttribute("unit", unit)
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "[group:raid, @"..unit..", exists]show;hide")
            end
        end
        GF.UpdateAuras(CUI_RaidFrame)
        GF.SortGroupFrames(CUI_RaidFrame)
    end
end

---------------------------------------------------------------------------------------------------------------------------------

function GF.UpdateFrame(groupFramesContainer)
    if InCombatLockdown() then return end
    local dbEntryGF = CUI.DB.profile.GroupFrames
    local dbEntry = dbEntryGF[groupFramesContainer.name]

    for i=1, #groupFramesContainer.frames do
        local frame = groupFramesContainer.frames[i]
        frame:SetSize(dbEntry.Width, dbEntry.Height)

        frame.HealthBar:SetStatusBarTexture(dbEntryGF.HealthBar.Texture)
        frame.Background:SetTexture(dbEntryGF.HealthBar.Texture)
        frame.HealPredictionBar:SetStatusBarTexture(dbEntryGF.HealthBar.Texture)
        frame.DamageAbsorbBar:SetStatusBarTexture(dbEntryGF.DamageAbsorbBar.Texture)
        frame.HealAbsorbBar:SetStatusBarTexture(dbEntryGF.HealAbsorbBar.Texture)

        local dbEntryName = dbEntry.Name
        local unitName = frame.Overlay.UnitName
        if dbEntryName.Enabled then
            unitName:Show()
            unitName:ClearAllPoints()
            unitName:SetPoint(dbEntryName.AnchorPoint, frame.Overlay, dbEntryName.AnchorRelativePoint, dbEntryName.PosX, dbEntryName.PosY)
            unitName:SetFont(dbEntryName.Font, dbEntryName.Size, dbEntryName.Outline)
            unitName:SetWidth(dbEntryName.Width)
        else
            unitName:Hide()
        end

        local dbEntryRole = dbEntry.RoleIcon
        local roleIcon = frame.Overlay.RoleIcon
        if dbEntryRole.Enabled then
            UpdateRole(frame)
            roleIcon:ClearAllPoints()
            roleIcon:SetPoint(dbEntryRole.AnchorPoint, frame.Overlay, dbEntryRole.AnchorRelativePoint, dbEntryRole.PosX, dbEntryRole.PosY)
            roleIcon:SetSize(dbEntryRole.Size, dbEntryRole.Size)
        else
            roleIcon:Hide()
        end

        frame.Overlay.DispelGradient:SetHeight(dbEntry.DispelGradient.Height)

        UpdateNameColor(frame)
        UpdateHealthColor(frame)
        UpdateAbsorbColor(frame)
    end

    Util.CheckAnchorFrame(groupFramesContainer, dbEntry)

    groupFramesContainer:ClearAllPoints()
    groupFramesContainer:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    GF.SortGroupFrames(groupFramesContainer)
end

---------------------------------------------------------------------------------------------------------------------------------

local rolePriority = {
    ["TANK"] = 3,
    ["HEALER"] = 2,
    ["DAMAGER"] = 1,
    ["NONE"] = 0,
}

local classPriority = {
    WARRIOR      = 1,
    PALADIN      = 2,
    HUNTER       = 3,
    ROGUE        = 4,
    PRIEST       = 5,
    DEATHKNIGHT  = 6,
    SHAMAN       = 7,
    MAGE         = 8,
    WARLOCK      = 9,
    MONK         = 10,
    DRUID        = 11,
    DEMONHUNTER  = 12,
    EVOKER       = 13,
}

local function RoleComp(a, b)
    local aExists = UnitExists(a.unit)
    local bExists = UnitExists(b.unit)

    if aExists and bExists then
        if rolePriority[a.role] == rolePriority[b.role] then
            local _, aC = UnitClass(a.unit)
            local _, bC = UnitClass(b.unit)
            if aC and bC then
                return classPriority[aC] > classPriority[bC]
            else
                return UnitName(a.unit) > UnitName(b.unit)
            end
        else
            return rolePriority[a.role] > rolePriority[b.role]
        end
    elseif aExists and not bExists then
        return true
    elseif not aExists and bExists then
        return false
    else
        return a.unit < b.unit
    end
end

function GF.SortGroupFrames(groupFramesContainer)
    if InCombatLockdown() then return end
    local dbEntry = CUI.DB.profile.GroupFrames[groupFramesContainer.name]
    local dirH = dbEntry.DirH
    local dirV = dbEntry.DirV
    local width = dbEntry.Width
    local height = dbEntry.Height
    local padding = dbEntry.Padding
    local rL = dbEntry.RowLength

    local numMem = math.min(GetNumGroupMembers(), rL)
    groupFramesContainer:SetWidth((numMem * (width + padding)) - padding)
    groupFramesContainer:SetHeight(height)

    -- TODO : Fixa läge där frames inte sorteras.

    table.sort(groupFramesContainer.frames, RoleComp)

    for i=1, #groupFramesContainer.frames do
        local frame = groupFramesContainer.frames[i]
        Util.PositionFromIndex(i-1, frame, groupFramesContainer, "TOPLEFT", "TOPLEFT", dirH, dirV, width, height, padding, 0, 0, rL)
    end
end

local function UpdateGroupFrames(groupFramesContainer)
    local numMem = GetNumGroupMembers()
    if numMem == 0 then return end

    local groupType = groupFramesContainer.groupType

    if groupType == "raid" and not IsInRaid() then return end
    if groupType == "party" and (not IsInGroup() or IsInRaid()) then return end

    for i=1, numMem do
        local unit = groupType..i
        if groupType == "party" and i == numMem then unit = "player" end

        local frame = groupFramesContainer[unit]

        UpdateAll(frame)
        UpdateAllAuras(frame)
    end

    if groupFramesContainer.LastNumMem == numMem then return end

    groupFramesContainer.LastNumMem = numMem

    GF.SortGroupFrames(groupFramesContainer)
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupGroupFrame(unit, groupType, frameName, parent, num)
    local dbEntryGF = CUI.DB.profile.GroupFrames
    local dbEntry = dbEntryGF[frameName]

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetParentKey(unit)
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    -- frame:SetAttribute("unit", unit)
    -- frame:RegisterForClicks("AnyDown")
    -- frame:SetAttribute("*type1", "target")
    -- frame:SetAttribute("*type2", "togglemenu")
    -- frame:SetAttribute("ping-receiver", true)

    frame.unit = unit
    frame.groupType = groupType
    frame.name = frameName
    frame.num = num
    frame.calc = CreateUnitHealPredictionCalculator()
    frame.calc:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
    frame.calc:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
    frame.privateAnchors = {}

    frame.disconnected = nil
    frame.summon = nil
    frame.ress = nil
    frame.readyCheck = nil
    frame.phase = nil
    frame.afk = nil

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetAllPoints(frame)
    healthBar:SetStatusBarTexture("")

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetParentKey("Background")
    background:SetTexture(dbEntryGF.HealthBar.Texture)
    background:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

    local healPredictionBar = CreateFrame("StatusBar", nil, frame)
    healPredictionBar:SetParentKey("HealPredictionBar")
    healPredictionBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    healPredictionBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    healPredictionBar:SetFrameLevel(healthBar:GetFrameLevel()+1)
    healPredictionBar:SetStatusBarTexture("")

    local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
    healAbsorbBar:SetParentKey("HealAbsorbBar")
    healAbsorbBar:SetFrameLevel(healPredictionBar:GetFrameLevel()+1)
    healAbsorbBar:SetAllPoints(frame)
    healAbsorbBar:SetStatusBarTexture("")
    healAbsorbBar:SetReverseFill(false)
    local absorbTexture = healAbsorbBar:GetStatusBarTexture()
    absorbTexture:SetTexture("", "REPEAT", "REPEAT")
    absorbTexture:SetHorizTile(true)

    local damageAbsorbBar = CreateFrame("StatusBar", nil, frame)
    damageAbsorbBar:SetParentKey("DamageAbsorbBar")
    damageAbsorbBar:SetAllPoints(frame)
    damageAbsorbBar:SetFrameLevel(healAbsorbBar:GetFrameLevel()+1)
    damageAbsorbBar:SetStatusBarTexture("")
    local shieldTexture = damageAbsorbBar:GetStatusBarTexture()
    shieldTexture:SetTexture("", "REPEAT", "REPEAT")
    shieldTexture:SetHorizTile(true)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(frame)
    overlayFrame:SetFrameLevel(damageAbsorbBar:GetFrameLevel()+1)

    local border = CreateFrame("Frame", nil, overlayFrame, "BackdropTemplate")
    border:SetParentKey("Border")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({
        edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorderWhite.tga",
        edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) * 3,
        bgFile = nil
    })

    frame.pool = CreateFramePool("Frame", overlayFrame, "CUI_AuraFrameTemplate")

    local dispelTexture = overlayFrame:CreateTexture(nil, "OVERLAY")
    dispelTexture:SetParentKey("DispelGradient")
    dispelTexture:SetPoint("BOTTOMLEFT", overlayFrame, "BOTTOMLEFT")
    dispelTexture:SetPoint("BOTTOMRIGHT", overlayFrame, "BOTTOMRIGHT")
    local dispelMask = overlayFrame:CreateMaskTexture()
    dispelMask:SetTexture("Interface/AddOns/CalippoUI/Media/Gradient.blp")
    dispelMask:SetRotation(math.pi)
    dispelMask:SetAllPoints(dispelTexture)
    dispelTexture:AddMaskTexture(dispelMask)

    local dbEntryUN = dbEntry.Name
    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetPoint(dbEntryUN.AnchorPoint, overlayFrame, dbEntryUN.AnchorRelativePoint, dbEntryUN.PosX, dbEntryUN.PosY)
    unitName:SetFont(dbEntryUN.Font, dbEntryUN.Size, dbEntryUN.Outline)
    unitName:SetJustifyH("LEFT")
    unitName:SetWordWrap(false)

    local centerTexture = overlayFrame:CreateTexture(nil, "OVERLAY")
    centerTexture:SetParentKey("CenterTexture")
    centerTexture:SetPoint("CENTER")
    centerTexture:Hide()

    local unitRole = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitRole:SetParentKey("RoleIcon")

    -- TODO : Private Auras
    SetupPrivateAnchors(frame)

    local clickFrame = CreateFrame("Button", nil, overlayFrame, "CUI_UnitFrameTemplate")
    clickFrame:SetParentKey("ClickFrame")
    clickFrame:SetAllPoints(overlayFrame)
    clickFrame:SetFrameLevel(overlayFrame:GetFrameLevel() + 20)
    clickFrame.unit = unit
    clickFrame:SetAttribute("unit", unit)
    clickFrame:RegisterForClicks("AnyDown")
    clickFrame:SetAttribute("*type1", "target")
    clickFrame:SetAttribute("*type2", "togglemenu")
    clickFrame:SetAttribute("ping-receiver", true)
    clickFrame:Show()

    frame:RegisterUnitEvent("UNIT_AURA", unit)
    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
    frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
    frame:RegisterUnitEvent("UNIT_PHASE", unit)
    frame:RegisterUnitEvent("UNIT_CONNECTION", unit)
    frame:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit)
    frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    frame:RegisterEvent("INCOMING_SUMMON_CHANGED")
    frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:SetScript("OnEvent", function(self, event)
        if not self:IsShown() then return end

        if event == "UNIT_AURA" then
            UpdateAllAuras(self)
        elseif event == "UNIT_HEALTH" then
            UpdateHealth(self)
            UpdateHealPrediction(self)
            UpdateIsDead(self)
        elseif event == "UNIT_MAXHEALTH" then
            UpdateMaxHealth(self)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UpdateDamageAbsorb(self)
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UpdateHealAbsorb(self)
        elseif event == "UNIT_HEAL_PREDICTION" then
            UpdateHealPrediction(self)
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            UpdateInRange(self)
        elseif event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE" then
            UpdateBorderColor(frame)
        elseif event  == "PLAYER_TARGET_CHANGED" then
            UpdateBorderColor(frame)
        elseif event == "PLAYER_FLAGS_CHANGED" then
            UpdateAFK(self)
            UpdateCenterIcon(self)
        elseif event == "UNIT_PHASE" then
            UpdateInPhase(self)
            UpdateCenterIcon(self)
        elseif event == "UNIT_CONNECTION" then
            UpdateConnection(self)
            UpdateCenterIcon(self)
        elseif event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" or event == "READY_CHECK_FINISHED" then
            UpdateReadyCheck(self)
            UpdateCenterIcon(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            UpdateRole(self)
        elseif event == "INCOMING_RESURRECT_CHANGED" then
            UpdateRess(self)
            UpdateCenterIcon(self)
        elseif event == "INCOMING_SUMMON_CHANGED" then
            UpdateSummon(self)
            UpdateCenterIcon(self)
        end
    end)

    if groupType == "party" then
        RegisterAttributeDriver(frame, "state-visibility", "[group:raid]hide;[group:party, @"..unit..", exists]show;hide")
    else
        RegisterAttributeDriver(frame, "state-visibility", "[group:raid, @"..unit..", exists]show;hide")
    end

    RegisterUnitWatch(frame, true)

    return frame
end

---------------------------------------------------------------------------------------------------------------------------------

function GF.Load()
    -- HideBlizzard()

    local dbEntryP = CUI.DB.profile.GroupFrames.PartyFrame
    local partyFrame = CreateFrame("Frame", "CUI_PartyFrame", UIParent)
    partyFrame.groupType = "party"
    partyFrame.name = "PartyFrame"
    partyFrame.frames = {}
    partyFrame.LastNumMem = 0
    partyFrame:SetPoint(dbEntryP.AnchorPoint, dbEntryP.AnchorFrame, dbEntryP.AnchorRelativePoint, dbEntryP.PosX, dbEntryP.PosY)
    partyFrame:SetSize(1, 1)
    partyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    partyFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    partyFrame:RegisterEvent("GROUP_JOINED")
    partyFrame:RegisterEvent("GROUP_LEFT")
    partyFrame:RegisterEvent("GROUP_FORMED")
    partyFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    partyFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    partyFrame:SetScript("OnEvent", function(self, event)
        if not IsInGroup() or IsInRaid() then return end

        if event == "GROUP_ROSTER_UPDATE" then
            UpdateGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            GF.SortGroupFrames(self)
        elseif event == "GROUP_JOINED" or event == "GROUP_LEFT" or event == "GROUP_FORMED" then
            self.LastNumMem = 0
        elseif event == "PLAYER_REGEN_ENABLED" then
            GF.UpdateAlpha(self)
            GF.UpdateAuras(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            GF.UpdateAuras(self)
            GF.UpdateAlpha(self, true)
            if GetNumGroupMembers() ~= self.LastNumMem then
                UpdateGroupFrames(self)
            end
        end
    end)

    for i=1, 4 do
        local frame = SetupGroupFrame("party"..i, "party", "PartyFrame", partyFrame, i)
        table.insert(partyFrame.frames, frame)
    end

    local playerFrame = SetupGroupFrame("player", "party", "PartyFrame", partyFrame, 0)
    table.insert(partyFrame.frames, playerFrame)

    GF.UpdateFrame(partyFrame)
    GF.UpdateAlpha(partyFrame)
    UpdateGroupFrames(partyFrame)

    local dbEntryR = CUI.DB.profile.GroupFrames.RaidFrame
    local raidFrame = CreateFrame("Frame", "CUI_RaidFrame", UIParent)
    raidFrame.groupType = "raid"
    raidFrame.name = "RaidFrame"
    raidFrame.frames = {}
    raidFrame.LastNumMem = 0
    raidFrame:SetPoint(dbEntryR.AnchorPoint, dbEntryR.AnchorFrame, dbEntryR.AnchorRelativePoint, dbEntryR.PosX, dbEntryR.PosY)
    raidFrame:SetSize(1, 1)
    raidFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    raidFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    raidFrame:RegisterEvent("GROUP_JOINED")
    raidFrame:RegisterEvent("GROUP_LEFT")
    raidFrame:RegisterEvent("GROUP_FORMED")
    raidFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    raidFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    raidFrame:SetScript("OnEvent", function(self, event)
        if not IsInRaid() then return end

        if event == "GROUP_ROSTER_UPDATE" then
            UpdateGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            GF.SortGroupFrames(self)
        elseif event == "GROUP_JOINED" or event == "GROUP_LEFT" or event == "GROUP_FORMED" then
            self.LastNumMem = 0
        elseif event == "PLAYER_REGEN_ENABLED" then
            GF.UpdateAuras(self)
            GF.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            GF.UpdateAuras(self)
            GF.UpdateAlpha(self, true)
            if GetNumGroupMembers() ~= self.LastNumMem then
                UpdateGroupFrames(self)
            end
        end
    end)

    for i=1, 40 do
        local frame = SetupGroupFrame("raid"..i, "raid", "RaidFrame", raidFrame, i)
        table.insert(raidFrame.frames, frame)
    end

    GF.UpdateFrame(raidFrame)
    GF.UpdateAlpha(raidFrame)
    UpdateGroupFrames(raidFrame)
end