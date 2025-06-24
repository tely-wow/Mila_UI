local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")

-- Unit frame list for the two-panel layout
local unitFrameItems = {
    {name = "General", tooltip = "General Settings", description = "Configure general unit frame settings"},
    {name = "Player", tooltip = "Player Frame", description = "Configure player frame"},
    {name = "Target", tooltip = "Target Frame", description = "Configure target frame"},
    {name = "Focus", tooltip = "Focus Frame", description = "Configure focus frame"},
    {name = "Pet", tooltip = "Pet Frame", description = "Configure pet frame"},
    {name = "TargetTarget", tooltip = "Target of Target", description = "Configure target of target frame"},
    {name = "FocusTarget", tooltip = "Focus Target", description = "Configure focus target frame"},
    {name = "Boss", tooltip = "Boss Frames", description = "Configure boss frames"},
    {name = "Tags", tooltip = "Tags Settings", description = "Configure unit frame tags"}
}

-- Create the unit frames tab with two-panel layout
function MilaUI:CreateAFUnitFramesLayout(parent)
    local container
    
    -- Create callback function that will have access to container variable
    local function onSelectionChanged(selectedId)
        if container and container.contentArea then
            MilaUI:HandleUnitFrameSelection(selectedId, container.contentArea)
        end
    end
    
    -- Create the container with the callback
    container = MilaUI.AF:CreateTwoPanelLayout(parent, unitFrameItems, "Settings", onSelectionChanged)
    
    -- Initialize with default content after container is fully created
    if container and container.contentArea then
        MilaUI:HandleUnitFrameSelection("General", container.contentArea)
    end
    
    return container
end

-- Handle unit frame selection and load appropriate content
function MilaUI:HandleUnitFrameSelection(selectedId, contentArea)
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
        MilaUI:CreateUnitFrameGeneralContent(contentArea.scrollContent)
    elseif selectedId == "Tags" then
        MilaUI:CreateUnitFrameTagsContent(contentArea.scrollContent)
    else
        MilaUI:CreateUnitFrameSpecificContent(contentArea.scrollContent, selectedId)
    end
    
    -- Calculate proper content height based on actual content
    local contentHeight = MilaUI.AF.currentY + 100
    contentArea:SetContentHeight(contentHeight)
    
    -- Force a refresh of the scroll frame
    if contentArea.UpdateScrollChildRect then
        contentArea:UpdateScrollChildRect()
    end
end

-- General unit frame settings content
function MilaUI:CreateUnitFrameGeneralContent(parent)
    local section = MilaUI.AF.CreateBorderedSection(parent, "General Unit Frame Settings", 600)
    
    local label = AF.CreateFontString(section, "Configure general settings that apply to all unit frames...", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
end

-- Tags settings content
function MilaUI:CreateUnitFrameTagsContent(parent)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Unit Frame Tags", 600)
    
    local label = AF.CreateFontString(section, "Configure custom tags for unit frames...", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
end

-- Specific unit frame settings content with tabs
function MilaUI:CreateUnitFrameSpecificContent(parent, unitType)
    -- Create tab definitions
    local tabs = {
        {key = "healthbar", display = "Healthbar", active = true},
        {key = "powerbar", display = "PowerBar", active = false},
        {key = "castbar", display = "Castbar", active = false},
        {key = "buffs", display = "Buffs", active = false},
        {key = "debuffs", display = "Debuffs", active = false},
        {key = "indicators", display = "Indicators", active = false},
        {key = "text", display = "Text", active = false}
    }
    
    -- Current tab state
    local currentTab = "healthbar"
    
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
        MilaUI:RefreshUnitFrameTabContent(parent, currentTab, unitType)
    end
    
    -- Find the actual scroll frame container (should be parent of scrollContent)
    -- parent = scrollContent, parent:GetParent() = scrollFrame, parent:GetParent():GetParent() = scroll container
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
    MilaUI:RefreshUnitFrameTabContent(parent, currentTab, unitType)
    
    return tabFrame
end

-- Refresh unit frame tab content
function MilaUI:RefreshUnitFrameTabContent(scrollContent, selectedTab, unitType)
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
    if selectedTab == "healthbar" then
        MilaUI:CreateUnitFrameHealthbarTabContent(scrollContent, unitType)
    elseif selectedTab == "powerbar" then
        MilaUI:CreateUnitFramePowerBarTabContent(scrollContent, unitType)
    elseif selectedTab == "castbar" then
        MilaUI:CreateUnitFrameCastbarTabContent(scrollContent, unitType)
    elseif selectedTab == "buffs" then
        MilaUI:CreateUnitFrameBuffsTabContent(scrollContent, unitType)
    elseif selectedTab == "debuffs" then
        MilaUI:CreateUnitFrameDebuffsTabContent(scrollContent, unitType)
    elseif selectedTab == "indicators" then
        MilaUI:CreateUnitFrameIndicatorsTabContent(scrollContent, unitType)
    elseif selectedTab == "text" then
        MilaUI:CreateUnitFrameTextTabContent(scrollContent, unitType)
    end
end

-- Unit Frame General Tab Content
function MilaUI:CreateUnitFrameGeneralTabContent(parent, unitType)
    local dbUnitName = self:GetUnitDatabaseKey(unitType)
    
    if not MilaUI.DB.profile.Unitframes[dbUnitName] then
        local errorLabel = AF.CreateFontString(parent, "Error: Unit frame data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    local frameData = MilaUI.DB.profile.Unitframes[dbUnitName].Frame
    
    -- Enable/Disable Unit Frame (top level, no border)
    local enableCheckbox = MilaUI.AF.CreateCheckbox(parent, "Enable " .. unitType .. " Frame",
        function() return frameData.Enabled end,
        function(value)
            frameData.Enabled = value
            MilaUI.AF:CreateReloadPrompt()
        end)
    AF.SetPoint(enableCheckbox, "TOPLEFT", parent, "TOPLEFT", 10, -MilaUI.AF.currentY)
    MilaUI.AF.currentY = MilaUI.AF.currentY + 40
    
    -- Combined Settings Section (Scale + Position in one box)
    local settingsSection = MilaUI.AF.CreateBorderedSection(parent, "Frame Settings", 200)
    
    -- Scale settings (left side)
    local scaleCheckbox = MilaUI.AF.CreateCheckbox(settingsSection, "Enable Custom Scale",
        function() return frameData.CustomScale end,
        function(value)
            frameData.CustomScale = value
            MilaUI:UpdateFrameScale()
        end)
    MilaUI.AF.AddWidgetToSection(settingsSection, scaleCheckbox, 10, -30)
    
    local customScaleSlider = MilaUI.AF.CreateSlider(settingsSection, "Scale", 0.1, 2.0,
        function() return frameData.Scale or 1.0 end,
        function(value)
            frameData.Scale = value
            MilaUI:UpdateFrameScale()
        end, 0.01)
    MilaUI.AF.AddWidgetToSection(settingsSection, customScaleSlider, 10, -70)
    
    -- Position settings (right side)
    local xPosSlider = MilaUI.AF.CreateSlider(settingsSection, "X Position", -999, 999,
        function() return frameData.XPosition or 0 end,
        function(value)
            frameData.XPosition = value
            MilaUI:UpdateFramePosition(dbUnitName)
        end, 0.1)
    MilaUI.AF.AddWidgetToSection(settingsSection, xPosSlider, 180, -30)
    
    local yPosSlider = MilaUI.AF.CreateSlider(settingsSection, "Y Position", -999, 999,
        function() return frameData.YPosition or 0 end,
        function(value)
            frameData.YPosition = value
            MilaUI:UpdateFramePosition(dbUnitName)
        end, 0.1)
    MilaUI.AF.AddWidgetToSection(settingsSection, yPosSlider, 180, -70)
end

-- Tab content functions using AbstractFramework
function MilaUI:CreateUnitFrameHealthbarTabContent(parent, unitType)
    local dbUnitName = self:GetUnitDatabaseKey(unitType)
    
    if not MilaUI.DB.profile.Unitframes[dbUnitName] then
        local errorLabel = AF.CreateFontString(parent, "Error: Unit frame data not found for " .. unitType, "red")
        AF.SetPoint(errorLabel, "TOPLEFT", parent, "TOPLEFT", 20, -20)
        return
    end
    
    local frameData = MilaUI.DB.profile.Unitframes[dbUnitName].Frame
    local generalData = MilaUI.DB.profile.Unitframes.General
    
    -- Enable/Disable Unit Frame (top level, no border, moved up)
    local enableCheckbox = MilaUI.AF.CreateCheckbox(parent, "Enable " .. unitType .. " Frame",
        function() return frameData.Enabled end,
        function(value)
            frameData.Enabled = value
            MilaUI.AF:CreateReloadPrompt()
        end)
    AF.SetPoint(enableCheckbox, "TOPLEFT", parent, "TOPLEFT", 10, -MilaUI.AF.currentY + 15)
    MilaUI.AF.currentY = MilaUI.AF.currentY -15

    -- Get healthbar data at the top so it's available for all sections
    local healthData = MilaUI.DB.profile.Unitframes[dbUnitName].Health

    -- Size Box (left side) - same width as Texture box but original height
    local sizeSection = MilaUI.AF.CreateBorderedSection(parent, "Size", 280, 170)
    AF.SetPoint(sizeSection, "TOPLEFT", enableCheckbox, "TOPLEFT", 10, -40)
    
    -- Store the Y position for the Appearance box
    local currentRowY = MilaUI.AF.currentY
    
    -- Width and Height sliders first
    if healthData then
        local healthWidthSlider = MilaUI.AF.CreateSlider(sizeSection, "Width", 50, 500,
            function() return healthData.Width or 200 end,
            function(value)
                healthData.Width = value
                MilaUI:UpdateFrames(unitType)
            end, 1, 140)
        MilaUI.AF.AddWidgetToSection(sizeSection, healthWidthSlider, 10, -30)
        
        local healthHeightSlider = MilaUI.AF.CreateSlider(sizeSection, "Height", 5, 50,
            function() return healthData.Height or 20 end,
            function(value)
                healthData.Height = value
                MilaUI:UpdateFrames(unitType)
            end, 1, 140)
        MilaUI.AF.AddWidgetToSection(sizeSection, healthHeightSlider, 10, -70)
    end
    
    -- Custom scale settings below width and height
    local scaleCheckbox = MilaUI.AF.CreateCheckbox(sizeSection, "Enable Custom Scale",
        function() return frameData.CustomScale end,
        function(value)
            frameData.CustomScale = value
            MilaUI:UpdateFrameScale()
        end)
    MilaUI.AF.AddWidgetToSection(sizeSection, scaleCheckbox, 10, -110)
    
    local scaleSlider = MilaUI.AF.CreateSlider(sizeSection, "Scale", 0.1, 2.0,
        function() return frameData.Scale or 1.0 end,
        function(value)
            frameData.Scale = value
            MilaUI:UpdateFrameScale()
        end, 0.01, 140)
    MilaUI.AF.AddWidgetToSection(sizeSection, scaleSlider, 10, -150)

    -- Texture Box (right side)
    local textureSection = MilaUI.AF.CreateBorderedSection(parent, "Texture", 280, 200)
    AF.SetPoint(textureSection, "TOPLEFT", sizeSection, "TOPRIGHT", 10, 0)
    
    if healthData then
        -- Foreground Texture Picker
        local LSM = LibStub("LibSharedMedia-3.0", true)
        if LSM then
            local textureDropdown = AF.CreateDropdown(textureSection, 150, 10, "texture")
            textureDropdown:SetLabel("Foreground Texture")
            
            local textureOptions = {}
            local textures, textureNames = LSM:HashTable("statusbar"), LSM:List("statusbar")
            for _, name in ipairs(textureNames) do
                tinsert(textureOptions, {
                    text = name,
                    texture = textures[name]
                })
            end
            textureDropdown:SetItems(textureOptions)
            
            -- Set current value and callback
            textureDropdown:SetSelectedValue(healthData.Texture or "Interface\\TargetingFrame\\UI-StatusBar")
            textureDropdown:SetOnClick(function(value)
                healthData.Texture = value
                MilaUI:UpdateFrames(unitType)
            end)
            
            MilaUI.AF.AddWidgetToSection(textureSection, textureDropdown, 10, -30)
            
            -- Background Texture Picker
            local backgroundTextureDropdown = AF.CreateDropdown(textureSection, 150, 10, "texture")
            backgroundTextureDropdown:SetLabel("Background Texture")
            backgroundTextureDropdown:SetItems(textureOptions)
            
            -- Set current value and callback for background texture
            backgroundTextureDropdown:SetSelectedValue(healthData.BackgroundTexture or "Interface\\TargetingFrame\\UI-StatusBar")
            backgroundTextureDropdown:SetOnClick(function(value)
                healthData.BackgroundTexture = value
                MilaUI:UpdateFrames(unitType)
            end)
            
            MilaUI.AF.AddWidgetToSection(textureSection, backgroundTextureDropdown, 10, -70)
        else
            local textureLabel = AF.CreateFontString(textureSection, "LibSharedMedia not found", "red")
            MilaUI.AF.AddWidgetToSection(textureSection, textureLabel, 10, -30)
        end
        
        -- Smooth Statusbar checkbox
        local smoothCheckbox = MilaUI.AF.CreateCheckbox(textureSection, "Smooth Statusbar",
            function() return healthData.Smooth end,
            function(value)
                healthData.Smooth = value
                MilaUI:UpdateFrames(unitType)
            end)
        MilaUI.AF.AddWidgetToSection(textureSection, smoothCheckbox, 10, -110)
        
        -- Custom Mask checkbox
        local customMaskData = healthData.CustomMask or {}
        local maskEnabledCheckbox = MilaUI.AF.CreateCheckbox(textureSection, "Enable Custom Mask",
            function() return customMaskData.Enabled end,
            function(value)
                if not healthData.CustomMask then healthData.CustomMask = {} end
                healthData.CustomMask.Enabled = value
                MilaUI:UpdateFrames(unitType)
            end)
        MilaUI.AF.AddWidgetToSection(textureSection, maskEnabledCheckbox, 10, -150)
        
        -- Custom Border checkbox
        local customBorderData = healthData.CustomBorder or {}
        local borderEnabledCheckbox = MilaUI.AF.CreateCheckbox(textureSection, "Enable Custom Border",
            function() return customBorderData.Enabled end,
            function(value)
                if not healthData.CustomBorder then healthData.CustomBorder = {} end
                healthData.CustomBorder.Enabled = value
                MilaUI:UpdateFrames(unitType)
            end)
        MilaUI.AF.AddWidgetToSection(textureSection, borderEnabledCheckbox, 10, -190)
    end
    
    -- Colors Box (below Size box) - anchored to bottom left of Size box, 4x width of Size box
    local colorsSection = MilaUI.AF.CreateBorderedSection(parent, "Colors", 300, 350)
    AF.SetPoint(colorsSection, "TOPLEFT", sizeSection, "BOTTOMLEFT", 0, -20)
    
    -- Get color data from the new structure
    local colorData = healthData.Colors or {}
    
    -- First column - Foreground colors
    local fgLabel = AF.CreateFontString(colorsSection, AF.GetGradientText("Foreground", "pink", "hotpink"))
    AF.SetPoint(fgLabel, "CENTER", colorsSection, "TOP", 0, -25)
    
    -- Color by Class checkbox
    local colorByClassCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Class",
        function() return colorData.ColourByClass end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColourByClass = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, colorByClassCheckbox, 35, -50)
    
    -- Color by Reaction checkbox
    local colorByReactionCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Reaction",
        function() return colorData.ColourByReaction end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColourByReaction = value
            MilaUI:UpdateFrames(unitType)
            end)
        MilaUI.AF.AddWidgetToSection(colorsSection, colorByReactionCheckbox, 35, -80)
    
    -- Pre-declare color pickers so we can reference them in the checkbox callbacks
    local disconnectedColorPicker
    local tappedColorPicker
    
    -- Color if Disconnected checkbox and color picker
    local colorIfDisconnectedCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color if Disconnected",
        function() return colorData.ColourIfDisconnected end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColourIfDisconnected = value
            -- Enable/disable the disconnected color picker based on checkbox value
            if disconnectedColorPicker then
                disconnectedColorPicker:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, colorIfDisconnectedCheckbox, 35, -120)
    
    disconnectedColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Disconnected",
        function() 
            local status = colorData.Status or {}
            return status[3] or {0.6, 0.6, 0.6}
        end,
        function(color)
            if not healthData.Colors then healthData.Colors = {} end
            if not healthData.Colors.Status then healthData.Colors.Status = {} end
            healthData.Colors.Status[3] = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, disconnectedColorPicker, 220, -120)
    
    -- Set initial enabled state based on checkbox value
    disconnectedColorPicker:SetEnabled(colorData.ColourIfDisconnected or false)
    
    -- Color if Tapped checkbox
    local colorIfTappedCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color if Tapped",
        function() return colorData.ColourIfTapped end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColourIfTapped = value
            -- Enable/disable the tapped color picker based on checkbox value
            if tappedColorPicker then
                tappedColorPicker:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, colorIfTappedCheckbox, 35, -160)
    
    -- Tapped color picker - positioned right next to its checkbox
    tappedColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Tapped",
        function() 
            local status = colorData.Status or {}
            return status[2] or {153/255, 153/255, 153/255}
        end,
        function(color)
            if not healthData.Colors then healthData.Colors = {} end
            if not healthData.Colors.Status then healthData.Colors.Status = {} end
            healthData.Colors.Status[2] = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, tappedColorPicker, 220, -160)
    
    -- Set initial enabled state based on checkbox value
    tappedColorPicker:SetEnabled(colorData.ColourIfTapped or false)
    
    -- Pre-declare foregroundColorPicker so it can be referenced in the checkbox setter
    local foregroundColorPicker
    
    -- Use Static Color checkbox  
    local useStaticColorCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Use Static Color",
        function() return colorData.ColorByStaticColor end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColorByStaticColor = value
            -- Enable/disable the static color picker based on checkbox value
            if foregroundColorPicker then
                foregroundColorPicker:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, useStaticColorCheckbox, 35, -200)
    
    -- Foreground Color picker (for static color) - positioned right next to its checkbox
    foregroundColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Static Color",
        function() return colorData.StaticColor or {1, 1, 1} end,
        function(color)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.StaticColor = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, foregroundColorPicker, 220, -200)
    
    -- Set initial enabled state based on checkbox
    foregroundColorPicker:SetEnabled(colorData.ColorByStaticColor == true)

    -- Colors Box (below Size box) - anchored to bottom left of Size box, 4x width of Size box
    local colorsBGSection = MilaUI.AF.CreateBorderedSection(parent, " ", 300, 350)
    AF.SetPoint(colorsBGSection, "TOPLEFT", colorsSection, "TOPRIGHT", 0, 0)
    
    -- Second column - Background colors (1/3 of width = 100px from left edge)
    local bgLabel = AF.CreateFontString(colorsSection, AF.GetGradientText("Background", "pink", "hotpink"))
    AF.SetPoint(bgLabel, "CENTER", colorsBGSection, "TOP", 0, -25)
    
    -- Pre-declare background multiplier slider so it can be referenced in the checkbox setter
    local backgroundMultiplierSlider
    
    -- Background by Foreground checkbox
    local bgByForegroundCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Foreground",
        function() return colorData.ColourBackgroundByForeground end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColourBackgroundByForeground = value
            if backgroundMultiplierSlider then
                backgroundMultiplierSlider:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, bgByForegroundCheckbox, 35, -50)
    
    -- Background Multiplier slider - positioned next to the checkbox
    backgroundMultiplierSlider = MilaUI.AF.CreateSlider(colorsSection, "Multiplier", 0.1, 1.0,
        function() return colorData.BackgroundMultiplier or 0.25 end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.BackgroundMultiplier = value
            MilaUI:UpdateFrames(unitType)
        end, 0.01, 80)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, backgroundMultiplierSlider, 200, -50)
    
    -- Set initial enabled state based on checkbox
    backgroundMultiplierSlider:SetEnabled(colorData.ColourBackgroundByForeground == true)
    
    -- Background by Class checkbox
    local bgByClassCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Class",
        function() return colorData.ColourBackgroundByClass end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColourBackgroundByClass = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, bgByClassCheckbox, 35, -80)
    
    -- Pre-declare background static color picker so it can be referenced in the checkbox setter
    local backgroundStaticColorPicker
    
    -- Background by Static Color checkbox
    local bgByStaticColorCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Static Color",
        function() return colorData.ColorBackgroundByStaticColor end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColorBackgroundByStaticColor = value
            if backgroundStaticColorPicker then
                backgroundStaticColorPicker:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, bgByStaticColorCheckbox, 35, -110)
    
    -- Background Static Color picker - positioned right next to its checkbox
    backgroundStaticColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Static Background",
        function() 
            return colorData.BackgroundStaticColor or {1, 1, 1} -- Default to white
        end,
        function(color)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.BackgroundStaticColor = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, backgroundStaticColorPicker, 200, -110)
    
    -- Set initial enabled state based on checkbox
    backgroundStaticColorPicker:SetEnabled(colorData.ColorBackgroundByStaticColor == true)
    
    -- Pre-declare background dead color picker so it can be referenced in the checkbox setter
    local backgroundDeadColorPicker
    
    -- Background if Dead checkbox
    local bgIfDeadCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "If Dead",
        function() return colorData.ColourBackgroundIfDead end,
        function(value)
            if not healthData.Colors then healthData.Colors = {} end
            healthData.Colors.ColourBackgroundIfDead = value
            if backgroundDeadColorPicker then
                backgroundDeadColorPicker:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, bgIfDeadCheckbox, 35, -140)
    
    -- Background Dead color picker - uses Status[1] for dead color
    backgroundDeadColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Dead Color",
        function() 
            local status = colorData.Status or {}
            return status[1] or {255/255, 64/255, 64/255} -- Default dead color
        end,
        function(color)
            if not healthData.Colors then healthData.Colors = {} end
            if not healthData.Colors.Status then healthData.Colors.Status = {} end
            healthData.Colors.Status[1] = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, backgroundDeadColorPicker, 200, -140)
    
    -- Set initial enabled state based on checkbox
    backgroundDeadColorPicker:SetEnabled(colorData.ColourBackgroundIfDead == true)
    
    -- Background Color picker (general background color still needed as fallback)
    local backgroundColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Default Background",
        function() return generalData.BackgroundColour or {0, 0, 0, 1} end,
        function(color)
            generalData.BackgroundColour = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, backgroundColorPicker, 200, -170)
    -- Update Y position based on Colors box placement
    MilaUI.AF.currentY = MilaUI.AF.currentY + 890  -- Size/Texture height (max 200) + gap (20) + Colors height (700)

    -- Position Section (contains all position-related settings)
    local positionSection = MilaUI.AF.CreateBorderedSection(parent, "Position", 360, 170)
    
    -- X and Y Position sliders (left column)
    local xPosSlider = MilaUI.AF.CreateSlider(positionSection, "X Position", -999, 999,
        function() return frameData.XPosition or 0 end,
        function(value)
            frameData.XPosition = value
            MilaUI:UpdateFramePosition(dbUnitName)
        end, 0.1, 140)
    MilaUI.AF.AddWidgetToSection(positionSection, xPosSlider, 10, -30)
    
    local yPosSlider = MilaUI.AF.CreateSlider(positionSection, "Y Position", -999, 999,
        function() return frameData.YPosition or 0 end,
        function(value)
            frameData.YPosition = value
            MilaUI:UpdateFramePosition(dbUnitName)
        end, 0.1, 140)
    MilaUI.AF.AddWidgetToSection(positionSection, yPosSlider, 10, -90)
    
    -- Anchoring settings (right column)
    local anchorOptions = {
        {text = "Top Left", value = "TOPLEFT"},
        {text = "Top", value = "TOP"},
        {text = "Top Right", value = "TOPRIGHT"},
        {text = "Left", value = "LEFT"},
        {text = "Center", value = "CENTER"},
        {text = "Right", value = "RIGHT"},
        {text = "Bottom Left", value = "BOTTOMLEFT"},
        {text = "Bottom", value = "BOTTOM"},
        {text = "Bottom Right", value = "BOTTOMRIGHT"}
    }
    
    local anchorFromDropdown = MilaUI.AF.CreateDropdown(positionSection, "Anchor From", anchorOptions,
        function() return frameData.AnchorFrom or "CENTER" end,
        function(value)
            frameData.AnchorFrom = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorFromDropdown, 190, -30)
    
    local anchorToDropdown = MilaUI.AF.CreateDropdown(positionSection, "Anchor To", anchorOptions,
        function() return frameData.AnchorTo or "CENTER" end,
        function(value)
            frameData.AnchorTo = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorToDropdown, 190, -90)
    
    -- Healthbar-specific settings section
    local healthbarSection = MilaUI.AF.CreateBorderedSection(parent, "Healthbar Settings", 360, 200)
    
    if not healthData then
        local errorLabel = AF.CreateFontString(healthbarSection, "No healthbar data found for " .. unitType, "red")
        MilaUI.AF.AddWidgetToSection(healthbarSection, errorLabel, 10, -30)
        return
    end
    
    -- Enable Healthbar checkbox
    local enableHealthCheckbox = MilaUI.AF.CreateCheckbox(healthbarSection, "Enable Healthbar",
        function() return healthData.Enabled end,
        function(value)
            healthData.Enabled = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(healthbarSection, enableHealthCheckbox, 10, -30)
    
    -- Fill Direction dropdown
    local directionOptions = {
        {text = "Left to Right", value = "LR"},
        {text = "Right to Left", value = "RL"}
    }
    local directionDropdown = MilaUI.AF.CreateDropdown(healthbarSection, "Fill Direction", directionOptions,
        function() return healthData.Direction or "LR" end,
        function(value)
            healthData.Direction = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(healthbarSection, directionDropdown, 190, -30)
    
    -- Healthbar anchoring settings (left column)
    local anchorOptions = {
        {text = "Top Left", value = "TOPLEFT"},
        {text = "Top", value = "TOP"},
        {text = "Top Right", value = "TOPRIGHT"},
        {text = "Left", value = "LEFT"},
        {text = "Center", value = "CENTER"},
        {text = "Right", value = "RIGHT"},
        {text = "Bottom Left", value = "BOTTOMLEFT"},
        {text = "Bottom", value = "BOTTOM"},
        {text = "Bottom Right", value = "BOTTOMRIGHT"}
    }
    
    local anchorFromDropdown = MilaUI.AF.CreateDropdown(healthbarSection, "Anchor From", anchorOptions,
        function() return healthData.AnchorFrom or "CENTER" end,
        function(value)
            healthData.AnchorFrom = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(healthbarSection, anchorFromDropdown, 10, -80)
    
    local anchorToDropdown = MilaUI.AF.CreateDropdown(healthbarSection, "Anchor To", anchorOptions,
        function() return healthData.AnchorTo or "CENTER" end,
        function(value)
            healthData.AnchorTo = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(healthbarSection, anchorToDropdown, 190, -80)
    
    -- Anchor Offsets
    local anchorXSlider = MilaUI.AF.CreateSlider(healthbarSection, "Anchor X", -200, 200,
        function() return healthData.AnchorXOffset or 0 end,
        function(value)
            healthData.AnchorXOffset = value
            MilaUI:UpdateFrames(unitType)
        end, 1, 140)
    MilaUI.AF.AddWidgetToSection(healthbarSection, anchorXSlider, 10, -130)
    
    local anchorYSlider = MilaUI.AF.CreateSlider(healthbarSection, "Anchor Y", -200, 200,
        function() return healthData.AnchorYOffset or 0 end,
        function(value)
            healthData.AnchorYOffset = value
            MilaUI:UpdateFrames(unitType)
        end, 1, 140)
    MilaUI.AF.AddWidgetToSection(healthbarSection, anchorYSlider, 190, -130)
    
    -- Health Prediction settings
    local healthPredictionData = healthData.HealthPrediction or {}
    local predictionCheckbox = MilaUI.AF.CreateCheckbox(healthbarSection, "Enable Health Prediction",
        function() return healthPredictionData.Enabled end,
        function(value)
            if not healthData.HealthPrediction then healthData.HealthPrediction = {} end
            healthData.HealthPrediction.Enabled = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(healthbarSection, predictionCheckbox, 10, -180)
    
    -- Incoming Heals sub-option
    local incomingHealsCheckbox = MilaUI.AF.CreateCheckbox(healthbarSection, "Show Incoming Heals",
        function() return healthPredictionData.IncomingHeals end,
        function(value)
            if not healthData.HealthPrediction then healthData.HealthPrediction = {} end
            healthData.HealthPrediction.IncomingHeals = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(healthbarSection, incomingHealsCheckbox, 190, -180)
    
    -- Special unit settings (Pet only)
    if unitType == "Pet" then
        local colorByPlayerClassCheckbox = MilaUI.AF.CreateCheckbox(healthbarSection, "Color by Player Class",
            function() return healthData.ColourByPlayerClass end,
            function(value)
                healthData.ColourByPlayerClass = value
                MilaUI:UpdateFrames(unitType)
            end)
        MilaUI.AF.AddWidgetToSection(healthbarSection, colorByPlayerClassCheckbox, 190, -180)
    end
    
    
    -- Force parent scroll frame to update after all content is created
    C_Timer.After(0.01, function()
        local scrollFrame = parent
        while scrollFrame and not scrollFrame.SetContentHeight do
            scrollFrame = scrollFrame:GetParent()
        end
        if scrollFrame and scrollFrame.SetContentHeight then
            local contentHeight = MilaUI.AF.currentY + 50
            scrollFrame:SetContentHeight(contentHeight)
            if scrollFrame.UpdateScrollChildRect then
                scrollFrame:UpdateScrollChildRect()
            end
        end
    end)
end

function MilaUI:CreateUnitFramePowerBarTabContent(parent, unitType)
    local dbUnitName = self:GetUnitDatabaseKey(unitType)
    local powerData = MilaUI.DB.profile.Unitframes[dbUnitName].PowerBar
    
    -- Enable/Disable Power Bar (top level, no border, moved up)
    local enableCheckbox = MilaUI.AF.CreateCheckbox(parent, "Enable Power Bar",
        function() return powerData.Enabled end,
        function(value)
            powerData.Enabled = value
            MilaUI:UpdateFrames(unitType)
        end)
    AF.SetPoint(enableCheckbox, "TOPLEFT", parent, "TOPLEFT", 10, -MilaUI.AF.currentY + 15)
    MilaUI.AF.currentY = MilaUI.AF.currentY -15
    
    -- Size Box (left side)
    local sizeSection = MilaUI.AF.CreateBorderedSection(parent, "Size", 280, 170)
    AF.SetPoint(sizeSection, "TOPLEFT", enableCheckbox, "TOPLEFT", 10, -40)
    
    -- Store the Y position for the Texture box
    local currentRowY = MilaUI.AF.currentY
    
    -- Width and Height sliders
    local widthSlider = MilaUI.AF.CreateSlider(sizeSection, "Width", 50, 500,
        function() return powerData.Width or 200 end,
        function(value)
            powerData.Width = value
            MilaUI:UpdateFrames(unitType)
        end, 1, 140)
    MilaUI.AF.AddWidgetToSection(sizeSection, widthSlider, 10, -30)
    
    local heightSlider = MilaUI.AF.CreateSlider(sizeSection, "Height", 5, 50,
        function() return powerData.Height or 20 end,
        function(value)
            powerData.Height = value
            MilaUI:UpdateFrames(unitType)
        end, 1, 140)
    MilaUI.AF.AddWidgetToSection(sizeSection, heightSlider, 10, -70)
    
    -- Fill Direction dropdown
    local directionOptions = {
        {text = "Left to Right", value = "LR"},
        {text = "Right to Left", value = "RL"}
    }
    local directionDropdown = MilaUI.AF.CreateDropdown(sizeSection, "Fill Direction", directionOptions,
        function() return powerData.Direction or "LR" end,
        function(value)
            powerData.Direction = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(sizeSection, directionDropdown, 10, -110)
    
    -- Texture Box (right side)
    local textureSection = MilaUI.AF.CreateBorderedSection(parent, "Texture", 280, 200)
    AF.SetPoint(textureSection, "TOPLEFT", sizeSection, "TOPRIGHT", 10, 0)
    
    -- Foreground Texture Picker
    local textureDropdown = MilaUI.AF.CreateTextureDropdown(textureSection, "Foreground Texture",
        function() return powerData.Texture or "Smooth" end,
        function(value)
            powerData.Texture = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(textureSection, textureDropdown, 10, -30)
    
    -- Background Texture Picker
    local bgTextureDropdown = MilaUI.AF.CreateTextureDropdown(textureSection, "Background Texture",
        function() return powerData.BackgroundTexture or "Smooth" end,
        function(value)
            powerData.BackgroundTexture = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(textureSection, bgTextureDropdown, 10, -70)
    
    -- Smooth Statusbar checkbox
    local smoothCheckbox = MilaUI.AF.CreateCheckbox(textureSection, "Smooth Statusbar",
        function() return powerData.Smooth end,
        function(value)
            powerData.Smooth = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(textureSection, smoothCheckbox, 10, -110)
    
    -- Custom Mask checkbox
    local customMaskData = powerData.CustomMask or {}
    local maskEnabledCheckbox = MilaUI.AF.CreateCheckbox(textureSection, "Enable Custom Mask",
        function() return customMaskData.Enabled end,
        function(value)
            if not powerData.CustomMask then powerData.CustomMask = {} end
            powerData.CustomMask.Enabled = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(textureSection, maskEnabledCheckbox, 10, -150)
    
    -- Custom Border checkbox
    local customBorderData = powerData.CustomBorder or {}
    local borderEnabledCheckbox = MilaUI.AF.CreateCheckbox(textureSection, "Enable Custom Border",
        function() return customBorderData.Enabled end,
        function(value)
            if not powerData.CustomBorder then powerData.CustomBorder = {} end
            powerData.CustomBorder.Enabled = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(textureSection, borderEnabledCheckbox, 10, -190)
    
    -- Colors Box (below Size box)
    local colorsSection = MilaUI.AF.CreateBorderedSection(parent, "Colors", 300, 250)
    AF.SetPoint(colorsSection, "TOPLEFT", sizeSection, "BOTTOMLEFT", 0, -20)
    
    -- First column - Foreground colors
    local fgLabel = AF.CreateFontString(colorsSection, AF.GetGradientText("Foreground", "pink", "hotpink"))
    AF.SetPoint(fgLabel, "CENTER", colorsSection, "TOP", 0, -25)
    
    -- Color by Power Type checkbox
    local colorByTypeCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Power Type",
        function() return powerData.ColourByType end,
        function(value)
            powerData.ColourByType = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, colorByTypeCheckbox, 35, -50)
    
    -- Pre-declare foreground color picker
    local foregroundColorPicker
    
    -- Use Static Color checkbox
    local useStaticColorCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Use Static Color",
        function() return not powerData.ColourByType end,
        function(value)
            powerData.ColourByType = not value
            if foregroundColorPicker then
                foregroundColorPicker:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, useStaticColorCheckbox, 35, -80)
    
    -- Foreground Color picker
    foregroundColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Static Color",
        function() return powerData.Colour or {0, 0, 1, 1} end,
        function(color)
            powerData.Colour = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsSection, foregroundColorPicker, 220, -80)
    
    -- Set initial enabled state based on checkbox
    foregroundColorPicker:SetEnabled(not (powerData.ColourByType == true))
    
    -- Second column - Background colors
    local colorsBGSection = MilaUI.AF.CreateBorderedSection(parent, " ", 300, 250)
    AF.SetPoint(colorsBGSection, "TOPLEFT", colorsSection, "TOPRIGHT", 0, 0)
    
    local bgLabel = AF.CreateFontString(colorsSection, AF.GetGradientText("Background", "pink", "hotpink"))
    AF.SetPoint(bgLabel, "CENTER", colorsBGSection, "TOP", 0, -25)
    
    -- Background by Power Type checkbox
    local bgByTypeCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Power Type",
        function() return powerData.ColourBackgroundByType end,
        function(value)
            powerData.ColourBackgroundByType = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, bgByTypeCheckbox, 35, -50)
    
    -- Pre-declare background multiplier slider
    local backgroundMultiplierSlider
    
    -- Background by Foreground checkbox
    local bgByForegroundCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Color by Foreground",
        function() return powerData.ColourBackgroundByType end,
        function(value)
            powerData.ColourBackgroundByType = value
            if backgroundMultiplierSlider then
                backgroundMultiplierSlider:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, bgByForegroundCheckbox, 35, -80)
    
    -- Background Multiplier slider
    backgroundMultiplierSlider = MilaUI.AF.CreateSlider(colorsSection, "Multiplier", 0.1, 1.0,
        function() return powerData.BackgroundMultiplier or 0.25 end,
        function(value)
            powerData.BackgroundMultiplier = value
            MilaUI:UpdateFrames(unitType)
        end, 0.01, 80)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, backgroundMultiplierSlider, 200, -80)
    
    -- Set initial enabled state based on checkbox
    backgroundMultiplierSlider:SetEnabled(powerData.ColourBackgroundByType == true)
    
    -- Pre-declare background static color picker
    local backgroundStaticColorPicker
    
    -- Background by Static Color checkbox
    local bgByStaticColorCheckbox = MilaUI.AF.CreateCheckbox(colorsSection, "Use Static Color",
        function() return not powerData.ColourBackgroundByType end,
        function(value)
            powerData.ColourBackgroundByType = not value
            if backgroundStaticColorPicker then
                backgroundStaticColorPicker:SetEnabled(value)
            end
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, bgByStaticColorCheckbox, 35, -110)
    
    -- Background Static Color picker
    backgroundStaticColorPicker = MilaUI.AF.CreateColorPicker(colorsSection, "Static Background",
        function() return powerData.BackgroundColour or {0.1, 0.1, 0.1, 1} end,
        function(color)
            powerData.BackgroundColour = color
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(colorsBGSection, backgroundStaticColorPicker, 200, -110)
    
    -- Set initial enabled state based on checkbox
    backgroundStaticColorPicker:SetEnabled(not (powerData.ColourBackgroundByType == true))
    
    -- Update Y position based on Colors box placement
    MilaUI.AF.currentY = MilaUI.AF.currentY + 490  -- Size/Texture height (max 200) + gap (20) + Colors height (250)
    
    -- Position Section (contains all position-related settings)
    local positionSection = MilaUI.AF.CreateBorderedSection(parent, "Position", 360, 170)
    
    -- X and Y Position sliders (left column)
    local xPosSlider = MilaUI.AF.CreateSlider(positionSection, "X Position", -999, 999,
        function() return powerData.XPosition or 0 end,
        function(value)
            powerData.XPosition = value
            MilaUI:UpdateFrames(unitType)
        end, 0.1, 140)
    MilaUI.AF.AddWidgetToSection(positionSection, xPosSlider, 10, -30)
    
    local yPosSlider = MilaUI.AF.CreateSlider(positionSection, "Y Position", -999, 999,
        function() return powerData.YPosition or 0 end,
        function(value)
            powerData.YPosition = value
            MilaUI:UpdateFrames(unitType)
        end, 0.1, 140)
    MilaUI.AF.AddWidgetToSection(positionSection, yPosSlider, 10, -90)
    
    -- Anchoring settings (right column)
    local anchorOptions = {
        {text = "Top Left", value = "TOPLEFT"},
        {text = "Top", value = "TOP"},
        {text = "Top Right", value = "TOPRIGHT"},
        {text = "Left", value = "LEFT"},
        {text = "Center", value = "CENTER"},
        {text = "Right", value = "RIGHT"},
        {text = "Bottom Left", value = "BOTTOMLEFT"},
        {text = "Bottom", value = "BOTTOM"},
        {text = "Bottom Right", value = "BOTTOMRIGHT"}
    }
    
    local anchorFromDropdown = MilaUI.AF.CreateDropdown(positionSection, "Anchor From", anchorOptions,
        function() return powerData.AnchorFrom or "CENTER" end,
        function(value)
            powerData.AnchorFrom = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorFromDropdown, 190, -30)
    
    local anchorToDropdown = MilaUI.AF.CreateDropdown(positionSection, "Anchor To", anchorOptions,
        function() return powerData.AnchorTo or "CENTER" end,
        function(value)
            powerData.AnchorTo = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorToDropdown, 190, -90)
    
    -- Anchor Parent Input
    local anchorParentInput = MilaUI.AF.CreateTextInput(positionSection, "Anchor Parent",
        function() return powerData.AnchorParent or "" end,
        function(value)
            powerData.AnchorParent = value
            MilaUI:UpdateFrames(unitType)
        end)
    MilaUI.AF.AddWidgetToSection(positionSection, anchorParentInput, 10, -140)
    
    -- Force parent scroll frame to update after all content is created
    C_Timer.After(0.01, function()
        local scrollFrame = parent
        while scrollFrame and not scrollFrame.SetContentHeight do
            scrollFrame = scrollFrame:GetParent()
        end
        if scrollFrame and scrollFrame.SetContentHeight then
            local contentHeight = MilaUI.AF.currentY + 50
            scrollFrame:SetContentHeight(contentHeight)
            if scrollFrame.UpdateScrollChildRect then
                scrollFrame:UpdateScrollChildRect()
            end
        end
    end)
end

function MilaUI:CreateUnitFrameCastbarTabContent(parent, unitType)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Castbar Settings", 200)
    local label = AF.CreateFontString(section, "Castbar settings for " .. unitType .. " - Coming Soon", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -30)
end

function MilaUI:CreateUnitFrameBuffsTabContent(parent, unitType)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Buffs Settings", 200)
    local label = AF.CreateFontString(section, "Buffs settings for " .. unitType .. " - Coming Soon", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -30)
end

function MilaUI:CreateUnitFrameDebuffsTabContent(parent, unitType)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Debuffs Settings", 200)
    local label = AF.CreateFontString(section, "Debuffs settings for " .. unitType .. " - Coming Soon", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -30)
end

function MilaUI:CreateUnitFrameIndicatorsTabContent(parent, unitType)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Indicators Settings", 200)
    local label = AF.CreateFontString(section, "Indicators settings for " .. unitType .. " - Coming Soon", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -30)
end

function MilaUI:CreateUnitFrameTextTabContent(parent, unitType)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Text Settings", 200)
    local label = AF.CreateFontString(section, "Text settings for " .. unitType .. " - Coming Soon", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -30)
end

-- Placeholder for the old function to maintain compatibility
function MilaUI:CreateAFUnitsTab(parent)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Unit Frame Settings", 600)
    
    local label = AF.CreateFontString(section, "Select a unit frame from the list to configure...", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
end