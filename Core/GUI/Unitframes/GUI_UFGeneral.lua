local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0") -- Direct reference to AceGUI
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")

-- Ensure GUI is also available through MilaUI.GUI for consistency
MilaUI.GUI = GUI


-- Placeholder for where unit frame settings will be drawn for the selected unit
local unitSettingsContainer = nil

function MilaUI:DrawUnitframesGeneralTab(parent)
    parent:ReleaseChildren()
    local General = MilaUI.DB.profile.Unitframes.General
    local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
    local LSMTextures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
    local white = MilaUI.DB.global.Colors.white
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    -- Create a single container for all content to ensure proper spacing
    local mainContainer = GUI:Create("SimpleGroup")
    mainContainer:SetLayout("Flow")
    mainContainer:SetFullWidth(true)
    mainContainer:SetFullHeight(true)
    parent:AddChild(mainContainer)

    -- Font Options
    MilaUI:CreateLargeHeading("Font Options", mainContainer)
    local FontOptions = GUI:Create("InlineGroup")
    FontOptions:SetLayout("Flow")
    FontOptions:SetFullWidth(true)
    mainContainer:AddChild(FontOptions)
    
    local Font = GUI:Create("LSM30_Font")
    Font:SetLabel(lavender .. "Font")
    Font:SetList(LSM:HashTable(LSM.MediaType.FONT))
    Font:SetValue(General.Font)
    -- NOTE: General.Font now stores the font key (e.g., "Friz Quadrata TT"). Always use LSM:Fetch("font", General.Font) when applying fonts!
    Font:SetCallback("OnValueChanged", function(widget, event, value)
        General.Font = value
        MilaUI:UpdateFrames()
        -- Update the displayed text to show the font name (value is already the font name/key)
        if widget and widget.SetText then
            widget:SetText(value)
        end
    end)
    Font:SetRelativeWidth(0.3)
    FontOptions:AddChild(Font)
    
    local FontFlag = GUI:Create("Dropdown")
    FontFlag:SetLabel(lavender .. "Font Flag")
    FontFlag:SetList({
        ["NONE"] = "None",
        ["OUTLINE"] = "Outline",
        ["THICKOUTLINE"] = "Thick Outline",
        ["MONOCHROME"] = "Monochrome",
        ["OUTLINE, MONOCHROME"] = "Outline, Monochrome",
        ["THICKOUTLINE, MONOCHROME"] = "Thick Outline, Monochrome",
    })
    FontFlag:SetValue(General.FontFlag)
    FontFlag:SetCallback("OnValueChanged", function(widget, event, value) 
        General.FontFlag = value 
        MilaUI:UpdateFrames() 
    end)
    FontFlag:SetRelativeWidth(0.2)
    FontOptions:AddChild(FontFlag)

    -- Mouseover Highlight Options
    MilaUI:CreateLargeHeading("Mouseover Highlight Options", mainContainer)
    local MouseoverHighlight = MilaUI.DB.profile.Unitframes.General.MouseoverHighlight or {Enabled=false, Colour={1,1,1,1}, Style="BORDER"}
    local MouseoverHighlightOptions = GUI:Create("InlineGroup")
    MouseoverHighlightOptions:SetLayout("Flow")
    MouseoverHighlightOptions:SetFullWidth(true)
    mainContainer:AddChild(MouseoverHighlightOptions)
    
    -- Enable checkbox
    MilaUI:CreateCheckBox("Enable Mouseover Highlight", 
        MouseoverHighlight and MouseoverHighlight.Enabled,
        function(widget, event, value) 
            MouseoverHighlight.Enabled = value 
            MilaUI:CreateReloadPrompt() 
        end,
        0.33, MouseoverHighlightOptions)
    
    -- Color picker
    MilaUI:CreateColorPicker("Color", 
        (MouseoverHighlight and MouseoverHighlight.Colour) or {1,1,1,1},
        function(widget, event, r, g, b, a) 
            MouseoverHighlight.Colour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end,
        0.33, true, MouseoverHighlightOptions)
    
    -- Style dropdown
    MilaUI:CreateDropdown("Style", 
        {
            ["BORDER"] = "Border",
            ["HIGHLIGHT"] = "Highlight",
        },
        MouseoverHighlight and MouseoverHighlight.Style,
        function(widget, event, value) 
            MouseoverHighlight.Style = value 
            MilaUI:UpdateFrames() 
        end,
        0.33, MouseoverHighlightOptions)
    
    -- Health Colour Options
    MilaUI:CreateLargeHeading("Health Colour Options", mainContainer)
    local ColouringOptionsContainer = GUI:Create("InlineGroup")
    ColouringOptionsContainer:SetLayout("Flow")
    ColouringOptionsContainer:SetFullWidth(true)
    mainContainer:AddChild(ColouringOptionsContainer)

    -- Health Colour Options section
    local PlaterColour = GUI:Create("CheckBox")
    PlaterColour:SetLabel("Use Plater Colour")
    PlaterColour:SetValue(General.ColourByPlater)
    PlaterColour:SetCallback("OnValueChanged", function(widget, event, value) 
        General.ColourByPlater = value 
        MilaUI:UpdateFrames()
        if value then 
            ForegroundColour:SetDisabled(true) 
            ColourByClass:SetDisabled(true)
        else 
            ForegroundColour:SetDisabled(false) 
            ColourByClass:SetDisabled(false)
        end 
    end)
    PlaterColour:SetRelativeWidth(0.25)
    ColouringOptionsContainer:AddChild(PlaterColour)
    
    local ColourOptions = GUI:Create("InlineGroup")
    ColourOptions:SetLayout("Flow")
    ColourOptions:SetRelativeWidth(0.75)
    ColouringOptionsContainer:AddChild(ColourOptions)
    -- Foreground Colour picker
    local ForegroundColour = GUI:Create("ColorPicker")
    ForegroundColour:SetLabel("Foreground Colour")
    local R, G, B, A = unpack(General.ForegroundColour or {1,1,1,1})
    ForegroundColour:SetColor(R, G, B, A)
    ForegroundColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) 
            General.ForegroundColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end)
    ForegroundColour:SetRelativeWidth(0.5)
    ColourOptions:AddChild(ForegroundColour)
    if General.ColourByPlater then
        ForegroundColour:SetDisabled(true)
    else
        ForegroundColour:SetDisabled(false)
    end

    local ColourByClass = GUI:Create("CheckBox")
    ColourByClass:SetLabel("Use Class / Reaction Colour")
    ColourByClass:SetValue(General.ColourByClass)
    ColourByClass:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourByClass = value 
            MilaUI:UpdateFrames() 
        end)
    ColourByClass:SetRelativeWidth(0.5)
    ColourOptions:AddChild(ColourByClass)
    if General.ColourByPlater then
        ColourByClass:SetDisabled(true)
    else
        ColourByClass:SetDisabled(false)
    end
    
    local ColourIfDisconnected = GUI:Create("CheckBox")
    ColourIfDisconnected:SetLabel("Use Disconnected Colour")
    ColourIfDisconnected:SetValue(General.ColourIfDisconnected)
    ColourIfDisconnected:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourIfDisconnected = value 
            MilaUI:UpdateFrames() 
        end)
    ColourIfDisconnected:SetRelativeWidth(0.5)
    ColourOptions:AddChild(ColourIfDisconnected)
    
    local ColourIfTapped = GUI:Create("CheckBox")
    ColourIfTapped:SetLabel("Use Tapped Colour")
    ColourIfTapped:SetValue(General.ColourIfTapped)
    ColourIfTapped:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourIfTapped = value 
            MilaUI:UpdateFrames() 
        end)
    ColourIfTapped:SetRelativeWidth(0.5)
    ColourOptions:AddChild(ColourIfTapped)
    
    MilaUI:CreateVerticalSpacer(15, mainContainer)
    
    -- Background Colour Options
    MilaUI:CreateLargeHeading("Background Colour Options", mainContainer)
    local BackgroundColourOptions = GUI:Create("InlineGroup")
    BackgroundColourOptions:SetLayout("Flow")
    BackgroundColourOptions:SetFullWidth(true)
    mainContainer:AddChild(BackgroundColourOptions)
    
    -- Background Colour picker
    local BackgroundColour = GUI:Create("ColorPicker")
    BackgroundColour:SetLabel("Background Colour")
    local R, G, B, A = unpack(General.BackgroundColour or {0,0,0,1})
    BackgroundColour:SetColor(R, G, B, A)
    BackgroundColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) 
            General.BackgroundColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end)
    BackgroundColour:SetRelativeWidth(1)
    BackgroundColourOptions:AddChild(BackgroundColour)
    
    -- Background multiplier slider
    local BackgroundColourMultiplier = GUI:Create("Slider")
    BackgroundColourMultiplier:SetLabel("Multiplier")
    BackgroundColourMultiplier:SetSliderValues(0, 1, 0.01)
    BackgroundColourMultiplier:SetValue(General.BackgroundMultiplier or 1)
    BackgroundColourMultiplier:SetCallback("OnMouseUp", function(widget, event, value) 
            General.BackgroundMultiplier = value 
            MilaUI:UpdateFrames() 
        end)
    BackgroundColourMultiplier:SetRelativeWidth(0.25)
    BackgroundColourOptions:AddChild(BackgroundColourMultiplier)
    
    -- Background colour options
    local BackgroundColourByForeground = GUI:Create("CheckBox")
    BackgroundColourByForeground:SetLabel("Colour By Foreground")
    BackgroundColourByForeground:SetValue(General.ColourBackgroundByForeground)
    BackgroundColourByForeground:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourBackgroundByForeground = value 
            MilaUI:UpdateFrames() 
            if value then 
                BackgroundColourMultiplier:SetDisabled(false) 
            else 
                BackgroundColourMultiplier:SetDisabled(true) 
            end 
        end)
    BackgroundColourByForeground:SetRelativeWidth(0.25)
    BackgroundColourOptions:AddChild(BackgroundColourByForeground)
    -- Initialize multiplier disabled state
    if General.ColourBackgroundByForeground then
        BackgroundColourMultiplier:SetDisabled(false)
    else
        BackgroundColourMultiplier:SetDisabled(true)
    end
    
    MilaUI:CreateCheckBox("Colour If Dead", 
        General.ColourBackgroundIfDead,
        function(widget, event, value) 
            General.ColourBackgroundIfDead = value 
            MilaUI:UpdateFrames() 
        end,
        0.25, BackgroundColourOptions)
    
    MilaUI:CreateCheckBox("Colour By Class / Reaction", 
        General.ColourBackgroundByClass,
        function(widget, event, value) 
            General.ColourBackgroundByClass = value 
            MilaUI:UpdateFrames() 
        end,
        0.25, BackgroundColourOptions)
    
    -- Border Colour Options
    MilaUI:CreateLargeHeading("Border Colour Options", mainContainer)
    local BorderColourOptions = GUI:Create("InlineGroup")
    BorderColourOptions:SetLayout("Flow")
    BorderColourOptions:SetFullWidth(true)
    mainContainer:AddChild(BorderColourOptions)
    
    -- Border Colour picker
    MilaUI:CreateColorPicker("Border Colour", 
        General.BorderColour or {1,1,1,1},
        function(widget, _, r, g, b, a) 
            General.BorderColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end,
        0.33, true, BorderColourOptions)
    
    -- Custom Colours
    MilaUI:CreateLargeHeading("Custom Colours", mainContainer)
    local CustomColours = GUI:Create("InlineGroup")
    CustomColours:SetLayout("Flow")
    CustomColours:SetFullWidth(true)
    mainContainer:AddChild(CustomColours)
    
    local ResetCustomColoursButton = GUI:Create("Button")
    ResetCustomColoursButton:SetText("Reset Custom Colours")
    ResetCustomColoursButton:SetCallback("OnClick", function(widget, event, value) 
        MilaUI:ResetColours() 
    end)
    ResetCustomColoursButton:SetRelativeWidth(1)
    CustomColours:AddChild(ResetCustomColoursButton)
    
    -- Power Colours
    local PowerColours = GUI:Create("InlineGroup")
    PowerColours:SetTitle(pink .. "Power Colours")
    PowerColours:SetLayout("Flow")
    PowerColours:SetFullWidth(true)
    CustomColours:AddChild(PowerColours)

    local PowerNames = {
        [0] = "Mana", [1] = "Rage", [2] = "Focus", [3] = "Energy", [6] = "Rune", [8] = "Runic Power", [11] = "Maelstrom", [13] = "Insanity", [17] = "Fury", [18] = "Pain"
    }
    local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
    for _, powerType in ipairs(PowerOrder) do
        local powerColour = (General.CustomColours and General.CustomColours.Power and General.CustomColours.Power[powerType]) or {1,1,1}
        local PowerColour = GUI:Create("ColorPicker")
        PowerColour:SetLabel(PowerNames[powerType] or tostring(powerType))
        local R, G, B = unpack(powerColour)
        PowerColour:SetColor(R, G, B)
        PowerColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
            if not General.CustomColours then General.CustomColours = {} end
            if not General.CustomColours.Power then General.CustomColours.Power = {} end
            General.CustomColours.Power[powerType] = {r, g, b}
            MilaUI:UpdateFrames()
        end)
        PowerColour:SetHasAlpha(false)
        PowerColour:SetRelativeWidth(0.25)
        PowerColours:AddChild(PowerColour)
    end

    -- Reaction Colours
    local ReactionColours = GUI:Create("InlineGroup")
    ReactionColours:SetTitle(pink .. "Reaction Colours")
    ReactionColours:SetLayout("Flow")
    ReactionColours:SetFullWidth(true)
    CustomColours:AddChild(ReactionColours)

    local ReactionNames = {
        [1] = "Hated", [2] = "Hostile", [3] = "Unfriendly", [4] = "Neutral", [5] = "Friendly", [6] = "Honored", [7] = "Revered", [8] = "Exalted"
    }
    for reactionType, reactionColour in pairs((General.CustomColours and General.CustomColours.Reaction) or {}) do
        local ReactionColour = GUI:Create("ColorPicker")
        ReactionColour:SetLabel(ReactionNames[reactionType] or tostring(reactionType))
        local R, G, B = unpack(reactionColour)
        ReactionColour:SetColor(R, G, B)
        ReactionColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
            if not General.CustomColours then General.CustomColours = {} end
            if not General.CustomColours.Reaction then General.CustomColours.Reaction = {} end
            General.CustomColours.Reaction[reactionType] = {r, g, b}
            MilaUI:UpdateFrames()
        end)
        ReactionColour:SetHasAlpha(false)
        ReactionColour:SetRelativeWidth(0.25)
        ReactionColours:AddChild(ReactionColour)
    end

    -- Status Colours
    local StatusColours = GUI:Create("InlineGroup")
    StatusColours:SetTitle(pink .. "Status Colours")
    StatusColours:SetLayout("Flow")
    StatusColours:SetFullWidth(true)
    CustomColours:AddChild(StatusColours)

    local StatusNames = {
        [1] = "Dead",
        [2] = "Tapped", 
        [3] = "Offline"
    }
    for statusType, statusColour in pairs((General.CustomColours and General.CustomColours.Status) or {}) do
        local StatusColour = GUI:Create("ColorPicker")
        StatusColour:SetLabel(StatusNames[statusType] or tostring(statusType))
        local R, G, B = unpack(statusColour)
        StatusColour:SetColor(R, G, B)
        StatusColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
            if not General.CustomColours then General.CustomColours = {} end
            if not General.CustomColours.Status then General.CustomColours.Status = {} end
            General.CustomColours.Status[statusType] = {r, g, b}
            MilaUI:UpdateFrames()
        end)
        StatusColour:SetHasAlpha(false)
        StatusColour:SetRelativeWidth(0.33)
        StatusColours:AddChild(StatusColour)
    end
    -- Recalculate the scroll frame layout once all widgets are added
    if parent and parent.DoLayout then
        parent:DoLayout()
    end
end
