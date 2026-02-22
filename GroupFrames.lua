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
    [0] = CreateColor(0, 0, 0, 1),
    [1] = DEBUFF_TYPE_MAGIC_COLOR,
    [2] = DEBUFF_TYPE_CURSE_COLOR,
    [3] = DEBUFF_TYPE_DISEASE_COLOR,
    [4] = DEBUFF_TYPE_POISON_COLOR,
    [9] = DEBUFF_TYPE_BLEED_COLOR,
    [11] = DEBUFF_TYPE_BLEED_COLOR,
}

local DEBUFF_DISPLAY_COLOR_INFO_GRADIENT = {
    [0] = CreateColor(0, 0, 0, 0),
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


local dispelColorCurveGradient = C_CurveUtil.CreateColorCurve()
dispelColorCurveGradient:SetType(Enum.LuaCurveType.Step)
for i, c in pairs(DEBUFF_DISPLAY_COLOR_INFO_GRADIENT) do
    dispelColorCurveGradient:AddPoint(i, c)
end

local buffFilter = "PLAYER|HELPFUL|RAID"
local buffFilterInCombat = "PLAYER|HELPFUL|RAID_IN_COMBAT"
local debuffFilter = "HARMFUL|RAID"
local debuffFilterInCombat = "HARMFUL|RAID_IN_COMBAT"
local defensiveFilter = "HELPFUL|BIG_DEFENSIVE"
local playerDispellableFilter = "HARMFUL|RAID_PLAYER_DISPELLABLE"

local function UpdateDispel(frame)
    for id, aura in pairs(frame.dispels) do
        local dispelColor = C_UnitAuras.GetAuraDispelTypeColor(frame.unit, aura.auraInstanceID, dispelColorCurveGradient)
        if dispelColor then
            frame.Overlay.DispelGradient:SetColorTexture(dispelColor.r, dispelColor.g, dispelColor.b, dispelColor.a)
            frame.Overlay.DispelGradient:Show()
            return
        end
    end

    frame.Overlay.DispelGradient:Hide()
end

local function IterateAuras(frame, auraTable, pool, type)
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

    pool:ReleaseAll()

    index = 0
	auraTable:Iterate(function(id, aura)
        if index > maxShown then return end
        
        local auraFrame = pool:Acquire()
        auraFrame:Show()

        auraFrame.unit = frame.unit
        auraFrame.type = type
        auraFrame.showTooltip = true
        auraFrame.auraInstanceID = id

        auraFrame:SetSize(size, size)

        if type == "Debuffs" then
            -- local c = aura.borderColor
            local color = C_UnitAuras.GetAuraDispelTypeColor(frame.unit, id, dispelColorCurve)
            if color then
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

        Util.PositionFromIndex(index, auraFrame, frame, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        index = index + 1
	end)
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
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name]
    local unit = frame.unit
    -- table.wipe(frame.buffs)
    -- table.wipe(frame.debuffs)
    -- table.wipe(frame.defensives)
    table.wipe(frame.dispels)

    -- local function AddBuff(aura)
    --     ProcessAura(unit, aura)
	-- 	frame.buffs[aura.auraInstanceID] = aura
	-- end

    -- local function AddDebuff(aura)
    --     ProcessAura(unit, aura)
    --     frame.debuffs[aura.auraInstanceID] = aura
	-- end

    -- local function AddDefensive(aura)
    --     ProcessAura(unit, aura)
    --     frame.defensives[aura.auraInstanceID] = aura
    -- end

    local function AddDispel(aura)
        frame.dispels[aura.auraInstanceID] = aura
    end

    AuraUtil.ForEachAura(unit, playerDispellableFilter, nil, AddDispel, true)

    -- if dbEntry.Buffs.Enabled then
    --     if UnitAffectingCombat("player") then
    --         AuraUtil.ForEachAura(unit, buffFilterInCombat, nil, AddBuff, true)
    --     else
    --         AuraUtil.ForEachAura(unit, buffFilter, nil, AddBuff, true)
    --     end
    -- end

    -- if dbEntry.Defensives.Enabled then
    --     AuraUtil.ForEachAura(unit, defensiveFilter, nil, AddDefensive, true)
    -- end

    -- if dbEntry.Debuffs.Enabled then
    --     if UnitAffectingCombat("player") then
    --         AuraUtil.ForEachAura(unit, debuffFilterInCombat, nil, AddDebuff, true)
    --     else
    --         AuraUtil.ForEachAura(unit, debuffFilter, nil, AddDebuff, true)
    --     end
    -- end
end

local function UpdateBlizzardFrame(frame)
    if frame.blizzFrame and frame.blizzFrame.unit == frame.unit then return true end

    if frame.groupType == "party" then
        for _, blizzFrame in ipairs(CompactPartyFrame.memberUnitFrames) do
            if blizzFrame:IsShown() and blizzFrame.unit == frame.unit then
                frame.blizzFrame = blizzFrame
                return true
            end
        end
    elseif frame.groupType == "raid" then
        for i=1, 8 do
            local group = _G["CompactRaidGroup"..i]
            if group then
                for _, blizzFrame in ipairs(group.memberUnitFrames) do
                    if blizzFrame.unit == frame.unit then
                        frame.blizzFrame = blizzFrame
                        return true
                    end
                end
            end
        end

        for i=1, 40 do
            local blizzFrame = _G["CompactRaidFrame"..i]
            if blizzFrame and blizzFrame.unit == frame.unit then
                frame.blizzFrame = blizzFrame
                return true
            end
        end
    end

    return false
end

local function UpdateAuras(frame, updateInfo)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name]
    local buffsEnabled = dbEntry.Buffs.Enabled
    local debuffsEnabled = dbEntry.Debuffs.Enabled
    local defensivesEnabled = dbEntry.Defensives.Enabled
    local unit = frame.unit
	-- local buffsChanged = false
    -- local debuffsChanged = false
    -- local defensivesChanged = false
    local dispelsChanged = false

    if not buffsEnabled and not debuffsEnabled then return end

    -- Temp tills filters fixas.
    local foundBlizzFrame = UpdateBlizzardFrame(frame)
    if not foundBlizzFrame then return end

    if buffsEnabled then
        IterateAuras(frame, frame.blizzFrame.buffs, frame.buffPool, "Buffs")
    end

    if debuffsEnabled then
        IterateAuras(frame, frame.blizzFrame.debuffs, frame.debuffPool, "Debuffs")
    end

    if defensivesEnabled then
        IterateAuras(frame, frame.blizzFrame.bigDefensives, frame.defensivePool, "Defensives")
    end

    if not updateInfo or updateInfo.isFullUpdate then
        AddAllAuras(frame)
        -- buffsChanged = true
        -- debuffsChanged = true
        -- defensivesChanged = true
        dispelChanged = true
    else
        if updateInfo.addedAuras then
            for i=1, #updateInfo.addedAuras do
                local aura = updateInfo.addedAuras[i]
                -- local done = false

                -- TODO : Optimera?

                if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, playerDispellableFilter) then
                    frame.dispels[aura.auraInstanceID] = aura
                    dispelChanged = true
                end

                -- if defensivesEnabled and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, defensiveFilter) then
                --     ProcessAura(unit, aura)
                --     frame.defensives[aura.auraInstanceID] = aura
                --     defensivesChanged = true
                --     done = true
                -- elseif not done and buffsEnabled then
                --     if UnitAffectingCombat("player") then
                --         if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, buffFilterInCombat) then
                --             ProcessAura(unit, aura)
                --             frame.buffs[aura.auraInstanceID] = aura
                --             buffsChanged = true
                --             done = true
                --         end
                --     else
                --         if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, buffFilter) then
                --             ProcessAura(unit, aura)
                --             frame.buffs[aura.auraInstanceID] = aura
                --             buffsChanged = true
                --             done = true
                --         end
                --     end
                -- end

                -- if not done and debuffsEnabled then
                --     if UnitAffectingCombat("player") then
                --         if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, debuffFilterInCombat) then
                --             ProcessAura(unit, aura)
                --             frame.debuffs[aura.auraInstanceID] = aura
                --             debuffsChanged = true
                --         end
                --     else
                --         if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, debuffFilter) then
                --             ProcessAura(unit, aura)
                --             frame.debuffs[aura.auraInstanceID] = aura
                --             debuffsChanged = true
                --         end
                --     end
                -- end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            -- for i=1, #updateInfo.updatedAuraInstanceIDs do
            --     local id = updateInfo.updatedAuraInstanceIDs[i]

			-- 	if frame.buffs[id] then
			-- 		local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id)
            --         ProcessAura(unit, newAura)
            --         frame.buffs[id] = newAura
            --         buffsChanged = true
            --     elseif frame.debuffs[id] then
            --         local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id)
            --         ProcessAura(unit, newAura)
            --         frame.debuffs[id] = newAura
            --         debuffsChanged = true
            --     end

            --     if frame.defensives[id] then
            --         local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id)
            --         ProcessAura(unit, newAura)
            --         frame.defensives[id] = newAura
            --         defensivesChanged = true
			-- 	end 
            -- end
        end

        if updateInfo.removedAuraInstanceIDs then
            for i=1, #updateInfo.removedAuraInstanceIDs do
                local id = updateInfo.removedAuraInstanceIDs[i]

                -- if frame.buffs[id] then
                --     frame.buffs[id] = nil
                --     buffsChanged = true
                -- elseif frame.debuffs[id] then
                --     frame.debuffs[id] = nil
                --     debuffsChanged = true
                -- end

                if frame.dispels[id] then
                    frame.dispels[id] = nil
                    dispelChanged = true
                end
                
                -- if frame.defensives[id] then
                --     frame.defensives[id] = nil
                --     defensivesChanged = true
                -- end
            end
        end
    end

    -- if buffsChanged then
    --     IterateAuras(frame, frame.buffs, frame.buffPool, "Buffs")
    -- end

    -- if defensivesChanged then
    --     IterateAuras(frame, frame.defensives, frame.defensivePool, "Defensives")
    -- end

    -- if debuffsChanged then
    --     IterateAuras(frame, frame.debuffs, frame.debuffPool, "Debuffs")
    -- end

    if dispelChanged then
        UpdateDispel(frame)
    end
end

local function UpdatePrivateAuraAnchors(frame, showTest)
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
        local container = frame.Overlay["PrivateAuraContainer"..i]
        container:SetSize(size, size)
        Util.PositionFromIndex(i-1, container, frame.Overlay, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        if showTest == true then
            container.TestTexture:Show()
        elseif showTest == false then
            container.TestTexture:Hide()
        end
    end
end

function GF.UpdateAuras(groupFrame, privateAuraTest)
    for _, frame in ipairs(groupFrame.frames) do
        UpdateAuras(frame)
        UpdatePrivateAuraAnchors(frame, privateAuraTest)
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

        local texture = container:CreateTexture(nil, "OVERLAY")
        texture:SetParentKey("TestTexture")
        texture:SetAllPoints(container)
        texture:SetColorTexture(0, 0, 0, 1)
        texture:Hide()

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
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name]
    local rangeAlpha = CUI.DB.profile.GroupFrames[frame.name].OutOfRangeAlpha

    if UnitAffectingCombat(frame.unit) then
        if frame.unit == "player" then
            frame:SetAlpha(dbEntry.CombatAlpha)
        else
            frame:SetAlphaFromBoolean(UnitInRange(frame.unit), dbEntry.CombatAlpha, rangeAlpha)
        end
    else
        if frame.unit == "player" then
            frame:SetAlpha(dbEntry.Alpha)
        else
            frame:SetAlphaFromBoolean(UnitInRange(frame.unit), dbEntry.Alpha, rangeAlpha)
        end
    end
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
    local isAFK = UnitIsAFK(frame.unit)

    if issecretvalue(isAFK) then
        frame.afk = false
        return
    end

    if isAFK then
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
                UpdateAuras(frame)
                RegisterAttributeDriver(frame, "state-visibility", "[group:raid]hide;[group:party, @"..unit..", exists]show;hide")
            end
        end
        GF.SortGroupFrames(CUI_PartyFrame)
    elseif type == "RaidFrame" then
        for i=1, #CUI_RaidFrame.frames do
            local frame = CUI_RaidFrame.frames[i]
            if state then
                UpdateUnitEvents(frame, "player")
                frame.unit = "player"
                frame:SetAttribute("unit", "player")
                UpdateAll(frame)
                UpdateAuras(frame)
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

local function SortyByRole(a, b)
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
        return a.num < b.num
    end
end

local function SortByNumber(a, b)
    return a.num < b.num
end

function GF.SortGroupFrames(groupFramesContainer)
    if InCombatLockdown() then return end
    
    groupFramesContainer.groupChanged = false

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

    if dbEntry.SortByRole then
        table.sort(groupFramesContainer.frames, SortyByRole)
    else
        table.sort(groupFramesContainer.frames, SortByNumber)
    end

    for i=1, #groupFramesContainer.frames do
        local frame = groupFramesContainer.frames[i]
        Util.PositionFromIndex(i-1, frame, groupFramesContainer, "TOPLEFT", "TOPLEFT", dirH, dirV, width, height, padding, 0, 0, rL)
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupGroupFrame(unit, groupType, frameName, parent, num)
    local dbEntryGF = CUI.DB.profile.GroupFrames
    local dbEntry = dbEntryGF[frameName]

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetParentKey(unit)
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    frame.unit = unit
    frame.groupType = groupType
    frame.name = frameName
    frame.num = num
    frame.buffs = {}
    frame.debuffs = {}
    frame.defensives = {}
    frame.dispels = {}
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
    absorbTexture:SetVertTile(true)

    local damageAbsorbBar = CreateFrame("StatusBar", nil, frame)
    damageAbsorbBar:SetParentKey("DamageAbsorbBar")
    damageAbsorbBar:SetAllPoints(frame)
    damageAbsorbBar:SetFrameLevel(healAbsorbBar:GetFrameLevel()+1)
    damageAbsorbBar:SetStatusBarTexture("")
    local shieldTexture = damageAbsorbBar:GetStatusBarTexture()
    shieldTexture:SetTexture("", "REPEAT", "REPEAT")
    shieldTexture:SetHorizTile(true)
    shieldTexture:SetVertTile(true)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(frame)
    overlayFrame:SetFrameLevel(damageAbsorbBar:GetFrameLevel()+1)

    frame.buffPool = CreateFramePool("Frame", overlayFrame, "CUI_AuraFrameTemplate")
    frame.debuffPool = CreateFramePool("Frame", overlayFrame, "CUI_AuraFrameTemplate")
    frame.defensivePool = CreateFramePool("Frame", overlayFrame, "CUI_AuraFrameTemplate")

    local border = CreateFrame("Frame", nil, overlayFrame, "BackdropTemplate")
    border:SetParentKey("Border")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({
        edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorderWhite.tga",
        edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) * 3,
        bgFile = nil
    })

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
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "GROUP_ROSTER_UPDATE" then
            if UnitExists(self.unit) and IsInGroup() then
                UpdateAll(self)
            end
        end

        if not self:IsShown() then return end

        if event == "UNIT_AURA" then
            local _, updateInfo = ...
            UpdateAuras(self, updateInfo)
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
        elseif event == "PLAYER_REGEN_ENABLED" then
            UpdateAuras(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            UpdateAuras(self)
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

    UpdateAll(frame)
    UpdateAuras(frame)

    if groupType == "party" then
        RegisterAttributeDriver(frame, "state-visibility", "[group:raid]hide;[group:party, @"..unit..", exists]show;hide")
    else
        RegisterAttributeDriver(frame, "state-visibility", "[group:raid, @"..unit..", exists]show;hide")
    end

    return frame
end

---------------------------------------------------------------------------------------------------------------------------------

function GF.Load()
    HideBlizzard()

    local dbEntryP = CUI.DB.profile.GroupFrames.PartyFrame
    local partyFrame = CreateFrame("Frame", "CUI_PartyFrame", UIParent)
    partyFrame.groupType = "party"
    partyFrame.name = "PartyFrame"
    partyFrame.frames = {}
    partyFrame.groupChanged = true
    partyFrame:SetPoint(dbEntryP.AnchorPoint, dbEntryP.AnchorFrame, dbEntryP.AnchorRelativePoint, dbEntryP.PosX, dbEntryP.PosY)
    partyFrame:SetSize(1, 1)
    partyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    partyFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    partyFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    partyFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    partyFrame:SetScript("OnEvent", function(self, event)
        if not IsInGroup() or IsInRaid() then return end

        if event == "GROUP_ROSTER_UPDATE" then
            self.groupChanged = true
            GF.SortGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            GF.SortGroupFrames(self)
        elseif event == "PLAYER_REGEN_ENABLED" then
            GF.UpdateAlpha(self)
            if self.groupChanged then
                GF.SortGroupFrames(self)
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            GF.UpdateAlpha(self, true)
            if self.groupChanged then
                GF.SortGroupFrames(self)
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

    local dbEntryR = CUI.DB.profile.GroupFrames.RaidFrame
    local raidFrame = CreateFrame("Frame", "CUI_RaidFrame", UIParent)
    raidFrame.groupType = "raid"
    raidFrame.name = "RaidFrame"
    raidFrame.frames = {}
    raidFrame.groupChanged = true
    raidFrame:SetPoint(dbEntryR.AnchorPoint, dbEntryR.AnchorFrame, dbEntryR.AnchorRelativePoint, dbEntryR.PosX, dbEntryR.PosY)
    raidFrame:SetSize(1, 1)
    raidFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    raidFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    raidFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    raidFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    raidFrame:SetScript("OnEvent", function(self, event)
        if not IsInRaid() then return end

        if event == "GROUP_ROSTER_UPDATE" then
            self.groupChanged = true
            GF.SortGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            GF.SortGroupFrames(self)
        elseif event == "PLAYER_REGEN_ENABLED" then
            GF.UpdateAlpha(self)
            if self.groupChanged then
                GF.SortGroupFrames(self)
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            GF.UpdateAlpha(self, true)
            if self.groupChanged then
                GF.SortGroupFrames(self)
            end
        end
    end)

    for i=1, 40 do
        local frame = SetupGroupFrame("raid"..i, "raid", "RaidFrame", raidFrame, i)
        table.insert(raidFrame.frames, frame)
    end

    GF.UpdateFrame(raidFrame)
    GF.UpdateAlpha(raidFrame)
end