local _, MilaUI = ...
-- Explicitly load AbstractFramework if it's not already loaded
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- Color constants for UI elements
local lavender = "|cffBFACE2"
local pink = "|cffFF9CD0"
local green = "|cff00FF00"
local red = "|cffFF0000"

-- Main GUI frame reference
local cleanCastbarGUI = nil

-- Helper function to create vertical spacers
local function CreateVerticalSpacer(parent, height)
    -- Create a simple frame instead of using CreateSimpleGroup
    local spacer = CreateFrame("Frame", nil, parent)
    spacer:SetHeight(height or 10)
    spacer:SetWidth(1) -- Width doesn't matter for a vertical spacer
    return spacer
end

-- Helper function to create section headers
local function CreateLargeHeading(parent, text)
    local heading = AF.CreateFontString(parent, text, "accent")
    heading:SetFont(heading:GetFont(), 14, "OUTLINE")
    return heading
end

-- Helper function to create unit tabs
local function CreateUnitTab(parent, unitName, isSelected)
    local tab = AF.CreateButton(parent, unitName, isSelected and "accent" or "accent_transparent", 80, 25)
    return tab
end

-- Helper function to get unit-specific setting key
local function GetUnitSettingKey(unit, setting)
    return unit:upper() .. "_" .. setting
end

-- Helper function to create color picker
local function CreateColorPicker(parent, label, r, g, b, a, callback)
    local colorPicker = AF.CreateColorPicker(parent, label, {r, g, b, a}, callback)
    return colorPicker
end

-- Function to create the castbar GUI
function MilaUI:CreateCleanCastbarGUI()
    if cleanCastbarGUI then
        cleanCastbarGUI:Show()
        return
    end
    
    -- Create main frame
    cleanCastbarGUI = AF.CreateHeaderedFrame(AF.UIParent, "MilaUI_CleanCastbarGUI",
        "|TInterface\\AddOns\\Mila_UI\\Media\\logo.tga:16:16|t" .. 
        AF.GetGradientText(" Mila UI  - Version:", "pink", "lavender") .. 
        " " .. AF.WrapTextInColor(AF.GetAddOnVersion("MilaUI"), "lavender") .. " |TInterface\\AddOns\\Mila_UI\\Media\\logo.tga:16:16|t",
        920, 720)
    cleanCastbarGUI:SetPoint("CENTER")
    cleanCastbarGUI:SetFrameLevel(500)
    cleanCastbarGUI:SetTitleJustify("CENTER")
    
    -- Apply combat protection
    AF.ApplyCombatProtectionToFrame(cleanCastbarGUI)
    
    -- Create unit tabs
    local tabContainer = CreateFrame("Frame", nil, cleanCastbarGUI)
    tabContainer:SetSize(cleanCastbarGUI:GetWidth() - 20, 30)
    tabContainer:SetPoint("TOPLEFT", 10, -10)
    
    local playerTab = CreateUnitTab(tabContainer, "Player", true)
    AF.SetPoint(playerTab, "TOPLEFT", 0, 0)
    
    local targetTab = CreateUnitTab(tabContainer, "Target", false)
    AF.SetPoint(targetTab, "TOPLEFT", playerTab, "TOPRIGHT", 5, 0)
    
    local focusTab = CreateUnitTab(tabContainer, "Focus", false)
    AF.SetPoint(focusTab, "TOPLEFT", targetTab, "TOPRIGHT", 5, 0)
    
    -- Create content frames for each unit
    local contentContainer = CreateFrame("Frame", nil, cleanCastbarGUI)
    contentContainer:SetSize(cleanCastbarGUI:GetWidth() - 20, cleanCastbarGUI:GetHeight() - 80)
    contentContainer:SetPoint("TOPLEFT", 10, -50)
    
    local playerContent = AF.CreateScrollFrame(contentContainer, nil, contentContainer:GetWidth(), contentContainer:GetHeight())
    AF.SetPoint(playerContent, "TOPLEFT", 0, 0)
    AF.SetPoint(playerContent, "BOTTOMRIGHT", 0, 0)
    
    local targetContent = AF.CreateScrollFrame(contentContainer, nil, contentContainer:GetWidth(), contentContainer:GetHeight())
    AF.SetPoint(targetContent, "TOPLEFT", 0, 0)
    AF.SetPoint(targetContent, "BOTTOMRIGHT", 0, 0)
    targetContent:Hide()
    
    local focusContent = AF.CreateScrollFrame(contentContainer, nil, contentContainer:GetWidth(), contentContainer:GetHeight())
    AF.SetPoint(focusContent, "TOPLEFT", 0, 0)
    AF.SetPoint(focusContent, "BOTTOMRIGHT", 0, 0)
    focusContent:Hide()
    
    -- Tab switching functionality
    AF.CreateButtonGroup({playerTab, targetTab, focusTab}, function(id)
        playerContent:Hide()
        targetContent:Hide()
        focusContent:Hide()
        
        if id == playerTab.id then
            playerContent:Show()
        elseif id == targetTab.id then
            targetContent:Show()
        elseif id == focusTab.id then
            focusContent:Show()
        end
    end)
    
    -- Populate content for each unit
    local units = {"player", "target", "focus"}
    local contentFrames = {playerContent, targetContent, focusContent}
    
    for i, unit in ipairs(units) do
        local content = contentFrames[i].scrollContent
        local unitUpper = unit:upper()
        
        -- Enable/Disable checkbox
        local enabledKey = GetUnitSettingKey(unit, "CASTBAR_ENABLED")
        local enabledCheckbox = AF.CreateCheckButton(content, "Enable Clean Castbar", function(checked)
            MilaUI.DB.profile.castBars[enabledKey] = checked
            -- Also update the useCleanCastbar setting in the unitframe settings
            if MilaUI.DB.profile.Unitframes[MilaUI:GetUnitKey(unit)] and 
               MilaUI.DB.profile.Unitframes[MilaUI:GetUnitKey(unit)].Castbar then
                MilaUI.DB.profile.Unitframes[MilaUI:GetUnitKey(unit)].Castbar.useCleanCastbar = checked
            end
        end)
        AF.SetPoint(enabledCheckbox, "TOPLEFT", 10, -10)
        enabledCheckbox:SetChecked(MilaUI.DB.profile.castBars[enabledKey] or false)
        
        -- Create vertical spacer
        local spacer1 = CreateVerticalSpacer(content)
        AF.SetPoint(spacer1, "TOPLEFT", enabledCheckbox, "BOTTOMLEFT", 0, -5)
        
        -- Position and Size section
        local sizeHeader = CreateLargeHeading(content, "Position and Size")
        AF.SetPoint(sizeHeader, "TOPLEFT", spacer1, "BOTTOMLEFT", 0, -5)
        
        -- Width slider
        local widthKey = GetUnitSettingKey(unit, "CASTBAR_WIDTH")
        local widthSlider = AF.CreateSlider(content, "Width", 250, 50, 400, 1, true)
        AF.SetPoint(widthSlider, "TOPLEFT", sizeHeader, "BOTTOMLEFT", 10, -20)
        widthSlider:SetValue(MilaUI.DB.profile.castBars[widthKey] or 125)
        widthSlider:SetAfterValueChanged(function(value)
            MilaUI.DB.profile.castBars[widthKey] = value
        end)
        
        -- Height slider
        local heightKey = GetUnitSettingKey(unit, "CASTBAR_HEIGHT")
        local heightSlider = AF.CreateSlider(content, "Height", 250, 5, 50, 1, true)
        AF.SetPoint(heightSlider, "TOPLEFT", widthSlider, "BOTTOMLEFT", 0, -20)
        heightSlider:SetValue(MilaUI.DB.profile.castBars[heightKey] or 18)
        heightSlider:SetAfterValueChanged(function(value)
            MilaUI.DB.profile.castBars[heightKey] = value
        end)
        
        -- Scale slider
        local scaleKey = GetUnitSettingKey(unit, "CASTBAR_SCALE")
        local scaleSlider = AF.CreateSlider(content, "Scale", 250, 0.5, 2, 0.05, true)
        AF.SetPoint(scaleSlider, "TOPLEFT", heightSlider, "BOTTOMLEFT", 0, -20)
        scaleSlider:SetValue(MilaUI.DB.profile.castBars[scaleKey] or 1.0)
        scaleSlider:SetAfterValueChanged(function(value)
            MilaUI.DB.profile.castBars[scaleKey] = value
        end)
        
        -- X Offset slider
        local xOffsetKey = GetUnitSettingKey(unit, "CASTBAR_X_OFFSET")
        local xOffsetSlider = AF.CreateSlider(content, "X Offset", 250, -200, 200, 1, true)
        AF.SetPoint(xOffsetSlider, "TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -20)
        xOffsetSlider:SetValue(MilaUI.DB.profile.castBars[xOffsetKey] or 0)
        xOffsetSlider:SetAfterValueChanged(function(value)
            MilaUI.DB.profile.castBars[xOffsetKey] = value
        end)
        
        -- Y Offset slider
        local yOffsetKey = GetUnitSettingKey(unit, "CASTBAR_Y_OFFSET")
        local yOffsetSlider = AF.CreateSlider(content, "Y Offset", 250, -200, 200, 1, true)
        AF.SetPoint(yOffsetSlider, "TOPLEFT", xOffsetSlider, "BOTTOMLEFT", 0, -20)
        yOffsetSlider:SetValue(MilaUI.DB.profile.castBars[yOffsetKey] or -20)
        yOffsetSlider:SetAfterValueChanged(function(value)
            MilaUI.DB.profile.castBars[yOffsetKey] = value
        end)
        
        -- Create vertical spacer
        local spacer2 = CreateVerticalSpacer(content)
        AF.SetPoint(spacer2, "TOPLEFT", yOffsetSlider, "BOTTOMLEFT", -10, -10)
        
        -- Display Options section
        local displayHeader = CreateLargeHeading(content, "Display Options")
        AF.SetPoint(displayHeader, "TOPLEFT", spacer2, "BOTTOMLEFT", 0, -5)
        
        -- Show Icon checkbox
        local showIconKey = GetUnitSettingKey(unit, "CASTBAR_SHOW_ICON")
        local showIconCheckbox = AF.CreateCheckButton(content, "Show Spell Icon", function(checked)
            MilaUI.DB.profile.castBars[showIconKey] = checked
        end)
        AF.SetPoint(showIconCheckbox, "TOPLEFT", displayHeader, "BOTTOMLEFT", 10, -10)
        showIconCheckbox:SetChecked(MilaUI.DB.profile.castBars[showIconKey] ~= false) -- Default to true
        
        -- Show Text checkbox
        local showTextKey = GetUnitSettingKey(unit, "CASTBAR_SHOW_TEXT")
        local showTextCheckbox = AF.CreateCheckButton(content, "Show Spell Name", function(checked)
            MilaUI.DB.profile.castBars[showTextKey] = checked
        end)
        AF.SetPoint(showTextCheckbox, "TOPLEFT", showIconCheckbox, "BOTTOMLEFT", 0, -10)
        showTextCheckbox:SetChecked(MilaUI.DB.profile.castBars[showTextKey] ~= false) -- Default to true
        
        -- Show Timer checkbox
        local showTimerKey = GetUnitSettingKey(unit, "CASTBAR_SHOW_TIMER")
        local showTimerCheckbox = AF.CreateCheckButton(content, "Show Cast Timer", function(checked)
            MilaUI.DB.profile.castBars[showTimerKey] = checked
        end)
        AF.SetPoint(showTimerCheckbox, "TOPLEFT", showTextCheckbox, "BOTTOMLEFT", 0, -10)
        showTimerCheckbox:SetChecked(MilaUI.DB.profile.castBars[showTimerKey] ~= false) -- Default to true
        
        -- Create vertical spacer
        local spacer3 = CreateVerticalSpacer(content)
        AF.SetPoint(spacer3, "TOPLEFT", showTimerCheckbox, "BOTTOMLEFT", -10, -10)
        
        -- Textures section
        local texturesHeader = CreateLargeHeading(content, "Textures")
        AF.SetPoint(texturesHeader, "TOPLEFT", spacer3, "BOTTOMLEFT", 0, -5)
        
        -- Cast Texture dropdown
        local castTextureKey = GetUnitSettingKey(unit, "CAST_TEXTURE")
        local castTextureDropdown = AF.CreateDropdown(content, 250, 10, "texture")
        AF.SetPoint(castTextureDropdown, "TOPLEFT", texturesHeader, "BOTTOMLEFT", 10, -20)
        castTextureDropdown:SetLabel("Cast Texture")
        
        -- Set up texture items for Cast Texture
        local castItems = {}
        local textures, textureNames = LSM:HashTable("statusbar"), LSM:List("statusbar")
        for _, name in ipairs(textureNames) do
            tinsert(castItems, {
                ["text"] = name,
                ["value"] = name,
                ["texture"] = textures[name],
                ["onClick"] = function()
                    MilaUI.DB.profile.castBars[castTextureKey] = name
                    castTextureDropdown:SetSelectedValue(name)
                end
            })
        end
        castTextureDropdown:SetItems(castItems)
        castTextureDropdown:SetSelectedValue(MilaUI.DB.profile.castBars[castTextureKey] or "g1")
        
        -- Channel Texture dropdown
        local channelTextureKey = GetUnitSettingKey(unit, "CHANNEL_TEXTURE")
        local channelTextureDropdown = AF.CreateDropdown(content, 250, 10, "texture")
        AF.SetPoint(channelTextureDropdown, "TOPLEFT", castTextureDropdown, "BOTTOMLEFT", 0, -20)
        channelTextureDropdown:SetLabel("Channel Texture")
        -- Set up texture items for Channel Texture
        local channelItems = {}
        for _, name in ipairs(textureNames) do
            tinsert(channelItems, {
                ["text"] = name,
                ["value"] = name,
                ["texture"] = textures[name],
                ["onClick"] = function()
                    MilaUI.DB.profile.castBars[channelTextureKey] = name
                    channelTextureDropdown:SetSelectedValue(name)
                end
            })
        end
        channelTextureDropdown:SetItems(channelItems)
        channelTextureDropdown:SetSelectedValue(MilaUI.DB.profile.castBars[channelTextureKey] or "g1")
        
        -- Uninterruptible Texture dropdown
        local uninterruptibleTextureKey = GetUnitSettingKey(unit, "UNINTERRUPTIBLE_TEXTURE")
        local uninterruptibleTextureDropdown = AF.CreateDropdown(content, 250, 10, "texture")
        AF.SetPoint(uninterruptibleTextureDropdown, "TOPLEFT", channelTextureDropdown, "BOTTOMLEFT", 0, -20)
        uninterruptibleTextureDropdown:SetLabel("Uninterruptible Texture")
        -- Set up texture items for Uninterruptible Texture
        local uninterruptibleItems = {}
        for _, name in ipairs(textureNames) do
            tinsert(uninterruptibleItems, {
                ["text"] = name,
                ["value"] = name,
                ["texture"] = textures[name],
                ["onClick"] = function()
                    MilaUI.DB.profile.castBars[uninterruptibleTextureKey] = name
                    uninterruptibleTextureDropdown:SetSelectedValue(name)
                end
            })
        end
        uninterruptibleTextureDropdown:SetItems(uninterruptibleItems)
        uninterruptibleTextureDropdown:SetSelectedValue(MilaUI.DB.profile.castBars[uninterruptibleTextureKey] or "g1")
        
        -- Interrupt Texture dropdown
        local interruptTextureKey = GetUnitSettingKey(unit, "INTERRUPT_TEXTURE")
        local interruptTextureDropdown = AF.CreateDropdown(content, 250, 10, "texture")
        AF.SetPoint(interruptTextureDropdown, "TOPLEFT", uninterruptibleTextureDropdown, "BOTTOMLEFT", 0, -20)
        interruptTextureDropdown:SetLabel("Interrupt Texture")
        -- Set up texture items for Interrupt Texture
        local interruptItems = {}
        for _, name in ipairs(textureNames) do
            tinsert(interruptItems, {
                ["text"] = name,
                ["value"] = name,
                ["texture"] = textures[name],
                ["onClick"] = function()
                    MilaUI.DB.profile.castBars[interruptTextureKey] = name
                    interruptTextureDropdown:SetSelectedValue(name)
                end
            })
        end
        interruptTextureDropdown:SetItems(interruptItems)
        interruptTextureDropdown:SetSelectedValue(MilaUI.DB.profile.castBars[interruptTextureKey] or "g1")
        
        -- Create vertical spacer
        local spacer4 = CreateVerticalSpacer(content)
        AF.SetPoint(spacer4, "TOPLEFT", interruptTextureDropdown, "BOTTOMLEFT", -10, -10)
        
        -- Colors section
        local colorsHeader = CreateLargeHeading(content, "Colors")
        AF.SetPoint(colorsHeader, "TOPLEFT", spacer4, "BOTTOMLEFT", 0, -5)
        
        -- Cast Color picker
        local castColorKey = GetUnitSettingKey(unit, "CAST_COLOR")
        local castColor = MilaUI.DB.profile.castBars[castColorKey] or {0, 1, 1, 1}
        local castColorPicker = CreateColorPicker(content, "Cast Color", castColor[1], castColor[2], castColor[3], castColor[4], function(r, g, b, a)
            MilaUI.DB.profile.castBars[castColorKey] = {r, g, b, a}
        end)
        AF.SetPoint(castColorPicker, "TOPLEFT", colorsHeader, "BOTTOMLEFT", 10, -20)
        
        -- Channel Color picker
        local channelColorKey = GetUnitSettingKey(unit, "CHANNEL_COLOR")
        local channelColor = MilaUI.DB.profile.castBars[channelColorKey] or {0.5, 0.3, 0.9, 1}
        local channelColorPicker = CreateColorPicker(content, "Channel Color", channelColor[1], channelColor[2], channelColor[3], channelColor[4], function(r, g, b, a)
            MilaUI.DB.profile.castBars[channelColorKey] = {r, g, b, a}
        end)
        AF.SetPoint(channelColorPicker, "TOPLEFT", castColorPicker, "BOTTOMLEFT", 0, -20)
        
        -- Uninterruptible Color picker
        local uninterruptibleColorKey = GetUnitSettingKey(unit, "UNINTERRUPTIBLE_COLOR")
        local uninterruptibleColor = MilaUI.DB.profile.castBars[uninterruptibleColorKey] or {0.8, 0.8, 0.8, 1}
        local uninterruptibleColorPicker = CreateColorPicker(content, "Uninterruptible Color", uninterruptibleColor[1], uninterruptibleColor[2], uninterruptibleColor[3], uninterruptibleColor[4], function(r, g, b, a)
            MilaUI.DB.profile.castBars[uninterruptibleColorKey] = {r, g, b, a}
        end)
        AF.SetPoint(uninterruptibleColorPicker, "TOPLEFT", channelColorPicker, "BOTTOMLEFT", 0, -20)
        
        -- Interrupt Color picker
        local interruptColorKey = GetUnitSettingKey(unit, "INTERRUPT_COLOR")
        local interruptColor = MilaUI.DB.profile.castBars[interruptColorKey] or {1, 0.2, 0.2, 1}
        local interruptColorPicker = CreateColorPicker(content, "Interrupt Color", interruptColor[1], interruptColor[2], interruptColor[3], interruptColor[4], function(r, g, b, a)
            MilaUI.DB.profile.castBars[interruptColorKey] = {r, g, b, a}
        end)
        AF.SetPoint(interruptColorPicker, "TOPLEFT", uninterruptibleColorPicker, "BOTTOMLEFT", 0, -20)
        
        -- Set content height for proper scrolling
        local contentHeight = 700 -- Adjust based on actual content
        contentFrames[i]:SetContentHeight(contentHeight)
    end
    
    -- Add reload UI button
    local reloadButton = AF.CreateButton(cleanCastbarGUI, "Reload UI", "accent", 100, 25)
    AF.SetPoint(reloadButton, "BOTTOMRIGHT", -10, 10)
    reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    -- Add apply button
    local applyButton = AF.CreateButton(cleanCastbarGUI, "Apply Changes", "green", 120, 25)
    AF.SetPoint(applyButton, "RIGHT", reloadButton, "LEFT", -10, 0)
    applyButton:SetScript("OnClick", function()
        -- Refresh castbars if possible
        if MilaUI.RefreshCastbars then
            MilaUI.RefreshCastbars()
            AF.ShowNotificationText("Castbar settings applied!", "green")
        else
            AF.ShowNotificationText("Reload UI to apply all changes", "accent")
        end
    end)
end

-- Register slash command
SLASH_MILACAST1 = "/muicast"
SlashCmdList["MILACAST"] = function(msg)
    MilaUI:CreateCleanCastbarGUI()
end

-- Add a refresh castbars function
function MilaUI:RefreshCastbars()
    -- This function would need to be implemented to refresh castbars without reload
    -- For now, just show a message
    print(lavender .. "MilaUI:" .. pink .. " Castbar settings updated. Some changes may require a UI reload.")
end
