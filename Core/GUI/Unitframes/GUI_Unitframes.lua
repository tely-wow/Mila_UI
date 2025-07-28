local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0") -- Direct reference to AceGUI
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
MilaUI.GUI = GUI
local unitSettingsContainer = nil


-- Create a global resize throttling system
if not MilaUI.resizeThrottle then
    MilaUI.resizeThrottle = {
        lastUpdate = 0,
        isUpdating = false,
        queue = {},
        frame = CreateFrame("Frame")
    }
    
    -- Set up the OnUpdate handler for processing the queue
    MilaUI.resizeThrottle.frame:SetScript("OnUpdate", function(self, elapsed)
        if MilaUI.resizeThrottle.isUpdating then return end
        
        local currentTime = GetTime()
        if currentTime - MilaUI.resizeThrottle.lastUpdate < 0.2 then return end
        
        if #MilaUI.resizeThrottle.queue > 0 then
            MilaUI.resizeThrottle.isUpdating = true
            
            local item = table.remove(MilaUI.resizeThrottle.queue, 1)
            if item and item.func then
                item.func()
            end
            
            MilaUI.resizeThrottle.lastUpdate = currentTime
            MilaUI.resizeThrottle.isUpdating = false
        end
    end)
    
    -- Function to add a layout update to the queue
    function MilaUI:QueueLayoutUpdate(func)
        if type(func) ~= "function" then return end
        
        table.insert(MilaUI.resizeThrottle.queue, {func = func})
    end
end

function MilaUI:DrawUnitframesGeneralTab(parent)
    local white = MilaUI.DB.global.Colors.white
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    parent:ReleaseChildren()
    local General = MilaUI.DB.profile.Unitframes.General
    local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
    local LSMTextures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
    

    -- Create a single container for all content to ensure proper spacing
    local mainContainer = GUI:Create("SimpleGroup")
    mainContainer:SetLayout("Flow")
    mainContainer:SetFullWidth(true)
    mainContainer:SetFullHeight(true)
    parent:AddChild(mainContainer)
    C_Timer.After(0.1, function()
        local p = parent
        while p and p.DoLayout do
            p:DoLayout()
            p = p.parent
        end
    end)
    -- Mouseover Highlight Options
    local MouseoverHighlight = General.MouseoverHighlight or {Enabled=false, Colour={1,1,1,1}, Style="BORDER"}
    
    -- Enable checkbox
    MilaUI:CreateLargeHeading("Mouseover Highlight", mainContainer)
    local enableCheckbox = MilaUI:CreateCheckBox("Enable Mouseover Highlight", 
        MouseoverHighlight and MouseoverHighlight.Enabled,
        function(widget, event, value) 
            MouseoverHighlight.Enabled = value 
            MilaUI:CreateReloadPrompt() 
            
            -- Enable or disable the color picker and style dropdown based on the checkbox state
            if colorPicker then colorPicker:SetDisabled(not value) end
            if styleDropdown then styleDropdown:SetDisabled(not value) end
        end,
        1, mainContainer)
    
    -- Color picker
    local colorPicker = MilaUI:CreateColorPicker(lavender .. "Color", 
        (MouseoverHighlight and MouseoverHighlight.Colour) or {1,1,1,1},
        function(widget, event, r, g, b, a) 
            MouseoverHighlight.Colour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end,
        0.2, true, mainContainer)
    
    -- Style dropdown
    local styleDropdown = MilaUI:Create("Dropdown")
    styleDropdown:SetLabel(lavender .. "Style")
    styleDropdown:SetList({
        ["BORDER"] = "Border",
        ["HIGHLIGHT"] = "Highlight",
    })
    styleDropdown:SetValue(MouseoverHighlight and MouseoverHighlight.Style)
    styleDropdown:SetCallback("OnValueChanged", function(widget, event, value) 
        MouseoverHighlight.Style = value 
        MilaUI:UpdateFrames() 
    end)
    styleDropdown:SetRelativeWidth(0.2)
    mainContainer:AddChild(styleDropdown)
        
    -- Set initial disabled state based on the checkbox value
    colorPicker:SetDisabled(not (MouseoverHighlight and MouseoverHighlight.Enabled))
    styleDropdown:SetDisabled(not (MouseoverHighlight and MouseoverHighlight.Enabled))
    
    MilaUI:CreateLargeHeading("Misc", mainContainer)
    -- Absorb Bar Texture Picker
    local AbsorbBarTexturePicker = GUI:Create("LSM30_Statusbar")
    AbsorbBarTexturePicker:SetLabel(lavender .. "Absorb Bar Texture")
    AbsorbBarTexturePicker:SetList(LSM:HashTable("statusbar"))
    AbsorbBarTexturePicker:SetValue(General.AbsorbTexture)
    AbsorbBarTexturePicker:SetRelativeWidth(0.4)
    AbsorbBarTexturePicker:SetCallback("OnValueChanged", function(widget, event, value)
        General.AbsorbTexture = value
        AbsorbBarTexturePicker:SetValue(value) -- Immediately update the dropdown value
        MilaUI:UpdateFrames()
    end)
    mainContainer:AddChild(AbsorbBarTexturePicker)
    
    -- Create the main container for color options
    MilaUI:CreateLargeHeading("Colour Options", mainContainer)
        -- Foreground Colour picker
        local ForegroundColourOptions = GUI:Create("InlineGroup")
        ForegroundColourOptions:SetTitle(pink .. "Foreground Colour")
        ForegroundColourOptions:SetLayout("Flow")
        ForegroundColourOptions:SetFullWidth(true)
        mainContainer:AddChild(ForegroundColourOptions)
        
        local ForegroundColour = GUI:Create("ColorPicker")
        ForegroundColour:SetLabel(lavender .. "Foreground Colour")
        local R, G, B, A = unpack(General.ForegroundColour or {1,1,1,1})
        ForegroundColour:SetColor(R, G, B, A)
        ForegroundColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) 
            General.ForegroundColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end)
        ForegroundColour:SetRelativeWidth(0.5)
        ForegroundColourOptions:AddChild(ForegroundColour)
        
        local ForegroundAlpha = GUI:Create("Slider")
        ForegroundAlpha:SetLabel(lavender .. "Alpha")
        ForegroundAlpha:SetSliderValues(0, 1, 0.01)
        ForegroundAlpha:SetValue(General.ForegroundColour and General.ForegroundColour[4] or 1)
        ForegroundAlpha:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ForegroundColour[4] = value 
            MilaUI:UpdateFrames() 
        end)
        ForegroundAlpha:SetRelativeWidth(0.5)
        ForegroundColourOptions:AddChild(ForegroundAlpha)
    
    local BorderColour = GUI:Create("ColorPicker")
    BorderColour:SetLabel(lavender .. "Border Colour")
    local R, G, B, A = unpack(General.BorderColour or {1,1,1,1})
    BorderColour:SetColor(R, G, B, A)
    BorderColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) 
        General.BorderColour = {r, g, b, a} 
        MilaUI:UpdateFrames() 
    end)
    BorderColour:SetRelativeWidth(0.5)
    ForegroundColourOptions:AddChild(BorderColour)
    
    local BorderAlpha = GUI:Create("Slider")
    BorderAlpha:SetLabel(lavender .. "Alpha")
    BorderAlpha:SetSliderValues(0, 1, 0.01)
    BorderAlpha:SetValue(General.BorderColour and General.BorderColour[4] or 1)
    BorderAlpha:SetCallback("OnValueChanged", function(widget, event, value) 
        General.BorderColour[4] = value 
        MilaUI:UpdateFrames() 
    end)
    BorderAlpha:SetRelativeWidth(0.5)
    ForegroundColourOptions:AddChild(BorderAlpha)
    
    -- Health colour checkboxes
    local ColourByClass = GUI:Create("CheckBox")
    ColourByClass:SetLabel("Use Class / Reaction Colour")
    ColourByClass:SetValue(General.ColourByClass)
    ColourByClass:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourByClass = value 
            MilaUI:UpdateFrames() 
        end)
    ColourByClass:SetRelativeWidth(0.5)
    ForegroundColourOptions:AddChild(ColourByClass)
    
    local ColourIfDisconnected = GUI:Create("CheckBox")
    ColourIfDisconnected:SetLabel("Use Disconnected Colour")
    ColourIfDisconnected:SetValue(General.ColourIfDisconnected)
    ColourIfDisconnected:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourIfDisconnected = value 
            MilaUI:UpdateFrames() 
        end)
    ColourIfDisconnected:SetRelativeWidth(0.5)
    ForegroundColourOptions:AddChild(ColourIfDisconnected)
    
    local ColourIfTapped = GUI:Create("CheckBox")
    ColourIfTapped:SetLabel("Use Tapped Colour")
    ColourIfTapped:SetValue(General.ColourIfTapped)
    ColourIfTapped:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourIfTapped = value 
            MilaUI:UpdateFrames() 
        end)
    ColourIfTapped:SetRelativeWidth(0.5)
    ForegroundColourOptions:AddChild(ColourIfTapped)
    
    -- Background Colour Options section
    local BackgroundColourOptions = GUI:Create("InlineGroup")
    BackgroundColourOptions:SetTitle(pink .. "Background Colour Options")
    BackgroundColourOptions:SetLayout("Flow")
    BackgroundColourOptions:SetFullWidth(true)
    mainContainer:AddChild(BackgroundColourOptions)
    local backgroundColorPicker = GUI:Create("ColorPicker")
    backgroundColorPicker:SetLabel(lavender .. "Background Colour")
    local R, G, B, A = unpack(General.BackgroundColour or {0,0,0,1})
    backgroundColorPicker:SetColor(R, G, B, A)
    backgroundColorPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) 
            General.BackgroundColour = {r, g, b, a} 
            MilaUI:UpdateFrames() 
        end)
    backgroundColorPicker:SetRelativeWidth(0.5)
    BackgroundColourOptions:AddChild(backgroundColorPicker)
    
    local BackgroundColourByForeground = GUI:Create("CheckBox")
    BackgroundColourByForeground:SetLabel("Colour By Foreground")
    BackgroundColourByForeground:SetValue(General.ColourBackgroundByForeground)
    BackgroundColourByForeground:SetCallback("OnValueChanged", function(widget, event, value) 
            General.ColourBackgroundByForeground = value 
            MilaUI:UpdateFrames() 
            if value then 
                BackgroundColourMultiplier:SetDisabled(false) 
                backgroundColorPicker:SetDisabled(true) -- Disable background color picker when using foreground color
            else 
                BackgroundColourMultiplier:SetDisabled(true) 
                backgroundColorPicker:SetDisabled(false) -- Enable background color picker when not using foreground color
            end 
        end)
    BackgroundColourByForeground:SetRelativeWidth(0.5)
    BackgroundColourOptions:AddChild(BackgroundColourByForeground)
    
    local BackgroundColourMultiplier = GUI:Create("Slider")
    BackgroundColourMultiplier:SetLabel(lavender .. "Multiplier")
    BackgroundColourMultiplier:SetValue(General.BackgroundMultiplier or 1)
    BackgroundColourMultiplier:SetCallback("OnValueChanged", function(widget, event, value) 
        General.BackgroundMultiplier = value 
        MilaUI:UpdateFrames() 
    end)
    BackgroundColourMultiplier:SetRelativeWidth(0.5)
    BackgroundColourOptions:AddChild(BackgroundColourMultiplier)

    -- Set initial disabled states based on current settings
    BackgroundColourMultiplier:SetDisabled(not General.ColourBackgroundByForeground)
    backgroundColorPicker:SetDisabled(General.ColourBackgroundByForeground)
    
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
        0.20, BackgroundColourOptions)
    
    MilaUI:CreateCheckBox("Colour By Class / Reaction", 
        General.ColourBackgroundByClass,
        function(widget, event, value) 
            General.ColourBackgroundByClass = value 
            MilaUI:UpdateFrames() 
        end,
        0.3, BackgroundColourOptions)
    
   
    -- Custom Colours
    MilaUI:CreateLargeHeading("Custom Colours", mainContainer)
    

    
    -- Power Colours
    local PowerColours = GUI:Create("InlineGroup")
    PowerColours:SetTitle(pink .. "Power Colours")
    PowerColours:SetLayout("Flow")
    PowerColours:SetFullWidth(true)
    mainContainer:AddChild(PowerColours)

    local PowerNames = {
        [0] = "Mana", 
        [1] = "Rage", 
        [2] = "Focus", 
        [3] = "Energy", 
        [6] = "Rune", 
        [8] = "Runic Power", 
        [11] = "Maelstrom", 
        [13] = "Insanity", 
        [17] = "Fury", 
        [18] = "Pain"
    }
    local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
    for _, powerType in ipairs(PowerOrder) do
        local powerColour = (General.CustomColours and General.CustomColours.Power and General.CustomColours.Power[powerType]) or {1,1,1}
        local PowerColour = GUI:Create("ColorPicker")
        PowerColour:SetLabel(lavender .. PowerNames[powerType] or tostring(powerType))
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
    mainContainer:AddChild(ReactionColours)

    local ReactionNames = {
        [1] = "Hated", 
        [2] = "Hostile", 
        [3] = "Unfriendly", 
        [4] = "Neutral", 
        [5] = "Friendly", 
        [6] = "Honored", 
        [7] = "Revered", 
        [8] = "Exalted"
    }
    for reactionType, reactionColour in pairs((General.CustomColours and General.CustomColours.Reaction) or {}) do
        local ReactionColour = GUI:Create("ColorPicker")
        ReactionColour:SetLabel(lavender .. ReactionNames[reactionType] or tostring(reactionType))
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
    mainContainer:AddChild(StatusColours)

    local StatusNames = {
        [1] = "Dead",
        [2] = "Tapped", 
        [3] = "Offline"
    }
    for statusType, statusColour in pairs((General.CustomColours and General.CustomColours.Status) or {}) do
        local StatusColour = GUI:Create("ColorPicker")
        StatusColour:SetLabel(lavender .. StatusNames[statusType] or tostring(statusType))
        local R, G, B = unpack(statusColour)
        StatusColour:SetColor(R, G, B)
        StatusColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
            if not General.CustomColours then General.CustomColours = {} end
            if not General.CustomColours.Status then General.CustomColours.Status = {} end
            General.CustomColours.Status[statusType] = {r, g, b}
            MilaUI:UpdateFrames()
        end)
        StatusColour:SetHasAlpha(false)
        StatusColour:SetRelativeWidth(0.25)
        StatusColours:AddChild(StatusColour)
    end
    local ResetCustomColoursButton = GUI:Create("Button")
    ResetCustomColoursButton:SetText(pink .. "Reset Custom Colours")
    ResetCustomColoursButton:SetCallback("OnClick", function(widget, event, value) 
        MilaUI:ResetColours() 
    end)
    ResetCustomColoursButton:SetRelativeWidth(1)
    mainContainer:AddChild(ResetCustomColoursButton)

end

function MilaUI:DrawUnitContainer(container, unitName, tabKey)
    local white = MilaUI.DB.global.Colors.white
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender

    -- Use pcall to safely release children
    local success, errorMsg = pcall(function()
        container:ReleaseChildren() -- Clear previous unit's settings
    end)
    
    -- Convert UI unit name to database key
    local dbUnitName = self:GetUnitDatabaseKey(unitName)
    
    -- Debug output to help troubleshoot
    if not MilaUI.DB.profile.Unitframes[dbUnitName] then
        print(pink .. "♥MILA UI ♥: " .. lavender .. "Error: Could not find settings for unit '" .. dbUnitName .. "'")
        return
    end

    --Enable / Disable Unit
    local EnableUnit = GUI:Create("CheckBox")
    EnableUnit:SetLabel("Enable Unit")
    EnableUnit:SetValue(MilaUI.DB.profile.Unitframes[dbUnitName].Frame.Enabled)
    EnableUnit:SetCallback("OnValueChanged", function(widget, event, value) MilaUI.DB.profile.Unitframes[dbUnitName].Frame.Enabled = value MilaUI:CreateReloadPrompt() end)
    EnableUnit:SetRelativeWidth(1)
    container:AddChild(EnableUnit)
    -- Create a tab group using AceGUI's built-in tab system
    local tabGroup = GUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    
    -- Store base tab names without colors
    local tabNames = {
        { text = "Healthbar", value = "Healthbar" },
        { text = "PowerBar", value = "PowerBar" },
        { text = "Castbar", value = "Castbar" },
        { text = "Buffs", value = "Buffs" },
        { text = "Debuffs", value = "Debuffs" },
        { text = "Indicators", value = "Indicators" },
        { text = "Text", value = "Text" },
    }
    
    -- Check if this unit has a clean castbar defined in the database
    local unitKey = dbUnitName:lower()
    if MilaUI.DB.profile.castBars and MilaUI.DB.profile.castBars[unitKey] then
        -- Add CleanCastbar tab after regular castbar
        table.insert(tabNames, 4, { text = "CleanCastbar", value = "CleanCastbar" })
    end
    
    -- Store current selected tab to prevent recursion
    local currentSelectedTab = "Healthbar"
    
    -- Function to update tab colors
    local function updateTabColors(selectedValue)
        if currentSelectedTab == selectedValue then return end -- Prevent unnecessary updates
        currentSelectedTab = selectedValue
        
        local coloredTabs = {}
        for i, tab in ipairs(tabNames) do
            local color = (tab.value == selectedValue) and pink or lavender
            coloredTabs[i] = { text = color .. tab.text, value = tab.value }
        end
        tabGroup:SetTabs(coloredTabs)
    end
    
    -- Set initial tabs with all lavender except first
    local initialTabs = {}
    for i, tab in ipairs(tabNames) do
        local color = (tab.value == "Healthbar") and pink or lavender
        initialTabs[i] = { text = color .. tab.text, value = tab.value }
    end
    tabGroup:SetTabs(initialTabs)
    
    -- Add the tab group to the container first
    container:AddChild(tabGroup)
    
    -- Set up the callback for tab selection - use a simple approach
    tabGroup:SetCallback("OnGroupSelected", function(widget, event, tabKey)
        -- Update tab colors when selection changes
        updateTabColors(tabKey)
        
        -- Use pcall to safely release children and catch any errors
        local success, errorMsg = pcall(function()
            widget:ReleaseChildren() -- Clear previous tab's content
        end)
        
        -- Create a simple container for the content
        local contentFrame = GUI:Create("SimpleGroup")
        contentFrame:SetLayout("Flow")
        contentFrame:SetFullWidth(true)
        contentFrame:SetFullHeight(true)
        
        -- Use pcall to safely add the child
        success, errorMsg = pcall(function()
            widget:AddChild(contentFrame)
        end)
        
        if tabKey == "Healthbar" then
            local General = MilaUI.DB.profile.Unitframes.General
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

            local Health = MilaUI.DB.profile.Unitframes[dbUnitName].Health
            local Frame = MilaUI.DB.profile.Unitframes[dbUnitName].Frame
            local HealthPrediction = MilaUI.DB.profile.Unitframes[dbUnitName].Health.HealthPrediction

            -- Texture and Border
            MilaUI:CreateLargeHeading("Texture and Border", contentFrame, 16)
            MilaUI:CreateVerticalSpacer(10, contentFrame)
            local TextureandBorder = GUI:Create("InlineGroup")
            TextureandBorder:SetLayout("Flow")
            TextureandBorder:SetRelativeWidth(1)

            local CustomMask = GUI:Create("CheckBox")
            CustomMask:SetLabel("Custom Mask")
            CustomMask:SetValue(Health.CustomMask and Health.CustomMask.Enabled)
            CustomMask:SetCallback("OnValueChanged", function(widget, event, value) Health.CustomMask.Enabled = value MilaUI:CreateReloadPrompt() end)
            CustomMask:SetRelativeWidth(0.5)
            TextureandBorder:AddChild(CustomMask)

            -- Custom Border
            local CustomBorder = GUI:Create("CheckBox")
            CustomBorder:SetLabel("Custom Border")
            CustomBorder:SetValue(Health.CustomBorder and Health.CustomBorder.Enabled)
            CustomBorder:SetCallback("OnValueChanged", function(widget, event, value) Health.CustomBorder.Enabled = value MilaUI:CreateReloadPrompt() end)
            CustomBorder:SetRelativeWidth(0.5)
            TextureandBorder:AddChild(CustomBorder)
            
            -- Health Texture Picker
            local HealthTexturePicker = GUI:Create("LSM30_Statusbar")
            HealthTexturePicker:SetLabel(lavender .. "Health Texture")
            HealthTexturePicker:SetList(LSM:HashTable("statusbar"))
            HealthTexturePicker:SetValue(Health.Texture)
            HealthTexturePicker:SetRelativeWidth(0.4)
            HealthTexturePicker:SetCallback("OnValueChanged", function(widget, event, value)
                Health.Texture = value
                HealthTexturePicker:SetValue(value)
                MilaUI:UpdateFrames()
            end)
            TextureandBorder:AddChild(HealthTexturePicker)
            MilaUI:CreateHorizontalSpacer(0.6, TextureandBorder)

            if dbUnitName == "Boss" then
                local DisplayFrames = GUI:Create("Button")
                DisplayFrames:SetText(pink .. "Display Frames")
                DisplayFrames:SetCallback("OnClick", function(widget, event, value) MilaUI.DB.profile.TestMode = not MilaUI.DB.profile.TestMode MilaUI:DisplayBossFrames() MilaUI:UpdateFrames() end)
                DisplayFrames:SetRelativeWidth(0.25)
                TextureandBorder:AddChild(DisplayFrames)
                if not Frame.Enabled then DisplayFrames:SetDisabled(true) end
            end

            if dbUnitName == "Boss" then
                local FrameSpacing = GUI:Create("Slider")
                FrameSpacing:SetLabel(lavender .. "Frame Spacing")
                FrameSpacing:SetSliderValues(-999, 999, 0.1)
                FrameSpacing:SetValue(Frame.Spacing)
                FrameSpacing:SetCallback("OnMouseUp", function(widget, event, value) Frame.Spacing = value MilaUI:UpdateFrames() end)
                FrameSpacing:SetRelativeWidth(0.25)
                TextureandBorder:AddChild(FrameSpacing)

                local GrowthDirection = GUI:Create("Dropdown")
                GrowthDirection:SetLabel(lavender .. "Growth Direction")
                GrowthDirection:SetList({
                    ["DOWN"] = "Down",
                    ["UP"] = "Up",
                })
                GrowthDirection:SetValue(Frame.GrowthY)
                GrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) Frame.GrowthY = value MilaUI:UpdateFrames() end)
                GrowthDirection:SetRelativeWidth(0.25)
                TextureandBorder:AddChild(GrowthDirection)
            end
            contentFrame:AddChild(TextureandBorder)
            MilaUI:CreateLargeHeading("Heal Prediction", contentFrame)
            
            local AbsorbsContainer = GUI:Create("InlineGroup")
            local HealPrediction = GUI:Create("CheckBox")
            HealPrediction:SetLabel("Enable Heal Prediction")
            HealPrediction:SetValue(HealthPrediction.Enabled)
            HealPrediction:SetCallback("OnValueChanged", function(widget, event, value) HealthPrediction.Enabled = value MilaUI:UpdateFrames() end)
            HealPrediction:SetRelativeWidth(1)
            contentFrame:AddChild(HealPrediction)
            AbsorbsContainer:SetTitle(lavender .. "Absorbs")
            AbsorbsContainer:SetLayout("Flow")
            AbsorbsContainer:SetRelativeWidth(0.5)
            contentFrame:AddChild(AbsorbsContainer)
        
            local AbsorbsEnabled = GUI:Create("CheckBox")
            AbsorbsEnabled:SetLabel("Enable Absorbs")
            AbsorbsEnabled:SetValue(HealthPrediction.Absorbs.Enabled)
            AbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) HealthPrediction.Absorbs.Enabled = value MilaUI:CreateReloadPrompt() end)
            AbsorbsEnabled:SetRelativeWidth(1)
            AbsorbsContainer:AddChild(AbsorbsEnabled)
        
            local AbsorbsColourPicker = GUI:Create("ColorPicker")
            AbsorbsColourPicker:SetLabel("Colour")
            local AR, AG, AB, AA = unpack(HealthPrediction.Absorbs.Colour)
            AbsorbsColourPicker:SetColor(AR, AG, AB, AA)
            AbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) HealthPrediction.Absorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            AbsorbsColourPicker:SetHasAlpha(true)
            AbsorbsColourPicker:SetRelativeWidth(1)
            AbsorbsContainer:AddChild(AbsorbsColourPicker)
        
            local HealAbsorbsContainer = GUI:Create("InlineGroup")
            HealAbsorbsContainer:SetTitle(lavender .. "Heal Absorbs")
            HealAbsorbsContainer:SetLayout("Flow")
            HealAbsorbsContainer:SetRelativeWidth(0.5)
            contentFrame:AddChild(HealAbsorbsContainer)
        
            local HealAbsorbsEnabled = GUI:Create("CheckBox")
            HealAbsorbsEnabled:SetLabel("Enable Heal Absorbs")
            HealAbsorbsEnabled:SetValue(HealthPrediction.HealAbsorbs.Enabled)
            HealAbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) HealthPrediction.HealAbsorbs.Enabled = value MilaUI:UpdateFrames() end)
            HealAbsorbsEnabled:SetRelativeWidth(1)
            HealAbsorbsContainer:AddChild(HealAbsorbsEnabled)
        
            local HealAbsorbsColourPicker = GUI:Create("ColorPicker")
            HealAbsorbsColourPicker:SetLabel("Colour")
            local HAR, HAG, HAB, HAA = unpack(HealthPrediction.HealAbsorbs.Colour)
            HealAbsorbsColourPicker:SetColor(HAR, HAG, HAB, HAA)
            HealAbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) HealthPrediction.HealAbsorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            HealAbsorbsColourPicker:SetHasAlpha(true)
            HealAbsorbsColourPicker:SetRelativeWidth(1)
            HealAbsorbsContainer:AddChild(HealAbsorbsColourPicker)

            -- Size and Position
            MilaUI:CreateLargeHeading("Size and Position", contentFrame)
            MilaUI:CreateVerticalSpacer(20, contentFrame)
            
            -- Create Size group
            local Size = GUI:Create("InlineGroup")
            Size:SetLayout("Flow")
            Size:SetRelativeWidth(0.5)
            Size:SetHeight(150)
            Size:SetAutoAdjustHeight(false)
            Size:SetTitle(lavender .. "Size")
            contentFrame:AddChild(Size)
            
            -- Create Position group
            local Position = GUI:Create("InlineGroup")
            Position:SetLayout("Flow")
            Position:SetRelativeWidth(0.5)
            Position:SetHeight(150)
            Position:SetAutoAdjustHeight(false)
            Position:SetTitle(lavender .. "Position")
            contentFrame:AddChild(Position)
            
            -- Create Anchor group
            local Anchor = GUI:Create("InlineGroup")
            Anchor:SetLayout("Flow")
            Anchor:SetFullWidth(true)
            Anchor:SetTitle(lavender .. "Anchor")
            contentFrame:AddChild(Anchor)
            -- Frame Scale
            local FrameScaleEnabled = GUI:Create("CheckBox")
            FrameScaleEnabled:SetLabel("Custom Scale")
            FrameScaleEnabled:SetValue(Frame.CustomScale)
            FrameScaleEnabled:SetCallback("OnValueChanged", function(widget, event, value) Frame.CustomScale = value MilaUI:UpdateFrameScale() end)
            FrameScaleEnabled:SetRelativeWidth(0.5)
            Size:AddChild(FrameScaleEnabled)
            local FrameScale = GUI:Create("Slider")
            FrameScale:SetLabel(white .. "Scale")
            FrameScale:SetSliderValues(0, 1, 0.01)
            FrameScale:SetValue(Frame.Scale)
            FrameScale:SetCallback("OnMouseUp", function(widget, event, value) Frame.Scale = value MilaUI:UpdateFrameScale() end)
            FrameScale:SetRelativeWidth(0.5)
            Size:AddChild(FrameScale)
            -- Frame Width
            local FrameWidth = GUI:Create("Slider")
            FrameWidth:SetLabel(white .. "Width")
            FrameWidth:SetSliderValues(1, 500, 1)
            FrameWidth:SetValue(Health.Width)
            FrameWidth:SetCallback("OnValueChanged", function(widget, event, value) 
                Health.Width = value 
                MilaUI:UpdateHealthBarSize(dbUnitName) 
            end)
            FrameWidth:SetRelativeWidth(0.5)
            Size:AddChild(FrameWidth)

            -- Frame Height
            local FrameHeight = GUI:Create("Slider")
            FrameHeight:SetLabel(white .. "Height")
            FrameHeight:SetSliderValues(1, 500, 1)
            FrameHeight:SetValue(Health.Height)
            FrameHeight:SetCallback("OnValueChanged", function(widget, event, value) 
                Health.Height = value 
                MilaUI:UpdateHealthBarSize(dbUnitName) 
            end)
            FrameHeight:SetRelativeWidth(0.5)
            Size:AddChild(FrameHeight)

            -- Frame X Position
            MilaUI:CreateVerticalSpacer(30, Position)
            local FrameXPosition = GUI:Create("Slider")
            FrameXPosition:SetLabel(white .. "Frame X Position")
            FrameXPosition:SetSliderValues(-999, 999, 0.1)
            FrameXPosition:SetValue(Frame.XPosition)
            FrameXPosition:SetCallback("OnValueChanged", function(widget, event, value) 
                Frame.XPosition = value 
                MilaUI:UpdateFramePosition(dbUnitName) 
            end)
            FrameXPosition:SetRelativeWidth(0.5)
            Position:AddChild(FrameXPosition)
            
            -- Frame Y Position
            local FrameYPosition = GUI:Create("Slider")
            FrameYPosition:SetLabel(white .. "Frame Y Position")
            FrameYPosition:SetSliderValues(-999, 999, 0.1)
            FrameYPosition:SetValue(Frame.YPosition)
            FrameYPosition:SetCallback("OnValueChanged", function(widget, event, value) 
                Frame.YPosition = value 
                MilaUI:UpdateFramePosition(dbUnitName) 
            end)
            FrameYPosition:SetRelativeWidth(0.5)
            Position:AddChild(FrameYPosition)
            
            -- Frame Anchor Parent
            local FrameAnchorParent = GUI:Create("EditBox")
            FrameAnchorParent:SetLabel(white .. "Anchor Parent")
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
            FrameAnchorParent:SetRelativeWidth(1)
            Anchor:AddChild(FrameAnchorParent)
            FrameAnchorParent:SetCallback("OnEnter", function(widget, event)
                GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")
                GameTooltip:AddLine("|cFF8080FFPLEASE NOTE|r: This will |cFFFF4040NOT|r work for WeakAuras.")
                GameTooltip:Show()
            end)
            FrameAnchorParent:SetCallback("OnLeave", function(widget, event) GameTooltip:Hide() end)

            -- Frame Anchor From
            local FrameAnchorFrom = GUI:Create("Dropdown")
            FrameAnchorFrom:SetLabel(white .. "Anchor From")
            FrameAnchorFrom:SetList(AnchorPoints)
            FrameAnchorFrom:SetValue(Frame.AnchorFrom)
            FrameAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorFrom = value MilaUI:UpdateFrames() end)
            FrameAnchorFrom:SetRelativeWidth(0.5)
            Anchor:AddChild(FrameAnchorFrom)

            -- Frame Anchor To
            local FrameAnchorTo = GUI:Create("Dropdown")
            FrameAnchorTo:SetLabel(white .. "Anchor To")
            FrameAnchorTo:SetList(AnchorPoints)
            FrameAnchorTo:SetValue(Frame.AnchorTo)
            FrameAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorTo = value MilaUI:UpdateFrames() end)
            FrameAnchorTo:SetRelativeWidth(0.5)
            Anchor:AddChild(FrameAnchorTo)
            C_Timer.After(0.1, function()
                local p = contentFrame
                while p and p.DoLayout do
                    p:DoLayout()
                    p = p.parent
                end
            end)
        elseif tabKey == "PowerBar" then
            local General = MilaUI.DB.profile.Unitframes.General
            local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
            local LSMTextures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
            local LSMFonts = LSM and LSM:HashTable(LSM.MediaType.FONT) or {}
            local PowerBar = MilaUI.DB.profile.Unitframes[dbUnitName].PowerBar

            -- Use the helper function to create a large heading
            MilaUI:CreateLargeHeading("Texture and Border", contentFrame)
            local texandborder = GUI:Create("InlineGroup")
            texandborder:SetLayout("Flow")
            texandborder:SetRelativeWidth(1)
            contentFrame:AddChild(texandborder)
            -- PowerBar Enabled
            local PowerBarEnabled = GUI:Create("CheckBox")
            PowerBarEnabled:SetLabel(lavender .. "PowerBar Enabled")
            PowerBarEnabled:SetValue(PowerBar.Enabled)
            PowerBarEnabled:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Enabled = value MilaUI:UpdateFrames() end)
            PowerBarEnabled:SetRelativeWidth(0.33)
            texandborder:AddChild(PowerBarEnabled)

            --PowerBar Custom Mask
            local PowerBarCustomMask = GUI:Create("CheckBox")
            PowerBarCustomMask:SetLabel(lavender .. "PowerBar Custom Mask")
            PowerBarCustomMask:SetValue(PowerBar.CustomMask.Enabled)
            PowerBarCustomMask:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.CustomMask.Enabled = value MilaUI:CreateReloadPrompt() end)
            PowerBarCustomMask:SetRelativeWidth(0.33)
            texandborder:AddChild(PowerBarCustomMask)

            local PowerBarCustomBorder = GUI:Create("CheckBox")
            PowerBarCustomBorder:SetLabel(lavender .. "PowerBar Custom Border")
            PowerBarCustomBorder:SetValue(PowerBar.CustomBorder.Enabled)
            PowerBarCustomBorder:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.CustomBorder.Enabled = value MilaUI:CreateReloadPrompt() end)
            PowerBarCustomBorder:SetRelativeWidth(0.33)
            texandborder:AddChild(PowerBarCustomBorder)

            -- Smooth
            local PowerBarSmooth = GUI:Create("CheckBox")
            PowerBarSmooth:SetLabel(lavender .. "Smooth")
            PowerBarSmooth:SetValue(PowerBar.Smooth)
            PowerBarSmooth:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Smooth = value MilaUI:UpdateFrames() end)
            PowerBarSmooth:SetRelativeWidth(0.33)
            texandborder:AddChild(PowerBarSmooth)

            -- PowerBar Texture Picker
            local PowerBarTexturePicker = GUI:Create("LSM30_Statusbar")
            PowerBarTexturePicker:SetLabel(lavender .. "Texture")
            PowerBarTexturePicker:SetList(LSM and LSM:HashTable("statusbar") or {})
            PowerBarTexturePicker:SetValue(PowerBar.Texture)
            PowerBarTexturePicker:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Texture = value MilaUI:UpdateFrames() end)
            PowerBarTexturePicker:SetRelativeWidth(0.4)
            texandborder:AddChild(PowerBarTexturePicker)

            -- PowerBar Positioning Group
            MilaUI:CreateLargeHeading("Size and Position", contentFrame)
            local Size = GUI:Create("InlineGroup")
            local Anchor = GUI:Create("InlineGroup")
            local Position = GUI:Create("InlineGroup")
            Size:SetLayout("Flow")
            Size:SetTitle(pink .. "Size")
            Size:SetRelativeWidth(0.5)
            
            contentFrame:AddChild(Size)
            
            Position:SetLayout("Flow")
            Position:SetTitle(pink .. "Position")
            Position:SetRelativeWidth(0.5)
            contentFrame:AddChild(Position)
            
            Anchor:SetLayout("Flow")
            Anchor:SetTitle(pink .. "Anchor")
            Anchor:SetFullWidth(true)
            contentFrame:AddChild(Anchor)
            
            
            -- PowerBar Width
            local PowerBarWidth = GUI:Create("Slider")
            PowerBarWidth:SetLabel(lavender .. "Width")
            PowerBarWidth:SetSliderValues(1, 500, 1)
            PowerBarWidth:SetValue(PowerBar.Width or 100)
            PowerBarWidth:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Width = value MilaUI:UpdateFrames() end)
            PowerBarWidth:SetRelativeWidth(0.5)
            Size:AddChild(PowerBarWidth)



            -- PowerBar Height
            local PowerBarHeight = GUI:Create("Slider")
            PowerBarHeight:SetLabel(lavender .. "Height")
            PowerBarHeight:SetSliderValues(1, 500, 1)
            PowerBarHeight:SetValue(PowerBar.Height or 10)
            PowerBarHeight:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Height = value MilaUI:UpdateFrames() end)
            PowerBarHeight:SetRelativeWidth(0.5)
            Size:AddChild(PowerBarHeight)

            -- PowerBar X Position slider
            local PowerBarXPosition = GUI:Create("Slider")
            PowerBarXPosition:SetLabel(lavender .. "X Position")
            PowerBarXPosition:SetSliderValues(-999, 999, 0.1)
            PowerBarXPosition:SetValue(PowerBar.XPosition or 0)
            PowerBarXPosition:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.XPosition = value MilaUI:UpdateFrames() end)
            PowerBarXPosition:SetRelativeWidth(0.5)
            Position:AddChild(PowerBarXPosition)

            -- PowerBar Y Position slider
            local PowerBarYPosition = GUI:Create("Slider")
            PowerBarYPosition:SetLabel(lavender .. "Y Position")
            PowerBarYPosition:SetSliderValues(-999, 999, 0.1)
            PowerBarYPosition:SetValue(PowerBar.YPosition or 0)
            PowerBarYPosition:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.YPosition = value MilaUI:UpdateFrames() end)
            PowerBarYPosition:SetRelativeWidth(0.5)
            Position:AddChild(PowerBarYPosition)

            -- PowerBar Anchor Parent input
            local PowerBarAnchorParent = GUI:Create("EditBox")
            PowerBarAnchorParent:SetLabel(lavender .. "Anchor Parent")
            PowerBarAnchorParent:SetText(PowerBar.AnchorParent or "UIParent")
            PowerBarAnchorParent:SetCallback("OnEnterPressed", function(widget, event, value) PowerBar.AnchorParent = value MilaUI:UpdateFrames() end)
            PowerBarAnchorParent:SetRelativeWidth(0.5)
            Anchor:AddChild(PowerBarAnchorParent)

            -- PowerBar Anchor From dropdown
            local PowerBarAnchorFrom = GUI:Create("Dropdown")
            PowerBarAnchorFrom:SetLabel(lavender .. "Anchor From")
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
            PowerBarAnchorFrom:SetRelativeWidth(0.5)
            Anchor:AddChild(PowerBarAnchorFrom)
            
            -- PowerBar Growth Direction
            local PowerBarGrowthDirection = GUI:Create("Dropdown")
            PowerBarGrowthDirection:SetLabel(lavender .. "Growth Direction")
            PowerBarGrowthDirection:SetList({
                ["LR"] = "Left To Right",
                ["RL"] = "Right To Left",
            })
            PowerBarGrowthDirection:SetValue(PowerBar.GrowthDirection or "LR")
            PowerBarGrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.GrowthDirection = value MilaUI:UpdateFrames() end)
            PowerBarGrowthDirection:SetRelativeWidth(0.5)
            Anchor:AddChild(PowerBarGrowthDirection)
            
            -- PowerBar Anchor To dropdown
            local PowerBarAnchorTo = GUI:Create("Dropdown")
            PowerBarAnchorTo:SetLabel(lavender .. "Anchor To")
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
            PowerBarAnchorTo:SetRelativeWidth(0.5)
            Anchor:AddChild(PowerBarAnchorTo)


            -- Add a new header for Colours
            MilaUI:CreateLargeHeading("Colours", contentFrame)
            local backgroundcolours = GUI:Create("InlineGroup")
            backgroundcolours:SetLayout("Flow")
            backgroundcolours:SetRelativeWidth(0.5)
            backgroundcolours:SetHeight(100)
            backgroundcolours:SetAutoAdjustHeight(false)
            backgroundcolours:SetTitle(pink .. "Background Colours")
            contentFrame:AddChild(backgroundcolours)
            local foregroundcolours = GUI:Create("InlineGroup")
            foregroundcolours:SetLayout("Flow")
            foregroundcolours:SetRelativeWidth(0.5)
            foregroundcolours:SetHeight(100)
            foregroundcolours:SetAutoAdjustHeight(false)
            foregroundcolours:SetTitle(pink .. "Foreground Colours")
            contentFrame:AddChild(foregroundcolours)
            
            -- Colour By Type
            local PowerBarColourByType = GUI:Create("CheckBox")
            PowerBarColourByType:SetLabel("Colour By Type")
            PowerBarColourByType:SetValue(PowerBar.ColourByType)
            PowerBarColourByType:SetCallback("OnValueChanged", function(widget, event, value) 
                PowerBar.ColourByType = value 
                MilaUI:UpdateFrames() 
                -- Disable foreground color picker when Colour By Type is selected
                PowerBarColour:SetDisabled(value)
            end)
            PowerBarColourByType:SetRelativeWidth(0.5)
            foregroundcolours:AddChild(PowerBarColourByType)
            -- PowerBar Foreground Colour
            local PowerBarColour = GUI:Create("ColorPicker")
            PowerBarColour:SetLabel("Foreground Colour")
            local PBR, PBG, PBB, PBA = unpack(PowerBar.Colour or {1,1,1,1})
            PowerBarColour:SetColor(PBR, PBG, PBB, PBA)
            PowerBarColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            PowerBarColour:SetHasAlpha(true)
            PowerBarColour:SetRelativeWidth(0.5)
            PowerBarColour:SetDisabled(PowerBar.ColourByType)
            foregroundcolours:AddChild(PowerBarColour)

            -- PowerBar Background Colour
            local PowerBarBackdropColour = GUI:Create("ColorPicker")
            PowerBarBackdropColour:SetLabel("Background Colour")
            local PBGR, PBGB, PBGG, PBGA = unpack(PowerBar.BackgroundColour or {0,0,0,1})
            PowerBarBackdropColour:SetColor(PBGR, PBGB, PBGG, PBGA)
            PowerBarBackdropColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.BackgroundColour = {r, g, b, a} MilaUI:UpdateFrames() end)
            PowerBarBackdropColour:SetHasAlpha(true)
            PowerBarBackdropColour:SetRelativeWidth(0.5)
            backgroundcolours:AddChild(PowerBarBackdropColour)

            -- Background Multiplier
            local BackgroundColourMultiplier = GUI:Create("Slider")
            BackgroundColourMultiplier:SetLabel(lavender .. "Background Multiplier")
            BackgroundColourMultiplier:SetSliderValues(0, 1, 0.01)
            BackgroundColourMultiplier:SetValue(PowerBar.BackgroundMultiplier or 0.5)
            BackgroundColourMultiplier:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.BackgroundMultiplier = value MilaUI:UpdateFrames() end)
            BackgroundColourMultiplier:SetRelativeWidth(0.5)
            backgroundcolours:AddChild(BackgroundColourMultiplier)

        elseif tabKey == "Castbar" then
            MilaUI:DrawCastbarContainer(dbUnitName, contentFrame)
        
        elseif tabKey == "CleanCastbar" then
            MilaUI:DrawCleanCastbarContainer(dbUnitName, contentFrame)

        elseif tabKey == "Buffs" then
            MilaUI:DrawBuffsContainer(dbUnitName, contentFrame)

        elseif tabKey == "Debuffs" then
            MilaUI:DrawDebuffsContainer(dbUnitName, contentFrame)
        elseif tabKey == "Indicators" then
            MilaUI:DrawIndicatorContainer(dbUnitName, contentFrame)
        elseif tabKey == "Text" then
            MilaUI:DrawUnitFrameTextOptions(contentFrame, unitName)
        end
        -- Queue a single layout update instead of doing it immediately
        -- This prevents layout thrashing during resize operations
        MilaUI:QueueLayoutUpdate(function()
            -- First update the content frame
            if contentFrame and contentFrame.DoLayout then
                contentFrame:DoLayout()
            end
            
            -- Update the tab widget
            if widget and widget.DoLayout then
                widget:DoLayout()
            end
        end)
        
        -- Run a recursive layout update after a short delay to ensure proper rendering
        C_Timer.After(0.1, function()
            local p = contentFrame
            while p and p.DoLayout do
                p:DoLayout()
                p = p.parent
            end
        end)
        
        -- Add a frame resize handler to the main frame if it doesn't exist
        if tabGroup and tabGroup.frame and not tabGroup.frame.resizeHandler then
            tabGroup.frame.resizeHandler = CreateFrame("Frame")
            tabGroup.frame.resizeHandler.elapsed = 0
            tabGroup.frame.resizeHandler.lastWidth = tabGroup.frame:GetWidth()
            tabGroup.frame.resizeHandler.lastHeight = tabGroup.frame:GetHeight()
            
            tabGroup.frame.resizeHandler:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed
                
                -- Only check every 0.2 seconds to avoid excessive updates
                if self.elapsed < 0.2 then return end
                self.elapsed = 0
                
                -- Check if the frame size has changed
                local currentWidth = tabGroup.frame:GetWidth()
                local currentHeight = tabGroup.frame:GetHeight()
                
                if currentWidth ~= self.lastWidth or currentHeight ~= self.lastHeight then
                    -- Queue a layout update
                    MilaUI:QueueLayoutUpdate(function()
                        if contentFrame and contentFrame.DoLayout then
                            contentFrame:DoLayout()
                        end
                        
                        if widget and widget.DoLayout then
                            widget:DoLayout()
                        end
                    end)
                    
                    -- Update the stored dimensions
                    self.lastWidth = currentWidth
                    self.lastHeight = currentHeight
                end
            end)
        end
    end)
    
    -- Select the default tab to display initial content
    tabGroup:SelectTab("Healthbar")
    
    -- Run a recursive layout update after a short delay to ensure proper rendering
    C_Timer.After(0.1, function()
        local p = tabGroup
        while p and p.DoLayout do
            p:DoLayout()
            p = p.parent
        end
    end)
    
    -- powerGroup:SetLayout("Flow")
    -- scroll:AddChild(powerGroup)
        -- Add power bar options...

    -- ... and so on for Portrait, Castbar, Auras, Name, Texts, etc.

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
    treeGroup:SetStatusTable({Units = true})
    container:AddChild(treeGroup)
    
    -- On selection, draw settings directly into the TreeGroup's content area
    treeGroup:SetCallback("OnGroupSelected", function(widget, _, unit)
        -- Use pcall to safely release children and catch any errors
        local success, errorMsg = pcall(function()
            widget:ReleaseChildren() -- Clear the TreeGroup's content area
        end)
        
        -- Use pcall to safely draw the unit container
        success, errorMsg = pcall(function()
            MilaUI:DrawUnitContainer(widget, unit) -- Draw directly into the TreeGroup
        end)
    end)
end