local _, MilaUI = ...
local MilaUIAddon = LibStub("AceAddon-3.0"):NewAddon("MilaUI")
MilaUI.addon = MilaUIAddon
MilaUI.NewCastbarSystem = MilaUI.NewCastbarSystem or {}
MilaUI.modules = MilaUI.modules or {}
MilaUI.modules.bars = MilaUI.NewCastbarSystem
MilaUI.UnitFrames = MilaUI.UnitFrames or {}
MilaUIAddon_GUI = MilaUIAddon_GUI or {}
MilaUIAddon:SetDefaultModuleState(false)

-- MilaUI defaults are now loaded from separate files in Core/Defaults/
-- This keeps Main.lua clean and makes defaults modular

function MilaUIAddon:MigrateDatabase()
    local db = MilaUI.DB.profile
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    db.Unitframes = db.Unitframes or {}
    if db.Unitframes.migrated == false then
        local migratedAny = false
        if db.Player then
            db.Unitframes.Player = db.Player
            print(lavender .. "MilaUI:" .. pink .. " Migrated Player settings to Unitframes.Player")
            db.Player = nil
            migratedAny = true
        end

        if db.Target then
            db.Unitframes.Target = db.Target  
            print(lavender .. "MilaUI:" .. pink .. " Migrated Target settings to Unitframes.Target")
            db.Target = nil
            migratedAny = true
        end
        
        if db.Focus then
            db.Unitframes.Focus = db.Focus
            print(lavender .. "MilaUI:" .. pink .. " Migrated Focus settings to Unitframes.Focus")
            db.Focus = nil
            migratedAny = true
        end
        
        if db.Pet then
            db.Unitframes.Pet = db.Pet
            print(lavender .. "MilaUI:" .. pink .. " Migrated Pet settings to Unitframes.Pet")
            db.Pet = nil
            migratedAny = true
        end
        
        if db.TargetTarget then
            db.Unitframes.TargetTarget = db.TargetTarget
            print(lavender .. "MilaUI:" .. pink .. " Migrated TargetTarget settings to Unitframes.TargetTarget")
            db.TargetTarget = nil
            migratedAny = true
        end
        
        if db.FocusTarget then
            db.Unitframes.FocusTarget = db.FocusTarget
            print(lavender .. "MilaUI:" .. pink .. " Migrated FocusTarget settings to Unitframes.FocusTarget")
            db.FocusTarget = nil
            migratedAny = true
        end
        
        if db.Boss then
            db.Unitframes.Boss = db.Boss
            print(lavender .. "MilaUI:" .. pink .. " Migrated Boss settings to Unitframes.Boss")
            db.Boss = nil
            migratedAny = true
        end
        
        if migratedAny then
            print(lavender .. "MilaUI:" .. pink .. " Database migration complete!")
        else
            print(lavender .. "MilaUI:" .. pink .. " No database entries needed migration.")
        end
        db.Unitframes.migrated = true
        MilaUI:UpdateFrames()
        MilaUI:CreateReloadPrompt()
    end
end

function MilaUIAddon:OnInitialize()
    -- Create merged defaults from modular files
    local defaults = {
        global = MilaUI.Defaults.global,
        profile = {
            TestMode = MilaUI.Defaults.TestMode,
            CursorMod = MilaUI.Defaults.CursorMod,
            Unitframes = MilaUI.Defaults.Unitframes,
            castBars = MilaUI.Defaults.Castbars,
            AuraFilters = MilaUI.Defaults.AuraFilters,
        }
    }
    
    -- Initialize database with merged defaults
    MilaUI.DB = LibStub("AceDB-3.0"):New("MilaUIDB", defaults)
end

function MilaUI:SetupSlashCommands()
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    local white = MilaUI.DB.global.Colors.white
    
    SLASH_MilaUI1 = "/MilaUI"
    SLASH_MilaUI2 = "/mui"
    SLASH_MilaUI3 = "/Mila"
    SlashCmdList["MilaUI"] = function(msg)
        if msg == "" then
            MilaUI_OpenGUIMain()
        elseif msg == "reset" then
            MilaUI:ResetDefaultSettings()
        elseif msg == "help" then
            print(pink .. "♥MILA UI ♥:  " .. lavender .. " Slash Commands.")
            print(pink .. "/MilaUI or /MUI:" .. lavender .. " Opens the GUI")
            print(pink .. "/MilaUI reset or /MUI reset:" .. lavender .. " Resets To Default")
            print(pink .. "/MilaUI debug or /MUI debug:" .. lavender .. " Toggle debug mode")
        elseif msg == "debug" then
            MilaUI.DB.global.DebugMode = not MilaUI.DB.global.DebugMode
            print(pink .. "MilaUI Debug Mode: " .. lavender .. (MilaUI.DB.global.DebugMode and "Enabled" or "Disabled"))
        elseif msg == "dumpfilters" then
            print(pink .. "=== FILTER RULES DUMP ===")
            for unitName, unitConfig in pairs(MilaUI.DB.profile.AuraFilters.UnitFilters or {}) do
                print(lavender .. unitName .. ":")
                
                -- Count active buff rules
                local activeBuffs = 0
                for _, rule in ipairs(unitConfig.Buffs.rules or {}) do
                    if not rule.deleted then activeBuffs = activeBuffs + 1 end
                end
                print("  Buffs: " .. activeBuffs .. " active rules (of " .. #(unitConfig.Buffs.rules or {}) .. " total)")
                for i, rule in ipairs(unitConfig.Buffs.rules or {}) do
                    if not rule.deleted then
                        print("    [" .. i .. "] " .. (rule.name or "unnamed") .. " (" .. (rule.type or "unknown") .. ") - " .. (rule.action or "unknown"))
                    end
                end
                
                -- Count active debuff rules  
                local activeDebuffs = 0
                for _, rule in ipairs(unitConfig.Debuffs.rules or {}) do
                    if not rule.deleted then activeDebuffs = activeDebuffs + 1 end
                end
                print("  Debuffs: " .. activeDebuffs .. " active rules (of " .. #(unitConfig.Debuffs.rules or {}) .. " total)")
                for i, rule in ipairs(unitConfig.Debuffs.rules or {}) do
                    if not rule.deleted then
                        print("    [" .. i .. "] " .. (rule.name or "unnamed") .. " (" .. (rule.type or "unknown") .. ") - " .. (rule.action or "unknown"))
                    end
                end
            end
        end
    end
    SLASH_MILAUIPRINT1 = "/muiprint"
    local db = MilaUI.DB  -- Use MilaUI.DB, which is where your DB lives
    SlashCmdList["MILAUIPRINT"] = function(msg)
        local path = {strsplit(".", msg)}
        local value = db
        for _, key in ipairs(path) do
            if value and type(value) == "table" then
                value = value[key]
            else
                value = nil
                break
            end
        end
        print("Value:", value)
    end
    SLASH_MILAUICOLORS1 = "/milacolors"
    SlashCmdList["MILAUICOLORS"] = function()
        local colors = MilaUI.DB.profile.Unitframes.General.CustomColours.Reaction
        for k, v in pairs(colors) do
            print("Reaction", k, "->", string.format("r=%.2f g=%.2f b=%.2f", v[1], v[2], v[3]))
        end
    end
    
    -- Register cursor slash commands
    if MilaUIAddon:GetModule("CursorMod", true) then
        SLASH_MUILACURSOR1 = "/mui cursor"
        SLASH_MUILACURSOR2 = "/mila cursor"
        SlashCmdList["MILAUICURSOR"] = function(msg)
            local cmd = string.lower(msg or "")
            
            if cmd == "toggle" then
                MilaUIAddon:ToggleModule("CursorMod")
                print("MilaUI CursorMod:", MilaUIAddon:GetModule("CursorMod"):GetStatus().enabled and "Enabled" or "Disabled")
            elseif cmd == "status" then
                local status = MilaUIAddon:GetModule("CursorMod"):GetStatus()
                print("MilaUI CursorMod Status:")
                for k, v in pairs(status) do
                    if type(v) == "table" then
                        print(" ", k .. ":", table.concat(v, ", "))
                    else
                        print(" ", k .. ":", tostring(v))
                    end
                end
            elseif cmd == "reload" then
                MilaUIAddon:GetModule("CursorMod"):UpdateCursorSettings()
                print("MilaUI CursorMod: Settings reloaded")
            else
                print("MilaUI CursorMod Commands:")
                print("  /mui cursor toggle - Toggle module on/off")
                print("  /mui cursor status - Show current settings")
                print("  /mui cursor reload - Reload settings")
            end
        end
    end
end

function MilaUIAddon:OnEnable()
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    local white = MilaUI.DB.global.Colors.white
    if MilaUI.DB.global.UIScaleEnabled then UIParent:SetScale(MilaUI.DB.global.UIScale) end
    if MilaUI.DB.profile.TestMode then MilaUI.DB.profile.TestMode = false end
    -- Check if CursorMod module exists and handle its state
    local cursorMod = MilaUIAddon:GetModule("CursorMod", true)
    if cursorMod then
        if not MilaUI.DB.profile.CursorMod.enabled then
            MilaUIAddon:DisableModule("CursorMod")
        end
    end
    MilaUIAddon:MigrateDatabase()
    MilaUI:UpdateEscapeMenuScale()
    MilaUI:SetTagUpdateInterval()
    MilaUI:LoadCustomColours()
    MilaUI:SpawnPlayerFrame()
    MilaUI:SpawnTargetFrame()
    MilaUI:SpawnTargetTargetFrame()
    MilaUI:SpawnFocusFrame()
    MilaUI:SpawnFocusTargetFrame()
    MilaUI:SpawnPetFrame()
    MilaUI:SpawnBossFrames()
    MilaUI:SetupSlashCommands()
    
    -- Schedule a delayed update to ensure optional dependency fonts are loaded
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function(self, event, isLogin, isReload)
        if isLogin or isReload then
            -- Delay UpdateFrames by 3 seconds to ensure all addons (including MilaUI_Media) have loaded their fonts
            C_Timer.After(3, function()
                MilaUI:UpdateFrames()
            end)
        end
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end)
    
    print(pink .. "♥MILA UI ♥:  " .. lavender .. "Type: " .. pink .. "/MUI" .. lavender .. " for in-game configuration.")
end
