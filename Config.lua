local addonName, CUI = ...

CUI.Conf = {}
local Conf = CUI.Conf
local AB = CUI.AB
local UF = CUI.UF
local CDM = CUI.CDM
local PA = CUI.PA
local RB = CUI.RB
local MM = CUI.MM
local CB = CUI.CB
local GF = CUI.GF

local AceGUI = LibStub("AceGUI-3.0")

---------------------------------------------------------------------------------------------------------------------------------------

local anchorPoints = {
    ["TOPLEFT"] = "Top Left",
    ["TOPRIGHT"] = "Top Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOMRIGHT"] = "Bottom Right",
    ["TOP"] = "Top",
    ["BOTTOM"] = "Bottom",
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
    ["CENTER"] = "Center",
}

local directionsHorizontal = {
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
}

local directionsVertical = {
    ["UP"] = "Up",
    ["DOWN"] = "Down",
}

local outlines = {
    [""] = "None",
    ["OUTLINE"] = "Outline",
    ["THICKOUTLINE"] = "Thick",
    ["MONOCHROME"] = "Monochrome",
}

---------------------------------------------------------------------------------------------------------------------------------------

local function ReverseHashTable(table)
    local newTable = {}
    for k, v in pairs(table) do
        newTable[v] = k
    end
    return newTable
end

local fonts
local textures

local function CreateInlineGroup(container, title)
    local inlineGroup = AceGUI:Create("InlineGroup")
    inlineGroup:SetTitle(title)
    inlineGroup:SetLayout("Flow")
    inlineGroup:SetRelativeWidth(1)
    container:AddChild(inlineGroup)
    return inlineGroup
end

local function CreateSlider(container, label, min, max, step, value, func, width)
    local slider = AceGUI:Create("Slider")
    slider:SetLabel(label)
    slider:SetSliderValues(min, max, step)
    slider:SetValue(value)
    slider:SetCallback("OnValueChanged", func)
    if width then slider:SetRelativeWidth(width) end
    container:AddChild(slider)
    return slider
end

local function CreateCheckBox(container, label, value, func, width)
    local checkBox = AceGUI:Create("CheckBox")
    checkBox:SetLabel(label)
    checkBox:SetValue(value)
    checkBox:SetCallback("OnValueChanged", func)
    if width then checkBox:SetRelativeWidth(width) end
    container:AddChild(checkBox)
    return checkBox
end

local function CreateEditBox(container, label, value, func, width)
    local editBox = AceGUI:Create("EditBox")
    editBox:SetLabel(label)
    editBox:SetText(value)
    editBox:SetCallback("OnEnterPressed", func)
    if width then editBox:SetRelativeWidth(width) end
    container:AddChild(editBox)
end

local function CreateDropDown(container, label, value, list, func, width)
    local dropDown = AceGUI:Create("Dropdown")
    dropDown:SetLabel(label)
    dropDown:SetList(list)
    dropDown:SetValue(value)
    dropDown:SetCallback("OnValueChanged", func)
    if width then dropDown:SetRelativeWidth(width) end
    container:AddChild(dropDown)
end

local function CreateColorPicker(container, label, value, func, width, alpha)
    local colorPicker = AceGUI:Create("ColorPicker")
    colorPicker:SetHasAlpha(alpha)
    colorPicker:SetLabel(label)
    colorPicker:SetColor(value.r, value.g, value.b, value.a)
    colorPicker:SetCallback("OnValueChanged", func)
    if width then colorPicker:SetRelativeWidth(width) end
    container:AddChild(colorPicker)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateAnchorGroup(container, dbEntry, func, frame)
    local anchorGroup = CreateInlineGroup(container, "Anchor")

    CreateEditBox(anchorGroup, "Anchor Frame", dbEntry.AnchorFrame,
        function(self, event, value)
            local frameExists = _G[value]
            if frameExists then
                dbEntry.AnchorFrame = value
                func(frame)
            else
                print("Frame does not exist!")
                self:SetText(dbEntry.AnchorFrame)
            end
        end, 0.33)

    CreateDropDown(anchorGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            func(frame)
        end, 0.33)
        
    CreateDropDown(anchorGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            func(frame)
        end, 0.33)
        
    CreateSlider(anchorGroup, "Position X", -1000, 1000, 0.1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            func(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Position Y", -1000, 1000, 0.1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            func(frame)
        end, 0.5)

    return anchorGroup
end

local function CreateAnchorGroupWithoutFrame(container, dbEntry, func, frame)
    local anchorGroup = CreateInlineGroup(container, "Anchor")

    CreateDropDown(anchorGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            func(frame)
        end, 0.5)
        
    CreateDropDown(anchorGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            func(frame)
        end, 0.5)
        
    CreateSlider(anchorGroup, "Position X", -1000, 1000, 0.1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            func(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Position Y", -1000, 1000, 0.1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            func(frame)
        end, 0.5)

    return anchorGroup
end

local function CreateAlphaGroup(container, dbEntry, func, frame)
    local alphaGroup = CreateInlineGroup(container, "Alpha") 

    CreateSlider(alphaGroup, "Alpha (Out of combat)", 0, 100, 1, dbEntry.Alpha*100, 
        function(self, event, value)
            dbEntry.Alpha = value/100
            func(frame)
        end, 0.5)

    CreateSlider(alphaGroup, "Alpha (In Combat)", 0, 100, 1, dbEntry.CombatAlpha*100, 
        function(self, event, value)
            dbEntry.CombatAlpha = value/100
            func(frame)
        end, 0.5)

    return alphaGroup
end

local function CreateSizeGroup(container, dbEntry, func, frame)
    local sizeGroup = CreateInlineGroup(container, "Size")

    CreateSlider(sizeGroup, "Width", 1, 500, 1, dbEntry.Width,
        function(self, event, value)
            dbEntry.Width = value
            func(frame)
        end, 0.5)

    CreateSlider(sizeGroup, "Height", 1, 500, 1, dbEntry.Height,
        function(self, event, value)
            dbEntry.Height = value
            func(frame)
        end, 0.5)

    return sizeGroup
end

local function CreateColorGroup(container, dbEntry, func, frame)
    local colorGroup = CreateInlineGroup(container, "Color")

    local colorPicker = AceGUI:Create("ColorPicker")
    colorPicker:SetColor(dbEntry.Color.r, dbEntry.Color.g, dbEntry.Color.b, dbEntry.Color.a)
    colorPicker:SetCallback("OnValueChanged",
        function(self, event, r, g, b, a)
            dbEntry.Color.r = r
            dbEntry.Color.g = g
            dbEntry.Color.b = b
            dbEntry.Color.a = a

            func(frame)
        end)
    colorGroup:AddChild(colorPicker)

    return colorGroup
end

local function CreateTextGroup(container, dbEntry, func, frame, text, colorOption)
    local textGroup = CreateInlineGroup(container, text)

    CreateCheckBox(textGroup, "Toggle "..text, dbEntry.Enabled,
        function(self, event, value)
            dbEntry.Enabled = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, text.." Font Size", 1, 50, 1, dbEntry.Size, 
        function(self, event, value)
            dbEntry.Size = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, "Position X", -100, 100, 1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, "Position Y", -100, 100, 1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Font", dbEntry.Font, fonts,
        function(self, event, value)
            dbEntry.Font = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Outline", dbEntry.Outline, outlines,
        function(self, event, value)
            dbEntry.Outline = value
            func(frame)
        end, 0.5)

    if colorOption then
        CreateColorPicker(textGroup, "Color", dbEntry.Color,
            function(self, event, r, g, b, a)
                dbEntry.Color.r = r
                dbEntry.Color.g = g
                dbEntry.Color.b = b
                dbEntry.Color.a = a

                func(frame)
            end, 1)
    end

    return textGroup
end

local function CreateTextGroupWithoutToggle(container, dbEntry, func, frame, text, colorOption)
    local textGroup = CreateInlineGroup(container, text)

    CreateSlider(textGroup, text.." Font Size", 1, 50, 1, dbEntry.Size, 
        function(self, event, value)
            dbEntry.Size = value
            func(frame)
        end, 1)

    CreateDropDown(textGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, "Position X", -100, 100, 1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, "Position Y", -100, 100, 1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Font", dbEntry.Font, fonts,
        function(self, event, value)
            dbEntry.Font = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Outline", dbEntry.Outline, outlines,
        function(self, event, value)
            dbEntry.Outline = value
            func(frame)
        end, 0.5)

    if colorOption then
        CreateColorPicker(textGroup, "Color", dbEntry.Color,
            function(self, event, r, g, b, a)
                dbEntry.Color.r = r
                dbEntry.Color.g = g
                dbEntry.Color.b = b
                dbEntry.Color.a = a

                func(frame)
            end, 1)
    end

    return textGroup
end

local function CreateTextureGroup(container, dbEntry, func, frame)
    local textureGroup = CreateInlineGroup(container, "Texture")

    CreateDropDown(textureGroup, "", dbEntry.Texture, textures,
        function(self, event, value)
            dbEntry.Texture = value
            func(frame)
        end, 1)

    return textureGroup
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateGeneralSettings(container)
    local dbEntry = CUI.DB.profile

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local modulesGroup = CreateInlineGroup(scrollFrame, "Toggle Modules (Reload to apply changes)")

    CreateCheckBox(modulesGroup, "Action Bars", dbEntry.ActionBars.Enabled,
        function(self, event, value)
            dbEntry.ActionBars.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Unit Frames", dbEntry.UnitFrames.Enabled,
        function(self, event, value)
            dbEntry.UnitFrames.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Cooldown Manager", dbEntry.CooldownManager.Enabled,
        function(self, event, value)
            dbEntry.CooldownManager.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Resource Bar", dbEntry.ResourceBar.Enabled,
        function(self, event, value)
            dbEntry.ResourceBar.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Player Cast Bar", dbEntry.PlayerCastBar.Enabled,
        function(self, event, value)
            dbEntry.PlayerCastBar.Enabled = value
        end, 0.33)

    -- CreateCheckBox(modulesGroup, "Nameplates (WIP)", dbEntry.Nameplates.Enabled,
    --     function(self, event, value)
    --         dbEntry.Nameplates.Enabled = value
    --     end, 0.33)

    CreateCheckBox(modulesGroup, "Group Frames", dbEntry.GroupFrames.Enabled,
        function(self, event, value)
            dbEntry.GroupFrames.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Minimap", dbEntry.Minimap.Enabled,
        function(self, event, value)
            dbEntry.Minimap.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "PlayerAuras", dbEntry.PlayerAuras.Enabled,
        function(self, event, value)
            dbEntry.PlayerAuras.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Chat", dbEntry.Chat.Enabled,
        function(self, event, value)
            dbEntry.Chat.Enabled = value
        end, 0.33)

    local reloadButton = AceGUI:Create("Button")
    reloadButton:SetText("Reload")
    reloadButton:SetCallback("OnClick", function() ReloadUI() end)
    reloadButton:SetRelativeWidth(1)
    modulesGroup:AddChild(reloadButton)

    local miscGroup = CreateInlineGroup(scrollFrame, "Misc")

    CreateSlider(miscGroup, "Spell Queue Window", 0, 400, 1, C_CVar.GetCVar("SpellQueueWindow"),
        function(self, event, value)
            SetCVar("SpellQueueWindow", value)
        end, 1)

    scrollFrame:DoLayout()
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateActionBarFramePage(container, actionBar)
    local dbEntry = CUI.DB.profile.ActionBars[actionBar]
    local frame = _G[actionBar]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    CreateAlphaGroup(scrollFrame, dbEntry, AB.UpdateAlpha, frame)

    if actionBar == "MicroMenu" or actionBar == "BagsBar" then return end

    local paddingGroup = CreateInlineGroup(scrollFrame, "Padding")

    CreateSlider(paddingGroup, "Padding (Overrides padding from edit mode)", 0, 15, 0.1, dbEntry.Padding,
        function(self, event, value)
            dbEntry.Padding = value
            AB.UpdateBar(frame)
        end, 1)

    local anchorGroup = CreateInlineGroup(scrollFrame, "Anchor")

    CreateCheckBox(anchorGroup, "Toggle Anchoring (Overrides edit mode placement)", dbEntry.ShouldAnchor,
        function(self, event, value)
            dbEntry.ShouldAnchor = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateEditBox(anchorGroup, "Anchor Frame", dbEntry.AnchorFrame,
        function(self, event, value)
            local frameExists = _G[value]
            if frameExists then
                dbEntry.AnchorFrame = value
                AB.UpdateBarAnchor(frame)
            else
                print("Frame does not exist!")
                self:SetText(dbEntry.AnchorFrame)
            end
        end, 0.5)

    CreateDropDown(anchorGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateDropDown(anchorGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Position X", -1000, 1000, 0.1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Position Y", -1000, 1000, 0.1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    scrollFrame:DoLayout()
end

local function CreateActionBarTextPage(container, actionBar, type)
    local dbEntry = CUI.DB.profile.ActionBars[actionBar][type]
    local frame = _G[actionBar]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    CreateTextGroup(scrollFrame, dbEntry, AB.UpdateBar, frame, type)

    scrollFrame:DoLayout()
end

local function CreateActionBarTabs(container, actionBar)
    local function SelectGroup(container, event, type)
        container:ReleaseChildren()
        if type == "Frame" then
            CreateActionBarFramePage(container, actionBar)
        else
            CreateActionBarTextPage(container, actionBar, type)
        end
    end

    local tabs
    if actionBar == "MicroMenu" or actionBar == "BagsBar" or actionBar == "StanceBar" then
        tabs = {{text="Frame", value="Frame"}}
    else
        tabs = {{text="Frame", value="Frame"},
                {text="Cooldown", value="Cooldown"},
                {text="Charges", value="Charges"},
                {text="Keybind", value="Keybind"},
                {text="Macro", value="Macro"},}
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs(tabs)
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Frame")

    container:AddChild(tabGroup)
end

local function CreateActionBarSettings(container)
    local function SelectGroup(container, event, actionBar)
        container:ReleaseChildren()
        CreateActionBarTabs(container, actionBar)
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Action Bar 1", value="MainActionBar"}, 
                    {text="Action Bar 2", value="MultiBarBottomLeft"},
                    {text="Action Bar 3", value="MultiBarBottomRight"},
                    {text="Action Bar 4", value="MultiBarRight"},
                    {text="Action Bar 5", value="MultiBarLeft"},
                    {text="Action Bar 6", value="MultiBar5"},
                    {text="Action Bar 7", value="MultiBar6"},
                    {text="Action Bar 8", value="MultiBar7"},
                    {text="Pet Action Bar", value="PetActionBar"},
                    {text="Stance Bar", value="StanceBar"},
                    {text="Micro Menu", value="MicroMenu"},
                    {text="Bags Bar", value="BagsBar"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("MainActionBar")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local bossTestFrames = false

local function CreateUnitFrameGeneralPage(container)
    local dbEntry = CUI.DB.profile.UnitFrames

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local textureGroup = CreateInlineGroup(scrollFrame, "Textures")

    CreateDropDown(textureGroup, "Health", dbEntry.HealthBar.Texture, textures,
        function(self, event, value)
            dbEntry.HealthBar.Texture = value
            UF.UpdateAllFrames()
        end, 0.33)

    CreateDropDown(textureGroup, "Power", dbEntry.PowerBar.Texture, textures,
        function(self, event, value)
            dbEntry.PowerBar.Texture = value
            UF.UpdateAllFrames()
        end, 0.33)

    CreateDropDown(textureGroup, "Shield", dbEntry.DamageAbsorbBar.Texture, textures,
        function(self, event, value)
            dbEntry.DamageAbsorbBar.Texture = value
            UF.UpdateAllFrames()
        end, 0.33)

    CreateDropDown(textureGroup, "Heal absorb", dbEntry.HealAbsorbBar.Texture, textures,
        function(self, event, value)
            dbEntry.HealAbsorbBar.Texture = value
            UF.UpdateAllFrames()
        end, 0.33)

    CreateDropDown(textureGroup, "Cast bar", dbEntry.CastBar.Texture, textures,
        function(self, event, value)
            dbEntry.CastBar.Texture = value
            UF.UpdateAllFrames()
        end, 0.33)

    local healthColorGroup = CreateInlineGroup(scrollFrame, "Health bar colors")

    CreateCheckBox(healthColorGroup, "Toggle custom colors", dbEntry.HealthBar.CustomColor,
        function(self, event, value)
            dbEntry.HealthBar.CustomColor = value
            UF.UpdateAllFrames()
        end, 0.5)

    CreateColorPicker(healthColorGroup, "Health Bar", dbEntry.HealthBar.Color,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.Color.r = r
            dbEntry.HealthBar.Color.g = g
            dbEntry.HealthBar.Color.b = b
            dbEntry.HealthBar.Color.a = a

            UF.UpdateAllFrames()
        end, 0.5)

    CreateColorPicker(healthColorGroup, "Background", dbEntry.HealthBar.BackgroundColor,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.BackgroundColor.r = r
            dbEntry.HealthBar.BackgroundColor.g = g
            dbEntry.HealthBar.BackgroundColor.b = b
            dbEntry.HealthBar.BackgroundColor.a = a

            UF.UpdateAllFrames()
        end, 0.5)

    CreateColorPicker(healthColorGroup, "Healing Prediction", dbEntry.HealthBar.HealPredictionColor,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.HealPredictionColor.r = r
            dbEntry.HealthBar.HealPredictionColor.g = g
            dbEntry.HealthBar.HealPredictionColor.b = b
            dbEntry.HealthBar.HealPredictionColor.a = a

            UF.UpdateAllFrames()
        end, 0.5)

    local absorbColorGroup = CreateInlineGroup(scrollFrame, "Shield / Heal Absorb / Dead colors")

    CreateColorPicker(absorbColorGroup, "Shield color", dbEntry.DamageAbsorbBar.Color,
        function(self, event, r, g, b, a)
            dbEntry.DamageAbsorbBar.Color.r = r
            dbEntry.DamageAbsorbBar.Color.g = g
            dbEntry.DamageAbsorbBar.Color.b = b
            dbEntry.DamageAbsorbBar.Color.a = a

            UF.UpdateAllFrames()
        end, 0.5, true)

    CreateColorPicker(absorbColorGroup, "Heal absorb color", dbEntry.HealAbsorbBar.Color,
        function(self, event, r, g, b, a)
            dbEntry.HealAbsorbBar.Color.r = r
            dbEntry.HealAbsorbBar.Color.g = g
            dbEntry.HealAbsorbBar.Color.b = b
            dbEntry.HealAbsorbBar.Color.a = a

            UF.UpdateAllFrames()
        end, 0.5, true)

    CreateColorPicker(absorbColorGroup, "Dead color", dbEntry.HealthBar.DeadColor,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.DeadColor.r = r
            dbEntry.HealthBar.DeadColor.g = g
            dbEntry.HealthBar.DeadColor.b = b
            dbEntry.HealthBar.DeadColor.a = a

            UF.UpdateAllFrames()
        end, 0.5)

    local nameColorGroup = CreateInlineGroup(scrollFrame, "Text color")

    CreateCheckBox(nameColorGroup, "Toggle custom color", dbEntry.Name.CustomColor,
        function(self, event, value)
            dbEntry.Name.CustomColor = value
            UF.UpdateAllFrames()
        end, 0.5)

    CreateColorPicker(nameColorGroup, "Text Color", dbEntry.Name.Color,
        function(self, event, r, g, b, a)
            dbEntry.Name.Color.r = r
            dbEntry.Name.Color.g = g
            dbEntry.Name.Color.b = b
            dbEntry.Name.Color.a = a

            UF.UpdateAllFrames()
        end, 0.5)

    local castBarColorGroup = CreateInlineGroup(scrollFrame, "Cast bar colors")

    CreateColorPicker(castBarColorGroup, "Interruptible", dbEntry.CastBar.Color,
        function(self, event, r, g, b, a)
            dbEntry.CastBar.Color.r = r
            dbEntry.CastBar.Color.g = g
            dbEntry.CastBar.Color.b = b
            dbEntry.CastBar.Color.a = a
        end, 0.5)

    CreateColorPicker(castBarColorGroup, "Not interruptible", dbEntry.CastBar.ColorNotInterruptiple,
        function(self, event, r, g, b, a)
            dbEntry.CastBar.ColorNotInterruptiple.r = r
            dbEntry.CastBar.ColorNotInterruptiple.g = g
            dbEntry.CastBar.ColorNotInterruptiple.b = b
            dbEntry.CastBar.ColorNotInterruptiple.a = a
        end, 0.5)

    CreateColorPicker(castBarColorGroup, "Spell name color", dbEntry.CastBar.NameColor,
        function(self, event, r, g, b, a)
            dbEntry.CastBar.NameColor.r = r
            dbEntry.CastBar.NameColor.g = g
            dbEntry.CastBar.NameColor.b = b
            dbEntry.CastBar.NameColor.a = a

            UF.UpdateAllFrames()
        end, 0.5)

    CreateColorPicker(castBarColorGroup, "Spell progress color", dbEntry.CastBar.TimeColor,
        function(self, event, r, g, b, a)
            dbEntry.CastBar.TimeColor.r = r
            dbEntry.CastBar.TimeColor.g = g
            dbEntry.CastBar.TimeColor.b = b
            dbEntry.CastBar.TimeColor.a = a

            UF.UpdateAllFrames()
        end, 0.5)

    scrollFrame:DoLayout()
end

local function CreateUnitFrameFramePage(container, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame]
    local frame = _G["CUI_"..unitFrame]
    if unitFrame == "BossFrame" then frame = "BossFrame" end

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    if unitFrame == "BossFrame" then
        local testGroup = CreateInlineGroup(scrollFrame, "Test")

        CreateCheckBox(testGroup, "Toggle test boss frames", bossTestFrames,
            function(self, event, value)
                bossTestFrames = value
                UF.ToggleBossTest(value)
            end, 1)

        local bossGroup = CreateInlineGroup(scrollFrame, "Boss Frame Padding")

        CreateSlider(bossGroup, "Padding", 1, 100, 1, dbEntry.Padding,
            function(self, event, value)
                dbEntry.Padding = value
                UF.UpdateFrame(frame)
            end, 1)
    end

    CreateSizeGroup(scrollFrame, dbEntry, UF.UpdateFrame, frame)

    CreateAlphaGroup(scrollFrame, dbEntry, UF.UpdateAlpha, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, UF.UpdateFrame, frame)

    local powerBarGroup = CreateInlineGroup(scrollFrame, "Power Bar")

    CreateCheckBox(powerBarGroup, "Enable", dbEntry.PowerBar.Enabled,
        function(self, event, value)
            dbEntry.PowerBar.Enabled = value
            UF.UpdateFrame(frame)
        end, 0.5)

    CreateSlider(powerBarGroup, "Height", 1, 50, 1, dbEntry.PowerBar.Height,
        function(self, event, value)
            dbEntry.PowerBar.Height = value
            UF.UpdateFrame(frame)
        end, 0.5)

    scrollFrame:DoLayout()
end

local function CreateUnitFramAuraSettings(container, unitFrame, type)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame][type]
    local frame = _G["CUI_"..unitFrame]
    if unitFrame == "BossFrame" then frame = "BossFrame" end

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local group = CreateInlineGroup(scrollFrame, type)

    CreateCheckBox(group, "Toggle "..type, dbEntry.Enabled,
        function(self, event, value)
            dbEntry.Enabled = value
            UF.UpdateAuras(frame)
        end, 1)

    CreateSlider(group, "Size", 1, 50, 1, dbEntry.Size,
        function(self, event, value)
            dbEntry.Size = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateSlider(group, "Padding", 0, 20, 1, dbEntry.Padding,
        function(self, event, value)
            dbEntry.Padding = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateSlider(group, "Row length", 1, 20, 1, dbEntry.RowLength,
        function(self, event, value)
            dbEntry.RowLength = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateSlider(group, "Max Shown", 1, 30, 1, dbEntry.MaxShown,
        function(self, event, value)
            dbEntry.MaxShown = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateDropDown(group, "Horizontal Growth Direction", dbEntry.DirH, directionsHorizontal,
        function(self, event, value)
            dbEntry.DirH = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateDropDown(group, "Vertical Growth Direction", dbEntry.DirV, directionsVertical,
        function(self, event, value)
            dbEntry.DirV = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateDropDown(group, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateDropDown(group, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateSlider(group, "Position X", -500, 500, 0.1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateSlider(group, "Position Y", -500, 500, 0.1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            UF.UpdateAuras(frame)
        end, 0.5)

    CreateTextGroup(scrollFrame, dbEntry.Stacks, UF.UpdateAuras, frame, "Stacks")

    scrollFrame:DoLayout()
end

local function CreateUnitFrameAuraPage(container, unitFrame)
    local function SelectGroup(container, event, tab)
        container:ReleaseChildren()
        if tab == "Buffs" then
            CreateUnitFramAuraSettings(container, unitFrame, "Buffs")
        elseif tab == "Debuffs" then
            CreateUnitFramAuraSettings(container, unitFrame, "Debuffs")
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Buffs", value="Buffs"},
                    {text="Debuffs", value="Debuffs"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Buffs")

    container:AddChild(tabGroup)
end

local function CreateUnitFrameTextPage(container, unitFrame, type)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame][type]
    local frame = _G["CUI_"..unitFrame]
    if unitFrame == "BossFrame" then frame = "BossFrame" end

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local nameGroup = CreateTextGroup(scrollFrame, dbEntry, UF.UpdateTexts, frame, type)

    if type == "Name" then
        CreateSlider(nameGroup, "Width", 1, 500, 1, dbEntry.Width,
            function(self, event, value)
                dbEntry.Width = value
                UF.UpdateTexts(frame)
            end, 1)
    end

    scrollFrame:DoLayout()
end

local function CreateUnitFrameTextTabs(container, unitFrame)
    local function SelectGroup(container, event, type)
        container:ReleaseChildren()
        if type == "Name" then
            CreateUnitFrameTextPage(container, unitFrame, type)
        elseif type == "HealthText" then
            CreateUnitFrameTextPage(container, unitFrame, type)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Name", value="Name"}, 
                    {text="Health", value="HealthText"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Name")

    container:AddChild(tabGroup)
end

local function CreateUnitFrameCastBarPage(container, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame].CastBar
    local frame = _G["CUI_"..unitFrame]
    if unitFrame == "BossFrame" then frame = "BossFrame" end

    local function CastBarFramePage(container)
        local scrollFrame = AceGUI:Create("ScrollFrame")
        scrollFrame:SetLayout("List")
        container:AddChild(scrollFrame)

        local toggleGroup = CreateInlineGroup(scrollFrame, "Toggle")

        CreateCheckBox(toggleGroup, "Toggle Cast Bar", dbEntry.Enabled,
            function(self, event, value)
                dbEntry.Enabled = value
                UF.UpdateCastBarFrame(frame)
            end, 0.5)

        CreateCheckBox(toggleGroup, "Toggle Icon", dbEntry.ShowIcon,
            function(self, event, value)
                dbEntry.ShowIcon = value
                UF.UpdateCastBarFrame(frame)
            end, 0.5)

        local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, UF.UpdateCastBarFrame, frame)

        CreateCheckBox(sizeGroup, "Match width to anchored frame (also forces anchor to bottom of frame)", dbEntry.MatchWidth,
            function(self, event, value)
                dbEntry.MatchWidth = value
                UF.UpdateCastBarFrame(frame)
            end, 1)

        if unitFrame == "BossFrame" then
            CreateAnchorGroupWithoutFrame(scrollFrame, dbEntry, UF.UpdateCastBarFrame, frame)
        else
            CreateAnchorGroup(scrollFrame, dbEntry, UF.UpdateCastBarFrame, frame)
        end

        scrollFrame:DoLayout()
    end

    local function CastBarTextPage(container)
        local scrollFrame = AceGUI:Create("ScrollFrame")
        scrollFrame:SetLayout("List")
        container:AddChild(scrollFrame)

        local textGroup = CreateTextGroupWithoutToggle(scrollFrame, dbEntry.Name, UF.UpdateCastBarTexts, frame, "Spell Name")

        CreateSlider(textGroup, "Width", 1, 500, 1, dbEntry.Name.Width,
            function(self, event, value)
                dbEntry.Name.Width = value
                UF.UpdateCastBarTexts(frame)
            end, 1)

        CreateTextGroupWithoutToggle(scrollFrame, dbEntry.Time, UF.UpdateCastBarTexts, frame, "Spell Time")

        scrollFrame:DoLayout()
    end

    local function SelectGroup(container, event, tab)
        container:ReleaseChildren()
        if tab == "Frame" then
            CastBarFramePage(container)
        elseif tab == "Text" then
            CastBarTextPage(container)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Frame", value="Frame"},
                    {text="Text", value="Text"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Frame")

    container:AddChild(tabGroup)
end

local function CreateUnitFrameMiscPage(container, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame]
    local frame = _G["CUI_"..unitFrame]
    if unitFrame == "BossFrame" then frame = "BossFrame" end

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    if dbEntry.LeaderIcon then
        local leaderGroup = CreateInlineGroup(scrollFrame, "Leader / Assist Icon")

        CreateCheckBox(leaderGroup, "Toggle Leader / Assist Icon", dbEntry.LeaderIcon.Enabled,
            function(self, event, value)
                dbEntry.LeaderIcon.Enabled = value
                UF.UpdateFrame(frame)
            end, 0.5)

        CreateSlider(leaderGroup, "Size", 1, 50, 1, dbEntry.LeaderIcon.Size,
            function(self, event, value)
                dbEntry.LeaderIcon.Size = value
                UF.UpdateFrame(frame)
            end, 0.5)

        CreateAnchorGroupWithoutFrame(leaderGroup, dbEntry.LeaderIcon, UF.UpdateFrame, frame)
    end

    scrollFrame:DoLayout()
end

local function CreateUnitFrameTabs(container, unitFrame)
    local function SelectGroup(container, event, tab)
        container:ReleaseChildren()
        if tab == "Frame" then
            CreateUnitFrameFramePage(container, unitFrame)
        elseif tab == "Aura" then
            CreateUnitFrameAuraPage(container, unitFrame)
        elseif tab == "Text" then
            CreateUnitFrameTextTabs(container, unitFrame)
        elseif tab == "CastBar" then
            CreateUnitFrameCastBarPage(container, unitFrame)
        elseif tab == "Misc" then
            CreateUnitFrameMiscPage(container, unitFrame)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Frame", value="Frame"}, 
                    {text="Auras", value="Aura"},
                    {text="Texts", value="Text"},
                    {text="Cast Bar", value="CastBar"},
                    {text="Misc", value="Misc"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Frame")

    container:AddChild(tabGroup)
end

local function CreateUnitFrameSettings(container)
    local function SelectGroup(container, event, unitFrame)
        container:ReleaseChildren()
        if unitFrame == "General" then
            CreateUnitFrameGeneralPage(container)
        else
            CreateUnitFrameTabs(container, unitFrame)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="General", value="General"},
                    {text="Player Frame", value="PlayerFrame"},
                    {text="Target Frame", value="TargetFrame"},
                    {text="Focus Frame", value="FocusFrame"},
                    {text="Pet Frame", value="PetFrame"},
                    {text="Boss Frame", value="BossFrame"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("General")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local partyTestFrame = false
local raidTestFrame = false

local function CreateGroupFrameGeneralPage(container)
    local dbEntry = CUI.DB.profile.GroupFrames
    local raidFrame =  _G["CUI_RaidFrame"]
    local partyFrame =  _G["CUI_PartyFrame"]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local textureGroup = CreateInlineGroup(scrollFrame, "Textures")

    CreateDropDown(textureGroup, "Health", dbEntry.HealthBar.Texture, textures,
        function(self, event, value)
            dbEntry.HealthBar.Texture = value
            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.33)

    CreateDropDown(textureGroup, "Shield", dbEntry.DamageAbsorbBar.Texture, textures,
        function(self, event, value)
            dbEntry.DamageAbsorbBar.Texture = value
            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.33)

    CreateDropDown(textureGroup, "Heal absorb", dbEntry.HealAbsorbBar.Texture, textures,
        function(self, event, value)
            dbEntry.HealAbsorbBar.Texture = value
            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.33)

    local healthColorGroup = CreateInlineGroup(scrollFrame, "Health bar colors")

    CreateCheckBox(healthColorGroup, "Toggle custom colors", dbEntry.HealthBar.CustomColor,
        function(self, event, value)
            dbEntry.HealthBar.CustomColor = value
            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5)

    CreateColorPicker(healthColorGroup, "Health Bar", dbEntry.HealthBar.Color,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.Color.r = r
            dbEntry.HealthBar.Color.g = g
            dbEntry.HealthBar.Color.b = b
            dbEntry.HealthBar.Color.a = a

            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5)

    CreateColorPicker(healthColorGroup, "Background", dbEntry.HealthBar.BackgroundColor,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.BackgroundColor.r = r
            dbEntry.HealthBar.BackgroundColor.g = g
            dbEntry.HealthBar.BackgroundColor.b = b
            dbEntry.HealthBar.BackgroundColor.a = a

            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5)

    CreateColorPicker(healthColorGroup, "Healing Prediction", dbEntry.HealthBar.HealPredictionColor,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.HealPredictionColor.r = r
            dbEntry.HealthBar.HealPredictionColor.g = g
            dbEntry.HealthBar.HealPredictionColor.b = b
            dbEntry.HealthBar.HealPredictionColor.a = a

            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5)

    local absorbColorGroup = CreateInlineGroup(scrollFrame, "Shield / Heal Absorb / Dead colors")

    CreateColorPicker(absorbColorGroup, "Shield color", dbEntry.DamageAbsorbBar.Color,
        function(self, event, r, g, b, a)
            dbEntry.DamageAbsorbBar.Color.r = r
            dbEntry.DamageAbsorbBar.Color.g = g
            dbEntry.DamageAbsorbBar.Color.b = b
            dbEntry.DamageAbsorbBar.Color.a = a

            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5, true)

    CreateColorPicker(absorbColorGroup, "Heal absorb color", dbEntry.HealAbsorbBar.Color,
        function(self, event, r, g, b, a)
            dbEntry.HealAbsorbBar.Color.r = r
            dbEntry.HealAbsorbBar.Color.g = g
            dbEntry.HealAbsorbBar.Color.b = b
            dbEntry.HealAbsorbBar.Color.a = a

            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5, true)

    CreateColorPicker(absorbColorGroup, "Dead color", dbEntry.HealthBar.DeadColor,
        function(self, event, r, g, b, a)
            dbEntry.HealthBar.DeadColor.r = r
            dbEntry.HealthBar.DeadColor.g = g
            dbEntry.HealthBar.DeadColor.b = b
            dbEntry.HealthBar.DeadColor.a = a

            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5)

    local nameColorGroup = CreateInlineGroup(scrollFrame, "Name color")

    CreateCheckBox(nameColorGroup, "Toggle custom color", dbEntry.Name.CustomColor,
        function(self, event, value)
            dbEntry.Name.CustomColor = value
            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5)

    CreateColorPicker(nameColorGroup, "Name Color", dbEntry.Name.Color,
        function(self, event, r, g, b, a)
            dbEntry.Name.Color.r = r
            dbEntry.Name.Color.g = g
            dbEntry.Name.Color.b = b
            dbEntry.Name.Color.a = a

            GF.UpdateFrame(raidFrame)
            GF.UpdateFrame(partyFrame)
        end, 0.5)

    scrollFrame:DoLayout()
end

local function CreateGroupFrameFramePage(container, groupFrame)
    local dbEntry = CUI.DB.profile.GroupFrames[groupFrame]
    local frame =  _G["CUI_"..groupFrame]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local testGroup = CreateInlineGroup(scrollFrame, "Test frames")

    if groupFrame == "PartyFrame" then
        CreateCheckBox(testGroup, "Toggle test frames", partyTestFrame,
            function(self, event, value)
                partyTestFrame = value
                GF.ToggleGroupTestFrames(groupFrame, partyTestFrame)
            end, 1)
    else
        CreateCheckBox(testGroup, "Toggle test frames", raidTestFrame,
            function(self, event, value)
                raidTestFrame = value
                GF.ToggleGroupTestFrames(groupFrame, raidTestFrame)
            end, 1)
    end

    local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, GF.UpdateFrame, frame)

    CreateSlider(sizeGroup, "Padding", 0, 50, 1, dbEntry.Padding,
        function(self, event, value)
            dbEntry.Padding = value
            GF.UpdateFrame(frame)
        end, 1)

    CreateAlphaGroup(scrollFrame, dbEntry, GF.UpdateAlpha, frame)

    local anchorGroup = CreateAnchorGroup(scrollFrame, dbEntry, GF.UpdateFrame, frame)

    CreateDropDown(anchorGroup, "Horizontal Growth Direction", dbEntry.DirH, directionsHorizontal,
        function(self, event, value)
            dbEntry.DirH = value
            GF.UpdateFrame(frame)
        end, 0.5)

    CreateDropDown(anchorGroup, "Vertical Growth Direction", dbEntry.DirV, directionsVertical,
        function(self, event, value)
            dbEntry.DirV = value
            GF.UpdateFrame(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Row length", 1, 20, 1, dbEntry.RowLength,
        function(self, event, value)
            dbEntry.RowLength = value
            GF.UpdateFrame(frame)
        end, 1)

    scrollFrame:DoLayout()
end

local function CreateGroupFrameAuraPage(container, groupFrame)
    local function CreateAuraPage(container, groupFrame, type)
        local dbEntry = CUI.DB.profile.GroupFrames[groupFrame][type]
        local frame = _G["CUI_"..groupFrame]

        local scrollFrame = AceGUI:Create("ScrollFrame")
        scrollFrame:SetLayout("List")
        container:AddChild(scrollFrame)

        local group = CreateInlineGroup(scrollFrame, type)

        CreateCheckBox(group, "Toggle "..type, dbEntry.Enabled,
            function(self, event, value)
                dbEntry.Enabled = value
                GF.UpdateAuras(frame)
            end, 1)

        CreateSlider(group, "Size", 1, 50, 1, dbEntry.Size,
            function(self, event, value)
                dbEntry.Size = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateSlider(group, "Padding", 0, 20, 1, dbEntry.Padding,
            function(self, event, value)
                dbEntry.Padding = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateSlider(group, "Row length", 1, 20, 1, dbEntry.RowLength,
            function(self, event, value)
                dbEntry.RowLength = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateSlider(group, "Max Shown", 1, 30, 1, dbEntry.MaxShown,
            function(self, event, value)
                dbEntry.MaxShown = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateDropDown(group, "Horizontal Growth Direction", dbEntry.DirH, directionsHorizontal,
            function(self, event, value)
                dbEntry.DirH = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateDropDown(group, "Vertical Growth Direction", dbEntry.DirV, directionsVertical,
            function(self, event, value)
                dbEntry.DirV = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateDropDown(group, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
            function(self, event, value)
                dbEntry.AnchorPoint = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateDropDown(group, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
            function(self, event, value)
                dbEntry.AnchorRelativePoint = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateSlider(group, "Position X", -500, 500, 0.1, dbEntry.PosX,
            function(self, event, value)
                dbEntry.PosX = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateSlider(group, "Position Y", -500, 500, 0.1, dbEntry.PosY,
            function(self, event, value)
                dbEntry.PosY = value
                GF.UpdateAuras(frame)
            end, 0.5)

        CreateTextGroup(scrollFrame, dbEntry.Stacks, GF.UpdateAuras, frame, "Stacks")

        scrollFrame:DoLayout()
    end

    local function SelectGroup(container, event, tab)
        container:ReleaseChildren()
        if tab == "Buffs" then
            CreateAuraPage(container, groupFrame, "Buffs")
        elseif tab == "Debuffs" then
            CreateAuraPage(container, groupFrame, "Debuffs")
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Buffs", value="Buffs"},
                    {text="Debuffs", value="Debuffs"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Buffs")

    container:AddChild(tabGroup)
end

local function CreateGroupFrameTextTabs(container, groupFrame)
    local dbEntry = CUI.DB.profile.GroupFrames[groupFrame]
    local frame = _G["CUI_"..groupFrame]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local textGroup = CreateTextGroup(scrollFrame, dbEntry.Name, GF.UpdateFrame, frame, "Name")

    CreateSlider(textGroup, "Width", 1, 500, 1, dbEntry.Name.Width,
        function(self, event, value)
            dbEntry.Name.Width = value
            GF.UpdateFrame(frame)
        end, 1)

    scrollFrame:DoLayout()
end

local function CreateGroupFrameMiscPage(container, groupFrame)
    local dbEntry = CUI.DB.profile.GroupFrames[groupFrame]
    local frame = _G["CUI_"..groupFrame]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local roleGroup = CreateInlineGroup(scrollFrame, "Role Icon")

    CreateCheckBox(roleGroup, "Toggle Role Icon", dbEntry.RoleIcon.Enabled,
        function(self, event, value)
            dbEntry.RoleIcon.Enabled = value
            GF.UpdateFrame(frame)
        end, 0.5)

    CreateSlider(roleGroup, "Size", 1, 50, 1, dbEntry.RoleIcon.Size,
        function(self, event, value)
            dbEntry.RoleIcon.Size = value
            GF.UpdateFrame(frame)
        end, 0.5)

    CreateAnchorGroupWithoutFrame(roleGroup, dbEntry.RoleIcon, GF.UpdateFrame, frame)

    scrollFrame:DoLayout()
end

local function CreateGroupFrameTabs(container, groupFrame)
    local function SelectGroup(container, event, tab)
        container:ReleaseChildren()
        if tab == "Frame" then
            CreateGroupFrameFramePage(container, groupFrame)
        elseif tab == "Aura" then
            CreateGroupFrameAuraPage(container, groupFrame)
        elseif tab == "Text" then
            CreateGroupFrameTextTabs(container, groupFrame)
        elseif tab == "Misc" then
            CreateGroupFrameMiscPage(container, groupFrame)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Frame", value="Frame"},
                    {text="Auras", value="Aura"},
                    {text="Texts", value="Text"},
                    {text="Misc", value="Misc"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Frame")

    container:AddChild(tabGroup)
end

local function CreateGroupFrameSettings(container)
    local function SelectGroup(container, event, groupFrame)
        container:ReleaseChildren()
        if groupFrame == "General" then
            CreateGroupFrameGeneralPage(container)
        else
            CreateGroupFrameTabs(container, groupFrame)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="General", value="General"},
                    {text="Party", value="PartyFrame"},
                    {text="Raid", value="RaidFrame"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("General")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateCDMPage(container, viewer)
    local dbEntry = CUI.DB.profile.CooldownManager[viewer]
    local frame = _G[viewer]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local centerGroup = CreateInlineGroup(scrollFrame, "Center Icons")

    CreateCheckBox(centerGroup, "Toggle centering icons", dbEntry.CenterIcons,
        function(self, event, value)
            dbEntry.CenterIcons = value
            frame:Hide()
            frame:Show()
        end, 1)

    CreateAlphaGroup(scrollFrame, dbEntry, CDM.UpdateAlpha, frame)

    CreateTextGroupWithoutToggle(scrollFrame, dbEntry.Cooldown, CDM.UpdateStyle, frame, "Cooldown", true)

    CreateTextGroupWithoutToggle(scrollFrame, dbEntry.Charges, CDM.UpdateStyle, frame, "Charges", true)

    scrollFrame:DoLayout()
end

local function CreateCDMSettings(container)
    local function SelectGroup(container, event, viewer)
        container:ReleaseChildren()
        CreateCDMPage(container, viewer)
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Essential", value="EssentialCooldownViewer"}, 
                    {text="Utility", value="UtilityCooldownViewer"},
                    {text="Buff", value="BuffIconCooldownViewer"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("EssentialCooldownViewer")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreatePrimaryResourceBarPage(container)
    local dbEntry = CUI.DB.profile.ResourceBar
    local frame = CUI_PowerBar

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, RB.UpdateFrame, frame)

    CreateCheckBox(sizeGroup, "Match width to anchored frame (also forces anchor to top of frame)", dbEntry.MatchWidth,
        function(self, event, value)
            dbEntry.MatchWidth = value
            RB.UpdateFrame(frame)
        end, 1)

    CreateAlphaGroup(scrollFrame, dbEntry, RB.UpdateAlpha, frame)

    CreateTextureGroup(scrollFrame, dbEntry, RB.UpdateFrame, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, RB.UpdateFrame, frame)

    local textGroup = CreateTextGroup(scrollFrame, dbEntry.Text, RB.UpdateText, frame, "Text")

    CreateCheckBox(textGroup, "Show mana as percent", dbEntry.Text.ShowManaPercent,
        function(self, event, value)
            dbEntry.Text.ShowManaPercent = value
            RB.UpdateText(frame)
        end, 1)

    scrollFrame:DoLayout()
end

local function CreateSecondaryResourceBarPage(container)
    local dbEntry = CUI.DB.profile.ResourceBar.SecondaryResourceBar
    local frame = CUI_SecondaryPowerBar

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local toggleGroup = CreateInlineGroup(scrollFrame, "")

    CreateCheckBox(toggleGroup, "Toggle", dbEntry.Enabled,
        function(self, event, value)
            dbEntry.Enabled = value
            RB.UpdateSecondaryPowerBar(frame)
        end, 0.5)

    local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, RB.UpdateSecondaryPowerBar, frame)

    CreateCheckBox(sizeGroup, "Match width to anchored frame", dbEntry.MatchWidth,
        function(self, event, value)
            dbEntry.MatchWidth = value
            RB.UpdateSecondaryPowerBar(frame)
        end, 0.5)

    CreateSlider(sizeGroup, "Padding", 0, 50, 1, dbEntry.Padding,
        function(self, event, value)
            dbEntry.Padding = value
            RB.UpdateSecondaryPowerBar(frame)
        end, 0.5)

    CreateAlphaGroup(scrollFrame, dbEntry, RB.UpdateAlpha, frame)

    CreateTextureGroup(scrollFrame, dbEntry, RB.UpdateSecondaryPowerBar, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, RB.UpdateSecondaryPowerBar, frame)

    scrollFrame:DoLayout()
end

local function CreatePersonalResourceBarPage(container)
    local dbEntry = CUI.DB.profile.ResourceBar.PersonalResourceBar
    local frame = PersonalResourceDisplayFrame

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local toggleGroup = CreateInlineGroup(scrollFrame, "")

    CreateCheckBox(toggleGroup, "Toggle", dbEntry.Enabled,
        function(self, event, value)
            dbEntry.Enabled = value
            RB.UpdatePersonalBar(frame)
        end, 0.5)

    CreateAlphaGroup(scrollFrame, dbEntry, RB.UpdateAlpha, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, RB.UpdatePersonalBar, frame)

    scrollFrame:DoLayout()
end

local function CreateResourceBarSettings(container)
    local function SelectGroup(container, event, resource)
        container:ReleaseChildren()
        if resource == "Primary" then
            CreatePrimaryResourceBarPage(container)
        elseif resource == "Secondary" then
            CreateSecondaryResourceBarPage(container)
        elseif resource == "PersonalResourceBar" then
            CreatePersonalResourceBarPage(container)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Primary", value="Primary"},
                    {text="Secondary", value="Secondary"},
                    {text="Personal Resource Bar", value="PersonalResourceBar"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Primary")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateMinimapSettings(container)
    local dbEntry = CUI.DB.profile.Minimap

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    CreateAlphaGroup(scrollFrame, dbEntry, MM.UpdateAlpha, MinimapCluster)

    scrollFrame:DoLayout()
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreatePlayerAuraSettings(container)
    local dbEntry = CUI.DB.profile.PlayerAuras

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local alphaGroup = CreateInlineGroup(scrollFrame, "Alpha") 

    CreateSlider(alphaGroup, "Alpha (Out of combat)", 0, 100, 1, dbEntry.Alpha*100, 
        function(self, event, value)
            dbEntry.Alpha = value/100
            PA.UpdateAlpha(BuffFrame)
            PA.UpdateAlpha(DebuffFrame)
        end, 0.5)

    CreateSlider(alphaGroup, "Alpha (In Combat)", 0, 100, 1, dbEntry.CombatAlpha*100, 
        function(self, event, value)
            dbEntry.CombatAlpha = value/100
            PA.UpdateAlpha(BuffFrame)
            PA.UpdateAlpha(DebuffFrame)
        end, 0.5)

    scrollFrame:DoLayout()
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreatePlayerCastBarSettings(container)
    local dbEntry = CUI.DB.profile.PlayerCastBar
    local frame = CUI_CastBar

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    CreateCheckBox(sizeGroup, "Match width to anchored frame (also forces anchor to top of frame)", dbEntry.MatchWidth,
        function(self, event, value)
            dbEntry.MatchWidth = value
            CB.UpdateFrame(frame)
        end, 1)

    CreateColorGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    CreateTextureGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    scrollFrame:DoLayout()
end

---------------------------------------------------------------------------------------------------------------------------------------

local function SetupMainTabs(frame)
    local function SelectGroup(container, event, group)
        container:ReleaseChildren()
        if group == "General" then
            CreateGeneralSettings(container)
        elseif group == "ActionBars" then
            CreateActionBarSettings(container)
        elseif group == "UnitFrames" then
            CreateUnitFrameSettings(container)
        elseif group == "CooldownManager" then
            CreateCDMSettings(container)
        elseif group == "ResourceBar" then
            CreateResourceBarSettings(container)
        elseif group == "Minimap" then
            CreateMinimapSettings(container)
        elseif group == "PlayerAuras" then
            CreatePlayerAuraSettings(container)
        elseif group == "PlayerCastBar" then
            CreatePlayerCastBarSettings(container)
        elseif group == "GroupFrames" then
            CreateGroupFrameSettings(container)
        elseif group == "" then

        end
    end

    local activeModules = {{text="General", value="General"}}
    local dbEntry = CUI.DB.profile

    if dbEntry.ActionBars.Enabled then
        table.insert(activeModules, {text="Action Bars", value="ActionBars"})
    end
    if dbEntry.UnitFrames.Enabled then
        table.insert(activeModules, {text="Unit Frames", value="UnitFrames"})
    end
    if dbEntry.GroupFrames.Enabled then
        table.insert(activeModules, {text="Group Frames", value="GroupFrames"})
    end
    if dbEntry.CooldownManager.Enabled then
        table.insert(activeModules, {text="Cooldown Manager", value="CooldownManager"})
    end
    if dbEntry.ResourceBar.Enabled then
        table.insert(activeModules, {text="Resource Bar", value="ResourceBar"})
    end
    if dbEntry.PlayerCastBar.Enabled then
        table.insert(activeModules, {text="Cast Bar", value="PlayerCastBar"})
    end
    if dbEntry.Nameplates.Enabled then
        table.insert(activeModules, {text="Nameplates", value="Nameplates"})
    end
    if dbEntry.Minimap.Enabled then
        table.insert(activeModules, {text="Minimap", value="Minimap"})
    end
    if dbEntry.PlayerAuras.Enabled then
        table.insert(activeModules, {text="Player Auras", value="PlayerAuras"})
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs(activeModules)
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("General")

    frame:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

function Conf.Load()
    fonts = ReverseHashTable(CUI.SharedMedia:HashTable("font"))
    textures = ReverseHashTable(CUI.SharedMedia:HashTable("statusbar"))

    local dbEntry = CUI.DB.global.Config
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("CalippoUI")
    frame:SetStatusText("CalippoUI, bästa UIn i Midnight!")
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        dbEntry.Width, dbEntry.Height = frame.frame:GetSize()
        end)
    frame:SetLayout("Fill")

    SetupMainTabs(frame)

    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetWidth(dbEntry.Width)
    frame:SetHeight(dbEntry.Height)
end