local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- Color constants
local lavender = "|cffBFACE2"
local pink = "|cffFF9CD0"
local green = "|cff00FF00"
local red = "|cffFF0000"

-- Global positioning state
MilaUI.AF = MilaUI.AF or {}
MilaUI.AF.currentY = 0

-- Helper Functions
local function CreateCheckbox(parent, label, getValue, setValue)
    local checkbox = AF.CreateCheckButton(parent, label, function(checked)
        setValue(checked)
    end)
    checkbox:SetChecked(getValue())
    checkbox.accentColor = "pink"
    return checkbox
end

local function CreateSlider(parent, label, minVal, maxVal, getValue, setValue, step, width)
    local slider = AF.CreateSlider(parent, label, width or 200, minVal, maxVal, step or 1)
    
    -- Set the callback first
    slider:SetAfterValueChanged(function(value)
        setValue(value)
    end)
    
    -- Set the initial value and force display update
    local initialValue = getValue()
    slider:SetValue(initialValue)
    
    -- Force the edit box to update its text display
    C_Timer.After(0.01, function()
        if slider.editBox and slider.editBox.SetText then
            slider.editBox:SetText(tostring(initialValue))
        end
    end)
    
    slider.accentColor = "pink"
    return slider
end

local function CreateColorPicker(parent, label, getValue, setValue)
    local value = getValue()
    
    local colorPicker = AF.CreateColorPicker(parent, label, true, function(r, g, b, a)
        setValue({r, g, b, a})
    end, function(r, g, b, a)
        setValue({r, g, b, a})
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
                colorPickerFrame:SetParent(MilaUI.AF.mainFrame or AF.UIParent)
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
    dropdown.accentColor = "pink"
    return dropdown
end

local function CreateTextInput(parent, label, getValue, setValue)
    local editbox = AF.CreateEditBox(parent, label, 150)
    editbox:SetText(getValue())
    editbox:SetOnEnterPressed(function(value)
        setValue(value)
    end)
    editbox.accentColor = "pink"
    return editbox
end

local function CreateBorderedSection(parent, title, height, width)
    local section = AF.CreateBorderedFrame(parent, nil, width or 350, height or 120, nil, "pink")
    section:SetLabel(title, "pink")
    AF.SetPoint(section, "TOPLEFT", 10, -MilaUI.AF.currentY)
    MilaUI.AF.currentY = MilaUI.AF.currentY + (height or 120) + 20
    
    -- Ensure sections don't block mouse wheel scrolling
    section:EnableMouse(false)
    section:EnableMouseWheel(true)
    section:SetScript("OnMouseWheel", function(self, delta)
        -- Find the scroll frame parent and forward the event
        local scrollParent = self:GetParent()
        while scrollParent do
            if scrollParent.VerticalScroll then -- This is our scroll frame
                local scrollScript = scrollParent:GetScript("OnMouseWheel")
                if scrollScript then
                    scrollScript(scrollParent, delta)
                    break
                end
            end
            scrollParent = scrollParent:GetParent()
        end
    end)
    
    return section
end

local function AddWidgetToSection(section, widget, x, y)
    AF.SetPoint(widget, "TOPLEFT", section, "TOPLEFT", x or 10, y or -35)
end

-- Export functions to MilaUI.AF namespace
MilaUI.AF.CreateCheckbox = CreateCheckbox
MilaUI.AF.CreateSlider = CreateSlider
MilaUI.AF.CreateColorPicker = CreateColorPicker
MilaUI.AF.CreateDropdown = CreateDropdown
MilaUI.AF.CreateTextInput = CreateTextInput
MilaUI.AF.CreateBorderedSection = CreateBorderedSection
MilaUI.AF.AddWidgetToSection = AddWidgetToSection

-- Reset positioning for new container
function MilaUI.AF:ResetPositioning()
    self.currentY = 50
end

-- Update all frames or a specific frame based on unitType
function MilaUI:UpdateFrames(unitType)
    MilaUI:LoadCustomColours()
    
    -- If unitType is provided, only update that specific frame
    if unitType then
        local frameName = unitType .. "Frame"
        if self[frameName] then
            MilaUI:UpdateUnitFrame(self[frameName])
            return
        elseif unitType == "Boss" then
            MilaUI:UpdateBossFrames()
            return
        end
    end
    
    -- If no unitType is provided or it wasn't a valid frame, update all frames
    if self.PlayerFrame then
        MilaUI:UpdateUnitFrame(self.PlayerFrame)
    end
    if self.TargetFrame then
        MilaUI:UpdateUnitFrame(self.TargetFrame)
    end
    if self.FocusFrame then
        MilaUI:UpdateUnitFrame(self.FocusFrame)
    end
    if self.FocusTargetFrame then
        MilaUI:UpdateUnitFrame(self.FocusTargetFrame)
    end
    if self.PetFrame then
        MilaUI:UpdateUnitFrame(self.PetFrame)
    end
    if self.TargetTargetFrame then
        MilaUI:UpdateUnitFrame(self.TargetTargetFrame)
    end
    MilaUI:UpdateBossFrames()
end

-- Create tab system for main GUI
function MilaUI.AF:CreateTabSystem(parent, tabs)
    local tabContainer = AF.CreateFrame(parent)
    tabContainer:SetHeight(30)
    
    -- Ensure tab container doesn't block mouse wheel
    tabContainer:EnableMouse(false)
    tabContainer:EnableMouseWheel(true)
    tabContainer:SetScript("OnMouseWheel", function(self, delta)
        -- Find the content area and forward the scroll event
        local contentArea = parent.contentArea
        if contentArea and contentArea:GetScript("OnMouseWheel") then
            contentArea:GetScript("OnMouseWheel")(contentArea, delta)
        end
    end)
    
    local tabObjects = {}
    local tabWidth = 90
    
    for i, tab in ipairs(tabs) do
        local tabBtn = AF.CreateButton(tabContainer, tab.display, 
            tab.active and "pink" or "pink_transparent", 
            tabWidth, 25)
        
        tabBtn:SetPoint("LEFT", (i-1) * (tabWidth + 5), 0)
        
        -- Forward mouse wheel events from tab buttons
        tabBtn:EnableMouseWheel(true)
        tabBtn:SetScript("OnMouseWheel", function(self, delta)
            local contentArea = parent.contentArea
            if contentArea and contentArea:GetScript("OnMouseWheel") then
                contentArea:GetScript("OnMouseWheel")(contentArea, delta)
            end
        end)
        
        tabBtn:SetOnClick(function()
            if tab.callback then
                tab.callback()
            end
            -- Update tab states
            for _, t in ipairs(tabObjects) do
                t:SetColor("pink_transparent")
            end
            tabBtn:SetColor("pink")
        end)
        
        tabObjects[i] = tabBtn
    end
    
    return tabContainer, tabObjects
end

-- Create main content area with scroll
function MilaUI.AF:CreateContentArea(parent)
    local content = AF.CreateScrollFrame(parent)
    
    -- Force enable mouse wheel on the scroll content as well
    if content.scrollContent then
        content.scrollContent:EnableMouseWheel(true)
        content.scrollContent:SetScript("OnMouseWheel", function(self, delta)
            -- Redirect to parent scroll frame
            content:GetScript("OnMouseWheel")(content, delta)
        end)
    end
    
    return content
end

-- Create shared two-panel layout for tabs with button lists
function MilaUI.AF:CreateTwoPanelLayout(parent, listItems, listLabel, selectionCallback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetAllPoints(parent)
    
    -- Create list section (left side)
    local listWidth = 130
    local listHeight = 500
    local listSection = AF.CreateBorderedFrame(container, nil, listWidth, listHeight)
    listSection:SetLabel(listLabel, "pink")
    AF.SetPoint(listSection, "TOPLEFT", container, "TOPLEFT", 0, -20)
    AF.SetPoint(listSection, "BOTTOM", container, "BOTTOM", 0, 0)
    
    -- Create button group
    local buttons = {}
    local yOffset = -10
    
    for i, item in ipairs(listItems) do
        local btn = AF.CreateButton(listSection, item.name, "pink_transparent", 75, 25)
        btn.id = item.id or item.name
        btn:SetTextJustifyH("LEFT")
        AF.SetPoint(btn, "TOPLEFT", listSection, "TOPLEFT", 10, yOffset)
        AF.SetPoint(btn, "RIGHT", listSection, "RIGHT", -10, 0)
        
        -- Add tooltip
        AF.SetTooltips(btn, "LEFT", -2, 0, item.tooltip or (item.name .. " Settings"), 
                       item.description or ("Configure " .. item.name:lower() .. " settings"))
        
        tinsert(buttons, btn)
        yOffset = yOffset - 26
    end
    
    -- Create button group
    AF.CreateButtonGroup(buttons, selectionCallback)
    
    -- Create content area (right side)
    local content = MilaUI.AF:CreateContentArea(container)
    AF.SetPoint(content, "TOPLEFT", listSection, "TOPRIGHT", 10, 0)
    AF.SetPoint(content, "BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)
    
    container.listSection = listSection
    container.contentArea = content
    container.buttons = buttons
    
    return container
end

-- Create header with logo and title
function MilaUI.AF:CreateHeader(parent, title)
    local headerText = AF.CreateFontString(parent, title, "white")
    AF.SetPoint(headerText, "TOPLEFT", 10, -10)
    return headerText
end

-- Create AbstractFramework reload prompt dialog (Dialog1 approach from demo.lua)
function MilaUI.AF:CreateReloadPrompt()
    local text = AF.WrapTextInColor("Settings Changed", "pink") .. "\nReload UI to apply changes?\n" .. AF.WrapTextInColor("Some changes require a UI reload to take effect.", "gray")
    
    -- Get the main AF GUI frame as parent, fallback to UIParent
    local parentFrame = MilaUI.AF.mainFrame or AF.UIParent
    
    AF.ShowDialog(parentFrame, text, 250, nil, nil, true)
    AF.SetDialogPoint("CENTER")
    AF.SetDialogOnConfirm(function()
        C_UI.Reload()
    end)
end