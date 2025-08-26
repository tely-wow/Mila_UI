local _, MilaUI = ...

-- Initialize defaults table if it doesn't exist
MilaUI.Defaults = MilaUI.Defaults or {}

-- Castbars defaults
MilaUI.Defaults.Castbars = {
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
        strata = "MEDIUM",      
        strataLevel = 1,        
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
        strata = "MEDIUM",      
        strataLevel = 1,        
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
        strata = "MEDIUM",      
        strataLevel = 1,        
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
        strata = "MEDIUM",      
        strataLevel = 1,        
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
        strata = "MEDIUM",      
        strataLevel = 1,        
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
}