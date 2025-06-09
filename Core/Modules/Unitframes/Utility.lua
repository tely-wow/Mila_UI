local _, MilaUI = ...
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local oUF = MilaUI.oUF
MilaUI.TargetHighlightEvtFrames = {}
MilaUI.Frames = {
    ["player"] = "Player",
    ["target"] = "Target",
    ["focus"] = "Focus",
    ["focustarget"] = "FocusTarget",
    ["pet"] = "Pet",
    ["targettarget"] = "TargetTarget",
}

MilaUI.nameBlacklist = {
    ["the"] = true,
    ["of"] = true,
    ["Tentacle"] = true,
    ["Apprentice"] = true,
    ["Denizen"] = true,
    ["Emissary"] = true,
    ["Howlis"] = true,
    ["Terror"] = true,
    ["Totem"] = true,
    ["Waycrest"] = true,
    ["Aspect"] = true
}

-- This can be called globally by other AddOns that require a refresh of all tags.
function MilaUI:UpdateAllTags()
    for FrameName, Frame in pairs(_G) do
        if FrameName:match("^MilaUI_") and Frame.UpdateTags then
            Frame:UpdateTags()
        end
    end
end

local function PostCreateButton(_, button, Unit, AuraType)
    local General = MilaUI.DB.profile.Unitframes.General
    local BuffCount = MilaUI.DB.profile.Unitframes[Unit].Buffs.Count
    local DebuffCount = MilaUI.DB.profile.Unitframes[Unit].Debuffs.Count
    -- Icon Options
    local auraIcon = button.Icon
    auraIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Border Options
    local buttonBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
    buttonBorder:SetAllPoints()
    buttonBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
    buttonBorder:SetBackdropBorderColor(0, 0, 0, 1)

    -- Cooldown Options
    local auraCooldown = button.Cooldown
    if auraCooldown then
        auraCooldown:SetDrawEdge(false)
        auraCooldown:SetReverse(true)
    end

    -- Count Options
    local auraCount = button.Count
    local fontPath = LSM:Fetch("font", General.Font)
    if AuraType == "HELPFUL" then
        auraCount:ClearAllPoints()
        auraCount:SetPoint(BuffCount.AnchorFrom, button, BuffCount.AnchorTo, BuffCount.XOffset, BuffCount.YOffset)
        auraCount:SetFont(fontPath, BuffCount.FontSize, "OUTLINE")
        auraCount:SetJustifyH("CENTER")
        auraCount:SetTextColor(BuffCount.Colour[1], BuffCount.Colour[2], BuffCount.Colour[3], BuffCount.Colour[4])
    elseif AuraType == "HARMFUL" then
        auraCount:ClearAllPoints()
        auraCount:SetPoint(DebuffCount.AnchorFrom, button, DebuffCount.AnchorTo, DebuffCount.XOffset, DebuffCount.YOffset)
        auraCount:SetFont(fontPath, DebuffCount.FontSize, "OUTLINE")
        auraCount:SetJustifyH("CENTER")
        auraCount:SetTextColor(DebuffCount.Colour[1], DebuffCount.Colour[2], DebuffCount.Colour[3], DebuffCount.Colour[4])
    end
end

local function PostUpdateButton(_, button, Unit, AuraType)
    local General = MilaUI.DB.profile.Unitframes.General
    local BuffCount = MilaUI.DB.profile.Unitframes[Unit].Buffs.Count
    local DebuffCount = MilaUI.DB.profile.Unitframes[Unit].Debuffs.Count

    local auraCount = button.Count
    if AuraType == "HELPFUL" then
        auraCount:ClearAllPoints()
        auraCount:SetPoint(BuffCount.AnchorFrom, button, BuffCount.AnchorTo, BuffCount.XOffset, BuffCount.YOffset)
        auraCount:SetFont(General.Font, BuffCount.FontSize, "OUTLINE")
        auraCount:SetJustifyH("CENTER")
        auraCount:SetTextColor(BuffCount.Colour[1], BuffCount.Colour[2], BuffCount.Colour[3], BuffCount.Colour[4])
    elseif AuraType == "HARMFUL" then
        auraCount:ClearAllPoints()
        auraCount:SetPoint(DebuffCount.AnchorFrom, button, DebuffCount.AnchorTo, DebuffCount.XOffset, DebuffCount.YOffset)
        auraCount:SetFont(General.Font, DebuffCount.FontSize, "OUTLINE")
        auraCount:SetJustifyH("CENTER")
        auraCount:SetTextColor(DebuffCount.Colour[1], DebuffCount.Colour[2], DebuffCount.Colour[3], DebuffCount.Colour[4])
    end
end

local function ColourBackgroundByUnitStatus(self)
    local General = MilaUI.DB.profile.Unitframes.General
    local CustomColour = General.CustomColours
    local unit = self.unit
    local bar = self.Health
    if not unit or not bar or not bar.bg or not UnitExists(unit) then return end

    local bg = bar.bg

    if UnitIsDead(unit) then
        if General.ColourBackgroundIfDead then
            -- Use custom dead color
            local r, g, b = unpack(CustomColour.Status[1])
            bg:SetVertexColor(r, g, b, General.BackgroundColour[4])
        elseif General.ColourBackgroundByReaction then
            -- Use fallback multiplier on foreground
            local a = General.BackgroundMultiplier
            local fr, fg, fb = bar:GetStatusBarColor()
            bg:SetVertexColor(fr * a, fg * a, fb * a, General.BackgroundColour[4])
        else
            -- Static fallback color
            bg:SetVertexColor(unpack(General.BackgroundColour))
        end
    else
        if General.ColourBackgroundByForeground then
            local a = General.BackgroundMultiplier
            local r, g, b = bar:GetStatusBarColor()
            bg:SetVertexColor(r * a, g * a, b * a, General.BackgroundColour[4])
        elseif General.ColourBackgroundByClass then
            local r, g, b
            if UnitIsPlayer(unit) then
                local class = select(2, UnitClass(unit))
                local color = RAID_CLASS_COLORS[class]
                if color then r, g, b = color.r, color.g, color.b end
            else
                local reaction = UnitReaction(unit, "player")
                if reaction and oUF.colors.reaction[reaction] then
                    r, g, b = unpack(oUF.colors.reaction[reaction])
                end
            end

            if r and g and b then
                bg:SetVertexColor(r, g, b, General.BackgroundColour[4])
            else
                bg:SetVertexColor(unpack(General.BackgroundColour))
            end
        else
            -- Default static color
            bg:SetVertexColor(unpack(General.BackgroundColour))
        end
    end
end


function MilaUI:FormatLargeNumber(value)
    if value < 999 then
        return value
    elseif value < 999999 then
        return string.format("%.1fk", value / 1000)
    elseif value < 99999999 then
        return string.format("%.2fm", value / 1000000)
    elseif value < 999999999 then
        return string.format("%.1fm", value / 1000000)
    elseif value < 99999999999 then
        return string.format("%.2fb", value / 1000000000)
    end
    return string.format("%db", value / 1000000000)
end

function MilaUI:WrapTextInColor(unitName, unit)
    if not unitName then return "" end
    if not unit then return unitName end
    local unitColor
    if UnitIsPlayer(unit) then
        local unitClass = select(2, UnitClass(unit))
        unitColor = RAID_CLASS_COLORS[unitClass]
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local r, g, b = unpack(oUF.colors.reaction[reaction])
            unitColor = { r = r, g = g, b = b }
        end
    end
    if unitColor then
        return string.format("|cff%02x%02x%02x%s|r", unitColor.r * 255, unitColor.g * 255, unitColor.b * 255, unitName)
    end
    return unitName
end

function MilaUI:ShortenName(name, nameBlacklist)
    if not name or name == "" then return nil end
    local words = { strsplit(" ", name) }
    return nameBlacklist[words[2]] and words[1] or words[#words] or name
end

function MilaUI:AbbreviateName(unitName)
    local unitNameParts = {}
    for word in unitName:gmatch("%S+") do
        table.insert(unitNameParts, word)
    end

    local last = table.remove(unitNameParts)
    for i, word in ipairs(unitNameParts) do
        unitNameParts[i] = (string.utf8sub or string.sub)(word, 1, 1) .. "."
    end

    table.insert(unitNameParts, last)
    return table.concat(unitNameParts, " ")
end

function MilaUI:ResetDefaultSettings()
    MilaUI.DB:ResetProfile()
    MilaUI:CreateReloadPrompt()
end

local function CreateHealthBar(self, Unit)
    local General = MilaUI.DB.profile.Unitframes.General
    local Frame = MilaUI.DB.profile.Unitframes[Unit].Frame
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    local BackdropTemplate = {
        bgFile = Health.BackgroundTexture,
        edgeFile = General.BorderTexture,
        edgeSize = General.BorderSize,
        insets = {
            left = General.BorderInset,
            right = General.BorderInset,
            top = General.BorderInset,
            bottom = General.BorderInset
        },
    }

    -- Optional border
    if not self.unitBorder and not Health.CustomBorder.Enabled then
        self.unitBorder = CreateFrame("Frame", nil, self, "BackdropTemplate")
        self.unitBorder:SetAllPoints()
        self.unitBorder:SetBackdrop(BackdropTemplate)
        self.unitBorder:SetBackdropColor(0, 0, 0, 0)
        self.unitBorder:SetBackdropBorderColor(unpack(General.BorderColour))
        self.unitBorder:SetFrameLevel(1)
    end

    -- Health bar
    if not self.unitHealthBar then
        local health = CreateFrame("StatusBar", nil, self)
        health:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        health:SetSize(Health.Width - 2, Health.Height - 2)
        health:SetStatusBarTexture(LSM:Fetch("statusbar", Health.Texture))
        local tex = health:GetStatusBarTexture()
        tex:SetTexCoord(0, 1, 0, 1)
        if Health.CustomMask.Enabled then
            tex:SetMask(Health.CustomMask.MaskTexture)
        end

        -- oUF background (health.bg)
        local bg = health:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(LSM:Fetch("statusbar", Health.BackgroundTexture))
        bg:SetTexCoord(0, 1, 0, 1)
        if Health.CustomMask.Enabled then
            bg:SetMask(Health.CustomMask.MaskTexture)
        end
        bg:SetVertexColor(unpack(General.BackgroundColour))
        bg:Show()

        health.bg = bg

        -- Color logic
        health.colorClass        = General.ColourByClass
        health.colorReaction     = General.ColourByClass
        health.colorDisconnected = General.ColourIfDisconnected
        health.colorTapping      = General.ColourIfTapped
        health.colorHealth       = true

        if Unit == "Pet" then
            local ColourByPlayerClass = MilaUI.DB.profile.Unitframes.Pet.Health.ColourByPlayerClass
            if ColourByPlayerClass then
                health.colorClass = false
                health.colorReaction = false
                health.colorHealth = false
                local unitClass = select(2, UnitClass("player"))
                local unitColor = RAID_CLASS_COLORS[unitClass]
                if unitColor then
                    health:SetStatusBarColor(unitColor.r, unitColor.g, unitColor.b, General.ForegroundColour[4])
                end
            end
        end

        health:SetMinMaxValues(0, 100)
        health:SetAlpha(General.ForegroundColour[4])
        health.PostUpdateColor = function(bar, unit, r, g, b)
            local parent = bar.__owner or bar:GetParent()
            if parent and parent.ColourBackgroundByUnitStatus then
                parent:ColourBackgroundByUnitStatus()
            elseif ColourBackgroundByUnitStatus then
                ColourBackgroundByUnitStatus(parent or bar)
            end
            -- NPC: Custom color via Plater
            if MilaUI.DB.profile.Unitframes.General.ColourByPlaterNameplates then
                if not UnitIsPlayer(unit) then
                    local guid = UnitGUID(unit)
                    if guid then
                        local mobID = MilaUI:ExtractMobID(guid)
                        if mobID then
                            local color = MilaUI:GetColorForMobID(mobID)
                            if color then
                                bar:SetStatusBarColor(color.r, color.g, color.b)
                            end
                        end
                    end
                end
            end
        end
        if Health.Direction == "RL" then
            health:SetReverseFill(true)
        elseif Health.Direction == "LR" then
            health:SetReverseFill(false)
        end
        health:SetFrameLevel(2)

        self.unitHealthBar = health
        self.Health = health
    end
end


local function CreateAbsorbBar(self, Unit)
    local General = MilaUI.DB.profile.Unitframes.General
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    local HealthPrediction = MilaUI.DB.profile.Unitframes[Unit].Health.HealthPrediction
    local Absorbs = HealthPrediction.Absorbs

    if Absorbs.Enabled and not self.unitAbsorbs then
        self.unitAbsorbs = CreateFrame("StatusBar", nil, self.unitHealthBar)
        local absorbsTexturePath = LSM:Fetch("statusbar", General.AbsorbTexture)
        self.unitAbsorbs:SetStatusBarTexture(absorbsTexturePath)
        self.unitAbsorbs:SetStatusBarColor(0.6, 0.8, 1, 1)
        local HealthBarTexture = self.unitHealthBar:GetStatusBarTexture()
        if HealthBarTexture then
            self.unitAbsorbs:ClearAllPoints()
            if Health.Direction == "RL" then
                self.unitAbsorbs:SetReverseFill(true)
                self.unitAbsorbs:SetPoint("TOPRIGHT", HealthBarTexture, "TOPLEFT", 0, 0)
                self.unitAbsorbs:SetPoint("BOTTOMRIGHT", HealthBarTexture, "BOTTOMLEFT", 0, 0)
            elseif Health.Direction == "LR" then
                self.unitAbsorbs:SetReverseFill(false)
                self.unitAbsorbs:SetPoint("TOPLEFT", HealthBarTexture, "TOPRIGHT", 0, 0)
                self.unitAbsorbs:SetPoint("BOTTOMLEFT", HealthBarTexture, "BOTTOMRIGHT", 0, 0)
            end
        end
        self.unitAbsorbs:SetSize(self:GetWidth() - 2, self:GetHeight() - 2)
        local UAR, UAG, UAB, UAA = unpack(Absorbs.Colour)
        self.unitAbsorbs:SetStatusBarColor(UAR, UAG, UAB, UAA)
        self.unitAbsorbs:SetFrameLevel(self.unitHealthBar:GetFrameLevel() + 1)
        self.unitAbsorbs:Hide()
    end
end

local function CreateHealAbsorbBar(self, Unit)
    local General = MilaUI.DB.profile.Unitframes.General
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    local HealthPrediction = MilaUI.DB.profile.Unitframes[Unit].Health.HealthPrediction
    local HealAbsorbs = HealthPrediction.HealAbsorbs
    
    if HealAbsorbs.Enabled and not self.unitHealAbsorbs then
        self.unitHealAbsorbs = CreateFrame("StatusBar", nil, self.unitHealthBar)
        local healAbsorbsTexturePath = LSM:Fetch("statusbar", General.AbsorbTexture)
        self.unitHealAbsorbs:SetStatusBarTexture(healAbsorbsTexturePath)
        local HealthBarTexture = self.unitHealthBar:GetStatusBarTexture()
        if HealthBarTexture then
            self.unitHealAbsorbs:ClearAllPoints()
            if Health.Direction == "RL" then
                self.unitHealAbsorbs:SetReverseFill(false)
                self.unitHealAbsorbs:SetPoint("TOPLEFT", HealthBarTexture, "TOPLEFT", 0, 0)
                self.unitHealAbsorbs:SetPoint("BOTTOMRIGHT", HealthBarTexture, "BOTTOMRIGHT", 0, 0)
            else
                self.unitHealAbsorbs:SetReverseFill(true)
                self.unitHealAbsorbs:SetPoint("TOPRIGHT", HealthBarTexture, "TOPRIGHT", 0, 0)
                self.unitHealAbsorbs:SetPoint("BOTTOMLEFT", HealthBarTexture, "BOTTOMLEFT", 0, 0)
            end
        end
        self.unitHealAbsorbs:SetSize(self:GetWidth() - 2, self:GetHeight() - 2)
        local UHAR, UHAG, UHAB, UHAA = unpack(HealAbsorbs.Colour)
        self.unitHealAbsorbs:SetStatusBarColor(UHAR, UHAG, UHAB, UHAA)
        self.unitHealAbsorbs:SetFrameLevel(self.unitHealthBar:GetFrameLevel() + 1)
        self.unitHealAbsorbs:Hide()
    end
end

local function CreatePowerBar(self, Unit)
    local General = MilaUI.DB.profile.Unitframes.General
    local PowerBar = MilaUI.DB.profile.Unitframes[Unit].PowerBar
    local r, g, b, a = unpack(MilaUI.DB.profile.Unitframes.General.BackgroundColour)
    local BackdropTemplate = {
        bgFile = General.BackgroundTexture,
        edgeFile = General.BorderTexture,
        edgeSize = General.BorderSize,
        insets = { left = General.BorderInset, right = General.BorderInset, top = General.BorderInset, bottom = General.BorderInset },
    }
    if not PowerBar.Enabled then return end
    
    -- Create the power bar as a standard oUF element
    if not self.unitPowerBar then
        -- Create the power bar
        self.unitPowerBar = CreateFrame("StatusBar", nil, self)
        
        -- Position the power bar using database values
        self.unitPowerBar:ClearAllPoints()
        
        -- Get anchor points from database or use defaults
        local anchorFrom = PowerBar.AnchorFrom or "TOPLEFT"
        local anchorTo = PowerBar.AnchorTo or "BOTTOMLEFT"
        local anchorParent = PowerBar.AnchorParent or "unitHealthBar"
        local xOffset = PowerBar.XPosition or 0
        local yOffset = PowerBar.YPosition or -1
        
        -- Determine the actual anchor parent frame
        local parentFrame
        if anchorParent == "unitHealthBar" or anchorParent == "" then
            parentFrame = self.unitHealthBar
        elseif anchorParent == "UIParent" then
            parentFrame = UIParent
        else
            -- Try to find the frame by name, fallback to health bar if not found
            parentFrame = _G[anchorParent] or self.unitHealthBar
        end
        
        -- Set the position
        self.unitPowerBar:SetPoint(anchorFrom, parentFrame, anchorTo, xOffset, yOffset)
        self.unitPowerBar:SetSize(PowerBar.Width - 2, PowerBar.Height - 2)
        
        -- Set up the power bar appearance
        local powerTexturePath = LSM:Fetch("statusbar", PowerBar.Texture)
        self.unitPowerBar:SetStatusBarTexture(powerTexturePath)
        local tex = self.unitPowerBar:GetStatusBarTexture()
        if PowerBar.CustomMask.Enabled and PowerBar.CustomMask.MaskTexture and not tex.mask then 
            tex:SetMask(PowerBar.CustomMask.MaskTexture) 
        end
        
        -- Configure power bar behavior
        self.unitPowerBar:SetStatusBarColor(unpack(PowerBar.Colour))
        self.unitPowerBar:SetMinMaxValues(0, 100)
        self.unitPowerBar:SetAlpha(PowerBar.Colour[4])
        self.unitPowerBar.colorPower = PowerBar.ColourByType
        self.unitPowerBar.frequentUpdates = PowerBar.Smooth
        
        -- Set fill direction
        if PowerBar.Direction == "RL" then
            self.unitPowerBar:SetReverseFill(true)
        elseif PowerBar.Direction == "LR" then
            self.unitPowerBar:SetReverseFill(false)
        end
        
        -- Register with oUF
        self.Power = self.unitPowerBar
        
        -- Create power bar background
        self.unitPowerBarBackground = self.unitPowerBar:CreateTexture(nil, "BACKGROUND")
        self.unitPowerBarBackground:SetAllPoints()
        local powerBgTexturePath = LSM:Fetch("statusbar", PowerBar.BackgroundTexture)
        self.unitPowerBarBackground:SetTexture(powerBgTexturePath)
        if PowerBar.CustomMask.Enabled and PowerBar.CustomMask.MaskTexture then 
            self.unitPowerBarBackground:SetMask(PowerBar.CustomMask.MaskTexture) 
        end
        self.unitPowerBarBackground:SetAlpha(PowerBar.BackgroundColour[4])
        
        -- Set up background coloring
        if PowerBar.ColourBackgroundByType then 
            self.unitPowerBarBackground.multiplier = PowerBar.BackgroundMultiplier
            self.unitPowerBar.bg = self.unitPowerBarBackground
        else
            self.unitPowerBarBackground:SetVertexColor(r, g, b, a)
            self.unitPowerBar.bg = nil
        end
        
        -- Create power bar border if enabled
        if PowerBar.Border and PowerBar.Border.Enabled and not PowerBar.CustomBorder.Enabled then
            self.unitPowerBarBorder = CreateFrame("Frame", nil, self.unitPowerBar, "BackdropTemplate")
            self.unitPowerBarBorder:SetSize(PowerBar.Width, PowerBar.Height)
            self.unitPowerBarBorder:SetPoint("CENTER", self.unitPowerBar, "CENTER", 0, 0)
            self.unitPowerBarBorder:SetBackdrop(BackdropTemplate)
            self.unitPowerBarBorder:SetBackdropColor(0,0,0,0)
            self.unitPowerBarBorder:SetBackdropBorderColor(r, g, b, a)
            self.unitPowerBarBorder:SetFrameLevel(4)
        end
    end
end

local function CreateBuffs(self, Unit)
    local Buffs = MilaUI.DB.profile.Unitframes[Unit].Buffs
    if Buffs.Enabled and not self.unitBuffs then
        self.unitBuffs = CreateFrame("Frame", nil, self)
        self.unitBuffs:SetSize(self:GetWidth(), Buffs.Size)
        
        -- Determine anchor based on AnchorFrame setting
        local anchorFrame = self
        if Buffs.AnchorFrame then
            if Buffs.AnchorFrame == "HealthBar" and self.unitHealthBar then
                anchorFrame = self.unitHealthBar
            elseif Buffs.AnchorFrame == "PowerBar" and self.unitPowerBar then
                anchorFrame = self.unitPowerBar
            elseif Buffs.AnchorFrame == "Debuffs" and self.unitDebuffs then
                anchorFrame = self.unitDebuffs
            elseif Buffs.AnchorFrame ~= "Buffs" and _G[Buffs.AnchorFrame] then
                -- Try to find a global frame with this name
                anchorFrame = _G[Buffs.AnchorFrame]
            end
        end
        
        self.unitBuffs:SetPoint(Buffs.AnchorFrom, anchorFrame, Buffs.AnchorTo, Buffs.XOffset, Buffs.YOffset)
        self.unitBuffs.size = Buffs.Size
        self.unitBuffs.spacing = Buffs.Spacing
        self.unitBuffs.num = Buffs.Num
        self.unitBuffs.initialAnchor = Buffs.AnchorFrom
        self.unitBuffs.onlyShowPlayer = Buffs.OnlyShowPlayer
        self.unitBuffs["growth-x"] = Buffs.GrowthX
        self.unitBuffs["growth-y"] = Buffs.GrowthY
        self.unitBuffs.filter = "HELPFUL"
        self.unitBuffs.PostCreateButton = function(_, button) PostCreateButton(_, button, "Player", "HELPFUL") end
        self.Buffs = self.unitBuffs
    end
end

local function CreateDebuffs(self, Unit)
    local Debuffs = MilaUI.DB.profile.Unitframes[Unit].Debuffs
    if Debuffs.Enabled and not self.unitDebuffs then
        self.unitDebuffs = CreateFrame("Frame", nil, self)
        self.unitDebuffs:SetSize(self:GetWidth(), Debuffs.Size)
        
        -- Determine anchor based on AnchorFrame setting
        local anchorFrame = self
        if Debuffs.AnchorFrame then
            if Debuffs.AnchorFrame == "HealthBar" and self.unitHealthBar then
                anchorFrame = self.unitHealthBar
            elseif Debuffs.AnchorFrame == "PowerBar" and self.unitPowerBar then
                anchorFrame = self.unitPowerBar
            elseif Debuffs.AnchorFrame == "Buffs" and self.unitBuffs then
                anchorFrame = self.unitBuffs
            elseif Debuffs.AnchorFrame ~= "Debuffs" and _G[Debuffs.AnchorFrame] then
                -- Try to find a global frame with this name
                anchorFrame = _G[Debuffs.AnchorFrame]
            end
        end
        
        self.unitDebuffs:SetPoint(Debuffs.AnchorFrom, anchorFrame, Debuffs.AnchorTo, Debuffs.XOffset, Debuffs.YOffset)
        self.unitDebuffs.size = Debuffs.Size
        self.unitDebuffs.spacing = Debuffs.Spacing
        self.unitDebuffs.num = Debuffs.Num
        self.unitDebuffs.initialAnchor = Debuffs.AnchorFrom
        self.unitDebuffs.onlyShowPlayer = Debuffs.OnlyShowPlayer
        self.unitDebuffs["growth-x"] = Debuffs.GrowthX
        self.unitDebuffs["growth-y"] = Debuffs.GrowthY
        self.unitDebuffs.filter = "HARMFUL"
        self.unitDebuffs.PostCreateButton = function(_, button) PostCreateButton(_, button, "Player", "HARMFUL") end
        self.Debuffs = self.unitDebuffs
    end
end

local function CreatePortrait(self, Unit)
    local General = MilaUI.DB.profile.Unitframes.General
    local Portrait = MilaUI.DB.profile.Unitframes[Unit].Portrait
    local BackdropTemplate = {
        bgFile = General.BackgroundTexture,
        edgeFile = General.BorderTexture,
        edgeSize = General.BorderSize,
        insets = { left = General.BorderInset, right = General.BorderInset, top = General.BorderInset, bottom = General.BorderInset },
    }
    if Portrait.Enabled and not self.unitPortraitBackdrop and not self.unitPortrait then
        self.unitPortraitBackdrop = CreateFrame("Frame", nil, self, "BackdropTemplate")
        self.unitPortraitBackdrop:SetSize(Portrait.Size, Portrait.Size)
        self.unitPortraitBackdrop:SetPoint(Portrait.AnchorFrom, self, Portrait.AnchorTo, Portrait.XOffset, Portrait.YOffset)
        self.unitPortraitBackdrop:SetBackdrop(BackdropTemplate)
        self.unitPortraitBackdrop:SetBackdropColor(unpack(General.BackgroundColour))
        self.unitPortraitBackdrop:SetBackdropBorderColor(unpack(General.BorderColour))
        
        self.unitPortrait = self.unitPortraitBackdrop:CreateTexture(nil, "OVERLAY")
        self.unitPortrait:SetSize(self.unitPortraitBackdrop:GetHeight() - 2, self.unitPortraitBackdrop:GetHeight() - 2)
        self.unitPortrait:SetPoint("CENTER", self.unitPortraitBackdrop, "CENTER", 0, 0)
        self.unitPortrait:SetTexCoord(0.2, 0.8, 0.2, 0.8)
        self.Portrait = self.unitPortrait
    end
end

local function CreateIndicators(self, Unit)
    local TargetIndicator = MilaUI.DB.profile.Unitframes[Unit].TargetIndicator
    local CombatIndicator = MilaUI.DB.profile.Unitframes[Unit].CombatIndicator
    local LeaderIndicator = MilaUI.DB.profile.Unitframes[Unit].LeaderIndicator
    local TargetMarker = MilaUI.DB.profile.Unitframes[Unit].TargetMarker

    if not self.unitIsTargetIndicator and Unit == "Boss" and TargetIndicator and TargetIndicator.Enabled then
        self.unitIsTargetIndicator = CreateFrame("Frame", nil, self, "BackdropTemplate")
        self.unitIsTargetIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        self.unitIsTargetIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
        self.unitIsTargetIndicator:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
        self.unitIsTargetIndicator:SetBackdropColor(0, 0, 0, 0)
        self.unitIsTargetIndicator:SetBackdropBorderColor(1, 1, 1, 1)
        self.unitIsTargetIndicator:SetFrameLevel(self.unitHealthBar:GetFrameLevel() + 10)
        self.unitIsTargetIndicator:Hide()
    end
    -- Frame Target Marker
    if not self.unitTargetMarker and TargetMarker and TargetMarker.Enabled then
        self.unitTargetMarker = self.unitHighLevelFrame:CreateTexture(nil, "OVERLAY")
        self.unitTargetMarker:SetSize(TargetMarker.Size, TargetMarker.Size)
        self.unitTargetMarker:SetPoint(TargetMarker.AnchorFrom, self.unitHighLevelFrame, TargetMarker.AnchorTo, TargetMarker.XOffset, TargetMarker.YOffset)
        self.RaidTargetIndicator = self.unitTargetMarker
    end

    -- Frame Combat Indicator
    if not self.unitCombatIndicator and CombatIndicator and CombatIndicator.Enabled and (Unit == "Player" or Unit == "Target" or Unit == "Focus") then
        self.unitCombatIndicator = self.unitHighLevelFrame:CreateTexture(nil, "OVERLAY")
        self.unitCombatIndicator:SetSize(CombatIndicator.Size, CombatIndicator.Size)
        self.unitCombatIndicator:SetPoint(CombatIndicator.AnchorFrom, self.unitHighLevelFrame, CombatIndicator.AnchorTo, CombatIndicator.XOffset, CombatIndicator.YOffset)
        self.CombatIndicator = self.unitCombatIndicator
    end

    -- Frame Leader Indicator
    if LeaderIndicator and LeaderIndicator.Enabled and not self.unitLeaderIndicator and (Unit == "Player" or Unit == "Target" or Unit == "Focus") then
        self.unitLeaderIndicator = self.unitHighLevelFrame:CreateTexture(nil, "OVERLAY")
        self.unitLeaderIndicator:SetSize(LeaderIndicator.Size, LeaderIndicator.Size)
        self.unitLeaderIndicator:SetPoint(LeaderIndicator.AnchorFrom, self.unitHighLevelFrame, LeaderIndicator.AnchorTo, LeaderIndicator.XOffset, LeaderIndicator.YOffset)
        self.LeaderIndicator = self.unitLeaderIndicator
    end
end

local function CreateTextFields(self, Unit)
    local General = MilaUI.DB.profile.Unitframes.General
    local Frame = MilaUI.DB.profile.Unitframes[Unit].Frame
    local FirstText = MilaUI.DB.profile.Unitframes[Unit].Texts.First
    local SecondText = MilaUI.DB.profile.Unitframes[Unit].Texts.Second
    local ThirdText = MilaUI.DB.profile.Unitframes[Unit].Texts.Third
    if not self.unitHighLevelFrame then 
        self.unitHighLevelFrame = CreateFrame("Frame", nil, self)
        self.unitHighLevelFrame:SetSize(Frame.Width, Frame.Height)
        self.unitHighLevelFrame:SetPoint("CENTER", 0, 0)
        self.unitHighLevelFrame:SetFrameLevel(self.unitHealthBar:GetFrameLevel() + 20)

        -- Fetch font path and flag once
        local fontPath = LSM:Fetch("font", General.Font)
        local fontFlag = General.FontFlag

        if not self.unitFirstText then
            self.unitFirstText = self.unitHighLevelFrame:CreateFontString(nil, "OVERLAY")
            self.unitFirstText:SetFont(fontPath, FirstText.FontSize, fontFlag)
            self.unitFirstText:SetShadowColor(General.FontShadowColour[1], General.FontShadowColour[2], General.FontShadowColour[3], General.FontShadowColour[4])
            self.unitFirstText:SetShadowOffset(General.FontShadowXOffset, General.FontShadowYOffset)
            self.unitFirstText:SetPoint(FirstText.AnchorFrom, self.unitHighLevelFrame, FirstText.AnchorTo, FirstText.XOffset, FirstText.YOffset)
            self.unitFirstText:SetTextColor(FirstText.Colour[1], FirstText.Colour[2], FirstText.Colour[3], FirstText.Colour[4])
            self.unitFirstText:SetJustifyH(MilaUI:GetFontJustification(FirstText.AnchorTo))
            self:Tag(self.unitFirstText, FirstText.Tag)
        end

        if not self.unitSecondText then
            self.unitSecondText = self.unitHighLevelFrame:CreateFontString(nil, "OVERLAY")
            self.unitSecondText:SetFont(fontPath, SecondText.FontSize, fontFlag)
            self.unitSecondText:SetShadowColor(General.FontShadowColour[1], General.FontShadowColour[2], General.FontShadowColour[3], General.FontShadowColour[4])
            self.unitSecondText:SetShadowOffset(General.FontShadowXOffset, General.FontShadowYOffset)
            self.unitSecondText:SetPoint(SecondText.AnchorFrom, self.unitHighLevelFrame, SecondText.AnchorTo, SecondText.XOffset, SecondText.YOffset)
            self.unitSecondText:SetTextColor(SecondText.Colour[1], SecondText.Colour[2], SecondText.Colour[3], SecondText.Colour[4])
            self.unitSecondText:SetJustifyH(MilaUI:GetFontJustification(SecondText.AnchorTo))
            self:Tag(self.unitSecondText, SecondText.Tag)
        end

        if not self.unitThirdText then
            self.unitThirdText = self.unitHighLevelFrame:CreateFontString(nil, "OVERLAY")
            self.unitThirdText:SetFont(fontPath, ThirdText.FontSize, fontFlag)
            self.unitThirdText:SetShadowColor(General.FontShadowColour[1], General.FontShadowColour[2], General.FontShadowColour[3], General.FontShadowColour[4])
            self.unitThirdText:SetShadowOffset(General.FontShadowXOffset, General.FontShadowYOffset)
            self.unitThirdText:SetPoint(ThirdText.AnchorFrom, self.unitHighLevelFrame, ThirdText.AnchorTo, ThirdText.XOffset, ThirdText.YOffset)
            self.unitThirdText:SetTextColor(ThirdText.Colour[1], ThirdText.Colour[2], ThirdText.Colour[3], ThirdText.Colour[4])
            self.unitThirdText:SetJustifyH(MilaUI:GetFontJustification(ThirdText.AnchorTo))
            self:Tag(self.unitThirdText, ThirdText.Tag)
        end
    end
end

local function CreateMouseoverHighlight(self) -- 'self' here is equivalent to 'FrameName'
    local Unit = MilaUI.Frames[self.unit] or "Boss" -- Define Unit based on self.unit
    local MouseoverHighlight = MilaUI.DB.profile.Unitframes.General.MouseoverHighlight
    local CustomBorderSettings = MilaUI.DB.profile.Unitframes[Unit].Health.CustomBorder

    if MouseoverHighlight.Enabled then
        if not self.unitHighlight then
            -- Create the frame if it doesn't exist
            self.unitHighlight = CreateFrame("Frame", nil, self, "BackdropTemplate")
        end

        -- Now, mirror the logic from UpdateMouseoverHighlight, using 'self' instead of 'FrameName'
        local MHR, MHG, MHB, MHA = unpack(MouseoverHighlight.Colour)

        -- Clear previous states of self.unitHighlight (from Update function)
        self.unitHighlight:SetBackdrop(nil)
        if self.unitHighlight.texture then
            self.unitHighlight.texture:SetTexture(nil) -- Clear texture before reconfiguring
            self.unitHighlight.texture:Hide()
        end

        if MouseoverHighlight.Style == "BORDER" then
            if not CustomBorderSettings.Enabled then
                -- Standard border highlight (not custom)
                self.unitHighlight:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
                self.unitHighlight:SetBackdropColor(0, 0, 0, 0)
                self.unitHighlight:SetBackdropBorderColor(MHR, MHG, MHB, MHA)
                self.unitHighlight:SetFrameLevel(20) -- Default high level
                self.unitHighlight:ClearAllPoints()
                self.unitHighlight:SetAllPoints(self.unitHealthBar or self)
            else -- CustomBorderSettings.Enabled is true: Use custom border texture for highlight
                if not self.unitHighlight.texture then
                    self.unitHighlight.texture = self.unitHighlight:CreateTexture(nil, "OVERLAY")
                    self.unitHighlight.texture:SetAllPoints(true) -- Texture fills self.unitHighlight
                end
                self.unitHighlight.texture:SetTexture(CustomBorderSettings.BorderTexture)
                self.unitHighlight.texture:SetVertexColor(MHR, MHG, MHB, MHA) -- Apply highlight color
                self.unitHighlight.texture:Show()

                self.unitHighlight:ClearAllPoints()
                if self.MilaUICustomBorderFrame and self.MilaUICustomBorderFrame:IsShown() then
                    self.unitHighlight:SetAllPoints(self.MilaUICustomBorderFrame)
                    self.unitHighlight:SetFrameLevel(self.MilaUICustomBorderFrame:GetFrameLevel() + 1)
                else
                    self.unitHighlight:SetAllPoints(self.unitHealthBar or self) -- Fallback positioning
                    self.unitHighlight:SetFrameLevel(20) -- Fallback high level
                end
            end
        elseif MouseoverHighlight.Style == "HIGHLIGHT" then
            -- Standard fill highlight
            self.unitHighlight:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
            self.unitHighlight:SetBackdropColor(MHR, MHG, MHB, MHA)
            self.unitHighlight:SetBackdropBorderColor(0, 0, 0, 0)
            self.unitHighlight:SetFrameLevel(1) -- Lower level for a fill highlight
            self.unitHighlight:ClearAllPoints()
            self.unitHighlight:SetAllPoints(self.unitHealthBar or self)
        else
            -- Unknown style or style explicitly set to none, ensure highlight frame is cleared and hidden
            self.unitHighlight:Hide()
            return -- Nothing more to do for this style
        end
        self.unitHighlight:Hide() -- Initially hide; OnEnter script will show it.

    elseif self.unitHighlight then -- If MouseoverHighlight is NOT Enabled, but frame exists
        self.unitHighlight:Hide() -- Hide if mouseover highlight is disabled
    end
    -- If MouseoverHighlight is NOT Enabled and frame does NOT exist, do nothing.
end

local function CreateCustomBorder(self, unit, frameType)
    local r, g, b, a = unpack(MilaUI.DB.profile.Unitframes.General.BorderColour)
    
    -- Determine which border settings to use based on frameType
    local borderSettings
    local parent
    
    if frameType == "Power" then
        borderSettings = MilaUI.DB.profile.Unitframes[unit].PowerBar.CustomBorder
        parent = self.unitPowerBar
    else -- Default to Health
        borderSettings = MilaUI.DB.profile.Unitframes[unit].Health.CustomBorder
        parent = self.unitHealthBar
    end
    
    if not parent then return end
    
    -- If we already made a border for this frame, remove it
    local borderFrameName = "unitBorderFrame" .. (frameType or "")
    if self[borderFrameName] then
        self[borderFrameName]:Hide()
        self[borderFrameName] = nil
    end
    
    -- Create the border if enabled
    if borderSettings and borderSettings.Enabled then
        local BorderFrame = CreateFrame("Frame", nil, parent)
        
        -- For PowerBar, offset the border 1 pixel to the right
        if frameType == "Power" then
            BorderFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0.5, 0)
            BorderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0.5, 0)
        else
            BorderFrame:SetAllPoints(parent)
        end
        
        BorderFrame:SetFrameLevel(parent:GetFrameLevel() + 1)
        local BorderTexture = BorderFrame:CreateTexture(nil, "OVERLAY")
        BorderTexture:SetAllPoints(BorderFrame)
        BorderTexture:SetTexture(borderSettings.BorderTexture)
        BorderTexture:SetTexCoord(0, 1, 0, 1)
        BorderTexture:SetVertexColor(r, g, b, a)
        BorderTexture:SetAlpha(a)
        
        -- Store reference to the border frame
        self[borderFrameName] = BorderFrame
    end
end


local function ApplyScripts(self)
    local MouseoverHighlight = MilaUI.DB.profile.Unitframes.General.MouseoverHighlight
    self:RegisterForClicks("AnyUp")
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "togglemenu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:HookScript("OnEnter", function() if not MouseoverHighlight.Enabled then return end self.unitHighlight:Show() end)
    self:HookScript("OnLeave", function() if not MouseoverHighlight.Enabled then return end self.unitHighlight:Hide() end)
end

function MilaUI:CreateUnitFrame(Unit)
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    local PowerBar = MilaUI.DB.profile.Unitframes[Unit].PowerBar
    local Frame = MilaUI.DB.profile.Unitframes[Unit].Frame
    local HealthPrediction = Health.HealthPrediction
    local Absorbs = HealthPrediction.Absorbs
    local HealAbsorbs = HealthPrediction.HealAbsorbs

    -- Set the main frame size based on health bar dimensions
    self:SetSize(Health.Width, Health.Height)
    
    -- Create health bar directly on the main frame
    CreateHealthBar(self, Unit)
    CreateMouseoverHighlight(self)
    CreateAbsorbBar(self, Unit)
    CreateHealAbsorbBar(self, Unit)
    
    -- Configure health bar size independently
    if self.unitHealthBar then
        self.unitHealthBar:ClearAllPoints()
        self.unitHealthBar:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        self.unitHealthBar:SetSize(Health.Width - 2, Health.Height - 2)
    end
    
    -- Health prediction setup
    self.HealthPrediction = {
        myBar = nil,
        otherBar = nil,
        absorbBar = Absorbs.Enabled and self.unitAbsorbs or nil,
        healAbsorbBar = HealAbsorbs.Enabled and self.unitHealAbsorbs or nil,
        maxOverflow = 1,
        PostUpdate = function(_, unit, _, _, absorb, _, _, _)
            if not unit then return end
            local absorbBar = self.unitAbsorbs
            if not absorbBar then return end
            local maxHealth = UnitHealthMax(unit) or 0
            if maxHealth == 0 or not absorb or absorb == 0 then absorbBar:Hide() return end
            local overflowFactor = (self.HealthPrediction and self.HealthPrediction.maxOverflow) or 1.0
            if type(overflowFactor) ~= "number" then overflowFactor = 1.0 end
            local overflowLimit = maxHealth * overflowFactor
            local shownAbsorb = math.min(absorb, overflowLimit)
            absorbBar:SetValue(shownAbsorb)
            absorbBar:Show()
        end
    }
    
    -- Create power bar with oUF handling but custom size
    CreatePowerBar(self, Unit)
    
    -- Apply custom borders if needed
    if Health.CustomBorder.Enabled then
        CreateCustomBorder(self, Unit, "Health")
    end
    
    if PowerBar.Enabled and PowerBar.CustomBorder.Enabled then
        CreateCustomBorder(self, Unit, "Power")
    end
    
    -- Create other elements on the main frame
    CreatePortrait(self, Unit)
    CreateBuffs(self, Unit)
    CreateDebuffs(self, Unit)
    CreateTextFields(self, Unit)
    CreateIndicators(self, Unit)
    
    -- Apply scripts
    ApplyScripts(self)
    
    -- Store references to elements
    self.Health = self.unitHealthBar
    if PowerBar.Enabled then
        self.Power = self.unitPowerBar
    end
end

local function UpdateFrame(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local Frame = MilaUI.DB.profile.Unitframes[Unit].Frame
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    local PowerBar = MilaUI.DB.profile.Unitframes[Unit].PowerBar
    if FrameName then
        FrameName:ClearAllPoints()
        -- Set the frame size based only on the health bar dimensions
        -- since the power bar is now positioned independently
        FrameName:SetSize(Health.Width, Health.Height)
        local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
        FrameName:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
        if Frame.CustomScale then FrameName:SetScale(Frame.Scale) end
    end

end

local function UpdateHealthBar(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local General = MilaUI.DB.profile.Unitframes.General
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    -- Update border if applicable
    if FrameName.unitBorder and not Health.CustomBorder.Enabled then
        FrameName.unitBorder:SetBackdropBorderColor(unpack(General.BorderColour))
        FrameName.unitBorder:SetFrameLevel(1)
    end

    local bar = FrameName.unitHealthBar
    if bar then
        -- Resize and reposition health bar
        bar:SetSize(Health.Width - 2, Health.Height - 2)
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", FrameName, "TOPLEFT", 1, -1)

        -- Apply texture and optional mask
        local healthTexturePath = LSM:Fetch("statusbar", Health.Texture)
        bar:SetStatusBarTexture(healthTexturePath)
        local tex = bar:GetStatusBarTexture()
        if Health.CustomMask.Enabled and Health.CustomMask.MaskTexture and not tex.mask then
            tex:SetMask(Health.CustomMask.MaskTexture)
        end

        -- Update oUF color logic flags
        bar.colorClass        = General.ColourByClass
        bar.colorReaction     = General.ColourByClass
        bar.colorDisconnected = General.ColourIfDisconnected
        bar.colorTapping      = General.ColourIfTapped
        bar.colorHealth       = true
        bar:SetAlpha(General.ForegroundColour[4])

        -- Special color override for pet
        if Unit == "Pet" then
            local ColourByPlayerClass = MilaUI.DB.profile.Unitframes.Pet.Health.ColourByPlayerClass
            if ColourByPlayerClass then
                bar.colorClass = false
                bar.colorReaction = false
                bar.colorHealth = false
                local unitClass = select(2, UnitClass("player"))
                local unitColor = RAID_CLASS_COLORS[unitClass]
                if unitColor then
                    bar:SetStatusBarColor(unitColor.r, unitColor.g, unitColor.b, General.ForegroundColour[4])
                end
            end
            FrameName.unitHealthBar:ForceUpdate()
        end

        -- Reverse fill direction
        if Health.Direction == "RL" then
            FrameName.unitHealthBar:SetReverseFill(true)
        elseif Health.Direction == "LR" then
            FrameName.unitHealthBar:SetReverseFill(false)
        end

        -- Ensure proper layering
        bar:SetFrameLevel(2)

        -- ✅ NEW: Update background (health.bg)
        if bar.bg then
            bar.bg:SetSize(Health.Width - 2, Health.Height - 2)
            bar.bg:ClearAllPoints()
            bar.bg:SetPoint("TOPLEFT", FrameName, "TOPLEFT", 1, -1)
            local bgTexture = LSM:Fetch("statusbar", Health.BackgroundTexture)
            bar.bg:SetTexture(bgTexture)
            if Health.CustomMask.Enabled and Health.CustomMask.MaskTexture and not bar.bg.mask then
                bar.bg:SetMask(Health.CustomMask.MaskTexture)
            end
            bar.bg:SetVertexColor(unpack(General.BackgroundColour))
            bar.bg:SetAlpha(General.BackgroundColour[4])
        end

        bar:ForceUpdate()
    end
end


local function UpdateAbsorbBar(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local General = MilaUI.DB.profile.Unitframes.General
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    local HealthPrediction = MilaUI.DB.profile.Unitframes[Unit].Health.HealthPrediction
    local Absorbs = HealthPrediction.Absorbs
    if FrameName.unitAbsorbs and Absorbs.Enabled then
        local absorbsTexturePath = LSM:Fetch("statusbar", General.AbsorbTexture)
        FrameName.unitAbsorbs:SetStatusBarTexture(absorbsTexturePath)
        local HealthBarTexture = FrameName.unitHealthBar:GetStatusBarTexture()
        if HealthBarTexture then
            FrameName.unitAbsorbs:SetReverseFill(Health.Direction == "RL")
            FrameName.unitAbsorbs:ClearAllPoints()
            if Health.Direction == "RL" then
                FrameName.unitAbsorbs:SetPoint("TOPRIGHT", HealthBarTexture, "TOPLEFT")
                FrameName.unitAbsorbs:SetPoint("BOTTOMRIGHT", HealthBarTexture, "BOTTOMLEFT")
            else
                FrameName.unitAbsorbs:SetPoint("TOPLEFT", HealthBarTexture, "TOPRIGHT")
                FrameName.unitAbsorbs:SetPoint("BOTTOMLEFT", HealthBarTexture, "BOTTOMRIGHT")
            end
        end
        local UHAR, UHAG, UHAB, UHAA = unpack(Absorbs.Colour)
        FrameName.unitAbsorbs:SetStatusBarColor(UHAR, UHAG, UHAB, UHAA)
        FrameName.unitAbsorbs:SetSize(FrameName:GetWidth() - 2, FrameName:GetHeight() - 2)
        FrameName.unitAbsorbs:SetFrameLevel(FrameName.unitHealthBar:GetFrameLevel() + 1)
    end
end

local function UpdateHealAbsorbBar(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local General = MilaUI.DB.profile.Unitframes.General
    local Health = MilaUI.DB.profile.Unitframes[Unit].Health
    local HealthPrediction = MilaUI.DB.profile.Unitframes[Unit].Health.HealthPrediction
    local HealAbsorbs = HealthPrediction.HealAbsorbs
    if FrameName.unitHealAbsorbs and HealAbsorbs.Enabled then
        local healAbsorbsTexturePath = LSM:Fetch("statusbar", General.AbsorbTexture)
        FrameName.unitHealAbsorbs:SetStatusBarTexture(healAbsorbsTexturePath)
        local HealthBarTexture = FrameName.unitHealthBar:GetStatusBarTexture()
        if HealthBarTexture then
            FrameName.unitHealAbsorbs:ClearAllPoints()
            if Health.Direction == "RL" then
                FrameName.unitHealAbsorbs:SetReverseFill(false)
                FrameName.unitHealAbsorbs:SetPoint("TOPLEFT", HealthBarTexture, "TOPLEFT")
                FrameName.unitHealAbsorbs:SetPoint("BOTTOMRIGHT", HealthBarTexture, "BOTTOMRIGHT")
            else
                FrameName.unitHealAbsorbs:SetReverseFill(true)
                FrameName.unitHealAbsorbs:SetPoint("TOPRIGHT", HealthBarTexture, "TOPRIGHT")
                FrameName.unitHealAbsorbs:SetPoint("BOTTOMLEFT", HealthBarTexture, "BOTTOMLEFT")
            end
        end
        local UHAR, UHAG, UHAB, UHAA = unpack(HealAbsorbs.Colour)
        FrameName.unitHealAbsorbs:SetStatusBarColor(UHAR, UHAG, UHAB, UHAA)
        FrameName.unitHealAbsorbs:SetSize(FrameName:GetWidth() - 2, FrameName:GetHeight() - 2)
        FrameName.unitHealAbsorbs:SetFrameLevel(FrameName.unitHealthBar:GetFrameLevel() + 1)
    end
end

local function UpdatePowerBar(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local General = MilaUI.DB.profile.Unitframes.General
    local PowerBar = MilaUI.DB.profile.Unitframes[Unit].PowerBar
    local r, g, b, a = unpack(General.BackgroundColour)
    local BackdropTemplate = {
        bgFile = General.BackgroundTexture,
        edgeFile = General.BorderTexture,
        edgeSize = General.BorderSize,
        insets = { left = General.BorderInset, right = General.BorderInset, top = General.BorderInset, bottom = General.BorderInset },
    }
    
    if PowerBar.Enabled and FrameName.unitPowerBar then
        FrameName.unitPowerBar:ClearAllPoints()
        
        local anchorFrom = PowerBar.AnchorFrom or "TOPLEFT"
        local anchorTo = PowerBar.AnchorTo or "BOTTOMLEFT"
        local anchorParent = PowerBar.AnchorParent or "unitHealthBar"
        local xOffset = PowerBar.XPosition or 0
        local yOffset = PowerBar.YPosition or -1
        
        -- Determine the actual anchor parent frame
        local parentFrame
        if anchorParent == "unitHealthBar" or anchorParent == "" then
            parentFrame = FrameName.unitHealthBar
        elseif anchorParent == "UIParent" then
            parentFrame = UIParent
        else
            -- Try to find the frame by name, fallback to health bar if not found
            parentFrame = _G[anchorParent] or FrameName.unitHealthBar
        end
        
        -- Set the position
        FrameName.unitPowerBar:SetPoint(anchorFrom, parentFrame, anchorTo, xOffset, yOffset)
        FrameName.unitPowerBar:SetSize(PowerBar.Width - 2, PowerBar.Height - 2)
        
        -- Update power bar appearance
        local powerTexturePath = LSM:Fetch("statusbar", PowerBar.Texture)
        FrameName.unitPowerBar:SetStatusBarTexture(powerTexturePath)
        
        -- Update mask if needed
        local tex = FrameName.unitPowerBar:GetStatusBarTexture()
        if PowerBar.CustomMask.Enabled and PowerBar.CustomMask.MaskTexture then
            if not tex.mask then
                tex:SetMask(PowerBar.CustomMask.MaskTexture)
            end
        end
        
        -- Update power bar properties
        FrameName.unitPowerBar:SetStatusBarColor(unpack(PowerBar.Colour))
        FrameName.unitPowerBar:SetAlpha(PowerBar.Colour[4])
        FrameName.unitPowerBar.colorPower = PowerBar.ColourByType
        FrameName.unitPowerBar.frequentUpdates = PowerBar.Smooth
        
        -- Update fill direction
        if PowerBar.Direction == "RL" then
            FrameName.unitPowerBar:SetReverseFill(true)
        elseif PowerBar.Direction == "LR" then
            FrameName.unitPowerBar:SetReverseFill(false)
        end
        
        -- Update power bar background
        if FrameName.unitPowerBarBackground then
            FrameName.unitPowerBarBackground:ClearAllPoints()
            FrameName.unitPowerBarBackground:SetAllPoints()
            
            local powerBgTexturePath = LSM:Fetch("statusbar", PowerBar.BackgroundTexture)
            FrameName.unitPowerBarBackground:SetTexture(powerBgTexturePath)
            
            if PowerBar.CustomMask.Enabled and PowerBar.CustomMask.MaskTexture then
                if not FrameName.unitPowerBarBackground.mask then
                    FrameName.unitPowerBarBackground:SetMask(PowerBar.CustomMask.MaskTexture)
                end
            end
            
            FrameName.unitPowerBarBackground:SetAlpha(PowerBar.BackgroundColour[4])
            
            if PowerBar.ColourBackgroundByType then
                FrameName.unitPowerBarBackground.multiplier = PowerBar.BackgroundMultiplier
                FrameName.unitPowerBar.bg = FrameName.unitPowerBarBackground
            else
                FrameName.unitPowerBarBackground:SetVertexColor(unpack(PowerBar.BackgroundColour))
                FrameName.unitPowerBar.bg = nil
            end
        end
        
        -- Update power bar border
        if PowerBar.Border and PowerBar.Border.Enabled and not PowerBar.CustomBorder.Enabled and FrameName.unitPowerBarBorder then
            FrameName.unitPowerBarBorder:SetSize(PowerBar.Width, PowerBar.Height)
            FrameName.unitPowerBarBorder:ClearAllPoints()
            FrameName.unitPowerBarBorder:SetPoint("CENTER", FrameName.unitPowerBar, "CENTER", 0, 0)
            FrameName.unitPowerBarBorder:SetBackdrop(BackdropTemplate)
            FrameName.unitPowerBarBorder:SetBackdropColor(0, 0, 0, 0)
            FrameName.unitPowerBarBorder:SetBackdropBorderColor(unpack(General.BorderColour))
            FrameName.unitPowerBarBorder:SetFrameLevel(4)
        end
        
        -- Force update the power bar
        FrameName.unitPowerBar:ForceUpdate()
    end
end

local function UpdateBuffs(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local Buffs = MilaUI.DB.profile.Unitframes[Unit].Buffs
    
    -- Safety check: ensure unitBuffs exists
    if not FrameName.unitBuffs then
        return
    end
    
    if Buffs.Enabled then
        FrameName.unitBuffs:ClearAllPoints()
        FrameName.unitBuffs:SetSize(FrameName:GetWidth(), Buffs.Size)
        
        -- Determine anchor based on AnchorFrame setting
        local anchorFrame = FrameName
        if Buffs.AnchorFrame then
            if Buffs.AnchorFrame == "HealthBar" and FrameName.unitHealthBar then
                anchorFrame = FrameName.unitHealthBar
            elseif Buffs.AnchorFrame == "PowerBar" and FrameName.unitPowerBar then
                anchorFrame = FrameName.unitPowerBar
            elseif Buffs.AnchorFrame == "Debuffs" and FrameName.unitDebuffs then
                anchorFrame = FrameName.unitDebuffs
            elseif Buffs.AnchorFrame ~= "Buffs" and _G[Buffs.AnchorFrame] then
                -- Try to find a global frame with this name
                anchorFrame = _G[Buffs.AnchorFrame]
            end
        end
        
        FrameName.unitBuffs:SetPoint(Buffs.AnchorFrom, anchorFrame, Buffs.AnchorTo, Buffs.XOffset, Buffs.YOffset)
        FrameName.unitBuffs.size = Buffs.Size
        FrameName.unitBuffs.spacing = Buffs.Spacing
        FrameName.unitBuffs.num = Buffs.Num
        FrameName.unitBuffs.initialAnchor = Buffs.AnchorFrom
        FrameName.unitBuffs.onlyShowPlayer = Buffs.OnlyShowPlayer
        FrameName.unitBuffs.onlyShowBoss = Buffs.OnlyShowBoss
        FrameName.unitBuffs["growth-x"] = Buffs.GrowthX
        FrameName.unitBuffs["growth-y"] = Buffs.GrowthY
        FrameName.unitBuffs.filter = "HELPFUL"
        FrameName.unitBuffs:Show()
        FrameName.unitBuffs.PostUpdateButton = function(_, button) PostUpdateButton(_, button, Unit, "HELPFUL") end
        FrameName.unitBuffs:ForceUpdate()
    else
        if FrameName.unitBuffs then
            FrameName.unitBuffs:Hide()
        end
    end
end

local function UpdateDebuffs(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local Debuffs = MilaUI.DB.profile.Unitframes[Unit].Debuffs
    
    -- Safety check: ensure unitDebuffs exists
    if not FrameName.unitDebuffs then
        return
    end
    
    if Debuffs.Enabled then
        FrameName.unitDebuffs:ClearAllPoints()
        FrameName.unitDebuffs:SetSize(FrameName:GetWidth(), Debuffs.Size)
        
        -- Determine anchor based on AnchorFrame setting
        local anchorFrame = FrameName
        if Debuffs.AnchorFrame then
            if Debuffs.AnchorFrame == "HealthBar" and FrameName.unitHealthBar then
                anchorFrame = FrameName.unitHealthBar
            elseif Debuffs.AnchorFrame == "PowerBar" and FrameName.unitPowerBar then
                anchorFrame = FrameName.unitPowerBar
            elseif Debuffs.AnchorFrame == "Buffs" and FrameName.unitBuffs then
                anchorFrame = FrameName.unitBuffs
            elseif Debuffs.AnchorFrame ~= "Debuffs" and _G[Debuffs.AnchorFrame] then
                -- Try to find a global frame with this name
                anchorFrame = _G[Debuffs.AnchorFrame]
            end
        end
        
        FrameName.unitDebuffs:SetPoint(Debuffs.AnchorFrom, anchorFrame, Debuffs.AnchorTo, Debuffs.XOffset, Debuffs.YOffset)
        FrameName.unitDebuffs.size = Debuffs.Size
        FrameName.unitDebuffs.spacing = Debuffs.Spacing
        FrameName.unitDebuffs.num = Debuffs.Num
        FrameName.unitDebuffs.initialAnchor = Debuffs.AnchorFrom
        FrameName.unitDebuffs.onlyShowPlayer = Debuffs.OnlyShowPlayer
        FrameName.unitDebuffs.onlyShowBoss = Debuffs.OnlyShowBoss
        FrameName.unitDebuffs["growth-x"] = Debuffs.GrowthX
        FrameName.unitDebuffs["growth-y"] = Debuffs.GrowthY
        FrameName.unitDebuffs.filter = "HARMFUL"
        FrameName.unitDebuffs:Show()
        FrameName.unitDebuffs.PostUpdateButton = function(_, button) PostUpdateButton(_, button, Unit, "HARMFUL") end
        FrameName.unitDebuffs:ForceUpdate()
    else
        if FrameName.unitDebuffs then
            FrameName.unitDebuffs:Hide()
        end
    end
end

local function UpdatePortrait(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local General = MilaUI.DB.profile.Unitframes.General
    local Portrait = MilaUI.DB.profile.Unitframes[Unit].Portrait
    local BackdropTemplate = {
        bgFile = General.BackgroundTexture,
        edgeFile = General.BorderTexture,
        edgeSize = General.BorderSize,
        insets = { left = General.BorderInset, right = General.BorderInset, top = General.BorderInset, bottom = General.BorderInset },
    }
    if FrameName.unitPortraitBackdrop and FrameName.unitPortrait and Portrait.Enabled then
        FrameName.unitPortraitBackdrop:ClearAllPoints()
        FrameName.unitPortraitBackdrop:SetSize(Portrait.Size, Portrait.Size)
        FrameName.unitPortraitBackdrop:SetPoint(Portrait.AnchorFrom, FrameName, Portrait.AnchorTo, Portrait.XOffset, Portrait.YOffset)
        FrameName.unitPortraitBackdrop:SetBackdrop(BackdropTemplate)
        FrameName.unitPortraitBackdrop:SetBackdropColor(unpack(General.BackgroundColour))
        FrameName.unitPortraitBackdrop:SetBackdropBorderColor(unpack(General.BorderColour))
        FrameName.unitPortrait:SetSize(FrameName.unitPortraitBackdrop:GetHeight() - 2, FrameName.unitPortraitBackdrop:GetHeight() - 2)
        FrameName.unitPortrait:SetPoint("CENTER", FrameName.unitPortraitBackdrop, "CENTER", 0, 0)
    end
end

function MilaUI:UpdateIndicators(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local TargetIndicator = MilaUI.DB.profile.Unitframes[Unit].TargetIndicator
    local CombatIndicator = MilaUI.DB.profile.Unitframes[Unit].CombatIndicator
    local LeaderIndicator = MilaUI.DB.profile.Unitframes[Unit].LeaderIndicator
    local TargetMarker = MilaUI.DB.profile.Unitframes[Unit].TargetMarker

    if FrameName.unitIsTargetIndicator and not TargetIndicator.Enabled then
        FrameName.unitIsTargetIndicator:Hide()
    end

    if FrameName.unitTargetMarker and TargetMarker.Enabled then
        FrameName.unitTargetMarker:ClearAllPoints()
        FrameName.unitTargetMarker:SetSize(TargetMarker.Size, TargetMarker.Size)
        FrameName.unitTargetMarker:SetPoint(TargetMarker.AnchorFrom, FrameName, TargetMarker.AnchorTo, TargetMarker.XOffset, TargetMarker.YOffset)
    end

    -- Frame Combat Indicator
    if FrameName.unitCombatIndicator and (Unit == "Player" or Unit == "Target" or Unit == "Focus") and CombatIndicator.Enabled then
        FrameName.unitCombatIndicator:Show()
        if FrameName.unitCombatIndicator.hideTimer then
            FrameName.unitCombatIndicator.hideTimer:Cancel()
        end
        FrameName.unitCombatIndicator.hideTimer = C_Timer.NewTimer(5, function()
            if FrameName.unitCombatIndicator and FrameName.unitCombatIndicator:IsShown() then
                FrameName.unitCombatIndicator:Hide()
            end
        end)
        FrameName.unitCombatIndicator:ClearAllPoints()
        FrameName.unitCombatIndicator:SetSize(CombatIndicator.Size, CombatIndicator.Size)
        FrameName.unitCombatIndicator:SetPoint(CombatIndicator.AnchorFrom, FrameName, CombatIndicator.AnchorTo, CombatIndicator.XOffset, CombatIndicator.YOffset)
    end

    -- Frame Leader Indicator
    if FrameName.unitLeaderIndicator and (Unit == "Player" or Unit == "Target" or Unit == "Focus") and LeaderIndicator.Enabled then
        FrameName.unitLeaderIndicator:ClearAllPoints()
        FrameName.unitLeaderIndicator:SetSize(LeaderIndicator.Size, LeaderIndicator.Size)
        FrameName.unitLeaderIndicator:SetPoint(LeaderIndicator.AnchorFrom, FrameName, LeaderIndicator.AnchorTo, LeaderIndicator.XOffset, LeaderIndicator.YOffset)
    end
end

local function UpdateTextFields(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local Frame = MilaUI.DB.profile.Unitframes[Unit].Frame
    local General = MilaUI.DB.profile.Unitframes.General
    local FirstText = MilaUI.DB.profile.Unitframes[Unit].Texts.First
    local SecondText = MilaUI.DB.profile.Unitframes[Unit].Texts.Second
    local ThirdText = MilaUI.DB.profile.Unitframes[Unit].Texts.Third
    if FrameName.unitHighLevelFrame then
        FrameName.unitHighLevelFrame:ClearAllPoints()
        FrameName.unitHighLevelFrame:SetSize(Frame.Width, Frame.Height)
        FrameName.unitHighLevelFrame:SetPoint("CENTER", 0, 0)
        FrameName.unitHighLevelFrame:SetFrameLevel(FrameName.unitHealthBar:GetFrameLevel() + 20)

        -- Fetch font path and flag once
        local fontPath = LSM:Fetch("font", General.Font)
        local fontFlag = General.FontFlag

        if FrameName.unitFirstText then
            FrameName.unitFirstText:ClearAllPoints()
            FrameName.unitFirstText:SetFont(fontPath, FirstText.FontSize, fontFlag)
            FrameName.unitFirstText:SetShadowColor(General.FontShadowColour[1], General.FontShadowColour[2], General.FontShadowColour[3], General.FontShadowColour[4])
            FrameName.unitFirstText:SetShadowOffset(General.FontShadowXOffset, General.FontShadowYOffset)
            FrameName.unitFirstText:SetPoint(FirstText.AnchorFrom, FrameName.unitHighLevelFrame, FirstText.AnchorTo, FirstText.XOffset, FirstText.YOffset)
            FrameName.unitFirstText:SetTextColor(FirstText.Colour[1], FirstText.Colour[2], FirstText.Colour[3], FirstText.Colour[4])
            FrameName.unitFirstText:SetJustifyH(MilaUI:GetFontJustification(FirstText.AnchorTo)) -- Always Ensure Alignment Is Either Left/Right/Center based on AnchorTo.
            FrameName:Tag(FrameName.unitFirstText, FirstText.Tag)
        end

        if FrameName.unitSecondText then
            FrameName.unitSecondText:ClearAllPoints()
            FrameName.unitSecondText:SetFont(fontPath, SecondText.FontSize, fontFlag)
            FrameName.unitSecondText:SetShadowColor(General.FontShadowColour[1], General.FontShadowColour[2], General.FontShadowColour[3], General.FontShadowColour[4])
            FrameName.unitSecondText:SetShadowOffset(General.FontShadowXOffset, General.FontShadowYOffset)
            FrameName.unitSecondText:SetPoint(SecondText.AnchorFrom, FrameName.unitHighLevelFrame, SecondText.AnchorTo, SecondText.XOffset, SecondText.YOffset)
            FrameName.unitSecondText:SetTextColor(SecondText.Colour[1], SecondText.Colour[2], SecondText.Colour[3], SecondText.Colour[4])
            FrameName.unitSecondText:SetJustifyH(MilaUI:GetFontJustification(SecondText.AnchorTo)) -- Always Ensure Alignment Is Either Left/Right/Center based on AnchorTo.
            FrameName:Tag(FrameName.unitSecondText, SecondText.Tag)
        end

        if FrameName.unitThirdText then
            FrameName.unitThirdText:ClearAllPoints()
            FrameName.unitThirdText:SetFont(fontPath, ThirdText.FontSize, fontFlag)
            FrameName.unitThirdText:SetShadowColor(General.FontShadowColour[1], General.FontShadowColour[2], General.FontShadowColour[3], General.FontShadowColour[4])
            FrameName.unitThirdText:SetShadowOffset(General.FontShadowXOffset, General.FontShadowYOffset)
            FrameName.unitThirdText:SetPoint(ThirdText.AnchorFrom, FrameName.unitHighLevelFrame, ThirdText.AnchorTo, ThirdText.XOffset, ThirdText.YOffset)
            FrameName.unitThirdText:SetTextColor(ThirdText.Colour[1], ThirdText.Colour[2], ThirdText.Colour[3], ThirdText.Colour[4])
            FrameName.unitThirdText:SetJustifyH(MilaUI:GetFontJustification(ThirdText.AnchorTo)) -- Always Ensure Alignment Is Either Left/Right/Center based on AnchorTo.
            FrameName:Tag(FrameName.unitThirdText, ThirdText.Tag)
        end

        FrameName:UpdateTags()
    end
end

local function UpdateMouseoverHighlight(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss" -- Define Unit
    local MouseoverHighlight = MilaUI.DB.profile.Unitframes.General.MouseoverHighlight
    local CustomBorderSettings = MilaUI.DB.profile.Unitframes[Unit].Health.CustomBorder

    if MouseoverHighlight.Enabled and FrameName.unitHighlight then
        local MHR, MHG, MHB, MHA = unpack(MouseoverHighlight.Colour)

        -- Clear previous states of FrameName.unitHighlight
        FrameName.unitHighlight:SetBackdrop(nil)
        if FrameName.unitHighlight.texture then
            FrameName.unitHighlight.texture:SetTexture(nil) -- Clear texture before reconfiguring
            FrameName.unitHighlight.texture:Hide()
        end

        if MouseoverHighlight.Style == "BORDER" then
            if not CustomBorderSettings.Enabled then
                -- Standard border highlight (not custom)
                FrameName.unitHighlight:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
                FrameName.unitHighlight:SetBackdropColor(0, 0, 0, 0)
                FrameName.unitHighlight:SetBackdropBorderColor(MHR, MHG, MHB, MHA)
                FrameName.unitHighlight:SetFrameLevel(20) -- Default high level
                FrameName.unitHighlight:ClearAllPoints()
                FrameName.unitHighlight:SetAllPoints(FrameName.unitHealthBar or FrameName)
            else -- CustomBorderSettings.Enabled is true: Use custom border texture for highlight
                if not FrameName.unitHighlight.texture then
                    FrameName.unitHighlight.texture = FrameName.unitHighlight:CreateTexture(nil, "OVERLAY")
                    FrameName.unitHighlight.texture:SetAllPoints(true) -- Texture fills FrameName.unitHighlight
                end
                FrameName.unitHighlight.texture:SetTexture(CustomBorderSettings.BorderTexture)
                FrameName.unitHighlight.texture:SetVertexColor(MHR, MHG, MHB, MHA) -- Apply highlight color
                FrameName.unitHighlight.texture:Show()

                FrameName.unitHighlight:ClearAllPoints()
                if FrameName.MilaUICustomBorderFrame and FrameName.MilaUICustomBorderFrame:IsShown() then
                    FrameName.unitHighlight:SetAllPoints(FrameName.MilaUICustomBorderFrame)
                    FrameName.unitHighlight:SetFrameLevel(FrameName.MilaUICustomBorderFrame:GetFrameLevel() + 1) -- On top of existing custom border
                else
                    FrameName.unitHighlight:SetAllPoints(FrameName.unitHealthBar or FrameName) -- Fallback positioning
                    FrameName.unitHighlight:SetFrameLevel(20) -- Fallback high level
                end
            end
        elseif MouseoverHighlight.Style == "HIGHLIGHT" then
            -- Standard fill highlight
            FrameName.unitHighlight:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} })
            FrameName.unitHighlight:SetBackdropColor(MHR, MHG, MHB, MHA)
            FrameName.unitHighlight:SetBackdropBorderColor(0, 0, 0, 0)
            FrameName.unitHighlight:SetFrameLevel(1) -- Lower level for a fill highlight
            FrameName.unitHighlight:ClearAllPoints()
            FrameName.unitHighlight:SetAllPoints(FrameName.unitHealthBar or FrameName)
        else
            -- Unknown style or style explicitly set to none, ensure highlight frame is cleared and hidden
            FrameName.unitHighlight:Hide()
            return -- Nothing more to do for this style
        end
        FrameName.unitHighlight:Hide() -- Initially hide; OnEnter script will show it.
    elseif FrameName.unitHighlight then
        FrameName.unitHighlight:Hide() -- Hide if mouseover highlight is disabled
    end
end

local function UpdateCustomBorder(FrameName)
    local Unit = MilaUI.Frames[FrameName.unit] or "Boss"
    local GeneralSettings = MilaUI.DB.profile.Unitframes.General
    local CustomBorderHealth = MilaUI.DB.profile.Unitframes[Unit].Health.CustomBorder
    local CustomBorderPower = MilaUI.DB.profile.Unitframes[Unit].PowerBar.CustomBorder

    if CustomBorderHealth.Enabled then
        if not FrameName.MilaUICustomBorderFrame then
            -- Create the border frame and its texture only if they don't already exist
            FrameName.MilaUICustomBorderFrame = CreateFrame("Frame", nil, FrameName)
            FrameName.MilaUICustomBorderFrame:SetFrameLevel(FrameName:GetFrameLevel() + 2) -- Ensure it's above the health bar, +1 might be the health bar itself
            local texture = FrameName.MilaUICustomBorderFrame:CreateTexture(nil, "OVERLAY")
            texture:SetAllPoints(FrameName.MilaUICustomBorderFrame)
            FrameName.MilaUICustomBorderFrame.texture = texture -- Store the texture object on the frame for easy access
        end

        -- Update the texture and color of the existing/newly created border
        FrameName.MilaUICustomBorderFrame.texture:SetTexture(CustomBorderHealth.BorderTexture) -- Corrected from CustomBorder.Texture
        FrameName.MilaUICustomBorderFrame.texture:SetTexCoord(0, 1, 0, 1)
        FrameName.MilaUICustomBorderFrame.texture:SetVertexColor(unpack(GeneralSettings.BorderColour))
        FrameName.MilaUICustomBorderFrame:SetAllPoints(FrameName.unitHealthBar or FrameName) -- Ensure it covers the health bar or frame
        FrameName.MilaUICustomBorderFrame:Show()
    elseif CustomBorderPower.Enabled then
        if not FrameName.MilaUICustomBorderFrame then
            -- Create the border frame and its texture only if they don't already exist
            FrameName.MilaUICustomBorderFrame = CreateFrame("Frame", nil, FrameName)
            FrameName.MilaUICustomBorderFrame:SetFrameLevel(FrameName:GetFrameLevel() + 2) -- Ensure it's above the health bar, +1 might be the health bar itself
            local texture = FrameName.MilaUICustomBorderFrame:CreateTexture(nil, "OVERLAY")
            texture:SetAllPoints(FrameName.MilaUICustomBorderFrame)
            FrameName.MilaUICustomBorderFrame.texture = texture -- Store the texture object on the frame for easy access
        end

        -- Update the texture and color of the existing/newly created border
        FrameName.MilaUICustomBorderFrame.texture:SetTexture(CustomBorderPower.BorderTexture) -- Corrected from CustomBorder.Texture
        FrameName.MilaUICustomBorderFrame.texture:SetTexCoord(0, 1, 0, 1)
        FrameName.MilaUICustomBorderFrame.texture:SetVertexColor(unpack(GeneralSettings.BorderColour))
        FrameName.MilaUICustomBorderFrame:SetAllPoints(FrameName.unitPowerBar or FrameName) -- Ensure it covers the health bar or frame
        FrameName.MilaUICustomBorderFrame:Show()
    else
        -- If custom border is not enabled, hide the frame if it exists
        if FrameName.MilaUICustomBorderFrame then
            FrameName.MilaUICustomBorderFrame:Hide()
        end
    end
end

function MilaUI:UpdateUnitFrame(FrameName)
    if not FrameName then return end
    if not FrameName.unit then return end
    UpdateFrame(FrameName)
    UpdateHealthBar(FrameName)
    UpdatePowerBar(FrameName)
    UpdateAbsorbBar(FrameName)
    UpdateHealAbsorbBar(FrameName)
    UpdateCustomBorder(FrameName)
    UpdateBuffs(FrameName)
    UpdateDebuffs(FrameName)
    UpdatePortrait(FrameName)
    MilaUI:UpdateIndicators(FrameName)
    UpdateTextFields(FrameName)
    UpdateMouseoverHighlight(FrameName)
    if MilaUI.DB.profile.TestMode then MilaUI:DisplayBossFrames() end
end

function MilaUI:UpdateBossFrames()
    if not MilaUI.BossFrames then return end
    for _, BossFrame in ipairs(MilaUI.BossFrames) do MilaUI:UpdateUnitFrame(BossFrame) end
    local Frame = MilaUI.DB.profile.Unitframes.Boss.Frame
    local BossSpacing = Frame.Spacing
    local growDown = Frame.GrowthY == "DOWN"
    for i, BossFrame in ipairs(MilaUI.BossFrames) do
        BossFrame:ClearAllPoints()
        if i == 1 then
            local BossContainerHeight = (BossFrame:GetHeight() + BossSpacing) * #MilaUI.BossFrames - BossSpacing
            local offsetY = 0
            if (Frame.AnchorFrom == "TOPLEFT" or Frame.AnchorFrom == "TOPRIGHT" or Frame.AnchorFrom == "TOP") and not growDown then
                offsetY = -BossContainerHeight
            elseif (Frame.AnchorFrom == "BOTTOMLEFT" or Frame.AnchorFrom == "BOTTOMRIGHT" or Frame.AnchorFrom == "BOTTOM") and growDown then
                offsetY = BossContainerHeight
            elseif (Frame.AnchorFrom == "CENTER" or Frame.AnchorFrom == "LEFT" or Frame.AnchorFrom == "RIGHT") then
                if (growDown) then
                    offsetY = (BossContainerHeight - BossFrame:GetHeight()) / 2
                else
                    offsetY = -(BossContainerHeight - BossFrame:GetHeight()) / 2
                end
            end
            local adjustedAnchorFrom = Frame.AnchorFrom 
            if Frame.AnchorFrom == "TOPLEFT" and not growDown then
                adjustedAnchorFrom = "BOTTOMLEFT"
            elseif Frame.AnchorFrom == "TOP" and not growDown then
                adjustedAnchorFrom = "BOTTOM"
            elseif Frame.AnchorFrom == "TOPRIGHT" and not growDown then
                adjustedAnchorFrom = "BOTTOMRIGHT"
            elseif Frame.AnchorFrom == "BOTTOMLEFT" and growDown then
                adjustedAnchorFrom = "TOPLEFT"
            elseif Frame.AnchorFrom == "BOTTOM" and growDown then
                adjustedAnchorFrom = "TOP"
            elseif Frame.AnchorFrom == "BOTTOMRIGHT" and growDown then
                adjustedAnchorFrom = "TOPRIGHT"
            end
            BossFrame:SetPoint( adjustedAnchorFrom, Frame.AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition + offsetY)
        else
            local anchor = growDown and "TOPLEFT" or "BOTTOMLEFT"
            local relativeAnchor = growDown and "BOTTOMLEFT" or "TOPLEFT"
            local offsetY = growDown and -BossSpacing or BossSpacing
            BossFrame:SetPoint( anchor, _G["MilaUI_Boss" .. (i - 1)], relativeAnchor, 0, offsetY )
        end
    end
end

function MilaUI:LoadCustomColours()
    local General = MilaUI.DB.profile.Unitframes.General
    local PowerTypesToString = {
        [0] = "MANA",
        [1] = "RAGE",
        [2] = "FOCUS",
        [3] = "ENERGY",
        [6] = "RUNIC_POWER",
        [8] = "LUNAR_POWER",
        [11] = "MAELSTROM",
        [13] = "INSANITY",
        [17] = "FURY",
        [18] = "PAIN"
    }

    for powerType, color in pairs(General.CustomColours.Power) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then
            oUF.colors.power[powerTypeString] = color
        end
    end

    for reaction, color in pairs(General.CustomColours.Reaction) do
        oUF.colors.reaction[reaction] = color
    end

    oUF.colors.health = { General.ForegroundColour[1], General.ForegroundColour[2], General.ForegroundColour[3] }
    oUF.colors.tapped = { General.CustomColours.Status[2][1], General.CustomColours.Status[2][2], General.CustomColours.Status[2][3] }
    oUF.colors.disconnected = { General.CustomColours.Status[3][1], General.CustomColours.Status[3][2], General.CustomColours.Status[3][3] }
end

function MilaUI:DisplayBossFrames()
    local General = MilaUI.DB.profile.Unitframes.General
    local Frame = MilaUI.DB.profile.Unitframes.Boss.Frame
    local Health = MilaUI.DB.profile.Unitframes.Boss.Health
    local PowerBar = MilaUI.DB.profile.Unitframes.Boss.PowerBar
    local HealthPrediction = Health.HealthPrediction
    local Absorbs = HealthPrediction.Absorbs
    local HealAbsorbs = HealthPrediction.HealAbsorbs

    local BackdropTemplate = {
        bgFile = General.BackgroundTexture,
        edgeFile = General.BorderTexture,
        edgeSize = General.BorderSize,
        insets = { left = General.BorderInset, right = General.BorderInset, top = General.BorderInset, bottom = General.BorderInset },
    }

    if not MilaUI.BossFrames then return end
    
    for _, BossFrame in ipairs(MilaUI.BossFrames) do
        
        if BossFrame.unitBorder then
            BossFrame.unitBorder:SetAllPoints()
            BossFrame.unitBorder:SetBackdrop(BackdropTemplate)
            BossFrame.unitBorder:SetBackdropColor(0,0,0,0)
            BossFrame.unitBorder:SetBackdropBorderColor(unpack(General.BorderColour))
        end

        if BossFrame.unitHealthBar then
            local BF = BossFrame.unitHealthBar
            local PlayerClassColour = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
            if General.ColourByClass then
                BF:SetStatusBarColor(PlayerClassColour.r, PlayerClassColour.g, PlayerClassColour.b)
            else 
                BF:SetStatusBarColor(unpack(General.ForegroundColour))
            end
            BF:SetMinMaxValues(0, 100)
            BF:SetValue(math.random(20, 50))
            if BossFrame.unitHealthBarBackground then
                BossFrame.unitHealthBarBackground:SetSize(Frame.Width - 2, Frame.Height - 2)
                BossFrame.unitHealthBarBackground:SetPoint("TOPLEFT", BossFrame, "TOPLEFT", 1, -1)
                BossFrame.unitHealthBarBackground:SetTexture(General.BackgroundTexture)
                BossFrame.unitHealthBarBackground:SetAlpha(General.BackgroundColour[4])
                if General.ColourBackgroundByReaction then
                    BossFrame.unitHealthBarBackground:SetVertexColor(PlayerClassColour.r * General.BackgroundMultiplier, PlayerClassColour.g * General.BackgroundMultiplier, PlayerClassColour.b * General.BackgroundMultiplier)
                else
                    BossFrame.unitHealthBarBackground:SetVertexColor(unpack(General.BackgroundColour))
                end
            end
        end

        if BossFrame.unitAbsorbs then
            local BF = BossFrame.unitAbsorbs
            BF:SetStatusBarColor(unpack(Absorbs.Colour))
            BF:SetMinMaxValues(0, 100)
            BF:SetValue(math.random(20, 50))
            BF:Show()
        end

        if BossFrame.unitHealAbsorbs then
            local BF = BossFrame.unitHealAbsorbs
            BF:SetStatusBarColor(unpack(HealAbsorbs.Colour))
            BF:SetMinMaxValues(0, 100)
            BF:SetValue(math.random(20, 50))
            BF:Show()
        end

        if BossFrame.unitPowerBar then
            local BF = BossFrame.unitPowerBar
            BF:SetStatusBarColor(unpack(General.CustomColours.Power[0]))
            BF:SetMinMaxValues(0, 100)
            BF:SetValue(math.random(20, 50))
            if BF.Background then
                BF.Background:SetAllPoints()
                BF.Background:SetTexture(General.BackgroundTexture)
                if PowerBar.ColourBackgroundByType then
                    local PBGR, PBGG, PBGB = unpack(General.CustomColours.Power[0])
                    BF.Background:SetVertexColor(PBGR * PowerBar.BackgroundMultiplier, PBGG * PowerBar.BackgroundMultiplier, PBGB * PowerBar.BackgroundMultiplier)
                else
                    BF.Background:SetVertexColor(unpack(PowerBar.BackgroundColour))
                end
            end
        end

        if BossFrame.unitPortrait then
            local BF = BossFrame.unitPortrait
            local PortraitOptions = {
                [1] = "achievement_character_human_female",
                [2] = "achievement_character_human_male",
                [3] = "achievement_character_dwarf_male",
                [4] = "achievement_character_dwarf_female"
            }
            BF:SetTexture("Interface\\ICONS\\" .. PortraitOptions[math.random(1, #PortraitOptions)])
        end
        
        if BossFrame.unitFirstText then
            local BF = BossFrame.unitFirstText
            BF:SetText("Boss " .. _)
        end

        if BossFrame.unitSecondText then
            local BF = BossFrame.unitSecondText
            BF:SetText(MilaUI:FormatLargeNumber(math.random(1e3, 1e6)))
        end

        if BossFrame.unitTargetMarker then
            local BF = BossFrame.unitTargetMarker
            BF:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
        end

        if not MilaUI.DB.profile.TestMode then
            BossFrame:SetAttribute("unit", "boss" .. _)
            RegisterUnitWatch(BossFrame)
            BossFrame:Hide()
        else
            BossFrame:SetAttribute("unit", nil)
            UnregisterUnitWatch(BossFrame)
            BossFrame:Show()
        end
    end
end

function MilaUI:GetFontJustification(AnchorTo)
    if AnchorTo == "TOPLEFT" or AnchorTo == "BOTTOMLEFT" or AnchorTo == "LEFT" then return "LEFT" end
    if AnchorTo == "TOPRIGHT" or AnchorTo == "BOTTOMRIGHT" or AnchorTo == "RIGHT" then return "RIGHT" end
    if AnchorTo == "TOP" or AnchorTo == "BOTTOM" or AnchorTo == "CENTER" then return "CENTER" end
end

function MilaUI:RegisterTargetHighlightFrame(frame, unit)
    if not frame then return end
    table.insert(MilaUI.TargetHighlightEvtFrames, { frame = frame, unit = unit })
end

function MilaUI:UpdateTargetHighlight(frame, unit)
    if frame and frame.unitIsTargetIndicator then
        if UnitIsUnit("target", unit) then
            frame.unitIsTargetIndicator:Show()
        else
            frame.unitIsTargetIndicator:Hide()
        end
    end
end
