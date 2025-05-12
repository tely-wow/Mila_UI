-- MilaUI GUI Initialization and Tab Content

local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0")
local MilaUI_GUI = GUI
local GUI_WIDTH = 920
local GUI_HEIGHT = 720
local GUI_TITLE = C_AddOns.GetAddOnMetadata("MilaUI", "Title")
local GUI_VERSION = C_AddOns.GetAddOnMetadata("MilaUI", "Version")
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
if LSM then LSM:Register("border", "WHITE8X8", [[Interface\Buttons\WHITE8X8]]) end
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"
-- State
local isOpen, mainFrame = false, nil

-- Expose AceGUI and localization
MilaUI.GUI = GUI
MilaUI.L   = MilaUI.L or {}
local L_strings = {
  Unitframes     = "Unitframes",   Tags    = "Tags",
  Profiles       = "Profiles",     General = "General",
  Player         = "Player",       Target  = "Target",
  Focus          = "Focus",        Pet     = "Pet",
  TargetTarget = "Target of Target", Boss = "Boss Frames",
  FocusTarget    = "Focus Target",
}
for k,v in pairs(L_strings) do
  MilaUI.L[k] = MilaUI.L[k] or v
end
local L = MilaUI.L

-- Draw placeholder methods
local function DrawPlaceholder(parent, text)
  local lbl = GUI:Create("Label")
  lbl:SetText(text .. " placeholder.")
  parent:AddChild(lbl)
end

-- Submenu handler
local submenuContainer
local function DrawSubmenuTabs(parent)
  -- Sub-tab buttons bar
  local subTabs = GUI:Create("TabGroup")
  subTabs:SetTabs({
    { text = "Colours", value = "Colours"},
    { text = "Player", value = "Player" },
    { text = "Target", value = "Target" },
    { text = "Focus", value = "Focus" },
    { text = "Pet", value = "Pet" },
    { text = "Target of Target", value = "Target of Target" },
    { text = "Focus Target", value = "Focus Target" },
    { text = "Boss", value = "Boss" },
  })
  subTabs:SetHeight(30)
  subTabs:SetFullWidth(true)
  subTabs:SetLayout("Flow")
  subTabs.frame:SetPoint("TOPLEFT", parent.frame, "TOPLEFT", 0, 0)
  subTabs.frame:SetPoint("TOPRIGHT", parent.frame, "TOPRIGHT", 0, 0)
  parent:AddChild(subTabs)

  -- Sub-content wrapper below sub-tabs
  local innerPanel = GUI:Create("SimpleGroup")
  innerPanel:SetLayout("Manual")
  innerPanel.frame:SetPoint("TOPLEFT", subTabs.frame, "BOTTOMLEFT", 0, -5)
  innerPanel.frame:SetPoint("BOTTOMRIGHT", parent.frame, "BOTTOMRIGHT", 0, 0)
  parent:AddChild(innerPanel)

  -- Settings content container
  submenuContainer = GUI:Create("SimpleGroup")
  submenuContainer:SetLayout("Fill")
  submenuContainer.frame:SetPoint("TOPLEFT", innerPanel.frame, "TOPLEFT", 5, 0)
  submenuContainer.frame:SetPoint("BOTTOMRIGHT", innerPanel.frame, "BOTTOMRIGHT", -5, 5)
  innerPanel:AddChild(submenuContainer)

  -- Callbacks
  subTabs:SetCallback("OnGroupSelected", function(_, _, unit)
    submenuContainer:ReleaseChildren()
    MilaUI:DrawUnitContainer(submenuContainer, unit)
  end)

  subTabs:SetCallback("OnGroupSelected", function(_, _, tabKey)
    submenuContainer:ReleaseChildren()
    MilaUI:DrawUnitContainer(submenuContainer, tabKey)
  end)

  subTabs:SelectTab("Player")
end

-- Main GUI creation
-- Make these variables global to the file so they can be accessed by ReOpenGUI
mainFrame = nil
mainTabs = nil
unitframesTabs = nil

function MilaUI:CreateGUIMain()
  if isOpen then return end
  isOpen = true
  local LSMFonts = LSM:HashTable(LSM.MediaType.FONT)
  local LSMTextures = LSM:HashTable(LSM.MediaType.STATUSBAR)
  -- Main frame
  mainFrame = GUI:Create("Frame")
  mainFrame:SetTitle(pink .. GUI_TITLE)
  mainFrame:SetLayout("Manual")
  mainFrame:SetWidth(GUI_WIDTH)
  mainFrame:SetHeight(GUI_HEIGHT)
  mainFrame:EnableResize(true)
  mainFrame:SetCallback("OnClose", function(widget)
    GUI:Release(widget)
    isOpen = false
  end)



  -- Create a container for the logo
  local logoGroup = GUI:Create("SimpleGroup")
  logoGroup:SetLayout("Manual")
  logoGroup:SetPoint("TOPLEFT", mainFrame.frame, "TOPLEFT", 8, -25)
  logoGroup:SetWidth(150)
  logoGroup:SetHeight(150)
  -- Add the logo texture to the logoGroup's frame
  local logo = logoGroup.frame:CreateTexture(nil, "ARTWORK")
  logo:SetTexture("Interface\\Addons\\Mila_UI\\Media\\logo.tga")
  logo:SetAllPoints()
  -- Add the logoGroup to the leftPanel as the first child
  mainFrame:AddChild(logoGroup)

  -- Create a label for the lock/unlock button
  local lockLabel = GUI:Create("Label")
  lockLabel:SetText(pink .. "Lock / Unlock Unit Frames")
  lockLabel:SetFontObject(GameFontNormal)
  lockLabel:SetFullWidth(false)
  lockLabel.frame:SetPoint("TOPLEFT", logoGroup.frame, "TOPRIGHT", 0, -20)
  mainFrame:AddChild(lockLabel)

  -- Create the lock/unlock button
  local function updateLockButtonText(btn)
    if MilaUI.DB.global.FramesLocked then
      btn:SetText("Unlock")
    else
      btn:SetText("Lock")
    end
  end

  local lockButton = GUI:Create("Button")
  updateLockButtonText(lockButton)
  lockButton:SetWidth(80)
  lockButton:SetCallback("OnClick", function(widget)
    MilaUI.DB.global.FramesLocked = not MilaUI.DB.global.FramesLocked
    if MilaUI.DB.global.FramesLocked then
      MilaUI:LockFrames()
      print(pink.."♥MILA UI ♥"..lavender.." Unitframes LOCKED!")
    else
      MilaUI:UnlockFrames()
      print(pink.."♥MILA UI ♥"..lavender.." Unitframes UNLOCKED!")
    end
    updateLockButtonText(widget)
  end)
  lockButton.frame:SetPoint("TOPLEFT", lockLabel.frame, "BOTTOMLEFT", 0, -2)
  mainFrame:AddChild(lockButton)





  -- Create the main content area first
  local contentPanel = GUI:Create("SimpleGroup")
  contentPanel:SetLayout("Flow")
  contentPanel:SetFullWidth(true)
  contentPanel.frame:SetPoint("TOPLEFT", logoGroup.frame, "BOTTOMLEFT", 10, -20)
  contentPanel.frame:SetPoint("BOTTOMRIGHT", mainFrame.frame, "BOTTOMRIGHT", -50, 60) -- Leave space at bottom for buttons
  mainFrame:AddChild(contentPanel)
  
  -- Create tab buttons at the bottom using native WoW UI buttons
  local currentTab = L.General -- Track the currently selected tab
  
  -- Create the buttons first without click handlers
  local buttonSpacing = 0
  
  -- Create all buttons first using the helper function from GUI_Utility.lua
  local generalButton = MilaUI:CreateTabButton(L.General, L.General, mainFrame.frame, "BOTTOMLEFT")
  local unitframesButton = MilaUI:CreateTabButton(L.Unitframes, L.Unitframes, mainFrame.frame, "BOTTOMLEFT")
  local tagsButton = MilaUI:CreateTabButton(L.Tags, L.Tags, mainFrame.frame, "BOTTOMLEFT")
  local profilesButton = MilaUI:CreateTabButton(L.Profiles, L.Profiles, mainFrame.frame, "BOTTOMLEFT")
  
  -- Position the buttons
  unitframesButton:ClearAllPoints()
  unitframesButton:SetPoint("LEFT", generalButton, "RIGHT", buttonSpacing, 0)
  
  tagsButton:ClearAllPoints()
  tagsButton:SetPoint("LEFT", unitframesButton, "RIGHT", buttonSpacing, 0)
  
  profilesButton:ClearAllPoints()
  profilesButton:SetPoint("LEFT", tagsButton, "RIGHT", buttonSpacing, 0)
  
  -- Store all buttons in a table for easier reference
  local allButtons = {generalButton, unitframesButton, tagsButton, profilesButton}
  
  -- Add click handlers for each button
  generalButton:SetScript("OnClick", function()
    currentTab = L.General
    MilaUI:UpdateTabButtonStates(generalButton, allButtons)
    contentPanel:ReleaseChildren()
    HandleGeneralTab(contentPanel)
  end)
  
  unitframesButton:SetScript("OnClick", function()
    currentTab = L.Unitframes
    MilaUI:UpdateTabButtonStates(unitframesButton, allButtons)
    contentPanel:ReleaseChildren()
    HandleUnitframesTab(contentPanel)
  end)
  
  tagsButton:SetScript("OnClick", function()
    currentTab = L.Tags
    MilaUI:UpdateTabButtonStates(tagsButton, allButtons)
    contentPanel:ReleaseChildren()
    DrawPlaceholder(contentPanel, L.Tags)
  end)
  
  profilesButton:SetScript("OnClick", function()
    currentTab = L.Profiles
    MilaUI:UpdateTabButtonStates(profilesButton, allButtons)
    contentPanel:ReleaseChildren()
    DrawPlaceholder(contentPanel, L.Profiles)
  end)
  
  -- Helper functions for tab content
  function HandleUnitframesTab(parent)
    -- Add a nested TabGroup for 'General' and 'Individual Frames'
    local unitframesTabs = GUI:Create("TabGroup")
    unitframesTabs:SetTabs({
      { text = "General", value = "General" },
      { text = "Individual Frames", value = "IndividualFrames" },
      { text = "Colours", value = "Colours" },
    })
    
    unitframesTabs:SetLayout("Fill")
    unitframesTabs:SetFullWidth(true)
    unitframesTabs:SetFullHeight(true)
    parent:AddChild(unitframesTabs)
    
    -- Set the callback for tab selection
    unitframesTabs:SetCallback("OnGroupSelected", function(container, _, subTab)
      -- The container parameter is the content area of the selected tab
      container:ReleaseChildren()
      
      -- Create a scroll frame inside the tab content area
      local contentFrame = GUI:Create("ScrollFrame")
      contentFrame:SetLayout("Flow")
      contentFrame:SetFullWidth(true)
      contentFrame:SetFullHeight(true)
      container:AddChild(contentFrame)
      
      -- Schedule a frame update to ensure scrollbar appears correctly
      C_Timer.After(0.1, function()
        if contentFrame and contentFrame.frame and contentFrame.scrollframe then
          -- Force scrollbar calculation
          contentFrame.scrollframe:UpdateScrollChildRect()
          contentFrame:DoLayout()
        end
      end)
      
      if subTab == "General" then
        MilaUI:DrawUnitframesGeneralTab(contentFrame)
      elseif subTab == "IndividualFrames" then
        -- Draw the unit frame tabs directly in the container (NO scrollframe)
        MilaUI:DrawUnitframesTabContent(container)
      elseif subTab == "Colours" then
        MilaUI:DrawUnitframesColoursTab(contentFrame)
      end
    end)
    
    -- Select the General tab by default
    unitframesTabs:SelectTab("General")
  end
  
  function HandleGeneralTab(parent)
    local General = MilaUI.DB.profile.General
    local UIScale = GUI:Create("InlineGroup")
    UIScale:SetLayout("Flow")
    UIScale:SetTitle(pink .. "Custom UI Scale")
    UIScale.titletext:SetFontObject(GameFontNormalLarge)
    UIScale:SetFullWidth(true)
    UIScale:SetHeight(20)
    -- Enable UI Scale checkbox
    local UIScaleToggle = GUI:Create("CheckBox")
    UIScaleToggle:SetLabel("Enable UI Scale")
    UIScaleToggle:SetValue(MilaUI.DB.global.UIScaleEnabled)
    UIScaleToggle:SetRelativeWidth(0.3)
    UIScale:AddChild(MilaUI:CreateHorizontalSpacer(0.02))
    UIScale:AddChild(UIScaleToggle)
    -- UIScale slider
    local UIScaleSlider = GUI:Create("Slider")
    UIScaleSlider:SetSliderValues(0.4, 2, 0.01)
    UIScaleSlider:SetValue(MilaUI.DB.global.UIScale)
    UIScaleSlider:SetWidth(200)
    UIScaleSlider:SetHeight(20)
    UIScaleSlider:SetCallback("OnMouseUp", function(widget, event, value)
      if value > 2 then value = 1 print(pink .. "♥MILA UI ♥: " .. lavender .. "UI Scale reset to 1. Maximum of 2 for UIScale.") end
      MilaUI.DB.global.UIScale = value
      MilaUI:UpdateUIScale()
      UIScaleSlider:SetValue(value)
    end)
    UIScale:AddChild(UIScaleSlider)
    UIScaleToggle:SetCallback("OnValueChanged", function(widget, event, value)
      MilaUI.DB.global.UIScaleEnabled = value
      if value then
        UIScaleSlider:SetDisabled(false)
        MilaUI:UpdateUIScale()
      else
        UIScaleSlider:SetDisabled(true)
        UIParent:SetScale(1)
      end
    end)
    if not MilaUI.DB.global.UIScaleEnabled then
      UIScaleSlider:SetDisabled(true)
    end
    parent:AddChild(UIScale)
    
    local FontOptions = GUI:Create("InlineGroup")
    FontOptions:SetLayout("Flow")
    FontOptions:SetTitle(pink .. "Font Options")
    FontOptions.titletext:SetFontObject(GameFontNormalLarge)
    FontOptions:SetFullWidth(true)
    FontOptions:SetHeight(20)
    parent:AddChild(FontOptions)
    
    local Font = MilaUI_GUI:Create("LSM30_Font")
    Font:SetLabel("Font")
    Font:SetList(LSMFonts)
    Font:SetValue(General.Font)
    -- NOTE: General.Font now stores the font key (e.g., "Friz Quadrata TT"). Always use LSM:Fetch("font", General.Font) when applying fonts!
    Font:SetCallback("OnValueChanged", function(widget, event, value)
      General.Font = value
      MilaUI:CreateReloadPrompt()
    end)
    Font:SetRelativeWidth(0.3)
    Font:SetPoint("TOPLEFT", FontOptions.frame, "TOPLEFT", 100, 0)
    FontOptions:AddChild(Font)
    
    local FontFlag = MilaUI_GUI:Create("Dropdown")
    FontFlag:SetLabel("Font Flag")
    FontFlag:SetList({
        ["NONE"] = "None",
        ["OUTLINE"] = "Outline",
        ["THICKOUTLINE"] = "Thick Outline",
        ["MONOCHROME"] = "Monochrome",
        ["OUTLINE, MONOCHROME"] = "Outline, Monochrome",
        ["THICKOUTLINE, MONOCHROME"] = "Thick Outline, Monochrome",
    })
    FontFlag:SetValue(General.FontFlag)
    FontFlag:SetCallback("OnValueChanged", function(widget, event, value) General.FontFlag = value MilaUI:UpdateFrames() end)
    FontFlag:SetRelativeWidth(0.2)
    FontOptions:AddChild(FontFlag)
  end
  
  -- Initialize with the General tab selected
  MilaUI:UpdateTabButtonStates(generalButton, allButtons) -- Disable the active button
  HandleGeneralTab(contentPanel)

  mainFrame:Show()
end

-- Public open/close
function MilaUI_OpenGUIMain()
  MilaUI:CreateGUIMain()
end

function MilaUI_CloseGUIMain()
  if mainFrame then mainFrame:Hide() end
end

-- ReOpenGUI function moved to GUI_Utility.lua

-- Slash command
SLASH_MILAUI1 = "/milaui"
SLASH_MILAUI2 = "/mui"
SlashCmdList["MILAUI"] = function(msg, editBox)
  -- Open the GUI
  MilaUI_OpenGUIMain()
  -- Return true to indicate the command was handled (closes the chat input box)
  return true
end
