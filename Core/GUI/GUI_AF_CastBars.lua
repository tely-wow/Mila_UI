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
    local container = MilaUI.AF:CreateTwoPanelLayout(parent, castbarItems, "Settings", function(selectedId)
        MilaUI:HandleCastBarSelection(selectedId, container.contentArea)
    end)
    
    -- Initialize with default content
    MilaUI:HandleCastBarSelection("General", container.contentArea)
    
    return container
end

-- Handle castbar selection and load appropriate content
function MilaUI:HandleCastBarSelection(selectedId, contentArea)
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
    
    -- Create header
    local headerText = selectedId:upper() .. " CASTBAR SETTINGS"
    local header = MilaUI.AF:CreateHeader(contentArea.scrollContent, headerText)
    
    -- Load content based on selection
    if selectedId == "General" then
        MilaUI:CreateCastBarGeneralContent(contentArea.scrollContent)
    else
        MilaUI:CreateCastBarSpecificContent(contentArea.scrollContent, selectedId)
    end
    
    contentArea:SetContentHeight(1400)
end

-- General castbar settings content
function MilaUI:CreateCastBarGeneralContent(parent)
    local section = MilaUI.AF.CreateBorderedSection(parent, "General Castbar Settings", 600)
    
    local label = AF.CreateFontString(section, "Configure general settings that apply to all castbars...", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
    
    -- Button to open existing castbar GUI
    local openCastbarBtn = AF.CreateButton(section, "Open Legacy Castbar GUI", "pink", 200, 25)
    openCastbarBtn:SetScript("OnClick", function()
        MilaUI:CreateCleanCastbarGUI()
    end)
    MilaUI.AF.AddWidgetToSection(section, openCastbarBtn, 10, -60)
end

-- Specific castbar settings content
function MilaUI:CreateCastBarSpecificContent(parent, castbarType)
    local unitKey = castbarType:lower()
    local castbarSettings = MilaUI.DB and MilaUI.DB.profile and MilaUI.DB.profile.castBars and MilaUI.DB.profile.castBars[unitKey]
    
    if not castbarSettings then
        local label = AF.CreateFontString(parent, "No castbar settings found for " .. castbarType, "white")
        MilaUI.AF.AddWidgetToSection(parent, label, 10, -25)
        return
    end
    
    -- General Settings Section
    local generalSection = MilaUI.AF.CreateBorderedSection(parent, castbarType .. " General Settings", 200)
    
    local enabledCB = MilaUI.AF.CreateCheckbox(generalSection, "Enable Castbar", function(checked)
        castbarSettings.enabled = checked
        MilaUI:RefreshCastbars()
    end)
    enabledCB:SetChecked(castbarSettings.enabled)
    MilaUI.AF.AddWidgetToSection(generalSection, enabledCB, 10, -25)
    
    local widthSlider = MilaUI.AF.CreateSlider(generalSection, "Width", 200, 50, 400, 1)
    widthSlider:SetValue(castbarSettings.size and castbarSettings.size.width or 200)
    widthSlider:SetAfterValueChanged(function(value)
        if not castbarSettings.size then castbarSettings.size = {} end
        castbarSettings.size.width = value
        MilaUI:RefreshCastbars()
    end)
    MilaUI.AF.AddWidgetToSection(generalSection, widthSlider, 10, -60)
    
    local heightSlider = MilaUI.AF.CreateSlider(generalSection, "Height", 200, 10, 50, 1)
    heightSlider:SetValue(castbarSettings.size and castbarSettings.size.height or 20)
    heightSlider:SetAfterValueChanged(function(value)
        if not castbarSettings.size then castbarSettings.size = {} end
        castbarSettings.size.height = value
        MilaUI:RefreshCastbars()
    end)
    MilaUI.AF.AddWidgetToSection(generalSection, heightSlider, 10, -95)
    
    -- Bar Color Settings Section
    local colorSection = MilaUI.AF.CreateBorderedSection(parent, castbarType .. " Bar Colors", 200)
    
    -- Cast Color
    local castColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Cast Color", true, function(r, g, b, a)
        if not castbarSettings.colors then castbarSettings.colors = {} end
        castbarSettings.colors.cast = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local castColor = castbarSettings.colors and castbarSettings.colors.cast or {0, 1, 1, 1}
    castColorPicker:SetColor(castColor)
    MilaUI.AF.AddWidgetToSection(colorSection, castColorPicker, 10, -25)
    
    -- Channel Color
    local channelColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Channel Color", true, function(r, g, b, a)
        if not castbarSettings.colors then castbarSettings.colors = {} end
        castbarSettings.colors.channel = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local channelColor = castbarSettings.colors and castbarSettings.colors.channel or {0.5, 0.3, 0.9, 1}
    channelColorPicker:SetColor(channelColor)
    MilaUI.AF.AddWidgetToSection(colorSection, channelColorPicker, 180, -25)
    
    -- Uninterruptible Color
    local uninterruptibleColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Uninterruptible Color", true, function(r, g, b, a)
        if not castbarSettings.colors then castbarSettings.colors = {} end
        castbarSettings.colors.uninterruptible = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local uninterruptibleColor = castbarSettings.colors and castbarSettings.colors.uninterruptible or {0.8, 0.8, 0.8, 1}
    uninterruptibleColorPicker:SetColor(uninterruptibleColor)
    MilaUI.AF.AddWidgetToSection(colorSection, uninterruptibleColorPicker, 10, -60)
    
    -- Interrupt Color
    local interruptColorPicker = MilaUI.AF.CreateColorPicker(colorSection, "Interrupt Color", true, function(r, g, b, a)
        if not castbarSettings.colors then castbarSettings.colors = {} end
        castbarSettings.colors.interrupt = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local interruptColor = castbarSettings.colors and castbarSettings.colors.interrupt or {1, 0.2, 0.2, 1}
    interruptColorPicker:SetColor(interruptColor)
    MilaUI.AF.AddWidgetToSection(colorSection, interruptColorPicker, 180, -60)
    
    -- Flash Color Settings Section
    local flashColorSection = MilaUI.AF.CreateBorderedSection(parent, castbarType .. " Flash Colors", 200)
    
    -- Cast Flash Color
    local castFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Cast Flash Color", true, function(r, g, b, a)
        if not castbarSettings.flashColors then castbarSettings.flashColors = {} end
        castbarSettings.flashColors.cast = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local castFlashColor = castbarSettings.flashColors and castbarSettings.flashColors.cast or {0.2, 0.8, 0.2, 1.0}
    castFlashColorPicker:SetColor(castFlashColor)
    MilaUI.AF.AddWidgetToSection(flashColorSection, castFlashColorPicker, 10, -25)
    
    -- Channel Flash Color
    local channelFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Channel Flash Color", true, function(r, g, b, a)
        if not castbarSettings.flashColors then castbarSettings.flashColors = {} end
        castbarSettings.flashColors.channel = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local channelFlashColor = castbarSettings.flashColors and castbarSettings.flashColors.channel or {1.0, 0.4, 1.0, 0.9}
    channelFlashColorPicker:SetColor(channelFlashColor)
    MilaUI.AF.AddWidgetToSection(flashColorSection, channelFlashColorPicker, 180, -25)
    
    -- Uninterruptible Flash Color
    local uninterruptibleFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Uninterruptible Flash Color", true, function(r, g, b, a)
        if not castbarSettings.flashColors then castbarSettings.flashColors = {} end
        castbarSettings.flashColors.uninterruptible = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local uninterruptibleFlashColor = castbarSettings.flashColors and castbarSettings.flashColors.uninterruptible or {0.8, 0.8, 0.8, 0.9}
    uninterruptibleFlashColorPicker:SetColor(uninterruptibleFlashColor)
    MilaUI.AF.AddWidgetToSection(flashColorSection, uninterruptibleFlashColorPicker, 10, -60)
    
    -- Interrupt Flash Color (for glow effect)
    local interruptFlashColorPicker = MilaUI.AF.CreateColorPicker(flashColorSection, "Interrupt Glow Color", true, function(r, g, b, a)
        if not castbarSettings.flashColors then castbarSettings.flashColors = {} end
        castbarSettings.flashColors.interrupt = {r, g, b, a}
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(unitKey)
        end
    end)
    local interruptFlashColor = castbarSettings.flashColors and castbarSettings.flashColors.interrupt or {1, 1, 1, 1}
    interruptFlashColorPicker:SetColor(interruptFlashColor)
    MilaUI.AF.AddWidgetToSection(flashColorSection, interruptFlashColorPicker, 180, -60)
    
    -- Info label for flash colors
    local flashInfoLabel = AF.CreateFontString(flashColorSection, "Flash colors control the completion flash effect for each cast type", "gray")
    AF.SetFont(flashInfoLabel, nil, 10)
    MilaUI.AF.AddWidgetToSection(flashColorSection, flashInfoLabel, 10, -95)
    
    -- Legacy GUI Button
    local legacySection = MilaUI.AF.CreateBorderedSection(parent, "Advanced Settings", 100)
    
    local legacyBtn = AF.CreateButton(legacySection, "Open Legacy Castbar GUI", "pink", 200, 25)
    legacyBtn:SetScript("OnClick", function()
        MilaUI:CreateCleanCastbarGUI()
    end)
    MilaUI.AF.AddWidgetToSection(legacySection, legacyBtn, 10, -25)
    
    local infoLabel = AF.CreateFontString(legacySection, "Use the legacy GUI for advanced texture, positioning, and display settings", "gray")
    AF.SetFont(infoLabel, nil, 10)
    MilaUI.AF.AddWidgetToSection(legacySection, infoLabel, 10, -55)
end

-- Placeholder for the old function to maintain compatibility
function MilaUI:CreateAFCastbarsTab(parent)
    local section = MilaUI.AF.CreateBorderedSection(parent, "Cast Bar Settings", 600)
    
    local label = AF.CreateFontString(section, "Cast bar settings available via button selection", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
    
    local castbarBtn = AF.CreateButton(section, "Open Castbar GUI", "pink", 150, 25)
    castbarBtn:SetScript("OnClick", function()
        MilaUI:CreateCleanCastbarGUI()
    end)
    MilaUI.AF.AddWidgetToSection(section, castbarBtn, 10, -50)
end