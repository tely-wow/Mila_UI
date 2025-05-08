local _, MilaUI = ...
local MilaUIAddon = LibStub("AceAddon-3.0"):NewAddon("MilaUI")
MilaUIAddon_GUI = MilaUIAddon_GUI or {}

MilaUIAddon.Defaults = {
    global = {
        UIScaleEnabled = true,
        UIScale = 0.5333333333333,
        TagUpdateInterval = 0.5,
        FramesLocked = true,
    },
    profile = {
        TestMode = false,
        General = {
            Font                              = "Fonts\\FRIZQT__.TTF",
            FontFlag                          = "OUTLINE",
            FontShadowColour                  = {0, 0, 0, 1},
            FontShadowXOffset                 = 0,
            FontShadowYOffset                 = 0,
            ForegroundTexture                 = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
            BackgroundTexture                 = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\solid.tga",
            BorderTexture                     = "Interface\\Buttons\\WHITE8X8",
            BackgroundColour                  = {26 / 255, 26 / 255, 26 / 255, 1},
            ForegroundColour                  = {26 / 255, 26 / 255, 26 / 255, 1},
            BorderColour                      = {0 / 255, 0 / 255, 0 / 255, 1},
            BorderSize                        = 1,
            BorderInset                       = 1,
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
                Width               = 272,
                Height              = 42,
                XPosition           = -425.1,
                YPosition           = -275.1,
                AnchorFrom          = "CENTER",
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
                Direction = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram.tga",
                CustomBorder = {
                    Enabled = true,
                    BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_thick.tga",
                },
                HealthPrediction = {
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
                Direction               = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\power_para.tga",
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
                AnchorFrom          = "BOTTOMLEFT",
                AnchorTo            = "TOPLEFT",
                XOffset             = 0,
                YOffset             = 1,
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
                Num                 = 7,
                AnchorFrom          = "BOTTOMLEFT",
                AnchorTo            = "TOPLEFT",
                XOffset             = 0,
                YOffset             = 1,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
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
                XOffset             = 3,
                YOffset             = 0,
                AnchorFrom          = "LEFT",
                AnchorTo            = "TOPLEFT",
            },
            CombatIndicator = {
                Enabled             = true,
                Size                = 24,
                XOffset             = 0,
                YOffset             = 0,
                AnchorFrom          = "CENTER",
                AnchorTo            = "CENTER",
            },
            LeaderIndicator = {
                Enabled             = true,
                Size                = 16,
                XOffset             = 3,
                YOffset             = 0,
                AnchorFrom          = "LEFT",
                AnchorTo            = "TOPLEFT",
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
            },
        },
        Target = {
            Frame = {
                Enabled             = true,
                Width               = 272,
                Height              = 42,
                XPosition           = 425.1,
                YPosition           = -275.1,
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
                Direction = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram2.tga",
                CustomBorder = {
                    Enabled = true,
                    BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_thick_mirrored.tga",
                },
                HealthPrediction = {
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
                Direction               = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\power_para2.tga",
                Enabled                 = true,
                Height                  = 5,
                ColourByType            = true,
                ColourBackgroundByType  = true,
                BackgroundMultiplier    = 0.25,
                Colour                  = {0/255, 0/255, 1/255, 1},
                BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
                Smooth = false,
            },
            Buffs = {
                Enabled             = true,
                Size                = 38,
                Spacing             = 1,
                Num                 = 7,
                AnchorFrom          = "BOTTOMLEFT",
                AnchorTo            = "TOPLEFT",
                XOffset             = 0,
                YOffset             = 1,
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
                Num                 = 3,
                AnchorFrom          = "BOTTOMRIGHT",
                AnchorTo            = "TOPRIGHT",
                XOffset             = 0,
                YOffset             = 1,
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
            Texts = {
                First = {
                    AnchorTo        = "LEFT",
                    AnchorFrom      = "LEFT",
                    Colour         = {1, 1, 1, 1},
                    FontSize        = 12,
                    XOffset         = 3,
                    YOffset         = 0,
                    Tag             = "[Name:NamewithTargetTarget:LastNameOnly]",
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
            },
            Range = {
                Enable = true,
                OOR = 0.5,
                IR = 1.0
            },
        },
        TargetTarget = {
            Frame = {
                Enabled             = false,
                Width               = 120,
                Height              = 42,
                XPosition           = 1.1,
                YPosition           = 0,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
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
                Direction = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram2.tga",
                CustomBorder = {
                    Enabled = true,
                    BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_thick_mirrored.tga",
                },
                HealthPrediction = {
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
                Direction              = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\power_para2.tga",
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
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
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
            },
            Range = {
                Enable = false,
                OOR = 0.5,
                IR = 1.0
            }
        },
        Focus = {
            Frame = {
                Enabled             = true,
                Width               = 272,
                Height              = 36,
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
                Direction = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram2.tga",
                CustomBorder = {
                    Enabled = true,
                    BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_thick_mirrored.tga",
                },
                HealthPrediction = {
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
                Direction              = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\power_para2.tga",
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
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
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
                    Tag             = "[Health:PerHPwithAbsorbs]",
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
            },
            Range = {
                Enable = true,
                OOR = 0.5,
                IR = 1.0
            }
        },
        FocusTarget = {
            Frame = {
                Enabled             = false,
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
                Direction = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram2.tga",
                CustomBorder = {
                    Enabled = true,
                    BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_thick_mirrored.tga",
                },
                HealthPrediction = {
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
                Direction              = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\power_para2.tga",
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
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
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
            },
            Range = {
                Enable = true,
                OOR = 0.5,
                IR = 1.0
            }
        },
        Pet = {
            Frame = {
                Enabled             = true,
                Width               = 272,
                Height              = 10,
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
                Direction = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram.tga",
                CustomBorder = {
                    Enabled = true,
                    BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_thick.tga",
                },
                ColourByPlayerClass = false,
                HealthPrediction = {
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
                Direction              = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\power_para.tga",
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
            },
            Range = {
                Enable = false,
                OOR = 0.5,
                IR = 1.0
            }
        },
        Boss = {
            Frame = {
                Enabled             = true,
                Width               = 250,
                Height              = 42,
                XPosition           = 750.1,
                YPosition           = 0.1,
                Spacing             = 26.1,
                AnchorFrom          = "CENTER",
                AnchorTo            = "CENTER",
                AnchorParent        = "UIParent",
                GrowthY             = "DOWN",
            },
            Portrait = {
                Enabled         = true,
                Size            = 42,
                XOffset         = -1,
                YOffset         = 0,
                AnchorFrom      = "RIGHT",
                AnchorTo        = "LEFT",
            },
            Health = {
                Direction = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\Parallelogram2.tga",
                CustomBorder = {
                    Enabled = true,
                    BorderTexture = "Interface\\Addons\\Mila_UI\\Media\\Borders\\Custom\\border_thick_mirrored.tga",
                },
                HealthPrediction = {
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
                Direction              = "LR",
                Texture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                Mask = "Interface\\Addons\\Mila_UI\\Media\\Statusbars\\Masks\\power_para2.tga",
                Enabled                 = true,
                Height                  = 5,
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
            },
            Range = {
                Enable = true,
                OOR = 0.5,
                IR = 1.0
            },
        }
    }
}

function MilaUIAddon:OnInitialize()
    MilaUI.DB = LibStub("AceDB-3.0"):New("MilaUIDB", MilaUIAddon.Defaults)
    for k, v in pairs(MilaUIAddon.Defaults) do
        if MilaUI.DB.profile[k] == nil then
            MilaUI.DB.profile[k] = v
        end
    end
end

function MilaUIAddon:OnEnable()
    if MilaUI.DB.global.UIScaleEnabled then UIParent:SetScale(MilaUI.DB.global.UIScale) end
    if MilaUI.DB.profile.TestMode then MilaUI.DB.profile.TestMode = false end
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
    print(C_AddOns.GetAddOnMetadata("MilaUI", "Title") .. ": `|cFF8080FF/MilaUI|r` for in-game configuration.")
end