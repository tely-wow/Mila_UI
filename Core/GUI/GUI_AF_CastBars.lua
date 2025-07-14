local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")

-- Castbar list for the two-panel layout
local castbarItems = {
    {name = "General", tooltip = "General Settings", description = "Configure general castbar settings"},
    {name = "Player", tooltip = "Player Castbar", description = "Configure player castbar"},
    {name = "Target", tooltip = "Target Castbar", description = "Configure target castbar"},
    {name = "Focus", tooltip = "Focus Castbar", description = "Configure focus castbar"},
    {name = "Pet", tooltip = "Pet Castbar", description = "Configure pet castbar"},
    {name = "Boss", tooltip = "Boss Castbars", description = "Configure boss castbars"}
}

-- Create the castbars tab with two-panel layout
function MilaUI:CreateAFCastBarsLayout(parent)
    local container
    
    -- Create callback function that will have access to container variable
    local function onSelectionChanged(selectedId)
        if container and container.contentArea then
            MilaUI:HandleCastbarSelection(selectedId, container.contentArea)
        end
    end
    
    -- Create the container with the callback
    container = MilaUI.AF:CreateTwoPanelLayout(parent, castbarItems, "Settings", onSelectionChanged)
    
    -- Initialize with default content after container is fully created
    if container and container.contentArea then
        MilaUI:HandleCastbarSelection("General", container.contentArea)
    end
    
    return container
end

-- Handle castbar selection and load appropriate content
function MilaUI:HandleCastbarSelection(selectedId, contentArea)
    -- Clear existing content by hiding all children of scrollContent
    if contentArea.scrollContent then
        local children = {contentArea.scrollContent:GetChildren()}
        for _, child in ipairs(children) do
            if child then
                child:Hide()
            end
        end
    end
    
    -- Reset positioning
    MilaUI.AF:ResetPositioning()
    
    -- Load content based on selection
    if selectedId == "General" then
        MilaUI:CreateCastbarGeneralContent(contentArea.scrollContent)
    else
        MilaUI:CreateCastbarSpecificContent(contentArea.scrollContent, selectedId)
    end
    
    -- Calculate proper content height based on actual content
    local contentHeight = MilaUI.AF.currentY + 100
    contentArea:SetContentHeight(contentHeight)
    
    -- Force a refresh of the scroll frame
    if contentArea.UpdateScrollChildRect then
        contentArea:UpdateScrollChildRect()
    end
end

-- General castbar settings content
function MilaUI:CreateCastbarGeneralContent(parent)
    local section = MilaUI.AF.CreateBorderedSection(parent, "General Castbar Settings", 600)
    
    local label = AF.CreateFontString(section, "Configure general settings that apply to all castbars...", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
end

-- Specific castbar settings content with tabs
function MilaUI:CreateCastbarSpecificContent(parent, unitType)
    -- Create tab definitions
    local tabs = {
        {key = "general", display = "General", active = true},
        {key = "colors", display = "Colors", active = false},
        {key = "flash", display = "Flash Colors", active = false},
        {key = "textures", display = "Textures", active = false},
        {key = "icon", display = "Icon", active = false},
        {key = "text", display = "Text", active = false},
        {key = "spark", display = "Spark", active = false},
        {key = "advanced", display = "Advanced", active = false}
    }
    
    -- Current tab state
    local currentTab = "general"
    
    -- Tab switching function
    local function SwitchToTab(tabKey, tabObjects)
        if currentTab == tabKey then return end
        
        currentTab = tabKey
        
        -- Update visual tab states
        for i, tab in ipairs(tabs) do
            tab.active = (tab.key == tabKey)
            if tabObjects and tabObjects[i] then
                if tab.active then
                    tabObjects[i]:SetColor("pink")
                else
                    tabObjects[i]:SetColor("pink_transparent")
                end
            end
        end
        
        -- Refresh content in the scroll content area
        MilaUI:RefreshCastbarTabContent(parent, currentTab, unitType)
    end
    
    -- Find the actual scroll frame container (should be parent of scrollContent)
    local scrollContent = parent
    local scrollFrame = scrollContent:GetParent()
    local scrollContainer = scrollFrame:GetParent()
    
    -- Create tab system on the scroll container, moved up by tab height
    local tabFrame, tabObjects = MilaUI.AF:CreateTabSystem(scrollContainer, tabs)
    AF.SetPoint(tabFrame, "TOPLEFT", scrollContainer, "TOPLEFT", 0, 25)
    AF.SetPoint(tabFrame, "TOPRIGHT", scrollContainer, "TOPRIGHT", 0, 25)
    
    -- Set up tab callbacks after tab objects are created
    for i, tab in ipairs(tabs) do
        tab.callback = function()
            SwitchToTab(tab.key, tabObjects)
        end
    end
    
    -- Adjust the scroll frame to start below tabs
    AF.ClearPoints(scrollFrame)
    AF.SetPoint(scrollFrame, "TOPLEFT", scrollContainer, "TOPLEFT", 0, -35)
    AF.SetPoint(scrollFrame, "BOTTOMRIGHT", scrollContainer, "BOTTOMRIGHT", 0, 0)
    
    -- Store references
    scrollContainer.tabFrame = tabFrame
    scrollContainer.currentTab = currentTab
    
    -- Initialize with default content
    MilaUI:RefreshCastbarTabContent(parent, currentTab, unitType)
    
    return tabFrame
end

-- Refresh castbar tab content
function MilaUI:RefreshCastbarTabContent(scrollContent, selectedTab, unitType)
    -- Clear existing content by hiding all children
    local children = {scrollContent:GetChildren()}
    for _, child in ipairs(children) do
        if child then
            child:Hide()
        end
    end
    
    -- Reset positioning (start from top since tabs are outside)
    MilaUI.AF.currentY = 20
    
    -- Create content based on selected tab
    if selectedTab == "general" then
        MilaUI:CreateCastbarGeneralTabContent(scrollContent, unitType)
    elseif selectedTab == "colors" then
        MilaUI:CreateCastbarColorsTabContent(scrollContent, unitType)
    elseif selectedTab == "flash" then
        MilaUI:CreateCastbarFlashTabContent(scrollContent, unitType)
    elseif selectedTab == "textures" then
        MilaUI:CreateCastbarTexturesTabContent(scrollContent, unitType)
    elseif selectedTab == "icon" then
        MilaUI:CreateCastbarIconTabContent(scrollContent, unitType)
    elseif selectedTab == "text" then
        MilaUI:CreateCastbarTextTabContent(scrollContent, unitType)
    elseif selectedTab == "spark" then
        MilaUI:CreateCastbarSparkTabContent(scrollContent, unitType)
    elseif selectedTab == "advanced" then
        MilaUI:CreateCastbarAdvancedTabContent(scrollContent, unitType)
    end
end

-- Helper functions for castbar settings
local function GetCastbarSettings(unit)
    local profile = MilaUI.DB.profile
    if profile.castBars and profile.castBars[unit] then
        return profile.castBars[unit]
    end
    return nil
end

local function UpdateCastbarSetting(unit, setting, value)
    local castbarSettings = GetCastbarSettings(unit)
    if castbarSettings then
        if type(setting) == "table" then
            local current = castbarSettings
            for i = 1, #setting - 1 do
                if not current[setting[i]] then current[setting[i]] = {} end
                current = current[setting[i]]
            end
            current[setting[#setting]] = value
        else
            castbarSettings[setting] = value
        end
        
        -- Apply specific updates based on setting type
        if type(setting) == "table" and (setting[1] == "colors" or setting[1] == "flashColors") then
            if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
                MilaUI.NewCastbarSystem.UpdateCastBarColors(unit)
            end
        end
        
        -- Show castbar temporarily for preview when changing visual settings
        if type(setting) == "table" and (setting[1] == "textures" or setting[1] == "display" or setting[1] == "spark") then
            MilaUI:ShowCastbarPreview(unit)
        end
        
        MilaUI:RefreshCastbars()
    end
end

function MilaUI:ShowCastbarPreview(unit)
    local frame = nil
    if unit == "player" then
        frame = MilaUI.PlayerFrame
    elseif unit == "target" then
        frame = MilaUI.TargetFrame
    elseif unit == "focus" then
        frame = MilaUI.FocusFrame
    elseif unit == "pet" then
        frame = MilaUI.PetFrame
    elseif unit == "boss" then
        frame = MilaUI.BossFrames and MilaUI.BossFrames[1]
    end
    
    if frame and frame.castBar then
        frame.castBar:SetValue(0.6)
        frame.castBar:Show()
        -- Hide after 3 seconds
        C_Timer.After(3, function()
            if frame.castBar and not frame.castBar.casting then
                frame.castBar:Hide()
            end
        end)
    end
end

-- Castbar General Tab Content
function MilaUI:CreateCastbarGeneralTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- General Settings Section
    local generalSection = MilaUI.AF.CreateBorderedSection(parent, "General Settings", 140)
    
    local enabledCB = MilaUI.AF.CreateCheckbox(generalSection, "Enable Castbar", function(checked)
        UpdateCastbarSetting(unitKey, "enabled", checked)
    end)
    enabledCB:SetChecked(castbarSettings.enabled)
    MilaUI.AF.AddWidgetToSection(generalSection, enabledCB, 10, -25)
    
    local widthSlider = MilaUI.AF.CreateSlider(generalSection, "Width", 200, 50, 400, 1)
    widthSlider:SetValue(castbarSettings.size and castbarSettings.size.width or 200)
    widthSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"size", "width"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(generalSection, widthSlider, 10, -60)
    
    local heightSlider = MilaUI.AF.CreateSlider(generalSection, "Height", 200, 10, 50, 1)
    heightSlider:SetValue(castbarSettings.size and castbarSettings.size.height or 18)
    heightSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"size", "height"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(generalSection, heightSlider, 10, -95)
    
    local scaleSlider = MilaUI.AF.CreateSlider(generalSection, "Scale", 200, 0.5, 2.0, 0.1)
    scaleSlider:SetValue(castbarSettings.size and castbarSettings.size.scale or 1.0)
    scaleSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"size", "scale"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(generalSection, scaleSlider, 10, -130)
    
    -- Position Settings Section
    local positionSection = MilaUI.AF.CreateBorderedSection(parent, "Position Settings", 160)
    
    local anchorOptions = {
        {text = "Top", value = "TOP"},
        {text = "Bottom", value = "BOTTOM"},
        {text = "Left", value = "LEFT"},
        {text = "Right", value = "RIGHT"},
        {text = "Center", value = "CENTER"},
        {text = "Top Left", value = "TOPLEFT"},
        {text = "Top Right", value = "TOPRIGHT"},
        {text = "Bottom Left", value = "BOTTOMLEFT"},
        {text = "Bottom Right", value = "BOTTOMRIGHT"}
    }
    
    local anchorPointDD = MilaUI.AF.CreateDropdown(positionSection, "Anchor Point", anchorOptions)
    anchorPointDD:SetSelectedValue(castbarSettings.position and castbarSettings.position.anchorPoint or "CENTER")
    anchorPointDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"position", "anchorPoint"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorPointDD, 10, -25)
    
    local anchorToDD = MilaUI.AF.CreateDropdown(positionSection, "Anchor To", anchorOptions)
    anchorToDD:SetSelectedValue(castbarSettings.position and castbarSettings.position.anchorTo or "CENTER")
    anchorToDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"position", "anchorTo"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorToDD, 180, -25)
    
    local xOffsetSlider = MilaUI.AF.CreateSlider(positionSection, "X Offset", 200, -1000, 1000, 1)
    xOffsetSlider:SetValue(castbarSettings.position and castbarSettings.position.xOffset or 0)
    xOffsetSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"position", "xOffset"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(positionSection, xOffsetSlider, 10, -75)
    
    local yOffsetSlider = MilaUI.AF.CreateSlider(positionSection, "Y Offset", 200, -1000, 1000, 1)
    yOffsetSlider:SetValue(castbarSettings.position and castbarSettings.position.yOffset or -20)
    yOffsetSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"position", "yOffset"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(positionSection, yOffsetSlider, 10, -110)
    
    local anchorFrameInput = MilaUI.AF.CreateEditBox(positionSection, "Anchor Frame", 150)
    anchorFrameInput:SetText(castbarSettings.position and castbarSettings.position.anchorFrame or "MilaUI_Player")
    anchorFrameInput:SetOnEnterPressed(function(value)
        UpdateCastbarSetting(unitKey, {"position", "anchorFrame"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorFrameInput, 180, -75)
end

-- Castbar Colors Tab Content
function MilaUI:CreateCastbarColorsTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- Bar Color Settings Section
    local colorSection = MilaUI.AF.CreateBorderedSection(parent, "Bar Color Settings", 160)
    
    -- Cast Color
    local castColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Cast Color",
        function() return castbarSettings.colors and castbarSettings.colors.cast or {0, 1, 1, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"colors", "cast"}, color) end)
    MilaUI.AF.AddWidgetToSection(colorSection, castColorPicker, 10, -25)
    
    -- Channel Color
    local channelColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Channel Color",
        function() return castbarSettings.colors and castbarSettings.colors.channel or {0.5, 0.3, 0.9, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"colors", "channel"}, color) end)
    MilaUI.AF.AddWidgetToSection(colorSection, channelColorPicker, 180, -25)
    
    -- Uninterruptible Color
    local uninterruptibleColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Uninterruptible Color",
        function() return castbarSettings.colors and castbarSettings.colors.uninterruptible or {0.8, 0.8, 0.8, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"colors", "uninterruptible"}, color) end)
    MilaUI.AF.AddWidgetToSection(colorSection, uninterruptibleColorPicker, 10, -60)
    
    -- Interrupt Color
    local interruptColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Interrupt Color",
        function() return castbarSettings.colors and castbarSettings.colors.interrupt or {1, 0.2, 0.2, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"colors", "interrupt"}, color) end)
    MilaUI.AF.AddWidgetToSection(colorSection, interruptColorPicker, 180, -60)
    
    -- Completion Color
    local completionColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Completion Color",
        function() return castbarSettings.colors and castbarSettings.colors.completion or {0.2, 1.0, 1.0, 1.0} end,
        function(color) UpdateCastbarSetting(unitKey, {"colors", "completion"}, color) end)
    MilaUI.AF.AddWidgetToSection(colorSection, completionColorPicker, 10, -95)
end

-- Castbar Flash Colors Tab Content
function MilaUI:CreateCastbarFlashTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- Flash Color Settings Section
    local flashColorSection = MilaUI.AF.CreateBorderedSection(parent, "Flash Color Settings", 160)
    
    -- Cast Flash Color
    local castFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Cast Flash Color",
        function() return castbarSettings.flashColors and castbarSettings.flashColors.cast or {0.2, 0.8, 0.2, 1.0} end,
        function(color) UpdateCastbarSetting(unitKey, {"flashColors", "cast"}, color) end)
    MilaUI.AF.AddWidgetToSection(flashColorSection, castFlashColorPicker, 10, -25)
    
    -- Channel Flash Color
    local channelFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Channel Flash Color",
        function() return castbarSettings.flashColors and castbarSettings.flashColors.channel or {1.0, 0.4, 1.0, 0.9} end,
        function(color) UpdateCastbarSetting(unitKey, {"flashColors", "channel"}, color) end)
    MilaUI.AF.AddWidgetToSection(flashColorSection, channelFlashColorPicker, 180, -25)
    
    -- Uninterruptible Flash Color
    local uninterruptibleFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Uninterruptible Flash Color",
        function() return castbarSettings.flashColors and castbarSettings.flashColors.uninterruptible or {0.8, 0.8, 0.8, 0.9} end,
        function(color) UpdateCastbarSetting(unitKey, {"flashColors", "uninterruptible"}, color) end)
    MilaUI.AF.AddWidgetToSection(flashColorSection, uninterruptibleFlashColorPicker, 10, -60)
    
    -- Interrupt Flash Color (for glow effect)
    local interruptFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Interrupt Glow Color",
        function() return castbarSettings.flashColors and castbarSettings.flashColors.interrupt or {1, 1, 1, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"flashColors", "interrupt"}, color) end)
    MilaUI.AF.AddWidgetToSection(flashColorSection, interruptFlashColorPicker, 180, -60)
    
    -- Info label for flash colors
    local flashInfoLabel = AF.CreateFontString(flashColorSection, "Flash colors control the completion flash effect for each cast type", "gray")
    AF.SetFont(flashInfoLabel, nil, 10)
    MilaUI.AF.AddWidgetToSection(flashColorSection, flashInfoLabel, 10, -95)
end

-- Castbar Textures Tab Content
function MilaUI:CreateCastbarTexturesTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- Texture Settings Section
    local textureSection = MilaUI.AF.CreateBorderedSection(parent, "Texture Settings", 200)
    
    -- Get available textures from LSM
    local LSM = LibStub("LibSharedMedia-3.0")
    local textureList = LSM:List("statusbar")
    local textureOptions = {}
    
    for i, textureName in ipairs(textureList) do
        textureOptions[i] = {text = textureName, value = textureName}
    end
    
    -- Main Texture
    local mainTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Main Texture", textureOptions)
    mainTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.main or "Blizzard")
    mainTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "main"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, mainTextureDD, 10, -25)
    
    -- Cast Texture
    local castTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Cast Texture", textureOptions)
    castTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.cast or "Blizzard")
    castTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "cast"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, castTextureDD, 180, -25)
    
    -- Channel Texture
    local channelTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Channel Texture", textureOptions)
    channelTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.channel or "Blizzard")
    channelTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "channel"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, channelTextureDD, 10, -60)
    
    -- Uninterruptible Texture
    local uninterruptibleTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Uninterruptible Texture", textureOptions)
    uninterruptibleTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.uninterruptible or "Blizzard")
    uninterruptibleTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "uninterruptible"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, uninterruptibleTextureDD, 180, -60)
    
    -- Interrupt Texture
    local interruptTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Interrupt Texture", textureOptions)
    interruptTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.interrupt or "Blizzard")
    interruptTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "interrupt"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, interruptTextureDD, 10, -95)
    
    -- Cast Completion Texture
    local castCompletionTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Cast Completion Texture", textureOptions)
    castCompletionTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.castCompletion or "Blizzard")
    castCompletionTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "castCompletion"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, castCompletionTextureDD, 180, -95)
    
    -- Channel Completion Texture
    local channelCompletionTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Channel Completion Texture", textureOptions)
    channelCompletionTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.channelCompletion or "Blizzard")
    channelCompletionTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "channelCompletion"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, channelCompletionTextureDD, 10, -130)
    
    -- Spark Texture
    local sparkTextureDD = MilaUI.AF.CreateDropdown(textureSection, "Spark Texture", textureOptions)
    sparkTextureDD:SetSelectedValue(castbarSettings.textures and castbarSettings.textures.spark or "Blizzard")
    sparkTextureDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"textures", "spark"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textureSection, sparkTextureDD, 180, -130)
end

-- Castbar Icon Tab Content
function MilaUI:CreateCastbarIconTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- Icon Settings Section
    local iconSection = MilaUI.AF.CreateBorderedSection(parent, "Icon Settings", 140)
    
    local enableIconCB = MilaUI.AF.CreateCheckbox(iconSection, "Enable Icon", function(checked)
        UpdateCastbarSetting(unitKey, {"display", "icon", "show"}, checked)
    end)
    enableIconCB:SetChecked(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.show)
    MilaUI.AF.AddWidgetToSection(iconSection, enableIconCB, 10, -25)
    
    local iconSizeSlider = MilaUI.AF.CreateSlider(iconSection, "Icon Size", 200, 10, 100, 1)
    iconSizeSlider:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.size or 20)
    iconSizeSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"display", "icon", "size"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(iconSection, iconSizeSlider, 10, -60)
    
    local iconXOffsetSlider = MilaUI.AF.CreateSlider(iconSection, "Icon X Offset", 200, -50, 50, 1)
    iconXOffsetSlider:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.xOffset or 0)
    iconXOffsetSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"display", "icon", "xOffset"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(iconSection, iconXOffsetSlider, 10, -95)
    
    local iconYOffsetSlider = MilaUI.AF.CreateSlider(iconSection, "Icon Y Offset", 200, -50, 50, 1)
    iconYOffsetSlider:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.yOffset or 0)
    iconYOffsetSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"display", "icon", "yOffset"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(iconSection, iconYOffsetSlider, 180, -95)
end

-- Castbar Text Tab Content
function MilaUI:CreateCastbarTextTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- Text Settings Section
    local textSection = MilaUI.AF.CreateBorderedSection(parent, "Text Settings", 180)
    
    local enableTextCB = MilaUI.AF.CreateCheckbox(textSection, "Enable Text", function(checked)
        UpdateCastbarSetting(unitKey, {"display", "text", "show"}, checked)
    end)
    enableTextCB:SetChecked(castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.show)
    MilaUI.AF.AddWidgetToSection(textSection, enableTextCB, 10, -25)
    
    local showTimerCB = MilaUI.AF.CreateCheckbox(textSection, "Show Timer", function(checked)
        UpdateCastbarSetting(unitKey, {"display", "timer", "show"}, checked)
    end)
    showTimerCB:SetChecked(castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.show)
    MilaUI.AF.AddWidgetToSection(textSection, showTimerCB, 180, -25)
    
    local textSizeSlider = MilaUI.AF.CreateSlider(textSection, "Text Size", 200, 6, 32, 1)
    textSizeSlider:SetValue(castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.size or 12)
    textSizeSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"display", "text", "size"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textSection, textSizeSlider, 10, -60)
    
    local timerSizeSlider = MilaUI.AF.CreateSlider(textSection, "Timer Size", 200, 6, 32, 1)
    timerSizeSlider:SetValue(castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.size or 12)
    timerSizeSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"display", "timer", "size"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textSection, timerSizeSlider, 180, -60)
    
    -- Font flags
    local fontFlagOptions = {
        {text = "None", value = "NONE"},
        {text = "Outline", value = "OUTLINE"},
        {text = "Thick Outline", value = "THICKOUTLINE"},
        {text = "Monochrome", value = "MONOCHROME"}
    }
    
    local textFontFlagsDD = MilaUI.AF.CreateDropdown(textSection, "Text Font Flags", fontFlagOptions)
    textFontFlagsDD:SetSelectedValue(castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.fontFlags or "NONE")
    textFontFlagsDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"display", "text", "fontFlags"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textSection, textFontFlagsDD, 10, -95)
    
    local timerFontFlagsDD = MilaUI.AF.CreateDropdown(textSection, "Timer Font Flags", fontFlagOptions)
    timerFontFlagsDD:SetSelectedValue(castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.fontFlags or "NONE")
    timerFontFlagsDD:SetOnClick(function(value)
        UpdateCastbarSetting(unitKey, {"display", "timer", "fontFlags"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(textSection, timerFontFlagsDD, 180, -95)
    
    -- Text Color
    local textColorPicker = MilaUI.AF.CreateColorPicker(textSection, "Text Color",
        function() return castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.fontColor or {1, 1, 1, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"display", "text", "fontColor"}, color) end)
    MilaUI.AF.AddWidgetToSection(textSection, textColorPicker, 10, -130)
    
    -- Timer Color
    local timerColorPicker = MilaUI.AF.CreateColorPicker(textSection, "Timer Color",
        function() return castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.fontColor or {1, 1, 1, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"display", "timer", "fontColor"}, color) end)
    MilaUI.AF.AddWidgetToSection(textSection, timerColorPicker, 180, -130)
end

-- Castbar Spark Tab Content
function MilaUI:CreateCastbarSparkTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- Spark Settings Section
    local sparkSection = MilaUI.AF.CreateBorderedSection(parent, "Spark Settings", 160)
    
    local enableSparkCB = MilaUI.AF.CreateCheckbox(sparkSection, "Enable Spark", function(checked)
        UpdateCastbarSetting(unitKey, {"spark", "enabled"}, checked)
    end)
    enableSparkCB:SetChecked(castbarSettings.spark and castbarSettings.spark.enabled)
    MilaUI.AF.AddWidgetToSection(sparkSection, enableSparkCB, 10, -25)
    
    local sparkWidthSlider = MilaUI.AF.CreateSlider(sparkSection, "Spark Width", 200, 1, 50, 1)
    sparkWidthSlider:SetValue(castbarSettings.spark and castbarSettings.spark.width or 8)
    sparkWidthSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"spark", "width"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(sparkSection, sparkWidthSlider, 10, -60)
    
    local sparkHeightSlider = MilaUI.AF.CreateSlider(sparkSection, "Spark Height", 200, 1, 100, 1)
    sparkHeightSlider:SetValue(castbarSettings.spark and castbarSettings.spark.height or 20)
    sparkHeightSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, {"spark", "height"}, value)
    end)
    MilaUI.AF.AddWidgetToSection(sparkSection, sparkHeightSlider, 180, -60)
    
    -- Spark Color
    local sparkColorPicker = MilaUI.AF.CreateColorPicker(sparkSection, "Spark Color",
        function() return castbarSettings.spark and castbarSettings.spark.color or {1, 1, 1, 1} end,
        function(color) UpdateCastbarSetting(unitKey, {"spark", "color"}, color) end)
    MilaUI.AF.AddWidgetToSection(sparkSection, sparkColorPicker, 10, -95)
end

-- Castbar Advanced Tab Content
function MilaUI:CreateCastbarAdvancedTabContent(parent, unitType)
    local unitKey = unitType:lower()
    local castbarSettings = GetCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = AF.CreateFontString(parent, "Error: Castbar data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    -- Advanced Settings Section
    local advancedSection = MilaUI.AF.CreateBorderedSection(parent, "Advanced Settings", 200)
    
    local hideTradeSkillsCB = MilaUI.AF.CreateCheckbox(advancedSection, "Hide Trade Skills", function(checked)
        UpdateCastbarSetting(unitKey, "hideTradeSkills", checked)
    end)
    hideTradeSkillsCB:SetChecked(castbarSettings.hideTradeSkills)
    MilaUI.AF.AddWidgetToSection(advancedSection, hideTradeSkillsCB, 10, -25)
    
    local showBorderCB = MilaUI.AF.CreateCheckbox(advancedSection, "Show Border", function(checked)
        UpdateCastbarSetting(unitKey, "border", checked)
    end)
    showBorderCB:SetChecked(castbarSettings.border)
    MilaUI.AF.AddWidgetToSection(advancedSection, showBorderCB, 180, -25)
    
    local borderSizeSlider = MilaUI.AF.CreateSlider(advancedSection, "Border Size", 200, 0, 10, 1)
    borderSizeSlider:SetValue(castbarSettings.borderSize or 1)
    borderSizeSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, "borderSize", value)
    end)
    MilaUI.AF.AddWidgetToSection(advancedSection, borderSizeSlider, 10, -60)
    
    local holdTimeSlider = MilaUI.AF.CreateSlider(advancedSection, "Hold Time", 200, 0, 5, 0.1)
    holdTimeSlider:SetValue(castbarSettings.holdTime or 0.5)
    holdTimeSlider:SetAfterValueChanged(function(value)
        UpdateCastbarSetting(unitKey, "holdTime", value)
    end)
    MilaUI.AF.AddWidgetToSection(advancedSection, holdTimeSlider, 180, -60)
    
    -- Player-specific settings
    if unitKey == "player" then
        local showSafeZoneCB = MilaUI.AF.CreateCheckbox(advancedSection, "Show Safe Zone", function(checked)
            UpdateCastbarSetting(unitKey, "showSafeZone", checked)
        end)
        showSafeZoneCB:SetChecked(castbarSettings.showSafeZone)
        MilaUI.AF.AddWidgetToSection(advancedSection, showSafeZoneCB, 10, -95)
        
        local safeZoneColorPicker = MilaUI.AF.CreateColorPicker(advancedSection, "Safe Zone Color",
            function() return castbarSettings.safeZoneColor or {1, 0, 0, 0.5} end,
            function(color) UpdateCastbarSetting(unitKey, "safeZoneColor", color) end)
        MilaUI.AF.AddWidgetToSection(advancedSection, safeZoneColorPicker, 180, -95)
    end
    
    local showShieldCB = MilaUI.AF.CreateCheckbox(advancedSection, "Show Shield Icon", function(checked)
        UpdateCastbarSetting(unitKey, "showShield", checked)
    end)
    showShieldCB:SetChecked(castbarSettings.showShield)
    MilaUI.AF.AddWidgetToSection(advancedSection, showShieldCB, 10, -130)
end

-- Placeholder for the old function to maintain compatibility
function MilaUI:CreateAFCastbarsTab(parent)
    return MilaUI:CreateAFCastBarsLayout(parent)
end