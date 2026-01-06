local addonName, CUI = ...

CUI.AW = {}
local AW = CUI.AW

local canCraft = {
    "Charged Claymore",
    "Charged Facesmasher",
    "Charged Halberd",
    "Charged Hexsword",
    "Charged Invoker",
    "Everforged Dagger",
    "Everforged Greataxe",
    "Everforged Longsword",
    "Everforged Mace",
    "Everforged Stabber",
    "Everforged Warglaive",

    "Ironclaw Great Mace",
    "Ironclaw Knuckles",
    "Ironclaw Axe",
    "Ironclaw Sword",
    "Ironclaw Dirk",
    "Ironclaw Great Axe",
    "Ironclaw Stiletto",

    "Everforged Defender",
    "Everforged Gauntlets",
    "Everforged Greatbelt",
    "Everforged Vambraces",
    "Everforged Breastplate",
    "Everforged Pauldrons",
    "Everforged Legplates",
    "Everforged Helm",
    "Everforged Sabatons",

    "Dredger's Developed Legplates" ,
    "Dredger's Developed Pauldrons",
    "Dredger's Developed Gauntlets",
    "Dredger's Developed Helm",
    "Dredger's Developed Defender",
    "Dredger's Developed Greatbelt",
    "Dredger's Plate Vambraces",
    "Dredger's Plate Breastplate",
    "Dredger's Plate Sabatons",
}

function AW.Load()
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_CHANNEL")
    f:RegisterEvent("CHAT_MSG_SYSTEM")
    f:SetScript("OnEvent", function(self, event, message, playerName)
        if UnitName("player") ~= "Grimrizzler" or IsInGroup() or not CUI.DB.profile.AutoWhisper.Enabled then return end

        if message == "You have received a new Personal Crafting Order." then
            PlaySoundFile("Interface/AddOns/CalippoUI/Media/kaching.ogg", "Master")
            return
        end

        if message then
            local looking = false

            for w in string.gmatch(message, "%a+") do
                if w == "LF" or w == "lf" or w == "Lf" or w == "LFC" or w == "Lfc" or w == "lfc" then
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

                        whisper = whisper..", pay what you want! Send to this char."

                        C_ChatInfo.SendChatMessage(whisper, "WHISPER", nil, playerName)
                    end
                end
            end
        end
    end)
end