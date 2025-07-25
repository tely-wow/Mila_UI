local _, ns = ...
local addon = ns.addon
local module = ns.modules.bars
local LSM = LibStub("LibSharedMedia-3.0")

-- Helper function to safely get textures from LSM with fallbacks
local function GetTexture(mediaType, textureName, fallback)
    if not textureName then
        return fallback or LSM:Fetch(mediaType, "Smooth")
    end
    
    local success, texture = pcall(LSM.Fetch, LSM, mediaType, textureName)
    if success and texture then
        return texture
    end
    
    -- Fallback to default if texture not found
    return fallback or LSM:Fetch(mediaType, "Smooth")
end

-- CLEAN CAST BAR SYSTEM - No Blizzard template bullshit

-- Cleanup functions
function module.StopHolderAnimations(castBar)
    if not castBar then return end
    
    -- Stop animations for all holders
    local holders = {
        castBar.holderFrame, 
        castBar.castCompletionHolder, 
        castBar.channelCompletionHolder,
        castBar.uninterruptibleHolder
    }
    
    for _, holder in pairs(holders) do
        if holder then
            -- Hide spark
            if holder.spark then
                holder.spark:Hide()
            end
            
            -- Stop completion flash
            if holder.completionFlashAnim then
                holder.completionFlashAnim:Stop()
            end
            if holder.completionFlash then
                holder.completionFlash:Hide()
                holder.completionFlash:SetAlpha(0)
                holder.completionFlash:SetScale(1, 1)
            end
            
            -- Stop interrupt glow
            if holder.interruptGlowAnim then
                holder.interruptGlowAnim:Stop()
            end
            if holder.interruptGlow then
                holder.interruptGlow:Hide()
                holder.interruptGlow:SetAlpha(0)
            end
            
            -- Stop shake
            if holder.shakeStartTime then
                holder.shakeStartTime = nil
                if holder.shakeOriginalPoint then
                    holder:ClearAllPoints()
                    holder:SetPoint(unpack(holder.shakeOriginalPoint))
                    holder.shakeOriginalPoint = nil
                end
            end
            
            -- Cancel timers
            if holder.hideTimer then
                holder.hideTimer:Cancel()
                holder.hideTimer = nil
            end
            
            -- Stop fade animations
            if holder.fadeOutAnim then
                holder.fadeOutAnim:Stop()
            end
            if holder.interruptFadeOutAnim then
                holder.interruptFadeOutAnim:Stop()
            end
            
            holder:Hide()
            holder:SetAlpha(1) -- Reset alpha
        end
    end
end

function module.CleanupCastBar(castBar)
    if not castBar then return end
    
    module.StopHolderAnimations(castBar)
    
    -- Cancel any pending hide timers
    if castBar.hideTimer then
        castBar.hideTimer:Cancel()
        castBar.hideTimer = nil
    end
    
    if castBar.updateTimer then
        castBar.updateTimer:Cancel()
        castBar.updateTimer = nil
    end
    
    castBar:UnregisterAllEvents()
    castBar:SetScript("OnEvent", nil)
    castBar:SetScript("OnUpdate", nil)
    castBar:Hide()
    castBar:SetParent(nil)
end

-- MASKING SYSTEM - Add these functions to your existing code

function module.CreateMask(parent, width, height, maskTexture)
    if not parent then return end
    
    -- Create mask frame
    local maskFrame = CreateFrame("Frame", nil, parent)
    maskFrame:SetSize(width, height)
    maskFrame:SetAllPoints(parent)
    
    -- Create mask texture
    local mask = maskFrame:CreateMaskTexture()
    mask:SetTexture(maskTexture or "Interface\\AddOns\\Mila_UI\\Textures\\UIUnitFramePlayerHealthMask2x.tga")
    mask:SetAllPoints(maskFrame)
    
    return mask
end

function module.ApplyMaskToStatusBar(statusBar, mask)
    if not statusBar or not mask then return end
    
    -- Apply mask to the status bar texture
    local statusBarTexture = statusBar:GetStatusBarTexture()
    if statusBarTexture then
        statusBarTexture:AddMaskTexture(mask)
    end
    
    -- Apply mask to background if it exists
    if statusBar.bg then
        statusBar.bg:AddMaskTexture(mask)
    end
    
    -- Store mask reference for later use
    statusBar.appliedMask = mask
end

function module.RemoveMaskFromStatusBar(statusBar)
    if not statusBar or not statusBar.appliedMask then return end
    
    -- Remove mask from status bar texture
    local statusBarTexture = statusBar:GetStatusBarTexture()
    if statusBarTexture then
        statusBarTexture:RemoveMaskTexture(statusBar.appliedMask)
    end
    
    -- Remove mask from background if it exists
    if statusBar.bg then
        statusBar.bg:RemoveMaskTexture(statusBar.appliedMask)
    end
    
    -- Clear mask reference
    statusBar.appliedMask = nil
end

function module.SetCastBarMask(castBar, maskTexture)
    if not castBar then return end
    
    local width = castBar:GetWidth()
    local height = castBar:GetHeight()
    
    -- Create mask for main cast bar
    local mask = module.CreateMask(castBar, width, height, maskTexture)
    if mask then
        module.ApplyMaskToStatusBar(castBar, mask)
        castBar.mask = mask
    end
    
    -- Apply same mask to all holder frames
    local holders = {
        castBar.holderFrame,
        castBar.castCompletionHolder,
        castBar.channelCompletionHolder,
        castBar.uninterruptibleHolder
    }
    
    for _, holder in pairs(holders) do
        if holder then
            local holderMask = module.CreateMask(holder, width, height, maskTexture)
            if holderMask then
                module.ApplyMaskToStatusBar(holder, holderMask)
                holder.mask = holderMask
            end
        end
    end
end

function module.RemoveCastBarMask(castBar)
    if not castBar then return end
    
    -- Remove mask from main cast bar
    module.RemoveMaskFromStatusBar(castBar)
    castBar.mask = nil
    
    -- Remove masks from all holder frames
    local holders = {
        castBar.holderFrame,
        castBar.castCompletionHolder,
        castBar.channelCompletionHolder,
        castBar.uninterruptibleHolder
    }
    
    for _, holder in pairs(holders) do
        if holder then
            module.RemoveMaskFromStatusBar(holder)
            holder.mask = nil
        end
    end
end


function module.CreateCleanCastBar(parent, unit, options)
    if not parent or not unit then return end
    
    options = options or {}
    local width = (options.size and options.size.width) or parent:GetWidth()
    local height = (options.size and options.size.height) or 18
    local xOffset = (options.position and options.position.xOffset) or 0
    local yOffset = (options.position and options.position.yOffset) or -20
    -- Get display sub-sections
    local icon = options.display and options.display.icon or {}
    local text = options.display and options.display.text or {}
    local timer = options.display and options.display.timer or {}
    
    local showIcon = icon.show ~= false
    local showText = text.show ~= false
    local showTimer = timer.show ~= false
    
    -- Create main cast bar frame (no template!)
    local castBar = CreateFrame("StatusBar", nil, parent)
    castBar:SetSize(width, height)
    
    -- Get anchor settings from config
    local anchorPoint = (options.position and options.position.anchorPoint) or "CENTER"
    local anchorTo = (options.position and options.position.anchorTo) or "CENTER"
    local anchorFrame = (options.position and options.position.anchorFrame) or parent
    
    -- Convert string frame name to actual frame if needed
    if type(anchorFrame) == "string" then
        anchorFrame = _G[anchorFrame] or parent
    end
    
    castBar:SetPoint(anchorPoint, anchorFrame, anchorTo, xOffset, yOffset)
    
    -- Get texture from LSM with fallback
    local mainTexture = GetTexture("statusbar", (options.textures and options.textures.main), "Interface\\Buttons\\WHITE8X8")
    castBar:SetStatusBarTexture(mainTexture)
    -- Don't set hardcoded color here - let UpdateAppearance handle it
    castBar:SetMinMaxValues(0, 1)
    castBar:SetValue(0)
    castBar:SetAlpha(1)
    castBar:Hide()
    
    module.SetCastBarMask(castBar, "Interface\\AddOns\\Mila_UI\\Textures\\UIUnitFramePlayerHealthMask2x.tga")
    
    -- Store references
    castBar.unit = unit
    castBar.options = options
    parent.castBar = castBar
    
    -- Initialize color configuration from options
    if options.colors then
        castBar.colorConfig = {
            cast = options.colors.cast or {0, 1, 1, 1},
            completion = options.colors.completion or {0.2, 1.0, 1.0, 1.0},
            channel = options.colors.channel or {1.0, 0.4, 1.0, 1.0},
            uninterruptible = options.colors.uninterruptible or {0.8, 0.8, 0.8, 1.0},
            interrupt = options.colors.interrupt or {1, 0.2, 0.2, 1}
        }
        
        -- Apply initial cast color
        local initialColor = castBar.colorConfig.cast
        castBar:SetStatusBarColor(unpack(initialColor))
    else
        -- Apply default color if no color config
        castBar:SetStatusBarColor(0, 1, 1, 1)
    end
    
    -- Create background
    local bg = castBar:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\AddOns\\Mila_UI\\Textures\\MirroredFrameSingleBG.tga")
    bg:SetAllPoints(castBar)
    bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    castBar.bg = bg
    
    -- Create border with backdrop
    local border = CreateFrame("Frame", nil, castBar, "BackdropTemplate")
    border:SetPoint("TOPLEFT", castBar, "TOPLEFT", -10, 10)
    border:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 10, -10)
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\Mila_UI\\Textures\\MirroredFrameSingle2.tga",
        edgeSize = 14,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    castBar.border = border
    
    -- Create spark
    local spark = castBar:CreateTexture(nil, "OVERLAY")
    spark:SetTexture("Interface\\AddOns\\Mila_UI\\Textures\\absorbsparkcastbar.tga")
    spark:SetSize(20, height)
    spark:SetBlendMode("ADD")
    spark:Hide()
    castBar.spark = spark
    
    -- Create icon
    if showIcon then
        local iconFrame = castBar:CreateTexture(nil, "OVERLAY", nil, 1)
        iconFrame:SetSize(icon.size or (height + 4), icon.size or (height + 4))
        
        -- Use anchor settings from database
        local anchorFrom = icon.anchorFrom or (unit == "player" and "LEFT" or "RIGHT")
        local anchorTo = icon.anchorTo or (unit == "player" and "RIGHT" or "LEFT")
        local xOffset = icon.xOffset or 4
        local yOffset = icon.yOffset or 0
        
        -- Adjust xOffset for non-player units if using old behavior
        if unit ~= "player" and not icon.anchorFrom then
            xOffset = -xOffset
        end
        
        iconFrame:SetPoint(anchorFrom, castBar, anchorTo, xOffset, yOffset)
        castBar.icon = iconFrame
    end
    
    -- Create text
    if showText then
        local textFrame = castBar:CreateFontString(nil, "OVERLAY")
        local fontPath = LSM:Fetch("font", text.font or "Expressway") or "Fonts\\FRIZQT__.TTF"
        textFrame:SetFont(fontPath, text.size or 12, text.fontFlags or "OUTLINE")
        
        -- Use anchor settings from database
        local anchorFrom = text.anchorFrom or "BOTTOM"
        local anchorTo = text.anchorTo or "TOP"
        local xOffset = text.xOffset or 0
        local yOffset = text.yOffset or 2
        
        textFrame:SetPoint(anchorFrom, castBar, anchorTo, xOffset, yOffset)
        textFrame:SetTextColor(unpack(text.fontColor or {1, 1, 1, 1}))
        castBar.text = textFrame
    end
    
    -- Create timer
    if showTimer then
        local timerFrame = castBar:CreateFontString(nil, "OVERLAY")
        local fontPath = LSM:Fetch("font", timer.font or "Expressway") or "Fonts\\FRIZQT__.TTF"
        timerFrame:SetFont(fontPath, timer.size or 10, timer.fontFlags or "OUTLINE")
        
        -- Use anchor settings from database
        local anchorFrom = timer.anchorFrom or "RIGHT"
        local anchorTo = timer.anchorTo or "RIGHT"
        local xOffset = timer.xOffset or -5
        local yOffset = timer.yOffset or 0
        
        timerFrame:SetPoint(anchorFrom, castBar, anchorTo, xOffset, yOffset)
        timerFrame:SetTextColor(unpack(timer.fontColor or {1, 1, 1, 1}))
        castBar.timer = timerFrame
    end

    -- CREATE HOLDER FRAME SYSTEM - Separate holders for each type
    local holderFrame = CreateFrame("StatusBar", nil, parent)
    holderFrame:SetSize(width, height)
    holderFrame:SetPoint(anchorPoint, anchorFrame, anchorTo, xOffset, yOffset)
    local interruptTexture = GetTexture("statusbar", (options.textures and options.textures.interrupt), "Interface\\AddOns\\Mila_UI\\Textures\\statusbar\\HPRedHD.tga")
    holderFrame:SetStatusBarTexture(interruptTexture)
    --holderFrame:SetStatusBarColor(1, 0, 0, 1.0) -- Red for interrupts
    holderFrame:SetMinMaxValues(0, 1)
    holderFrame:SetValue(0)
    holderFrame:Hide()
    castBar.holderFrame = holderFrame -- Keep for interrupt (existing system)
    
    -- CREATE CAST COMPLETION HOLDER
    local castCompletionHolder = CreateFrame("StatusBar", nil, parent)
    castCompletionHolder:SetSize(width, height)
    castCompletionHolder:SetPoint(anchorPoint, anchorFrame, anchorTo, xOffset, yOffset)
    local castCompletionTexture = GetTexture("statusbar", (options.textures and options.textures.castCompletion), "Interface\\AddOns\\Mila_UI\\Textures\\g1.tga")
    castCompletionHolder:SetStatusBarTexture(castCompletionTexture)
    --castCompletionHolder:SetStatusBarColor(0.2, 1.0, 1.0, 1.0) -- Bright cyan for cast completion
    castCompletionHolder:SetMinMaxValues(0, 1)
    castCompletionHolder:SetValue(0)
    castCompletionHolder:Hide()
    castBar.castCompletionHolder = castCompletionHolder
    
    -- CREATE CHANNEL COMPLETION HOLDER  
    local channelCompletionHolder = CreateFrame("StatusBar", nil, parent)
    channelCompletionHolder:SetSize(width, height)
    channelCompletionHolder:SetPoint(anchorPoint, anchorFrame, anchorTo, xOffset, yOffset)
    local channelCompletionTexture = GetTexture("statusbar", (options.textures and options.textures.channelCompletion), "Interface\\AddOns\\Mila_UI\\Textures\\g1.tga")
    channelCompletionHolder:SetStatusBarTexture(channelCompletionTexture)
    -- Color will be set by UpdateCastBarColors
    channelCompletionHolder:SetMinMaxValues(0, 1)
    channelCompletionHolder:SetValue(0)
    channelCompletionHolder:Hide()
    castBar.channelCompletionHolder = channelCompletionHolder
    
    -- CREATE UNINTERRUPTIBLE COMPLETION HOLDER
    local uninterruptibleHolder = CreateFrame("StatusBar", nil, parent)
    uninterruptibleHolder:SetSize(width, height)
    uninterruptibleHolder:SetPoint(anchorPoint, anchorFrame, anchorTo, xOffset, yOffset)
    local uninterruptibleTexture = GetTexture("statusbar", (options.textures and options.textures.uninterruptible), "Interface\\AddOns\\Mila_UI\\Textures\\g1.tga")
    uninterruptibleHolder:SetStatusBarTexture(uninterruptibleTexture)
    -- Color will be set by UpdateCastBarColors
    uninterruptibleHolder:SetMinMaxValues(0, 1)
    uninterruptibleHolder:SetValue(0)
    uninterruptibleHolder:Hide()
    castBar.uninterruptibleHolder = uninterruptibleHolder
    
    -- Create shared components for all holders with customizable textures/flashes
    local function setupHolderComponents(holder, holderType, unitName)
        -- Get flash colors from database settings - access through namespace
        local profile = ns.DB and ns.DB.profile
        
        
        -- Get flash colors from database
        local flashColors = profile and profile.castBars and profile.castBars[unitName] and profile.castBars[unitName].flashColors
        
        -- Define holder type configurations with database flash colors
local holderConfigs = {
    interrupt = {
        flashColor = (flashColors and flashColors.interrupt) or {1, 1, 1, 1},
        flashTexture = "Interface\\AddOns\\Mila_UI\\Textures\\interruptglow.tga",
        sparkTexture = "Interface\\AddOns\\Mila_UI\\Textures\\test\\orangespark.tga",
        sparkColor = {1, 1, 1, 1},
		blendMode = "ADD",
		sparkWidth = 20,
		sparkHeight = 32, 
        hasGlow = true,
        hasFlash = false
    },
    cast = {
        flashColor = (flashColors and flashColors.cast) or {0.2, 0.8, 0.2, 1.0},
        flashTexture = "Interface\\AddOns\\Mila_UI\\Textures\\cflash.tga", 
        sparkTexture = "Interface\\AddOns\\Mila_UI\\Textures\\absorbsparkcastbar.tga",
        sparkColor = {1, 1, 1, 0.2},
		--sparkWidth = 20,
        hasGlow = false,
        hasFlash = true
    },
    channel = {
        flashColor = (flashColors and flashColors.channel) or {1.0, 0.4, 1.0, 0.9},
        flashTexture = "Interface\\AddOns\\Mila_UI\\Textures\\cflash.tga",
        sparkTexture = "Interface\\AddOns\\Mila_UI\\Textures\\test\\orangespark.tga",
        sparkColor = {1, 1, 1, 1}, --{1.0, 0.4, 1.0, 1},
		blendMode = ("ADD"),
		sparkHeight = 32,
		sparkWidth = 20,
        hasGlow = false,
        hasFlash = true
    },
    uninterruptible = {
        flashColor = (flashColors and flashColors.uninterruptible) or {0.8, 0.8, 0.8, 0.9},
        flashTexture = "Interface\\AddOns\\Mila_UI\\Textures\\cflash.tga",
        sparkTexture = "Interface\\AddOns\\Mila_UI\\Textures\\absorbsparkcastbar.tga",
        sparkColor = {0.9, 0.9, 0.9, 1},
        hasGlow = false,
        hasFlash = true
    }
}
        local config = holderConfigs[holderType]
        
        -- Create holder background
        local holderBg = holder:CreateTexture(nil, "BACKGROUND")
        holderBg:SetTexture("Interface\\AddOns\\Mila_UI\\Textures\\MirroredFrameSingleBG.tga")
        holderBg:SetAllPoints(holder)
        holderBg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
        holder.bg = holderBg
        
        -- Create holder border
        local holderBorder = CreateFrame("Frame", nil, holder, "BackdropTemplate")
        holderBorder:SetPoint("TOPLEFT", holder, "TOPLEFT", -12, 12)
        holderBorder:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 12, -12)
        holderBorder:SetBackdrop({
            edgeFile = "Interface\\AddOns\\Mila_UI\\Textures\\MirroredFrameSingle2.tga",
            edgeSize = 16,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        holderBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        holder.border = holderBorder
        
        -- Create holder text
        if showText then
            local holderText = holder:CreateFontString(nil, "OVERLAY")
            local fontPath = LSM:Fetch("font", text.font or "Expressway") or "Fonts\\FRIZQT__.TTF"
            holderText:SetFont(fontPath, text.size or 12, text.fontFlags or "OUTLINE")
            
            -- Use anchor settings from database
            local anchorFrom = text.anchorFrom or "BOTTOM"
            local anchorTo = text.anchorTo or "TOP"
            local xOffset = text.xOffset or 0
            local yOffset = text.yOffset or 2
            
            holderText:SetPoint(anchorFrom, holder, anchorTo, xOffset, yOffset)
            holderText:SetTextColor(unpack(text.fontColor or {1, 1, 1, 1}))
            holder.text = holderText
        end
        
        -- Create holder icon
        if showIcon then
            local holderIcon = holder:CreateTexture(nil, "OVERLAY", nil, 1)
            holderIcon:SetSize(icon.size or (height + 4), icon.size or (height + 4))
            
            -- Use anchor settings from database
            local anchorFrom = icon.anchorFrom or (unit == "player" and "LEFT" or "RIGHT")
            local anchorTo = icon.anchorTo or (unit == "player" and "RIGHT" or "LEFT")
            local xOffset = icon.xOffset or 4
            local yOffset = icon.yOffset or 0
            
            -- Adjust xOffset for non-player units if using old behavior
            if unit ~= "player" and not icon.anchorFrom then
                xOffset = -xOffset
            end
            
            holderIcon:SetPoint(anchorFrom, holder, anchorTo, xOffset, yOffset)
            holder.icon = holderIcon
        end
        
-- Create spark for holder with custom texture and color - OUTSIDE the masked holder
local sparkFrame = CreateFrame("Frame", nil, holder) -- Use holder as parent
sparkFrame:SetSize(config.sparkWidth or 20, config.sparkHeight or height)
sparkFrame:SetFrameLevel(holder:GetFrameLevel() + 1) -- Above the holder

local holderSpark = sparkFrame:CreateTexture(nil, "OVERLAY")
holderSpark:SetTexture(config.sparkTexture)
holderSpark:SetAllPoints(sparkFrame) -- Fill the entire spark frame
holderSpark:SetVertexColor(unpack(config.sparkColor))
local blendMode = config.blendMode or "ADD" -- Default to ADD if not specified
holderSpark:SetBlendMode(blendMode)

sparkFrame:Hide()
holder.spark = sparkFrame -- Store the frame, not the texture
holder.sparkTexture = holderSpark -- Store texture separately if needed
        
        -- Create completion flash with custom color/texture
        if config.hasFlash then
            -- Create a frame for the flash that will move with the holder
            local flashFrame = CreateFrame("Frame", nil, holder)
            flashFrame:SetSize(width + 20, height + 20) -- Slightly larger than holder
            flashFrame:SetPoint("CENTER", holder, "CENTER", 0, 0) -- Centered on holder
            
            local holderCompletionFlash = flashFrame:CreateTexture(nil, "OVERLAY", nil, 3)
            holderCompletionFlash:SetTexture(config.flashTexture)
            holderCompletionFlash:SetAllPoints(flashFrame) -- Fill the frame
            holderCompletionFlash:SetVertexColor(unpack(config.flashColor))
            holderCompletionFlash:SetBlendMode("ADD")
            holderCompletionFlash:Hide()
            
            holder.flashFrame = flashFrame -- Store the frame reference
            holder.completionFlash = holderCompletionFlash
        end
        
        -- Create interrupt glow with custom color
        if config.hasGlow then
            -- Create a frame for the glow that will move with the holder
            local glowFrame = CreateFrame("Frame", nil, holder)
            glowFrame:SetSize(width + 20, height + 10) -- Slightly larger than holder
            glowFrame:SetPoint("CENTER", holder, "CENTER", 0, 0) -- Centered on holder
            
            local holderInterruptGlow = glowFrame:CreateTexture(nil, "OVERLAY", nil, 2)
            holderInterruptGlow:SetTexture(config.flashTexture)
            holderInterruptGlow:SetAllPoints(glowFrame) -- Fill the frame
            holderInterruptGlow:SetVertexColor(unpack(config.flashColor))
            --holderInterruptGlow:SetBlendMode("ADD")
            holderInterruptGlow:Hide()
            
            holder.glowFrame = glowFrame -- Store the frame reference
            holder.interruptGlow = holderInterruptGlow
        end
        
        -- Store config for easy access
        holder.holderType = holderType
        holder.config = config
    end
    
    -- Setup all holders with their specific types
    setupHolderComponents(holderFrame, "interrupt", unit)
    setupHolderComponents(castCompletionHolder, "cast", unit)
    setupHolderComponents(channelCompletionHolder, "channel", unit)
    setupHolderComponents(uninterruptibleHolder, "uninterruptible", unit)
    
    -- CORE STATE VARIABLES
    castBar.isChanneling = false
    castBar.castStartTime = 0
    castBar.castEndTime = 0
    castBar.spellName = ""
    castBar.spellIcon = ""
    castBar.isInterruptible = true
    castBar.castID = nil
    castBar.isCasting = false
    
    -- CORE FUNCTIONS
    
function castBar:UpdateAppearance(castType, isInterruptible)
    -- Get colors from database settings or use defaults
    local colors = self.colorConfig or {}
    local defaultColors = {
        cast = {0, 1, 1, 1},
        completion = {0.2, 1.0, 1.0, 1.0},
        channel = {1.0, 0.4, 1.0, 1.0},
        uninterruptible = {0.8, 0.8, 0.8, 1.0},
        interrupt = {1, 0.2, 0.2, 1}
    }
    
    if castType == "cast" then
        if isInterruptible then
            local texture = GetTexture("statusbar", (self.options.textures and self.options.textures.cast), "Interface\\AddOns\\Mila_UI\\Textures\\HPYellowHD.tga")
            self:SetStatusBarTexture(texture)
            local color = colors.cast or defaultColors.cast
            self:SetStatusBarColor(unpack(color))
        else
            local texture = GetTexture("statusbar", (self.options.textures and self.options.textures.uninterruptible), "Interface\\AddOns\\Mila_UI\\Textures\\statusbar\\ArmorCastBar.tga")
            self:SetStatusBarTexture(texture)
            local color = colors.uninterruptible or defaultColors.uninterruptible
            self:SetStatusBarColor(unpack(color))
        end
    elseif castType == "channel" then
        if isInterruptible then
            local texture = GetTexture("statusbar", (self.options.textures and self.options.textures.channel), "Interface\\AddOns\\Mila_UI\\Textures\\shield-fill.tga")
            self:SetStatusBarTexture(texture)
            local color = colors.channel or defaultColors.channel
            self:SetStatusBarColor(unpack(color))
        else
            local texture = GetTexture("statusbar", (self.options.textures and self.options.textures.uninterruptible), "Interface\\AddOns\\Mila_UI\\Textures\\statusbar\\ArmorCastBar.tga")
            self:SetStatusBarTexture(texture)
            local color = colors.uninterruptible or defaultColors.uninterruptible
            self:SetStatusBarColor(unpack(color))
        end
    elseif castType == "interrupt" then
        local texture = GetTexture("statusbar", (self.options.textures and self.options.textures.interrupt), "Interface\\AddOns\\Mila_UI\\Textures\\statusbar\\HPRedHD2.tga")
        self:SetStatusBarTexture(texture)
        local color = colors.interrupt or defaultColors.interrupt
        self:SetStatusBarColor(unpack(color))
    end
    
    -- Force texture update for statusbar (sometimes needed for mid-cast target changes)
    local statusBarTexture = self:GetStatusBarTexture()
    if statusBarTexture then
        statusBarTexture:SetDrawLayer("ARTWORK", 0)
    end
end
    
    -- UNIFIED: Setup channel (used everywhere channels are detected)
    function castBar:SetupChannel(name, texture, startTimeMS, endTimeMS, isInterruptible)
        module.StopHolderAnimations(self)
        
        self.isChanneling = true
        self.isCasting = true
        self.spellName = name
        self.spellIcon = texture or ""
        self.isInterruptible = isInterruptible
        
        self:UpdateAppearance("channel", isInterruptible)
        
        if self.text then
            self.text:SetText(name)
        end
        
        if self.icon then
            self.icon:SetTexture(self.spellIcon)
        end
        
        self.spark:Show()
        self:Show()
        
        -- Set up timing
        if startTimeMS and endTimeMS then
            self.castStartTime = startTimeMS
            self.castEndTime = endTimeMS
        else
            -- Fallback: get current channel state
            local currentName, currentText, currentTexture, currentStartTime, currentEndTime, _, currentNotInterruptible = UnitChannelInfo(self.unit)
            if currentEndTime then
                -- Check if interruptibility changed in the fresh data
                if currentNotInterruptible ~= nil and (not currentNotInterruptible) ~= self.isInterruptible then
                    -- Update if there's a mismatch
                    self.isInterruptible = not currentNotInterruptible
                    self:UpdateAppearance("channel", self.isInterruptible)
                end
                
                self.castStartTime = currentStartTime or (currentEndTime - 5000)
                self.castEndTime = currentEndTime
            else
                self.castStartTime = 0
                self.castEndTime = 0
                self:SetValue(0.5)
            end
        end
    end
    
    -- Unified cast starting (handles both fresh and mid-cast)
    function castBar:StartCast(name, icon, startTime, endTime, isInterruptible, castID)
        module.StopHolderAnimations(self)
        
        self.isChanneling = false
        self.isCasting = true
        self.spellName = name
        self.spellIcon = icon
        self.isInterruptible = isInterruptible
        self.castID = castID
        
        self:UpdateAppearance("cast", isInterruptible)
        
        if self.text then
            self.text:SetText(name)
        end
        
        if self.icon then
            self.icon:SetTexture(icon)
        end
        
        self.spark:Show()
        self:Show()
        
        -- Handle timing: fresh cast vs mid-cast
        if startTime and endTime and startTime > 0 and endTime > 0 then
            self.castStartTime = startTime
            self.castEndTime = endTime
        else
            -- Mid-cast: calculate timing like Blizzard
            local currentName, currentText, currentTexture, currentStartTime, currentEndTime, _, _, currentNotInterruptible = UnitCastingInfo(self.unit)
            if currentName and currentStartTime then
                -- Check if interruptibility changed in the fresh data
                if currentNotInterruptible ~= nil and (not currentNotInterruptible) ~= self.isInterruptible then
                    -- Update if there's a mismatch
                    self.isInterruptible = not currentNotInterruptible
                    self:UpdateAppearance("cast", self.isInterruptible)
                end
                
                local spellID = C_Spell.GetSpellIDForSpellIdentifier(name)
                local castTime = 2500 -- default
                
                if spellID then
                    local spellInfo = C_Spell.GetSpellInfo(spellID)
                    if spellInfo and spellInfo.castTime then
                        castTime = spellInfo.castTime
                    end
                end
                
                self.castStartTime = currentStartTime
                self.castEndTime = currentStartTime + castTime
            else
                self.castStartTime = 0
                self.castEndTime = 0
                self:SetValue(0.5)
            end
        end
    end
    
    -- Stop casting/channeling
    function castBar:StopCast()
        self.spark:Hide()
        self:Hide()
        self.castStartTime = 0
        self.castEndTime = 0
        self.castID = nil
        self.isCasting = false
        self.isChanneling = false
    end
    
    -- Show completion flash on appropriate holder frame
    function castBar:ShowCompletionFlash()
        local currentProgress = self:GetValue()
        local spellName = self.spellName
        local spellIcon = self.spellIcon
        local isChanneling = self.isChanneling
        local isInterruptible = self.isInterruptible
        
        -- Choose the correct holder based on cast type and interruptibility
        local targetHolder
        if not isInterruptible then
            targetHolder = self.uninterruptibleHolder
        elseif isChanneling then
            targetHolder = self.channelCompletionHolder
        else
            targetHolder = self.castCompletionHolder  
        end
        
        -- GUARD: Prevent multiple calls
        if targetHolder:IsShown() then
            return
        end
        
        -- Copy current state to appropriate holder
        targetHolder:SetValue(currentProgress)
        
        -- Show spark at completion progress point
        self:UpdateHolderSpark(targetHolder, currentProgress)
        
        -- No text on completion
        if targetHolder.text then
            targetHolder.text:SetText("")
        end
        
        if targetHolder.icon and spellIcon then
            targetHolder.icon:SetTexture(spellIcon)
        end
        
        -- Hide main cast bar immediately
        self:Hide()
        
        -- Show appropriate holder frame
        targetHolder:Show()
        
        -- Play completion flash on holder
        if not targetHolder.completionFlashAnim then
            targetHolder.completionFlashAnim = targetHolder.completionFlash:CreateAnimationGroup()
            
            -- Quick bright flash
            local flashIn = targetHolder.completionFlashAnim:CreateAnimation("Alpha")
            flashIn:SetOrder(1)
            flashIn:SetDuration(0.2)
            flashIn:SetFromAlpha(0)
            flashIn:SetToAlpha(1)
            
            
            -- Fade out
            local flashOut = targetHolder.completionFlashAnim:CreateAnimation("Alpha")
            flashOut:SetOrder(2)
            flashOut:SetDuration(0.6)
            flashOut:SetFromAlpha(1)
            flashOut:SetToAlpha(0)
            flashOut:SetSmoothing("OUT")
            
            -- Scale back
            local scaleDown = targetHolder.completionFlashAnim:CreateAnimation("Scale")
            scaleDown:SetOrder(2)
            scaleDown:SetDuration(0.6)
            scaleDown:SetScale(0.9, 0.9)
            scaleDown:SetOrigin("CENTER", 0, 0)
            scaleDown:SetSmoothing("OUT")
            
            targetHolder.completionFlashAnim:SetScript("OnFinished", function()
                targetHolder.completionFlash:Hide()
                targetHolder.completionFlash:SetScale(1, 1)
                
                -- Start fade out after short hold
                targetHolder.hideTimer = C_Timer.NewTimer(0.1, function()
                    if targetHolder then
                        -- Create fade out animation if it doesn't exist
                        if not targetHolder.fadeOutAnim then
                            targetHolder.fadeOutAnim = targetHolder:CreateAnimationGroup()
                            local fadeOut = targetHolder.fadeOutAnim:CreateAnimation("Alpha")
                            fadeOut:SetDuration(0.4)
                            fadeOut:SetFromAlpha(1)
                            fadeOut:SetToAlpha(0)
                            fadeOut:SetSmoothing("OUT")
                            
                            targetHolder.fadeOutAnim:SetScript("OnFinished", function()
                                targetHolder:Hide()
                                targetHolder:SetAlpha(1)
                            end)
                        end
                        
                        targetHolder.fadeOutAnim:Play()
                    end
                end)
            end)
        end
        
        targetHolder.completionFlash:Show()
        targetHolder.completionFlash:SetAlpha(0)
        targetHolder.completionFlash:SetScale(1, 1)
        targetHolder.completionFlashAnim:Play()
    end
    
    -- Show interrupt animation on holder frame
    function castBar:ShowInterruptAnimation()
        -- GUARD: Prevent multiple calls
        if self.holderFrame:IsShown() then
            return
        end
        
        local currentProgress = self:GetValue()
        local spellName = self.spellName
        local spellIcon = self.spellIcon
        
        -- Copy current state to holder (frozen at interrupt point)
        self.holderFrame:SetValue(currentProgress)
        -- Color is already set by holder initialization, don't override it
        
        -- Show spark at interrupt progress point
        self:UpdateHolderSpark(self.holderFrame, currentProgress)
        
        -- Simple interrupt text
        if self.holderFrame.text then
            self.holderFrame.text:SetText("Interrupted")
        end
        
        if self.holderFrame.icon and spellIcon then
            self.holderFrame.icon:SetTexture(spellIcon)
        end
        
        -- Hide main cast bar immediately
        self:Hide()
        
        -- Show holder frame
        self.holderFrame:Show()
        
        -- Play shake animation on holder frame
        self:PlayHolderShake()
        
        -- Play interrupt glow on holder
        self:PlayHolderInterruptGlow()
    end
    
    -- Enhanced shake animation
    function castBar:PlayHolderShake()
        if not self.holderFrame then return end
        
        -- Stop any existing shake first
        if self.holderFrame.shakeStartTime then
            self.holderFrame.shakeStartTime = nil
            if self.holderFrame.shakeOriginalPoint then
                self.holderFrame:ClearAllPoints()
                self.holderFrame:SetPoint(unpack(self.holderFrame.shakeOriginalPoint))
                self.holderFrame.shakeOriginalPoint = nil
            end
        end
        
        local duration = 0.45
        local deltaX = 14
        local deltaY = 6
        local startTime = GetTime()
        
        local point, relativeTo, relativePoint, x, y = self.holderFrame:GetPoint()
        self.holderFrame.shakeOriginalPoint = {point, relativeTo, relativePoint, x, y}
        self.holderFrame.shakeStartTime = startTime
        
        local function shakeUpdate()
            if not self.holderFrame or not self.holderFrame.shakeStartTime then 
                return 
            end
            
            local elapsed = GetTime() - self.holderFrame.shakeStartTime
            local progress = elapsed / duration
            
            if progress >= 1 then
                -- Cleanup shake state
                if self.holderFrame.shakeOriginalPoint then
                    self.holderFrame:ClearAllPoints()
                    self.holderFrame:SetPoint(unpack(self.holderFrame.shakeOriginalPoint))
                    self.holderFrame.shakeOriginalPoint = nil
                    self.holderFrame.shakeStartTime = nil
                end
                
                -- Hide holder after shake with smooth fade
                self.holderFrame.hideTimer = C_Timer.NewTimer(0.5, function()
                    if self.holderFrame then
                        -- Create fade out animation if it doesn't exist
                        if not self.holderFrame.interruptFadeOutAnim then
                            self.holderFrame.interruptFadeOutAnim = self.holderFrame:CreateAnimationGroup()
                            local fadeOut = self.holderFrame.interruptFadeOutAnim:CreateAnimation("Alpha")
                            fadeOut:SetDuration(0.4)
                            fadeOut:SetFromAlpha(1)
                            fadeOut:SetToAlpha(0)
                            fadeOut:SetSmoothing("OUT")
                            
                            self.holderFrame.interruptFadeOutAnim:SetScript("OnFinished", function()
                                self.holderFrame:Hide()
                                self.holderFrame:SetAlpha(1)
                            end)
                        end
                        
                        self.holderFrame.interruptFadeOutAnim:Play()
                    end
                end)
                return
            end
            
            local easedProgress = progress * (2 - progress)
            local angle = (easedProgress + 0.25) * 2 * math.pi
            local offsetX = math.cos(angle) * deltaX * math.cos(angle * 2) * (1 - easedProgress)
            local offsetY = math.abs(math.cos(angle)) * deltaY * math.sin(angle * 2) * (1 - easedProgress)
            
            self.holderFrame:ClearAllPoints()
            local origPoint = self.holderFrame.shakeOriginalPoint
            self.holderFrame:SetPoint(origPoint[1], origPoint[2], origPoint[3], origPoint[4] + offsetX, origPoint[5] + offsetY)
            
            C_Timer.After(0.016, shakeUpdate)
        end
        
        shakeUpdate()
    end
    
    -- Interrupt glow for holder frame
    function castBar:PlayHolderInterruptGlow()
        if not self.holderFrame or not self.holderFrame.interruptGlow then return end
        
        if not self.holderFrame.interruptGlowAnim then
            self.holderFrame.interruptGlowAnim = self.holderFrame.interruptGlow:CreateAnimationGroup()
            
            local fadeIn = self.holderFrame.interruptGlowAnim:CreateAnimation("Alpha")
            fadeIn:SetOrder(1)
            fadeIn:SetDuration(0.2)
            fadeIn:SetFromAlpha(0)
            fadeIn:SetToAlpha(1)
            
            local fadeOut = self.holderFrame.interruptGlowAnim:CreateAnimation("Alpha")
            fadeOut:SetOrder(2)
            fadeOut:SetDuration(1.4)
            fadeOut:SetFromAlpha(1)
            fadeOut:SetToAlpha(0)
            fadeOut:SetSmoothing("OUT")
            
            self.holderFrame.interruptGlowAnim:SetScript("OnFinished", function()
                self.holderFrame.interruptGlow:Hide()
            end)
        end
        
        self.holderFrame.interruptGlow:Show()
        self.holderFrame.interruptGlow:SetAlpha(0)
        self.holderFrame.interruptGlowAnim:Play()
    end
    
    -- Handle interrupt
    function castBar:Interrupt()
        self:ShowInterruptAnimation()
    end
    
    -- Update spark position
    function castBar:UpdateSpark()
        if not self.spark:IsShown() then return end
        
        local progress = self:GetValue()
        local width = self:GetWidth()
        local sparkPos = width * progress
        
        self.spark:ClearAllPoints()
        self.spark:SetPoint("CENTER", self, "LEFT", sparkPos, 0)
    end
    
    -- Update spark position for holders
    function castBar:UpdateHolderSpark(holder, progress)
        if not holder or not holder.spark then return end
        
        local width = holder:GetWidth()
        local sparkPos = width * progress
        
        holder.spark:ClearAllPoints()
        holder.spark:SetPoint("CENTER", holder, "LEFT", sparkPos, 0)
        holder.spark:Show()
    end
    
    -- Target/focus change handling
    local function OnTargetFocusChange(self, event)
        if (event == "PLAYER_TARGET_CHANGED" and self.unit == "target") or
           (event == "PLAYER_FOCUS_CHANGED" and self.unit == "focus") then
            
            module.StopHolderAnimations(self)
            
            -- Clear all casting states
            self.isChanneling = false
            self.isCasting = false
            self.castStartTime = 0
            self.castEndTime = 0
            self.castID = nil
            self.spark:Hide()
            self:Hide()
            
            -- Only check new target/focus if one exists
            if UnitExists(self.unit) then
                local castingInfo = UnitCastingInfo(self.unit)
                local channelInfo = UnitChannelInfo(self.unit)
                
                if castingInfo then
                    local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible = castingInfo
                    if name then
                        self.isInterruptible = not notInterruptible
                        -- Debug logging
                        if MilaUI.DebugMode then
                            print(string.format("[Castbar] Target changed mid-cast: %s, notInterruptible=%s, isInterruptible=%s", 
                                name, tostring(notInterruptible), tostring(not notInterruptible)))
                        end
                        self:StartCast(name, texture, startTimeMS, endTimeMS, not notInterruptible, castID)
                    end
                elseif channelInfo then
                    local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = channelInfo
                    if name then
                        self.isInterruptible = not notInterruptible
                        self:SetupChannel(name, texture, startTimeMS, endTimeMS, not notInterruptible)
                    end
                end
            end
        end
    end
    
    -- EVENT HANDLING
    local function OnEvent(self, event, unitID, ...)
        -- Handle target/focus changes (these are global events without unitID)
        if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
            OnTargetFocusChange(self, event)
            return
        end
        
        -- Unit-specific events are already filtered by RegisterUnitEvent
        
        if event == "UNIT_SPELLCAST_START" then
            local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitID)
            if name then
                self:StartCast(name, texture, startTimeMS, endTimeMS, not notInterruptible, castID)
            end
            
        elseif event == "UNIT_SPELLCAST_STOP" then
            if self:IsShown() and self.isCasting and not self.isChanneling then
                self:ShowCompletionFlash()
            else
                self:StopCast()
            end
            
        elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            if self:IsShown() and self.isCasting and self.isChanneling then
                self:ShowCompletionFlash()
            else
                self:StopCast()
            end
            
elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
            if self.isCasting and not self.isChanneling and self:IsShown() then
                self:Interrupt()
            end
            
        elseif event == "UNIT_SPELLCAST_FAILED" then
            -- UNIT_SPELLCAST_FAILED often fires when player tries to cast while already casting
            -- Only stop if we're not currently in a valid casting state
            if not (self.isCasting and self:IsShown()) then
                self:StopCast()
            end
            -- Otherwise ignore it - we're still casting the original spell
            
        elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
            local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = UnitChannelInfo(unitID)
            if name then
                self.isInterruptible = not notInterruptible
                self:SetupChannel(name, texture, startTimeMS, endTimeMS, not notInterruptible)
            end
            
        elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
            self.isInterruptible = false
            if self.isChanneling then
                self:UpdateAppearance("channel", false)
            else
                self:UpdateAppearance("cast", false)
            end
            
        elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
            self.isInterruptible = true
            if self.isChanneling then
                self:UpdateAppearance("channel", true)
            else
                self:UpdateAppearance("cast", true)
            end
        end
    end
    
    -- UPDATE LOOP - Handles progress calculation and display only
    local function OnUpdate(self, elapsed)
        -- Validate state before calculations
        if not self.castStartTime or not self.castEndTime or 
           self.castStartTime == 0 or self.castEndTime == 0 then 
            return 
        end
        
        local currentTime = GetTime() * 1000
        local totalTime = self.castEndTime - self.castStartTime
        
        -- Safety check for invalid times
        if totalTime <= 0 then
            self:StopCast()
            return
        end
        
        -- Calculate progress
        local progress
        if self.isChanneling then
            -- Channeling goes from 1 to 0
            progress = (self.castEndTime - currentTime) / totalTime
        else
            -- Casting goes from 0 to 1
            progress = (currentTime - self.castStartTime) / totalTime
        end
        
        -- Update visual elements
        progress = math.max(0, math.min(1, progress))
        self:SetValue(progress)
        self:UpdateSpark()
        
        -- Update timer display
        if self.timer then
            local remaining = (self.castEndTime - currentTime) / 1000
            if remaining > 0 then
                self.timer:SetFormattedText("%.1f", remaining)
            else
                self.timer:SetText("")
            end
        end
        
        -- Completion detection (fallback for when events don't fire)
        if (not self.isChanneling and progress >= 0.99) or 
           (self.isChanneling and progress <= 0.01) then
            self:ShowCompletionFlash()
            return -- Stop updating
        end
    end
    
    -- REGISTER EVENTS - Use unit-specific events for better performance
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)
    
    -- Global events for unit changes (can't be unit-specific)
    if unit == "target" then
        castBar:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit == "focus" then
        castBar:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end
    
    castBar:SetScript("OnEvent", OnEvent)
    castBar:SetScript("OnUpdate", OnUpdate)
    
    -- Check for existing casts on creation (handles both cast and channel)
    local castingInfo = UnitCastingInfo(unit)
    local channelInfo = UnitChannelInfo(unit)
    
    if castingInfo then
        local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible = castingInfo
        if name then
            castBar:StartCast(name, texture, startTimeMS, endTimeMS, not notInterruptible, castID)
        end
    elseif channelInfo then
        local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = channelInfo
        if name then
            castBar.isInterruptible = not notInterruptible
            castBar:SetupChannel(name, texture, startTimeMS, endTimeMS, not notInterruptible)
        end
    end
    
    -- Apply colors to all holder frames after creation
    if options.colors then
        local interruptColor = options.colors.interrupt or {1, 0.2, 0.2, 1}
        local completionColor = options.colors.completion or {0.2, 1.0, 1.0, 1.0}
        local channelColor = options.colors.channel or {1.0, 0.4, 1.0, 1.0}
        local uninterruptibleColor = options.colors.uninterruptible or {0.8, 0.8, 0.8, 1.0}
        
        if castBar.holderFrame then
            castBar.holderFrame:SetStatusBarColor(unpack(interruptColor))
        end
        if castBar.castCompletionHolder then
            castBar.castCompletionHolder:SetStatusBarColor(unpack(completionColor))
        end
        if castBar.channelCompletionHolder then
            castBar.channelCompletionHolder:SetStatusBarColor(unpack(channelColor))
        end
        if castBar.uninterruptibleHolder then
            castBar.uninterruptibleHolder:SetStatusBarColor(unpack(uninterruptibleColor))
        end
    end
    
    return castBar
end

-- Disable Blizzard cast bars
function module.DisableDefaultCastBars()
    if PlayerCastingBarFrame then
        PlayerCastingBarFrame:Hide()
        PlayerCastingBarFrame:SetScript("OnShow", function(self) self:Hide() end)
    end
    
    if TargetFrameSpellBar then
        TargetFrameSpellBar:Hide()
        TargetFrameSpellBar:SetScript("OnShow", function(self) self:Hide() end)
    end
    
    if FocusFrameSpellBar then
        FocusFrameSpellBar:Hide()
        FocusFrameSpellBar:SetScript("OnShow", function(self) self:Hide() end)
    end
end

-- Initialize system
function module.InitializeCleanCastBarSystem()
    C_Timer.After(0.5, function()
        module.DisableDefaultCastBars()
    end)
end

-- Cast Bar Update Functions
-- Add these at the end of your cast bar file

-- Update cast bar dimensions
function module.UpdateCastBarDimensions(unit)
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings then return end
    
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    local width = (settings.size and settings.size.width) or 125
    local height = (settings.size and settings.size.height) or 18
    
    castBar:SetSize(width, height)
    
    -- Update all holder frames
    local holders = {
        castBar.holderFrame,
        castBar.castCompletionHolder,
        castBar.channelCompletionHolder,
        castBar.uninterruptibleHolder
    }
    
    for _, holder in pairs(holders) do
        if holder then
            holder:SetSize(width, height)
        end
    end
end

-- Update cast bar scale
function module.UpdateCastBarScale(unit)
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings then return end
    
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    local scale = (settings.size and settings.size.scale) or 1.0
    
    castBar:SetScale(scale)
    
    -- Update all holder frames
    local holders = {
        castBar.holderFrame,
        castBar.castCompletionHolder,
        castBar.channelCompletionHolder,
        castBar.uninterruptibleHolder
    }
    
    for _, holder in pairs(holders) do
        if holder then
            holder:SetScale(scale)
        end
    end
end

-- Update cast bar position
function module.UpdateCastBarPosition(unit)
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings then return end
    
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    local anchorPoint = (settings.position and settings.position.anchorPoint) or "CENTER"
    local anchorTo = (settings.position and settings.position.anchorTo) or "CENTER"
    local xOffset = (settings.position and settings.position.xOffset) or 0
    local yOffset = (settings.position and settings.position.yOffset) or -20
    
    -- Get parent frame (health bar)
    local parent = castBar:GetParent()
    if not parent then return end
    
    castBar:ClearAllPoints()
    castBar:SetPoint(anchorPoint, parent, anchorTo, xOffset, yOffset)
    
    -- Update all holder frames
    local holders = {
        castBar.holderFrame,
        castBar.castCompletionHolder,
        castBar.channelCompletionHolder,
        castBar.uninterruptibleHolder
    }
    
    for _, holder in pairs(holders) do
        if holder then
            holder:ClearAllPoints()
            holder:SetPoint(anchorPoint, parent, anchorTo, xOffset, yOffset)
        end
    end
end

-- Update cast bar display options (icon, text, timer)
function module.UpdateCastBarDisplay(unit)
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings then return end
    
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    -- Get display sub-sections
    local icon = settings.display and settings.display.icon or {}
    local text = settings.display and settings.display.text or {}
    local timer = settings.display and settings.display.timer or {}
    
    local showIcon = icon.show ~= false
    local showText = text.show ~= false
    local showTimer = timer.show ~= false
    
    -- Update main cast bar elements
    if castBar.icon then
        if showIcon then
            castBar.icon:Show()
        else
            castBar.icon:Hide()
        end
    end
    
    if castBar.text then
        if showText then
            castBar.text:Show()
        else
            castBar.text:Hide()
        end
    end
    
    if castBar.timer then
        if showTimer then
            castBar.timer:Show()
        else
            castBar.timer:Hide()
        end
    end
    
    -- Update all holder frames
    local holders = {
        castBar.holderFrame,
        castBar.castCompletionHolder,
        castBar.channelCompletionHolder,
        castBar.uninterruptibleHolder
    }
    
    for _, holder in pairs(holders) do
        if holder then
            if holder.icon then
                if showIcon then
                    holder.icon:Show()
                else
                    holder.icon:Hide()
                end
            end
            
            if holder.text then
                if showText then
                    holder.text:Show()
                else
                    holder.text:Hide()
                end
            end
        end
    end
end

-- Update cast bar colors (applies to individual holders and main bar)
function module.UpdateCastBarColors(unit)
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings then return end
    
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    local castColor = (settings.colors and settings.colors.cast) or {0, 1, 1, 1}
    local completionColor = (settings.colors and settings.colors.completion) or {0.2, 1.0, 1.0, 1.0}
    local channelColor = (settings.colors and settings.colors.channel) or {1.0, 0.4, 1.0, 1.0}
    local uninterruptibleColor = (settings.colors and settings.colors.uninterruptible) or {0.8, 0.8, 0.8, 1.0}
    local interruptColor = (settings.colors and settings.colors.interrupt) or {1, 0.2, 0.2, 1}
    
    -- Update individual holder frame colors
    if castBar.holderFrame then
        -- Interrupt holder gets interrupt color
        castBar.holderFrame:SetStatusBarColor(unpack(interruptColor))
    end
    
    if castBar.castCompletionHolder then
        -- Cast completion holder gets its own color
        castBar.castCompletionHolder:SetStatusBarColor(unpack(completionColor))
    end
    
    if castBar.channelCompletionHolder then
        -- Channel completion holder gets its own color
        castBar.channelCompletionHolder:SetStatusBarColor(unpack(channelColor))
    end
    
    if castBar.uninterruptibleHolder then
        -- Uninterruptible holder gets its own color
        castBar.uninterruptibleHolder:SetStatusBarColor(unpack(uninterruptibleColor))
    end
    
    -- Store color config in castbar for UpdateAppearance to use (using GUI color names)
    if castBar then
        castBar.colorConfig = {
            cast = castColor,
            completion = completionColor,
            channel = channelColor,
            uninterruptible = uninterruptibleColor,
            interrupt = interruptColor
        }
        
        -- If currently casting/channeling, update the appearance immediately
        if castBar.isCasting then
            local castType = castBar.isChanneling and "channel" or "cast"
            castBar:UpdateAppearance(castType, castBar.isInterruptible)
        end
    end
    
    -- Also update flash colors when colors change
    module.UpdateCastBarFlashColors(unit)
end

-- Update cast bar visibility
function module.UpdateCastBarVisibility(unit)
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings then return end
    
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    local enabled = settings.enabled ~= false
    
    if enabled then
        -- Don't force show, let the cast bar show when there's actual casting
        castBar:SetScript("OnEvent", castBar:GetScript("OnEvent"))
        castBar:SetScript("OnUpdate", castBar:GetScript("OnUpdate"))
    else
        -- Hide and disable
        castBar:Hide()
        module.StopHolderAnimations(castBar)
        castBar:SetScript("OnEvent", nil)
        castBar:SetScript("OnUpdate", nil)
    end
end

-- Update cast bar textures
function module.UpdateCastBarTextures(unit)
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings then return end
    
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    -- Update main texture
    if settings.textures and settings.textures.main then
        local mainTexture = GetTexture("statusbar", settings.textures.main, "Interface\\Buttons\\WHITE8X8")
        castBar:SetStatusBarTexture(mainTexture)
    end
    
    -- Store textures in options for UpdateAppearance to use
    castBar.options.textures = settings.textures
    
    -- If currently casting/channeling, update the appearance
    if castBar.isCasting then
        local castType = castBar.isChanneling and "channel" or "cast"
        castBar:UpdateAppearance(castType, castBar.isInterruptible)
    end
end

-- Update cast bar flash colors
function module.UpdateCastBarFlashColors(unit)
    local castBar = module:GetCastBarForUnit(unit)
    if not castBar then return end
    
    local settings = ns.DB and ns.DB.profile and ns.DB.profile.castBars and ns.DB.profile.castBars[unit]
    if not settings or not settings.flashColors then return end
    
    -- Update all holder frames' flash colors
    local holders = {
        {holder = castBar.holderFrame, type = "interrupt"},
        {holder = castBar.castCompletionHolder, type = "cast"},
        {holder = castBar.channelCompletionHolder, type = "channel"},
        {holder = castBar.uninterruptibleHolder, type = "uninterruptible"}
    }
    
    for _, holderData in pairs(holders) do
        local holder = holderData.holder
        local flashColor = settings.flashColors[holderData.type]
        
        if holder and holder.completionFlash and flashColor then
            holder.completionFlash:SetVertexColor(unpack(flashColor))
        end
        
        if holder and holder.interruptGlow and flashColor then
            holder.interruptGlow:SetVertexColor(unpack(flashColor))
        end
    end
end

-- Apply all cast bar settings for a unit
function module.UpdateCastBarSettings(unit)
    module.UpdateCastBarDimensions(unit)
    module.UpdateCastBarScale(unit)
    module.UpdateCastBarPosition(unit)
    module.UpdateCastBarDisplay(unit)
    module.UpdateCastBarColors(unit)
    module.UpdateCastBarFlashColors(unit)
    module.UpdateCastBarTextures(unit)
    module.UpdateCastBarVisibility(unit)
end

-- Helper function to get cast bar for a unit
function module:GetCastBarForUnit(unit)
    if unit == "player" then
        return self.playerCastBar
    elseif unit == "target" then
        return self.targetCastBar
    elseif unit == "focus" then
        return self.focusCastBar
    end
    return nil
end