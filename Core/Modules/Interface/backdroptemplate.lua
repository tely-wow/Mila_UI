local _, MilaUI = ...
MilaUI.BackdropTemplates = {}

local constBackdropDropDown = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}
MilaUI.BackdropTemplates.DopwDown = constBackdropDropDown

local constBackdropFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
MilaUI.BackdropTemplates.Default = constBackdropFrame

local constBackdropFrameBorder = {
    bgFile = "",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
MilaUI.BackdropTemplates.OnlyBorder = constBackdropFrameBorder

local constBackdropFrameSmallerBorder = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 18,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
MilaUI.BackdropTemplates.DefaultWithSmallBorder = constBackdropFrameSmallerBorder

local constBackdropFrameStatusBar = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/StatusBar",
    --edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
MilaUI.BackdropTemplates.StatusBar = constBackdropFrameStatusBar

local constBackdropFrameColorBorder = {
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
    edgeSize = 1
}
MilaUI.BackdropTemplates.DefaultWithColorableBorder = constBackdropFrameColorBorder

local constBackdropFrameColorBorderNoBackground = {
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
    bgFile = "",
    edgeSize = 1
}
MilaUI.BackdropTemplates.ColorableBorderOnly = constBackdropFrameColorBorderNoBackground