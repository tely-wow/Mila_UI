local _, MilaUI = ...

-- Function to create a castbar for a unit frame
function MilaUI:CreateCastbar(self, unit)
    -- Get the unit settings (convert unit to proper case for DB lookup)
    local unitKey = unit:gsub("^%l", string.upper)
    
    -- Skip if the unit doesn't have a castbar or it's disabled
    if not MilaUI.DB.profile.Unitframes[unitKey] or 
       not MilaUI.DB.profile.Unitframes[unitKey].Castbar or 
       not MilaUI.DB.profile.Unitframes[unitKey].Castbar.enabled then 
        return 
    end
    
    -- Get castbar settings
    local settings = MilaUI.DB.profile.Unitframes[unitKey].Castbar
    local generalSettings = MilaUI.DB.profile.Unitframes.General.CastbarSettings
    
    -- Create the castbar
    local castbar = CreateFrame("StatusBar", nil, self)
    castbar:SetSize(settings.width, settings.height)
    
    -- Position the castbar
    if settings.position then
        local pos = settings.position
        local relativeTo = pos.anchorFrom and self[pos.anchorFrom] or self
        castbar:SetPoint(pos.anchorTo, relativeTo, "TOP", pos.xOffset or 0, pos.yOffset or 0)
    else
        -- Default position if not specified
        castbar:SetPoint("BOTTOM", self, "TOP", 0, 5)
    end
    
    -- Set the castbar texture
    castbar:SetStatusBarTexture(settings.texture)
    castbar:SetStatusBarColor(unpack(generalSettings.Colors.barColor))
    
    -- Create a background
    local bg = castbar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(castbar)
    bg:SetTexture(settings.texture)
    bg:SetVertexColor(unpack(settings.backgroundColor))
    castbar.bg = bg
    
    -- Create a border
    if settings.borderSize > 0 then
        local border = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
        border:SetPoint("TOPLEFT", castbar, "TOPLEFT", -settings.borderSize, settings.borderSize)
        border:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", settings.borderSize, -settings.borderSize)
        border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = settings.borderSize,
        })
        border:SetBackdropBorderColor(unpack(settings.borderColor))
        castbar.Border = border
    end
    
    -- Create a spark
    if settings.Spark and settings.Spark.showSpark then
        local spark = castbar:CreateTexture(nil, "OVERLAY")
        spark:SetSize(settings.Spark.sparkWidth, settings.Spark.sparkHeight)
        spark:SetBlendMode("ADD")
        spark:SetPoint("CENTER", castbar:GetStatusBarTexture(), "RIGHT", 0, 0)
        spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
        spark:SetAlpha(0.8)
        castbar.Spark = spark
    end
    
    -- Create spell icon
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
        local iconBorder = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
        iconBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -settings.borderSize, settings.borderSize)
        iconBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", settings.borderSize, -settings.borderSize)
        iconBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = settings.borderSize,
        })
        iconBorder:SetBackdropBorderColor(unpack(settings.borderColor))
        
        castbar.Icon = icon
        castbar.IconBorder = iconBorder
    end
    
    -- Create shield icon for non-interruptible casts
    if settings.showShield then
        local shield = castbar:CreateTexture(nil, "OVERLAY")
        shield:SetSize(settings.height * 1.4, settings.height * 1.4)
        shield:SetPoint("CENTER", castbar, "LEFT", 0, 0)
        shield:SetTexture([[Interface\CastingBar\UI-CastingBar-Small-Shield]])
        shield:SetTexCoord(0, 36/256, 0, 1)
        shield:Hide()
        castbar.Shield = shield
    end
    
    -- Create latency indicator (SafeZone)
    if settings.showSafeZone and unit == "player" then
        local safeZone = castbar:CreateTexture(nil, "OVERLAY")
        safeZone:SetTexture(settings.texture)
        safeZone:SetVertexColor(unpack(settings.safeZoneColor or {1, 0, 0, 0.6}))
        safeZone:SetPoint("TOPRIGHT")
        safeZone:SetPoint("BOTTOMRIGHT")
        castbar.SafeZone = safeZone
    end
    
    -- Create spell text
    if settings.text and settings.text.showText then
        -- Use the standard oUF approach with a font template
        local text = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", castbar, "LEFT", 5, 0)
        
        -- Apply custom font if specified in settings
        if generalSettings.font then
            local fontPath = generalSettings.font
            local fontSize = generalSettings.fontSize or 10
            local fontFlags = generalSettings.fontFlags or ""
            text:SetFont(fontPath, fontSize, fontFlags)
            print("font set for " .. unit .. " castbar text")
        end
        
        text:SetText("") -- Initialize with empty text
        text:SetJustifyH(settings.text.textJustify or "LEFT")
        text:SetWidth(settings.width * 0.7)
        text:SetHeight(settings.height)
        text:SetWordWrap(false)
        castbar.Text = text
    end
    
    -- Create time text
    if settings.text and settings.text.showTime then
        -- Use the standard oUF approach with a font template
        local time = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        time:SetPoint("RIGHT", castbar, "RIGHT", -5, 0)
        
        -- Apply custom font if specified in settings
        if generalSettings.font then
            local fontPath = generalSettings.font
            local fontSize = generalSettings.fontSize or 10
            local fontFlags = generalSettings.fontFlags or ""
            time:SetFont(fontPath, fontSize, fontFlags)
        end
        
        time:SetText("") -- Initialize with empty text
        time:SetJustifyH(settings.text.timeJustify or "RIGHT")
        castbar.Time = time
    end
    
    -- Set castbar options
    castbar.timeToHold = settings.timeToHold
    castbar.hideTradeSkills = settings.hideTradeSkills
    
    
    castbar.colors = {
        casting = generalSettings.Colors.barColor,
        channeling = generalSettings.Colors.channelColor,
        nonInterruptible = generalSettings.Colors.nonInterruptibleColor,
        failed = generalSettings.Colors.failedColor
    }
    
    -- Custom post update function
    castbar.PostCastStart = function(self, unit)
        local name, _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
        if not name then
            name, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
        end
        
        -- Handle non-interruptible casts
        if notInterruptible then
            self:SetStatusBarColor(unpack(self.colors.nonInterruptible))
            if self.Shield then self.Shield:Show() end
        else
            local isChanneling = UnitChannelInfo(unit) ~= nil
            if isChanneling then
                self:SetStatusBarColor(unpack(self.colors.channeling))
            else
                self:SetStatusBarColor(unpack(self.colors.casting))
            end
            if self.Shield then self.Shield:Hide() end
        end
        
        -- Hide the castbar for tradeskills if configured
        if self.hideTradeSkills and name and IsTradeSkillSpell(name) then
            self:Hide()
        end
    end
    
    castbar.PostCastFailed = function(self)
        self:SetStatusBarColor(unpack(self.colors.failed))
    end
    
    -- Handle empowered casts (Evoker)
    if settings.showEmpowered then
        local empoweredStages = {}
        castbar.empoweredStages = empoweredStages
        
        castbar.PostCastUpdate = function(self, unit)
            local name, text, _, startTime, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(unit)
            if not name then return end
            
            local isEmpowered = spellID and IsSpellEmpowered(spellID)
            if not isEmpowered then return end
            
            -- Get empowered spell info
            local numStages = GetSpellEmpowerNumStages(spellID) or 0
            if numStages <= 0 then return end
            
            -- Calculate stage positions
            local castDuration = endTime - startTime
            local stageWidth = self:GetWidth() / numStages
            
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
            
            -- Update stage positions
            for i = 1, numStages do
                if empoweredStages[i] then
                    empoweredStages[i]:SetPoint("LEFT", self, "LEFT", stageWidth * i, 0)
                    empoweredStages[i]:Show()
                end
            end
            
            -- Hide unused stages
            for i = numStages + 1, #empoweredStages do
                if empoweredStages[i] then
                    empoweredStages[i]:Hide()
                end
            end
        end
    end
    
    -- Custom post update function
    castbar.PostUpdate = function(self, unit)
        -- Get cast information
        local castName, castText, castTexture, castStart, castEnd, castIsTradeSkill, castNotInterruptible, castSpellID = UnitCastingInfo(unit)
        local isChanneling = false
        
        -- If not casting, check if channeling
        if not castName then
            castName, castText, castTexture, castStart, castEnd, castIsTradeSkill, castNotInterruptible, castSpellID = UnitChannelInfo(unit)
            if castName then
                isChanneling = true
            end
        end
        
        -- Exit if no cast/channel in progress
        if not castName then return end
        
        -- Debug
        print("Cast: " .. castName .. ", Interruptible: " .. tostring(not castNotInterruptible))
        
        -- Update castbar text
        if self.Text then
            self.Text:SetText(castName)
        end
        
        -- Update castbar time
        if self.Time then
            local time = castEnd - castStart
            -- Use string.format instead of format to ensure it's available
            self.Time:SetText(string.format("%.1f", time/1000))
        end
        
        -- Update castbar color and shield based on interruptibility
        if castNotInterruptible then
            -- Non-interruptible cast
            self:SetStatusBarColor(unpack(self.colors.nonInterruptible))
            if self.Shield then self.Shield:Show() end
        else
            -- Interruptible cast
            if isChanneling then
                self:SetStatusBarColor(unpack(self.colors.channeling))
            else
                self:SetStatusBarColor(unpack(self.colors.casting))
            end
            if self.Shield then self.Shield:Hide() end
        end
        
        -- Update empowered stages
        if self.empoweredStages then
            self:PostCastUpdate(unit)
        end
    end
    
    -- Register with oUF
    self.Castbar = castbar
    return castbar
end