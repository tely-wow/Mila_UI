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
        MilaUI:RefreshCastbars()
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
    local colorPicker = AF.CreateColorPicker(parent, label, value, function(r, g, b, a)
        setValue({r, g, b, a})
    end)
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
end

local function PopulateIconSettings(parent)
end

local function PopulateTextSettings(parent)
end

local function PopulateSparkSettings(parent)
end

local function PopulatePositionSettings(parent)
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
    
    content:SetContentHeight(450)  -- Increased for better spacing
    
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
            print(lavender .. "MilaUI:" .. pink .. " " .. currentUnit:upper() .. " castbar updated with new settings.")
        end
    else
        print(lavender .. "MilaUI:" .. pink .. " Castbar settings saved. Type '/reload' to apply all changes.")
    end
end
