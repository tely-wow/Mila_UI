local _, Mila = ...
local UF = Mila.UnitFrames

-- Debuff filter lists
local blacklist = {
    -- Cosmetic or minor debuffs
    [95223] = true,  -- Recently Mass Resurrected
}

local whitelist = {
    -- Important PvE boss debuffs
    -- 8% Spell damage taken increase
    [1490] = true,   -- Curse of the Elements (Warlock)
    [60433] = true,  -- Earth and Moon (Druid Balance)
    [93068] = true,  -- Master Poisoner (Rogue Assassination)
    [65142] = true,  -- Ebon Plague (Death Knight Unholy)
    [24844] = true,  -- Lightning Breath (Hunter Wind Serpent)
    [34889] = true,  -- Fire Breath (Hunter Dragonhawk)
    
    -- 5% Spell crit increase
    [22959] = true,  -- Critical Mass (Mage Fire)
    [17800] = true,  -- Shadow and Flame (Warlock Destruction)
    
    -- 4% Physical damage taken increase
    [30070] = true,  -- Blood Frenzy (Warrior Arms)
    [58683] = true,  -- Savage Combat (Rogue Combat)
    [81326] = true,  -- Brittle Bones (Death Knight Frost)
    [50518] = true,  -- Ravage (Hunter Ravager)
    [55749] = true,  -- Acid Spit (Hunter Worm)
    
    -- 12% Armor reduction
    [91565] = true,  -- Faerie Fire (Druid)
    [58567] = true,  -- Sunder Armor (Warrior)
    [8647] = true,   -- Expose Armor (Rogue)
    [35387] = true,  -- Corrosive Spit (Hunter Serpent)
    [50498] = true,  -- Tear Armor (Hunter Raptor)
}

-- Basic blacklist filter (show all except those in list)
function UF.BlacklistDebuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    if blacklist[spellID] then
        return false -- Hide this debuff
    end
    return true -- Show all other debuffs
end

-- Basic whitelist filter (show only those in list)
function UF.WhitelistDebuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    if whitelist[spellID] then
        return true -- Show this debuff
    end
    return false -- Hide all other debuffs
end

-- Player debuff filter (show only player-cast debuffs)
function UF.PlayerDebuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    -- Hide blacklisted debuffs
    if blacklist[spellID] then
        return false
    end
    
    -- Show player-cast debuffs
    if source == "player" then
        return true
    end
    
    -- Show important debuffs
    if whitelist[spellID] then
        return true
    end
    
    return false
end

-- Target debuff filter (show player debuffs and important ones)
function UF.TargetDebuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    -- Hide blacklisted debuffs
    if blacklist[spellID] then
        return false
    end
    
    -- Show player-cast debuffs
    if source == "player" or source == "pet" or source == "vehicle" then
        return true
    end
    
    -- Show important debuffs
    if whitelist[spellID] then
        return true
    end
    
    -- Show boss debuffs
    if isBossDebuff then
        return true
    end
    
    return false
end

-- Boss debuff filter (show all important debuffs)
function UF.BossDebuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff)
    -- Hide blacklisted debuffs
    if blacklist[spellID] then
        return false
    end
    
    -- Show all boss debuffs
    if isBossDebuff then
        return true
    end
    
    -- Show important debuffs
    if whitelist[spellID] then
        return true
    end
    
    -- Show player-cast debuffs
    if source == "player" or source == "pet" or source == "vehicle" then
        return true
    end
    
    -- Show dispellable debuffs
    local dispelType = debuffType
    if dispelType and (dispelType == "Magic" or dispelType == "Curse" or dispelType == "Disease" or dispelType == "Poison") then
        return true
    end
    
    return false
end