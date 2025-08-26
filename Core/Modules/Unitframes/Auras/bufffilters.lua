local _, MilaUI = ...
local oUF = MilaUI.oUF

-- Get buff blacklist from saved variables
function MilaUI:GetBuffBlacklist()
    if not MilaUI or not MilaUI.DB or not MilaUI.DB.profile then
        print("|cffff0000MilaUI Error:|r Database not available")
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
    if not MilaUI.DB.profile.AuraFilters.Buffs then
        print("|cffff0000MilaUI Error:|r Buffs profile not found")
        return {}
    end
    if not MilaUI.DB.profile.AuraFilters.Buffs.Blacklist then
        print("|cffff0000MilaUI Error:|r Buffs Blacklist profile not found")
        return {}
    end
    
    -- Ensure all keys are numbers
    local blacklist = MilaUI.DB.profile.AuraFilters.Buffs.Blacklist
    local cleanedBlacklist = {}
    for id, value in pairs(blacklist) do
        local numId = tonumber(id)
        if numId then
            cleanedBlacklist[numId] = true
        end
    end
    MilaUI.DB.profile.AuraFilters.Buffs.Blacklist = cleanedBlacklist
    
    return cleanedBlacklist
end

-- Get buff whitelist from saved variables
function MilaUI:GetBuffWhitelist()
    if not MilaUI or not MilaUI.DB or not MilaUI.DB.profile then
        print("|cffff0000MilaUI Error:|r Database not available")
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
    if not MilaUI.DB.profile.AuraFilters.Buffs then
        print("|cffff0000MilaUI Error:|r Buffs profile not found")
        return {}
    end
    if not MilaUI.DB.profile.AuraFilters.Buffs.Whitelist then
        print("|cffff0000MilaUI Error:|r Buffs Whitelist profile not found")
        return {}
    end
    return MilaUI.DB.profile.AuraFilters.Buffs.Whitelist
end

-- Add spell to buff blacklist
function MilaUI:AddToBuffBlacklist(spellID)
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
    if not MilaUI.DB.profile.AuraFilters.Buffs then
        print("|cffff0000MilaUI Error:|r Buffs profile not found")
        return
    end
    if not MilaUI.DB.profile.AuraFilters.Buffs.Blacklist then
        print("|cffff0000MilaUI Error:|r Buffs Blacklist profile not found")
        return
    end
    
    -- Store with number key
    MilaUI.DB.profile.AuraFilters.Buffs.Blacklist[spellID] = true
    
    -- Force unit frame update
    MilaUI:UpdateAllUnitFrames()
end

-- Remove spell from buff blacklist
function MilaUI:RemoveFromBuffBlacklist(spellID)
    spellID = tonumber(spellID)
    if not spellID then return end
    
    MilaUI.DB.profile.AuraFilters.Buffs.Blacklist[spellID] = nil
    MilaUI:UpdateAllUnitFrames()
end

-- Helper function to update all unit frames
function MilaUI:UpdateAllUnitFrames()
    -- Force update all frames
    if oUF and oUF.objects then
        for _, frame in pairs(oUF.objects) do
            if frame.unit and frame:IsShown() then
                frame:UpdateAllElements("ForceUpdate")
            end
        end
    end
end

