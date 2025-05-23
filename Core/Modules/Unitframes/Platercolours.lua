local _, MilaUI = ...
local DF = _G.DetailsFramework
if not DF then
    print("MilaUI: DetailsFramework not found! Plater NPC color translation disabled.")
end
local eventHandler = CreateFrame("Frame")
local reactionColors, statuscolours, general
local npcColorData = Plater.db.profile.npc_colors
local mobColors = {}
local frameUnitCache = {}


function MilaUI:ExtractMobID(guid)
    if not guid then
        return nil
    end
    
    local guidType, _, _, _, _, npcID = strsplit("-", guid)
    
    if guidType == "Creature" or guidType == "Vehicle" or guidType == "Pet" or guidType == "Vignette" then
        return tonumber(npcID)
    else
        return nil
    end
end

local function GetPlaterColorForMobID(mobID)
    if not Plater or not Plater.db or not Plater.db.profile or not Plater.db.profile.npc_colors then
        return nil
    end

    local infoTable = Plater.db.profile.npc_colors[mobID]
    if not infoTable then return nil end

    local enabled1, enabled2, colorID = infoTable[1], infoTable[2], infoTable[3]

    if enabled1 and DF and DF.ParseColors then
        local r, g, b = DF:ParseColors(colorID)
        if r and g and b then
            return {r = r, g = g, b = b}
        end
    end
    
    if enabled2 and DF and DF.ParseColors then
        local r, g, b = DF:ParseColors(colorID)
        if r and g and b then
            return {r = r, g = g, b = b}
        end 
    end

    return nil
end




function MilaUI:GetColorForMobID(mobID)
    if not mobID then return nil end
    
    local color = mobColors[mobID]
    if color then
        return color
    end
    
    if Plater then
        color = GetPlaterColorForMobID(mobID)
        if color then
            mobColors[mobID] = color
            return color
        end
    end
    
    return nil
end

local function ApplyHealthAndBackdropColor(health, r, g, b)
    local backdropcolor = general.BackgroundColour
    health:SetStatusBarColor(r, g, b)
    if general.ColourBackgroundByForeground then
        local a = general.BackgroundMultiplier
        backdropcolor = {r * a, g * a, b * a}
    end
    if health.bg then
        health.bg:SetVertexColor(backdropcolor[1], backdropcolor[2], backdropcolor[3])
    else
        print("MilaUI: Health backdrop not found!")
    end
end

function MilaUI:UpdateHealthBarColor(health, unit)
    if not health then return end
    if unit ~= "target" and unit ~= "focus" then return end

    local guid = UnitGUID(unit)
    if not guid or not UnitExists(unit) then return end

    -- Only care about NPCs
    if not UnitIsPlayer(unit) then
        local mobID = ExtractMobID(guid)
        if mobID then
            local color = GetColorForMobID(mobID)
            if color then
                health:SetStatusBarColor(color.r, color.g, color.b)
                -- Optionally set backdrop/bg here
                if health.bg then
                    local mult = MilaUI.DB.profile.General.BackgroundMultiplier or 0.25
                    health.bg:SetVertexColor(color.r * mult, color.g * mult, color.b * mult, MilaUI.DB.profile.General.BackgroundColour[4] or 1)
                end
                return
            end
        end
    end
    -- If not an NPC or no custom color, oUF's PostUpdateColor will handle it
end


local function CleanupFrameCache()
    local currentTime = GetTime()
    local cleanupThreshold = 300
    
    for frame, data in pairs(frameUnitCache) do
        if not frame:IsVisible() or (data.timestamp and currentTime - data.timestamp > cleanupThreshold) then
            frameUnitCache[frame] = nil
        end
    end
end


local cleanupFrame = CreateFrame("Frame")
cleanupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
cleanupFrame:SetScript("OnEvent", function()
    C_Timer.NewTicker(60, CleanupFrameCache)
end)

eventHandler:RegisterEvent("ADDON_LOADED")
eventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
eventHandler:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        self:UnregisterEvent("ADDON_LOADED")
        reactionColors = MilaUI.DB.profile.General.CustomColours.Reaction
        statuscolours = MilaUI.DB.profile.General.CustomColours.Status
        general = MilaUI.DB.profile.General
    end 
end)

