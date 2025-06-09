local _, Mila = ...
local UF = Mila.UnitFrames

-- Buff filter lists
local blacklist = {
    -- Cosmetic buffs
    [7353] = true,   -- Cozy Fire
    [17619] = true,  -- Alchemist Stone
    [72968] = true,  -- Precious' Ribbon
    [97340] = true,  -- Guild Champion
    [97341] = true,  -- Guild Champion
    
    -- Alliance Tabards
    [93795] = true,  -- Champion of Stormwind
    [93805] = true,  -- Champion of Ironforge
    [93806] = true,  -- Champion of Darnassus
    [93811] = true,  -- Champion of the Exodar
    [93816] = true,  -- Champion of Gilneas
    [93821] = true,  -- Champion of Gnomeregan
    
    -- Horde Tabards
    [93825] = true,  -- Champion of Orgrimmar
    [93827] = true,  -- Champion of the Darkspear
    [93828] = true,  -- Champion of Silvermoon
    [93830] = true,  -- Champion of the Bilgewater Cartel
    [94462] = true,  -- Champion of the Undercity
    [94463] = true,  -- Champion of Thunder Bluff
    
    -- Mounts
    [783] = true,    -- Travel Form
    [1066] = true,   -- Aquatic Form
    [33943] = true,  -- Flight Form
    [6648] = true,   -- Mount
    [8394] = true,   -- Mount
    [10789] = true,  -- Mount
    [10793] = true,  -- Mount
}

local whitelist = {
    -- Important player buffs
    [31821] = true,  -- Aura Mastery
    [31884] = true,  -- Avenging Wrath
    [12472] = true,  -- Icy Veins
    [12042] = true,  -- Arcane Power
    [48505] = true,  -- Starfall
    [51713] = true,  -- Shadow Dance
    [1719] = true,   -- Recklessness
    [871] = true,    -- Shield Wall
}

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