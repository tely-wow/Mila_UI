local _, MilaUI = ...
local MilaUIAddon = LibStub("AceAddon-3.0"):NewAddon("MilaUI")
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"
MilaUIAddon_GUI = MilaUIAddon_GUI or {}
MilaUIAddon:SetDefaultModuleState(false)

MilaUIAddon.Defaults = {
    global = {
        UIScaleEnabled    = true,
        UIScale           = 0.65,
        GameMenuScale     = 1,
        TagUpdateInterval = 0.5,
        FramesLocked      = true,
    },
    profile = {
        TestMode = false,
        CursorMod = {
            enabled = true,
            texPoint = 1,
            size = 0, -- Will be set to cursorSizePreferred from GetCVar if not specified
            autoScale = true,
            scale = 1,
            opacity = 1,
            color = {1, 1, 1},
            useClassColor = false,
            showOnlyInCombat = false,
            changeCursorSize = false,
            lookStartDelta = 0.001, -- Will use CursorFreelookStartDelta from GetCVar if not specified
            textures = {
                "Interface/AddOns/Mila_UI/Media/Cursor/point",
                -- Retail cursor
                {
                    {"Interface/cursor/UICursor2x", 261/512, 293/512, 67/256, 99/256},
                    {"Interface/cursor/UICursor2x", 393/512, 441/512, 1/256, 49/256},
                    {"Interface/cursor/UICursor2x", 261/512, 325/512, 1/256, 65/256},
                    {"Interface/cursor/UICursor2x", 1/512, 97/512, 131/256, 227/256},
                    {"Interface/cursor/UICursor2x", 1/512, 129/512, 1/256, 129/256},
                },
                -- Classic cursor
                {
                    {"Interface/cursor/UICursor2x", 261/512, 293/512, 101/256, 133/256},
                    {"Interface/cursor/UICursor2x", 443/512, 491/512, 1/256, 49/256},
                    {"Interface/cursor/UICursor2x", 327/512, 391/512, 1/256, 65/256},
                    {"Interface/cursor/UICursor2x", 131/512, 227/512, 131/256, 227/256},
                    {"Interface/cursor/UICursor2x", 131/512, 259/512, 1/256, 129/256},
                },
                "Interface/AddOns/Mila_UI/Media/Cursor/point-inverse",
                "Interface/AddOns/Mila_UI/Media/Cursor/point-ghostly",
                {"talents-search-notonactionbar", 84, 84, -2, 3},
                {"talents-search-notonactionbarhidden", 84, 84, -2, 3},
            },
            sizes = {[0] = 32, 48, 64, 96, 128},
        },
        Unitframes = {
            migrated = false,       
            General = {
                Font                              = "Expressway",
                FontFlag                          = "OUTLINE",
                FontShadowColour                  = {0, 0, 0, 1},
                FontShadowXOffset                 = 0,
                FontShadowYOffset                 = 0,
                ForegroundTexture                 = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                AbsorbTexture                     = "AbsorbBar",
                BackgroundTexture                 = "Smooth",
                BorderTexture                     = "Interface\\Buttons\\WHITE8X8",
                BackgroundColour                  = {26 / 255, 26 / 255, 26 / 255, 1},
                ForegroundColour                  = {26 / 255, 26 / 255, 26 / 255, 1},
                BorderColour                      = {0 / 255, 0 / 255, 0 / 255, 1},
                BorderSize                        = 1,
                BorderInset                       = 1,
                ColourByPlaterNameplates          = true,
                ColourByClass                     = true,
                ColourByReaction                  = true,
                ColourIfDisconnected              = true,
                ColourIfTapped                    = true,
                ColourBackgroundByForeground      = false,
                ColourBackgroundByClass           = false,
                ColourBackgroundIfDead            = false,
                BackgroundMultiplier              = 0.25,
                CustomColours = {
                    Reaction = {
                        [1] = {255/255, 64/255, 64/255},            -- Hated
                        [2] = {255/255, 64/255, 64/255},            -- Hostile
                        [3] = {255/255, 128/255, 64/255},           -- Unfriendly
                        [4] = {255/255, 255/255, 64/255},           -- Neutral
                        [5] = {64/255, 255/255, 64/255},            -- Friendly
                        [6] = {64/255, 255/255, 64/255},            -- Honored
                        [7] = {64/255, 255/255, 64/255},            -- Revered
                        [8] = {64/255, 255/255, 64/255},            -- Exalted
                    },
                    Power = {
                        [0] = {0, 0, 1},            -- Mana
                        [1] = {1, 0, 0},            -- Rage
                        [2] = {1, 0.5, 0.25},       -- Focus
                        [3] = {1, 1, 0},            -- Energy
                        [6] = {0, 0.82, 1},         -- Runic Power
                        [8] = {0.3, 0.52, 0.9},     -- Lunar Power
                        [11] = {0, 0.5, 1},         -- Maelstrom
                        [13] = {0.4, 0, 0.8},       -- Insanity
                        [17] = {0.79, 0.26, 0.99},  -- Fury
                        [18] = {1, 0.61, 0}         -- Pain
                    },
                    Status = {
                        [1] = {255/255, 64/255, 64/255},           -- Dead
                        [2] = {153/255, 153/255, 153/255}, -- Tapped 
                        [3] = {0.6, 0.6, 0.6}, -- Disconnected
                    }
                },
                MouseoverHighlight = {
                    Enabled = true,
                    Style = "BORDER",
                    Colour = {1, 1, 1, 1},
                }
            },
            Player = {
                Frame = {
                    Enabled             = true,
                    CustomScale         = false,
                    Scale               = 1,
                    Width               = 230,
                    Height              = 38,
                    XPosition           = -300,
                    YPosition           = -150,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "CENTER",
                    AnchorParent        = "UIParent",
                },
                Portrait = {
                    Enabled         = false,
                    Size            = 42,
                    XOffset         = -1,
                    YOffset         = 0,
                    AnchorFrom      = "RIGHT",
                    AnchorTo        = "LEFT",
                },
                Health = {
                    Width               = 230,
                    Height              = 38,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    CustomMask = {
                        Enabled = true,
                        MaskTexture = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_style2.tga",
                    },
                    CustomBorder = {
                        Enabled = true,
                        BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_style2.tga",
                    },
                    HealthPrediction = {
                        Enabled = true,
                        IncomingHeals = {},
                        HealAbsorbs = {
                            Enabled = true,
                            Colour = {128/255, 64/255, 255/255, 1},
                        },
                        Absorbs = {
                            Enabled         = true,
                            Colour          = {255/255, 205/255, 0/255, 1},
                            ColourByType    = true,
                        }
                    }
                },
                PowerBar = {
                    Width                   = 219,
                    Height                  = 19,
                    XPosition               = 0,
                    YPosition               = 0,
                    AnchorFrom              = "TOPRIGHT",
                    AnchorTo                = "BOTTOMRIGHT",
                    AnchorParent            = "MilaUI_Player",
                    Direction               = "LR",
                    Texture                 = "Smooth",
                    BackgroundTexture       = "Smooth",
                    CustomMask = {
                        Enabled = true,
                        MaskTexture = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2.tga",
                    },
                    CustomBorder = {
                        Enabled = true,
                        BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2.tga",
                    },
                    Enabled                 = true,
                    ColourByType            = true,
                    ColourBackgroundByType  = true,
                    BackgroundMultiplier    = 0.25,
                    Colour                  = {0/255, 0/255, 1/255, 1},
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Buffs = {
                    Enabled             = false,
                    Size                = 32,
                    Spacing             = 1,
                    Num                 = 7,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "PowerBar",
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "DOWN",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 32,
                    Spacing             = 1,
                    Num                 = 7,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "Buffs",
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "DOWN",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom      = "BOTTOMRIGHT",
                        AnchorTo        = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                TargetMarker = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = 0,
                    YOffset             = 0,
                    AnchorFrom          = "CENTER",
                    AnchorTo            = "TOP",
                },
                CombatIndicator = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -30,
                    YOffset             = 0,
                    AnchorFrom          = "CENTER",
                    AnchorTo            = "RIGHT",
                },
                LeaderIndicator = {
                    Enabled             = true,
                    Size                = 16,
                    XOffset             = 7,
                    YOffset             = 0,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "TOPLEFT",
                },
                Texts = {
                    First = {
                        AnchorTo        = "TOPLEFT",
                        AnchorFrom      = "LEFT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 16,
                        XOffset         = 23,
                        YOffset         = 0,
                        Tag             = "[name]",
                    },
                    Second = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 14,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "[Health:CurHPwithPerHP]",
                    },
                    Third = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = -28,
                        Tag             = "[Power:PerPP]",
                    },
                },
            },
            Target = {
                Frame = {
                    Enabled             = true,
                    CustomScale         = false,
                    Scale               = 1,
                    Width               = 230,
                    Height              = 38,
                    XPosition           = 300,
                    YPosition           = -150,
                    AnchorFrom          = "CENTER",
                    AnchorTo            = "CENTER",
                    AnchorParent        = "UIParent",
                },
                Portrait = {
                    Enabled         = false,
                    Size            = 42,
                    XOffset         = -1,
                    YOffset         = 0,
                    AnchorFrom      = "LEFT",
                    AnchorTo        = "RIGHT",
                },
                Health = {
                    Width               = 230,
                    Height              = 38,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    CustomMask = {
                        Enabled = true,
                        MaskTexture = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled = true,
                        BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_style2_mirrored.tga",
                    },
                    HealthPrediction = {
                        Enabled = true,
                        IncomingHeals = {},
                        HealAbsorbs = {
                            Enabled = true,
                            Colour = {128/255, 64/255, 255/255, 1},
                        },
                        Absorbs = {
                            Enabled         = true,
                            Colour          = {255/255, 205/255, 0/255, 1},
                            ColourByType    = true,
                        }
                    }
                },
                PowerBar = {
                    Width                   = 219,
                    Height                  = 19,
                    Direction               = "LR",
                    Texture                 = "Smooth",
                    BackgroundTexture       = "Smooth",
                    XPosition               = 0,
                    YPosition               = 0,
                    AnchorFrom              = "TOPLEFT",
                    AnchorTo                = "BOTTOMLEFT",
                    AnchorParent            = "MilaUI_Target",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    Enabled                 = true,
                    ColourByType            = true,
                    ColourBackgroundByType  = true,
                    BackgroundMultiplier    = 0.25,
                    Colour                  = {0/255, 0/255, 1/255, 1},
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Buffs = {
                    Enabled             = true,
                    Size                = 32,
                    Spacing             = 1,
                    Num                 = 7,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "PowerBar",
                    XOffset             = 10,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "DOWN",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 32,
                    Spacing             = 1,
                    Num                 = 3,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "Buffs",
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "LEFT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                },
                TargetMarker = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -3,
                    YOffset             = 0,
                    AnchorFrom          = "RIGHT",
                    AnchorTo            = "TOPRIGHT",
                },
                CombatIndicator = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -30,
                    YOffset             = 0,
                    AnchorFrom          = "CENTER",
                    AnchorTo            = "RIGHT",
                },
                LeaderIndicator = {
                    Enabled             = true,
                    Size                = 16,
                    XOffset             = 7,
                    YOffset             = 0,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "TOPLEFT",
                },
                Texts = {
                    First = {
                        AnchorTo        = "TOPRIGHT",
                        AnchorFrom      = "RIGHT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 16,
                        XOffset         = -15,
                        YOffset         = 0,
                        Tag             = "[Name:NamewithTargetTarget:LastNameOnly]",
                    },
                    Second = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 14,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "[Health:CurHPwithPerHP]",
                    },
                    Third = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = -28,
                        Tag             = "[Power:PerPP]",
                    },
                },
            },
            TargetTarget = {
                Frame = {
                    Enabled             = false,
                    CustomScale         = true,
                    Scale               = 0.4,
                    Width               = 230,
                    Height              = 38,
                    XPosition           = 1.1,
                    YPosition           = 0,
                    AnchorFrom          = "TOPRIGHT",
                    AnchorTo            = "BOTTOMRIGHT",
                    AnchorParent        = "MilaUI_Target",
                },
                Portrait = {
                    Enabled         = false,
                    Size            = 42,
                    XOffset         = 1,
                    YOffset         = 0,
                    AnchorFrom      = "LEFT",
                    AnchorTo        = "RIGHT",
                },
                Health = {
                    Width               = 230,
                    Height              = 38,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_style2_mirrored.tga",
                    },
                    HealthPrediction = {
                        Enabled = false,
                        IncomingHeals = {},
                        HealAbsorbs = {
                            Enabled = false,
                            Colour = {128/255, 64/255, 255/255, 1},
                        },
                        Absorbs = {
                            Enabled         = false,
                            Colour          = {255/255, 205/255, 0/255, 1},
                            ColourByType    = true,
                        }
                    }
                },
                PowerBar = {
                    Width                  = 230,
                    Height                 = 38,
                    XPosition              = 0,
                    YPosition              = 0,
                    AnchorFrom             = "RIGHT",
                    AnchorTo               = "BOTTOMRIGHT",
                    AnchorParent           = "UIParent",
                    Direction              = "LR",
                    Texture                = "Smooth",
                    BackgroundTexture      = "Smooth",
                    CustomMask = {
                        Enabled = true,
                        MaskTexture = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled = true,
                        BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    Enabled                 = false,
                    ColourByType            = true,
                    ColourBackgroundByType  = true,
                    BackgroundMultiplier    = 0.25,
                    Colour                  = {0/255, 0/255, 1/255, 1},
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Buffs = {
                    Enabled             = false,
                    Size                = 42,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_TargetTarget",
                    XOffset             = 1,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_TargetTarget",
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                TargetMarker = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -3,
                    YOffset             = 0,
                    AnchorFrom          = "RIGHT",
                    AnchorTo            = "TOPRIGHT",
                },
                Texts = {
                    First = {
                        AnchorTo        = "LEFT",
                        AnchorFrom      = "LEFT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 3,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    Second = {
                        AnchorTo        = "RIGHT",
                        AnchorFrom      = "RIGHT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = -3,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    Third = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "[Name:LastNameOnly]",
                    },
                }
            },
            Focus = {
                Frame = {
                    Enabled             = true,
                    CustomScale         = true,
                    Scale               = 0.6,
                    Width               = 230,
                    Height              = 38,
                    XPosition           = 0,
                    YPosition           = 40.1,
                    AnchorFrom          = "BOTTOMLEFT",
                    AnchorTo            = "TOPLEFT",
                    AnchorParent        = "MilaUI_Target",
                },
                Portrait = {
                    Enabled         = false,
                    Size            = 42,
                    XOffset         = 1,
                    YOffset         = 0,
                    AnchorFrom      = "LEFT",
                    AnchorTo        = "RIGHT",
                },
                Health = {
                    Width               = 230,
                    Height              = 38,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_style2_mirrored.tga",
                    },
                    HealthPrediction = {
                        Enabled = false,
                        IncomingHeals = {},
                        HealAbsorbs = {
                            Enabled = false,
                            Colour = {128/255, 64/255, 255/255, 1},
                        },
                        Absorbs = {
                            Enabled         = true,
                            Colour          = {255/255, 205/255, 0/255, 1},
                            ColourByType    = true,
                        }
                    }
                },
                PowerBar = {
                    Width                  = 219,
                    Height                 = 19,
                    Direction              = "LR",
                    Texture                = "Smooth",
                    BackgroundTexture      = "Smooth",
                    XPosition              = 0,
                    YPosition              = 0,
                    AnchorFrom             = "TOPLEFT",
                    AnchorTo               = "BOTTOMLEFT",
                    AnchorParent           = "MilaUI_Focus",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    Enabled                 = true,
                    ColourByType            = true,
                    ColourBackgroundByType  = true,
                    BackgroundMultiplier    = 0.25,
                    Colour                  = {0/255, 0/255, 1/255, 1},
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Buffs = {
                    Enabled             = false,
                    Size                = 42,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_Focus",
                    XOffset             = 1,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_Focus",
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                },
                TargetMarker = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -3,
                    YOffset             = 0,
                    AnchorFrom          = "RIGHT",
                    AnchorTo            = "TOPRIGHT",
                },
                CombatIndicator = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -30,
                    YOffset             = 0,
                    AnchorFrom          = "CENTER",
                    AnchorTo            = "RIGHT",
                },
                Texts = {
                    First = {
                        AnchorTo        = "TOPRIGHT",
                        AnchorFrom      = "RIGHT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 16,
                        XOffset         = -22,
                        YOffset         = 0,
                        Tag             = "[Name:LastNameOnly]",
                    },
                    Second = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 14,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "[Health:CurHPwithPerHP]",
                    },
                    Third = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = -28,
                        Tag             = "[Power:PerPP]",
                    },
                }
            },
            FocusTarget = {
                Frame = {
                    Enabled             = false,
                    CustomScale         = true,
                    Scale               = 0.4,
                    Width               = 120,
                    Height              = 28,
                    XPosition           = 0,
                    YPosition           = 1.1,
                    AnchorFrom          = "BOTTOMLEFT",
                    AnchorTo            = "TOPLEFT",
                    AnchorParent        = "MilaUI_Focus",
                },
                Portrait = {
                    Enabled         = false,
                    Size            = 28,
                    XOffset         = 1,
                    YOffset         = 0,
                    AnchorFrom      = "LEFT",
                    AnchorTo        = "RIGHT",
                },
                Health = {
                    Width               = 120,
                    Height              = 28,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_style2_mirrored.tga",
                    },
                    HealthPrediction = {
                        Enabled = false,
                        IncomingHeals = {},
                        HealAbsorbs = {
                            Enabled = false,
                            Colour = {128/255, 64/255, 255/255, 1},
                        },
                        Absorbs = {
                            Enabled         = false,
                            Colour          = {255/255, 205/255, 0/255, 1},
                            ColourByType    = true,
                        }
                    }
                },
                PowerBar = {
                    Width               = 120,
                    Height              = 28,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    XPosition           = 0,
                    YPosition           = 0,
                    AnchorFrom          = "TOPRIGHT",
                    AnchorTo            = "BOTTOMRIGHT",
                    AnchorParent        = "MilaUI_FocusTarget",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    Enabled                 = false,
                    ColourByType            = true,
                    ColourBackgroundByType  = true,
                    BackgroundMultiplier    = 0.25,
                    Colour                  = {0/255, 0/255, 1/255, 1},
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Buffs = {
                    Enabled             = false,
                    Size                = 42,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_FocusTarget",
                    XOffset             = 1,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_FocusTarget",
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                },
                TargetMarker = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -3,
                    YOffset             = 0,
                    AnchorFrom          = "RIGHT",
                    AnchorTo            = "TOPRIGHT",
                },
                Texts = {
                    First = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "[Name:LastNameOnly]",
                    },
                    Second = {
                        AnchorTo        = "RIGHT",
                        AnchorFrom      = "RIGHT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = -3,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    Third = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                }
            },
            Pet = {
                Frame = {
                    Enabled             = true,
                    CustomScale         = true,
                    Scale               = 0.4,
                    Width               = 230,
                    Height              = 19,
                    XPosition           = 0,
                    YPosition           = -1.1,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorParent        = "MilaUI_Player",
                },
                Portrait = {
                    Enabled         = false,
                    Size            = 42,
                    XOffset         = -1,
                    YOffset         = 0,
                    AnchorFrom      = "RIGHT",
                    AnchorTo        = "LEFT",
                },
                Health = {
                    Width               = 230,
                    Height              = 19,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_style2.tga",
                    },
                    ColourByPlayerClass = false,
                    HealthPrediction = {
                        Enabled = false,
                        IncomingHeals = {},
                        HealAbsorbs = {
                            Enabled = false,
                            Colour = {128/255, 64/255, 255/255, 1},
                        },
                        Absorbs = {
                            Enabled         = false,
                            Colour          = {255/255, 205/255, 0/255, 1},
                            ColourByType    = true,
                        }
                    }
                },
                PowerBar = {
                    Width               = 219,
                    Height              = 19,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    XPosition           = 0,
                    YPosition           = 0,
                    AnchorFrom          = "BOTTOMRIGHT",
                    AnchorTo            = "TOPRIGHT",
                    AnchorParent        = "MilaUI_Pet",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    Enabled                 = false,
                    Height                  = 5,
                    ColourByType            = true,
                    ColourBackgroundByType  = true,
                    BackgroundMultiplier    = 0.25,
                    Colour                  = {0/255, 0/255, 1/255, 1},
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Buffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 7,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "MilaUI_Pet",
                    XOffset             = 0,
                    YOffset             = -1,
                    GrowthX             = "RIGHT",
                    GrowthY             = "DOWN",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 7,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "MilaUI_Pet",
                    XOffset             = 0,
                    YOffset             = -1,
                    GrowthX             = "RIGHT",
                    GrowthY             = "DOWN",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                TargetMarker = {
                    Enabled             = false,
                    Size                = 24,
                    XOffset             = 0,
                    YOffset             = 0,
                    AnchorFrom          = "CENTER",
                    AnchorTo            = "CENTER",
                },
                Texts = {
                    First = {
                        AnchorTo        = "LEFT",
                        AnchorFrom      = "LEFT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 3,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    Second = {
                        AnchorTo        = "RIGHT",
                        AnchorFrom      = "RIGHT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = -3,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    Third = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                }
            },
            Boss = {
                Frame = {
                    Enabled             = true,
                    CustomScale         = false,
                    Scale               = 1,
                    Width               = 230,
                    Height              = 38,
                    XPosition           = 750.1,
                    YPosition           = 0.1,
                    Spacing             = 26.1,
                    AnchorFrom          = "CENTER",
                    AnchorTo            = "CENTER",
                    AnchorParent        = "UIParent",
                    GrowthY             = "DOWN",
                },
                Portrait = {
                    Enabled         = false,
                    Size            = 42,
                    XOffset         = -1,
                    YOffset         = 0,
                    AnchorFrom      = "RIGHT",
                    AnchorTo        = "LEFT",
                },
                Health = {
                    Width               = 230,
                    Height              = 38,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_style2_mirrored.tga",
                    },
                    HealthPrediction = {
                        Enabled = true,
                        IncomingHeals = {},
                        HealAbsorbs = {
                            Enabled = true,
                            Colour = {128/255, 64/255, 255/255, 1},
                        },
                        Absorbs = {
                            Enabled         = true,
                            Colour          = {255/255, 205/255, 0/255, 1},
                            ColourByType    = true,
                        }
                    }
                },
                PowerBar = {
                    Width               = 219,
                    Height              = 19,
                    Direction           = "LR",
                    Texture             = "Smooth",
                    BackgroundTexture   = "Smooth",
                    XPosition           = 0,
                    YPosition           = 0,
                    AnchorFrom          = "BOTTOMRIGHT",
                    AnchorTo            = "TOPRIGHT",
                    AnchorParent        = "MilaUI_Boss",
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    Enabled                 = true,
                    ColourByType            = true,
                    ColourBackgroundByType  = true,
                    BackgroundMultiplier    = 0.25,
                    Colour                  = {0/255, 0/255, 1/255, 1},
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Buffs = {
                    Enabled             = true,
                    Size                = 42,
                    Spacing             = 1,
                    Num                 = 3,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_Boss",
                    XOffset             = 1,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 42,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "RIGHT",
                    AnchorTo            = "LEFT",
                    AnchorFrame         = "MilaUI_Boss",
                    XOffset             = -1,
                    YOffset             = 0,
                    GrowthX             = "LEFT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true
                },
                TargetMarker = {
                    Enabled             = true,
                    Size                = 24,
                    XOffset             = -3,
                    YOffset             = 0,
                    AnchorFrom          = "RIGHT",
                    AnchorTo            = "TOPRIGHT",
                },
                TargetIndicator = {
                    Enabled            = true,
                },
                Texts = {
                    First = {
                        AnchorTo        = "LEFT",
                        AnchorFrom      = "LEFT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 3,
                        YOffset         = 0,
                        Tag             = "[Name:LastNameOnly]",
                    },
                    Second = {
                        AnchorTo        = "RIGHT",
                        AnchorFrom      = "RIGHT",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = -3,
                        YOffset         = 0,
                        Tag             = "[Health:CurHPwithPerHP]",
                    },
                    Third = {
                        AnchorTo        = "CENTER",
                        AnchorFrom      = "CENTER",
                        Colour         = {1, 1, 1, 1},
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                }
            }
        },
    }
}

function MilaUIAddon:MigrateDatabase()
    local db = MilaUI.DB.profile
    db.Unitframes = db.Unitframes or {}
    if db.Unitframes.migrated == false then
        local migratedAny = false
        if db.Player then
            db.Unitframes.Player = db.Player
            print(lavender .. "MilaUI:" .. pink .. " Migrated Player settings to Unitframes.Player")
            db.Player = nil
            migratedAny = true
        end

        if db.Target then
            db.Unitframes.Target = db.Target  
            print(lavender .. "MilaUI:" .. pink .. " Migrated Target settings to Unitframes.Target")
            db.Target = nil
            migratedAny = true
        end
        
        if db.Focus then
            db.Unitframes.Focus = db.Focus
            print(lavender .. "MilaUI:" .. pink .. " Migrated Focus settings to Unitframes.Focus")
            db.Focus = nil
            migratedAny = true
        end
        
        if db.Pet then
            db.Unitframes.Pet = db.Pet
            print(lavender .. "MilaUI:" .. pink .. " Migrated Pet settings to Unitframes.Pet")
            db.Pet = nil
            migratedAny = true
        end
        
        if db.TargetTarget then
            db.Unitframes.TargetTarget = db.TargetTarget
            print(lavender .. "MilaUI:" .. pink .. " Migrated TargetTarget settings to Unitframes.TargetTarget")
            db.TargetTarget = nil
            migratedAny = true
        end
        
        if db.FocusTarget then
            db.Unitframes.FocusTarget = db.FocusTarget
            print(lavender .. "MilaUI:" .. pink .. " Migrated FocusTarget settings to Unitframes.FocusTarget")
            db.FocusTarget = nil
            migratedAny = true
        end
        
        if db.Boss then
            db.Unitframes.Boss = db.Boss
            print(lavender .. "MilaUI:" .. pink .. " Migrated Boss settings to Unitframes.Boss")
            db.Boss = nil
            migratedAny = true
        end
        
        if migratedAny then
            print(lavender .. "MilaUI:" .. pink .. " Database migration complete!")
        else
            print(lavender .. "MilaUI:" .. pink .. " No database entries needed migration.")
        end
        db.Unitframes.migrated = true
        MilaUI:UpdateFrames()
        MilaUI:CreateReloadPrompt()
    end
end

function MilaUIAddon:OnInitialize()
    MilaUI.DB = LibStub("AceDB-3.0"):New("MilaUIDB", MilaUIAddon.Defaults)
    for k, v in pairs(MilaUIAddon.Defaults) do
        if MilaUI.DB.profile[k] == nil then
            MilaUI.DB.profile[k] = v
        end
    end
end

function MilaUI:SetupSlashCommands()
    SLASH_MilaUI1 = "/MilaUI"
    SLASH_MilaUI2 = "/MilaUI"
    SLASH_MilaUI3 = "/mui"
    SLASH_MilaUI4 = "/Mila"
    SlashCmdList["MilaUI"] = function(msg)
        if msg == "" then
            MilaUI_OpenGUIMain()
        elseif msg == "reset" then
            MilaUI:ResetDefaultSettings()
        elseif msg == "help" then
            print(pink .. "♥MILA UI ♥:  " .. lavender .. " Slash Commands.")
            print(pink .. "/MilaUI or /MUI:" .. lavender .. " Opens the GUI")
            print(pink .. "/MilaUI reset or /MUI reset:" .. lavender .. " Resets To Default")
        end
    end
    SLASH_MILAUIPRINT1 = "/muiprint"
    local db = MilaUI.DB  -- Use MilaUI.DB, which is where your DB lives
    SlashCmdList["MILAUIPRINT"] = function(msg)
        local path = {strsplit(".", msg)}
        local value = db
        for _, key in ipairs(path) do
            if value and type(value) == "table" then
                value = value[key]
            else
                value = nil
                break
            end
        end
        print("Value:", value)
    end
    SLASH_MILAUICOLORS1 = "/milacolors"
    SlashCmdList["MILAUICOLORS"] = function()
        local colors = MilaUI.DB.profile.Unitframes.General.CustomColours.Reaction
        for k, v in pairs(colors) do
            print("Reaction", k, "->", string.format("r=%.2f g=%.2f b=%.2f", v[1], v[2], v[3]))
        end
    end
end



function MilaUIAddon:OnEnable()
    if MilaUI.DB.global.UIScaleEnabled then UIParent:SetScale(MilaUI.DB.global.UIScale) end
    if MilaUI.DB.profile.TestMode then MilaUI.DB.profile.TestMode = false end
    -- Check if CursorMod module exists and handle its state
    local cursorMod = MilaUIAddon:GetModule("CursorMod", true)
    if cursorMod then
        if not MilaUI.DB.profile.CursorMod.enabled then
            MilaUIAddon:DisableModule("CursorMod")
        end
    end
    MilaUIAddon:MigrateDatabase()
    MilaUI:UpdateEscapeMenuScale()
    MilaUI:SetTagUpdateInterval()
    MilaUI:LoadCustomColours()
    MilaUI:SpawnPlayerFrame()
    MilaUI:SpawnTargetFrame()
    MilaUI:SpawnTargetTargetFrame()
    MilaUI:SpawnFocusFrame()
    MilaUI:SpawnFocusTargetFrame()
    MilaUI:SpawnPetFrame()
    MilaUI:SpawnBossFrames()
    MilaUI:SetupSlashCommands()
    print(pink .. "♥MILA UI ♥:  " .. lavender .. "Type: " .. pink .. "/MUI" .. lavender .. " for in-game configuration.")
end
