local _, MilaUI = ...
local AF = _G.AbstractFramework or LibStub("AbstractFramework-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- Color constants
local lavender = "|cffBFACE2"
local pink = "|cffFF9CD0"
local green = "|cff00FF00"
local red = "|cffFF0000"

-- State
local afMainFrame = nil
local currentTab = "general"
local moversLocked = true
local moverTestFrames = {}

-- Tab definitions
local tabs = {
    {key = "general", display = "General Settings", active = true},
    {key = "unitframes", display = "Unit Frames", active = false},
    {key = "castbars", display = "Cast Bars", active = false},
    {key = "cursormod", display = "Cursor Mod", active = false},
    {key = "profiles", display = "Profiles", active = false}
}

-- Unit frame list for movers (simplified for mover creation only)
local unitFrameList = {
    "Player", "Target", "Focus", "Pet", 
    "TargetTarget", "FocusTarget", "Boss"
}

local function SwitchToTab(tabKey)
    if currentTab == tabKey then return end
    
    currentTab = tabKey
    
    -- Update tab states
    for _, tab in ipairs(tabs) do
        tab.active = (tab.key == tabKey)
    end
    
    -- Refresh content
    MilaUI:RefreshAFGUIContent()
end

local function CreateTabContent(parent)
    -- Reset positioning for new content
    MilaUI.AF:ResetPositioning()
    
    -- Load appropriate content based on current tab using modular structure
    if currentTab == "general" then
        local content = MilaUI.AF:CreateContentArea(parent)
        local header = MilaUI.AF:CreateHeader(content.scrollContent, "GENERAL SETTINGS")
        MilaUI:CreateAFGeneralTab(content.scrollContent)
        content:SetContentHeight(1200)
        return content
    elseif currentTab == "unitframes" then
        return MilaUI:CreateAFUnitFramesLayout(parent)
    elseif currentTab == "castbars" then
        return MilaUI:CreateAFCastBarsLayout(parent)
    elseif currentTab == "cursormod" then
        local content = MilaUI.AF:CreateContentArea(parent)
        local header = MilaUI.AF:CreateHeader(content.scrollContent)
        MilaUI:CreateAFCursorModTab(content.scrollContent)
        content:SetContentHeight(1200)
        return content
    elseif currentTab == "profiles" then
        local content = MilaUI.AF:CreateContentArea(parent)
        local header = MilaUI.AF:CreateHeader(content.scrollContent, "PROFILE MANAGEMENT")
        MilaUI:CreateAFProfilesTab(content.scrollContent)
        content:SetContentHeight(1200)
        return content
    end
end

local function CreateTabButtons(parent)
    -- Update tab callbacks
    for _, tab in ipairs(tabs) do
        tab.callback = function()
            SwitchToTab(tab.key)
        end
    end
    
    local tabContainer, tabObjects = MilaUI.AF:CreateTabSystem(parent, tabs)
    return tabContainer
end

function MilaUI:CreateAFMainGUI()
    if afMainFrame then
        afMainFrame:Hide()
        afMainFrame = nil
    end
    
    afMainFrame = AF.CreateHeaderedFrame(AF.UIParent, "MilaUI_AF_MainGUI",
        "|TInterface\\AddOns\\Mila_UI\\Media\\logo.tga:16:16|t" .. 
        AF.GetGradientText(" Mila UI Settings (AF)", "pink", "lavender") .. 
        " |TInterface\\AddOns\\Mila_UI\\Media\\logo.tga:16:16|t",
        920, 720)
    afMainFrame:SetPoint("CENTER")
    afMainFrame:SetFrameLevel(500)
    afMainFrame:SetTitleJustify("CENTER")
    
    AF.ApplyCombatProtectionToFrame(afMainFrame)
    
    -- Store reference for color picker reparenting
    MilaUI.AF.mainFrame = afMainFrame
    
    -- Create lock/unlock button in top right corner
    local lockBtn = AF.CreateButton(afMainFrame, moversLocked and "Unlock Movers" or "Lock Movers", "pink", 120, 25)
    AF.SetPoint(lockBtn, "TOPRIGHT", afMainFrame, "TOPRIGHT", -20, -15)
    lockBtn:SetScript("OnClick", function()
        moversLocked = not moversLocked
        lockBtn:SetText(moversLocked and "Unlock Movers" or "Lock Movers")
        if moversLocked then
            AF.HideMovers()
        else
            CreateUnitFrameMovers()
        end
    end)
    
    afMainFrame.lockBtn = lockBtn
    
    -- Create tab system
    afMainFrame.tabFrame = CreateTabButtons(afMainFrame)
    afMainFrame.tabFrame:SetPoint("TOPLEFT", afMainFrame, "TOPLEFT", 20, -85)
    afMainFrame.tabFrame:SetPoint("TOPRIGHT", lockBtn, "TOPLEFT", -10, 0)
    
    -- Create content area
    afMainFrame.contentFrame = CreateTabContent(afMainFrame)
    afMainFrame.contentFrame:SetPoint("TOPLEFT", afMainFrame.tabFrame, "BOTTOMLEFT", 0, -10)
    afMainFrame.contentFrame:SetPoint("BOTTOMRIGHT", afMainFrame, "BOTTOMRIGHT", -20, 50)
    
    -- Create bottom buttons
    local closeBtn = AF.CreateButton(afMainFrame, "Close", "pink", 80, 25)
    closeBtn:SetPoint("BOTTOMRIGHT", afMainFrame, "BOTTOMRIGHT", -20, 15)
    closeBtn:SetOnClick(function()
        afMainFrame:Hide()
    end)
    
    local reloadBtn = AF.CreateButton(afMainFrame, "Reload UI", "lavender", 80, 25)
    reloadBtn:SetPoint("BOTTOMRIGHT", closeBtn, "BOTTOMLEFT", -10, 0)
    reloadBtn:SetOnClick(function()
        ReloadUI()
    end)
    
    local aceGUIBtn = AF.CreateButton(afMainFrame, "Open Ace GUI", "blue", 120, 25)
    aceGUIBtn:SetPoint("BOTTOMRIGHT", reloadBtn, "BOTTOMLEFT", -10, 0)
    aceGUIBtn:SetOnClick(function()
        MilaUI_OpenGUIMain()
    end)
    
    afMainFrame:Show()
end

function MilaUI:RefreshAFGUIContent()
    if not afMainFrame or not afMainFrame.contentFrame then return end
    
    afMainFrame.contentFrame:Hide()
    afMainFrame.contentFrame = CreateTabContent(afMainFrame)
    afMainFrame.contentFrame:SetPoint("TOPLEFT", afMainFrame.tabFrame, "BOTTOMLEFT", 0, -10)
    afMainFrame.contentFrame:SetPoint("BOTTOMRIGHT", afMainFrame, "BOTTOMRIGHT", -20, 50)
end

-- Function to create mover test frames for unit frames
local function CreateUnitFrameMovers()
    -- Clear existing movers
    for _, f in pairs(moverTestFrames) do
        if f then f:Hide() end
    end
    wipe(moverTestFrames)
    
    -- Create movers for each unit frame
    for i, unit in ipairs(unitFrameList) do
        if unit ~= "Tags" then -- Skip Tags entry for movers
            local f = AF.CreateBorderedFrame(AF.UIParent, nil, 120, 60)
            f:SetLabel(unit .. " Frame", "pink", nil, true)
            
            -- Position frames in a grid
            local col = (i - 1) % 5
            local row = math.floor((i - 1) / 5)
            AF.SetPoint(f, "TOPLEFT", AF.UIParent, "TOPLEFT", 50 + (col * 140), -50 - (row * 80))
            
            -- Create mover for this frame
            AF.CreateMover(f, "UnitFrames", unit .. " Mover", function(p, x, y)
                print("Mover " .. unit .. ":", p, x, y)
            end)
            
            tinsert(moverTestFrames, f)
            f:Show()
        end
    end
    
    -- Show all movers
    AF.ShowMovers("UnitFrames")
end


-- Slash commands for AF GUI
SLASH_MILAAF1 = "/mui2"
SLASH_MILAAF2 = "/muiaf"
SlashCmdList["MILAAF"] = function(msg)
    local command = strtrim(msg or ""):lower()
    
    if command == "general" then
        MilaUI:CreateAFMainGUI()
        SwitchToTab("general")
    elseif command == "unitframes" then
        MilaUI:CreateAFMainGUI()
        SwitchToTab("unitframes")
    elseif command == "castbars" then
        MilaUI:CreateAFMainGUI()
        SwitchToTab("castbars")
    elseif command == "cursormod" then
        MilaUI:CreateAFMainGUI()
        SwitchToTab("cursormod")
    elseif command == "profiles" then
        MilaUI:CreateAFMainGUI()
        SwitchToTab("profiles")
    else
        MilaUI:CreateAFMainGUI()
    end
end