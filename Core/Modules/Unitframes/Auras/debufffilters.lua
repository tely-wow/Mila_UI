local _, MilaUI = ...
local oUF = MilaUI.oUF

-- Get debuff blacklist from saved variables
function MilaUI:GetDebuffBlacklist()
    if not MilaUI or not MilaUI.DB or not MilaUI.DB.profile then
        return {}
    end
    if not MilaUI.DB.profile.Unitframes then
        print("|cffff0000MilaUI Error:|r Unitframes profile not found")
        return {}
    end
    if not MilaUI.DB.profile.AuraFilters then
        print("|cffff0000MilaUI Error:|r AuraFilters profile not found")
        return {}
    end
    if not MilaUI.DB.profile.AuraFilters.Debuffs then
        MilaUI.DB.profile.AuraFilters.Debuffs = {}
    end
    if not MilaUI.DB.profile.AuraFilters.Debuffs.Blacklist then
        MilaUI.DB.profile.AuraFilters.Debuffs.Blacklist = {}
    end
    
        -- Ensure all keys are numbers
    local blacklist = MilaUI.DB.profile.AuraFilters.Debuffs.Blacklist
    local cleanedBlacklist = {}
    for id, value in pairs(blacklist) do
        local numId = tonumber(id)
        if numId then
            cleanedBlacklist[numId] = true
        end
    end
    MilaUI.DB.profile.AuraFilters.Debuffs.Blacklist = cleanedBlacklist
    
    return cleanedBlacklist
end

-- Get debuff whitelist from saved variables
function MilaUI:GetDebuffWhitelist()
    if not MilaUI or not MilaUI.DB or not MilaUI.DB.profile then
        return {}
    end
    if not MilaUI.DB.profile.Unitframes then
        print("|cffff0000MilaUI Error:|r Unitframes profile not found")
        return {}
    end
    if not MilaUI.DB.profile.AuraFilters then
        print("|cffff0000MilaUI Error:|r AuraFilters profile not found")
        return {}
    end
    if not MilaUI.DB.profile.AuraFilters.Debuffs then
        MilaUI.DB.profile.AuraFilters.Debuffs = {}
    end
    if not MilaUI.DB.profile.AuraFilters.Debuffs.Whitelist then
        MilaUI.DB.profile.AuraFilters.Debuffs.Whitelist = {}
    end
    return MilaUI.DB.profile.AuraFilters.Debuffs.Whitelist
end

-- Add spell to debuff blacklist
function MilaUI:AddToDebuffBlacklist(spellID)
    -- Ensure spellID is a number
    spellID = tonumber(spellID)
    if not spellID then
        print("|cffff0000MilaUI Error:|r Invalid spell ID provided")
        return
    end
    
    -- Check if database is available
    if not MilaUI or not MilaUI.DB or not MilaUI.DB.profile then
        print("|cffff0000MilaUI Error:|r Database not available")
        return
    end
    
        -- Initialize database structure if needed
    if not MilaUI.DB.profile.Unitframes then
        print("|cffff0000MilaUI Error:|r Unitframes profile not found")
        return
    end
    if not MilaUI.DB.profile.AuraFilters then
        print("|cffff0000MilaUI Error:|r AuraFilters profile not found")
        return
    end
    if not MilaUI.DB.profile.AuraFilters.Debuffs then
        print("|cffff0000MilaUI Error:|r Debuffs profile not found")
        return
    end
    if not MilaUI.DB.profile.AuraFilters.Debuffs.Blacklist then
        print("|cffff0000MilaUI Error:|r Debuffs Blacklist profile not found")
        return
    end
    
    -- Store with number key
    MilaUI.DB.profile.AuraFilters.Debuffs.Blacklist[spellID] = true
    
    -- Force unit frame update
    MilaUI:UpdateAllUnitFrames()
end

-- Remove spell from debuff blacklist
function MilaUI:RemoveFromDebuffBlacklist(spellID)
    spellID = tonumber(spellID)
    if not spellID then return end
    
    MilaUI.DB.profile.AuraFilters.Debuffs.Blacklist[spellID] = nil
    MilaUI:UpdateAllUnitFrames()
end

