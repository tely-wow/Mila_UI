local _, MilaUI = ...

-- ACL-style Filter Engine for Auras
local FilterEngine = {}
MilaUI.FilterEngine = FilterEngine

-- Cache for sorted rules using table-based keys for better performance
local ruleCache = {}
local ruleCacheKeys = {} -- Pre-computed cache keys to avoid string concatenation
local cacheHits = 0
local cacheMisses = 0

-- Stats for aura unchanged detection
local auraUnchangedHits = 0
local auraChangedMisses = 0

-- Cache for boss unit checks (cleared each frame)
local bossUnitCache = {}
local bossUnitCacheFrame = 0
local frameCount = 0 -- Use frame counter instead of GetTime()

-- Aura unchanged detection will be done on buttons directly, no global cache needed

-- Cache for player's class and spec abilities
local playerClass = select(2, UnitClass("player"))
local canDispelMagic = false
local canDispelDisease = false
local canDispelPoison = false
local canDispelCurse = false
local canSteal = false
local isDebugMode = false -- Local cache for debug mode

-- Spell IDs for dispel abilities by class
local dispelSpells = {
    PRIEST = {
        [527] = {"Magic", "Disease"}, -- Purify
        [32375] = {"Magic"}, -- Mass Dispel
        [528] = {"Magic"} -- Dispel Magic (offensive)
    },
    PALADIN = {
        [4987] = {"Magic", "Disease", "Poison"}, -- Cleanse
        [213644] = {"Disease", "Poison"} -- Cleanse Toxins
    },
    SHAMAN = {
        [51886] = {"Curse"}, -- Cleanse Spirit
        [77130] = {"Magic", "Curse"}, -- Purify Spirit (Restoration)
        [370] = {"Magic"} -- Purge (offensive)
    },
    MAGE = {
        [475] = {"Curse"}, -- Remove Curse
        [30449] = {"Magic"} -- Spellsteal
    },
    DRUID = {
        [2782] = {"Curse", "Poison"}, -- Remove Corruption
        [88423] = {"Magic", "Curse", "Poison"} -- Nature's Cure (Restoration)
    },
    MONK = {
        [115450] = {"Magic", "Disease", "Poison"}, -- Detox
        [122783] = {"Magic"} -- Diffuse Magic
    },
    DEMONHUNTER = {
        [278326] = {"Magic"} -- Consume Magic
    },
    EVOKER = {
        [365585] = {"Poison"}, -- Expunge
        [360823] = {"Magic", "Poison"}, -- Naturalize
        [374251] = {"Curse", "Disease", "Magic", "Poison"} -- Cauterizing Flame
    },
    WARLOCK = {
        [119905] = {"Magic"}, -- Singe Magic (Imp)
        [89808] = {"Magic"} -- Singe Magic (Command Demon)
    },
    HUNTER = {
        [212638] = {"Magic"} -- Tranquilizing Shot (Dispel Enrage)
    }
}

-- Update dispel capabilities based on known spells
local function UpdateDispelCapabilities()
    canDispelMagic = false
    canDispelDisease = false
    canDispelPoison = false
    canDispelCurse = false
    canSteal = false
    
    local classSpells = dispelSpells[playerClass]
    if not classSpells then return end
    
    for spellId, types in pairs(classSpells) do
        if IsPlayerSpell(spellId) or IsSpellKnown(spellId) then
            for _, dispelType in ipairs(types) do
                if dispelType == "Magic" then
                    if spellId == 30449 then -- Spellsteal
                        canSteal = true
                    else
                        canDispelMagic = true
                    end
                elseif dispelType == "Disease" then
                    canDispelDisease = true
                elseif dispelType == "Poison" then
                    canDispelPoison = true
                elseif dispelType == "Curse" then
                    canDispelCurse = true
                end
            end
        end
    end
end

-- Cache management functions
-- Get or create cache key (avoids string concatenation)
local function GetCacheKey(unitType, auraType)
    if not ruleCacheKeys[unitType] then
        ruleCacheKeys[unitType] = {}
    end
    if not ruleCacheKeys[unitType][auraType] then
        ruleCacheKeys[unitType][auraType] = {unitType, auraType}
    end
    return ruleCacheKeys[unitType][auraType]
end

function FilterEngine:InvalidateCache(unitType, auraType)
    if unitType and auraType then
        local key = GetCacheKey(unitType, auraType)
        ruleCache[key] = nil
        if isDebugMode then
            print("|cffFFFF00[FilterEngine]|r Cache invalidated for", unitType, auraType)
        end
    else
        -- Invalidate all caches
        wipe(ruleCache)
        wipe(ruleCacheKeys)
        if isDebugMode then
            print("|cffFFFF00[FilterEngine]|r All caches invalidated")
        end
    end
end

-- Table pool for sorted rules to avoid allocations
local sortedRulesPool = {}
local function GetSortedRulesTable()
    local t = table.remove(sortedRulesPool) or {}
    return t
end

local function ReleaseSortedRulesTable(t)
    wipe(t)
    table.insert(sortedRulesPool, t)
end

function FilterEngine:GetCachedRules(unitType, auraType)
    local key = GetCacheKey(unitType, auraType)
    
    -- Check if we have cached rules
    if ruleCache[key] then
        cacheHits = cacheHits + 1
        return ruleCache[key]
    end
    
    cacheMisses = cacheMisses + 1
    
    -- Get the unit's filter configuration
    local filters = MilaUI.DB.profile.AuraFilters
    if not filters or not filters.UnitFilters then 
        return nil
    end
    
    local unitConfig = filters.UnitFilters[unitType]
    if not unitConfig then
        return nil
    end
    
    -- Get buff or debuff filter config
    local filterConfig = nil
    if auraType == "HELPFUL" then
        filterConfig = unitConfig.Buffs
    elseif auraType == "HARMFUL" then
        filterConfig = unitConfig.Debuffs
    end
    
    if not filterConfig or not filterConfig.enabled or not filterConfig.rules then
        return nil
    end
    
    -- Sort rules by order and cache them (use table pool)
    local sortedRules = GetSortedRulesTable()
    for _, rule in ipairs(filterConfig.rules) do
        if rule.enabled and not rule.deleted then
            table.insert(sortedRules, rule)
        end
    end
    table.sort(sortedRules, function(a, b) return (a.order or 999) < (b.order or 999) end)
    
    -- Cache the sorted rules
    ruleCache[key] = sortedRules
    
    if isDebugMode then
        print("|cff00FF00[FilterEngine]|r Cached", #sortedRules, "rules for", unitType, auraType)
    end
    
    return sortedRules
end

function FilterEngine:CacheAllRules()
    -- Pre-cache all unit/aura type combinations
    local unitTypes = {"Player", "Target", "Boss", "Focus", "Pet"}
    local auraTypes = {"HELPFUL", "HARMFUL"}
    
    for _, unitType in ipairs(unitTypes) do
        for _, auraType in ipairs(auraTypes) do
            self:GetCachedRules(unitType, auraType)
        end
    end
    
    if isDebugMode then
        print("|cff00FF00[FilterEngine]|r Pre-cached all filter rules")
    end
end

function FilterEngine:GetCacheStats()
    local hitRate = 0
    if (cacheHits + cacheMisses) > 0 then
        hitRate = (cacheHits / (cacheHits + cacheMisses)) * 100
    end
    return cacheHits, cacheMisses, hitRate
end

-- Frame counter for boss cache invalidation
local frameUpdateFrame = CreateFrame("Frame")
frameUpdateFrame:SetScript("OnUpdate", function()
    frameCount = frameCount + 1
end)

-- Initialize on PLAYER_ENTERING_WORLD
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event)
    UpdateDispelCapabilities()
    if event == "PLAYER_ENTERING_WORLD" then
        -- Update debug mode cache
        isDebugMode = MilaUI.DB and MilaUI.DB.global and MilaUI.DB.global.DebugMode or false
        -- Cache all rules when entering world
        C_Timer.After(0.5, function()
            FilterEngine:CacheAllRules()
        end)
    end
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

-- Spell List filter
RuleEvaluators.spellList = function(data, params)
    if not params.spellIds or not next(params.spellIds) then 
        return false -- No spells in list, don't match
    end
    
    -- Check if spell is in the list
    return params.spellIds[data.spellId] == true
end

-- Helper function to check if unit is a boss (with caching)
local function IsBossUnit(unit)
    if not unit then return false end
    
    -- Check cache validity (new frame = clear cache)
    if frameCount ~= bossUnitCacheFrame then
        wipe(bossUnitCache)
        bossUnitCacheFrame = frameCount
    end
    
    -- Check cache
    if bossUnitCache[unit] ~= nil then
        return bossUnitCache[unit]
    end
    
    -- Check if unit is a boss
    local isBoss = false
    for i = 1, 8 do
        if UnitExists("boss" .. i) and UnitIsUnit(unit, "boss" .. i) then
            isBoss = true
            break
        end
    end
    
    -- Cache the result
    bossUnitCache[unit] = isBoss
    return isBoss
end

-- Caster filter
RuleEvaluators.caster = function(data, params)
    local sourceUnit = data.sourceUnit
    if not sourceUnit then return params.others end
    
    -- Cache unit comparisons for efficiency
    local isPlayer = UnitIsUnit(sourceUnit, "player")
    
    -- Check player
    if params.player and isPlayer then
        return true
    end
    
    -- Early exit for others if not player and no boss check needed
    if params.others and not isPlayer and not params.boss then
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
    
    -- Check boss (using cached function)
    if params.boss and IsBossUnit(sourceUnit) then
        return true
    end
    
    -- Check others (anyone else who isn't a boss)
    if params.others and not isPlayer and not UnitIsUnit(sourceUnit, "pet") and not UnitIsUnit(sourceUnit, "vehicle") then
        if not IsBossUnit(sourceUnit) then
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
    if not data.sourceUnit then return data.isBossAura or false end
    
    -- Use cached boss check
    return IsBossUnit(data.sourceUnit) or data.isBossAura or false
end

-- No duration (permanent) filter
RuleEvaluators.noDuration = function(data, params)
    return data.duration == 0
end

-- Any/Catch-all filter - matches everything
RuleEvaluators.any = function(data, params)
    return true -- Always matches - use for cleanup rules
end

-- Check if aura has changed (button-based like ElvUI)
function FilterEngine:AuraUnchanged(button, data)
    -- Check if button has cached aura info
    if not button.milaAuraInfo then
        button.milaAuraInfo = {}
    end
    
    local cached = button.milaAuraInfo
    
    -- CRITICAL: Check if this button is being reused for a different aura
    -- Compare auraInstanceID or spellId to detect button reuse
    if cached.auraInstanceID ~= data.auraInstanceID then
        -- Button is being reused for a different aura, treat as changed
        if isDebugMode then
            print("|cffFF00FF[BUTTON REUSE]|r Button reassigned from", cached.name or "nil", "to", data.name or "nil")
        end
        auraChangedMisses = auraChangedMisses + 1
        return false
    end
    
    -- Check if aura data has changed (only stable properties, ignore expiration for refresh detection)
    -- Note: duration stays the same on refresh, only expirationTime changes
    if cached.name == data.name and 
       cached.icon == data.icon and 
       cached.count == data.applications and
       cached.duration == data.duration and
       cached.dispelName == data.dispelName then
        -- Aura unchanged or just refreshed, return cached result
        auraUnchangedHits = auraUnchangedHits + 1
        return true, cached.result, cached.size
    end
    
    -- Aura changed or new, will need to process
    auraChangedMisses = auraChangedMisses + 1
    return false
end

-- Store aura result on button (button-based like ElvUI)
function FilterEngine:CacheAuraResult(button, data, result, size)
    if not button.milaAuraInfo then
        button.milaAuraInfo = {}
    end
    
    button.milaAuraInfo.auraInstanceID = data.auraInstanceID  -- Store this to detect button reuse
    button.milaAuraInfo.name = data.name
    button.milaAuraInfo.icon = data.icon
    button.milaAuraInfo.count = data.applications
    button.milaAuraInfo.duration = data.duration
    button.milaAuraInfo.dispelName = data.dispelName
    button.milaAuraInfo.result = result
    button.milaAuraInfo.size = size
end

-- Main filter function (optimized with rule caching)
function FilterEngine:ProcessAura(unit, unitType, auraType, data)
    -- Get cached sorted rules
    local sortedRules = self:GetCachedRules(unitType, auraType)
    
    -- If no rules or disabled, allow by default
    if not sortedRules then
        return true, 32
    end
    
    -- Process rules with early exit on first match
    for _, rule in ipairs(sortedRules) do
        local evaluator = RuleEvaluators[rule.type]
        if evaluator then
            local result = evaluator(data, rule.params or {})
            
            -- Early exit on first matching rule
            if rule.action == "allow" and result then
                return true, rule.size or 32
            elseif rule.action == "deny" and result then
                return false, rule.size or 32
            end
        end
    end
    
    -- No rules matched - this shouldn't happen with proper 'any' rules
    return true, 32
end

-- Enhanced filter function with button-based unchanged detection
function FilterEngine:FilterAuraWithButton(element, button, unit, unitType, auraType, data)
    -- Check if aura is unchanged (ElvUI style)
    local unchanged, cachedResult, cachedSize = self:AuraUnchanged(button, data)
    if unchanged then
        return cachedResult, cachedSize
    end
    
    -- Process aura with rules
    local result, size = self:ProcessAura(unit, unitType, auraType, data)
    
    -- Cache result on button
    self:CacheAuraResult(button, data, result, size)
    
    return result, size
end

-- Export the filter function for use in FilterAura callbacks (no temp cache needed)
function MilaUI:FilterAuraWithEngine(unit, unitType, auraType, data)
    -- Process aura with rules directly
    -- Button-based caching will handle unchanged detection in PostUpdateButton
    return FilterEngine:ProcessAura(unit, unitType, auraType, data)
end


-- Add slash command for cache stats (debug)
SLASH_MILAUI_FILTER_CACHE1 = "/muicache"
SlashCmdList["MILAUI_FILTER_CACHE"] = function()
    local hits, misses, rate = FilterEngine:GetCacheStats()
    print("|cffFFD700[MilaUI Filter Cache Stats]|r")
    print(string.format("  Rule Cache Hits: |cff00FF00%d|r", hits))
    print(string.format("  Rule Cache Misses: |cffFF0000%d|r", misses))
    print(string.format("  Rule Hit Rate: |cffFFFF00%.1f%%|r", rate))
    
    -- Count cached rule entries
    local ruleCacheCount = 0
    for _ in pairs(ruleCache) do
        ruleCacheCount = ruleCacheCount + 1
    end
    print(string.format("  Rule Cache Entries: |cff00FFFF%d|r", ruleCacheCount))
    
    -- Aura unchanged stats
    local auraTotal = auraUnchangedHits + auraChangedMisses
    local auraRate = 0
    if auraTotal > 0 then
        auraRate = (auraUnchangedHits / auraTotal) * 100
    end
    print(string.format("  Aura Unchanged Hits: |cff00FF00%d|r", auraUnchangedHits))
    print(string.format("  Aura Changed Misses: |cffFF0000%d|r", auraChangedMisses))
    print(string.format("  Aura Unchanged Rate: |cffFFFF00%.1f%%|r", auraRate))
    
    print("|cffFFD700Button cache used in PostUpdateButton for unchanged detection|r")
    
    -- Show cached rule counts
    if isDebugMode then
        print("|cffFFD700Rule Details:|r")
        local ruleCount = 0
        for key, rules in pairs(ruleCache) do
            if rules then
                ruleCount = ruleCount + 1
            end
        end
        print(string.format("  Total cached rule sets: %d", ruleCount))
    end
end