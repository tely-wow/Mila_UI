local _, MilaUI = ...
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local MilaUI_GUI = LibStub("AceGUI-3.0")
local LSMFonts = {}
local LSMBorders = {}
local LSMTextures = {}
local CopyFrom = {
    ["Player"] = "Player",
    ["Target"] = "Target",
    ["Focus"] = "Focus",
    ["FocusTarget"] = "Focus Target",
    ["Pet"] = "Pet",
    ["TargetTarget"] = "Target Target",
}
local GUI = MilaUI_GUI
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"


function MilaUI:GenerateLSMBorders()
    local Borders = LSM:HashTable("border")
    for Path, Border in pairs(Borders) do
        LSMBorders[Border] = Path
    end
    return LSMBorders
end


function MilaUI:CreateInlineGroup(title, parent)
    local group = GUI:Create("InlineGroup")
    group:SetTitle(pink .. title)
    group.titletext:SetFontObject(GameFontNormalLarge)
    group:SetLayout("Flow")
    group:SetFullWidth(true)
    if parent then parent:AddChild(group) end
    return group
end

function MilaUI:CreateColorPicker(label, colorTable, callback, width, hasAlpha, parent)
    local picker = GUI:Create("ColorPicker")
    picker:SetLabel(label)
    local r, g, b, a = unpack(colorTable or {1, 1, 1, 1})
    picker:SetColor(r, g, b, a)
    picker:SetCallback("OnValueChanged", callback)
    picker:SetHasAlpha(hasAlpha or false)
    picker:SetRelativeWidth(width or 0.25)
    if parent then parent:AddChild(picker) end
    return picker
end

function MilaUI:CreateCheckBox(label, value, callback, width, parent)
    local checkbox = GUI:Create("CheckBox")
    checkbox:SetLabel(label)
    checkbox:SetValue(value)
    checkbox:SetCallback("OnValueChanged", callback)
    checkbox:SetRelativeWidth(width or 0.25)
    if parent then parent:AddChild(checkbox) end
    return checkbox
end

function MilaUI:CreateDropdown(label, list, value, callback, width, parent)
    local dropdown = GUI:Create("Dropdown")
    dropdown:SetLabel(label)
    dropdown:SetList(list)
    dropdown:SetValue(value)
    dropdown:SetCallback("OnValueChanged", callback)
    dropdown:SetRelativeWidth(width or 0.25)
    if parent then parent:AddChild(dropdown) end
    return dropdown
end



-- UpdateFrames function has been moved to GUI_AF_Utility.lua

function MilaUI:UpdateIndicator()
    if self.PlayerFrame then
        MilaUI:UpdateIndicators(self.PlayerFrame)
    end
    if self.TargetFrame then
        MilaUI:UpdateIndicators(self.TargetFrame)
    end
    if self.FocusFrame then
        MilaUI:UpdateIndicators(self.FocusFrame)
    end
    if self.FocusTargetFrame then
        MilaUI:UpdateIndicators(self.FocusTargetFrame)
    end
    if self.PetFrame then
        MilaUI:UpdateIndicators(self.PetFrame)
    end
    if self.TargetTargetFrame then
        MilaUI:UpdateIndicators(self.TargetTargetFrame)
    else
        MilaUI:UpdateBossFrames()
    end
end

function MilaUI:UpdateFrameScale()
    if self.PlayerFrame then
        local Frame = MilaUI.DB.profile.Unitframes.Player.Frame
        if Frame and Frame.CustomScale and Frame.Scale then
            MilaUI_Player:SetScale(Frame.Scale)
        end
    end
    if self.TargetFrame then
        local Frame = MilaUI.DB.profile.Unitframes.Target.Frame
        if Frame and Frame.CustomScale and Frame.Scale then
            self.TargetFrame:SetScale(Frame.Scale)
        end
    end
    if self.FocusFrame then
        local Frame = MilaUI.DB.profile.Unitframes.Focus.Frame
        if Frame and Frame.CustomScale and Frame.Scale then
            self.FocusFrame:SetScale(Frame.Scale)
        end
    end
    if self.FocusTargetFrame then
        local Frame = MilaUI.DB.profile.Unitframes.FocusTarget.Frame
        if Frame and Frame.CustomScale and Frame.Scale then
            self.FocusTargetFrame:SetScale(Frame.Scale)
        end
    end
    if self.PetFrame then
        local Frame = MilaUI.DB.profile.Unitframes.Pet.Frame
        if Frame and Frame.CustomScale and Frame.Scale then
            self.PetFrame:SetScale(Frame.Scale)
        end
    end
    if self.TargetTargetFrame then
        local Frame = MilaUI.DB.profile.Unitframes.TargetTarget.Frame
        if Frame and Frame.CustomScale and Frame.Scale then
            self.TargetTargetFrame:SetScale(Frame.Scale)
        end
    end
end

-- This function updates the frame position based on the unit name
function MilaUI:UpdateFramePosition(unitName)
    if not unitName or not MilaUI.DB.profile.Unitframes[unitName] then
        return
    end
    
    local frameObj = MilaUI:GetFrameForUnit(unitName)
    
    if frameObj then
        local Frame = MilaUI.DB.profile.Unitframes[unitName].Frame
        local AnchorParent = _G[Frame.AnchorParent] or UIParent
        frameObj:ClearAllPoints()
        frameObj:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    end
end

-- This function updates the health bar size based on the unit name
function MilaUI:UpdateHealthBarSize(unitName)
    if not unitName or not MilaUI.DB.profile.Unitframes[unitName] then
        return
    end
    
    local frameObj = MilaUI:GetFrameForUnit(unitName)
    
    if frameObj and frameObj.unitHealthBar then
        local Health = MilaUI.DB.profile.Unitframes[unitName].Health
        frameObj.unitHealthBar:SetSize(Health.Width - 2, Health.Height - 2)
    end
end

function MilaUI:UpdateCastbarSize(unitName)
    if not unitName or not MilaUI.DB.profile.Unitframes[unitName] then
        return
    end

    local frameObj = MilaUI:GetFrameForUnit(unitName)
    if frameObj and frameObj.Castbar then
        local castbarSettings = MilaUI.DB.profile.Unitframes[unitName].Castbar
        if castbarSettings.width and castbarSettings.height then
            frameObj.Castbar:SetSize(castbarSettings.width, castbarSettings.height)
        end
    end
end


function MilaUI:UpdateCastbarPosition(unitName)
    -- Debug print
    print("UpdateCastbarPosition called for unit: " .. (unitName or "nil"))
    
    if not unitName or not MilaUI.DB.profile.Unitframes[unitName] then
        print("Error: Invalid unitName or missing DB entry")
        return
    end
    
    local frameObj = MilaUI:GetFrameForUnit(unitName)
    
    print("frameObj found: " .. (frameObj and "yes" or "no"))
    print("frameObj.Castbar exists: " .. (frameObj and frameObj.Castbar and "yes" or "no"))
    
    if frameObj and frameObj.Castbar then
        local castbarSettings = MilaUI.DB.profile.Unitframes[unitName].Castbar
        if castbarSettings.position then
            local pos = castbarSettings.position
            
            print("Position settings:")
            print("  anchorFrom: " .. (pos.anchorFrom or "nil"))
            print("  anchorTo: " .. (pos.anchorTo or "nil"))
            print("  anchorParent: " .. (pos.anchorParent or "nil"))
            print("  xOffset: " .. (pos.xOffset or "nil"))
            print("  yOffset: " .. (pos.yOffset or "nil"))
            
            -- Improved anchor parent handling
            local relativeTo = frameObj
            if pos.anchorParent and type(pos.anchorParent) == "string" then
                -- Try global frame reference first
                local frameRef = _G[pos.anchorParent]
                print("Global frame reference found: " .. (frameRef and "yes" or "no"))
                if frameRef then
                    relativeTo = frameRef
                    print("Using global frame reference: " .. pos.anchorParent)
                elseif frameObj[pos.anchorParent] then
                    -- Try as a child of the frame object
                    relativeTo = frameObj[pos.anchorParent]
                    print("Using child frame reference: " .. pos.anchorParent)
                else
                    print("Could not find frame reference for: " .. pos.anchorParent)
                end
            end
            
            -- Safety check to ensure we have a valid frame
            if not relativeTo or type(relativeTo) ~= "table" or not relativeTo.SetPoint then
                print("WARNING: Invalid relativeTo frame, falling back to frameObj or UIParent")
                relativeTo = frameObj or UIParent
            end
            
            print("relativeTo type: " .. type(relativeTo))
            print("relativeTo has SetPoint: " .. (relativeTo.SetPoint and "yes" or "no"))
            
            -- Store the current visibility state
            local wasShown = frameObj.Castbar:IsShown()
            print("Castbar was shown: " .. (wasShown and "yes" or "no"))
            
            -- Show the castbar temporarily to ensure proper positioning
            if not wasShown then
                print("Temporarily showing castbar")
                frameObj.Castbar:Show()
            end
            
            print("Clearing all points")
            frameObj.Castbar:ClearAllPoints()
            
            print("Setting point: " .. pos.anchorFrom .. ", " .. pos.anchorTo .. ", " .. pos.xOffset .. ", " .. pos.yOffset)
            frameObj.Castbar:SetPoint(pos.anchorFrom, relativeTo, pos.anchorTo, pos.xOffset, pos.yOffset)
            
            -- Restore the original visibility state
            if not wasShown then
                print("Hiding castbar again")
                frameObj.Castbar:Hide()
            end
        else
            print("Error: Missing position settings")
        end
    else
        print("Error: Missing frameObj or frameObj.Castbar")
    end
end

function MilaUI:UpdateCastbarAppearance(unitName)
    if not unitName or not MilaUI.DB.profile.Unitframes[unitName] then
        return
    end
    
    local frameObj = MilaUI:GetFrameForUnit(unitName)
    
    if frameObj and frameObj.Castbar then
        local castbar = frameObj.Castbar
        local settings = MilaUI.DB.profile.Unitframes[unitName].Castbar
        local generalSettings = MilaUI.DB.profile.Unitframes.General.CastbarSettings
        
        -- Update size
        castbar:SetSize(settings.width, settings.height)
        
        -- Update position
        self:UpdateCastbarPosition(unitName)
        
        -- Update scale if enabled
        if settings.CustomScale then
            castbar:SetScale(settings.Scale)
        else
            castbar:SetScale(1)
        end
        
        -- Update texture
        local texturePath = LSM:Fetch("statusbar", settings.texture) or LSM:GetDefault("statusbar")
        castbar:SetStatusBarTexture(texturePath)
        if castbar.bg then
            castbar.bg:SetTexture(texturePath)
            castbar.bg:SetVertexColor(unpack(settings.backgroundColor))
        end
        
        -- Update colors
        local textures = settings.textures or {}
        local castColor = textures.castcolor or {1, 0.7, 0, 1}
        local channelColor = textures.channelcolor or {0, 0.7, 1, 1}
        local uninterruptibleColor = textures.uninterruptiblecolor or {0.7, 0, 0, 1}
        local failedColor = textures.failedcolor or {1, 0.3, 0.3, 1}

        if castbar.isNonInterruptible then
            castbar:SetStatusBarColor(unpack(uninterruptibleColor))
            if castbar.Shield then castbar.Shield:Show() end
        else
            if castbar.isChanneling then
                castbar:SetStatusBarColor(unpack(channelColor))
            else
                castbar:SetStatusBarColor(unpack(castColor))
            end
            if castbar.Shield then castbar.Shield:Hide() end
        end
        -- Optionally store for failed/interrupted appearance
        castbar._castbarColors = {
            cast = castColor,
            channel = channelColor,
            uninterruptible = uninterruptibleColor,
            failed = failedColor
        }
        
        -- Update custom mask if enabled
        if settings.CustomMask and settings.CustomMask.Enabled and castbar.Mask then
            castbar.Mask:SetTexture(settings.CustomMask.MaskTexture)
            castbar.Mask:Show()
        elseif castbar.Mask then
            castbar.Mask:Hide()
        end
        
        -- Update custom border if enabled
        if settings.CustomBorder and settings.CustomBorder.Enabled and castbar.Border then
            castbar.Border:SetTexture(settings.CustomBorder.BorderTexture)
            castbar.Border:Show()
        elseif castbar.Border then
            castbar.Border:Hide()
        end

        -- Update font, font size, and font flags for castbar text and time
        if castbar.Text then
            local fontPath = LSM:Fetch("font", settings.font or "Expressway") or STANDARD_TEXT_FONT
            local textsize = settings.text and settings.text.textsize or 12
            print("[Castbar] Setting main text font size:", textsize)
            castbar.Text:SetFont(fontPath, textsize, settings.fontFlags or "OUTLINE")
        end
        if castbar.Time then
            local fontPath = LSM:Fetch("font", settings.font or "Expressway") or STANDARD_TEXT_FONT
            local timesize = settings.text and settings.text.timesize or 12
            print("[Castbar] Setting time font size:", timesize)
            castbar.Time:SetFont(fontPath, timesize, settings.fontFlags or "OUTLINE")
        end
    end
end

function MilaUI:UpdateAllCastbars()
    for _, unit in ipairs(MilaUI.UnitList) do
        self:UpdateCastbarAppearance(unit)
    end
    for i = 1, MAX_BOSS_FRAMES do
        self:UpdateCastbarAppearance("Boss" .. i)
    end
end

function MilaUI:ReOpenGUI()
    -- Use the public functions instead of trying to access mainFrame directly
    MilaUI_CloseGUIMain()
    MilaUI_OpenGUIMain()
end

function MilaUI:CreateReloadPrompt()
    StaticPopupDialogs["MilaUI_RELOAD_PROMPT"] = {
        text = "Reload is necessary for changes to take effect. Reload Now?",
        button1 = "Reload",
        button2 = "Later",
        OnAccept = function() ReloadUI() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("MilaUI_RELOAD_PROMPT")
end

function MilaUI:UpdateUIScale()
    if not MilaUI.DB.global.UIScaleEnabled then return end
    UIParent:SetScale(MilaUI.DB.global.UIScale)
end

function MilaUI:GenerateCopyFromList(Unit)
    local CopyFromList = {}
    for k, v in pairs(CopyFrom) do
        if k ~= Unit then
            CopyFromList[k] = v
        end
    end
    return CopyFromList
end

function MilaUI:CopyUnit(sourceUnit, targetUnit)
    if type(sourceUnit) ~= "table" or type(targetUnit) ~= "table" then return end
    for key, targetValue in pairs(targetUnit) do
        local sourceValue = sourceUnit[key]
        if type(targetValue) == "table" and type(sourceValue) == "table" then
            MilaUI:CopyUnit(sourceValue, targetValue)
        elseif sourceValue ~= nil then
            targetUnit[key] = sourceValue
        end
    end
    MilaUI:UpdateFrames()
    MilaUI:CreateReloadPrompt()
end

function MilaUI:ResetColours()
    local General = MilaUI.DB.profile.Unitframes.General
    wipe(General.CustomColours)
    General.CustomColours = {
        Reaction = {
            [1] = {255/255, 64/255, 64/255},            -- Hated
            [2] = {255/255, 64/255, 64/255},            -- Hostile
            [3] = {255/255, 128/255, 64/255},           -- Unfriendly
            [4] = {255/255, 255/255, 64/255},           -- Neutral
            [5] = {64/255, 255/255, 64/255},            -- Friendly
            [6] = {64/255, 255/255, 64/255},            -- Honored
            [7] = {64/255, 255/255, 64/255},            -- Revered
            [8] = {64/255, 255/255, 64/255},            -- Exalted
        },
        Power = {
            [0] = {0, 0, 1},            -- Mana
            [1] = {1, 0, 0},            -- Rage
            [2] = {1, 0.5, 0.25},       -- Focus
            [3] = {1, 1, 0},            -- Energy
            [6] = {0, 0.82, 1},         -- Runic Power
            [8] = {0.3, 0.52, 0.9},     -- Lunar Power
            [11] = {0, 0.5, 1},         -- Maelstrom
            [13] = {0.4, 0, 0.8},       -- Insanity
            [17] = {0.79, 0.26, 0.99},  -- Fury
            [18] = {1, 0.61, 0}         -- Pain
        },
        Status = {
            [1] = {255/255, 64/255, 64/255},           -- Dead
            [2] = {153/255, 153/255, 153/255}, -- Tapped 
            [3] = {0.6, 0.6, 0.6}, -- Disconnected
        }
    }
    MilaUI:UpdateFrames()
end

function MilaUI:UnlockFrame(frame)
    if not frame or type(frame.SetMovable) ~= "function" then
        return
    end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
          self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
          self:StopMovingOrSizing()
    end)
    
    -- Also unlock the castbar if it exists
    if frame.Castbar then
        local castbar = frame.Castbar
        castbar:SetMovable(true)
        castbar:EnableMouse(true)
        castbar:RegisterForDrag("LeftButton")
        castbar:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        castbar:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
    end
 end
 
 function MilaUI:LockFrame(frame)
    if not frame or type(frame.SetMovable) ~= "function" then
        return
    end
   
    local frameName = frame:GetName()
    if frameName then
        local unitType = frameName:match("MilaUI_(%a+)")
       
        if unitType and MilaUI.DB and MilaUI.DB.profile and MilaUI.DB.profile.Unitframes and MilaUI.DB.profile.Unitframes[unitType] and MilaUI.DB.profile.Unitframes[unitType].Frame then
            local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
            if point then
                -- Debug: Show current anchor info
                local parentName = relativeTo and relativeTo:GetName() or "nil"
                MilaUI.DB.profile.Unitframes[unitType].Frame.XPosition = xOfs
                MilaUI.DB.profile.Unitframes[unitType].Frame.YPosition = yOfs
                MilaUI.DB.profile.Unitframes[unitType].Frame.AnchorFrom = point
                MilaUI.DB.profile.Unitframes[unitType].Frame.AnchorTo = relativePoint
               
                if relativeTo and type(relativeTo.GetName) == "function" then
                    MilaUI.DB.profile.Unitframes[unitType].Frame.AnchorParent = relativeTo:GetName()
                else
                    MilaUI.DB.profile.Unitframes[unitType].Frame.AnchorParent = "UIParent"
                end
            end
            
            -- Also save castbar position if it exists
            if frame.Castbar and MilaUI.DB.profile.Unitframes[unitType].Castbar then
                local castbar = frame.Castbar
                local castPoint, castRelativeTo, castRelativePoint, castXOfs, castYOfs = castbar:GetPoint()
                if castPoint then
                    local castSettings = MilaUI.DB.profile.Unitframes[unitType].Castbar
                    if not castSettings.position then
                        castSettings.position = {}
                    end
                    
                    castSettings.position.xOffset = castXOfs
                    castSettings.position.yOffset = castYOfs
                    castSettings.position.anchorFrom = castPoint
                    castSettings.position.anchorTo = castRelativePoint
                    
                    if castRelativeTo and type(castRelativeTo.GetName) == "function" then
                        castSettings.position.anchorParent = castRelativeTo:GetName()
                    else
                        castSettings.position.anchorParent = "UIParent"
                    end
                end
                
                -- Lock the castbar
                castbar:SetMovable(false)
                castbar:SetScript("OnDragStart", nil)
                castbar:SetScript("OnDragStop", nil)
            end
        end
    end
   
    frame:SetMovable(false)
    frame:SetScript("OnDragStart", nil)
    frame:SetScript("OnDragStop", nil)
end

function MilaUI:LockFrames()
    local globalFrameNames = {
        "MilaUI_Player", 
        "MilaUI_Target",
        "MilaUI_Focus",
        "MilaUI_FocusTarget",
        "MilaUI_Pet",
        "MilaUI_TargetTarget"
    }
    local framesToProcess = {}
    for i, name in ipairs(globalFrameNames) do
        local frame = _G[name]
        table.insert(framesToProcess, frame)
    end
    for i, actualFrame in ipairs(framesToProcess) do
        local frameDisplayName = globalFrameNames[i]
        local frameNameForLog = "Frame (originally " .. frameDisplayName .. ") (Type: " .. type(actualFrame) .. ")"
        if actualFrame and type(actualFrame.GetName) == "function" then
            frameNameForLog = actualFrame:GetName() .. " (originally " .. frameDisplayName .. ")"
        end

        if actualFrame and type(actualFrame.SetMovable) == "function" then
            MilaUI:LockFrame(actualFrame)
        end
    end
    if MilaUI.BossFrames then
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                MilaUI:LockFrame(bossFrameContainer.frame)
            end
        end
    end
    MilaUI:UpdateFrames()
end

function MilaUI:UnlockFrames()
    local globalFrameNames = {
        "MilaUI_Player", 
        "MilaUI_Target",
        "MilaUI_Focus",
        "MilaUI_FocusTarget",
        "MilaUI_Pet",
        "MilaUI_TargetTarget"
    }
    local framesToProcess = {}
    for i, name in ipairs(globalFrameNames) do
        local frame = _G[name]
        table.insert(framesToProcess, frame)
    end

    for i, actualFrame in ipairs(framesToProcess) do
        local frameDisplayName = globalFrameNames[i]
        if actualFrame and type(actualFrame.SetMovable) == "function" then
            MilaUI:UnlockFrame(actualFrame)
        end
    end

    if MilaUI.BossFrames then
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                MilaUI:UnlockFrame(bossFrameContainer.frame)
            end
        end
    end
end

function MilaUI:CreateVerticalSpacer(height, parent)
    local spacer = MilaUI_GUI:Create("Label")
    spacer:SetText("\n") -- One or more newlines to create vertical height
    spacer:SetFullWidth(true)

    -- Use font trick to stretch vertical space
    local font, _, flags = spacer.label:GetFont()
    spacer.label:SetFont(font, height or 14, flags)

    if parent then 
        parent:AddChild(spacer) 
    end
    return spacer
end

-- Helper: Create a horizontal spacer for AceGUI layouts
function MilaUI:CreateHorizontalSpacer(width, parent)
    -- Create a simple group instead of a label for more reliable spacing
    local spacer = MilaUI_GUI:Create("SimpleGroup")
    spacer:SetLayout("Flow")
    spacer:SetRelativeWidth(width or 0.1)
    spacer:SetHeight(1)
    
    -- Add to parent if provided (only once!)
    if parent then 
        -- Use pcall to safely add the child and catch any errors
        local success, errorMsg = pcall(function()
            parent:AddChild(spacer)
        end)
    end
    
    return spacer
end

-- Helper function to map UI unit names to database unit names
function MilaUI:GetUnitDatabaseKey(unitName)
    -- Map UI display names to database keys
    local unitMap = {
        ["Target of Target"] = "TargetTarget",
        ["Focus Target"] = "FocusTarget",
        ["Boss Frames"] = "Boss",
        ["Boss"] = "Boss",
        ["FocusTarget"] = "FocusTarget"
    }
    
    -- Return the mapped name or the original if no mapping exists
    return unitMap[unitName] or unitName
end

-- Helper function to create a large heading with custom font size
function MilaUI:CreateLargeHeading(text, parent, fontSize)
    local heading = MilaUI_GUI:Create("SFX-Header")
    heading:SetText(pink .. text)
    heading:SetFullWidth(true)
    heading:SetCenter(true)
    -- Set font size using the simpler approach
    fontSize = fontSize or 16 -- Default to 16 if not specified
    local label = heading.Label
    if label and label.SetFont then
        local font, _, flags = label:GetFont()
        label:SetFont(font, fontSize, flags)
    end
    
    -- Create a container to hold both the heading and the spacer
    local container = MilaUI_GUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)
    
    -- Add the heading to the container
    container:AddChild(heading)
    
    
    -- Add the container to the parent if provided
    if parent then 
        parent:AddChild(container) 
    end
    
    return container
end

function MilaUI:UpdateEscapeMenuScale()
    if MilaUI.DB.global.GameMenuScale ~= 1 then GameMenuFrame:SetScale(MilaUI.DB.global.GameMenuScale) end
end
