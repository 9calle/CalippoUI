local addonName, CUI = ...

CUI.Misc = {}
local Misc = CUI.Misc

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

    -- local ticker = C_Timer.NewTicker(0.01, function()
    --     local x, y = GetCursorPosition()
    --     f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    -- end)

    f:SetScript("OnUpdate", function(self)
        local x, y = GetCursorPosition()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    end)
end

function Misc.Load()
    SetupCursorRing()
end