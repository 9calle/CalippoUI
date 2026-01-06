local addonName, CUI = ...

CUI.CDM = {}
local CDM = CUI.CDM
local Util = CUI.Util

local cooldownViewers = {
    EssentialCooldownViewer,
    UtilityCooldownViewer,
    BuffIconCooldownViewer,
}

---------------------------------------------------------------------------------------------------

function CDM.UpdateAlpha(frame, inCombat)
    if not frame:IsShown() then return end
    local dbEntry = CUI.DB.profile.CooldownManager[frame:GetName()]

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
    end
end

function CDM.UpdateStyle(viewer)
    local dbEntry = CUI.DB.profile.CooldownManager[viewer:GetName()]

    for _, frame in ipairs({viewer:GetChildren()}) do
        if frame.Icon then
            frame.Icon:SetTexCoord(.08, .92, .08, .92)

            local mask = frame.Icon:GetMaskTexture(1)
            if mask then
                frame.Icon:RemoveMaskTexture(mask)

                local _, _, overlay = frame:GetRegions()
                overlay:Hide()
            end

            if not frame.Border then
                local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
                border:SetParentKey("Border")
                border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
                border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
                border:SetBackdrop({
                    edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorderWhite.tga",
                    edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) * 3,
                    bgFile = nil
                })
                border:SetBackdropBorderColor(0, 0, 0, 1)
            end
        end

        if frame.DebuffBorder then
            local debuffBorder = frame.DebuffBorder

            debuffBorder:ClearAllPoints()
            debuffBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -6, 6)
            debuffBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 6, -6)
        end

        if frame.Applications then
            local applications = frame.Applications.Applications
            local dbEntryA = dbEntry.Charges

            applications:SetFont(dbEntryA.Font, dbEntryA.Size, dbEntryA.Outline)
            local c = dbEntryA.Color
            applications:SetTextColor(c.r, c.g, c.b, c.a)
            applications:ClearAllPoints()
            applications:SetPoint(dbEntryA.AnchorPoint, frame, dbEntryA.AnchorRelativePoint, dbEntryA.PosX, dbEntryA.PosY)
        end

        if frame.ChargeCount then
            local chargeCount = frame.ChargeCount.Current
            local dbEntryC = dbEntry.Charges

            chargeCount:SetFont(dbEntryC.Font, dbEntryC.Size, dbEntryC.Outline)
            local c = dbEntryC.Color
            chargeCount:SetTextColor(c.r, c.g, c.b, c.a)
            chargeCount:ClearAllPoints()
            chargeCount:SetPoint(dbEntryC.AnchorPoint, frame, dbEntryC.AnchorRelativePoint, dbEntryC.PosX, dbEntryC.PosY)
        end

        if frame.Cooldown then
            local dbEntryCD = dbEntry.Cooldown

            frame.Cooldown:SetSwipeTexture("", 1, 1, 1, 1)

            local text = frame.Cooldown:GetRegions()
            text:SetFont(dbEntryCD.Font, dbEntryCD.Size, dbEntryCD.Outline)
            local c = dbEntryCD.Color
            text:SetTextColor(c.r, c.g, c.b, c.a)
            text:ClearAllPoints()
            text:SetPoint(dbEntryCD.AnchorPoint, frame, dbEntryCD.AnchorRelativePoint, dbEntryCD.PosX, dbEntryCD.PosY)
        end

        if frame.OutOfRange then
            frame.OutOfRange:SetScript("OnShow", function(self)
                self:Hide()
            end)
        end

        if frame.CooldownFlash then
            frame.CooldownFlash:SetScript("OnShow", function(self)
                self:Hide()
            end)
        end

        -- TODO
        -- frame:HookScript("OnUpdate", function(self)
        --     if self.PandemicIcon and self.PandemicIcon.Border.Border:IsShown() then
        --         print("SHOW")
        --         self.Border:SetBackdropBorderColor(1, 0, 0, 1)

        --         self.PandemicIcon:Hide()
        --         self.PandemicIcon.FX:Hide()
        --         self.PandemicIcon.Border.Border:Hide()

        --         self.PandemicIcon:HookScript("OnShow", function()
        --             print("OnShow")
        --             self.Border:SetBackdropBorderColor(1, 0, 0, 1)
        --         end)

        --         self.PandemicIcon:HookScript("OnHide", function()
        --             print("OnHide")
        --             self.Border:SetBackdropBorderColor(0, 0, 0, 1)
        --         end)
        --     end
        -- end)
    end
end

---------------------------------------------------------------------------------------------------

local function UpdatePositions(viewer)
    local padding = viewer.childXPadding
    local rowSize = viewer.iconLimit

    local viewerName = viewer:GetName()

    local frameSize
    if viewerName == "EssentialCooldownViewer" then
        frameSize = 50
    elseif viewerName == "UtilityCooldownViewer" then
        frameSize = 30
    elseif viewerName == "BuffIconCooldownViewer" then
        frameSize = 40
    end

    local frames = {}
    for _, frame in ipairs({viewer:GetChildren()}) do
        if frame.Cooldown and frame.Icon and frame:IsShown() then
            table.insert(frames, frame)
        end
    end
    viewer.frameCount = #frames

    table.sort(frames, function(a, b)
        local a2 = a.layoutIndex or 1000
        local b2 = b.layoutIndex or 1000
        return a2 < b2
    end)

    local lastRow
    local lastRowSize
    local lastRowOffest
    local starts
    local ends

    if viewerName == "BuffIconCooldownViewer" then
        lastRowOffest = ((frameSize + padding) * (#frames - 1)) / 2 + padding
        starts = 1
        ends = #frames
    else
        lastRow = math.ceil(#frames / rowSize) - 1
        lastRowSize = #frames % rowSize

        if lastRowSize == 0 or lastRowSize == #frames then return end

        starts = (rowSize*lastRow) + 1
        ends = #frames
        lastRowOffest = (frameSize + padding) * ((rowSize - lastRowSize) / 2)
    end

    for index=starts, ends do
        local frame = frames[index]
        index = index - 1
        local row = math.floor(index/rowSize)

        frame:ClearAllPoints()

        if viewerName == "BuffIconCooldownViewer" then
            frame:SetPoint("CENTER", viewer, "CENTER", (index*(frameSize+padding))-lastRowOffest, 0)
        elseif row == lastRow and row ~= 0 and lastRowSize ~= rowSize then
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowSize*(frameSize+padding))+lastRowOffest, -(row*(frameSize+padding)))
        else
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowSize*(frameSize+padding)), -(row*(frameSize+padding)))
        end
    end
end

local function HookScripts(viewer)
    local dbEntry = CUI.DB.profile.CooldownManager[viewer:GetName()]

    viewer:HookScript("OnSizeChanged", function(self)
        CDM.UpdateStyle(self)
        if dbEntry.CenterIcons then
            UpdatePositions(self)
        end
    end)

    viewer:HookScript("OnShow", function(self)
        CDM.UpdateAlpha(self)
        if dbEntry.CenterIcons then
            UpdatePositions(self)
        end
    end)

    viewer:RegisterEvent("PLAYER_REGEN_ENABLED")
    viewer:RegisterEvent("PLAYER_REGEN_DISABLED")
    viewer:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            CDM.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            CDM.UpdateAlpha(self, true)
        end
    end)

    if viewer:GetName() == "BuffIconCooldownViewer" then
        hooksecurefunc(viewer, "OnAcquireItemFrame", function(self, itemFrame)
            itemFrame:SetScript("OnShow", function()
                if dbEntry.CenterIcons then
                    UpdatePositions(self)
                end
            end)

            itemFrame:SetScript("OnHide", function()
                if dbEntry.CenterIcons then
                    UpdatePositions(self)
                end
            end)
        end)
    end
end

---------------------------------------------------------------------------------------------------

function CDM.Load()
    C_CVar.SetCVar("cooldownViewerEnabled", 1)

    for _, viewer in pairs(cooldownViewers) do
        CDM.UpdateAlpha(viewer)
        HookScripts(viewer)
    end
end