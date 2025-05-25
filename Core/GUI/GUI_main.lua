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
local initialLoad = true

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
-- Main GUI creation
-- Make these variables global to the file so they can be accessed by ReOpenGUI
mainFrame = nil
mainTabs = nil
unitframesTabs = nil


-- Initialize the main GUI
function MilaUI:InitGUI()
    if not MilaUI.DB then return end
    isOpen = true
    local LSMFonts = LSM:HashTable(LSM.MediaType.FONT)
    local LSMTextures = LSM:HashTable(LSM.MediaType.STATUSBAR)
  
  -- Main frame
  mainFrame = GUI:Create("Window")
  mainFrame:SetTitle(pink .. GUI_TITLE)
  mainFrame:SetLayout("Manual")
  mainFrame:SetWidth(GUI_WIDTH)
  mainFrame:SetHeight(GUI_HEIGHT)
  mainFrame:EnableResize(true)

  -- Background with padding
  local bg = mainFrame.frame:CreateTexture(nil, "BACKGROUND")
  bg:SetColorTexture(0.1, 0.1, 0.4, 0.85)
  bg:SetPoint("TOPLEFT", 6, -6)
  bg:SetPoint("BOTTOMRIGHT", -6, 6)

  -- Border around entire frame
  local border = CreateFrame("Frame", nil, mainFrame.frame, "BackdropTemplate")
  border:SetAllPoints()
  border:SetBackdrop({
    bgFile = nil,
    edgeFile = "Interface\\AddOns\\Mila_UI\\Media\\Borders\\border-glow-overlay.tga",
    edgeSize = 16,
  })
  border:SetBackdropBorderColor(1.0, 0.41, 1.0)

  mainFrame:SetCallback("OnClose", function(widget)
    GUI:Release(widget)
    isOpen = false
  end)
  -- Register with the UI escape key handler
  _G["MilaUI_MainFrame"] = mainFrame.frame
  tinsert(UISpecialFrames, "MilaUI_MainFrame")

  -- Create a container for the logo
  local logoGroup = GUI:Create("SimpleGroup")
  logoGroup:SetLayout("Fill")
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
      btn:SetText(pink .. "Unlock")
    else
      btn:SetText(pink .. "Lock")
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

  -- Create the main content area with a tree group
  local mainTree = GUI:Create("TreeGroup")
  mainTree:SetLayout("Fill")
  mainTree:SetFullWidth(true)
  mainTree:SetFullHeight(true)
  mainTree.frame:SetPoint("TOPLEFT", logoGroup.frame, "BOTTOMLEFT", 10, -20)
  mainTree.frame:SetPoint("BOTTOMRIGHT", mainFrame.frame, "BOTTOMRIGHT", -20, 20)
  mainFrame:AddChild(mainTree)
  
  -- Define the tree structure
  local treeData = {
    { value = "General", text = "General Settings" },
    { 
      value = "Units", text = "Unit Frames",
      children = {
        { value = "Player", text = L.Player },
        { value = "Target", text = L.Target },
        { value = "Focus", text = L.Focus },
        { value = "Pet", text = L.Pet },
        { value = "TargetTarget", text = L.TargetTarget },
        { value = "FocusTarget", text = L.FocusTarget },
        { value = "Boss", text = L.Boss },
      },
      expanded = true
    },
    { value = "Tags", text = "Tags" },
    { value = "Profiles", text = "Profiles" },
  }
  
  mainTree:SetTree(treeData)
  mainTree:SetStatusTable({Units = true})
  mainTree:SetCallback("OnClick", function(widget, uniquevalue)
  end)
  mainTree:SetStatusTable({["Units"] = true})
  
  -- Directly call the OnGroupSelected callback with 'General' as the selection
  C_Timer.After(0.1, function()
    mainTree:Fire("OnGroupSelected", "General")
  end)
  
  -- Handle tree selection
  mainTree:SetCallback("OnGroupSelected", function(container, _, selection)
    -- If this is the initial load and no selection is made, select General
    if initialLoad then
      initialLoad = false
      if not selection or selection == "" then
        mainTree:SelectByPath("General")
        return
      end
    end
    container:ReleaseChildren()
    
    -- Create a scroll frame for the content
    local contentFrame = GUI:Create("ScrollFrame")
    contentFrame:SetLayout("Flow")
    contentFrame:SetFullWidth(true)
    contentFrame:SetFullHeight(true)
    container:AddChild(contentFrame)
    
    -- Parse the selection path
    local main, sub = strsplit("\001", selection)
    
    -- General Settings
    if main == "General" then
      HandleGeneralTab(contentFrame)
    
    -- Tags Settings
    elseif main == "Tags" then
      MilaUI:DrawTagsContainer(contentFrame)
    
    -- Profiles Settings
    elseif main == "Profiles" then
      MilaUI:DrawProfileContainer(contentFrame)
      C_Timer.After(0.1, function()
        local p = parent
        while p and p.DoLayout do
            p:DoLayout()
            p = p.parent
        end
    end)
    
    -- Unit Frames
    elseif main == "Units" and sub == nil then
      -- Show the general unitframes tab when no specific unit is selected
      if MilaUI.DrawUnitframesGeneralTab then
        MilaUI:DrawUnitframesGeneralTab(contentFrame)
      else
        local label = GUI:Create("Label")
        label:SetFullWidth(true)
        contentFrame:AddChild(label)
      end
    elseif main == "Units" and sub then
      -- Directly call DrawUnitContainer to handle the unit settings
      if MilaUI.DrawUnitContainer then
        MilaUI:DrawUnitContainer(contentFrame, sub)
      else
        local label = GUI:Create("Label")
        label:SetText("Unit settings are currently unavailable.")
        label:SetFullWidth(true)
        contentFrame:AddChild(label)
      end
    end
    
    -- Force layout update after a short delay
    C_Timer.After(0.1, function()
      if container and container.frame then
        container:DoLayout()
      end
    end)
  end)
  
  -- Select the default tree item
  mainTree:SetStatusTable({Units = true})
end

function HandleGeneralTab(parent)
  -- Create a container for the content
  local container = GUI:Create("SimpleGroup")
  container:SetLayout("Flow")
  container:SetFullWidth(true)
  container:SetFullHeight(true)
  parent:AddChild(container)
  
  -- Add the AceConfig GUI for general settings
  if MilaUI.DrawGeneralTab then
    MilaUI:DrawGeneralTab(container)
  else
    local label = GUI:Create("Label")
    label:SetFullWidth(true)
    container:AddChild(label)
  end
  
  local General = MilaUI.DB.profile.General
  local UIScale = GUI:Create("InlineGroup")
  UIScale:SetLayout("Flow")
  UIScale:SetTitle(pink .. "Custom UI Scale")
  UIScale.titletext:SetFontObject(GameFontNormalLarge)
  UIScale:SetFullWidth(true)
  UIScale:SetHeight(20)
  -- Enable UI Scale checkbox
  local UIScaleToggle = GUI:Create("CheckBox")
  UIScaleToggle:SetLabel("Enable custom UI Scale")
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
  UIScaleSlider:SetLabel(lavender .. "UI Scale")
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
  container:AddChild(UIScale)
  
  local FontOptions = GUI:Create("InlineGroup")
  FontOptions:SetLayout("Flow")
  FontOptions:SetTitle(pink .. "Font Options")
  FontOptions.titletext:SetFontObject(GameFontNormalLarge)
  FontOptions:SetFullWidth(true)
  FontOptions:SetHeight(20)
  container:AddChild(FontOptions)
  
  local Font = MilaUI_GUI:Create("LSM30_Font")
  Font:SetLabel(lavender .. "Font")
  Font:SetList(LSM:HashTable(LSM.MediaType.FONT))
  Font:SetValue(General.Font)
  -- NOTE: General.Font now stores the font key (e.g., "Friz Quadrata TT"). Always use LSM:Fetch("font", General.Font) when applying fonts!
  Font:SetCallback("OnValueChanged", function(widget, event, value)
    General.Font = value
    MilaUI:CreateReloadPrompt()
  end)
  Font:SetRelativeWidth(0.3)
  FontOptions:AddChild(Font)
  
  local FontFlag = MilaUI_GUI:Create("Dropdown")
  FontFlag:SetLabel(lavender .. "Font Flag")
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


-- Public open/close
function MilaUI_OpenGUIMain()
  MilaUI:InitGUI()
  
  -- Select General tab after initialization
  C_Timer.After(0.1, function()
    if mainTree then
      mainTree:SelectByPath("General")
    end
  end)
end

function MilaUI_CloseGUIMain()
  if mainFrame then mainFrame:Hide() end
end

