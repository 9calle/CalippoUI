local addonName, CUI = ...

CUI.Misc = {}
local Misc = CUI.Misc

local GetCursorPosition = GetCursorPosition

---------------------------------------------------------------------------------------------------------------------------------

function Misc.UpdateCursorRing()
    local dbEntry = CUI.DB.profile.Miscellaneous.CursorRing

    local cR = CUI_CursorRing
    cR:SetSize(dbEntry.Size, dbEntry.Size)

    local color = dbEntry.Color
    cR.Texture:SetVertexColor(color.r, color.g, color.b, color.a)

    if dbEntry.Enabled then
        cR:Show()
    else
        cR:Hide()
    end
end

local function SetupCursorRing()
    local f = CreateFrame("Frame", "CUI_CursorRing")
    local t = f:CreateTexture()
    t:SetParentKey("Texture")
    t:SetTexture("Interface/AddOns/CalippoUI/Media/Ring.blp")
    t:SetAllPoints(f)

    Misc.UpdateCursorRing()

    f:SetScript("OnUpdate", function(self)
        local x, y = GetCursorPosition()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    end)
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupFastLoot()
    local f = CreateFrame("Frame")
    f:RegisterEvent("LOOT_READY")

    f:SetScript("OnEvent", function()
        for i=1, GetNumLootItems() do
            LootSlot(i)
        end

        CloseLoot()
    end)
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupAutoQuestGossip()
    local function HandleGossip()
        local active = C_GossipInfo.GetActiveQuests()
        if active then
            for _, quest in ipairs(active) do
                if quest.isComplete then
                    C_GossipInfo.SelectActiveQuest(quest.questID)
                    return
                end
            end
        end

        local available = C_GossipInfo.GetAvailableQuests()
        if available then
            for _, quest in ipairs(available) do
                C_GossipInfo.SelectAvailableQuest(quest.questID)
                return
            end
        end

        local options = C_GossipInfo.GetOptions()
        if options then
            for _, option in ipairs(options) do
                if option.gossipOptionID and option.flags == 1 then
                    C_GossipInfo.SelectOption(option.gossipOptionID)
                    return
                end
            end
        end
    end

    local function HandleGreeting()
        for i = 1, GetNumActiveQuests() do
            local title, isComplete = GetActiveTitle(i)
            if isComplete then
                SelectActiveQuest(i)
                return
            end
        end

        for i = 1, GetNumAvailableQuests() do
            SelectAvailableQuest(i)
            return
        end
    end

    local function HandleQuestComplete()
        local numChoices

        if C_QuestInfo and C_QuestInfo.GetNumQuestChoices then
            numChoices = C_QuestInfo.GetNumQuestChoices()
        else
            numChoices = GetNumQuestChoices()
        end

        if numChoices == 0 or numChoices == 1 then
            GetQuestReward(1)
        end
    end

    local dbEntry = CUI.DB.profile.Miscellaneous.General

    local f = CreateFrame("Frame")
    f:RegisterEvent("GOSSIP_SHOW")
    f:RegisterEvent("QUEST_GREETING")
    f:RegisterEvent("QUEST_DETAIL")
    f:RegisterEvent("QUEST_PROGRESS")
    f:RegisterEvent("QUEST_COMPLETE")
    f:SetScript("OnEvent", function(self, event)
        if not dbEntry.AutoQuestGossip then return end

        if event == "GOSSIP_SHOW" then
            HandleGossip()
        elseif event == "QUEST_GREETING" then
            HandleGreeting()
        elseif event == "QUEST_DETAIL" then
            AcceptQuest()
        elseif event == "QUEST_PROGRESS" then
            if IsQuestCompletable() then
                CompleteQuest()
            end
        elseif event == "QUEST_COMPLETE" then
            HandleQuestComplete()
        end
    end)
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupAutoRepairSell()
    local dbEntry = CUI.DB.profile.Miscellaneous.General

    local f = CreateFrame("Frame")
    f:RegisterEvent("MERCHANT_SHOW")
    f:SetScript("OnEvent", function()
        if not dbEntry.AutoRepairVendor then return end

        if CanMerchantRepair() then
            local cost = GetRepairAllCost()
            if cost and cost > 0 then
                if IsInGuild() and CanGuildBankRepair() then
                    RepairAllItems(true)
                else
                    RepairAllItems()
                end
            end
        end

        if C_MerchantFrame and C_MerchantFrame.SellAllJunkItems then
            C_MerchantFrame.SellAllJunkItems()
        end
    end)
end

---------------------------------------------------------------------------------------------------------------------------------

function Misc.UpdatePrivateAuraAnchors(show)
    local dbEntry = CUI.DB.profile.Miscellaneous.PrivateAuras
    local anchorPoint = dbEntry.AnchorPoint
    local anchorRelativePoint = dbEntry.AnchorRelativePoint
    local dirH = dbEntry.DirH
    local dirV = dbEntry.DirV
    local size = dbEntry.Size
    local padding = dbEntry.Padding
    local posX = dbEntry.PosX
    local posY = dbEntry.PosY
    local rowLength = dbEntry.RowLength

    for i=1, 6 do
        local container = _G["CUI_PrivateAura"..i]
        container:SetSize(size, size)
        CUI.Util.PositionFromIndex(i-1, container, UIParent, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        container.TestTexture:SetShown(show)
    end
end

local function SetupPrivateAuras()
    local dbEntry = CUI.DB.profile.Miscellaneous.PrivateAuras
    if not dbEntry.Enabled then return end

    local anchorPoint = dbEntry.AnchorPoint
    local anchorRelativePoint = dbEntry.AnchorRelativePoint
    local dirH = dbEntry.DirH
    local dirV = dbEntry.DirV
    local size = dbEntry.Size
    local padding = dbEntry.Padding
    local posX = dbEntry.PosX
    local posY = dbEntry.PosY
    local rowLength = dbEntry.RowLength

    for i=1, 6 do
        local container = CreateFrame("Frame", "CUI_PrivateAura"..i, UIParent)
        container:SetSize(size, size)
        CUI.Util.PositionFromIndex(i-1, container, UIParent, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        local texture = container:CreateTexture(nil, "OVERLAY")
        texture:SetParentKey("TestTexture")
        texture:SetAllPoints(container)
        texture:SetColorTexture(0, 0, 0, 1)
        texture:Hide()

        C_UnitAuras.AddPrivateAuraAnchor({
            unitToken = "player",
            auraIndex = i,
            parent = container,
            showCountdownFrame = true,
            showCountdownNumbers = true,
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
    end
end

---------------------------------------------------------------------------------------------------------------------------------

function Misc.Load()
    SetupCursorRing()
    SetupFastLoot()
    SetupAutoQuestGossip()
    SetupAutoRepairSell()
    SetupPrivateAuras()
end