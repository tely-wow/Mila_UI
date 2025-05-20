local _, MilaUI = ...
local MilaUI_GUI = LibStub("AceGUI-3.0")
local GUI_WIDTH = 920
local GUI_HEIGHT = 720
local GUI_TITLE = C_AddOns.GetAddOnMetadata("MilaUI", "Title")
local GUI_VERSION = C_AddOns.GetAddOnMetadata("MilaUI", "Version")
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local NSM = C_AddOns.IsAddOnLoaded("NorthernSkyMedia") or C_AddOns.IsAddOnLoaded("NorthernSkyRaidTools")
if LSM then LSM:Register("border", "WHITE8X8", [[Interface\Buttons\WHITE8X8]]) end
local LSMFonts = {}
local LSMTextures = {}
local LSMBorders = {}
local GUIActive = false
local Supporters = {
    [1] = {Supporter = "", Comment = ""},
}

local MilaUI_GUI_Container = nil;

local function GenerateSupportOptions()
    local SupportOptions = {
        [1] = {SupportOption = "MILA AND ALEX DID IT!!"},
        [2] = {SupportOption = "BEST UNITFRAMES IN TOWN"},
    }

    local RandomIndex = math.random(1, #SupportOptions)
    local RandomSupportOption = SupportOptions[RandomIndex].SupportOption

    return "|cFFFFFFFF" .. RandomSupportOption .. "|r"
end

local PowerNames = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [4] = "Combo Points",
    [5] = "Runes",
    [6] = "Runic Power",
    [7] = "Soul Shards",
    [8] = "Lunar Power",
    [9] = "Holy Power",
    [11] = "Maelstrom",
    [13] = "Insanity",
    [17] = "Fury",
    [18] = "Pain"
}

local ReactionNames = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local StatusNames = {
    [1] = "Dead - Background Only",
    [2] = "Tapped - Foreground Only",
    [3] = "Disconnected - Foreground Only"
}


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

local GrowthX = {
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
}

local GrowthY = {
    ["UP"] = "Up",
    ["DOWN"] = "Down",
}

local CopyFrom = {
    ["Player"] = "Player",
    ["Target"] = "Target",
    ["Focus"] = "Focus",
    ["FocusTarget"] = "Focus Target",
    ["Pet"] = "Pet",
    ["TargetTarget"] = "Target Target",
}

local function GenerateCopyFromList(Unit)
    local CopyFromList = {}
    for k, v in pairs(CopyFrom) do
        if k ~= Unit then
            CopyFromList[k] = v
        end
    end
    return CopyFromList
end

local function CopyUnit(sourceUnit, targetUnit)
    if type(sourceUnit) ~= "table" or type(targetUnit) ~= "table" then return end
    for key, targetValue in pairs(targetUnit) do
        local sourceValue = sourceUnit[key]
        if type(targetValue) == "table" and type(sourceValue) == "table" then
            CopyUnit(sourceValue, targetValue)
        elseif sourceValue ~= nil then
            targetUnit[key] = sourceValue
        end
    end
    MilaUI:UpdateFrames()
    MilaUI:CreateReloadPrompt()
end


function MilaUI:CreateGUI()




        local General = MilaUI.DB.profile.General
        local Frame = MilaUI.DB.profile[Unit].Frame
        local Portrait = MilaUI.DB.profile[Unit].Portrait
        local Health = MilaUI.DB.profile[Unit].Health
        local HealthPrediction = Health.HealthPrediction
        local Absorbs = HealthPrediction.Absorbs
        local HealAbsorbs = HealthPrediction.HealAbsorbs
        local PowerBar = MilaUI.DB.profile[Unit].PowerBar
        local Buffs = MilaUI.DB.profile[Unit].Buffs
        local Debuffs = MilaUI.DB.profile[Unit].Debuffs
        local TargetMarker = MilaUI.DB.profile[Unit].TargetMarker
        local CombatIndicator = MilaUI.DB.profile[Unit].CombatIndicator
        local LeaderIndicator = MilaUI.DB.profile[Unit].LeaderIndicator
        local TargetIndicator = MilaUI.DB.profile[Unit].TargetIndicator
        local FirstText = MilaUI.DB.profile[Unit].Texts.First
        local SecondText = MilaUI.DB.profile[Unit].Texts.Second
        local ThirdText = MilaUI.DB.profile[Unit].Texts.Third
        local Range = MilaUI.DB.profile[Unit].Range

           if Unit == "Boss" then
                local DisplayFrames = MilaUI_GUI:Create("Button")
                DisplayFrames:SetText("Display Frames")
                DisplayFrames:SetCallback("OnClick", function(widget, event, value) MilaUI.DB.profile.TestMode = not MilaUI.DB.profile.TestMode MilaUI:DisplayBossFrames() MilaUI:UpdateFrames() end)
                DisplayFrames:SetRelativeWidth(1)
                MilaUI_GUI_Container:AddChild(DisplayFrames)
                if not Frame.Enabled then DisplayFrames:SetDisabled(true) end
            end

            if Unit == "Boss" then
                local FrameSpacing = MilaUI_GUI:Create("Slider")
                FrameSpacing:SetLabel("Frame Spacing")
                FrameSpacing:SetSliderValues(-999, 999, 0.1)
                FrameSpacing:SetValue(Frame.Spacing)
                FrameSpacing:SetCallback("OnMouseUp", function(widget, event, value) Frame.Spacing = value MilaUI:UpdateFrames() end)
                FrameXPosition:SetRelativeWidth(0.25)
                FrameYPosition:SetRelativeWidth(0.25)
                FrameSpacing:SetRelativeWidth(0.25)
                FrameOptions:AddChild(FrameSpacing)

                local GrowthDirection = MilaUI_GUI:Create("Dropdown")
                GrowthDirection:SetLabel("Growth Direction")
                GrowthDirection:SetList({
                    ["DOWN"] = "Down",
                    ["UP"] = "Up",
                })
                GrowthDirection:SetValue(Frame.GrowthY)
                GrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) Frame.GrowthY = value MilaUI:UpdateFrames() end)
                GrowthDirection:SetRelativeWidth(0.25)
                FrameOptions:AddChild(GrowthDirection)
            end



            local PortraitOptions = MilaUI_GUI:Create("InlineGroup")
            PortraitOptions:SetTitle("Portrait Options")
            PortraitOptions:SetLayout("Flow")
            PortraitOptions:SetFullWidth(true)

            local PortraitEnabled = MilaUI_GUI:Create("CheckBox")
            PortraitEnabled:SetLabel("Enable Portrait")
            PortraitEnabled:SetValue(Portrait.Enabled)
            PortraitEnabled:SetCallback("OnValueChanged", function(widget, event, value) Portrait.Enabled = value MilaUI:CreateReloadPrompt() end)
            PortraitEnabled:SetRelativeWidth(1)
            PortraitOptions:AddChild(PortraitEnabled)

            local PortraitAnchorFrom = MilaUI_GUI:Create("Dropdown")
            PortraitAnchorFrom:SetLabel("Anchor From")
            PortraitAnchorFrom:SetList(AnchorPoints)
            PortraitAnchorFrom:SetValue(Portrait.AnchorFrom)
            PortraitAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorFrom = value MilaUI:UpdateFrames() end)
            PortraitAnchorFrom:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorFrom)

            local PortraitAnchorTo = MilaUI_GUI:Create("Dropdown")
            PortraitAnchorTo:SetLabel("Anchor To")
            PortraitAnchorTo:SetList(AnchorPoints)
            PortraitAnchorTo:SetValue(Portrait.AnchorTo)
            PortraitAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorTo = value MilaUI:UpdateFrames() end)
            PortraitAnchorTo:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorTo)

            local PortraitSize = MilaUI_GUI:Create("Slider")
            PortraitSize:SetLabel("Portrait Size")
            PortraitSize:SetSliderValues(1, 999, 0.1)
            PortraitSize:SetValue(Portrait.Size)
            PortraitSize:SetCallback("OnMouseUp", function(widget, event, value) Portrait.Size = value MilaUI:UpdateFrames() end)
            PortraitSize:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitSize)

            local PortraitXOffset = MilaUI_GUI:Create("Slider")
            PortraitXOffset:SetLabel("Portrait X Offset")
            PortraitXOffset:SetSliderValues(-999, 999, 1)
            PortraitXOffset:SetValue(Portrait.XOffset)
            PortraitXOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.XOffset = value MilaUI:UpdateFrames() end)
            PortraitXOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitXOffset)

            local PortraitYOffset = MilaUI_GUI:Create("Slider")
            PortraitYOffset:SetLabel("Portrait Y Offset")
            PortraitYOffset:SetSliderValues(-999, 999, 1)
            PortraitYOffset:SetValue(Portrait.YOffset)
            PortraitYOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.YOffset = value MilaUI:UpdateFrames() end)
            PortraitYOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitYOffset)

            MilaUI_GUI_Container:AddChild(PortraitOptions)
            
            local AbsorbsContainer = MilaUI_GUI:Create("InlineGroup")
            AbsorbsContainer:SetTitle("Health Prediction Options")
            AbsorbsContainer:SetLayout("Flow")
            AbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(AbsorbsContainer)

            local AbsorbsEnabled = MilaUI_GUI:Create("CheckBox")
            AbsorbsEnabled:SetLabel("Enable Absorbs")
            AbsorbsEnabled:SetValue(Absorbs.Enabled)
            AbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Absorbs.Enabled = value MilaUI:CreateReloadPrompt() end)
            AbsorbsEnabled:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsEnabled)

            local AbsorbsColourPicker = MilaUI_GUI:Create("ColorPicker")
            AbsorbsColourPicker:SetLabel("Colour")
            local AR, AG, AB, AA = unpack(Absorbs.Colour)
            AbsorbsColourPicker:SetColor(AR, AG, AB, AA)
            AbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Absorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            AbsorbsColourPicker:SetHasAlpha(true)
            AbsorbsColourPicker:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsColourPicker)

            local HealAbsorbsContainer = MilaUI_GUI:Create("InlineGroup")
            HealAbsorbsContainer:SetTitle("Heal Absorbs")
            HealAbsorbsContainer:SetLayout("Flow")
            HealAbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(HealAbsorbsContainer)

            local HealAbsorbsEnabled = MilaUI_GUI:Create("CheckBox")
            HealAbsorbsEnabled:SetLabel("Enable Heal Absorbs")
            HealAbsorbsEnabled:SetValue(HealAbsorbs.Enabled)
            HealAbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) HealAbsorbs.Enabled = value MilaUI:UpdateFrames() end)
            HealAbsorbsEnabled:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsEnabled)

            local HealAbsorbsColourPicker = MilaUI_GUI:Create("ColorPicker")
            HealAbsorbsColourPicker:SetLabel("Colour")
            local HAR, HAG, HAB, HAA = unpack(HealAbsorbs.Colour)
            HealAbsorbsColourPicker:SetColor(HAR, HAG, HAB, HAA)
            HealAbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) HealAbsorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            HealAbsorbsColourPicker:SetHasAlpha(true)
            HealAbsorbsColourPicker:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsColourPicker)

            MilaUI_GUI_Container:AddChild(HealthOptionsContainer)



        local function SelectedGroup(MilaUI_GUI_Container, Event, Group)
            MilaUI_GUI_Container:ReleaseChildren()
            if Group == "Frame" then
                DrawFrameContainer(MilaUI_GUI_Container)
            elseif Group == "Texts" then
                DrawTextsContainer(MilaUI_GUI_Container)
            elseif Group == "Buffs" then
                DrawBuffsContainer(MilaUI_GUI_Container)
            elseif Group == "Debuffs" then
                DrawDebuffsContainer(MilaUI_GUI_Container)
            elseif Group == "Indicators" then
                DrawIndicatorContainer(MilaUI_GUI_Container)
            elseif Unit ~= "player" and Group == "Range" then
                DrawRangeContainer(MilaUI_GUI_Container)
            end
        end

        GUIContainerTabGroup = MilaUI_GUI:Create("TabGroup")
        GUIContainerTabGroup:SetLayout("Flow")
        local ContainerTabs = {
            { text = "Frame",            value = "Frame" },
            { text = "Texts",            value = "Texts" },
            { text = "Buffs",            value = "Buffs" },
            { text = "Debuffs",          value = "Debuffs" },
            { text = "Indicators",       value = "Indicators" },
        }
        if Unit ~= "Player" then
            table.insert(ContainerTabs, { text = "Range", value = "Range" })
        end
        if not Frame.Enabled then
            for i = 1, #ContainerTabs do
                if ContainerTabs[i].value ~= "Frame" then
                    ContainerTabs[i].disabled = true
                end
            end
        end
        GUIContainerTabGroup:SetTabs(ContainerTabs)
        
        GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
        GUIContainerTabGroup:SelectTab("Frame")
        GUIContainerTabGroup:SetFullWidth(true)
        ScrollableContainer:AddChild(GUIContainerTabGroup)
    end

    


