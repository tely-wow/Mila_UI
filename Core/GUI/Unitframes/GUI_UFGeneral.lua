local _, MilaUI = ...
local L = MilaUI.L -- Assuming L is attached to MilaUI or accessible globally
local GUI = LibStub("AceGUI-3.0") -- Direct reference to AceGUI
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")

-- Ensure GUI is also available through MilaUI.GUI for consistency
MilaUI.GUI = GUI


local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"
-- Placeholder for where unit frame settings will be drawn for the selected unit
local unitSettingsContainer = nil

function MilaUI:DrawUnitframesGeneralTab(parent)
    parent:ReleaseChildren()
    local General = MilaUI.DB.profile.UnitframesGeneral or MilaUI.DB.profile.General -- fallback if not split
    local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
    local LSMTextures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
    
    -- Create a single container for all content to ensure proper spacing
    local mainContainer = GUI:Create("SimpleGroup")
    mainContainer:SetLayout("Flow")
    mainContainer:SetFullWidth(true)
    mainContainer:SetFullHeight(true)
    parent:AddChild(mainContainer)

    -- Mouseover Highlight Options
    local MouseoverHighlight = MilaUI.DB.profile.General.MouseoverHighlight or {Enabled=false, Colour={1,1,1,1}, Style="BORDER"}
    local MouseoverHighlightOptions = MilaUI:CreateInlineGroup("Mouseover Highlight Options", mainContainer)
    
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
    
    -- *** COLOUR OPTIONS (Moved from Colors tab) ***
    
    -- Create the main container for color options
    local ColouringOptionsContainer = MilaUI:CreateInlineGroup("Colour Options", mainContainer)
    
    -- Health Colour Options section
    local HealthColourOptions = MilaUI:CreateInlineGroup("Health Colour Options", ColouringOptionsContainer)
    
    -- Foreground Colour picker
    MilaUI:CreateColorPicker("Foreground Colour", 
        General.ForegroundColour or {1,1,1,1},
        function(widget, _, r, g, b, a) 
            General.ForegroundColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end,
        0.25, true, HealthColourOptions)
    
    -- Health colour checkboxes
    MilaUI:CreateCheckBox("Use Class / Reaction Colour", 
        General.ColourByClass,
        function(widget, event, value) 
            General.ColourByClass = value 
            MilaUI:UpdateFrames() 
        end,
        0.25, HealthColourOptions)
    
    MilaUI:CreateCheckBox("Use Disconnected Colour", 
        General.ColourIfDisconnected,
        function(widget, event, value) 
            General.ColourIfDisconnected = value 
            MilaUI:UpdateFrames() 
        end,
        0.25, HealthColourOptions)
    
    MilaUI:CreateCheckBox("Use Tapped Colour", 
        General.ColourIfTapped,
        function(widget, event, value) 
            General.ColourIfTapped = value 
            MilaUI:UpdateFrames() 
        end,
        0.25, HealthColourOptions)
    
    -- Background Colour Options section
    local BackgroundColourOptions = MilaUI:CreateInlineGroup("Background Colour Options", ColouringOptionsContainer)
    
    -- Background Colour picker
    MilaUI:CreateColorPicker("Background Colour", 
        General.BackgroundColour or {0,0,0,1},
        function(widget, _, r, g, b, a) 
            General.BackgroundColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end,
        1, true, BackgroundColourOptions)
    
    -- Background multiplier slider
    local BackgroundColourMultiplier = MilaUI:CreateSlider("Multiplier", 
        0, 1, 0.01,
        General.BackgroundMultiplier or 1,
        function(widget, event, value) 
            General.BackgroundMultiplier = value 
            MilaUI:UpdateFrames() 
        end,
        0.25, BackgroundColourOptions)
    
    -- Background colour options
    local BackgroundColourByForeground = MilaUI:CreateCheckBox("Colour By Foreground", 
        General.ColourBackgroundByForeground,
        function(widget, event, value) 
            General.ColourBackgroundByForeground = value 
            MilaUI:UpdateFrames() 
            if value then 
                BackgroundColourMultiplier:SetDisabled(false) 
            else 
                BackgroundColourMultiplier:SetDisabled(true) 
            end 
        end,
        0.25, BackgroundColourOptions)
    
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
    
    -- Border Colour Options section
    local BorderColourOptions = MilaUI:CreateInlineGroup("Border Colour Options", ColouringOptionsContainer)
    
    -- Border Colour picker
    MilaUI:CreateColorPicker("Border Colour", 
        General.BorderColour or {1,1,1,1},
        function(widget, _, r, g, b, a) 
            General.BorderColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end,
        0.33, true, BorderColourOptions)
    
    -- Custom Colours
    local CustomColours = MilaUI:CreateInlineGroup("Custom Colours", mainContainer)
    
    local ResetCustomColoursButton = GUI:Create("Button")
    ResetCustomColoursButton:SetText("Reset Custom Colours")
    ResetCustomColoursButton:SetCallback("OnClick", function(widget, event, value) 
        MilaUI:ResetColours() 
    end)
    ResetCustomColoursButton:SetRelativeWidth(1)
    CustomColours:AddChild(ResetCustomColoursButton)
    
    -- Power Colours
    local PowerColours = MilaUI:CreateInlineGroup("Power Colours", CustomColours)

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
    local ReactionColours = MilaUI:CreateInlineGroup("Reaction Colours", CustomColours)

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
    local StatusColours = MilaUI:CreateInlineGroup("Status Colours", CustomColours)

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
end