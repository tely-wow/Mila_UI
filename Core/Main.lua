local _, MilaUI = ...
local MilaUIAddon = LibStub("AceAddon-3.0"):NewAddon("MilaUI")
MilaUI.addon = MilaUIAddon
MilaUI.NewCastbarSystem = MilaUI.NewCastbarSystem or {}
MilaUI.modules = MilaUI.modules or {}
MilaUI.modules.bars = MilaUI.NewCastbarSystem
MilaUIAddon_GUI = MilaUIAddon_GUI or {}
MilaUIAddon:SetDefaultModuleState(false)

MilaUIAddon.Defaults = {
    global = {
        UIScaleEnabled    = true,
        UIScale           = 0.65,
        GameMenuScale     = 1,
        TagUpdateInterval = 0.5,
        FramesLocked      = true,
        DebugMode         = false,
        Colors = {
            pink = "|cffFF77B5",
            lavender = "|cFFCBA0E3",
            white = "|cffffffff",
        },
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
                },
                CastbarSettings = {
                    font = "Expressway",
                    fontSize = 10,
                    fontFlags = "OUTLINE",
                },
            },
            AuraFilters = {
                Buffs = {
                    Blacklists = {
                        
                    },
                    Whitelists = {
                        
                    },
                },
                Debuffs = {
                    Blacklists = {
                        
                    },
                    Whitelists = {
                        
                    },
                },
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
                    Colors = {
                        ColorByStaticColor                = false,
                        StaticColor                       = {1, 1, 1},
                        ColourByClass                     = true,
                        ColourByReaction                  = true,
                        ColourIfDisconnected              = true,
                        ColourIfTapped                    = true,
                        ColorBackgroundByStaticColor      = false,
                        BackgroundStaticColor             = {1, 1, 1},
                        ColourBackgroundByForeground      = false,
                        ColourBackgroundByClass           = false,
                        ColourBackgroundIfDead            = false,
                        BackgroundMultiplier              = 0.25,
                        Status = {
                            [1] = {255/255, 64/255, 64/255},           -- Dead
                            [2] = {153/255, 153/255, 153/255}, -- Tapped 
                            [3] = {0.6, 0.6, 0.6}, -- Disconnected
                        }
                        
                    },
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
                    BackgroundColour        = {26 / 255, 26 / 255, 26 / 26 / 255, 1},
                    Smooth = false,
                },
                Castbar = {
                    enabled = true,
                    CustomScale = false,
                    Scale = 1,
                    CustomMask = {
                        Enabled = true,
                        MaskTexture = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2.tga",
                    },
                    CustomBorder = {
                        Enabled = true,
                        BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2.tga",
                    },
                    width = 200,
                    height = 20,
                    texture = "Smooth",
                    backgroundColor = {0.1, 0.1, 0.1, 0.8},
                    border = false,
                    borderColor = {0, 0, 0, 1},
                    borderSize = 1,
                    showShield = true,
                    showSafeZone = true,
                    safeZoneColor = {1, 0, 0, 0.6},
                    timeToHold = 0.5,         -- How long to show failed/interrupted casts
                    hideTradeSkills = false,  -- Whether to hide profession casts
                    textures = {
                        channel = "Smooth",
                        cast = "Smooth",
                        uninterruptible = "Smooth",
                        castcolor = {1, 0.7, 0, 1},
                        channelcolor = {0, 0.7, 1, 1},
                        uninterruptiblecolor = {0.7, 0, 0, 1},
                        failedcolor = {1, 0.3, 0.3, 1},
                    },
                    Icon = {
                        showIcon = true,
                        iconSize = 24,
                        iconPosition = "LEFT",    -- LEFT or RIGHT
                    },
                    Spark = {
                        showSpark = true,
                        sparkWidth = 10,
                        sparkHeight = 30,
                        sparkTexture = "Interface\\Buttons\\WHITE8X8",
                        sparkColor = {1, 1, 1, 1},
                    },
                    text = {
                        showText = true,
                        textJustify = "LEFT",
                        timeJustify = "RIGHT",
                        showTime = true,
                        timeFormat = "%.1f",
                        textsize = 12,
                        timesize = 12,
                        textColor = {1, 1, 1, 1},
                        timeColor = {1, 1, 1, 1},
                    }, 
                    position = {
                        anchorParent = "MilaUI_Player",
                        anchorTo = "BOTTOM",
                        anchorFrom = "TOP", 
                        xOffset = 0,
                        yOffset = -20
                    }
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
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    ShowStealableBuffs = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 32,
                    Spacing             = 1,
                    Num                 = 7,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "Buffs",
                    SmartAnchoring      = true,
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "DOWN",
                    Count               = {
                        FontSize        = 12,
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom      = "BOTTOMRIGHT",
                        AnchorTo        = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
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
                    Colors = {
                        ColorByStaticColor                = false,
                        StaticColor                       = {1, 1, 1},
                        ColourByClass                     = true,
                        ColourByReaction                  = true,
                        ColourIfDisconnected              = true,
                        ColourIfTapped                    = true,
                        ColorBackgroundByStaticColor      = false,
                        BackgroundStaticColor             = {1, 1, 1},
                        ColourBackgroundByForeground      = false,
                        ColourBackgroundByClass           = false,
                        ColourBackgroundIfDead            = false,
                        BackgroundMultiplier              = 0.25,
                        Status = {
                            [1] = {255/255, 64/255, 64/255},           -- Dead
                            [2] = {153/255, 153/255, 153/255}, -- Tapped 
                            [3] = {0.6, 0.6, 0.6}, -- Disconnected
                        }
                        
                    },
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
                Castbar = {
                    enabled = true,
                    CustomScale = false,
                    Scale = 1,
                    border = false,
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    width = 200,
                    height = 20,
                    texture = "Smooth",
                    backgroundColor = {0.1, 0.1, 0.1, 0.8},
                    borderColor = {0, 0, 0, 1},
                    borderSize = 1,
                    showShield = true,
                    timeToHold = 0.5,
                    textures = {
                        channel = "Smooth",
                        cast = "Smooth",
                        uninterruptible = "Smooth",
                        castcolor = {1, 0.7, 0, 1},
                        channelcolor = {0, 0.7, 1, 1},
                        uninterruptiblecolor = {0.7, 0, 0, 1},
                        failedcolor = {1, 0.3, 0.3, 1},
                    },    
                    Icon = {
                        showIcon = true,
                        iconSize = 24,
                        iconPosition = "LEFT",    
                    },
                    Spark = {
                        showSpark = true,
                        sparkWidth = 10,
                        sparkHeight = 30,
                        sparkTexture = "Interface\\Buttons\\WHITE8X8",
                        sparkColor = {1, 1, 1, 1},
                    },
                    text = {
                        showText = true,
                        textJustify = "LEFT",
                        timeJustify = "RIGHT",
                        showTime = true,
                        timeFormat = "%.1f",
                        textsize = 12,
                        timesize = 12,
                        textColor = {1, 1, 1, 1},
                        timeColor = {1, 1, 1, 1},
                    }, 
                    position = {
                        anchorTo = "BOTTOM",
                        anchorFrom = "TOP", 
                        anchorParent = "MilaUI_Target",
                        xOffset = 0,
                        yOffset = -20
                    }
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
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    ShowStealableBuffs = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 32,
                    Spacing             = 1,
                    Num                 = 3,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "Buffs",
                    SmartAnchoring      = true,
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "LEFT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
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
                    Colors = {
                        ColorByStaticColor                = false,
                        StaticColor                       = {1, 1, 1},
                        ColourByClass                     = true,
                        ColourByReaction                  = true,
                        ColourIfDisconnected              = true,
                        ColourIfTapped                    = true,
                        ColorBackgroundByStaticColor      = false,
                        BackgroundStaticColor             = {1, 1, 1},
                        ColourBackgroundByForeground      = false,
                        ColourBackgroundByClass           = false,
                        ColourBackgroundIfDead            = false,
                        BackgroundMultiplier              = 0.25,
                        Status = {
                            [1] = {255/255, 64/255, 64/255},           -- Dead
                            [2] = {153/255, 153/255, 153/255}, -- Tapped 
                            [3] = {0.6, 0.6, 0.6}, -- Disconnected
                        }
                        
                    },
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
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    ShowStealableBuffs = false,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_TargetTarget",
                    SmartAnchoring      = false,
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
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
                    Colors = {
                        ColourByClass                     = true,
                        ColourByReaction                  = true,
                        ColourIfDisconnected              = true,
                        ColourIfTapped                    = true,
                        ColorBackgroundByStaticColor      = false,
                        BackgroundStaticColor             = {1, 1, 1},
                        ColourBackgroundByForeground      = false,
                        ColourBackgroundByClass           = false,
                        ColourBackgroundIfDead            = false,
                        BackgroundMultiplier              = 0.25,
                        Status = {
                            [1] = {255/255, 64/255, 64/255},           -- Dead
                            [2] = {153/255, 153/255, 153/255}, -- Tapped 
                            [3] = {0.6, 0.6, 0.6}, -- Disconnected
                        }
                        
                    },
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
                    BackgroundColour        = {26 / 255, 26 / 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Castbar = {
                    enabled = true,
                    CustomScale = false,
                    Scale = 1,
                    border = false,
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    width = 200,
                    height = 20,
                    texture = "Smooth",
                    backgroundColor = {0.1, 0.1, 0.1, 0.8},
                    borderColor = {0, 0, 0, 1},
                    borderSize = 1,
                    showShield = true,
                    timeToHold = 0.5,    
                    textures = {
                        channel = "Smooth",
                        cast = "Smooth",
                        uninterruptible = "Smooth",
                        castcolor = {1, 0.7, 0, 1},
                        channelcolor = {0, 0.7, 1, 1},
                        uninterruptiblecolor = {0.7, 0, 0, 1},
                        failedcolor = {1, 0.3, 0.3, 1},
                    },    
                    Icon = {
                        showIcon = true,
                        iconSize = 24,
                        iconPosition = "LEFT",    
                    },
                    Spark = {
                        showSpark = true,
                        sparkWidth = 10,
                        sparkHeight = 30,
                        sparkTexture = "Interface\\Buttons\\WHITE8X8",
                        sparkColor = {1, 1, 1, 1},
                    },
                    text = {
                        showText = true,
                        textJustify = "LEFT",
                        timeJustify = "RIGHT",
                        showTime = true,
                        timeFormat = "%.1f",
                        textsize = 12,
                        timesize = 12,
                        textColor = {1, 1, 1, 1},
                        timeColor = {1, 1, 1, 1},
                    }, 
                    position = {
                        anchorParent = "MilaUI_Focus",
                        anchorTo = "BOTTOM",
                        anchorFrom = "TOP", 
                        xOffset = 0,
                        yOffset = -20
                    }
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
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    ShowStealableBuffs = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_Focus",
                    SmartAnchoring      = false,
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
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
                    Colors = {
                        ColorByStaticColor                = false,
                        StaticColor                       = {1, 1, 1},
                        ColourByClass                     = true,
                        ColourByReaction                  = true,
                        ColourIfDisconnected              = true,
                        ColourIfTapped                    = true,
                        ColorBackgroundByStaticColor      = false,
                        BackgroundStaticColor             = {0.17, 0.09, 0.09},
                        ColourBackgroundByForeground      = false,
                        ColourBackgroundByClass           = false,
                        ColourBackgroundIfDead            = false,
                        BackgroundMultiplier              = 0.25,
                        Status = {
                            [1] = {255/255, 64/255, 64/255},           -- Dead
                            [2] = {153/255, 153/255, 153/255}, -- Tapped 
                            [3] = {0.6, 0.6, 0.6}, -- Disconnected
                        }
                        
                    },
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
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    ShowStealableBuffs = false,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "LEFT",
                    AnchorTo            = "RIGHT",
                    AnchorFrame         = "MilaUI_FocusTarget",
                    SmartAnchoring      = false,
                    XOffset             = 0,
                    YOffset             = 0,
                    GrowthX             = "RIGHT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
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
                    Colors = {
                        ColorByStaticColor                = false,
                        StaticColor                       = {1, 1, 1},
                        ColourByClass                     = true,
                        ColourByReaction                  = true,
                        ColourIfDisconnected              = true,
                        ColourIfTapped                    = true,
                        ColorBackgroundByStaticColor      = false,
                        BackgroundStaticColor             = {1, 1, 1},
                        ColourBackgroundByForeground      = false,
                        ColourBackgroundByClass           = false,
                        ColourBackgroundIfDead            = false,
                        BackgroundMultiplier              = 0.25,
                        Status = {
                            [1] = {255/255, 64/255, 64/255},           -- Dead
                            [2] = {153/255, 153/255, 153/255}, -- Tapped 
                            [3] = {0.6, 0.6, 0.6}, -- Disconnected
                        }
                        
                    },
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
                Castbar = {
                    border = false,
                    CustomMask = {
                        Enabled = true,
                        MaskTexture = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2.tga",
                    },
                    CustomBorder = {
                        Enabled = true,
                        BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2.tga",
                    },
                    enabled = true,
                    width = 200,
                    height = 20,
                    texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                    backgroundColor = {0.1, 0.1, 0.1, 0.8},
                    borderColor = {0, 0, 0, 1},
                    borderSize = 1,
                    showShield = true,
                    timeToHold = 0.5,         -- How long to show failed/interrupted casts
                    hideTradeSkills = false,  -- Whether to hide profession casts
                    textures = {
                        channel = "Smooth",
                        cast = "Smooth",
                        uninterruptible = "Smooth",
                        castcolor = {1, 0.7, 0, 1},
                        channelcolor = {0, 0.7, 1, 1},
                        uninterruptiblecolor = {0.7, 0, 0, 1},
                        failedcolor = {1, 0.3, 0.3, 1},
                    },
                    Icon = {
                        showIcon = true,
                        iconSize = 24,
                        iconPosition = "LEFT",    -- LEFT or RIGHT
                    },
                    Spark = {
                        showSpark = true,
                        sparkWidth = 10,
                        sparkHeight = 30,
                        sparkTexture = "Interface\\Buttons\\WHITE8X8",
                        sparkColor = {1, 1, 1, 1},
                    },
                    text = {
                        showText = true,
                        textJustify = "LEFT",
                        timeJustify = "RIGHT",
                        showTime = true,
                        timeFormat = "%.1f",
                        textsize = 12,
                        timesize = 12,
                        textColor = {1, 1, 1, 1},
                        timeColor = {1, 1, 1, 1},
                    }, 
                    position = {
                        anchorParent = "MilaUI_Pet",
                        anchorTo = "BOTTOM",
                        anchorFrom = "TOP", 
                        xOffset = 0,
                        yOffset = -20
                    }
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
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    ShowStealableBuffs = false,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 38,
                    Spacing             = 1,
                    Num                 = 7,
                    AnchorFrom          = "TOPLEFT",
                    AnchorTo            = "BOTTOMLEFT",
                    AnchorFrame         = "MilaUI_Pet",
                    SmartAnchoring      = false,
                    XOffset             = 0,
                    YOffset             = -1,
                    GrowthX             = "RIGHT",
                    GrowthY             = "DOWN",
                    Count               = {
                        FontSize        = 12,
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = false,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
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
                    Colors = {
                        ColorByStaticColor                = false,
                        StaticColor                       = {1, 1, 1},
                        ColourByClass                     = true,
                        ColourByReaction                  = true,
                        ColourIfDisconnected              = true,
                        ColourIfTapped                    = true,
                        ColorBackgroundByStaticColor      = false,
                        BackgroundStaticColor             = {1, 1, 1},
                        ColourBackgroundByForeground      = false,
                        ColourBackgroundByClass           = false,
                        ColourBackgroundIfDead            = false,
                        BackgroundMultiplier              = 0.25,
                        Status = {
                            [1] = {255/255, 64/255, 64/255},           -- Dead
                            [2] = {153/255, 153/255, 153/255}, -- Tapped 
                            [3] = {0.6, 0.6, 0.6}, -- Disconnected
                        }
                        
                    },
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
                    BackgroundColour        = {26 / 255, 26 / 26 / 255, 26 / 255, 1},
                    Smooth = false,
                },
                Castbar = {
                    enabled = true,
                    border = false,
                    CustomScale = false,
                    Scale = 1,
                    CustomMask = {
                        Enabled         = true,
                        MaskTexture     = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\parallelogram_power_style2_mirrored.tga",
                    },
                    CustomBorder = {
                        Enabled         = true,
                        BorderTexture   = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\power_border_style2_mirrored.tga",
                    },
                    width = 200,
                    height = 20,
                    texture = "Smooth",
                    backgroundColor = {0.1, 0.1, 0.1, 0.8},
                    borderColor = {0, 0, 0, 1},
                    borderSize = 1,
                    showShield = true,
                    timeToHold = 0.5,    
                    textures = {
                        channel = "Smooth",
                        cast = "Smooth",
                        uninterruptible = "Smooth",
                        castcolor = {1, 0.7, 0, 1},
                        channelcolor = {0, 0.7, 1, 1},
                        uninterruptiblecolor = {0.7, 0, 0, 1},
                        failedcolor = {1, 0.3, 0.3, 1},
                    },    
                    Icon = {
                        showIcon = true,
                        iconSize = 24,
                        iconPosition = "LEFT",    
                    },
                    Spark = {
                        showSpark = true,
                        sparkWidth = 10,
                        sparkHeight = 30,
                        sparkTexture = "Interface\\Buttons\\WHITE8X8",
                        sparkColor = {1, 1, 1, 1},
                    },
                    text = {
                        showText = true,
                        textJustify = "LEFT",
                        timeJustify = "RIGHT",
                        showTime = true,
                        timeFormat = "%.1f",
                        textsize = 12,
                        timesize = 12,
                        textColor = {1, 1, 1, 1},
                        timeColor = {1, 1, 1, 1},
                    }, 
                    position = {
                        anchorParent = "MilaUI_Boss",
                        anchorTo = "BOTTOM",
                        anchorFrom = "TOP", 
                        xOffset = 0,
                        yOffset = -20
                    }
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
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                    ShowStealableBuffs = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
                },
                Debuffs = {
                    Enabled             = false,
                    Size                = 42,
                    Spacing             = 1,
                    Num                 = 1,
                    AnchorFrom          = "RIGHT",
                    AnchorTo            = "LEFT",
                    AnchorFrame         = "MilaUI_Boss",
                    SmartAnchoring      = false,
                    XOffset             = -1,
                    YOffset             = 0,
                    GrowthX             = "LEFT",
                    GrowthY             = "UP",
                    Count               = {
                        FontSize        = 12,
                        Font            = "Friz Quadrata TT",
                        FontFlags       = "OUTLINE",
                        XOffset         = 0,
                        YOffset         = 3,
                        AnchorFrom     = "BOTTOMRIGHT",
                        AnchorTo       = "BOTTOMRIGHT",
                        Colour        = {1, 1, 1, 1},
                    },
                    OnlyShowPlayer     = true,
                    OnlyShowBoss     = true,
                    Blacklist = false,
                    appliedBlacklist = {},
                    Whitelist = false,
                    appliedWhitelist = {},
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
        castBars = {
            player = {
                enabled = true,
                size = {
                    width = 400,
                    height = 30,
                    scale = 1.0
                },
                position = {
                    anchorPoint = "CENTER",
                    anchorTo = "CENTER", 
                    xOffset = 0,
                    yOffset = -200,
                    anchorFrame = "UIParent"
                },
                display = {
                    icon = {
                        show = true,
                        size = 24,
                        xOffset = 4,
                        yOffset = 0,
                        anchorTo = "LEFT",
                        anchorFrom = "LEFT",
                    },
                    text = {
                        show = true,
                        size = 12,
                        xOffset = 0,
                        yOffset = 2,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "TOP",
                        anchorFrom = "BOTTOM",
                    },
                    timer = {
                        show = true,
                        size = 10,
                        xOffset = -5,
                        yOffset = 0,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "RIGHT",
                        anchorFrom = "RIGHT",
                    }
                },
                textures = {
                    main = "g1",
                    cast = "HPYellowHD",
                    channel = "shield-fill",
                    uninterruptible = "ArmorCastBar",
                    interrupt = "HPredHD2",
                    background = "MirroredFrameSingleBG",
                    spark = "Interface\\Buttons\\WHITE8X8"
                },
                colors = {
                    cast = {0, 1, 1, 1},
                    channel = {0.5, 0.3, 0.9, 1},
                    uninterruptible = {0.8, 0.8, 0.8, 1},
                    interrupt = {1, 0.2, 0.2, 1},
                    completion = {0.2, 1.0, 1.0, 1.0}
                },
                flashColors = {
                    cast = {0.2, 0.8, 0.2, 1.0},
                    channel = {1.0, 0.4, 1.0, 0.9},
                    uninterruptible = {0.8, 0.8, 0.8, 0.9},
                    interrupt = {1, 1, 1, 1}
                }
            },
            target = {
                enabled = false,
                size = {
                    width = 200,
                    height = 20,
                    scale = 1.0
                },
                position = {
                    anchorPoint = "BOTTOM",
                    anchorTo = "TOP",
                    xOffset = 0,
                    yOffset = -20,
                    anchorFrame = "MilaUI_Target"
                },
                display = {
                    icon = {
                        show = true,
                        size = 24,
                        xOffset = 4,
                        yOffset = 0,
                        anchorTo = "LEFT",
                        anchorFrom = "LEFT",
                    },
                    text = {
                        show = true,
                        size = 12,
                        xOffset = 0,
                        yOffset = 2,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "TOP",
                        anchorFrom = "BOTTOM",
                    },
                    timer = {
                        show = true,
                        size = 10,
                        xOffset = -5,
                        yOffset = 0,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "RIGHT",
                        anchorFrom = "RIGHT",
                    }
                },
                textures = {
                    main = "g1",
                    cast = "HPYellowHD",
                    channel = "shield-fill",
                    uninterruptible = "ArmorCastBar",
                    interrupt = "HPredHD2",
                    background = "MirroredFrameSingleBG",
                    spark = "Interface\\Buttons\\WHITE8X8"
                },
                colors = {
                    cast = {0, 1, 1, 1},
                    channel = {0.5, 0.3, 0.9, 1},
                    uninterruptible = {0.8, 0.8, 0.8, 1},
                    interrupt = {1, 0.2, 0.2, 1},
                    completion = {0.2, 1.0, 1.0, 1.0}
                },
                flashColors = {
                    cast = {0.2, 0.8, 0.2, 1.0},
                    channel = {1.0, 0.4, 1.0, 0.9},
                    uninterruptible = {0.8, 0.8, 0.8, 0.9},
                    interrupt = {1, 1, 1, 1}
                }
            },
            focus = {
                enabled = false,
                size = {
                    width = 200,
                    height = 20,
                    scale = 1.0
                },
                position = {
                    anchorPoint = "BOTTOM",
                    anchorTo = "TOP",
                    xOffset = 0,
                    yOffset = -20,
                    anchorFrame = "MilaUI_Focus"
                },
                display = {
                    icon = {
                        show = true,
                        size = 24,
                        xOffset = 4,
                        yOffset = 0,
                        anchorTo = "LEFT",
                        anchorFrom = "LEFT",
                    },
                    text = {
                        show = true,
                        size = 12,
                        xOffset = 0,
                        yOffset = 2,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "TOP",
                        anchorFrom = "BOTTOM",
                    },
                    timer = {
                        show = true,
                        size = 10,
                        xOffset = -5,
                        yOffset = 0,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "RIGHT",
                        anchorFrom = "RIGHT",
                    }
                },
                textures = {
                    main = "g1",
                    cast = "HPYellowHD",
                    channel = "shield-fill",
                    uninterruptible = "ArmorCastBar",
                    interrupt = "HPredHD2",
                    background = "MirroredFrameSingleBG",
                    spark = "Interface\\Buttons\\WHITE8X8"
                },
                colors = {
                    cast = {0, 1, 1, 1},
                    channel = {0.5, 0.3, 0.9, 1},
                    uninterruptible = {0.8, 0.8, 0.8, 1},
                    interrupt = {1, 0.2, 0.2, 1},
                    completion = {0.2, 1.0, 1.0, 1.0}
                },
                flashColors = {
                    cast = {0.2, 0.8, 0.2, 1.0},
                    channel = {1.0, 0.4, 1.0, 0.9},
                    uninterruptible = {0.8, 0.8, 0.8, 0.9},
                    interrupt = {1, 1, 1, 1}
                }
            },
            boss = {
                enabled = false,
                size = {
                    width = 200,
                    height = 20,
                    scale = 1.0
                },
                position = {
                    anchorPoint = "BOTTOM",
                    anchorTo = "TOP",
                    xOffset = 0,
                    yOffset = -20,
                    anchorFrame = "MilaUI_Boss"
                },
                display = {
                    icon = {
                        show = true,
                        size = 24,
                        xOffset = 4,
                        yOffset = 0,
                        anchorTo = "LEFT",
                        anchorFrom = "LEFT",
                    },
                    text = {
                        show = true,
                        size = 12,
                        xOffset = 0,
                        yOffset = 2,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "TOP",
                        anchorFrom = "BOTTOM",
                    },
                    timer = {
                        show = true,
                        size = 10,
                        xOffset = -5,
                        yOffset = 0,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "RIGHT",
                        anchorFrom = "RIGHT",
                    }
                },
                textures = {
                    main = "g1",
                    cast = "HPYellowHD",
                    channel = "shield-fill",
                    uninterruptible = "ArmorCastBar",
                    interrupt = "HPredHD2",
                    background = "MirroredFrameSingleBG",
                    spark = "Interface\\Buttons\\WHITE8X8"
                },
                colors = {
                    cast = {0, 1, 1, 1},
                    channel = {0.5, 0.3, 0.9, 1},
                    uninterruptible = {0.8, 0.8, 0.8, 1},
                    interrupt = {1, 0.2, 0.2, 1},
                    completion = {0.2, 1.0, 1.0, 1.0}
                },
                flashColors = {
                    cast = {0.2, 0.8, 0.2, 1.0},
                    channel = {1.0, 0.4, 1.0, 0.9},
                    uninterruptible = {0.8, 0.8, 0.8, 0.9},
                    interrupt = {1, 1, 1, 1}
                }
            },
            pet = {
                enabled = false,
                size = {
                    width = 200,
                    height = 20,
                    scale = 1.0
                },
                position = {
                    anchorPoint = "BOTTOM",
                    anchorTo = "TOP",
                    xOffset = 0,
                    yOffset = -20,
                    anchorFrame = "MilaUI_Pet"
                },
                display = {
                    icon = {
                        show = true,
                        size = 24,
                        xOffset = 4,
                        yOffset = 0,
                        anchorTo = "LEFT",
                        anchorFrom = "LEFT",
                    },
                    text = {
                        show = true,
                        size = 12,
                        xOffset = 0,
                        yOffset = 2,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "TOP",
                        anchorFrom = "BOTTOM",
                    },
                    timer = {
                        show = true,
                        size = 10,
                        xOffset = -5,
                        yOffset = 0,
                        font = "Expressway",
                        fontFlags = "OUTLINE",
                        fontColor = {1, 1, 1, 1},
                        anchorTo = "RIGHT",
                        anchorFrom = "RIGHT",
                    }
                },
                textures = {
                    main = "g1",
                    cast = "HPYellowHD",
                    channel = "shield-fill",
                    uninterruptible = "ArmorCastBar",
                    interrupt = "HPredHD2",
                    background = "MirroredFrameSingleBG",
                    spark = "Interface\\Buttons\\WHITE8X8"
                },
                colors = {
                    cast = {0, 1, 1, 1},
                    channel = {0.5, 0.3, 0.9, 1},
                    uninterruptible = {0.8, 0.8, 0.8, 1},
                    interrupt = {1, 0.2, 0.2, 1},
                    completion = {0.2, 1.0, 1.0, 1.0}
                },
                flashColors = {
                    cast = {0.2, 0.8, 0.2, 1.0},
                    channel = {1.0, 0.4, 1.0, 0.9},
                    uninterruptible = {0.8, 0.8, 0.8, 0.9},
                    interrupt = {1, 1, 1, 1}
                }
            },
             TARGET_CASTBAR_SHOW_ICON = true,
             TARGET_CASTBAR_SHOW_TEXT = true,
             TARGET_CASTBAR_SHOW_TIMER = true,
             TARGET_CASTBAR_WIDTH = 150,
             TARGET_CASTBAR_HEIGHT = 18,
             TARGET_CASTBAR_X_OFFSET = 15,
             TARGET_CASTBAR_Y_OFFSET = -55,
           
              FOCUS_CASTBAR_SHOW_ICON = true,
              FOCUS_CASTBAR_SHOW_TEXT = true,
              FOCUS_CASTBAR_SHOW_TIMER = true,
              FOCUS_CASTBAR_WIDTH = 150,
              FOCUS_CASTBAR_HEIGHT = 18,
              FOCUS_CASTBAR_X_OFFSET = 15,
              FOCUS_CASTBAR_Y_OFFSET = -55,
           
           
           -- Player text settings
           PLAYER_SHOW_HEALTH_TEXT = true,
           PLAYER_HEALTH_TEXT_SIZE = 11,
           PLAYER_HEALTH_TEXT_SHOW_PERCENT = true,
           PLAYER_HEALTH_TEXT_SPLIT = true, -- Set to true for left/right split
           
           PLAYER_SHOW_POWER_TEXT = true,
           PLAYER_POWER_TEXT_SIZE = 9,
           PLAYER_POWER_TEXT_SHOW_PERCENT = false,
           
           PLAYER_SHOW_NAME_TEXT = false, -- Usually don't show player name
           PLAYER_NAME_TEXT_SIZE = 12,
           PLAYER_NAME_TEXT_MAX_LENGTH = 20,
           
           PLAYER_SHOW_LEVEL_TEXT = false, -- Usually don't show player level
           PLAYER_LEVEL_TEXT_SIZE = 10,
           
           -- Target text settings
           TARGET_SHOW_HEALTH_TEXT = true,
           TARGET_HEALTH_TEXT_SIZE = 11,
           TARGET_HEALTH_TEXT_SHOW_PERCENT = true,
           TARGET_HEALTH_TEXT_SPLIT = true, -- Enable split positioning for target
           
           TARGET_SHOW_POWER_TEXT = true,
           TARGET_POWER_TEXT_SIZE = 9,
           TARGET_POWER_TEXT_SHOW_PERCENT = false,
           
           TARGET_SHOW_NAME_TEXT = true,
           TARGET_NAME_TEXT_SIZE = 12,
           TARGET_NAME_TEXT_MAX_LENGTH = 20,
           
           TARGET_SHOW_LEVEL_TEXT = true,
           TARGET_LEVEL_TEXT_SIZE = 10,
           
           -- Focus text settings
           FOCUS_SHOW_HEALTH_TEXT = true,
           FOCUS_HEALTH_TEXT_SIZE = 11,
           FOCUS_HEALTH_TEXT_SHOW_PERCENT = true,
           FOCUS_HEALTH_TEXT_SPLIT = false, -- Keep focus centered
           
           FOCUS_SHOW_POWER_TEXT = true,
           FOCUS_POWER_TEXT_SIZE = 9,
           FOCUS_POWER_TEXT_SHOW_PERCENT = false,
           
           FOCUS_SHOW_NAME_TEXT = true,
           FOCUS_NAME_TEXT_SIZE = 12,
           FOCUS_NAME_TEXT_MAX_LENGTH = 20,
           
           FOCUS_SHOW_LEVEL_TEXT = true,
           FOCUS_LEVEL_TEXT_SIZE = 10,
           bars = {
                       -- Player Cast Bar
                       PLAYER_CASTBAR_ENABLED = true,
                       PLAYER_CASTBAR_WIDTH = 125,
                       PLAYER_CASTBAR_HEIGHT = 18,
                       PLAYER_CASTBAR_SCALE = 1.0,
                       PLAYER_CASTBAR_X_OFFSET = 0,
                       PLAYER_CASTBAR_Y_OFFSET = -20,
                       PLAYER_CASTBAR_SHOW_ICON = true,
                       PLAYER_CASTBAR_SHOW_TEXT = true,
                       PLAYER_CASTBAR_SHOW_TIMER = true,
                       PLAYER_CASTBAR_MASK_TEXTURE = "Interface\\AddOns\\rnxmUI\\Textures\\UIUnitFramePlayerHealthMask2x.tga",
                       
                       -- Cast Type Textures
                       PLAYER_CAST_TEXTURE = "g1",
                       PLAYER_CHANNEL_TEXTURE = "g1",
                       PLAYER_UNINTERRUPTIBLE_TEXTURE = "g1",
                       PLAYER_INTERRUPT_TEXTURE = "g1",
                       
                       -- Cast Type Colors (RGBA)
                       PLAYER_CAST_COLOR = {0, 1, 1, 1},
                       PLAYER_CHANNEL_COLOR = {0.5, 0.3, 0.9, 1},
                       PLAYER_UNINTERRUPTIBLE_COLOR = {0.8, 0.8, 0.8, 1},
                       PLAYER_INTERRUPT_COLOR = {1, 0.2, 0.2, 1},
                       
                       -- Copy same structure for TARGET_ and FOCUS_ with appropriate prefixes
                       -- ... rest of cast bar defaults
            },     
        }
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
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    local white = MilaUI.DB.global.Colors.white
    
    SLASH_MilaUI1 = "/MilaUI"
    SLASH_MilaUI2 = "/mui"
    SLASH_MilaUI3 = "/Mila"
    SlashCmdList["MilaUI"] = function(msg)
        if msg == "" then
            MilaUI_OpenGUIMain()
        elseif msg == "reset" then
            MilaUI:ResetDefaultSettings()
        elseif msg == "help" then
            print(pink .. "♥MILA UI ♥:  " .. lavender .. " Slash Commands.")
            print(pink .. "/MilaUI or /MUI:" .. lavender .. " Opens the GUI")
            print(pink .. "/MilaUI reset or /MUI reset:" .. lavender .. " Resets To Default")
            print(pink .. "/MilaUI debug or /MUI debug:" .. lavender .. " Toggle debug mode")
        elseif msg == "debug" then
            MilaUI.DB.global.DebugMode = not MilaUI.DB.global.DebugMode
            print(pink .. "MilaUI Debug Mode: " .. lavender .. (MilaUI.DB.global.DebugMode and "Enabled" or "Disabled"))
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
    
    -- Register cursor slash commands
    if MilaUIAddon:GetModule("CursorMod", true) then
        SLASH_MUILACURSOR1 = "/mui cursor"
        SLASH_MUILACURSOR2 = "/mila cursor"
        SlashCmdList["MILAUICURSOR"] = function(msg)
            local cmd = string.lower(msg or "")
            
            if cmd == "toggle" then
                MilaUIAddon:ToggleModule("CursorMod")
                print("MilaUI CursorMod:", MilaUIAddon:GetModule("CursorMod"):GetStatus().enabled and "Enabled" or "Disabled")
            elseif cmd == "status" then
                local status = MilaUIAddon:GetModule("CursorMod"):GetStatus()
                print("MilaUI CursorMod Status:")
                for k, v in pairs(status) do
                    if type(v) == "table" then
                        print(" ", k .. ":", table.concat(v, ", "))
                    else
                        print(" ", k .. ":", tostring(v))
                    end
                end
            elseif cmd == "reload" then
                MilaUIAddon:GetModule("CursorMod"):UpdateCursorSettings()
                print("MilaUI CursorMod: Settings reloaded")
            else
                print("MilaUI CursorMod Commands:")
                print("  /mui cursor toggle - Toggle module on/off")
                print("  /mui cursor status - Show current settings")
                print("  /mui cursor reload - Reload settings")
            end
        end
    end
end

function MilaUIAddon:OnEnable()
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    local white = MilaUI.DB.global.Colors.white
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
