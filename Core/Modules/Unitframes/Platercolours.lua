local _, MilaUI = ...
-- Force debug on for troubleshooting
local Debug = function(msg) print("|cFF33FF99MilaUI PlaterColours:|r " .. msg) end

-- Print a table for debugging
local function PrintTable(tbl, indent)
    if not tbl then Debug("Table is nil"); return end
    indent = indent or 0
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            Debug(formatting)
            PrintTable(v, indent+1)
        else
            Debug(formatting .. tostring(v))
        end
    end
end

-- Initialize the module
MilaUI.PlaterColours = {}
local PC = MilaUI.PlaterColours

-- Configuration
PC.config = {
    enabled = true,
    darkMultiplier = 0.2, -- How dark the backdrop should be compared to the main color
    debugMode = false,
}

-- Function to get unit color based on class, reaction, etc.
function PC:GetUnitColor(unit)
    if not unit or not UnitExists(unit) then return 1, 1, 1 end
    
    -- Check if it's a player with a class
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class then
            local color = RAID_CLASS_COLORS[class]
            if color then
                return color.r, color.g, color.b
            end
        end
    end
    
    -- Check reaction for NPCs
    local reaction = UnitReaction(unit, "player")
    if reaction then
        if reaction >= 5 then  -- Friendly
            return 0.0, 0.8, 0.0
        elseif reaction == 4 then  -- Neutral
            return 1.0, 1.0, 0.0
        else  -- Hostile
            return 0.8, 0.0, 0.0
        end
    end
    
    -- Default color if nothing else applies
    return 1, 1, 1
end

-- Apply color to a Mila_UI health bar and its background
function PC:ApplyHealthAndBackdropColor(frame, unit)
    -- Get the color for this unit
    local r, g, b = self:GetUnitColor(unit)
    
    -- Debug output
    Debug("Applying color to " .. (unit or "unknown") .. ": " .. string.format("%.2f, %.2f, %.2f", r, g, b))
    
    -- Apply to the unitframe
    self:ApplyColorToFrame(frame, r, g, b)
end

-- Apply color to a specific frame
function PC:ApplyColorToFrame(frame, r, g, b)
    if not frame then 
        Debug("ApplyColorToFrame: frame is nil")
        return 
    end
    
    -- Try different ways to access the health bar
    local health = nil
    
    -- Try unitHealthBar (your custom structure)
    if frame.unitHealthBar then
        health = frame.unitHealthBar
        Debug("Found health bar via unitHealthBar")
    -- Try Health (oUF standard)
    elseif frame.Health then
        health = frame.Health
        Debug("Found health bar via Health")
    -- Try finding a child that looks like a health bar
    else
        Debug("No standard health bar found, searching children")
        for i=1, frame:GetNumChildren() do
            local child = select(i, frame:GetChildren())
            if child and child:GetObjectType() == "StatusBar" then
                health = child
                Debug("Found potential health bar in children")
                break
            end
        end
    end
    
    if not health then 
        Debug("ApplyColorToFrame: health is nil after all attempts")
        return 
    end

    -- 1. Set Health Bar Color
    PC.isApplyingColor = true
    health:SetStatusBarColor(r, g, b)
    PC.isApplyingColor = false
    Debug(string.format("ApplyColorToFrame: Set health bar to %.2f, %.2f, %.2f", r, g, b))

    -- 2. Find Backdrop and BG elements
    local backdrop = nil
    local bg = nil
    
    -- Try different ways to find backdrop and background
    if frame.unitBorder then
        backdrop = frame.unitBorder
        Debug("Found backdrop via unitBorder")
    elseif health.backdrop then
        backdrop = health.backdrop
        Debug("Found backdrop via health.backdrop")
    end
    
    if frame.unitHealthBarBackground then
        bg = frame.unitHealthBarBackground
        Debug("Found background via unitHealthBarBackground")
    elseif health.bg then
        bg = health.bg
        Debug("Found background via health.bg")
    end

    -- 3. Calculate Darkened Color for background
    local darkR, darkG, darkB = r * self.config.darkMultiplier, g * self.config.darkMultiplier, b * self.config.darkMultiplier
    Debug(string.format("ApplyColorToFrame: Setting background color to %.2f, %.2f, %.2f", darkR, darkG, darkB))
    
    -- 4. Apply color to background if found
    if bg then
        if bg.SetVertexColor then
            bg:SetVertexColor(darkR, darkG, darkB, 1)
            Debug("Applied color to background via SetVertexColor")
        elseif bg.SetColorTexture then
            bg:SetColorTexture(darkR, darkG, darkB, 1)
            Debug("Applied color to background via SetColorTexture")
        end
    else
        Debug("Background element not found")
    end
    
    -- 5. Apply color to border if needed (uncomment if you want colored borders)
    -- if backdrop and backdrop.SetBackdropBorderColor then
    --     backdrop:SetBackdropBorderColor(r, g, b, 1)
    --     Debug("Applied color to border")
    -- end
end

-- Hook into the frame creation/update process
function PC:Initialize()
    Debug("Initializing PlaterColours")
    
    -- Create a direct hook into the unitframes
    self.hookFrame = CreateFrame("Frame")
    self.hookFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.hookFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.hookFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self.hookFrame:RegisterEvent("UNIT_FACTION")
    self.hookFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    -- Set up event handler
    self.hookFrame:SetScript("OnEvent", function(_, event, ...)
        Debug("Event triggered: " .. event)
        
        -- Wait a bit to ensure frames are fully created
        C_Timer.After(0.1, function()
            PC:UpdateAllFrames()
        end)
    end)
    
    -- Create a direct hook into the unitframes' PostUpdate method
    if MilaUI.oUF then
        Debug("Found oUF framework, attempting to hook")
        
        -- Try to hook into oUF's health element
        local originalPostUpdate = MilaUI.oUF.elements.health.PostUpdate
        if originalPostUpdate then
            Debug("Found health PostUpdate function, hooking")
            
            MilaUI.oUF.elements.health.PostUpdate = function(element, unit, cur, max)
                -- Call the original function first
                originalPostUpdate(element, unit, cur, max)
                
                -- Now apply our colors
                local frame = element.__owner
                if frame then
                    Debug("Applying colors to health element for " .. (unit or "unknown"))
                    PC:ApplyHealthAndBackdropColor(frame, unit)
                end
            end
            
            Debug("Successfully hooked into oUF health PostUpdate")
        else
            Debug("Could not find oUF health PostUpdate function")
        end
    else
        Debug("Could not find oUF framework")
    end
    
    -- Create a direct hook into the MilaUI_Player frame
    C_Timer.After(1, function()
        -- Try to hook into the player frame directly
        local playerFrame = _G["MilaUI_Player"]
        if playerFrame and playerFrame.Health then
            Debug("Found player frame, applying direct hook")
            
            -- Store original SetStatusBarColor
            local originalSetStatusBarColor = playerFrame.Health.SetStatusBarColor
            playerFrame.Health.SetStatusBarColor = function(self, r, g, b, a)
                -- Ignore calls from our own code
                if PC.isApplyingColor then
                    return originalSetStatusBarColor(self, r, g, b, a)
                end
                
                -- Apply our colors instead
                PC.isApplyingColor = true
                local unit = playerFrame.unit
                local newR, newG, newB = PC:GetUnitColor(unit)
                local result = originalSetStatusBarColor(self, newR, newG, newB, a)
                PC.isApplyingColor = false
                return result
            end
            
            -- Force an update
            PC:ApplyHealthAndBackdropColor(playerFrame, "player")
            
            Debug("Successfully hooked into player frame health")
        else
            Debug("Could not find player frame or its health element")
        end
    end)
    
    -- Initial update
    C_Timer.After(2, function() PC:UpdateAllFrames() end)
    
    Debug("PlaterColours initialized")
end

-- Update all frames with appropriate colors
function PC:UpdateAllFrames()
    Debug("Updating all frames")
    
    -- Update player frame
    local playerFrame = _G["MilaUI_Player"]
    if playerFrame then
        self:ApplyHealthAndBackdropColor(playerFrame, "player")
    end
    
    -- Update target frame
    local targetFrame = _G["MilaUI_Target"]
    if targetFrame then
        self:ApplyHealthAndBackdropColor(targetFrame, "target")
    end
    
    -- Update focus frame
    local focusFrame = _G["MilaUI_Focus"]
    if focusFrame then
        self:ApplyHealthAndBackdropColor(focusFrame, "focus")
    end
    
    -- Update pet frame
    local petFrame = _G["MilaUI_Pet"]
    if petFrame then
        self:ApplyHealthAndBackdropColor(petFrame, "pet")
    end
    
    -- Update target of target frame
    local totFrame = _G["MilaUI_TargetTarget"]
    if totFrame then
        self:ApplyHealthAndBackdropColor(totFrame, "targettarget")
    end
    
    -- Update focus target frame
    local focusTargetFrame = _G["MilaUI_FocusTarget"]
    if focusTargetFrame then
        self:ApplyHealthAndBackdropColor(focusTargetFrame, "focustarget")
    end
    
    -- Update boss frames
    if MilaUI.BossFrames then
        for i, bossFrame in ipairs(MilaUI.BossFrames) do
            if bossFrame then
                self:ApplyHealthAndBackdropColor(bossFrame, "boss" .. i)
            end
        end
    end
end

-- Register events to trigger updates
function PC:RegisterEvents()
    -- Create a frame for events
    self.eventFrame = CreateFrame("Frame")
    
    -- Register events that should trigger color updates
    self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self.eventFrame:RegisterEvent("UNIT_FACTION")
    self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    -- Event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        Debug("Event triggered: " .. event)
        PC:UpdateAllFrames()
    end)
end

-- Initialize when addon is loaded
local function OnAddonLoaded(_, addonName)
    if addonName == "Mila_UI" then
        PC:Initialize()
        PC:RegisterEvents()
    end
end

-- Register for ADDON_LOADED event
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", OnAddonLoaded)


