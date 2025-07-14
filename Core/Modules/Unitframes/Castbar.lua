local _, MilaUI = ...
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")

-- Helper function to check if castbar is enabled for a unit
local function IsCastbarEnabled(unitKey)
    return MilaUI.DB.profile.Unitframes[unitKey] and
           MilaUI.DB.profile.Unitframes[unitKey].Castbar and
           MilaUI.DB.profile.Unitframes[unitKey].Castbar.enabled
end

-- Helper function to create castbar frame and background
local function CreateCastbarFrame(parent, settings, generalSettings)
    local castbar = CreateFrame("StatusBar", nil, parent)
    castbar:SetSize(settings.width, settings.height)
    
    -- Set the castbar texture using LibSharedMedia
    local texturePath = LSM:Fetch("statusbar", settings.texture) or LSM:GetDefault("statusbar")
    castbar:SetStatusBarTexture(texturePath)
    local initialColor = (settings.textures and settings.textures.castcolor) or {1, 0.7, 0, 1}
    castbar:SetStatusBarColor(unpack(initialColor))
    castbar:SetClipsChildren(true)
    -- Apply mask if supported and enabled
    if settings.CustomMask and settings.CustomMask.Enabled then
        -- Try to use mask if available in this WoW version
        pcall(function()
            local mask = castbar:CreateMaskTexture()
            if mask then
                mask:SetTexture(settings.CustomMask.MaskTexture)
                mask:SetPoint("TOPLEFT", castbar, "TOPLEFT", 0, 0)
                mask:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", 0, 0)
                castbar:GetStatusBarTexture():AddMaskTexture(mask)
            end
        end)
    end
    
    -- Create a background
    if settings.CustomMask and settings.CustomMask.Enabled then
        local bg = castbar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(castbar)
        bg:SetTexture(settings.CustomMask.MaskTexture)
        bg:SetVertexColor(unpack(settings.backgroundColor))
        bg:SetPoint("TOPLEFT", castbar, "TOPLEFT", 0, 0)
        bg:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", 0, 0)
    else
        local bg = castbar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(castbar)
        bg:SetTexture(texturePath)
        bg:SetVertexColor(unpack(settings.backgroundColor))
        bg:SetPoint("TOPLEFT", castbar, "TOPLEFT", 0, 0)
        bg:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", 0, 0)
    end
    
    castbar.bg = bg
    return castbar
end

-- Function to display a test castbar for customization
function MilaUI:ShowTestCastbar(unitName, persistent)
    print("ShowTestCastbar called for unit: " .. tostring(unitName) .. (persistent and " (persistent mode)" or ""))
    
    -- Check for clean castbar first
    local unitKey = unitName:lower()
    local cleanCastbarSettings = MilaUI.DB.profile.castBars and MilaUI.DB.profile.castBars[unitKey]
    
    if cleanCastbarSettings and cleanCastbarSettings.enabled then
        print("Using clean castbar system for " .. unitName)
        return MilaUI:ShowTestCleanCastbar(unitKey, persistent)
    end
    
    if not unitName or not MilaUI.DB.profile.Unitframes[unitName] then
        print("Invalid unit name for test castbar")
        return
    end
    
    -- Default to persistent mode if not specified
    if persistent == nil then
        persistent = true
    end
    
    local frameObj = MilaUI:GetFrameForUnit(unitName)
    if frameObj then
        print("Found frame for " .. unitName)
    end
    
    if not frameObj then
        print("Could not find frame object for unit: " .. unitName)
        return
    end
    
    if not frameObj.Castbar then
        print("Frame found but no Castbar component for unit: " .. unitName)
        return
    end
    
    local castbar = frameObj.Castbar
    print("Castbar found for " .. unitName .. ": " .. tostring(castbar:GetName() or "unnamed"))
    print("Castbar current visibility: " .. (castbar:IsVisible() and "visible" or "hidden"))
    -- Store the persistent mode flag
    castbar.testPersistent = persistent
    
    -- Define test spell data
    local testSpells = {
        -- Regular casts
        { name = "Fireball", icon = 135809, duration = 2.5, isChannel = false, isInterruptible = true },
        { name = "Frostbolt", icon = 135846, duration = 3.0, isChannel = false, isInterruptible = true },
        { name = "Pyroblast", icon = 135808, duration = 4.5, isChannel = false, isInterruptible = true },
        -- Channeled spells
        { name = "Arcane Missiles", icon = 136096, duration = 2.8, isChannel = true, isInterruptible = true },
        { name = "Mind Flay", icon = 136208, duration = 3.0, isChannel = true, isInterruptible = true },
        { name = "Drain Soul", icon = 136163, duration = 4.0, isChannel = true, isInterruptible = true },
        -- Uninterruptible casts
        { name = "Greater Heal", icon = 135913, duration = 3.0, isChannel = false, isInterruptible = false },
        { name = "Divine Hymn", icon = 237540, duration = 5.0, isChannel = true, isInterruptible = false },
    }
    
    -- Select a random spell from the list
    local randomIndex = math.random(1, #testSpells)
    local selectedSpell = testSpells[randomIndex]
    
    local duration = selectedSpell.duration
    local testSpellName = selectedSpell.name
    local testSpellIcon = selectedSpell.icon
    
    -- Show the castbar
    castbar:Show()
    castbar.casting = not selectedSpell.isChannel
    castbar.channeling = selectedSpell.isChannel
    castbar.interrupted = false
    castbar.failed = false
    castbar.isNonInterruptible = not selectedSpell.isInterruptible
    
    -- Set required oUF castbar fields
    castbar.max = duration
    castbar.duration = 0  -- Start at 0, oUF will increment this
    castbar.delay = 0
    castbar.startTime = GetTime()
    castbar.endTime = castbar.startTime + duration
    castbar.spellID = 1
    castbar.notInterruptible = false
    
    -- Set castbar values
    castbar:SetMinMaxValues(0, duration)
    castbar:SetValue(0)
    
    -- Set spell info
    if castbar.Text then
        castbar.Text:SetText(testSpellName)
    end
    
    if castbar.Icon and castbar.Icon.texture then
        castbar.Icon.texture:SetTexture(testSpellIcon)
        if MilaUI.DB.profile.Unitframes[unitName].Castbar.Icon.showIcon then
            castbar.Icon:Show()
        end
    end
    
    if castbar.Time then
        castbar.Time:SetText("0.0")
    end
    
    -- Create a timer to update the castbar
    castbar.testCastTimer = castbar.testCastTimer or {}
    if castbar.testCastTimer.handle then
        castbar.testCastTimer.handle:Cancel()
    end
    
    local startTime = GetTime()
    local endTime = startTime + duration
    
    castbar.testCastTimer.handle = C_Timer.NewTicker(0.05, function()
        local currentTime = GetTime()
        local elapsed = currentTime - startTime
        
        if elapsed >= duration then
            castbar:SetValue(duration)
            if castbar.Time then
                castbar.Time:SetText(format(MilaUI.DB.profile.Unitframes[unitName].Castbar.text.timeFormat, duration))
            end
            castbar.testCastTimer.handle:Cancel()
            castbar.testCastTimer.handle = nil
            
            -- If persistent mode is enabled, start a new cast after a short delay
            if castbar.testPersistent then
                C_Timer.After(0.8, function()
                    if castbar.testPersistent then -- Check again in case it was stopped
                        MilaUI:ShowTestCastbar(unitName, true)
                    end
                end)
            else
                -- Hide after a short delay if not in persistent mode
                C_Timer.After(0.5, function()
                    castbar.casting = false
                    castbar:Hide()
                end)
            end
            return
        end
        
        castbar:SetValue(elapsed)
        if castbar.Time then
            local timeText = format(MilaUI.DB.profile.Unitframes[unitName].Castbar.text.timeFormat, elapsed)
            castbar.Time:SetText(timeText)
        end
    end)
    
    -- Create a button to stop the test
    if not MilaUI.TestCastbarStopButton then
        local button = CreateFrame("Button", "MilaUI_TestCastbarStop", UIParent, "UIPanelButtonTemplate")
        button:SetSize(150, 30)
        button:SetPoint("TOP", UIParent, "TOP", 0, -100)
        button:SetText("Stop Test Castbars")
        button:SetFrameStrata("HIGH")
        button:SetScript("OnClick", function()
            MilaUI:StopAllTestCastbars()
            button:Hide()
        end)
        MilaUI.TestCastbarStopButton = button
    end
    
    MilaUI.TestCastbarStopButton:Show()
    print("Showing test castbar for " .. unitName)
end

-- Function to stop all test castbars
-- Function to show test castbar for clean castbar system
function MilaUI:ShowTestCleanCastbar(unitKey, persistent)
    print("ShowTestCleanCastbar called for unit: " .. tostring(unitKey) .. (persistent and " (persistent mode)" or ""))
    
    local cleanCastbarSettings = MilaUI.DB.profile.castBars and MilaUI.DB.profile.castBars[unitKey]
    if not cleanCastbarSettings or not cleanCastbarSettings.enabled then
        print("Clean castbar not enabled for unit: " .. unitKey)
        return
    end
    
    -- Get the parent frame for the castbar
    local frameObj = MilaUI:GetFrameForUnit(unitKey:gsub("^%l", string.upper))
    if not frameObj then
        print("Could not find frame object for unit: " .. unitKey)
        return
    end
    
    -- Get or create the clean castbar
    local castBar = frameObj.castBar
    if not castBar then
        print("No clean castbar found for unit: " .. unitKey)
        return
    end
    
    -- Default to persistent mode if not specified
    if persistent == nil then
        persistent = true
    end
    
    -- Store the persistent mode flag
    castBar.testPersistent = persistent
    
    -- Define test spell data
    local testSpells = {
        -- Regular casts
        { name = "Fireball", icon = 135809, duration = 2.5, isChannel = false, isInterruptible = true },
        { name = "Frostbolt", icon = 135846, duration = 3.0, isChannel = false, isInterruptible = true },
        { name = "Pyroblast", icon = 135808, duration = 4.5, isChannel = false, isInterruptible = true },
        -- Channeled spells
        { name = "Arcane Missiles", icon = 136096, duration = 2.8, isChannel = true, isInterruptible = true },
        { name = "Mind Flay", icon = 136208, duration = 3.0, isChannel = true, isInterruptible = true },
        { name = "Drain Soul", icon = 136163, duration = 4.0, isChannel = true, isInterruptible = true },
        -- Uninterruptible casts
        { name = "Greater Heal", icon = 135913, duration = 3.0, isChannel = false, isInterruptible = false },
        { name = "Divine Hymn", icon = 237540, duration = 5.0, isChannel = true, isInterruptible = false },
    }
    
    -- Select a random spell from the list
    local randomIndex = math.random(1, #testSpells)
    local selectedSpell = testSpells[randomIndex]
    
    local duration = selectedSpell.duration
    local testSpellName = selectedSpell.name
    local testSpellIcon = selectedSpell.icon
    
    -- Set up the test cast using the clean castbar's StartCast or SetupChannel function
    local currentTime = GetTime() * 1000
    local startTime = currentTime
    local endTime = currentTime + (duration * 1000)
    
    if selectedSpell.isChannel then
        castBar:SetupChannel(testSpellName, testSpellIcon, startTime, endTime, selectedSpell.isInterruptible)
    else
        castBar:StartCast(testSpellName, testSpellIcon, startTime, endTime, selectedSpell.isInterruptible, 1)
    end
    
    -- Store test data for persistence
    castBar.testSpellData = selectedSpell
    
    -- Schedule next test cast if persistent mode is enabled
    if persistent then
        C_Timer.After(duration + 0.8, function()
            if castBar.testPersistent then -- Check again in case it was stopped
                MilaUI:ShowTestCleanCastbar(unitKey, true)
            end
        end)
    end
    
    -- Create a button to stop the test if it doesn't exist
    if not MilaUI.TestCastbarStopButton then
        local button = CreateFrame("Button", "MilaUI_TestCastbarStop", UIParent, "UIPanelButtonTemplate")
        button:SetSize(150, 30)
        button:SetPoint("TOP", UIParent, "TOP", 0, -100)
        button:SetText("Stop Test Castbars")
        button:SetFrameStrata("HIGH")
        button:SetScript("OnClick", function()
            MilaUI:StopAllTestCastbars()
            button:Hide()
        end)
        MilaUI.TestCastbarStopButton = button
    end
    
    MilaUI.TestCastbarStopButton:Show()
    print("Showing test clean castbar for " .. unitKey)
end

function MilaUI:StopAllTestCastbars()
    local unitNames = {unpack(MilaUI.UnitList)}
    
    -- Add boss frames
    for i = 1, MAX_BOSS_FRAMES do
        table.insert(unitNames, "Boss" .. i)
    end
    
    for _, unitName in ipairs(unitNames) do
        local frameObj = MilaUI:GetFrameForUnit(unitName)
        
        -- Stop oUF castbars
        if frameObj and frameObj.Castbar then
            local castbar = frameObj.Castbar
            if castbar.testCastTimer and castbar.testCastTimer.handle then
                castbar.testCastTimer.handle:Cancel()
                castbar.testCastTimer.handle = nil
            end
            -- Clear all test castbar fields
            castbar.casting = false
            castbar.channeling = false
            castbar.interrupted = false
            castbar.failed = false
            castbar.max = nil
            castbar.duration = nil
            castbar.delay = nil
            castbar.startTime = nil
            castbar.endTime = nil
            castbar.spellID = nil
            castbar.notInterruptible = nil
            castbar.testPersistent = false -- Stop the persistent loop
            castbar:Hide()
        end
        
        -- Stop clean castbars
        if frameObj and frameObj.castBar then
            local castBar = frameObj.castBar
            castBar.testPersistent = false -- Stop the persistent loop
            if castBar.StopCast then
                castBar:StopCast()
            end
        end
    end
    
    if MilaUI.TestCastbarStopButton then
        MilaUI.TestCastbarStopButton:Hide()
    end
    
    print("All test castbars stopped")
end

-- Helper function to position the castbar
function MilaUI:PositionCastbar(castbar, parent, settings)
    -- Default position values
    local anchorFrom = "BOTTOM"
    local anchorTo = "TOP"
    local xOffset = 0
    local yOffset = 5
    local relativeTo = parent
    
    -- Try to use settings if they exist and are properly formatted
    if settings.position then
        local pos = settings.position
        
        -- Validate anchor points
        local validAnchors = {
            ["TOP"] = true, ["BOTTOM"] = true, ["LEFT"] = true, ["RIGHT"] = true,
            ["TOPLEFT"] = true, ["TOPRIGHT"] = true, ["BOTTOMLEFT"] = true, ["BOTTOMRIGHT"] = true,
            ["CENTER"] = true
        }
        
        if pos.anchorFrom and validAnchors[pos.anchorFrom] then
            anchorFrom = pos.anchorFrom
        end
        
        if pos.anchorTo and validAnchors[pos.anchorTo] then
            anchorTo = pos.anchorTo
        end
        
        if pos.xOffset and type(pos.xOffset) == "number" then
            xOffset = pos.xOffset
        end
        
        if pos.yOffset and type(pos.yOffset) == "number" then
            yOffset = pos.yOffset
        end
        
        -- Handle anchor parent similar to powerbar implementation
        if pos.anchorParent and type(pos.anchorParent) == "string" then
            -- Check if it's a direct frame reference
            local frameRef = _G[pos.anchorParent]
            if frameRef then
                relativeTo = frameRef
            elseif parent and parent[pos.anchorParent] then
                -- Try to find it as a child of the parent frame
                relativeTo = parent[pos.anchorParent]
            elseif parent then
                -- Default to parent if we can't find the specified frame
                relativeTo = parent
            end
        end
    end
    
    -- Safety check to ensure we have a valid frame before setting point
    if not relativeTo or type(relativeTo) ~= "table" or not relativeTo.SetPoint then
        relativeTo = parent or UIParent
    end
    
    castbar:ClearAllPoints()
    castbar:SetPoint(anchorFrom, relativeTo, anchorTo, xOffset, yOffset)
end

-- Helper function to add border to castbar
local function AddCastbarBorder(castbar, settings)
    if settings.border and settings.border == true then
        local border = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
        border:SetPoint("TOPLEFT", castbar, "TOPLEFT", -settings.borderSize, settings.borderSize)
        border:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", settings.borderSize, -settings.borderSize)
        border:SetBackdrop({ 
            edgeFile = "Interface\\Buttons\\WHITE8X8", 
            edgeSize = settings.borderSize
        })
        border:SetBackdropBorderColor(unpack(settings.borderColor))
        castbar.Border = border
    end
end

-- Helper function to add custom border to castbar
local function AddCastbarCustomBorder(castbar, settings)
    if settings.CustomBorder and settings.CustomBorder.Enabled then
        local customBorder = castbar:CreateTexture(nil, "OVERLAY")
        customBorder:SetAllPoints(castbar)
        customBorder:SetTexture(settings.CustomBorder.BorderTexture)
        castbar.CustomBorder = customBorder
    end
end

-- Helper function to add shield icon for non-interruptible casts
local function AddCastbarShield(castbar, settings)
    if settings.showShield then
        local shield = castbar:CreateTexture(nil, "OVERLAY")
        shield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield")
        shield:SetSize(settings.height * 1.4, settings.height * 1.4)
        shield:SetPoint("CENTER", castbar, "LEFT", 0, 0)
        shield:SetTexCoord(0, 36/256, 0, 1)
        shield:Hide()
        castbar.Shield = shield
    end
end

-- Helper function to add spark to castbar
local function AddCastbarSpark(castbar, settings)
    if settings.Spark and settings.Spark.showSpark then
        local spark = castbar:CreateTexture(nil, "OVERLAY")
        spark:SetSize(settings.Spark.sparkWidth, settings.Spark.sparkHeight)
        spark:SetBlendMode("ADD")
        spark:SetPoint("CENTER", castbar:GetStatusBarTexture(), "RIGHT", 0, 0)
        spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
        spark:SetAlpha(0.8)
        castbar.Spark = spark
    end
end

-- Helper function to add spell icon to castbar
local function AddCastbarIcon(castbar, settings)
    if settings.Icon and settings.Icon.showIcon then
        local iconSize = settings.Icon.iconSize or settings.height
        local icon = castbar:CreateTexture(nil, "OVERLAY")
        icon:SetSize(iconSize, iconSize)
        
        if settings.Icon.iconPosition == "LEFT" then
            icon:SetPoint("RIGHT", castbar, "LEFT", -2, 0)
        else
            icon:SetPoint("LEFT", castbar, "RIGHT", 2, 0)
        end
        
        -- Create icon border
        if settings.borderSize > 0 then
            local iconBorder = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
            iconBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -settings.borderSize, settings.borderSize)
            iconBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", settings.borderSize, -settings.borderSize)
            iconBorder:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                edgeSize = settings.borderSize,
            })
            iconBorder:SetBackdropBorderColor(unpack(settings.borderColor))
            castbar.IconBorder = iconBorder
        end
        
        castbar.Icon = icon
    end
end

-- Helper function to add safe zone (latency indicator)
local function AddCastbarSafeZone(castbar, settings, unit)
    if settings.showSafeZone and unit == "player" then
        local safeZone = castbar:CreateTexture(nil, "OVERLAY")
        local texturePath = LSM:Fetch("statusbar", settings.texture) or LSM:GetDefault("statusbar")
        safeZone:SetTexture(texturePath)
        safeZone:SetVertexColor(unpack(settings.safeZoneColor or {1, 0, 0, 0.6}))
        safeZone:SetPoint("TOPRIGHT")
        safeZone:SetPoint("BOTTOMRIGHT")
        castbar.SafeZone = safeZone
    end
end

-- Helper function to add text to castbar
local function AddCastbarText(castbar, settings, generalSettings)
    -- Create spell name text
    if settings.text and settings.text.showText then
        local text = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", castbar, "LEFT", 5, 0)
        
        -- Apply custom font from LibSharedMedia
        local fontPath = LSM:Fetch("font", generalSettings.font) or "Fonts\\FRIZQT__.TTF"
        local fontSize = settings.text.textsize or 12
        local fontFlags = generalSettings.fontFlags or ""
        text:SetFont(fontPath, fontSize, fontFlags)
        
        text:SetText("")
        text:SetJustifyH(settings.text.textJustify or "LEFT")
        text:SetWidth(settings.width * 0.7)
        text:SetHeight(settings.height)
        text:SetWordWrap(false)
        castbar.Text = text
    end
    
    -- Create time text
    if settings.text and settings.text.showTime then
        local time = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        time:SetPoint("RIGHT", castbar, "RIGHT", -5, 0)
        
        -- Apply custom font from LibSharedMedia
        local fontPath = LSM:Fetch("font", generalSettings.font) or "Fonts\\FRIZQT__.TTF"
        local fontSize = settings.text.timesize or 12
        local fontFlags = generalSettings.fontFlags or ""
        time:SetFont(fontPath, fontSize, fontFlags)
        
        time:SetText("")
        time:SetJustifyH(settings.text.timeJustify or "RIGHT")
        castbar.Time = time
    end
end

-- Helper function to set up empowered cast stages
local function SetupEmpoweredCasts(castbar, settings)
    if settings.showEmpowered then
        castbar.empoweredStages = {}
        
        castbar.PostCastUpdate = function(self, unit)
            local name, text, _, startTime, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(unit)
            if not name then return end
            
            local isEmpowered = spellID and IsSpellEmpowered and IsSpellEmpowered(spellID)
            if not isEmpowered then return end
            
            local numStages = GetSpellEmpowerNumStages and GetSpellEmpowerNumStages(spellID) or 0
            if numStages <= 0 then return end
            
            local stageWidth = self:GetWidth() / numStages
            local empoweredStages = self.empoweredStages
            
            -- Create stage indicators if they don't exist
            if #empoweredStages == 0 then
                for i = 1, numStages do
                    local stage = self:CreateTexture(nil, "OVERLAY")
                    stage:SetSize(2, self:GetHeight())
                    stage:SetColorTexture(1, 1, 1, 0.7)
                    stage:SetPoint("LEFT", self, "LEFT", stageWidth * i, 0)
                    empoweredStages[i] = stage
                end
            end
            
            -- Update stage positions and visibility
            for i = 1, numStages do
                if empoweredStages[i] then
                    empoweredStages[i]:SetPoint("LEFT", self, "LEFT", stageWidth * i, 0)
                    empoweredStages[i]:Show()
                end
            end
            
            for i = numStages + 1, #empoweredStages do
                if empoweredStages[i] then
                    empoweredStages[i]:Hide()
                end
            end
        end
    end
end

-- Helper function to configure castbar properties
local function ConfigureCastbarProperties(castbar, settings, generalSettings)
    castbar.timeToHold = settings.timeToHold
    castbar.hideTradeSkills = settings.hideTradeSkills
    castbar.isNonInterruptible = false
    castbar.isChanneling = false

    -- Use per-unit settings for initial colors, fallback to defaults
    local textures = settings.textures or {}
    castbar.colors = {
        casting = textures.castcolor or {1, 0.7, 0, 1},
        channeling = textures.channelcolor or {0, 0.7, 1, 1},
        nonInterruptible = textures.uninterruptiblecolor or {0.7, 0, 0, 1},
        failed = textures.failedcolor or {1, 0.3, 0.3, 1}
    }
end

-- Helper function to set up event handlers for the castbar
local function SetupCastbarEventHandlers(castbar)
    -- Appearance update method
    castbar.UpdateCastbarAppearance = function(self)
        local unitKey = self.unitKey or (self.__owner and self.__owner.unitKey) or (self:GetParent() and self:GetParent().unitKey)
        local db = MilaUI.DB.profile.Unitframes
        local config = (unitKey and db[unitKey] and db[unitKey].Castbar) or nil
        local textures = config and config.textures or {}
        local LSM = LibStub("LibSharedMedia-3.0")

        -- Fallbacks
        local defaultTexture = LSM and LSM:Fetch("statusbar", "Smooth") or "Interface\\TargetingFrame\\UI-StatusBar"
        local castTex = (textures.cast and LSM and LSM:Fetch("statusbar", textures.cast)) or defaultTexture
        local channelTex = (textures.channel and LSM and LSM:Fetch("statusbar", textures.channel)) or defaultTexture
        local uninterruptibleTex = (textures.uninterruptible and LSM and LSM:Fetch("statusbar", textures.uninterruptible)) or defaultTexture

        local castColor = textures.castcolor or {1, 0.7, 0, 1}
        local channelColor = textures.channelcolor or {0, 0.7, 1, 1}
        local uninterruptibleColor = textures.uninterruptiblecolor or {0.7, 0, 0, 1}
        local failedColor = textures.failedcolor or {1, 0.3, 0.3, 1}

        if self.isNonInterruptible then
            self:SetStatusBarTexture(uninterruptibleTex)
            self:SetStatusBarColor(unpack(uninterruptibleColor))
            if self.Shield then self.Shield:Show() end
        else
            if self.isChanneling then
                self:SetStatusBarTexture(channelTex)
                self:SetStatusBarColor(unpack(channelColor))
            else
                self:SetStatusBarTexture(castTex)
                self:SetStatusBarColor(unpack(castColor))
            end
            if self.Shield then self.Shield:Hide() end
        end
        self._castbarColors = {
            cast = castColor,
            channel = channelColor,
            uninterruptible = uninterruptibleColor,
            failed = failedColor
        }
    end
    
    -- Cast start handler
    castbar.PostCastStart = function(self, unit)
        local castName, castText, castTexture, castStart, castEnd, castIsTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit)
        local isChanneling = false

        if not castName then
            castName, castText, castTexture, castStart, castEnd, castIsTradeSkill, notInterruptible = UnitChannelInfo(unit)
            isChanneling = castName ~= nil
        end

        if not castName then return end

        -- Determine if the cast is non-interruptible
        local isNonInterruptible = (type(notInterruptible) == "boolean" and notInterruptible) or 
                                  (type(notInterruptible) == "number" and notInterruptible == 1)

        -- Store the current state
        self.isNonInterruptible = isNonInterruptible
        self.isChanneling = isChanneling

        -- Update appearance
        self:UpdateCastbarAppearance()

        -- Hide the castbar for tradeskills if configured
        if self.hideTradeSkills and castName and IsTradeSkillSpell and IsTradeSkillSpell(castName) then
            self:Hide()
        end
    end
    
    -- Cast stop handler
    castbar.PostCastStop = function(self, unit)
        self.isNonInterruptible = false
        self.isChanneling = false
        if self.Shield then self.Shield:Hide() end
    end
    
    -- Cast failed handler
    castbar.PostCastFailed = function(self, unit)
        local failedColor = (self._castbarColors and self._castbarColors.failed) or {1, 0.3, 0.3, 1}
        self:SetStatusBarColor(unpack(failedColor))
        self.isNonInterruptible = false
        self.isChanneling = false
        if self.Shield then self.Shield:Hide() end
    end
    
    -- Cast interrupted handler
    castbar.PostCastInterrupted = function(self, unit)
        self.isNonInterruptible = false
        self.isChanneling = false
        if self.Shield then self.Shield:Hide() end
    end
end

-- Main function to create a castbar for a unit frame
function MilaUI:CreateCastbar(self, unit)
    -- Get the unit settings (convert unit to proper case for DB lookup)
    local unitKey = unit:gsub("^%l", string.upper)
    
    -- Skip if the unit doesn't have a castbar or it's disabled
    if not IsCastbarEnabled(unitKey) then 
        return 
    end
    
    -- Get castbar settings
    local settings = MilaUI.DB.profile.Unitframes[unitKey].Castbar
    local generalSettings = MilaUI.DB.profile.Unitframes.General.CastbarSettings
    
    -- Create the main castbar frame
    local castbar = CreateCastbarFrame(self, settings, generalSettings)
    
    -- Configure basic properties first
    ConfigureCastbarProperties(castbar, settings, generalSettings)
    
    -- Position the castbar
    MilaUI:PositionCastbar(castbar, self, settings)
    
    -- Add all visual elements
    AddCastbarBorder(castbar, settings)
    AddCastbarCustomBorder(castbar, settings)
    AddCastbarShield(castbar, settings)
    AddCastbarSpark(castbar, settings)
    AddCastbarIcon(castbar, settings)
    AddCastbarSafeZone(castbar, settings, unit)
    AddCastbarText(castbar, settings, generalSettings)
    
    -- Set up empowered casts
    SetupEmpoweredCasts(castbar, settings)
    
    -- Set up event handlers (must be after properties are configured)
    SetupCastbarEventHandlers(castbar)
    
    -- Register with oUF
    self.Castbar = castbar
    return castbar
end
