local addonName, CUI = ...

-- TODO : Glöm inte att ta bort.
SetCVar("secretCombatRestrictionsForced", 1)
SetCVar("secretEncounterRestrictionsForced", 1)
SetCVar("secretChallengeModeRestrictionsForced", 1)
SetCVar("secretMapRestrictionsForced", 1)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if isLogin or isReload then
        CUI.Database.Load()

        local dbEntry = CUI.DB.profile

        if dbEntry.Chat.Enabled then
            CUI.Chat.Load()
        end

        if dbEntry.ResourceBar.Enabled then
            CUI.RB.Load()
        end

        if dbEntry.UnitFrames.Enabled then
            CUI.UF.Load()
        end

        if dbEntry.GroupFrames.Enabled then
            CUI.GF.Load()
        end

        if dbEntry.ActionBars.Enabled then
            CUI.AB.Load()
        end

        if dbEntry.CooldownManager.Enabled then
            CUI.CDM.Load()
        end

        if dbEntry.PlayerCastBar.Enabled then
            CUI.CB.Load()
        end

        if dbEntry.Minimap.Enabled then
            CUI.MM.Load()
        end

        if dbEntry.PlayerAuras.Enabled then
            CUI.PA.Load()
        end

        if dbEntry.Nameplates.Enabled then
            CUI.NP.Load()
        end
    end
end)

SLASH_CALIPPOUI1 = "/cui"
function SlashCmdList.CALIPPOUI(msg, editbox)
    CUI.Conf.Load()
end