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
    
    contentArea:SetContentHeight(1200)
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
    local section = MilaUI.AF.CreateBorderedSection(parent, castbarType .. " Castbar Settings", 600)
    
    local label = AF.CreateFontString(section, "Configure " .. castbarType:lower() .. " castbar settings...", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
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