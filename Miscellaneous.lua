local addonName, CUI = ...

CUI.Misc = {}
local Misc = CUI.Misc

local GetCursorPosition = GetCursorPosition

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

function Misc.Load()
    SetupCursorRing()
    SetupFastLoot()
end