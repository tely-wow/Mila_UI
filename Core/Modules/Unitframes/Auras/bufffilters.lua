local _, Mila = ...
local UF = Mila.UnitFrames


-- Basic blacklist filter (show all except those in list)
function UF.BlacklistBuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    if blacklist[spellID] then
        return false -- Hide this aura
    end
    return true -- Show all other auras
end

-- Basic whitelist filter (show only those in list)
function UF.WhitelistBuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    if whitelist[spellID] then
        return true -- Show this aura
    end
    return false -- Hide all other auras
end

-- Player buff filter (show only player buffs, except blacklisted ones)
function UF.PlayerBuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    -- Hide blacklisted buffs
    if blacklist[spellID] then
        return false
    end
    
    -- Only show player buffs
    if source == "player" then
        return true
    end
    
    -- Show important buffs from others
    if whitelist[spellID] then
        return true
    end
    
    return false
end

-- Target buff filter (more selective)
function UF.TargetBuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    -- Hide blacklisted buffs
    if blacklist[spellID] then
        return false
    end
    
    -- Show stealable buffs
    if isStealable then
        return true
    end
    
    -- Show important buffs
    if whitelist[spellID] then
        return true
    end
    
    -- Show player-cast buffs
    if source == "player" then
        return true
    end
    
    return false
end

-- Boss buff filter (show all except cosmetic)
function UF.BossBuffFilter(icons, unit, icon, name, texture, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID)
    if blacklist[spellID] then
        return false
    end
    return true
end