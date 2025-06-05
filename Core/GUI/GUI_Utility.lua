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

function MilaUI:GenerateLSMFonts()
    local Fonts = LSM:HashTable("font")
    for Path, Font in pairs(Fonts) do
        LSMFonts[Font] = Path
    end
    return LSMFonts
end

function MilaUI:GenerateLSMBorders()
    local Borders = LSM:HashTable("border")
    for Path, Border in pairs(Borders) do
        LSMBorders[Border] = Path
    end
    return LSMBorders
end

function MilaUI:GenerateLSMTextures()
    local Textures = LSM:HashTable("statusbar")
    for Path, Texture in pairs(Textures) do
        LSMTextures[Texture] = Path
    end
    return LSMTextures
end

function MilaUI:CreateSlider(label, min, max, step, value, callback, width, parent)
    local slider = GUI:Create("Slider")
    slider:SetLabel(label)
    slider:SetSliderValues(min, max, step)
    slider:SetValue(value)
    slider:SetCallback("OnMouseUp", callback)
    slider:SetRelativeWidth(width or 0.25)
    if parent then parent:AddChild(slider) end
    return slider

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



function MilaUI:UpdateFrames()
    MilaUI:LoadCustomColours()
    if self.PlayerFrame then
        MilaUI:UpdateUnitFrame(self.PlayerFrame)
    end
    if self.TargetFrame then
        MilaUI:UpdateUnitFrame(self.TargetFrame)
    end
    if self.FocusFrame then
        MilaUI:UpdateUnitFrame(self.FocusFrame)
    end
    if self.FocusTargetFrame then
        MilaUI:UpdateUnitFrame(self.FocusTargetFrame)
    end
    if self.PetFrame then
        MilaUI:UpdateUnitFrame(self.PetFrame)
    end
    if self.TargetTargetFrame then
        MilaUI:UpdateUnitFrame(self.TargetTargetFrame)
    end
    MilaUI:UpdateBossFrames()
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

-- Helper function to create tab buttons for the main GUI
function MilaUI:CreateTabButton(text, value, parentFrame, position)
    local button = CreateFrame("Button", "MilaUI_Tab_"..value, parentFrame, "UIPanelButtonTemplate")
    button:SetPoint(position, parentFrame, "BOTTOMLEFT", 0, -30)
    button:SetFrameStrata("FULLSCREEN")
    button:SetHeight(40)
    button:SetWidth(120) -- Default width
    button:SetText(text)
    return button
end

-- Function to update button states in tab groups
function MilaUI:UpdateTabButtonStates(activeButton, allButtons)
    for _, btn in ipairs(allButtons) do
        if btn == activeButton then
            btn:SetEnabled(false) -- Disable the active button
        else
            btn:SetEnabled(true)
        end
    end
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

-- Helper function to create a small header
function MilaUI:CreateSmallHeader(text, fontSize, relWidth)
    local header = MilaUI_GUI:Create("Label")
    header:SetText(text)
    header:SetFont("Interface\\AddOns\\Mila_UI\\Media\\Fonts\\Expressway.ttf", fontSize or 14, "OUTLINE")
    header:SetRelativeWidth(relWidth or 1)
    header:SetFullWidth(true)
    header:SetText(pink .. text)

    if relativeWidth then
        print("DEBUG: Setting relative width to " .. relativeWidth)
        header:SetRelativeWidth(relativeWidth)
    else
        print("DEBUG: Setting full width")
        header:SetFullWidth(true)
    end

    fontSize = fontSize or 14
    print("DEBUG: Setting font size to " .. fontSize)
    if header.label and header.label.SetFont then
        local font, _, flags = header.label:GetFont()
        header.label:SetFont(font, fontSize, flags)
    end

    return header
end

-- Helper function to create a properly sized scrollframe with a container
function MilaUI:CreateProperScrollFrame(parent, minHeight)
    minHeight = minHeight or 500 -- Default minimum height
    
    -- Create a container to hold the scrollframe
    local container = MilaUI_GUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container:SetLayout("Fill")
    if parent then parent:AddChild(container) end
    
    -- Set minimum height for the container
    if container.frame and container.frame.SetMinResize then
        container.frame:SetMinResize(200, minHeight)
    end
    
    -- Create the scrollframe inside the container
    local scrollFrame = MilaUI_GUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
    
    -- Ensure the scrollframe has a minimum height
    if scrollFrame.frame and scrollFrame.frame.SetMinResize then
        scrollFrame.frame:SetMinResize(200, minHeight)
    end
    
    -- Make sure content area is properly sized
    if scrollFrame.content then
        scrollFrame.content:SetHeight(minHeight)
    end
    
    return scrollFrame
end

function MilaUI:UpdateEscapeMenuScale()
    if MilaUI.DB.global.GameMenuScale ~= 1 then GameMenuFrame:SetScale(MilaUI.DB.global.GameMenuScale) end
end