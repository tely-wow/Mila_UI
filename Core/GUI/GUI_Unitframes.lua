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

-- This function draws the specific settings for a given unit (Player, Target, etc.)
function MilaUI:DrawUnitContainer(container, unitName, tabKey)
    container:ReleaseChildren() -- Clear previous unit's settings
    
    -- Convert UI unit name to database key
    local dbUnitName = self:GetUnitDatabaseKey(unitName)
    
    -- Debug output to help troubleshoot
    if not MilaUI.DB.profile[dbUnitName] then
        print(pink .. "♥MILA UI ♥: " .. lavender .. "Error: Could not find settings for unit '" .. dbUnitName .. "'")
        return
    end

    -- Create a tab group using AceGUI's built-in tab system
    local tabGroup = GUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    
    -- Set up the tabs
    tabGroup:SetTabs({
        { text = "Healthbar", value = "Healthbar" },
        { text = "PowerBar", value = "PowerBar" },
        { text = "Buffs", value = "Buffs" },
        { text = "Debuffs", value = "Debuffs" },
        { text = "Indicators", value = "Indicators" },
    })
    
    -- Add the tab group to the container first
    container:AddChild(tabGroup)
    
    -- Set up the callback for tab selection
    tabGroup:SetCallback("OnGroupSelected", function(widget, event, tabKey)
        widget:ReleaseChildren() -- Clear previous tab's content
        --widget:SetFullHeight(true)
        -- Create a scroll frame for the content
        local scrollFrame = GUI:Create("ScrollFrame")
        scrollFrame:SetLayout("Flow")
        scrollFrame:SetFullWidth(true)
        scrollFrame:SetFullHeight(true)
        widget:AddChild(scrollFrame)
        
        if tabKey == "Healthbar" then
            local General = MilaUI.DB.profile.UnitframesGeneral or MilaUI.DB.profile.General
            local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
            local LSMTextures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
            local LSMFonts = LSM and LSM:HashTable(LSM.MediaType.FONT) or {}
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

            local Health = MilaUI.DB.profile[dbUnitName].Health
            local Frame = MilaUI.DB.profile[dbUnitName].Frame

            -- Health Texture Picker
            local TextureandBorder = GUI:Create("InlineGroup")
            TextureandBorder:SetLayout("Flow")
            TextureandBorder:SetFullWidth(true)
            TextureandBorder:SetTitle(pink .. "Texture and Border")
            scrollFrame:AddChild(TextureandBorder)
            local HealthTexturePicker = GUI:Create("LSM30_Statusbar")
            HealthTexturePicker:SetLabel("Health Texture")
            HealthTexturePicker:SetList(LSM:HashTable("statusbar"))
            HealthTexturePicker:SetValue(Health.Texture)
            HealthTexturePicker:SetRelativeWidth(0.5)
            HealthTexturePicker:SetCallback("OnValueChanged", function(widget, event, value)
                Health.Texture = value
                HealthTexturePicker:SetValue(value) -- Immediately update the dropdown value
                MilaUI:UpdateFrames()
            end)
            TextureandBorder:AddChild(HealthTexturePicker)

            -- Add a little vertical space after the picker for clarity
            local spacer = GUI:Create("Label")
            spacer:SetText("")
            spacer:SetFullWidth(true)
            TextureandBorder:AddChild(spacer)

            -- Custom Border
            local CustomBorder = GUI:Create("CheckBox")
            CustomBorder:SetLabel("Custom Border")
            CustomBorder:SetValue(Health.CustomBorder and Health.CustomBorder.Enabled)
            CustomBorder:SetCallback("OnValueChanged", function(widget, event, value) Health.CustomBorder.Enabled = value MilaUI:UpdateFrames() end)
            CustomBorder:SetRelativeWidth(0.5)
            TextureandBorder:AddChild(CustomBorder)

            local PositionandSize = GUI:Create("InlineGroup")
            PositionandSize:SetLayout("Flow")
            PositionandSize:SetTitle(pink .. "Position and Size")
            PositionandSize.titletext:SetFontObject(GameFontNormalLarge)
            PositionandSize:SetFullWidth(true)
            PositionandSize:SetFullHeight(true)
            scrollFrame:AddChild(PositionandSize)
            -- Frame Width
            local FrameWidth = GUI:Create("Slider")
            FrameWidth:SetLabel("Width")
            FrameWidth:SetSliderValues(1, 500, 1)
            FrameWidth:SetValue(Health.Width)
            FrameWidth:SetCallback("OnMouseUp", function(widget, event, value) Health.Width = value MilaUI:UpdateFrames() end)
            FrameWidth:SetRelativeWidth(0.5)
            PositionandSize:AddChild(FrameWidth)

            -- Frame Height
            local FrameHeight = GUI:Create("Slider")
            FrameHeight:SetLabel("Height")
            FrameHeight:SetSliderValues(1, 500, 1)
            FrameHeight:SetValue(Health.Height)
            FrameHeight:SetCallback("OnMouseUp", function(widget, event, value) Health.Height = value MilaUI:UpdateFrames() end)
            FrameHeight:SetRelativeWidth(0.5)
            PositionandSize:AddChild(FrameHeight)

            -- Frame Anchor From
            local FrameAnchorFrom = GUI:Create("Dropdown")
            FrameAnchorFrom:SetLabel("Anchor From")
            FrameAnchorFrom:SetList(AnchorPoints)
            FrameAnchorFrom:SetValue(Frame.AnchorFrom)
            FrameAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorFrom = value MilaUI:UpdateFrames() end)
            FrameAnchorFrom:SetRelativeWidth(0.33)
            PositionandSize:AddChild(FrameAnchorFrom)

            -- Frame Anchor To
            local FrameAnchorTo = GUI:Create("Dropdown")
            FrameAnchorTo:SetLabel("Anchor To")
            FrameAnchorTo:SetList(AnchorPoints)
            FrameAnchorTo:SetValue(Frame.AnchorTo)
            FrameAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorTo = value MilaUI:UpdateFrames() end)
            FrameAnchorTo:SetRelativeWidth(0.33)
            PositionandSize:AddChild(FrameAnchorTo)

            -- Frame Anchor Parent
            local FrameAnchorParent = GUI:Create("EditBox")
            FrameAnchorParent:SetLabel("Anchor Parent")
            FrameAnchorParent:SetText(type(Frame.AnchorParent) == "string" and Frame.AnchorParent or "UIParent")
            FrameAnchorParent:SetCallback("OnEnterPressed", function(widget, event, value)
                local anchor = _G[value]
                if anchor and anchor.IsObjectType and anchor:IsObjectType("Frame") then
                    Frame.AnchorParent = value
                else
                    Frame.AnchorParent = "UIParent"
                    widget:SetText("UIParent")
                end
                MilaUI:UpdateFrames()
            end)
            FrameAnchorParent:SetRelativeWidth(0.33)
            scrollFrame:AddChild(FrameAnchorParent)
            FrameAnchorParent:SetCallback("OnEnter", function(widget, event)
                GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")
                GameTooltip:AddLine("|cFF8080FFPLEASE NOTE|r: This will |cFFFF4040NOT|r work for WeakAuras.")
                GameTooltip:Show()
            end)
            FrameAnchorParent:SetCallback("OnLeave", function(widget, event) GameTooltip:Hide() end)

            -- Frame X Position
            local FrameXPosition = GUI:Create("Slider")
            FrameXPosition:SetLabel("Frame X Position")
            FrameXPosition:SetSliderValues(-999, 999, 0.1)
            FrameXPosition:SetValue(Frame.XPosition)
            FrameXPosition:SetCallback("OnValueChanged", function(widget, event, value) Frame.XPosition = value MilaUI:UpdateFrames() end)
            FrameXPosition:SetRelativeWidth(0.5)
            PositionandSize:AddChild(FrameXPosition)

            -- Frame Y Position
            local FrameYPosition = GUI:Create("Slider")
            FrameYPosition:SetLabel("Frame Y Position")
            FrameYPosition:SetSliderValues(-999, 999, 0.1)
            FrameYPosition:SetValue(Frame.YPosition)
            FrameYPosition:SetCallback("OnValueChanged", function(widget, event, value) Frame.YPosition = value MilaUI:UpdateFrames() end)
            FrameYPosition:SetRelativeWidth(0.5)
            PositionandSize:AddChild(FrameYPosition)
        elseif tabKey == "PowerBar" then
            local General = MilaUI.DB.profile.UnitframesGeneral or MilaUI.DB.profile.General
            local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
            local LSMTextures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
            local LSMFonts = LSM and LSM:HashTable(LSM.MediaType.FONT) or {}
            local PowerBar = MilaUI.DB.profile[dbUnitName].PowerBar

            -- PowerBar Enabled
            local PowerBarEnabled = GUI:Create("CheckBox")
            PowerBarEnabled:SetLabel("PowerBar Enabled")
            PowerBarEnabled:SetValue(PowerBar.Enabled)
            PowerBarEnabled:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Enabled = value MilaUI:UpdateFrames() end)
            PowerBarEnabled:SetRelativeWidth(0.5)
            scrollFrame:AddChild(PowerBarEnabled)

            --PowerBar Custom Mask
            local PowerBarCustomMask = GUI:Create("CheckBox")
            PowerBarCustomMask:SetLabel("PowerBar Custom Mask")
            PowerBarCustomMask:SetValue(PowerBar.CustomMask.Enabled)
            PowerBarCustomMask:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.CustomMask.Enabled = value MilaUI:CreateReloadPrompt() end)
            PowerBarCustomMask:SetRelativeWidth(0.5)
            scrollFrame:AddChild(PowerBarCustomMask)

            -- PowerBar Texture Picker
            local PowerBarTexturePicker = GUI:Create("LSM30_Statusbar")
            PowerBarTexturePicker:SetLabel("PowerBar Texture")
            PowerBarTexturePicker:SetList(LSM and LSM:HashTable("statusbar") or {})
            PowerBarTexturePicker:SetValue(PowerBar.Texture)
            PowerBarTexturePicker:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Texture = value MilaUI:UpdateFrames() end)
            PowerBarTexturePicker:SetRelativeWidth(0.5)
            scrollFrame:AddChild(PowerBarTexturePicker)
            
            -- PowerBar Positioning Group
            local PowerBarPositioning = GUI:Create("InlineGroup")
            PowerBarPositioning:SetTitle(pink .. "PowerBar Positioning")
            PowerBarPositioning:SetLayout("Flow")
            PowerBarPositioning:SetFullWidth(true)
            scrollFrame:AddChild(PowerBarPositioning)
            
            -- PowerBar Anchor From dropdown
            local PowerBarAnchorFrom = GUI:Create("Dropdown")
            PowerBarAnchorFrom:SetLabel("Anchor From")
            PowerBarAnchorFrom:SetList({
                ["TOPLEFT"] = "Top Left",
                ["TOP"] = "Top",
                ["TOPRIGHT"] = "Top Right",
                ["LEFT"] = "Left",
                ["CENTER"] = "Center",
                ["RIGHT"] = "Right",
                ["BOTTOMLEFT"] = "Bottom Left",
                ["BOTTOM"] = "Bottom",
                ["BOTTOMRIGHT"] = "Bottom Right",
            })
            PowerBarAnchorFrom:SetValue(PowerBar.AnchorFrom or "TOPLEFT")
            PowerBarAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.AnchorFrom = value MilaUI:UpdateFrames() end)
            PowerBarAnchorFrom:SetRelativeWidth(0.33)
            PowerBarPositioning:AddChild(PowerBarAnchorFrom)
            
            -- PowerBar Anchor To dropdown
            local PowerBarAnchorTo = GUI:Create("Dropdown")
            PowerBarAnchorTo:SetLabel("Anchor To")
            PowerBarAnchorTo:SetList({
                ["TOPLEFT"] = "Top Left",
                ["TOP"] = "Top",
                ["TOPRIGHT"] = "Top Right",
                ["LEFT"] = "Left",
                ["CENTER"] = "Center",
                ["RIGHT"] = "Right",
                ["BOTTOMLEFT"] = "Bottom Left",
                ["BOTTOM"] = "Bottom",
                ["BOTTOMRIGHT"] = "Bottom Right",
            })
            PowerBarAnchorTo:SetValue(PowerBar.AnchorTo or "BOTTOMLEFT")
            PowerBarAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.AnchorTo = value MilaUI:UpdateFrames() end)
            PowerBarAnchorTo:SetRelativeWidth(0.33)
            PowerBarPositioning:AddChild(PowerBarAnchorTo)
            
            -- PowerBar Anchor Parent input
            local PowerBarAnchorParent = GUI:Create("EditBox")
            PowerBarAnchorParent:SetLabel("Anchor Parent")
            PowerBarAnchorParent:SetText(PowerBar.AnchorParent or "UIParent")
            PowerBarAnchorParent:SetCallback("OnEnterPressed", function(widget, event, value) PowerBar.AnchorParent = value MilaUI:UpdateFrames() end)
            PowerBarAnchorParent:SetRelativeWidth(0.33)
            PowerBarPositioning:AddChild(PowerBarAnchorParent)
            
            -- PowerBar X Position slider
            local PowerBarXPosition = GUI:Create("Slider")
            PowerBarXPosition:SetLabel("X Position")
            PowerBarXPosition:SetSliderValues(-999, 999, 0.1)
            PowerBarXPosition:SetValue(PowerBar.XPosition or 0)
            PowerBarXPosition:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.XPosition = value MilaUI:UpdateFrames() end)
            PowerBarXPosition:SetRelativeWidth(0.5)
            PowerBarPositioning:AddChild(PowerBarXPosition)
            
            -- PowerBar Y Position slider
            local PowerBarYPosition = GUI:Create("Slider")
            PowerBarYPosition:SetLabel("Y Position")
            PowerBarYPosition:SetSliderValues(-999, 999, 0.1)
            PowerBarYPosition:SetValue(PowerBar.YPosition or 0)
            PowerBarYPosition:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.YPosition = value MilaUI:UpdateFrames() end)
            PowerBarYPosition:SetRelativeWidth(0.5)
            PowerBarPositioning:AddChild(PowerBarYPosition)

            -- PowerBar Growth Direction
            local PowerBarGrowthDirection = GUI:Create("Dropdown")
            PowerBarGrowthDirection:SetLabel("Power Bar Growth Direction")
            PowerBarGrowthDirection:SetList({
                ["LR"] = "Left To Right",
                ["RL"] = "Right To Left",
            })
            PowerBarGrowthDirection:SetValue(PowerBar.Direction)
            PowerBarGrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Direction = value MilaUI:UpdateFrames() end)
            PowerBarGrowthDirection:SetRelativeWidth(0.33)
            scrollFrame:AddChild(PowerBarGrowthDirection)

            -- PowerBar Width
            local PowerBarWidth = GUI:Create("Slider")
            PowerBarWidth:SetLabel("Width")
            PowerBarWidth:SetSliderValues(1, 500, 1)
            PowerBarWidth:SetValue(PowerBar.Width)
            PowerBarWidth:SetCallback("OnMouseUp", function(widget, event, value) PowerBar.Width = value MilaUI:UpdateFrames() end)
            PowerBarWidth:SetRelativeWidth(0.5)
            scrollFrame:AddChild(PowerBarWidth)
            -- PowerBar Height
            local PowerBarHeight = GUI:Create("Slider")
            PowerBarHeight:SetLabel("Height")
            PowerBarHeight:SetSliderValues(1, 200, 1)
            PowerBarHeight:SetValue(PowerBar.Height)
            PowerBarHeight:SetCallback("OnMouseUp", function(widget, event, value) PowerBar.Height = value MilaUI:UpdateFrames() end)
            PowerBarHeight:SetRelativeWidth(0.5)
            scrollFrame:AddChild(PowerBarHeight)

            -- PowerBar Foreground Colour
            local PowerBarColour = GUI:Create("ColorPicker")
            PowerBarColour:SetLabel("Foreground Colour")
            local PBR, PBG, PBB, PBA = unpack(PowerBar.Colour or {1,1,1,1})
            PowerBarColour:SetColor(PBR, PBG, PBB, PBA)
            PowerBarColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            PowerBarColour:SetHasAlpha(true)
            PowerBarColour:SetRelativeWidth(0.25)
            scrollFrame:AddChild(PowerBarColour)

            -- PowerBar Background Colour
            local PowerBarBackdropColour = GUI:Create("ColorPicker")
            PowerBarBackdropColour:SetLabel("Background Colour")
            local PBGR, PBGB, PBGG, PBGA = unpack(PowerBar.BackgroundColour or {0,0,0,1})
            PowerBarBackdropColour:SetColor(PBGR, PBGB, PBGG, PBGA)
            PowerBarBackdropColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.BackgroundColour = {r, g, b, a} MilaUI:UpdateFrames() end)
            PowerBarBackdropColour:SetHasAlpha(true)
            PowerBarBackdropColour:SetRelativeWidth(0.25)
            scrollFrame:AddChild(PowerBarBackdropColour)

            -- Colour By Type
            local PowerBarColourByType = GUI:Create("CheckBox")
            PowerBarColourByType:SetLabel("Colour Bar By Type")
            PowerBarColourByType:SetValue(PowerBar.ColourByType)
            PowerBarColourByType:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.ColourByType = value MilaUI:UpdateFrames() end)
            PowerBarColourByType:SetRelativeWidth(0.25)
            scrollFrame:AddChild(PowerBarColourByType)

            -- Smooth
            local PowerBarSmooth = GUI:Create("CheckBox")
            PowerBarSmooth:SetLabel("Smooth")
            PowerBarSmooth:SetValue(PowerBar.Smooth)
            PowerBarSmooth:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Smooth = value MilaUI:UpdateFrames() end)
            PowerBarSmooth:SetRelativeWidth(0.33)
            scrollFrame:AddChild(PowerBarSmooth)

            -- Background Multiplier
            local BackgroundColourMultiplier = GUI:Create("Slider")
            BackgroundColourMultiplier:SetLabel("Background Multiplier")
            BackgroundColourMultiplier:SetSliderValues(0, 1, 0.01)
            BackgroundColourMultiplier:SetValue(PowerBar.BackgroundMultiplier)
            BackgroundColourMultiplier:SetCallback("OnMouseUp", function(widget, event, value) PowerBar.BackgroundMultiplier = value MilaUI:UpdateFrames() end)
            BackgroundColourMultiplier:SetRelativeWidth(0.5)
            scrollFrame:AddChild(BackgroundColourMultiplier)
        elseif tabKey == "Buffs" then
            local Buffs = MilaUI.DB.profile[dbUnitName].Buffs
            
            -- Buffs Options Group
            local BuffsOptions = GUI:Create("InlineGroup")
            BuffsOptions:SetLayout("Flow")
            BuffsOptions:SetTitle(pink .. "Buffs Options")
            BuffsOptions.titletext:SetFontObject(GameFontNormalLarge)
            BuffsOptions:SetFullWidth(true)
            scrollFrame:AddChild(BuffsOptions)
            
            -- Enable Buffs
            local BuffsEnabled = GUI:Create("CheckBox")
            BuffsEnabled:SetLabel("Enable Buffs")
            BuffsEnabled:SetValue(Buffs.Enabled)
            BuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Enabled = value MilaUI:UpdateFrames() end)
            BuffsEnabled:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(BuffsEnabled)
            
            -- Only Show Player Buffs
            local OnlyShowPlayer = GUI:Create("CheckBox")
            OnlyShowPlayer:SetLabel("Only Show Player Buffs")
            OnlyShowPlayer:SetValue(Buffs.OnlyShowPlayer)
            OnlyShowPlayer:SetCallback("OnValueChanged", function(widget, event, value) Buffs.OnlyShowPlayer = value MilaUI:UpdateFrames() end)
            OnlyShowPlayer:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(OnlyShowPlayer)
            
            -- Anchor From
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
            
            local BuffAnchorFrom = GUI:Create("Dropdown")
            BuffAnchorFrom:SetLabel("Anchor From")
            BuffAnchorFrom:SetList(AnchorPoints)
            BuffAnchorFrom:SetValue(Buffs.AnchorFrom)
            BuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorFrom = value MilaUI:UpdateFrames() end)
            BuffAnchorFrom:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(BuffAnchorFrom)
            
            -- Anchor To
            local BuffAnchorTo = GUI:Create("Dropdown")
            BuffAnchorTo:SetLabel("Anchor To")
            BuffAnchorTo:SetList(AnchorPoints)
            BuffAnchorTo:SetValue(Buffs.AnchorTo)
            BuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorTo = value MilaUI:UpdateFrames() end)
            BuffAnchorTo:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(BuffAnchorTo)
            
            -- Growth Direction X
            local GrowthX = {
                ["LEFT"] = "Left",
                ["RIGHT"] = "Right",
            }
            
            local BuffGrowthX = GUI:Create("Dropdown")
            BuffGrowthX:SetLabel("Growth Direction X")
            BuffGrowthX:SetList(GrowthX)
            BuffGrowthX:SetValue(Buffs.GrowthX)
            BuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthX = value MilaUI:UpdateFrames() end)
            BuffGrowthX:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(BuffGrowthX)
            
            -- Growth Direction Y
            local GrowthY = {
                ["UP"] = "Up",
                ["DOWN"] = "Down",
            }
            
            local BuffGrowthY = GUI:Create("Dropdown")
            BuffGrowthY:SetLabel("Growth Direction Y")
            BuffGrowthY:SetList(GrowthY)
            BuffGrowthY:SetValue(Buffs.GrowthY)
            BuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthY = value MilaUI:UpdateFrames() end)
            BuffGrowthY:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(BuffGrowthY)
            
            -- Size
            local BuffSize = GUI:Create("Slider")
            BuffSize:SetLabel("Size")
            BuffSize:SetSliderValues(1, 64, 1)
            BuffSize:SetValue(Buffs.Size)
            BuffSize:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Size = value MilaUI:UpdateFrames() end)
            BuffSize:SetRelativeWidth(0.33)
            BuffsOptions:AddChild(BuffSize)
            
            -- Spacing
            local BuffSpacing = GUI:Create("Slider")
            BuffSpacing:SetLabel("Spacing")
            BuffSpacing:SetSliderValues(0, 20, 1)
            BuffSpacing:SetValue(Buffs.Spacing)
            BuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Spacing = value MilaUI:UpdateFrames() end)
            BuffSpacing:SetRelativeWidth(0.33)
            BuffsOptions:AddChild(BuffSpacing)
            
            -- Number to Show
            local BuffNum = GUI:Create("Slider")
            BuffNum:SetLabel("Amount To Show")
            BuffNum:SetSliderValues(1, 40, 1)
            BuffNum:SetValue(Buffs.Num)
            BuffNum:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Num = value MilaUI:UpdateFrames() end)
            BuffNum:SetRelativeWidth(0.33)
            BuffsOptions:AddChild(BuffNum)
            
            -- X Offset
            local BuffXOffset = GUI:Create("Slider")
            BuffXOffset:SetLabel("X Offset")
            BuffXOffset:SetSliderValues(-50, 50, 1)
            BuffXOffset:SetValue(Buffs.XOffset)
            BuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.XOffset = value MilaUI:UpdateFrames() end)
            BuffXOffset:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(BuffXOffset)
            
            -- Y Offset
            local BuffYOffset = GUI:Create("Slider")
            BuffYOffset:SetLabel("Y Offset")
            BuffYOffset:SetSliderValues(-50, 50, 1)
            BuffYOffset:SetValue(Buffs.YOffset)
            BuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.YOffset = value MilaUI:UpdateFrames() end)
            BuffYOffset:SetRelativeWidth(0.5)
            BuffsOptions:AddChild(BuffYOffset)
            
        elseif tabKey == "Debuffs" then
            local Debuffs = MilaUI.DB.profile[dbUnitName].Debuffs
            
            -- Debuffs Options Group
            local DebuffsOptions = GUI:Create("InlineGroup")
            DebuffsOptions:SetLayout("Flow")
            DebuffsOptions:SetTitle(pink .. "Debuffs Options")
            DebuffsOptions.titletext:SetFontObject(GameFontNormalLarge)
            DebuffsOptions:SetFullWidth(true)
            scrollFrame:AddChild(DebuffsOptions)
            
            -- Enable Debuffs
            local DebuffsEnabled = GUI:Create("CheckBox")
            DebuffsEnabled:SetLabel("Enable Debuffs")
            DebuffsEnabled:SetValue(Debuffs.Enabled)
            DebuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Enabled = value MilaUI:UpdateFrames() end)
            DebuffsEnabled:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(DebuffsEnabled)
            
            -- Only Show Player Debuffs
            local OnlyShowPlayer = GUI:Create("CheckBox")
            OnlyShowPlayer:SetLabel("Only Show Player Debuffs")
            OnlyShowPlayer:SetValue(Debuffs.OnlyShowPlayer)
            OnlyShowPlayer:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.OnlyShowPlayer = value MilaUI:UpdateFrames() end)
            OnlyShowPlayer:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(OnlyShowPlayer)
            
            -- Anchor From
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
            
            local DebuffAnchorFrom = GUI:Create("Dropdown")
            DebuffAnchorFrom:SetLabel("Anchor From")
            DebuffAnchorFrom:SetList(AnchorPoints)
            DebuffAnchorFrom:SetValue(Debuffs.AnchorFrom)
            DebuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorFrom = value MilaUI:UpdateFrames() end)
            DebuffAnchorFrom:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(DebuffAnchorFrom)
            
            -- Anchor To
            local DebuffAnchorTo = GUI:Create("Dropdown")
            DebuffAnchorTo:SetLabel("Anchor To")
            DebuffAnchorTo:SetList(AnchorPoints)
            DebuffAnchorTo:SetValue(Debuffs.AnchorTo)
            DebuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorTo = value MilaUI:UpdateFrames() end)
            DebuffAnchorTo:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(DebuffAnchorTo)
            
            -- Growth Direction X
            local GrowthX = {
                ["LEFT"] = "Left",
                ["RIGHT"] = "Right",
            }
            
            local DebuffGrowthX = GUI:Create("Dropdown")
            DebuffGrowthX:SetLabel("Growth Direction X")
            DebuffGrowthX:SetList(GrowthX)
            DebuffGrowthX:SetValue(Debuffs.GrowthX)
            DebuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthX = value MilaUI:UpdateFrames() end)
            DebuffGrowthX:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(DebuffGrowthX)
            
            -- Growth Direction Y
            local GrowthY = {
                ["UP"] = "Up",
                ["DOWN"] = "Down",
            }
            
            local DebuffGrowthY = GUI:Create("Dropdown")
            DebuffGrowthY:SetLabel("Growth Direction Y")
            DebuffGrowthY:SetList(GrowthY)
            DebuffGrowthY:SetValue(Debuffs.GrowthY)
            DebuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthY = value MilaUI:UpdateFrames() end)
            DebuffGrowthY:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(DebuffGrowthY)
            
            -- Size
            local DebuffSize = GUI:Create("Slider")
            DebuffSize:SetLabel("Size")
            DebuffSize:SetSliderValues(1, 64, 1)
            DebuffSize:SetValue(Debuffs.Size)
            DebuffSize:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Size = value MilaUI:UpdateFrames() end)
            DebuffSize:SetRelativeWidth(0.33)
            DebuffsOptions:AddChild(DebuffSize)
            
            -- Spacing
            local DebuffSpacing = GUI:Create("Slider")
            DebuffSpacing:SetLabel("Spacing")
            DebuffSpacing:SetSliderValues(0, 20, 1)
            DebuffSpacing:SetValue(Debuffs.Spacing)
            DebuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Spacing = value MilaUI:UpdateFrames() end)
            DebuffSpacing:SetRelativeWidth(0.33)
            DebuffsOptions:AddChild(DebuffSpacing)
            
            -- Number to Show
            local DebuffNum = GUI:Create("Slider")
            DebuffNum:SetLabel("Amount To Show")
            DebuffNum:SetSliderValues(1, 40, 1)
            DebuffNum:SetValue(Debuffs.Num)
            DebuffNum:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Num = value MilaUI:UpdateFrames() end)
            DebuffNum:SetRelativeWidth(0.33)
            DebuffsOptions:AddChild(DebuffNum)
            
            -- X Offset
            local DebuffXOffset = GUI:Create("Slider")
            DebuffXOffset:SetLabel("X Offset")
            DebuffXOffset:SetSliderValues(-50, 50, 1)
            DebuffXOffset:SetValue(Debuffs.XOffset)
            DebuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.XOffset = value MilaUI:UpdateFrames() end)
            DebuffXOffset:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(DebuffXOffset)
            
            -- Y Offset
            local DebuffYOffset = GUI:Create("Slider")
            DebuffYOffset:SetLabel("Y Offset")
            DebuffYOffset:SetSliderValues(-50, 50, 1)
            DebuffYOffset:SetValue(Debuffs.YOffset)
            DebuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.YOffset = value MilaUI:UpdateFrames() end)
            DebuffYOffset:SetRelativeWidth(0.5)
            DebuffsOptions:AddChild(DebuffYOffset)
            
        elseif tabKey == "Indicators" then
            local label = GUI:Create("Label")
            label:SetText("Indicators options for " .. (L[unitName] or unitName))
            label:SetFullWidth(true)
            scrollFrame:AddChild(label)
            -- TODO: Add actual indicators options here
        end
    end)
    
    -- Select the default tab to display initial content
    tabGroup:SelectTab("Healthbar")

    -- powerGroup:SetLayout("Flow")
    -- scroll:AddChild(powerGroup)
        -- Add power bar options...

    -- ... and so on for Portrait, Castbar, Auras, Name, Texts, etc.

end

-- Draw the Unitframes -> General tab content
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
        -- Close and reopen the GUI properly
        MilaUI_CloseGUIMain()
        MilaUI_OpenGUIMain()
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

function MilaUI:DrawUnitframesColoursTab(parent)
    parent:ReleaseChildren()
    local General = MilaUI.DB.profile.UnitframesGeneral or MilaUI.DB.profile.General -- fallback if not split
    local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
    
    -- Create a single container for all content to ensure proper spacing
    local mainContainer = GUI:Create("SimpleGroup")
    mainContainer:SetLayout("Flow")
    mainContainer:SetFullWidth(true)
    mainContainer:SetFullHeight(true)
    parent:AddChild(mainContainer)
    
    -- Create the main container
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
        -- Close and reopen the GUI properly
        MilaUI_CloseGUIMain()
        MilaUI_OpenGUIMain()
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

function MilaUI:DrawUnitframesTabContent(container)
    container:ReleaseChildren()
    container:SetLayout("Fill")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    
    -- Create tree data
    local treeData = {}
    local unitFrameItems = {L.Player, L.Target, L.Focus, L.Pet, L.TargetTarget, L.FocusTarget, L.Boss}
    for _, key in ipairs(unitFrameItems) do
        table.insert(treeData, { text = key, value = key })
    end
    
    -- Create the TreeGroup - it has built-in tree and content areas
    local treeGroup = GUI:Create("TreeGroup")
    treeGroup:SetLayout("Fill")
    treeGroup:SetFullWidth(true)
    treeGroup:SetFullHeight(true)
    treeGroup:SetTree(treeData)
    container:AddChild(treeGroup)
    
    -- On selection, draw settings directly into the TreeGroup's content area
    treeGroup:SetCallback("OnGroupSelected", function(widget, _, unit)
        widget:ReleaseChildren() -- Clear the TreeGroup's content area
        MilaUI:DrawUnitContainer(widget, unit) -- Draw directly into the TreeGroup
        
        -- Force layout update after a short delay to fix positioning
        C_Timer.After(0.05, function()
            if widget and widget.frame then
                widget:DoLayout()
            end
        end)
    end)

    -- Initialize selection
    if #treeData > 0 then
        treeGroup:SelectByPath(treeData[1].value)
    end
    
    -- Force layout update for the container itself
    C_Timer.After(0.05, function()
        if container and container.frame then
            container:DoLayout()
        end
    end)
    
    -- Force layout update for the tree group
    C_Timer.After(0.05, function()
        if treeGroup and treeGroup.frame then
            treeGroup:DoLayout()
        end
    end)
end
