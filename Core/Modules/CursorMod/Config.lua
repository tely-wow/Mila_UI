-- MilaUI_CursorMod_Config.lua - Configuration panel for CursorMod
local _, MilaUI = ...
local MilaUIAddon = LibStub("AceAddon-3.0"):GetAddon("MilaUI")
 
-- Try to get the module, create it if it doesn't exist
local CursorMod = MilaUIAddon:GetModule("CursorMod", true)
if not CursorMod then
    CursorMod = MilaUIAddon:NewModule("CursorMod", "AceEvent-3.0")
end
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local function getSettings()
    return MilaUI.DB and MilaUI.DB.profile and MilaUI.DB.profile.CursorMod
end

-- Configuration options table
local options = {
    name = "CursorMod",
    type = "group",
    args = {
        enable = {
            name = "Enable CursorMod",
            desc = "Enable or disable the cursor modification module",
            type = "toggle",
            set = function(_, val) 
                local settings = getSettings()
                if not settings then return end
                settings.enabled = val
                if val then
                    CursorMod:OnEnable()
                else
                    CursorMod:OnDisable()
                end
            end,
            get = function() 
                local settings = getSettings()
                return settings and settings.enabled 
            end,
            order = 1,
        },
        
        header1 = {
            name = "Appearance",
            type = "header",
            order = 10,
        },
        
        texture = {
            name = "Cursor Texture",
            desc = "Select the cursor texture",
            type = "select",
            values = {
                [1] = "Custom Point",
                [2] = "Retail Cursor",
                [3] = "Classic Cursor", 
                [4] = "Inverse Point",
                [5] = "Ghostly Point",
                [6] = "Talent Search 1",
                [7] = "Talent Search 2",
            },
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.texPoint = val
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.texPoint
            end,
            order = 11,
        },
        
        size = {
            name = "Cursor Size",
            desc = "Select the cursor size",
            type = "select",
            values = {
                [0] = "32x32",
                [1] = "48x48",
                [2] = "64x64",
                [3] = "96x96",
                [4] = "128x128",
            },
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.size = val
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.size
            end,
            order = 12,
        },
        
        changeCursorSize = {
            name = "Change Game Cursor Size",
            desc = "Also change the default game cursor size",
            type = "toggle",
            set = function(_, val) 
                CursorMod.db.profile.changeCursorSize = val
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.changeCursorSize
            end,
            order = 13,
        },
        
        autoScale = {
            name = "Auto Scale",
            desc = "Automatically scale cursor based on UI scale",
            type = "toggle",
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.autoScale = val
                CursorMod:UpdateAutoScale()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.autoScale
            end,
            order = 14,
        },
        
        scale = {
            name = "Manual Scale",
            desc = "Manual scale factor (disabled when auto scale is on)",
            type = "range",
            min = 0.1,
            max = 2.0,
            step = 0.01,
            disabled = function()
                local settings = getSettings()
                return settings and settings.autoScale
            end,
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.scale = val
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.scale
            end,
            order = 15,
        },
        
        opacity = {
            name = "Opacity",
            desc = "Cursor opacity",
            type = "range",
            min = 0.1,
            max = 1.0,
            step = 0.1,
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.opacity = val
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.opacity
            end,
            order = 16,
        },
        
        header2 = {
            name = "Color",
            type = "header",
            order = 20,
        },
        
        useClassColor = {
            name = "Use Class Color",
            desc = "Use your class color for the cursor",
            type = "toggle",
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.useClassColor = val
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.useClassColor
            end,
            order = 21,
        },
        
        color = {
            name = "Custom Color",
            desc = "Custom cursor color",
            type = "color",
            disabled = function()
                local settings = getSettings()
                return settings and settings.useClassColor
            end,
            set = function(_, r, g, b)
                local settings = getSettings()
                if not settings then return end
                settings.color = {r, g, b}
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                local c = settings and settings.color
                if c then
                    return c[1], c[2], c[3]
                end
            end,
            order = 22,
        },
        
        header3 = {
            name = "Behavior",
            type = "header",
            order = 30,
        },
        
        showOnlyInCombat = {
            name = "Show Only in Combat",
            desc = "Only show the custom cursor during combat",
            type = "toggle",
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.showOnlyInCombat = val
                CursorMod:SetCombatTracking()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.showOnlyInCombat
            end,
            order = 31,
        },
        
        lookStartDelta = {
            name = "Freelook Start Delta",
            desc = "Sensitivity for cursor freelook activation",
            type = "range",
            min = 0.0001,
            max = 0.01,
            step = 0.0001,
            set = function(_, val)
                local settings = getSettings()
                if not settings then return end
                settings.lookStartDelta = val
                CursorMod:UpdateCursorSettings()
            end,
            get = function()
                local settings = getSettings()
                return settings and settings.lookStartDelta
            end,
            order = 32,
        },
    },
}

-- Register the options
function CursorMod:SetupConfig()
    AceConfig:RegisterOptionsTable("MilaUI_CursorMod", options)
    MilaUIAddon.optionsFrame = AceConfigDialog:AddToBlizOptions("MilaUI_CursorMod", "CursorMod")
end

-- Initialize config when module is ready
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "Mila_UI" then
        CursorMod:SetupConfig()
        frame:UnregisterEvent("ADDON_LOADED")
    end
end)