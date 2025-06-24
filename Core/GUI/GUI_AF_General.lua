local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- General Settings Tab Implementation
function MilaUI:CreateAFGeneralTab(parent)
    MilaUI.AF:ResetPositioning()
    
    -- UI Scale Settings Section
    local uiScaleSection = MilaUI.AF.CreateBorderedSection(parent, "UI Scale Settings", 140)
    
    local uiScaleEnabled = MilaUI.AF.CreateCheckbox(uiScaleSection, "Enable UI Scale",
        function() return MilaUI.DB.global.UIScaleEnabled end,
        function(value) 
            MilaUI.DB.global.UIScaleEnabled = value
            if value then
                UIParent:SetScale(MilaUI.DB.global.UIScale)
            else
                UIParent:SetScale(1.0)
            end
        end)
    MilaUI.AF.AddWidgetToSection(uiScaleSection, uiScaleEnabled, 10, -25)
    
    local uiScaleSlider = MilaUI.AF.CreateSlider(uiScaleSection, "UI Scale", 0.5, 1.2,
        function() return MilaUI.DB.global.UIScale end,
        function(value) 
            MilaUI.DB.global.UIScale = value
            if MilaUI.DB.global.UIScaleEnabled then
                UIParent:SetScale(value)
            end
        end, 0.05, 200)
    MilaUI.AF.AddWidgetToSection(uiScaleSection, uiScaleSlider, 10, -50)
    
    local gameMenuScaleSlider = MilaUI.AF.CreateSlider(uiScaleSection, "Game Menu Scale", 0.5, 2.0,
        function() return MilaUI.DB.global.GameMenuScale end,
        function(value) 
            MilaUI.DB.global.GameMenuScale = value
            MilaUI:UpdateEscapeMenuScale()
        end, 0.05, 200)
    MilaUI.AF.AddWidgetToSection(uiScaleSection, gameMenuScaleSlider, 10, -75)
    
    local framesLockedCB = MilaUI.AF.CreateCheckbox(uiScaleSection, "Lock Frames",
        function() return MilaUI.DB.global.FramesLocked end,
        function(value) 
            MilaUI.DB.global.FramesLocked = value
            MilaUI:ToggleFrameLock(value)
        end)
    MilaUI.AF.AddWidgetToSection(uiScaleSection, framesLockedCB, 10, -100)
    
    -- Font Settings Section
    local fontSection = MilaUI.AF.CreateBorderedSection(parent, "Font Settings", 100)
    
    local fontOptions = {}
    for _, font in pairs(LSM:List("font")) do
        table.insert(fontOptions, {text = font, value = font})
    end
    
    local fontDropdown = MilaUI.AF.CreateDropdown(fontSection, "Default Font", fontOptions,
        function() return MilaUI.DB.profile.Unitframes.General.Font end,
        function(value) 
            MilaUI.DB.profile.Unitframes.General.Font = value
            MilaUI:UpdateFrames()
        end)
    MilaUI.AF.AddWidgetToSection(fontSection, fontDropdown, 10, -25)
    
    local fontFlagOptions = {
        {text = "None", value = ""},
        {text = "Outline", value = "OUTLINE"},
        {text = "Thick Outline", value = "THICKOUTLINE"},
        {text = "Monochrome", value = "MONOCHROME"}
    }
    
    local fontFlagDropdown = MilaUI.AF.CreateDropdown(fontSection, "Font Flags", fontFlagOptions,
        function() return MilaUI.DB.profile.Unitframes.General.FontFlag end,
        function(value) 
            MilaUI.DB.profile.Unitframes.General.FontFlag = value
            MilaUI:UpdateFrames()
        end)
    MilaUI.AF.AddWidgetToSection(fontSection, fontFlagDropdown, 200, -25)
    
    -- Clean Castbar Section
    local castbarSection = MilaUI.AF.CreateBorderedSection(parent, "Clean Castbar System", 120)
    
    local castbarInfoText = AF.CreateFontString(castbarSection, 
        "Configure the new independent castbar system for all units.", "gray")
    MilaUI.AF.AddWidgetToSection(castbarSection, castbarInfoText, 10, -25)
    
    local openCastbarGUI = AF.CreateButton(castbarSection, "Open Castbar Settings", "pink", 200, 30)
    openCastbarGUI:SetOnClick(function()
        if MilaUI.CreateCleanCastbarGUI then
            MilaUI:CreateCleanCastbarGUI()
        else
            print("Castbar GUI not available")
        end
    end)
    MilaUI.AF.AddWidgetToSection(castbarSection, openCastbarGUI, 10, -50)
    
    local castbarSlashText = AF.CreateFontString(castbarSection, 
        "You can also use: /muicast", "gray")
    MilaUI.AF.AddWidgetToSection(castbarSection, castbarSlashText, 220, -60)
    
    -- Tag Update Section  
    local tagSection = MilaUI.AF.CreateBorderedSection(parent, "Performance Settings", 80)
    
    local tagUpdateSlider = MilaUI.AF.CreateSlider(tagSection, "Tag Update Interval (seconds)", 0.1, 2.0,
        function() return MilaUI.DB.global.TagUpdateInterval end,
        function(value) 
            MilaUI.DB.global.TagUpdateInterval = value
            MilaUI:SetTagUpdateInterval()
        end, 0.1, 200)
    MilaUI.AF.AddWidgetToSection(tagSection, tagUpdateSlider, 10, -25)
end