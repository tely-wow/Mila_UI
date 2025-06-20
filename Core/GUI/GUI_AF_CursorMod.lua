local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")

-- Cursor Mod Tab Implementation
function MilaUI:CreateAFCursorModTab(parent)
    -- Get cursor mod module
    local MilaUIAddon = LibStub("AceAddon-3.0"):GetAddon("MilaUI")
    local CursorMod = MilaUIAddon:GetModule("CursorMod")
    
    -- Layout constants
    local leftCol = 20
    local rightCol = 350
    local currentY = 20
    local lineHeight = 28
    local sectionSpacing = 15
    local headerSpacing = 40
    local optionSpacing = 8
    
    -- Master Enable Toggle (larger, prominent)
    local enableCheckbox = MilaUI.AF.CreateCheckbox(parent, "Enable Cursor Mod",
        function() return CursorMod:IsEnabled() end,
        function(value)
            if value then
                MilaUIAddon:EnableModule("CursorMod")
            else
                MilaUIAddon:DisableModule("CursorMod")
            end
        end)
    AF.SetPoint(enableCheckbox, "TOPLEFT", parent, "TOPLEFT", leftCol, -currentY)
    -- Make enable checkbox more prominent
    local enableLabel = enableCheckbox:GetFontString()
    if enableLabel then
        enableLabel:SetFont(enableLabel:GetFont(), 13, "OUTLINE")
    end
    currentY = currentY + lineHeight + sectionSpacing
    
    -- CREATE SECTION HEADERS (pink, bold text)
    local function CreateSectionHeader(text, x, y)
        local header = AF.CreateFontString(parent, text, "pink")
        header:SetFont(header:GetFont(), 14, "OUTLINE")
        AF.SetPoint(header, "TOPLEFT", parent, "TOPLEFT", x, -y)
        return header
    end
    
    -- LEFT COLUMN - BEHAVIOR & FUNCTIONALITY
    CreateSectionHeader("BEHAVIOR", leftCol, currentY)
    local leftY = currentY + headerSpacing
    
    local showOnlyInCombat = MilaUI.AF.CreateCheckbox(parent, "Show Only in Combat",
        function() return MilaUI.DB.profile.CursorMod.showOnlyInCombat end,
        function(value)
            MilaUI.DB.profile.CursorMod.showOnlyInCombat = value
            if CursorMod:IsEnabled() then
                CursorMod:SetShowOnlyInCombat(value)
            end
        end)
    AF.SetPoint(showOnlyInCombat, "TOPLEFT", parent, "TOPLEFT", leftCol, -leftY)
    leftY = leftY + lineHeight + optionSpacing
    
    local changeCursorSize = MilaUI.AF.CreateCheckbox(parent, "Change Game Cursor Size",
        function() return MilaUI.DB.profile.CursorMod.changeCursorSize end,
        function(value)
            MilaUI.DB.profile.CursorMod.changeCursorSize = value
            if CursorMod:IsEnabled() then
                CursorMod:SetChangeCursorSize(value)
            end
        end)
    AF.SetPoint(changeCursorSize, "TOPLEFT", parent, "TOPLEFT", leftCol, -leftY)
    leftY = leftY + lineHeight + optionSpacing
    
    local autoScale = MilaUI.AF.CreateCheckbox(parent, "Auto Scale",
        function() return MilaUI.DB.profile.CursorMod.autoScale end,
        function(value)
            MilaUI.DB.profile.CursorMod.autoScale = value
            if CursorMod:IsEnabled() then
                CursorMod:SetAutoScale(value)
            end
            -- Toggle manual scale visibility
            if value then
                manualScale:Hide()
            else
                manualScale:Show()
            end
        end)
    AF.SetPoint(autoScale, "TOPLEFT", parent, "TOPLEFT", leftCol, -leftY)
    leftY = leftY + lineHeight + optionSpacing
    
    local manualScale = MilaUI.AF.CreateSlider(parent, "Manual Scale", 0.4, 2,
        function() return MilaUI.DB.profile.CursorMod.scale end,
        function(value)
            MilaUI.DB.profile.CursorMod.scale = value
            if CursorMod:IsEnabled() then
                CursorMod:SetScale(value)
            end
        end, 0.01)
    AF.SetPoint(manualScale, "TOPLEFT", parent, "TOPLEFT", leftCol, -leftY)
    leftY = leftY + lineHeight + sectionSpacing
    
    -- Advanced toggle (minimal, inline)
    CreateSectionHeader("ADVANCED", leftCol, leftY)
    leftY = leftY + headerSpacing
    
    local lookStartDelta = MilaUI.AF.CreateSlider(parent, "Freelook Start Delta", 0.0001, 0.01,
        function() return MilaUI.DB.profile.CursorMod.lookStartDelta or 0.001 end,
        function(value)
            MilaUI.DB.profile.CursorMod.lookStartDelta = value
            if CursorMod:IsEnabled() then
                CursorMod:SetLookStartDelta(value)
            end
        end, 0.0001)
    AF.SetPoint(lookStartDelta, "TOPLEFT", parent, "TOPLEFT", leftCol + 20, -(leftY + lineHeight + optionSpacing))
    lookStartDelta:Hide()  -- Start collapsed
    
    local advancedToggle = MilaUI.AF.CreateCheckbox(parent, "Show Advanced Settings",
        function() return false end,
        function(value)
            if value then
                lookStartDelta:Show()
            else
                lookStartDelta:Hide()
            end
        end)
    AF.SetPoint(advancedToggle, "TOPLEFT", parent, "TOPLEFT", leftCol, -leftY)
    
    -- RIGHT COLUMN - APPEARANCE & VISUALS
    CreateSectionHeader("APPEARANCE", rightCol, currentY)
    local rightY = currentY + headerSpacing
    
    -- Texture and Size side-by-side, properly aligned
    local textureDropdown = AF.CreateDropdown(parent, 140)
    textureDropdown:SetLabel("Texture")
    textureDropdown:SetItems({
        {text = "Custom Point", value = 1},
        {text = "Retail Cursor", value = 2},
        {text = "Classic Cursor", value = 3},
        {text = "Inverse Point", value = 4},
        {text = "Ghostly Point", value = 5},
        {text = "Talent Search 1", value = 6},
        {text = "Talent Search 2", value = 7}
    })
    textureDropdown:SetSelectedValue(MilaUI.DB.profile.CursorMod.texPoint)
    textureDropdown:SetOnClick(function(value)
        MilaUI.DB.profile.CursorMod.texPoint = value
        if CursorMod:IsEnabled() then
            CursorMod:SetTexture(value)
        end
    end)
    AF.SetPoint(textureDropdown, "TOPLEFT", parent, "TOPLEFT", rightCol, -rightY)
    
    local sizeDropdown = AF.CreateDropdown(parent, 100)
    sizeDropdown:SetLabel("Size")
    sizeDropdown:SetItems({
        {text = "32x32", value = 0},
        {text = "48x48", value = 1},
        {text = "64x64", value = 2},
        {text = "96x96", value = 3},
        {text = "128x128", value = 4}
    })
    sizeDropdown:SetSelectedValue(MilaUI.DB.profile.CursorMod.size)
    sizeDropdown:SetOnClick(function(value)
        MilaUI.DB.profile.CursorMod.size = value
        if CursorMod:IsEnabled() then
            CursorMod:SetSize(value)
        end
    end)
    AF.SetPoint(sizeDropdown, "TOPLEFT", parent, "TOPLEFT", rightCol + 150, -rightY)
    rightY = rightY + lineHeight + lineHeight + optionSpacing
    
    -- Opacity slider 
    local opacitySlider = MilaUI.AF.CreateSlider(parent, "Opacity", 0, 1,
        function() return MilaUI.DB.profile.CursorMod.opacity end,
        function(value)
            MilaUI.DB.profile.CursorMod.opacity = value
            if CursorMod:IsEnabled() then
                CursorMod:SetOpacity(value)
            end
        end, 0.01)
    AF.SetPoint(opacitySlider, "TOPLEFT", parent, "TOPLEFT", rightCol, -rightY)
    rightY = rightY + lineHeight + optionSpacing
    
    -- Color settings
    local colorValue = MilaUI.DB.profile.CursorMod.color
    local colorPicker = MilaUI.AF.CreateColorPicker(parent, "Custom Color",
        function() return colorValue end,
        function(newColor)
            MilaUI.DB.profile.CursorMod.color = newColor
            if CursorMod:IsEnabled() then
                CursorMod:SetColor(newColor[1], newColor[2], newColor[3], newColor[4])
            end
        end)
    AF.SetPoint(colorPicker, "TOPLEFT", parent, "TOPLEFT", rightCol, -(rightY + lineHeight + optionSpacing))
    
    local useClassColor = MilaUI.AF.CreateCheckbox(parent, "Use Class Color",
        function() return MilaUI.DB.profile.CursorMod.useClassColor end,
        function(value)
            MilaUI.DB.profile.CursorMod.useClassColor = value
            if CursorMod:IsEnabled() then
                CursorMod:SetUseClassColor(value)
            end
            -- Toggle color picker visibility
            if value then
                colorPicker:Hide()
            else
                colorPicker:Show()
            end
        end)
    AF.SetPoint(useClassColor, "TOPLEFT", parent, "TOPLEFT", rightCol, -rightY)
    
    -- Initialize visibility states
    if MilaUI.DB.profile.CursorMod.autoScale then
        manualScale:Hide()
    else
        manualScale:Show()
    end
    
    if MilaUI.DB.profile.CursorMod.useClassColor then
        colorPicker:Hide()
    else
        colorPicker:Show()
    end
    
    -- PREVIEW/STATUS BAR (Future enhancement placeholder)
    -- local previewY = math.max(visualY + 200, scaleY + 100)
    -- CreateSectionHeader("PREVIEW", leftCol, previewY)
    -- Could add a small preview frame showing current cursor settings
end