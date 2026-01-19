local addonName, CUI = ...

CUI.Database = {}
local Database = CUI.Database

CUI_BACKDROP_DS = {
    edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorder.blp",
    edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) * 3,
    bgFile = nil
}

CUI_BACKDROP_DSW = {
    edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorderWhite.tga",
    edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) * 3,
    bgFile = nil
}

local defaultFont = "Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf"
local defaultTexture = "Interface/AddOns/CalippoUI/Media/Statusbar.tga"
local stripedTexture = "Interface/AddOns/CalippoUI/Media/Striped.tga"

local defaults = {
    global = {
        Config = {
            Width = 800,
            Height = 600,

            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = 0,
        },
    },
    profile = {
        ActionBars = {
            Enabled = true,

            ["**"] = {
                Alpha = 1,
                CombatAlpha = 1,

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,

                Padding = 2,

                Keybind = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "OUTLINE",
                    Size = 10,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 8,
                    PosY = -1,
                },
                Cooldown = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "OUTLINE",
                    Size = 16,

                    AnchorPoint = "CENTER",
                    AnchorRelativePoint = "CENTER",
                    PosX = 0,
                    PosY = 0,
                },
                Charges = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "OUTLINE",
                    Size = 16,

                    AnchorPoint = "BOTTOMRIGHT",
                    AnchorRelativePoint = "BOTTOMRIGHT",
                    PosX = 0,
                    PosY = 0,
                },
                Macro = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "OUTLINE",
                    Size = 10,

                    AnchorPoint = "BOTTOM",
                    AnchorRelativePoint = "BOTTOM",
                    PosX = 0,
                    PosY = 0,
                },
            },

            MainActionBar = {

            },
            MultiBarBottomLeft = {

            },
            MultiBarBottomRight = {

            },
            MultiBarLeft = {

            },
            MultiBarRight = {

            },
            MultiBar5 = {

            },
            MultiBar6 = {

            },
            MultiBar7 = {

            },
            PetActionBar = {
                Keybind = {
                    PosX = -2,
                },
            },
            MicroMenu = {

            },
            StanceBar = {

            },
            BagsBar = {

            },
        },
        UnitFrames = {
            Enabled = true,

            HealthBar = {
                Texture = defaultTexture,

                CustomColor = false,
                Color = {
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                    ["a"] = 1,
                },
                BackgroundColor = {
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
                HealPredictionColor = {
                    ["r"] = 0.5,
                    ["g"] = 0.5,
                    ["b"] = 0.5,
                    ["a"] = 1,
                },
                DeadColor = {
                    ["r"] = 0.3,
                    ["g"] = 0,
                    ["b"] = 0,
                    ["a"] = 1,
                },
            },
            HealAbsorbBar = {
                Texture = stripedTexture,

                Color = {
                    ["r"] = 1,
                    ["g"] = 0,
                    ["b"] = 0,
                    ["a"] = 1,
                },
            },
            DamageAbsorbBar = {
                Texture = stripedTexture,

                Color = {
                    ["r"] = 0,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
            },

            Name = {
                CustomColor = true,
                Color = {
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
            },

            PowerBar = {
                Texture = defaultTexture,
            },

            CastBar = {
                Texture = defaultTexture,

                Color = {
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 0,
                    ["a"] = 1
                },

                ColorNotInterruptiple = {
                    ["r"] = 0.5,
                    ["g"] = 0.5,
                    ["b"] = 0.5,
                    ["a"] = 1
                },

                NameColor = {
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
                TimeColor = {
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
            },

            ["**"] = {
                Alpha = 1,
                CombatAlpha = 1,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",

                Name = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 16,
                    Width = 115,

                    AnchorPoint = "LEFT",
                    AnchorRelativePoint = "LEFT",
                    PosX = 5,
                    PosY = 2,
                },
                HealthText = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 16,

                    AnchorPoint = "RIGHT",
                    AnchorRelativePoint = "RIGHT",
                    PosX = -5,
                    PosY = 2,
                },

                Buffs = {
                    Enabled = true,

                    RowLength = 8,
                    Size = 20,
                    DirH = "LEFT",
                    DirV = "UP",
                    Padding = 2,
                    MaxShown = 20,

                    AnchorPoint = "BOTTOMRIGHT",
                    AnchorRelativePoint = "TOPRIGHT",
                    PosX = 0,
                    PosY = 2,

                    Stacks = {
                        Enabled = true,
                        Font = defaultFont,
                        Outline = "OUTLINE",
                        Size = 10,

                        AnchorPoint = "BOTTOMRIGHT",
                        AnchorRelativePoint = "BOTTOMRIGHT",
                        PosX = 0,
                        PosY = 1,
                    },
                },
                Debuffs = {
                    Enabled = true,

                    RowLength = 8,
                    Size = 20,
                    DirH = "RIGHT",
                    DirV = "DOWN",
                    Padding = 2,
                    MaxShown = 20,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "BOTTOMLEFT",
                    PosX = 0,
                    PosY = -2,

                    Stacks = {
                        Enabled = true,
                        Font = defaultFont,
                        Outline = "OUTLINE",
                        Size = 10,

                        AnchorPoint = "BOTTOMRIGHT",
                        AnchorRelativePoint = "BOTTOMRIGHT",
                        PosX = 0,
                        PosY = 1,
                    },
                },

                HealthBar = {
                },
                PowerBar = {
                    Enabled = true,
                    Height = 5,
                },

                CastBar = {
                    Enabled = true,

                    MatchWidth = true,
                    Width = 200,
                    Height = 15,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "BOTTOMLEFT",
                    PosX = 0,
                    PosY = -2,

                    Texture = defaultTexture,
                    ShowIcon = true,

                    Name = {
                        Enabled = true,

                        Font = defaultFont,
                        Outline = "",
                        Size = 10,
                        Width = 150,

                        AnchorPoint = "LEFT",
                        AnchorRelativePoint = "LEFT",
                        PosX = 3,
                        PosY = 0,
                    },
                    Time = {
                        Enabled = true,

                        Font = defaultFont,
                        Outline = "",
                        Size = 10,

                        AnchorPoint = "RIGHT",
                        AnchorRelativePoint = "RIGHT",
                        PosX = -3,
                        PosY = 0,
                    },
                },
            },

            PlayerFrame = {
                Width = 174,
                Height = 50,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = -300,
                PosY = -200,

                LeaderIcon = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 2,
                    PosY = -1,
                },

                Buffs = {
                    Enabled = false,
                },
                Debuffs = {
                    Enabled = false,
                },

                CastBar = {
                    Enabled = false,
                    AnchorFrame = "CUI_PlayerFrame"
                },
            },
            TargetFrame = {
                Width = 174,
                Height = 50,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 300,
                PosY = -200,

                LeaderIcon = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 2,
                    PosY = -1,
                },

                CastBar = {
                    Enabled = false,
                    AnchorFrame = "CUI_TargetFrame"
                },
            },
            FocusFrame = {
                Width = 125,
                Height = 40,

                AnchorFrame = "CUI_TargetFrame",
                AnchorPoint = "TOPLEFT",
                AnchorRelativePoint = "TOPRIGHT",
                PosX = 50,
                PosY = 0,

                Name = {
                    Size = 12,
                    Width = 80,
                },
                HealthText = {
                    Size = 12,
                },

                Buffs = {
                    Enabled = false,
                },
                Debuffs = {
                    Enabled = false,
                },

                CastBar = {
                    AnchorFrame = "CUI_FocusFrame",

                    Name = {
                        Width = 100,
                    },
                },
            },
            PetFrame = {
                Width = 75,
                Height = 20,

                AnchorFrame = "CUI_PlayerFrame",
                AnchorPoint = "BOTTOMLEFT",
                AnchorRelativePoint = "TOPLEFT",
                PosX = 0,
                PosY = 0,

                Name = {
                    Enabled = false,
                    Size = 12,
                    Width = 40,
                },
                HealthText = {
                    Enabled = false,
                    Size = 12,
                },

                Buffs = {
                    Enabled = false,
                },
                Debuffs = {
                    Enabled = false,
                },

                PowerBar = {
                    Enabled = false,
                    Height = 5,
                },

                CastBar = {
                    Enabled = false,
                    AnchorFrame = "CUI_PetFrame"
                },
            },
            BossFrame = {
                Width = 150,
                Height = 40,

                Padding = 25,

                PosX = 600,
                PosY = 300,

                Buffs = {
                    AnchorPoint = "TOPRIGHT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = -2,
                    PosY = 0,
                },
                Debuffs = {
                    Enabled = false,
                },

                Name = {
                    Size = 14,
                    Width = 100,
                },
                HealthText = {
                    Size = 14,
                },
            },
        },
        GroupFrames = {
            Enabled = true,

            HealthBar = {
                Texture = defaultTexture,

                CustomColor = false,
                Color = {
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                    ["a"] = 1,
                },
                BackgroundColor = {
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
                HealPredictionColor = {
                    ["r"] = 0.5,
                    ["g"] = 0.5,
                    ["b"] = 0.5,
                    ["a"] = 1,
                },
                DeadColor = {
                    ["r"] = 0.3,
                    ["g"] = 0,
                    ["b"] = 0,
                    ["a"] = 1,
                },
                DisconnectedColor = {
                    ["r"] = 0.5,
                    ["g"] = 0.5,
                    ["b"] = 0.5,
                    ["a"] = 1,
                },
            },
            HealAbsorbBar = {
                Texture = stripedTexture,

                Color = {
                    ["r"] = 1,
                    ["g"] = 0,
                    ["b"] = 0,
                    ["a"] = 1,
                },
            },
            DamageAbsorbBar = {
                Texture = stripedTexture,

                Color = {
                    ["r"] = 0,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
            },

            Name = {
                CustomColor = true,
                Color = {
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                    ["a"] = 1,
                },
            },

            ["**"] = {
                Alpha = 1,
                CombatAlpha = 1,

                AnchorFrame = "UIParent",
                AnchorPoint = "TOPLEFT",
                AnchorRelativePoint = "CENTER",
                PosX = -400,
                PosY = 250,

                DirH = "RIGHT",
                DirV = "DOWN",
                RowLength = 5,

                Width = 150,
                Height = 70,

                Padding = 2,

                Name = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 10,
                    Width = 100,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 3,
                    PosY = -3,
                },

                RoleIcon = {
                    Enabled = true,
                    Size = 10,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 4,
                    PosY = -15,
                },

                Threat = {
                    Enabled = true,
                    Size = 15,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 4,
                    PosY = -15,
                },

                DispelGradient = {
                    Enabled = true,
                    Height = 25,
                },

                Buffs = {
                    Enabled = true,

                    RowLength = 3,
                    Size = 20,
                    DirH = "LEFT",
                    DirV = "DOWN",
                    Padding = 0,
                    MaxShown = 20,

                    AnchorPoint = "TOPRIGHT",
                    AnchorRelativePoint = "TOPRIGHT",
                    PosX = 0,
                    PosY = 0,

                    Stacks = {
                        Enabled = true,
                        Font = defaultFont,
                        Outline = "OUTLINE",
                        Size = 10,

                        AnchorPoint = "BOTTOMRIGHT",
                        AnchorRelativePoint = "BOTTOMRIGHT",
                        PosX = 0,
                        PosY = 0,
                    },
                },
                Debuffs = {
                    Enabled = true,

                    RowLength = 6,
                    Size = 20,
                    DirH = "RIGHT",
                    DirV = "UP",
                    Padding = 0,
                    MaxShown = 20,

                    AnchorPoint = "BOTTOMLEFT",
                    AnchorRelativePoint = "BOTTOMLEFT",
                    PosX = 0,
                    PosY = 0,

                    Stacks = {
                        Enabled = true,
                        Font = defaultFont,
                        Outline = "OUTLINE",
                        Size = 10,

                        AnchorPoint = "BOTTOMRIGHT",
                        AnchorRelativePoint = "BOTTOMRIGHT",
                        PosX = 0,
                        PosY = 0,
                    },
                },
                Defensives = {
                    Enabled = true,

                    RowLength = 8,
                    Size = 20,
                    DirH = "RIGHT",
                    DirV = "UP",
                    Padding = 2,
                    MaxShown = 20,

                    AnchorPoint = "CENTER",
                    AnchorRelativePoint = "CENTER",
                    PosX = 0,
                    PosY = 0,

                    Stacks = {
                        Enabled = true,
                        Font = defaultFont,
                        Outline = "OUTLINE",
                        Size = 10,

                        AnchorPoint = "BOTTOMRIGHT",
                        AnchorRelativePoint = "BOTTOMRIGHT",
                        PosX = 0,
                        PosY = 0,
                    },
                },
            },

            PartyFrame = {
                PosX = -450,
                PosY = 250,

                Width = 150,
                Height = 70,

                RowLength = 1,

                Name = {
                    Size = 12,
                    Width = 140,

                    PosX = 2,
                    PosY = -3,
                },

                RoleIcon = {
                    Size = 10,

                    PosX = 3,
                    PosY = -15,
                },

                Buffs = {
                    RowLength = 3,
                    Size = 20,

                    Stacks = {
                        Size = 10,
                    },
                },
                Debuffs = {
                    RowLength = 6,
                    Size = 20,

                    Stacks = {
                        Size = 10,
                    },
                },
                Defensives = {
                    RowLength = 8,
                    Size = 20,

                    Stacks = {
                        Size = 10,
                    },
                },
            },
            RaidFrame = {
                PosX = -700,
                PosY = 200,

                Width = 90,
                Height = 55,

                RowLength = 5,

                Name = {
                    Size = 10,
                    Width = 80,

                    PosX = 3,
                    PosY = -3,
                },

                RoleIcon = {
                    Size = 10,

                    PosX = 3,
                    PosY = -15,
                },

                Buffs = {
                    RowLength = 4,
                    Size = 15,

                    DirV = "DOWN",

                    Stacks = {
                        Size = 8,
                    },
                },
                Debuffs = {
                    RowLength = 6,
                    Size = 15,

                    Stacks = {
                        Size = 8,
                    },
                },
                Defensives = {
                    RowLength = 8,
                    Size = 15,

                    Stacks = {
                        Size = 8,
                    },
                },
            },
        },
        PlayerCastBar = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,

            MatchWidth = false,
            Width = 200,
            Height = 10,

            Color = {
                ["r"] = 0,
                ["g"] = 0.8,
                ["b"] = 0,
                ["a"] = 1
            },

            Texture = defaultTexture,

            AnchorFrame = "UIParent",
            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = -300,
        },
        PlayerAuras = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,
        },
        Minimap = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,
        },
        Chat = {
            Enabled = true,

            Font = defaultFont,
            Outline = "",
        },
        Nameplates = {
            Enabled = false,
        },
        ResourceBar = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,

            MatchWidth = true,
            Width = 200,
            Height = 15,

            Texture = defaultTexture,

            AnchorFrame = "EssentialCooldownViewer",
            AnchorPoint = "BOTTOM",
            AnchorRelativePoint = "TOP",
            PosX = 0,
            PosY = 2,

            Text = {
                Enabled = true,

                Font = defaultFont,
                Outline = "",
                Size = 14,

                ShowManaPercent = true,

                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = -1,
            },

            PersonalResourceBar = {
                Enabled = false,

                Alpha = 1,
                CombatAlpha = 1,

                AnchorFrame = "CUI_PowerBar",
                AnchorPoint = "BOTTOM",
                AnchorRelativePoint = "TOP",
                PosX = 0,
                PosY = 20,
            },

            SecondaryResourceBar = {
                Enabled = true,

                Alpha = 1,
                CombatAlpha = 1,

                MatchWidth = true,
                Width = 200,
                Height = 15,

                Padding = 2,

                Texture = defaultTexture,

                AnchorFrame = "CUI_PowerBar",
                AnchorPoint = "BOTTOM",
                AnchorRelativePoint = "TOP",
                PosX = 0,
                PosY = 2,
            },
        },
        CooldownManager = {
            Enabled = true,

            ["**"] = {
                Alpha = 1,
                CombatAlpha = 1,

                CenterIcons = true,

                Cooldown = {
                    Font = defaultFont,
                    Outline = "OUTLINE",
                    Size = 16,

                    Color = {
                        ["r"] = 1,
                        ["g"] = 1,
                        ["b"] = 1,
                        ["a"] = 1,
                    },

                    AnchorPoint = "CENTER",
                    AnchorRelativePoint = "CENTER",
                    PosX = 0,
                    PosY = 0,
                },
                Charges = {
                    Font = defaultFont,
                    Outline = "OUTLINE",
                    Size = 16,

                    Color = {
                        ["r"] = 1,
                        ["g"] = 1,
                        ["b"] = 1,
                        ["a"] = 1,
                    },

                    AnchorPoint = "BOTTOMRIGHT",
                    AnchorRelativePoint = "BOTTOMRIGHT",
                    PosX = 0,
                    PosY = 0,
                },
            },

            EssentialCooldownViewer = {
                Cooldown = {
                    Size = 20,
                },
                Charges = {
                    Size = 20,
                },
            },
            UtilityCooldownViewer = {
                Cooldown = {
                    Size = 12,
                },
                Charges = {
                    Size = 12,
                },
            },
            BuffIconCooldownViewer = {
                Cooldown = {
                    Size = 16,
                },
                Charges = {
                    Size = 16,
                },
            },
        },
        AutoWhisper = {
            Enabled = false,
        }
    }
}

function Database.Load()
    CUI.SharedMedia = LibStub("LibSharedMedia-3.0")
    CUI.SharedMedia:Register("font", "Fira Sans Medium", "Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf")
    CUI.SharedMedia:Register("font", "Fira Sans Black", "Interface/AddOns/CalippoUI/Fonts/FiraSans-Black.ttf")
    CUI.SharedMedia:Register("statusbar", "Default", "Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    CUI.SharedMedia:Register("statusbar", "Striped", "Interface/AddOns/CalippoUI/Media/Striped.tga")

    CUI.DB = LibStub("AceDB-3.0"):New("CalippoDB", defaults, "Default")
end