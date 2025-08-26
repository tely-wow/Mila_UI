local _, MilaUI = ...

-- ACL-style Filter Engine for Auras
local FilterEngine = {}
MilaUI.FilterEngine = FilterEngine

-- Cache for player's class and spec abilities
local playerClass = select(2, UnitClass("player"))
local canDispelMagic = false
local canDispelDisease = false
local canDispelPoison = false
local canDispelCurse = false
local canSteal = false

-- Update dispel capabilities based on class/spec
local function UpdateDispelCapabilities()
    -- This would need to be expanded based on class/spec
    -- For now, basic class-based detection
    if playerClass == "PRIEST" then
        canDispelMagic = true
        canDispelDisease = true
    elseif playerClass == "PALADIN" then
        canDispelMagic = true
        canDispelDisease = true
        canDispelPoison = true
    elseif playerClass == "SHAMAN" then
        canDispelMagic = false
        canDispelCurse = true
        canDispelPoison = true
        canDispelDisease = true
    elseif playerClass == "MAGE" then
        canDispelCurse = true
        canSteal = true
    elseif playerClass == "DRUID" then
        canDispelCurse = true
        canDispelPoison = true
        canDispelMagic = IsPlayerSpell(88423) -- Nature's Cure (Restoration)
    elseif playerClass == "MONK" then
        canDispelMagic = true
        canDispelDisease = true
        canDispelPoison = true
    elseif playerClass == "DEMONHUNTER" then
        canDispelMagic = true -- Consume Magic
    elseif playerClass == "EVOKER" then
        canDispelMagic = true
        canDispelDisease = true
        canDispelPoison = true
        canDispelCurse = true
    end
end

-- Initialize on PLAYER_LOGIN
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event)
    UpdateDispelCapabilities()
end)

-- Rule evaluation functions
local RuleEvaluators = {}

-- Duration filter
RuleEvaluators.duration = function(data, params)
    local duration = data.duration or 0
    local expirationTime = data.expirationTime or 0
    
    -- Handle permanent auras (duration = 0)
    if duration == 0 and params.includePermanent then
        return false -- Deny permanent auras if includePermanent is true
    end
    
    -- Check min duration
    if params.minDuration and duration > 0 and duration < params.minDuration then
        return false
    end
    
    -- Check max duration
    if params.maxDuration and duration > params.maxDuration then
        return false
    end
    
    return true
end

-- Blacklist filter
RuleEvaluators.blacklist = function(data, params)
    if not params.spellIds then return true end
    
    -- Check if spell is in blacklist
    return not params.spellIds[data.spellId]
end

-- Whitelist filter
RuleEvaluators.whitelist = function(data, params)
    if not params.spellIds or not next(params.spellIds) then 
        return true -- If no whitelist, allow all
    end
    
    -- Check if spell is in whitelist
    return params.spellIds[data.spellId] == true
end

-- Caster filter
RuleEvaluators.caster = function(data, params)
    local sourceUnit = data.sourceUnit
    if not sourceUnit then return params.others end
    
    -- Check player
    if params.player and UnitIsUnit(sourceUnit, "player") then
        return true
    end
    
    -- Check pet
    if params.pet and UnitIsUnit(sourceUnit, "pet") then
        return true
    end
    
    -- Check vehicle
    if params.vehicle and UnitIsUnit(sourceUnit, "vehicle") then
        return true
    end
    
    -- Check boss
    if params.boss then
        for i = 1, 8 do
            if UnitIsUnit(sourceUnit, "boss" .. i) then
                return true
            end
        end
    end
    
    -- Check others (anyone else)
    if params.others and not UnitIsUnit(sourceUnit, "player") and not UnitIsUnit(sourceUnit, "pet") and not UnitIsUnit(sourceUnit, "vehicle") then
        -- Also check it's not a boss
        local isBoss = false
        for i = 1, 8 do
            if UnitIsUnit(sourceUnit, "boss" .. i) then
                isBoss = true
                break
            end
        end
        if not isBoss then
            return true
        end
    end
    
    return false
end

-- Dispellable filter
RuleEvaluators.dispellable = function(data, params)
    if not data.dispelName then return false end
    
    local dispelType = data.dispelName
    
    -- Check if we should only show if player can dispel
    if params.onlyIfCanDispel then
        if dispelType == "Magic" and not canDispelMagic then return false end
        if dispelType == "Disease" and not canDispelDisease then return false end
        if dispelType == "Poison" and not canDispelPoison then return false end
        if dispelType == "Curse" and not canDispelCurse then return false end
    end
    
    -- Check if this dispel type is enabled in params
    if dispelType == "Magic" and params.magic then return true end
    if dispelType == "Disease" and params.disease then return true end
    if dispelType == "Poison" and params.poison then return true end
    if dispelType == "Curse" and params.curse then return true end
    
    return false
end

-- Stealable filter
RuleEvaluators.stealable = function(data, params)
    if not data.isStealable then return false end
    
    -- Check if we should only show if player can steal
    if params.onlyIfCanSteal and not canSteal then
        return false
    end
    
    return data.isStealable
end

-- Personal auras filter
RuleEvaluators.personal = function(data, params)
    -- Personal auras are ones that only affect the caster
    return data.isPersonal or false
end

-- Boss auras filter
RuleEvaluators.boss = function(data, params)
    if not data.sourceUnit then return false end
    
    -- Check if source is a boss unit
    for i = 1, 8 do
        if UnitIsUnit(data.sourceUnit, "boss" .. i) then
            return true
        end
    end
    
    return data.isBossAura or false
end

-- No duration (permanent) filter
RuleEvaluators.noDuration = function(data, params)
    return data.duration == 0
end

-- Any/Catch-all filter - matches everything
RuleEvaluators.any = function(data, params)
    return true -- Always matches - use for cleanup rules
end

-- Main filter function
function FilterEngine:ProcessAura(unit, unitType, auraType, data)
    -- Get the unit's filter configuration
    local filters = MilaUI.DB.profile.AuraFilters
    if not filters or not filters.UnitFilters then 
        return true, 32 -- Allow if no filters configured, default size
    end
    
    local unitConfig = filters.UnitFilters[unitType]
    if not unitConfig then
        return true, 32 -- Allow if unit not configured, default size
    end
    
    -- Get buff or debuff filter config
    local filterConfig = nil
    if auraType == "HELPFUL" then
        filterConfig = unitConfig.Buffs
    elseif auraType == "HARMFUL" then
        filterConfig = unitConfig.Debuffs
    end
    
    if not filterConfig or not filterConfig.enabled then
        return true, 32 -- Allow if filter not enabled, default size
    end
    
    -- Process rules in order
    if filterConfig.rules then
        -- Sort rules by order
        local sortedRules = {}
        for _, rule in ipairs(filterConfig.rules) do
            table.insert(sortedRules, rule)
        end
        table.sort(sortedRules, function(a, b) return (a.order or 999) < (b.order or 999) end)
        
        -- Evaluate each rule
        for _, rule in ipairs(sortedRules) do
            if rule.enabled and not rule.deleted then
                local evaluator = RuleEvaluators[rule.type]
                if evaluator then
                    local result = evaluator(data, rule.params or {})
                    
                    -- Apply action based on rule result
                    if rule.action == "allow" then
                        if result then
                            return true, rule.size or 32 -- Allow and stop processing with rule size
                        end
                    elseif rule.action == "deny" then
                        if result then
                            return false, rule.size or 32 -- Deny and stop processing
                        end
                    end
                end
            end
        end
    end
    
    -- No rules matched - this shouldn't happen with proper 'any' rules
    return true, 32
end

-- Helper function to migrate legacy blacklist/whitelist
function FilterEngine:MigrateLegacyFilters()
    local filters = MilaUI.DB.profile.AuraFilters
    if not filters then return end
    
    -- Migrate buff blacklist
    if filters.Buffs and filters.Buffs.Blacklist and next(filters.Buffs.Blacklist) then
        for unitType, unitConfig in pairs(filters.UnitFilters or {}) do
            if unitConfig.Buffs and unitConfig.Buffs.rules then
                for _, rule in ipairs(unitConfig.Buffs.rules) do
                    if rule.type == "blacklist" then
                        rule.params = rule.params or {}
                        rule.params.spellIds = rule.params.spellIds or {}
                        -- Merge legacy blacklist
                        for spellId, _ in pairs(filters.Buffs.Blacklist) do
                            rule.params.spellIds[spellId] = true
                        end
                    end
                end
            end
        end
    end
    
    -- Migrate debuff blacklist
    if filters.Debuffs and filters.Debuffs.Blacklist and next(filters.Debuffs.Blacklist) then
        for unitType, unitConfig in pairs(filters.UnitFilters or {}) do
            if unitConfig.Debuffs and unitConfig.Debuffs.rules then
                for _, rule in ipairs(unitConfig.Debuffs.rules) do
                    if rule.type == "blacklist" then
                        rule.params = rule.params or {}
                        rule.params.spellIds = rule.params.spellIds or {}
                        -- Merge legacy blacklist
                        for spellId, _ in pairs(filters.Debuffs.Blacklist) do
                            rule.params.spellIds[spellId] = true
                        end
                    end
                end
            end
        end
    end
end

-- Export the filter function for use in FilterAura callbacks
function MilaUI:FilterAuraWithEngine(unit, unitType, auraType, data)
    local shouldShow, size = FilterEngine:ProcessAura(unit, unitType, auraType, data)
    return shouldShow, size
end

-- Initialize migration on load
C_Timer.After(1, function()
    FilterEngine:MigrateLegacyFilters()
end)