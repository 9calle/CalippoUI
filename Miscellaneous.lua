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
            isContainer = false,
            iconInfo = {
                iconWidth = size,
                iconHeight = size,
                borderScale = size/20,
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

local canCraft = {
    "Martyr's Bindings",
    "Martyr's Waistwrap",
    "Adherent's Silken Shroud",

    "Blood Knight's Warblade",
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

local function UpdateGroupFinderScore(frame, profile, shouldOffset)
    if not frame.CUI_Score then
        local scoreFrame = frame:CreateFontString(nil, "OVERLAY")
        if shouldOffset then
            scoreFrame:SetPoint("CENTER", 0, -18)
        else
            scoreFrame:SetPoint("CENTER", 50, 0)
        end
        scoreFrame:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
        frame.CUI_Score = scoreFrame

        local mainScoreFrame = frame:CreateFontString(nil, "OVERLAY")
        mainScoreFrame:SetPoint("LEFT", scoreFrame, "RIGHT", 3, 0)
        mainScoreFrame:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
        frame.CUI_MainScore = mainScoreFrame

        local raidProgress = frame:CreateFontString(nil, "OVERLAY")
        raidProgress:SetPoint("LEFT", mainScoreFrame, "RIGHT", 0, 0)
        raidProgress:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
        raidProgress:SetTextColor(0.64, 0.21, 0.93)
        frame.CUI_RaidProg = raidProgress

        local mainRaidProgress = frame:CreateFontString(nil, "OVERLAY")
        mainRaidProgress:SetPoint("LEFT", raidProgress, "RIGHT", 3, 0)
        mainRaidProgress:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
        mainRaidProgress:SetTextColor(0.64, 0.21, 0.93)
        frame.CUI_MainRaidProg = mainRaidProgress
    end
    
    if profile and profile.mythicKeystoneProfile then
        local score = profile.mythicKeystoneProfile.currentScore
        local r, g, b = RaiderIO.GetScoreColor(score)
        frame.CUI_Score:SetText(score)
        frame.CUI_Score:SetTextColor(r, g, b)

        if profile.mythicKeystoneProfile.mainCurrentScore and profile.mythicKeystoneProfile.mainCurrentScore ~= 0 then
            local mainScore = profile.mythicKeystoneProfile.mainCurrentScore
            r, g, b = RaiderIO.GetScoreColor(mainScore)

            frame.CUI_MainScore:SetText("("..mainScore..") ")
            frame.CUI_MainScore:SetTextColor(r, g, b)
        else
            frame.CUI_MainScore:SetText("")
        end
    end

    if profile and profile.raidProfile then
        for i, raid in ipairs(profile.raidProfile.progress) do
            if raid.difficulty == 3 then
                frame.CUI_RaidProg:SetText("| "..raid.progressCount)
                break
            else
                frame.CUI_RaidProg:SetText("")
            end
        end
    end
end

local function SetupGroupFinder()
    hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(self, applicantID)
        if InCombatLockdown() then return end

        local applicantInfo = C_LFGList.GetApplicantInfo(applicantID)
        local name = C_LFGList.GetApplicantMemberInfo(applicantID, applicantInfo.numMembers)

        if self.Member1 and self.Member1.Rating then
            self.Member1.Rating:Hide()
        end

        if not RaiderIO then return end
        local profile = RaiderIO.GetProfile(name)

        if profile then
            UpdateGroupFinderScore(self, profile)
        end
    end)

    hooksecurefunc("LFGListSearchEntry_Update", function(self)
        if InCombatLockdown() then return end

        local searchResultData = C_LFGList.GetSearchResultInfo(self.resultID)

        if not RaiderIO then return end
        local profile = RaiderIO.GetProfile(searchResultData.leaderName)
        
        if profile then
            UpdateGroupFinderScore(self, profile, true)
        end
    end)
end

---------------------------------------------------------------------------------------------------------------------------------

function Misc.Load()
    SetupCursorRing()
    SetupFastLoot()
    SetupAutoQuestGossip()
    SetupAutoRepairSell()
    SetupPrivateAuras()
    SetupTradeAutoWhisper()
    SetupGroupFinder()
end