local _, MilaUI = ...

-- Initialize defaults table if it doesn't exist
MilaUI.Defaults = MilaUI.Defaults or {}

-- Global defaults
MilaUI.Defaults.global = {
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
}

-- CursorMod defaults
MilaUI.Defaults.CursorMod = {
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
}

-- Test mode flag
MilaUI.Defaults.TestMode = false