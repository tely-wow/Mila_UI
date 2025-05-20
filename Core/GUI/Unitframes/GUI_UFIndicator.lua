local _, MilaUI = ...
local L = MilaUI.L -- Assuming L is attached to MilaUI or accessible globally
local GUI = LibStub("AceGUI-3.0") -- Direct reference to AceGUI
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
MilaUI.GUI = GUI
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"
local unitSettingsContainer = nil

function MilaUI:DrawIndicatorContainer(dbUnitName, MilaUI_GUI_Container)
    local TargetMarker = MilaUI.DB.profile[dbUnitName].TargetMarker
    local CombatIndicator = MilaUI.DB.profile[dbUnitName].CombatIndicator
    local LeaderIndicator = MilaUI.DB.profile[dbUnitName].LeaderIndicator
    local TargetIndicator = MilaUI.DB.profile[dbUnitName].TargetIndicator
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

    MilaUI:CreateLargeHeading("Indicator Options", MilaUI_GUI_Container)

    local TargetMarkerOptions = GUI:Create("InlineGroup")
    TargetMarkerOptions:SetTitle(pink .. "Target Marker Options")
    TargetMarkerOptions:SetLayout("Flow")
    TargetMarkerOptions:SetFullWidth(true)
    MilaUI_GUI_Container:AddChild(TargetMarkerOptions)

    local TargetMarkerEnabled = GUI:Create("CheckBox")
    TargetMarkerEnabled:SetLabel("Enable Target Marker")
    TargetMarkerEnabled:SetValue(TargetMarker.Enabled)
    TargetMarkerEnabled:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.Enabled = value MilaUI:CreateReloadPrompt() end)
    TargetMarkerEnabled:SetRelativeWidth(0.5)
    TargetMarkerOptions:AddChild(TargetMarkerEnabled)

    local TargetMarkerSize = GUI:Create("Slider")
    TargetMarkerSize:SetLabel(lavender .. "Size")
    TargetMarkerSize:SetSliderValues(-1, 64, 1)
    TargetMarkerSize:SetValue(TargetMarker.Size)
    TargetMarkerSize:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.Size = value MilaUI:UpdateFrames() end)
    TargetMarkerSize:SetRelativeWidth(0.5)
    TargetMarkerOptions:AddChild(TargetMarkerSize)

    local anchorcontainer = GUI:Create("InlineGroup")
    anchorcontainer:SetLayout("Flow")
    anchorcontainer:SetRelativeWidth(0.5)
    TargetMarkerOptions:AddChild(anchorcontainer)

    local TargetMarkerAnchorFrom = GUI:Create("Dropdown")
    TargetMarkerAnchorFrom:SetLabel(lavender .. "Anchor From")
    TargetMarkerAnchorFrom:SetList(AnchorPoints)
    TargetMarkerAnchorFrom:SetValue(TargetMarker.AnchorFrom)
    TargetMarkerAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.AnchorFrom = value MilaUI:UpdateFrames() end)
    TargetMarkerAnchorFrom:SetRelativeWidth(1)
    anchorcontainer:AddChild(TargetMarkerAnchorFrom)

    local TargetMarkerAnchorTo = GUI:Create("Dropdown")
    TargetMarkerAnchorTo:SetLabel("Anchor To")
    TargetMarkerAnchorTo:SetList(AnchorPoints)
    TargetMarkerAnchorTo:SetValue(TargetMarker.AnchorTo)
    TargetMarkerAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.AnchorTo = value MilaUI:UpdateFrames() end)
    TargetMarkerAnchorTo:SetRelativeWidth(1)
    anchorcontainer:AddChild(TargetMarkerAnchorTo)

    local positioncontainer = GUI:Create("InlineGroup")
    positioncontainer:SetLayout("Flow")
    positioncontainer:SetRelativeWidth(0.5)
    TargetMarkerOptions:AddChild(positioncontainer)

    local TargetMarkerXOffset = GUI:Create("Slider")
    TargetMarkerXOffset:SetLabel(lavender .. "X Offset")
    TargetMarkerXOffset:SetSliderValues(-64, 64, 1)
    TargetMarkerXOffset:SetValue(TargetMarker.XOffset)
    TargetMarkerXOffset:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.XOffset = value MilaUI:UpdateFrames() end)
    TargetMarkerXOffset:SetRelativeWidth(1)
    positioncontainer:AddChild(TargetMarkerXOffset)

    local TargetMarkerYOffset = GUI:Create("Slider")
    TargetMarkerYOffset:SetLabel(lavender .. "Y Offset")
    TargetMarkerYOffset:SetSliderValues(-64, 64, 1)
    TargetMarkerYOffset:SetValue(TargetMarker.YOffset)
    TargetMarkerYOffset:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.YOffset = value MilaUI:UpdateFrames() end)
    TargetMarkerYOffset:SetRelativeWidth(1)
    positioncontainer:AddChild(TargetMarkerYOffset)

    if dbUnitName == "Player" or dbUnitName == "Target" or dbUnitName == "Focus" then
        MilaUI:CreateLargeHeading("Combat Indicator", MilaUI_GUI_Container)
        local CombatIndicatorOptions = GUI:Create("InlineGroup")
        CombatIndicatorOptions:SetLayout("Flow")
        CombatIndicatorOptions:SetFullWidth(true)
        MilaUI_GUI_Container:AddChild(CombatIndicatorOptions)

        local CombatIndicatorEnabled = GUI:Create("CheckBox")
        CombatIndicatorEnabled:SetLabel("Enable Combat Indicator")
        CombatIndicatorEnabled:SetValue(CombatIndicator.Enabled)
        CombatIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.Enabled = value MilaUI:CreateReloadPrompt() end)
        CombatIndicatorEnabled:SetRelativeWidth(0.5)
        CombatIndicatorOptions:AddChild(CombatIndicatorEnabled)

        local CombatIndicatorSize = GUI:Create("Slider")
        CombatIndicatorSize:SetLabel(lavender .. "Size")
        CombatIndicatorSize:SetSliderValues(-1, 64, 1)
        CombatIndicatorSize:SetValue(CombatIndicator.Size)
        CombatIndicatorSize:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.Size = value MilaUI:UpdateFrames() end)
        CombatIndicatorSize:SetRelativeWidth(0.5)
        CombatIndicatorOptions:AddChild(CombatIndicatorSize)

        local anchorcontainer = GUI:Create("InlineGroup")
        anchorcontainer:SetLayout("Flow")
        anchorcontainer:SetRelativeWidth(0.5)
        CombatIndicatorOptions:AddChild(anchorcontainer)

        local CombatIndicatorAnchorFrom = GUI:Create("Dropdown")
        CombatIndicatorAnchorFrom:SetLabel(lavender .. "Anchor From")
        CombatIndicatorAnchorFrom:SetList(AnchorPoints)
        CombatIndicatorAnchorFrom:SetValue(CombatIndicator.AnchorFrom)
        CombatIndicatorAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.AnchorFrom = value MilaUI:UpdateFrames() end)
        CombatIndicatorAnchorFrom:SetRelativeWidth(1)
        anchorcontainer:AddChild(CombatIndicatorAnchorFrom)

        local CombatIndicatorAnchorTo = GUI:Create("Dropdown")
        CombatIndicatorAnchorTo:SetLabel(lavender .. "Anchor To")
        CombatIndicatorAnchorTo:SetList(AnchorPoints)
        CombatIndicatorAnchorTo:SetValue(CombatIndicator.AnchorTo)
        CombatIndicatorAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.AnchorTo = value MilaUI:UpdateFrames() end)
        CombatIndicatorAnchorTo:SetRelativeWidth(1)
        anchorcontainer:AddChild(CombatIndicatorAnchorTo)

        local positioncontainer = GUI:Create("InlineGroup")
        positioncontainer:SetLayout("Flow")
        positioncontainer:SetRelativeWidth(0.5)
        CombatIndicatorOptions:AddChild(positioncontainer)

        local CombatIndicatorXOffset = GUI:Create("Slider")
        CombatIndicatorXOffset:SetLabel(lavender .. "X Offset")
        CombatIndicatorXOffset:SetSliderValues(-64, 64, 1)
        CombatIndicatorXOffset:SetValue(CombatIndicator.XOffset)
        CombatIndicatorXOffset:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.XOffset = value MilaUI:UpdateFrames() end)
        CombatIndicatorXOffset:SetRelativeWidth(1)
        positioncontainer:AddChild(CombatIndicatorXOffset)

        local CombatIndicatorYOffset = GUI:Create("Slider")
        CombatIndicatorYOffset:SetLabel(lavender .. "Y Offset")
        CombatIndicatorYOffset:SetSliderValues(-64, 64, 1)
        CombatIndicatorYOffset:SetValue(CombatIndicator.YOffset)
        CombatIndicatorYOffset:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.YOffset = value MilaUI:UpdateFrames() end)
        CombatIndicatorYOffset:SetRelativeWidth(1)
        positioncontainer:AddChild(CombatIndicatorYOffset)
        
        -- Leader Indicator
        if dbUnitName == "Player" or dbUnitName == "Target" then
        MilaUI:CreateLargeHeading("Leader Indicator", MilaUI_GUI_Container)
        local LeaderIndicatorOptions = GUI:Create("InlineGroup")
        LeaderIndicatorOptions:SetLayout("Flow")
        LeaderIndicatorOptions:SetFullWidth(true)
        MilaUI_GUI_Container:AddChild(LeaderIndicatorOptions)

        local LeaderIndicatorEnabled = GUI:Create("CheckBox")
        LeaderIndicatorEnabled:SetLabel("Enable Leader Indicator")
        LeaderIndicatorEnabled:SetValue(LeaderIndicator.Enabled)
        LeaderIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.Enabled = value MilaUI:CreateReloadPrompt() end)
        LeaderIndicatorEnabled:SetRelativeWidth(0.5)
        LeaderIndicatorOptions:AddChild(LeaderIndicatorEnabled)

        local LeaderIndicatorSize = GUI:Create("Slider")
        LeaderIndicatorSize:SetLabel(lavender .. "Size")
        LeaderIndicatorSize:SetSliderValues(-1, 64, 1)
        LeaderIndicatorSize:SetValue(LeaderIndicator.Size)
        LeaderIndicatorSize:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.Size = value MilaUI:UpdateFrames() end)
        LeaderIndicatorSize:SetRelativeWidth(0.5)
        LeaderIndicatorOptions:AddChild(LeaderIndicatorSize)

        local anchorcontainer = GUI:Create("InlineGroup")
        anchorcontainer:SetLayout("Flow")
        anchorcontainer:SetRelativeWidth(0.5)
        LeaderIndicatorOptions:AddChild(anchorcontainer)

        local LeaderIndicatorAnchorFrom = GUI:Create("Dropdown")
        LeaderIndicatorAnchorFrom:SetLabel(lavender .. "Anchor From")
        LeaderIndicatorAnchorFrom:SetList(AnchorPoints)
        LeaderIndicatorAnchorFrom:SetValue(LeaderIndicator.AnchorFrom)
        LeaderIndicatorAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.AnchorFrom = value MilaUI:UpdateFrames() end)
        LeaderIndicatorAnchorFrom:SetRelativeWidth(1)
        anchorcontainer:AddChild(LeaderIndicatorAnchorFrom)

        local LeaderIndicatorAnchorTo = GUI:Create("Dropdown")
        LeaderIndicatorAnchorTo:SetLabel(lavender .. "Anchor To")
        LeaderIndicatorAnchorTo:SetList(AnchorPoints)
        LeaderIndicatorAnchorTo:SetValue(LeaderIndicator.AnchorTo)
        LeaderIndicatorAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.AnchorTo = value MilaUI:UpdateFrames() end)
        LeaderIndicatorAnchorTo:SetRelativeWidth(1)
        anchorcontainer:AddChild(LeaderIndicatorAnchorTo)

        local positioncontainer = GUI:Create("InlineGroup")
        positioncontainer:SetLayout("Flow")
        positioncontainer:SetRelativeWidth(0.5)
        LeaderIndicatorOptions:AddChild(positioncontainer)

        local LeaderIndicatorXOffset = GUI:Create("Slider")
        LeaderIndicatorXOffset:SetLabel(lavender .. "X Offset")
        LeaderIndicatorXOffset:SetSliderValues(-64, 64, 1)
        LeaderIndicatorXOffset:SetValue(LeaderIndicator.XOffset)
        LeaderIndicatorXOffset:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.XOffset = value MilaUI:UpdateFrames() end)
        LeaderIndicatorXOffset:SetRelativeWidth(1)
        positioncontainer:AddChild(LeaderIndicatorXOffset)

        local LeaderIndicatorYOffset = GUI:Create("Slider")
        LeaderIndicatorYOffset:SetLabel(lavender .. "Y Offset")
        LeaderIndicatorYOffset:SetSliderValues(-64, 64, 1)
        LeaderIndicatorYOffset:SetValue(LeaderIndicator.YOffset)
        LeaderIndicatorYOffset:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.YOffset = value MilaUI:UpdateFrames() end)
        LeaderIndicatorYOffset:SetRelativeWidth(1)
        positioncontainer:AddChild(LeaderIndicatorYOffset)
        end
    end
end