local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")

-- General Settings Tab Implementation
function MilaUI:CreateAFGeneralTab(parent)
    local section = MilaUI.AF.CreateBorderedSection(parent, "General Settings", 600)
    
    -- Placeholder content
    local label = AF.CreateFontString(section, "General settings will go here...", "white")
    MilaUI.AF.AddWidgetToSection(section, label, 10, -25)
    
    -- Add some sample settings
    local testCheckbox = MilaUI.AF.CreateCheckbox(section, "Test Setting",
        function() return true end,
        function(value) print("Test setting:", value) end)
    MilaUI.AF.AddWidgetToSection(section, testCheckbox, 10, -50)
end