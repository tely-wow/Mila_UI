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

local Global = MilaUI.DB.global
local General = MilaUI.DB.profile.Unitframes.General
local cursorMod = MilaUI.DB.profile.CursorMod
  
  -- Main frame
  mainFrame = GUI:Create("Window")
  mainFrame:SetTitle(pink .. GUI_TITLE)
  mainFrame:SetLayout("Manual")  -- Manual layout allows SetPoint positioning
  mainFrame:SetWidth(GUI_WIDTH)
  mainFrame:SetHeight(GUI_HEIGHT)
  mainFrame:EnableResize(true)

  mainFrame:SetCallback("OnClose", function(widget)
    GUI:Release(widget)
    isOpen = false
    -- Clean up our escape key handler reference
    MilaUI.mainFrame = nil
  end)
  
  -- Store reference for escape key handling without accessing internal frame
  MilaUI.mainFrame = mainFrame
  
  -- Create a proxy frame for ESC key handling that doesn't violate AceGUI
  if not MilaUI.escapeHandler then
    MilaUI.escapeHandler = CreateFrame("Frame", "MilaUI_EscapeHandler", UIParent)
    MilaUI.escapeHandler:SetScript("OnHide", function()
      if MilaUI.mainFrame and MilaUI.mainFrame.Hide then
        MilaUI.mainFrame:Hide()
      end
    end)
    tinsert(UISpecialFrames, "MilaUI_EscapeHandler")
  end
  
  -- Show the escape handler when GUI is shown
  MilaUI.escapeHandler:Show()

  -- Create logo using proper AceGUI Icon widget
  local logo = GUI:Create("Icon")
  logo:SetImage("Interface\\Addons\\Mila_UI\\Media\\logo.tga")
  logo:SetImageSize(150, 150)
  logo:SetWidth(150)
  logo:SetHeight(150)
  logo:SetLabel("")  -- No label for the logo
  logo.frame:SetPoint("TOPLEFT", mainFrame.frame, "TOPLEFT", 8, -25)
  mainFrame:AddChild(logo)

  -- Create a label for the lock/unlock button
  local lockLabel = GUI:Create("Label")
  lockLabel:SetText(pink .. "Lock / Unlock Unit Frames")
  lockLabel:SetFontObject(GameFontNormal)
  lockLabel:SetFullWidth(false)
  lockLabel.frame:SetPoint("TOPLEFT", logo.frame, "TOPRIGHT", 0, -20)
  mainFrame:AddChild(lockLabel)

  -- Create the lock/unlock button
  local function updateLockButtonText(btn)
    if Global.FramesLocked then
      btn:SetText(pink .. "Unlock")
    else
      btn:SetText(pink .. "Lock")
    end
  end

  local lockButton = GUI:Create("Button")
  updateLockButtonText(lockButton)
  lockButton:SetRelativeWidth(0.15)
  lockButton:SetCallback("OnClick", function(widget)
    Global.FramesLocked = not Global.FramesLocked
    if Global.FramesLocked then
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

  -- Test Castbar Buttons
  local testCastbarGroup = GUI:Create("SimpleGroup")
  testCastbarGroup:SetLayout("Flow")
  testCastbarGroup:SetFullWidth(false)
  testCastbarGroup:SetRelativeWidth(0.4)

  local showTestCastbarButton = GUI:Create("Button")
  showTestCastbarButton:SetText(pink .. "Show Test Castbar")
  showTestCastbarButton:SetRelativeWidth(0.5)
  showTestCastbarButton:SetCallback("OnClick", function(widget, event, value)
    -- Test different units based on what's available
    local testUnits = {"player", "target", "focus"}
    
    for _, unitKey in ipairs(testUnits) do
      -- Check for clean castbar first
      local cleanCastbarSettings = MilaUI.DB.profile.castBars and MilaUI.DB.profile.castBars[unitKey]
      
      if cleanCastbarSettings and cleanCastbarSettings.enabled then
        MilaUI:ShowTestCleanCastbar(unitKey, true)
      else
        -- Fall back to oUF castbar
        local unitName = unitKey:gsub("^%l", string.upper)
        if MilaUI.DB.profile.Unitframes[unitName] and MilaUI.DB.profile.Unitframes[unitName].Castbar and MilaUI.DB.profile.Unitframes[unitName].Castbar.enabled then
          MilaUI:ShowTestCastbar(unitName, true)
        end
      end
    end
  end)
  testCastbarGroup:AddChild(showTestCastbarButton)

  local stopTestCastbarButton = GUI:Create("Button")
  stopTestCastbarButton:SetText(pink .. "Stop All Test Castbars")
  stopTestCastbarButton:SetRelativeWidth(0.5)
  stopTestCastbarButton:SetCallback("OnClick", function(widget, event, value)
    MilaUI:StopAllTestCastbars()
  end)
  testCastbarGroup:AddChild(stopTestCastbarButton)

  testCastbarGroup.frame:SetPoint("TOPLEFT", lockButton.frame, "TOPRIGHT", 10, 0)
  mainFrame:AddChild(testCastbarGroup)

  -- Create the main content area with a tree group
  local mainTree = GUI:Create("TreeGroup")
  mainTree:SetLayout("Fill")
  mainTree:SetFullWidth(true)
  mainTree:SetFullHeight(true)
  mainTree.frame:SetPoint("TOPLEFT", logo.frame, "BOTTOMLEFT", 10, -20)
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
        {
          value = "Auras", text = "Auras",
          children = {
            { value = "BuffFilter", text = "Buff Filter" },
            { value = "DebuffFilter", text = "Debuff Filter" },
          }
        },
      },
      expanded = true
    },
    { value = "Tags", text = "Tags" },
    { value = "Profiles", text = "Profiles" },
  }
  
  -- Set the tree data
  mainTree:SetTree(treeData)
  
  -- Set the status table to keep the Units group expanded
  local statusTable = {
    groups = {
      ["Units"] = true  -- This keeps the Units group expanded
    },
  }
  mainTree:SetStatusTable(statusTable)
  
  -- Force a layout refresh after setting up the tree
  mainTree:DoLayout()
  
  mainTree:SetCallback("OnClick", function(widget, uniquevalue)
  end)
  
  -- Handle tree selection
  mainTree:SetCallback("OnGroupSelected", function(container, _, selection)
    -- Debug output
    if MilaUI.DB.global.DebugMode then
        print("OnGroupSelected called with selection: " .. (selection or "nil"))
    end
    
    -- If this is the initial load and no selection is made, select General
    if initialLoad and (not selection or selection == "") then
      initialLoad = false
      mainTree:SelectByPath("General")
      return
    end
    if initialLoad then
      initialLoad = false
    end
    container:ReleaseChildren()
    container:SetLayout("Fill")
    
    -- Create a scroll frame for the content
    local contentFrame = GUI:Create("ScrollFrame")
    contentFrame:SetLayout("Flow")
    contentFrame:SetFullWidth(true)
    contentFrame:SetFullHeight(true)
    container:AddChild(contentFrame)
    
    -- Parse the selection path
    local parts = {strsplit("\001", selection)}
    if MilaUI.DB.global.DebugMode then
        print("Selection parts: " .. table.concat(parts, " -> "))
    end
    
    local main = parts[1]
    local sub = parts[2]
    local subsub = parts[3]
    
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
        if contentFrame and contentFrame.DoLayout and not contentFrame.released then
            contentFrame:DoLayout()
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
      -- Check if this is an Aura filter selection
      if sub == "Auras" and subsub == "BuffFilter" then
        print("Loading Buff Filter")
        if MilaUI.DrawBuffFilterContainer then
          MilaUI:DrawBuffFilterContainer(contentFrame)
        else
          print("DrawBuffFilterContainer function not found")
        end
      elseif sub == "Auras" and subsub == "DebuffFilter" then
        print("Loading Debuff Filter")
        if MilaUI.DrawDebuffFilterContainer then
          MilaUI:DrawDebuffFilterContainer(contentFrame)
        else
          print("DrawDebuffFilterContainer function not found")
        end
      elseif sub == "Auras" and not subsub then
        if MilaUI.DB.global.DebugMode then
            print("Showing Auras overview")
        end
        -- When clicking on "Auras" parent, show info about the children
        local container = GUI:Create("SimpleGroup")
        container:SetLayout("Flow")
        container:SetFullWidth(true)
        container:SetFullHeight(true)
        contentFrame:AddChild(container)
        
        MilaUI:CreateLargeHeading("Aura Filters", container)
        
        local info = GUI:Create("Label")
        info:SetText("Select a filter type from the menu:\n\n• Buff Filter - Hide specific buffs from all unit frames\n• Debuff Filter - Hide specific debuffs from all unit frames")
        info:SetFullWidth(true)
        container:AddChild(info)
      else
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
    end
    
    -- Force layout update after a short delay
    C_Timer.After(0.1, function()
      if container and container.DoLayout then
        container:DoLayout()
      end
    end)
  end)
  
  -- Force the Units group to expand after a short delay (if needed)
  C_Timer.After(0.2, function()
    if mainTree and mainTree.status and mainTree.status.groups and mainTree.RefreshTree then
      -- Only update if not already expanded
      if not mainTree.status.groups["Units"] then
        mainTree.status.groups["Units"] = true
        mainTree:RefreshTree()
      end
    end
  end)
  
  -- Select General tab by default after a short delay
  C_Timer.After(0.1, function()
    if mainTree and mainTree.SelectByPath then
      mainTree:SelectByPath("General")
    end
  end)
  
  -- Force a complete layout refresh after setup
  mainFrame:DoLayout()
end

function HandleGeneralTab(parent)
  local Global = MilaUI.DB.global
  local General = MilaUI.DB.profile.Unitframes.General
  local cursorMod = MilaUI.DB.profile.CursorMod
  -- Create a container for the content
  local container = GUI:Create("SimpleGroup")
  container:SetLayout("Flow")
  container:SetFullWidth(true)
  container:SetFullHeight(true)
  parent:AddChild(container)
  
  -- The general settings content is handled directly in this function
  -- Remove the check for DrawGeneralTab since we handle everything here
  MilaUI:CreateLargeHeading("Custom UI Scale", container)
  local UIScale = GUI:Create("InlineGroup")
  UIScale:SetLayout("Flow")
  UIScale:SetFullWidth(true)
  UIScale:SetHeight(20)

  --Escape Menu Scale
  local EscapeMenuScale = GUI:Create("Slider")
  EscapeMenuScale:SetSliderValues(0.4, 2, 0.01)
  EscapeMenuScale:SetValue(Global.GameMenuScale)
  EscapeMenuScale:SetRelativeWidth(0.5)
  EscapeMenuScale:SetLabel(lavender .. "Escape Menu Scale")
  EscapeMenuScale:SetCallback("OnMouseUp", function(widget, event, value)
    if value > 2 then value = 1 print(pink .. "♥MILA UI ♥: " .. lavender .. "Escape Menu Scale reset to 1. Maximum of 2 for EscapeMenuScale.") end
    Global.GameMenuScale = value
    MilaUI:UpdateEscapeMenuScale()
    EscapeMenuScale:SetValue(value)
  end)
  UIScale:AddChild(EscapeMenuScale)
  -- Enable UI Scale checkbox
  local UIScaleToggle = GUI:Create("CheckBox")
  UIScaleToggle:SetLabel("Enable custom UI Scale")
  UIScaleToggle:SetValue(Global.UIScaleEnabled)
  UIScaleToggle:SetRelativeWidth(0.3)
  UIScale:AddChild(MilaUI:CreateHorizontalSpacer(0.02))
  UIScale:AddChild(UIScaleToggle)
  -- UIScale slider
  local UIScaleSlider = GUI:Create("Slider")
  UIScaleSlider:SetSliderValues(0.4, 2, 0.01)
  UIScaleSlider:SetValue(Global.UIScale)
  UIScaleSlider:SetWidth(200)
  UIScaleSlider:SetHeight(20)
  UIScaleSlider:SetLabel(lavender .. "UI Scale")
  UIScaleSlider:SetCallback("OnMouseUp", function(widget, event, value)
    if value > 2 then value = 1 print(pink .. "♥MILA UI ♥: " .. lavender .. "UI Scale reset to 1. Maximum of 2 for UIScale.") end
    Global.UIScale = value
    MilaUI:UpdateUIScale()
    UIScaleSlider:SetValue(value)
  end)
  UIScale:AddChild(UIScaleSlider)
  UIScaleToggle:SetCallback("OnValueChanged", function(widget, event, value)
    Global.UIScaleEnabled = value
    if value then
      UIScaleSlider:SetDisabled(false)
      MilaUI:UpdateUIScale()
    else
      UIScaleSlider:SetDisabled(true)
      UIParent:SetScale(1)
    end
  end)
  if not Global.UIScaleEnabled then
    UIScaleSlider:SetDisabled(true)
  end
  container:AddChild(UIScale)
 MilaUI:CreateVerticalSpacer(20, UIScale)
 MilaUI:CreateVerticalSpacer(20, container)
  
  --CursorMod Options
  MilaUI:CreateLargeHeading("CursorMod Options", container)
  local CursorModOptions = GUI:Create("InlineGroup")
  CursorModOptions:SetLayout("Flow")
  CursorModOptions:SetFullWidth(true)
  
  
  local MilaUIAddon = LibStub("AceAddon-3.0"):GetAddon("MilaUI")
  local CursorMod = MilaUIAddon:GetModule("CursorMod")
  
  container:AddChild(CursorModOptions)
  
  -- Helper function to enable/disable all children of a container
  local function SetGroupEnabled(container, enabled)
      -- Check if container is valid and not released
      if not container or not container.children or container.released then return end
      for _, child in ipairs(container.children) do
          -- Only modify widgets that are still valid
          if child and not child.released and child.SetDisabled then
              child:SetDisabled(not enabled)
          end
          -- Recursively handle nested containers
          if child and child.children and not child.released then
              SetGroupEnabled(child, enabled)
          end
      end
  end
  
  -- Create the enable checkbox first
  local enablecursormod = GUI:Create("CheckBox")
  enablecursormod:SetLabel(lavender .. "Enable CursorMod")
  enablecursormod:SetValue(CursorMod:IsEnabled())
  CursorModOptions:AddChild(enablecursormod)
  
  -- Create the groups that will be referenced in the checkbox callback
  local CursorModGeneral = GUI:Create("InlineGroup")
  CursorModGeneral:SetLayout("Flow")
  CursorModGeneral:SetTitle(pink .. "General")
  CursorModGeneral:SetFullWidth(true)
  CursorModOptions:AddChild(CursorModGeneral)
  
  local cursormodapperance = GUI:Create("InlineGroup")
  cursormodapperance:SetLayout("Flow")
  cursormodapperance:SetTitle(pink .. "Appearance")
  cursormodapperance:SetFullWidth(true)
  CursorModOptions:AddChild(cursormodapperance)
  
  -- Set up the callback after all UI elements are created
  enablecursormod:SetCallback("OnValueChanged", function(_, _, value)
      if value then
          MilaUIAddon:EnableModule("CursorMod")
          SetGroupEnabled(CursorModGeneral, true)
          SetGroupEnabled(cursormodapperance, true)
      else
          MilaUIAddon:DisableModule("CursorMod")
          SetGroupEnabled(CursorModGeneral, false)
          SetGroupEnabled(cursormodapperance, false)
      end
  end)
  
  -- Initialize the UI state based on whether CursorMod is enabled
  if not CursorMod:IsEnabled() then
      SetGroupEnabled(CursorModGeneral, false)
      SetGroupEnabled(cursormodapperance, false)
  end

  local showOnlyInCombat = GUI:Create("CheckBox")
  showOnlyInCombat:SetLabel(lavender .. "Show Only in Combat")
  showOnlyInCombat:SetValue(MilaUI.DB.profile.CursorMod.showOnlyInCombat)
  showOnlyInCombat:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.showOnlyInCombat = value
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
        CursorMod:SetShowOnlyInCombat(value)
      end
  end)
  CursorModGeneral:AddChild(showOnlyInCombat)
  
  local CursorFreelookStartDelta = GUI:Create("Slider")
  CursorFreelookStartDelta:SetLabel(lavender .. "Freelook Start Delta")
  CursorFreelookStartDelta:SetSliderValues(0.0001, 0.01, 0.0001)
  CursorFreelookStartDelta:SetValue(MilaUI.DB.profile.CursorMod.lookStartDelta or 0.001)
  CursorFreelookStartDelta:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.lookStartDelta = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetLookStartDelta(value)
      end
  end)
  CursorModGeneral:AddChild(CursorFreelookStartDelta)

  local cursormodgamecursor = GUI:Create("CheckBox")
  cursormodgamecursor:SetLabel(lavender .. "Change Game Cursor Size")
  cursormodgamecursor:SetValue(MilaUI.DB.profile.CursorMod.changeCursorSize)
  cursormodgamecursor:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.changeCursorSize = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetChangeCursorSize(value)
      end
  end)
  CursorModGeneral:AddChild(cursormodgamecursor)
  local cursormodtexture = GUI:Create("Dropdown")
  cursormodtexture:SetLabel(lavender .. "Cursor Texture")
  cursormodtexture:SetList({
      [1] = "Custom Point",
      [2] = "Retail Cursor",
      [3] = "Classic Cursor", 
      [4] = "Inverse Point",
      [5] = "Ghostly Point",
      [6] = "Talent Search 1",
      [7] = "Talent Search 2",
  })
  cursormodtexture:SetValue(MilaUI.DB.profile.CursorMod.texPoint)
  cursormodtexture:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.texPoint = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetTexture(value)
      end
  end)
  cursormodapperance:AddChild(cursormodtexture)
  local cursormodsize = GUI:Create("Dropdown")
  cursormodsize:SetLabel(lavender .. "Cursor Size")
  cursormodsize:SetList({
      [0] = "32x32",
      [1] = "48x48",
      [2] = "64x64",
      [3] = "96x96",
      [4] = "128x128",
  })
  cursormodsize:SetValue(MilaUI.DB.profile.CursorMod.size)
  cursormodsize:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.size = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetSize(value)
      end
  end)
  cursormodapperance:AddChild(cursormodsize)
  local cursormodopacity = GUI:Create("Slider")
  cursormodopacity:SetSliderValues(0, 1, 0.01)
  cursormodopacity:SetLabel(lavender .. "Opacity")
  cursormodopacity:SetValue(MilaUI.DB.profile.CursorMod.opacity)
  cursormodopacity:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.opacity = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetOpacity(value)
      end
  end)
  cursormodapperance:AddChild(cursormodopacity)

  local cursormodscalecontainer = GUI:Create("InlineGroup")
  cursormodscalecontainer:SetLayout("Flow")
  cursormodscalecontainer:SetRelativeWidth(0.5)
  cursormodscalecontainer:SetTitle(pink .. "Scale")
  cursormodapperance:AddChild(cursormodscalecontainer)

  local cursormodautoscale = GUI:Create("CheckBox")
  cursormodautoscale:SetLabel(lavender .. "Auto Scale")
  cursormodautoscale:SetValue(MilaUI.DB.profile.CursorMod.autoScale)
  cursormodautoscale:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.autoScale = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetAutoScale(value)
          if value then
              cursormodscaleslider:SetDisabled(true)
          else
              cursormodscaleslider:SetDisabled(false)
          end
      end
  end)
  cursormodscalecontainer:AddChild(cursormodautoscale)

  local cursormodscaleslider = GUI:Create("Slider")
  cursormodscaleslider:SetSliderValues(0.4, 2, 0.01)
  cursormodscaleslider:SetLabel(lavender .. "Manual Scale")
  cursormodscaleslider:SetValue(MilaUI.DB.profile.CursorMod.scale)
  cursormodscaleslider:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.scale = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetScale(value)
      end
  end)
  cursormodscalecontainer:AddChild(cursormodscaleslider)
  
  local cursormodcolorcontainer = GUI:Create("InlineGroup")
  cursormodcolorcontainer:SetLayout("Flow")
  cursormodcolorcontainer:SetFullWidth(true)
  cursormodcolorcontainer:SetTitle(pink .. "Color")
  cursormodcolorcontainer:SetRelativeWidth(0.5)
  cursormodapperance:AddChild(cursormodcolorcontainer)
  local cursormodclasscolor = GUI:Create("CheckBox")
  cursormodclasscolor:SetLabel(lavender .. "Class Color")
  cursormodclasscolor:SetValue(MilaUI.DB.profile.CursorMod.useClassColor)
  cursormodclasscolor:SetCallback("OnValueChanged", function(_, _, value)
      MilaUI.DB.profile.CursorMod.useClassColor = value
      -- Update the setting if CursorMod is enabled
      local CursorMod = MilaUIAddon:GetModule("CursorMod")
      if CursorMod:IsEnabled() then
          CursorMod:SetUseClassColor(value)
      end
  end)
  cursormodcolorcontainer:AddChild(cursormodclasscolor)
  local cursormodcolorpicker = GUI:Create("ColorPicker")
  cursormodcolorpicker:SetLabel(lavender .. "Color")
  local AR, AG, AB, AA = unpack(MilaUI.DB.profile.CursorMod.color)
  cursormodcolorpicker:SetColor(AR, AG, AB, AA)
  cursormodcolorpicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) MilaUI.DB.profile.CursorMod.color = {r, g, b, a} CursorMod:SetColor(r, g, b, a) end)
  cursormodcolorpicker:SetHasAlpha(true)
  cursormodcolorpicker:SetRelativeWidth(1)
  cursormodcolorcontainer:AddChild(cursormodcolorpicker)
  
  -- Font Options
  MilaUI:CreateLargeHeading("Font Options", container)
  local FontOptions = GUI:Create("InlineGroup")
  FontOptions:SetLayout("Flow")
  FontOptions:SetFullWidth(true)
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
  
  -- Force layout update to show all content properly
  C_Timer.After(0.1, function()
    if parent and parent.DoLayout and not parent.released then
      parent:DoLayout()
    end
  end)
end


-- Public open/close
function MilaUI_OpenGUIMain()
  MilaUI:InitGUI()
end

function MilaUI_CloseGUIMain()
  if mainFrame and mainFrame.Hide then 
    mainFrame:Hide() 
  end
  -- Hide the escape handler as well
  if MilaUI.escapeHandler then
    MilaUI.escapeHandler:Hide()
  end
end

