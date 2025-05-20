--[[
    Mila_UI
    GUI_UFText.lua
    Handles the text options for unitframes
]]

local _, MilaUI = ...
-- Initialize module structure
local GUI = LibStub("AceGUI-3.0") -- Direct reference to AceGUI
MilaUI.GUI.UnitFrames = MilaUI.GUI.UnitFrames or {}

local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"

-- Define anchor points for dropdown menus
local AnchorPoints = {
    ["TOPLEFT"] = "Top Left",
    ["TOP"] = "Top",
    ["TOPRIGHT"] = "Top Right",
    ["LEFT"] = "Left",
    ["CENTER"] = "Center",
    ["RIGHT"] = "Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOM"] = "Bottom",
    ["BOTTOMRIGHT"] = "Bottom Right",
}

-- Function to create a text configuration section
local function CreateTextSection(container, title, textConfig, unitName)
    local taggroup = GUI:Create("InlineGroup")
    local position = GUI:Create("InlineGroup")
    local anchor = GUI:Create("InlineGroup")
    taggroup:SetLayout("Flow")
    taggroup:SetRelativeWidth(1)
    position:SetLayout("Flow")
    position:SetTitle(pink .. "Position")
    position:SetRelativeWidth(0.5)
    anchor:SetLayout("Flow")
    anchor:SetTitle(pink .. "Anchor")
    anchor:SetRelativeWidth(0.5)
    container:AddChild(MilaUI:CreateLargeHeading(title))
    container:AddChild(taggroup)
    local tag = GUI:Create("EditBox")
    tag:SetLabel(lavender .. "Tag")
    tag:SetText(textConfig.Tag)
    tag:SetCallback("OnEnterPressed", function(widget, event, value) 
        textConfig.Tag = value 
        MilaUI:UpdateFrames() 
    end)
    tag:SetRelativeWidth(0.4)
    taggroup:AddChild(tag)

    taggroup:AddChild(MilaUI:CreateHorizontalSpacer(0.1))

    local colorPicker = GUI:Create("ColorPicker")
    colorPicker:SetLabel(lavender .. "Colour")
    local r, g, b, a = unpack(textConfig.Colour)
    colorPicker:SetColor(r, g, b, a)
    colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) 
        textConfig.Colour = {r, g, b, a} 
        MilaUI:UpdateFrames() 
    end)
    colorPicker:SetHasAlpha(true)
    colorPicker:SetRelativeWidth(0.15)
    taggroup:AddChild(colorPicker)

    local fontSize = GUI:Create("Slider")
    fontSize:SetLabel(lavender .. "Font Size")
    fontSize:SetSliderValues(1, 64, 1)
    fontSize:SetValue(textConfig.FontSize)
    fontSize:SetCallback("OnMouseUp", function(widget, event, value) 
        textConfig.FontSize = value 
        MilaUI:UpdateFrames() 
    end)
    fontSize:SetRelativeWidth(0.3)
    taggroup:AddChild(fontSize)
    taggroup:AddChild(position)
    taggroup:AddChild(anchor)
    
    local xOffset = GUI:Create("Slider")
    xOffset:SetLabel(lavender .. "X Offset")
    xOffset:SetSliderValues(-200, 200, 1)
    xOffset:SetValue(textConfig.XOffset)
    xOffset:SetCallback("OnMouseUp", function(widget, event, value) 
        textConfig.XOffset = value 
        MilaUI:UpdateFrames() 
    end)
    xOffset:SetRelativeWidth(1)
    position:AddChild(xOffset)

    local yOffset = GUI:Create("Slider")
    yOffset:SetLabel(lavender .. "Y Offset")
    yOffset:SetSliderValues(-200, 200, 1)
    yOffset:SetValue(textConfig.YOffset)
    yOffset:SetCallback("OnMouseUp", function(widget, event, value) 
        textConfig.YOffset = value 
        MilaUI:UpdateFrames() 
    end)
    yOffset:SetRelativeWidth(1)
    position:AddChild(yOffset)

    local anchorFrom = GUI:Create("Dropdown")
    anchorFrom:SetLabel(lavender .. "Anchor From")
    anchorFrom:SetList(AnchorPoints)
    anchorFrom:SetValue(textConfig.AnchorFrom)
    anchorFrom:SetCallback("OnValueChanged", function(widget, event, value) 
        textConfig.AnchorFrom = value 
        MilaUI:UpdateFrames() 
    end)
    anchorFrom:SetRelativeWidth(1)
    anchor:AddChild(anchorFrom)



    local anchorTo = GUI:Create("Dropdown")
    anchorTo:SetLabel(lavender .. "Anchor To")
    anchorTo:SetList(AnchorPoints)
    anchorTo:SetValue(textConfig.AnchorTo)
    anchorTo:SetCallback("OnValueChanged", function(widget, event, value) 
        textConfig.AnchorTo = value 
        MilaUI:UpdateFrames() 
    end)
    anchorTo:SetRelativeWidth(1)
    anchor:AddChild(anchorTo)

    return container
end

-- Main function to draw the text options container
function MilaUI:DrawUnitFrameTextOptions(container, unitName)
    local dbUnitName = MilaUI:GetUnitDatabaseKey(unitName)
    
    -- Safety check
    if not dbUnitName or not MilaUI.DB.profile[dbUnitName] then
        local errorText = GUI:Create("Label")
        errorText:SetText("Error: Could not find unit data for " .. (unitName or "unknown"))
        errorText:SetFullWidth(true)
        container:AddChild(errorText)
        return
    end
    
    -- Get the text configuration for this unit
    local unitConfig = MilaUI.DB.profile[dbUnitName]
    
    -- Check if the unit has text configuration
    if not unitConfig.Texts then
        unitConfig.Texts = {
            First = {
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                XOffset = 0,
                YOffset = 0,
                FontSize = 12,
                Colour = {1, 1, 1, 1},
                Tag = "[health:current]"
            },
            Second = {
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                XOffset = 0,
                YOffset = -15,
                FontSize = 10,
                Colour = {1, 1, 1, 1},
                Tag = "[name]"
            },
            Third = {
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                XOffset = 0,
                YOffset = 15,
                FontSize = 10,
                Colour = {1, 1, 1, 1},
                Tag = "[power:current]"
            }
        }
    end
    
    -- First Text Options
    CreateTextSection(container, "First Tag", unitConfig.Texts.First, dbUnitName)
    container:AddChild(MilaUI:CreateVerticalSpacer(15))
    
    -- Second Text Options
    CreateTextSection(container, "Second Tag", unitConfig.Texts.Second, dbUnitName)
    container:AddChild(MilaUI:CreateVerticalSpacer(15))
    
    -- Third Text Options
    CreateTextSection(container, "Third Tag", unitConfig.Texts.Third, dbUnitName)
end

