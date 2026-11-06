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
    f:SetPoint("CENTER", UIParent, "BOTTOMLEFT")
    f:SetSize(20, 20)

    local t = f:CreateTexture()
    t:SetParentKey("Texture")
    t:SetTexture("Interface/AddOns/CalippoUI/Media/Ring.tga")
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
        if GetCVar("autoLootDefault") ~= "1" then
            return
        end

        if IsShiftKeyDown() then
            return
        end

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
                if option.gossipOptionID and (option.flags == 1 or C_ChallengeMode.IsChallengeModeActive()) then
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
        if not dbEntry.AutoQuestGossip and not C_ChallengeMode.IsChallengeModeActive() then return end

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

local canCraft = {
    "Martyr's Bindings",
    "Martyr's Waistwrap",
    "Adherent's Silken Shroud",

    "Spellbreaker's Bracers",
    "Spellbreaker's Girdle",
    "Spellbreaker's Rebuke",

    "Blood Knight's Warblade",
    "Blood Knight's Impetus",
    "Farstrider's Mercy",
    "Farstrider's Chopper",
    "Magister's Mana Sword",
    "Magister's Ritual Knife",
    "Magister's Cleaver",
    "Spellbreaker's Blade",
    "Spellbreaker's Warglaive",
    "Bloomforged Claw",
}

local function SetupTradeAutoWhisper()
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_CHANNEL")
    f:RegisterEvent("CHAT_MSG_SYSTEM")
    f:SetScript("OnEvent", function(self, event, message, playerName)
        if issecretvalue(message) then return end

        if message == "You have received a new Personal Crafting Order." then
            PlaySoundFile("Interface/AddOns/CalippoUI/Media/kaching.ogg", "Master")
            return
        end

        if UnitName("player") ~= "Doombøm" or IsInGroup() or not CUI.DB.profile.Miscellaneous.TradeAutoWhisper.Enabled then return end

        if message then
            local looking = false

            for w in string.gmatch(message, "%a+") do
                if w == "LF" or w == "Lf" or w == "lf" or w == "LFC" or w == "Lfc" or w == "lfc" then
                    looking = true
                    break
                end
            end

            if looking then
                local items = {}
                local toCraft = {}

                for i in string.gmatch(message, "%[([%a%s%-']+)[|%]]") do
                    local item = string.gsub(i, "^%s*(.-)%s*$", "%1")
                    table.insert(items, item)
                end

                if #items > 0 then
                    for _, i1 in pairs(items) do
                        for _, i2 in pairs(canCraft) do
                            if i1 == i2 then
                                table.insert(toCraft, i1)
                                break
                            end
                        end
                    end

                    if #toCraft > 0 then
                        local whisper = "Can craft"
                        for i, v in pairs(toCraft) do
                            if i == 1 then
                                whisper = whisper.." "..v
                            else
                                whisper = whisper.." and "..v
                            end
                        end

                        whisper = whisper..". Pay what you want, use max rank mats and send to this char."

                        C_ChatInfo.SendChatMessage(whisper, "WHISPER", nil, playerName)
                    end
                end
            end
        end
    end)
end

---------------------------------------------------------------------------------------------------------------------------------

function Misc.Load()
    SetupCursorRing()
    SetupFastLoot()
    SetupAutoQuestGossip()
    SetupAutoRepairSell()
    SetupTradeAutoWhisper()
end