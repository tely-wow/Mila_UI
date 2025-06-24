local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

local lavender = "|cffBFACE2"
local pink = "|cffFF9CD0"
local green = "|cff00FF00"
local red = "|cffFF0000"

local cleanCastbarGUI = nil
local currentUnit = "player"

local units = {
    {key = "player", display = "Player"},
    {key = "target", display = "Target"},
    {key = "focus", display = "Focus"},
    {key = "pet", display = "Pet"},
    {key = "boss", display = "Boss"}
}

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
        if type(setting) == "table" and setting[1] == "colors" then
            -- Color settings changed, update colors immediately
            if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
                MilaUI.NewCastbarSystem.UpdateCastBarColors(unit)
            end
        end
        
        -- Show castbar temporarily for preview when changing non-color visual settings
        if type(setting) == "table" and (setting[1] == "textures" or setting[1] == "display" or setting[1] == "spark") then
            ShowCastbarPreview(unit)
        end
        
        MilaUI:RefreshCastbars()
    end
end

local function ShowCastbarPreview(unit)
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

local function CreateCheckbox(parent, label, getValue, setValue)
    local checkbox = AF.CreateCheckButton(parent, label, function(checked)
        setValue(checked)
    end)
    checkbox:SetChecked(getValue())
    checkbox.accentColor = "pink"  -- Set checkbox accent color to pink
    return checkbox
end

local function CreateSlider(parent, label, minVal, maxVal, getValue, setValue, step)
    local slider = AF.CreateSlider(parent, label, 200, minVal, maxVal, step or 1)
    slider:SetValue(getValue())
    slider:SetAfterValueChanged(function(value)
        setValue(value)
    end)
    slider.accentColor = "pink"  -- Set slider accent color to pink
    return slider
end

local function CreateColorPicker(parent, label, getValue, setValue)
    local value = getValue()
    
    local colorPicker = AF.CreateColorPicker(parent, label, true, function(r, g, b, a)
        setValue({r, g, b, a})
        -- Update colors immediately and show preview
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(currentUnit)
        end
        ShowCastbarPreview(currentUnit)
    end, function(r, g, b, a)
        setValue({r, g, b, a})
        -- Update colors immediately and show preview
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.UpdateCastBarColors then
            MilaUI.NewCastbarSystem.UpdateCastBarColors(currentUnit)
        end
        ShowCastbarPreview(currentUnit)
    end)
    
    -- Hook the OnClick to reparent the color picker dialog
    local originalOnClick = colorPicker:GetScript("OnClick")
    colorPicker:SetScript("OnClick", function(self, ...)
        if originalOnClick then
            originalOnClick(self, ...)
        end
        -- Reparent the color picker dialog to main GUI frame after it's created
        C_Timer.After(0.01, function()
            local colorPickerFrame = _G.AFColorPicker
            if colorPickerFrame and colorPickerFrame:IsVisible() then
                colorPickerFrame:SetParent(cleanCastbarGUI or AF.UIParent)
                colorPickerFrame:SetFrameStrata("DIALOG")
                colorPickerFrame:SetToplevel(true)
            end
        end)
    end)
    
    -- Set the initial color after creating the picker
    if value then
        colorPicker:SetColor(value)
    end
    
    return colorPicker
end

local function CreateDropdown(parent, label, options, getValue, setValue)
    local dropdown = AF.CreateDropdown(parent, 150)
    dropdown:SetLabel(label)
    dropdown:SetItems(options)
    dropdown:SetOnClick(function(selectedValue)
        setValue(selectedValue)
    end)
    -- Set the current value
    local currentValue = getValue()
    if currentValue then
        dropdown:SetSelectedValue(currentValue)
    end
    dropdown.accentColor = "pink"  -- Set dropdown accent color to pink
    return dropdown
end

local function CreateTexturePicker(parent, label, getValue, setValue)
    -- Get available textures from LSM
    local textureList = LSM:List("statusbar")
    local textureOptions = {}
    
    -- Build options table with texture preview
    for i, textureName in ipairs(textureList) do
        local texturePath = LSM:Fetch("statusbar", textureName)
        textureOptions[i] = {
            text = textureName, 
            value = textureName,
            -- Add texture preview to the dropdown item
            icon = texturePath,
            iconCoords = {0, 1, 0, 1},
            iconHeight = 16,
            iconWidth = 60
        }
    end
    
    -- Create the dropdown with texture previews
    local dropdown = AF.CreateDropdown(parent, 150)
    dropdown:SetLabel(label)
    dropdown:SetItems(textureOptions)
    dropdown:SetOnClick(function(selectedValue)
        setValue(selectedValue)
        MilaUI.modules.bars.UpdateCastBarSettings(currentUnit)
    end)
    
    -- Set the current value
    local currentValue = getValue()
    if currentValue then
        dropdown:SetSelectedValue(currentValue)
    end
    
    dropdown.accentColor = "pink"
    return dropdown
end

local function CreateTextInput(parent, label, getValue, setValue)
    local editbox = AF.CreateEditBox(parent, label, 150)
    editbox:SetText(getValue())
    editbox:SetOnEnterPressed(function(value)
        setValue(value)
    end)
    editbox.accentColor = "pink"  -- Set editbox accent color to pink
    return editbox
end

local currentY = 0

local function CreateBorderedSection(parent, title, height)
    local section = AF.CreateBorderedFrame(parent, nil, 350, height or 120, nil, "pink")
    section:SetLabel(title, "pink")  -- Set label color to pink
    AF.SetPoint(section, "TOPLEFT", 10, -currentY)
    currentY = currentY + (height or 120) + 20  -- Increased spacing between sections
    return section
end

local function AddWidgetToSection(section, widget, x, y)
    AF.SetPoint(widget, "TOPLEFT", section, "TOPLEFT", x or 10, y or -35)  -- More space for section label
end

local function PopulateGeneralSettings(parent)
    local castbarSettings = GetCastbarSettings(currentUnit)
    if not castbarSettings then return end
    
    currentY = 50  -- Space for header text plus section spacing
    
    -- General Settings Section
    local generalSection = CreateBorderedSection(parent, "General Settings", 140)
    
    local enableCB = CreateCheckbox(generalSection, "Enable Castbar", 
        function() return castbarSettings.enabled end,
        function(value) UpdateCastbarSetting(currentUnit, "enabled", value) end)
    AddWidgetToSection(generalSection, enableCB, 10, -25)
    
    local widthSlider = CreateSlider(generalSection, "Width", 50, 400, 
        function() return castbarSettings.size and castbarSettings.size.width or 200 end,
        function(value) UpdateCastbarSetting(currentUnit, {"size", "width"}, value) end)
    AddWidgetToSection(generalSection, widthSlider, 10, -50)
    
    local heightSlider = CreateSlider(generalSection, "Height", 10, 50, 
        function() return castbarSettings.size and castbarSettings.size.height or 18 end,
        function(value) UpdateCastbarSetting(currentUnit, {"size", "height"}, value) end)
    AddWidgetToSection(generalSection, heightSlider, 10, -75)
    
    local scaleSlider = CreateSlider(generalSection, "Scale", 0.5, 2.0, 
        function() return castbarSettings.size and castbarSettings.size.scale or 1.0 end,
        function(value) UpdateCastbarSetting(currentUnit, {"size", "scale"}, value) end, 0.1)
    AddWidgetToSection(generalSection, scaleSlider, 10, -100)
    
    -- Position Settings Section
    local positionSection = CreateBorderedSection(parent, "Position Settings", 160)
    
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
    
    local anchorPointDD = CreateDropdown(positionSection, "Anchor Point", anchorOptions,
        function() return castbarSettings.position and castbarSettings.position.anchorPoint or "CENTER" end,
        function(value) UpdateCastbarSetting(currentUnit, {"position", "anchorPoint"}, value) end)
    AddWidgetToSection(positionSection, anchorPointDD, 10, -25)
    
    local anchorToDD = CreateDropdown(positionSection, "Anchor To", anchorOptions,
        function() return castbarSettings.position and castbarSettings.position.anchorTo or "CENTER" end,
        function(value) UpdateCastbarSetting(currentUnit, {"position", "anchorTo"}, value) end)
    AddWidgetToSection(positionSection, anchorToDD, 180, -25)
    
    local xOffsetSlider = CreateSlider(positionSection, "X Offset", -1000, 1000,
        function() return castbarSettings.position and castbarSettings.position.xOffset or 0 end,
        function(value) UpdateCastbarSetting(currentUnit, {"position", "xOffset"}, value) end)
    AddWidgetToSection(positionSection, xOffsetSlider, 10, -75)
    
    local yOffsetSlider = CreateSlider(positionSection, "Y Offset", -1000, 1000,
        function() return castbarSettings.position and castbarSettings.position.yOffset or -20 end,
        function(value) UpdateCastbarSetting(currentUnit, {"position", "yOffset"}, value) end)
    AddWidgetToSection(positionSection, yOffsetSlider, 10, -100)
    
    local anchorFrameInput = CreateTextInput(positionSection, "Anchor Frame",
        function() return castbarSettings.position and castbarSettings.position.anchorFrame or "MilaUI_Player" end,
        function(value) UpdateCastbarSetting(currentUnit, {"position", "anchorFrame"}, value) end)
    AddWidgetToSection(positionSection, anchorFrameInput, 180, -75)
end

local function PopulateColorSettings(parent)
    local castbarSettings = GetCastbarSettings(currentUnit)
    if not castbarSettings then return end
    
    
    -- Color Settings Section
    local colorSection = CreateBorderedSection(parent, "Color Settings", 160)
    
    -- Cast Color
    local castColorPicker = CreateColorPicker(colorSection, "Cast Color",
        function() return castbarSettings.colors and castbarSettings.colors.cast or {0, 1, 1, 1} end,
        function(value) UpdateCastbarSetting(currentUnit, {"colors", "cast"}, value) end)
    AddWidgetToSection(colorSection, castColorPicker, 10, -25)
    
    -- Channel Color
    local channelColorPicker = CreateColorPicker(colorSection, "Channel Color",
        function() return castbarSettings.colors and castbarSettings.colors.channel or {0.5, 0.3, 0.9, 1} end,
        function(value) UpdateCastbarSetting(currentUnit, {"colors", "channel"}, value) end)
    AddWidgetToSection(colorSection, channelColorPicker, 180, -25)
    
    -- Uninterruptible Color
    local uninterruptibleColorPicker = CreateColorPicker(colorSection, "Uninterruptible Color",
        function() return castbarSettings.colors and castbarSettings.colors.uninterruptible or {0.8, 0.8, 0.8, 1} end,
        function(value) UpdateCastbarSetting(currentUnit, {"colors", "uninterruptible"}, value) end)
    AddWidgetToSection(colorSection, uninterruptibleColorPicker, 10, -75)
    
    -- Interrupt Color
    local interruptColorPicker = CreateColorPicker(colorSection, "Interrupt Color",
        function() return castbarSettings.colors and castbarSettings.colors.interrupt or {1, 0.2, 0.2, 1} end,
        function(value) UpdateCastbarSetting(currentUnit, {"colors", "interrupt"}, value) end)
    AddWidgetToSection(colorSection, interruptColorPicker, 180, -75)
    
    -- Completion Color
    local completionColorPicker = CreateColorPicker(colorSection, "Completion Color",
        function() return castbarSettings.colors and castbarSettings.colors.completion or {0.2, 1.0, 1.0, 1.0} end,
        function(value) UpdateCastbarSetting(currentUnit, {"colors", "completion"}, value) end)
    AddWidgetToSection(colorSection, completionColorPicker, 10, -125)
end

local function PopulateIconSettings(parent)
    local castbarSettings = GetCastbarSettings(currentUnit)
    if not castbarSettings then return end
    
    -- Icon Settings Section
    local iconSection = CreateBorderedSection(parent, "Icon Settings", 120)
    
    local iconEnabledCB = CreateCheckbox(iconSection, "Enable Icon",
        function() return castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.show end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "icon", "show"}, value) end)
    AddWidgetToSection(iconSection, iconEnabledCB, 10, -25)
    
    local iconSizeSlider = CreateSlider(iconSection, "Icon Size", 10, 100,
        function() return castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.size or 24 end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "icon", "size"}, value) end, 1)
    AddWidgetToSection(iconSection, iconSizeSlider, 10, -50)
    
    local iconXOffsetSlider = CreateSlider(iconSection, "Icon X Offset", -50, 50,
        function() return castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.xOffset or 4 end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "icon", "xOffset"}, value) end, 1)
    AddWidgetToSection(iconSection, iconXOffsetSlider, 180, -25)
    
    local iconYOffsetSlider = CreateSlider(iconSection, "Icon Y Offset", -50, 50,
        function() return castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.yOffset or 0 end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "icon", "yOffset"}, value) end, 1)
    AddWidgetToSection(iconSection, iconYOffsetSlider, 180, -50)
end

local function PopulateTextSettings(parent)
    local castbarSettings = GetCastbarSettings(currentUnit)
    if not castbarSettings then return end
    
    -- Text Settings Section
    local textSection = CreateBorderedSection(parent, "Text Settings", 200)
    
    local textEnabledCB = CreateCheckbox(textSection, "Enable Text",
        function() return castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.show end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "text", "show"}, value) end)
    AddWidgetToSection(textSection, textEnabledCB, 10, -25)
    
    local timeEnabledCB = CreateCheckbox(textSection, "Show Timer",
        function() return castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.show end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "timer", "show"}, value) end)
    AddWidgetToSection(textSection, timeEnabledCB, 180, -25)
    
    local textSizeSlider = CreateSlider(textSection, "Text Size", 6, 32,
        function() return castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.size or 12 end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "text", "size"}, value) end, 1)
    AddWidgetToSection(textSection, textSizeSlider, 10, -50)
    
    local timeSizeSlider = CreateSlider(textSection, "Timer Size", 6, 32,
        function() return castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.size or 10 end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "timer", "size"}, value) end, 1)
    AddWidgetToSection(textSection, timeSizeSlider, 180, -50)
    
    local fontFlagOptions = {
        {text = "None", value = "NONE"},
        {text = "Outline", value = "OUTLINE"},
        {text = "Thick Outline", value = "THICKOUTLINE"},
        {text = "Monochrome", value = "MONOCHROME"}
    }
    
    local textFontFlagsDD = CreateDropdown(textSection, "Text Font Flags", fontFlagOptions,
        function() return castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.fontFlags or "OUTLINE" end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "text", "fontFlags"}, value) end)
    AddWidgetToSection(textSection, textFontFlagsDD, 10, -100)
    
    local timerFontFlagsDD = CreateDropdown(textSection, "Timer Font Flags", fontFlagOptions,
        function() return castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.fontFlags or "OUTLINE" end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "timer", "fontFlags"}, value) end)
    AddWidgetToSection(textSection, timerFontFlagsDD, 180, -100)
    
    local textColorPicker = CreateColorPicker(textSection, "Text Color",
        function() return castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.fontColor or {1, 1, 1, 1} end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "text", "fontColor"}, value) end)
    AddWidgetToSection(textSection, textColorPicker, 10, -150)
    
    local timerColorPicker = CreateColorPicker(textSection, "Timer Color",
        function() return castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.fontColor or {1, 1, 1, 1} end,
        function(value) UpdateCastbarSetting(currentUnit, {"display", "timer", "fontColor"}, value) end)
    AddWidgetToSection(textSection, timerColorPicker, 180, -150)
end

local function PopulateTextureSettings(parent)
    local castbarSettings = GetCastbarSettings(currentUnit)
    if not castbarSettings then return end
    
    -- Texture Settings Section
    local textureSection = CreateBorderedSection(parent, "Texture Settings", 250)
    
    -- Main texture
    local mainTexturePicker = CreateTexturePicker(textureSection, "Main Texture",
        function() return castbarSettings.textures and castbarSettings.textures.main or "Smooth" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "main"}, value) end)
    AddWidgetToSection(textureSection, mainTexturePicker, 10, -25)
    
    -- Cast texture
    local castTexturePicker = CreateTexturePicker(textureSection, "Cast Texture",
        function() return castbarSettings.textures and castbarSettings.textures.cast or "Smooth" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "cast"}, value) end)
    AddWidgetToSection(textureSection, castTexturePicker, 180, -25)
    
    -- Channel texture
    local channelTexturePicker = CreateTexturePicker(textureSection, "Channel Texture",
        function() return castbarSettings.textures and castbarSettings.textures.channel or "Smooth" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "channel"}, value) end)
    AddWidgetToSection(textureSection, channelTexturePicker, 10, -75)
    
    -- Uninterruptible texture
    local uninterruptibleTexturePicker = CreateTexturePicker(textureSection, "Uninterruptible Texture",
        function() return castbarSettings.textures and castbarSettings.textures.uninterruptible or "Smooth" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "uninterruptible"}, value) end)
    AddWidgetToSection(textureSection, uninterruptibleTexturePicker, 180, -75)
    
    -- Interrupt texture
    local interruptTexturePicker = CreateTexturePicker(textureSection, "Interrupt Texture",
        function() return castbarSettings.textures and castbarSettings.textures.interrupt or "Smooth" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "interrupt"}, value) end)
    AddWidgetToSection(textureSection, interruptTexturePicker, 10, -125)
    
    -- Cast completion texture
    local castCompletionTexturePicker = CreateTexturePicker(textureSection, "Cast Completion Texture",
        function() return castbarSettings.textures and castbarSettings.textures.castCompletion or "Smooth" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "castCompletion"}, value) end)
    AddWidgetToSection(textureSection, castCompletionTexturePicker, 180, -125)
    
    -- Channel completion texture
    local channelCompletionTexturePicker = CreateTexturePicker(textureSection, "Channel Completion Texture",
        function() return castbarSettings.textures and castbarSettings.textures.channelCompletion or "Smooth" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "channelCompletion"}, value) end)
    AddWidgetToSection(textureSection, channelCompletionTexturePicker, 10, -175)
    
    -- Info label
    local infoLabel = AF.CreateFontString(textureSection, "Note: Flash textures remain hardcoded for visual consistency", "gray")
    AF.SetFont(infoLabel, nil, 10)
    AddWidgetToSection(textureSection, infoLabel, 10, -225)
end

local function PopulateSparkSettings(parent)
    local castbarSettings = GetCastbarSettings(currentUnit)
    if not castbarSettings then return end
    
    -- Spark Settings Section
    local sparkSection = CreateBorderedSection(parent, "Spark Settings", 140)
    
    local sparkEnabledCB = CreateCheckbox(sparkSection, "Enable Spark",
        function() return castbarSettings.spark and castbarSettings.spark.enabled or true end,
        function(value) UpdateCastbarSetting(currentUnit, {"spark", "enabled"}, value) end)
    AddWidgetToSection(sparkSection, sparkEnabledCB, 10, -25)
    
    local sparkWidthSlider = CreateSlider(sparkSection, "Spark Width", 1, 50,
        function() return castbarSettings.spark and castbarSettings.spark.width or 10 end,
        function(value) UpdateCastbarSetting(currentUnit, {"spark", "width"}, value) end, 1)
    AddWidgetToSection(sparkSection, sparkWidthSlider, 10, -50)
    
    local sparkHeightSlider = CreateSlider(sparkSection, "Spark Height", 1, 100,
        function() return castbarSettings.spark and castbarSettings.spark.height or 30 end,
        function(value) UpdateCastbarSetting(currentUnit, {"spark", "height"}, value) end, 1)
    AddWidgetToSection(sparkSection, sparkHeightSlider, 180, -50)
    
    local sparkColorPicker = CreateColorPicker(sparkSection, "Spark Color",
        function() return castbarSettings.spark and castbarSettings.spark.color or {1, 1, 1, 1} end,
        function(value) UpdateCastbarSetting(currentUnit, {"spark", "color"}, value) end)
    AddWidgetToSection(sparkSection, sparkColorPicker, 10, -100)
    
    local sparkTextureInput = CreateTextInput(sparkSection, "Spark Texture",
        function() return castbarSettings.textures and castbarSettings.textures.spark or "Interface\\Buttons\\WHITE8X8" end,
        function(value) UpdateCastbarSetting(currentUnit, {"textures", "spark"}, value) end)
    AddWidgetToSection(sparkSection, sparkTextureInput, 180, -100)
end

local function PopulateAdvancedSettings(parent)
    local castbarSettings = GetCastbarSettings(currentUnit)
    if not castbarSettings then return end
    
    -- Advanced Settings Section
    local advancedSection = CreateBorderedSection(parent, "Advanced Settings", 160)
    
    local hideTradeSkillsCB = CreateCheckbox(advancedSection, "Hide Trade Skills",
        function() return castbarSettings.hideTradeSkills end,
        function(value) UpdateCastbarSetting(currentUnit, "hideTradeSkills", value) end)
    AddWidgetToSection(advancedSection, hideTradeSkillsCB, 10, -25)
    
    local showBorderCB = CreateCheckbox(advancedSection, "Show Border",
        function() return castbarSettings.border ~= false end,
        function(value) UpdateCastbarSetting(currentUnit, "border", value) end)
    AddWidgetToSection(advancedSection, showBorderCB, 180, -25)
    
    local borderSizeSlider = CreateSlider(advancedSection, "Border Size", 0, 10,
        function() return castbarSettings.borderSize or 1 end,
        function(value) UpdateCastbarSetting(currentUnit, "borderSize", value) end, 0.1)
    AddWidgetToSection(advancedSection, borderSizeSlider, 10, -50)
    
    local holdTimeSlider = CreateSlider(advancedSection, "Hold Time", 0, 5,
        function() return castbarSettings.holdTime or 0.5 end,
        function(value) UpdateCastbarSetting(currentUnit, "holdTime", value) end, 0.05)
    AddWidgetToSection(advancedSection, holdTimeSlider, 180, -50)
    
    -- Player-specific settings
    if currentUnit == "player" then
        local showSafeZoneCB = CreateCheckbox(advancedSection, "Show Safe Zone (Latency)",
            function() return castbarSettings.showSafeZone end,
            function(value) UpdateCastbarSetting(currentUnit, "showSafeZone", value) end)
        AddWidgetToSection(advancedSection, showSafeZoneCB, 10, -100)
        
        local safeZoneColorPicker = CreateColorPicker(advancedSection, "Safe Zone Color",
            function() return castbarSettings.safeZoneColor or {1, 0, 0, 0.6} end,
            function(value) UpdateCastbarSetting(currentUnit, "safeZoneColor", value) end)
        AddWidgetToSection(advancedSection, safeZoneColorPicker, 180, -100)
    end
    
    local showShieldCB = CreateCheckbox(advancedSection, "Show Shield (Non-Interruptible)",
        function() return castbarSettings.showShield end,
        function(value) UpdateCastbarSetting(currentUnit, "showShield", value) end)
    AddWidgetToSection(advancedSection, showShieldCB, 10, -125)
end

local function CreateUnitTabs(parent)
    local tabContainer = AF.CreateFrame(parent)
    tabContainer:SetHeight(30)
    
    local tabs = {}
    local tabWidth = 100
    
    for i, unit in ipairs(units) do
        local tab = AF.CreateButton(tabContainer, unit.display, 
            currentUnit == unit.key and "pink" or "pink_transparent", 
            tabWidth, 25)
        
        tab:SetPoint("LEFT", (i-1) * (tabWidth + 5), 0)
        
        tab:SetOnClick(function()
            if currentUnit ~= unit.key then
                currentUnit = unit.key
                for _, t in ipairs(tabs) do
                    t:SetColor("pink_transparent")
                end
                tab:SetColor("pink")
                MilaUI:RefreshCastbarGUIContent()
            end
        end)
        
        tabs[i] = tab
    end
    
    return tabContainer
end

local function CreateTabContent(parent)
    local content = AF.CreateScrollFrame(parent)
    
    -- Unit header text
    local testLabel = AF.CreateFontString(content.scrollContent, "Castbar Settings for " .. currentUnit:upper(), "white")
    AF.SetPoint(testLabel, "TOPLEFT", 10, -10)
    
    PopulateGeneralSettings(content.scrollContent)
    PopulateColorSettings(content.scrollContent)
    PopulateTextureSettings(content.scrollContent)
    PopulateIconSettings(content.scrollContent)
    PopulateTextSettings(content.scrollContent)
    PopulateSparkSettings(content.scrollContent)
    PopulateAdvancedSettings(content.scrollContent)
    
    content:SetContentHeight(1500)  -- Increased for all sections including textures
    
    return content
end

function MilaUI:RefreshCastbarGUIContent()
    if not cleanCastbarGUI or not cleanCastbarGUI.contentFrame then return end
    
    cleanCastbarGUI.contentFrame:Hide()
    cleanCastbarGUI.contentFrame = CreateTabContent(cleanCastbarGUI)
    cleanCastbarGUI.contentFrame:SetPoint("TOPLEFT", cleanCastbarGUI.tabFrame, "BOTTOMLEFT", 0, -10)
    cleanCastbarGUI.contentFrame:SetPoint("BOTTOMRIGHT", cleanCastbarGUI, "BOTTOMRIGHT", -20, 50)
end

function MilaUI:CreateCleanCastbarGUI()
    if cleanCastbarGUI then
        cleanCastbarGUI:Hide()
        cleanCastbarGUI = nil
    end
    
    cleanCastbarGUI = AF.CreateHeaderedFrame(AF.UIParent, "MilaUI_CleanCastbarGUI",
        "|TInterface\\AddOns\\Mila_UI\\Media\\logo.tga:16:16|t" .. 
        AF.GetGradientText(" Mila UI Castbar Settings", "pink", "lavender") .. 
        " |TInterface\\AddOns\\Mila_UI\\Media\\logo.tga:16:16|t",
        920, 720)
    cleanCastbarGUI:SetPoint("CENTER")
    cleanCastbarGUI:SetFrameLevel(500)
    cleanCastbarGUI:SetTitleJustify("CENTER")
    
    AF.ApplyCombatProtectionToFrame(cleanCastbarGUI)
    
    cleanCastbarGUI.tabFrame = CreateUnitTabs(cleanCastbarGUI)
    cleanCastbarGUI.tabFrame:SetPoint("TOPLEFT", cleanCastbarGUI, "TOPLEFT", 20, -60)
    cleanCastbarGUI.tabFrame:SetPoint("TOPRIGHT", cleanCastbarGUI, "TOPRIGHT", -20, -60)
    
    cleanCastbarGUI.contentFrame = CreateTabContent(cleanCastbarGUI)
    cleanCastbarGUI.contentFrame:SetPoint("TOPLEFT", cleanCastbarGUI.tabFrame, "BOTTOMLEFT", 0, -10)
    cleanCastbarGUI.contentFrame:SetPoint("BOTTOMRIGHT", cleanCastbarGUI, "BOTTOMRIGHT", -20, 50)
    
    local closeBtn = AF.CreateButton(cleanCastbarGUI, "Close", "pink", 80, 25)
    closeBtn:SetPoint("BOTTOMRIGHT", cleanCastbarGUI, "BOTTOMRIGHT", -20, 15)
    closeBtn:SetOnClick(function()
        cleanCastbarGUI:Hide()
    end)
    
    local reloadBtn = AF.CreateButton(cleanCastbarGUI, "Reload UI", "lavender", 80, 25)
    reloadBtn:SetPoint("BOTTOMRIGHT", closeBtn, "BOTTOMLEFT", -10, 0)
    reloadBtn:SetOnClick(function()
        ReloadUI()
    end)
    
    cleanCastbarGUI:Show()
end

SLASH_MILACAST1 = "/muicast"
SlashCmdList["MILACAST"] = function(msg)
    MilaUI:CreateCleanCastbarGUI()
end

function MilaUI:RefreshCastbars()
    -- Refresh the specific unit's castbar if it exists
    local frame = nil
    if currentUnit == "player" then
        frame = MilaUI.PlayerFrame
    elseif currentUnit == "target" then
        frame = MilaUI.TargetFrame
    elseif currentUnit == "focus" then
        frame = MilaUI.FocusFrame
    elseif currentUnit == "pet" then
        frame = MilaUI.PetFrame
    elseif currentUnit == "boss" then
        frame = MilaUI.BossFrames and MilaUI.BossFrames[1]
    end
    
    if frame and frame.castBar and MilaUI.NewCastbarSystem then
        local castbarSettings = GetCastbarSettings(currentUnit)
        if castbarSettings and castbarSettings.enabled then
            -- Properly cleanup old castbar
            if MilaUI.NewCastbarSystem.CleanupCastBar then
                MilaUI.NewCastbarSystem.CleanupCastBar(frame.castBar)
            end
            
            -- Remove all child frames and textures
            if frame.castBar.border then
                frame.castBar.border:Hide()
                frame.castBar.border:SetParent(nil)
            end
            if frame.castBar.bg then
                frame.castBar.bg:Hide()
            end
            if frame.castBar.spark then
                frame.castBar.spark:Hide()
            end
            if frame.castBar.icon then
                frame.castBar.icon:Hide()
            end
            if frame.castBar.text then
                frame.castBar.text:Hide()
            end
            if frame.castBar.timer then
                frame.castBar.timer:Hide()
            end
            
            -- Hide and remove the main castbar
            frame.castBar:Hide()
            frame.castBar:ClearAllPoints()
            frame.castBar:SetParent(nil)
            frame.castBar = nil
            
            -- Create new castbar with updated settings
            local result = MilaUI.NewCastbarSystem.CreateCleanCastBar(frame, currentUnit, castbarSettings)
        end
    else
        print(lavender .. "MilaUI:" .. pink .. " Castbar settings saved. Type '/reload' to apply all changes.")
    end
end
