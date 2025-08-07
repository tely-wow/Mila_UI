local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0") 
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
MilaUI.GUI = GUI
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"
local unitSettingsContainer = nil


function MilaUI:DrawBuffsContainer(dbUnitName, contentFrame)
    local Buffs = MilaUI.DB.profile.Unitframes[dbUnitName].Buffs
    
    -- Buffs Options Container
    MilaUI:CreateLargeHeading("Buff Options", contentFrame)
    local BuffsOptions = GUI:Create("InlineGroup")
    BuffsOptions:SetLayout("Flow")
    BuffsOptions:SetTitle(pink .. "General")
    BuffsOptions:SetRelativeWidth(0.5)
    BuffsOptions:SetHeight(170)
    BuffsOptions:SetAutoAdjustHeight(false)
    contentFrame:AddChild(BuffsOptions)

    --Size Container
    local sizeGroup = GUI:Create("InlineGroup")
    sizeGroup:SetLayout("Flow")
    sizeGroup:SetRelativeWidth(0.5)
    sizeGroup:SetTitle(pink .. "Size")
    sizeGroup:SetHeight(170)
    sizeGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(sizeGroup)
    
    --Icon Position Container
    local positionGroup = GUI:Create("InlineGroup")
    positionGroup:SetLayout("Flow")
    positionGroup:SetRelativeWidth(0.5)
    positionGroup:SetTitle(pink .. "Icon Position")
    positionGroup:SetHeight(130)
    positionGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(positionGroup)
    
    --Icon Anchor Container
    local anchorGroup = GUI:Create("InlineGroup")
    anchorGroup:SetLayout("Flow")
    anchorGroup:SetRelativeWidth(0.5)
    anchorGroup:SetTitle(pink .. "Icon Anchor")
    anchorGroup:SetHeight(130)
    anchorGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(anchorGroup)
    
    -- Enable Buffs
    local BuffsEnabled = GUI:Create("CheckBox")
    BuffsEnabled:SetLabel("Enable Buffs")
    BuffsEnabled:SetValue(Buffs.Enabled)
    BuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Enabled = value MilaUI:UpdateFrames() end)
    BuffsEnabled:SetRelativeWidth(0.5)
    BuffsOptions:AddChild(BuffsEnabled)
    
    -- Only Show Player Buffs
    local OnlyShowPlayer = GUI:Create("CheckBox")
    OnlyShowPlayer:SetLabel("Only Show Player Buffs")
    OnlyShowPlayer:SetValue(Buffs.OnlyShowPlayer)
    OnlyShowPlayer:SetCallback("OnValueChanged", function(widget, event, value) Buffs.OnlyShowPlayer = value MilaUI:UpdateFrames() end)
    OnlyShowPlayer:SetRelativeWidth(0.5)
    BuffsOptions:AddChild(OnlyShowPlayer)

    -- Spacing
    local BuffSpacing = GUI:Create("Slider")
    BuffSpacing:SetLabel(lavender .. "Spacing")
    BuffSpacing:SetSliderValues(0, 20, 1)
    BuffSpacing:SetValue(Buffs.Spacing)
    BuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Spacing = value MilaUI:UpdateFrames() end)
    BuffSpacing:SetRelativeWidth(0.5)
    BuffsOptions:AddChild(BuffSpacing)
    BuffsOptions:AddChild(MilaUI:CreateHorizontalSpacer(0.25))
    local GrowthX = {
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right",
    }
    
    local BuffGrowthX = GUI:Create("Dropdown")
    BuffGrowthX:SetLabel(lavender .. "Growth Direction X")
    BuffGrowthX:SetList(GrowthX)
    BuffGrowthX:SetValue(Buffs.GrowthX)
    BuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthX = value MilaUI:UpdateFrames() end)
    BuffGrowthX:SetRelativeWidth(0.5)
    BuffsOptions:AddChild(BuffGrowthX)
    
    -- Growth Direction Y
    local GrowthY = {
        ["UP"] = "Up",
        ["DOWN"] = "Down",
    }
    
    local BuffGrowthY = GUI:Create("Dropdown")
    BuffGrowthY:SetLabel(lavender .. "Growth Direction Y")
    BuffGrowthY:SetList(GrowthY)
    BuffGrowthY:SetValue(Buffs.GrowthY)
    BuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthY = value MilaUI:UpdateFrames() end)
    BuffGrowthY:SetRelativeWidth(0.5)
    BuffsOptions:AddChild(BuffGrowthY)
    
    -- Size
    local BuffSize = GUI:Create("Slider")
    BuffSize:SetLabel(lavender .. "Size")
    BuffSize:SetSliderValues(1, 64, 1)
    BuffSize:SetValue(Buffs.Size)
    BuffSize:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Size = value MilaUI:UpdateFrames() end)
    BuffSize:SetRelativeWidth(1)
    sizeGroup:AddChild(BuffSize)
    -- Number to Show
    local BuffNum = GUI:Create("Slider")
    BuffNum:SetLabel(lavender .. "Amount To Show")
    BuffNum:SetSliderValues(1, 40, 1)
    BuffNum:SetValue(Buffs.Num)
    BuffNum:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Num = value MilaUI:UpdateFrames() end)
    BuffNum:SetRelativeWidth(1)
    sizeGroup:AddChild(BuffNum)

    -- Anchor Points
    local AnchorPoints = {
        ["TOPLEFT"] = "Top Left",
        ["TOP"] = "Top",
        ["TOPRIGHT"] = "Top Right",
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
        ["BOTTOMLEFT"] = "Bottom Left",
        ["BOTTOM"] = "Bottom",
        ["BOTTOMRIGHT"] = "Bottom Right",
    }
    -- Anchor Frame
    local AnchorFrameOptions = {
        ["HealthBar"] = "Health Bar",
        ["PowerBar"] = "Power Bar",
        ["Debuffs"] = "Debuffs",
        [Buffs.AnchorFrame] = Buffs.AnchorFrame, -- Add the current value if it's not in the list
    }
    
    local BuffAnchorFrame = GUI:Create("Dropdown")
    BuffAnchorFrame:SetLabel(lavender .. "Anchor Frame")
    BuffAnchorFrame:SetList(AnchorFrameOptions)
    BuffAnchorFrame:SetValue(Buffs.AnchorFrame)
    BuffAnchorFrame:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorFrame = value MilaUI:UpdateFrames() end)
    BuffAnchorFrame:SetRelativeWidth(1)
    anchorGroup:AddChild(BuffAnchorFrame)
    
    -- Anchor From
    local BuffAnchorFrom = GUI:Create("Dropdown")
    BuffAnchorFrom:SetLabel(lavender .. "Anchor From")
    BuffAnchorFrom:SetList(AnchorPoints)
    BuffAnchorFrom:SetValue(Buffs.AnchorFrom)
    BuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorFrom = value MilaUI:UpdateFrames() end)
    BuffAnchorFrom:SetRelativeWidth(0.5)
    anchorGroup:AddChild(BuffAnchorFrom)
    
    -- Anchor To
    local BuffAnchorTo = GUI:Create("Dropdown")
    BuffAnchorTo:SetLabel(lavender .. "Anchor To")
    BuffAnchorTo:SetList(AnchorPoints)
    BuffAnchorTo:SetValue(Buffs.AnchorTo)
    BuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorTo = value MilaUI:UpdateFrames() end)
    BuffAnchorTo:SetRelativeWidth(0.5)
    anchorGroup:AddChild(BuffAnchorTo)
    

    -- X Offset
    local BuffXOffset = GUI:Create("Slider")
    BuffXOffset:SetLabel(lavender .. "X Offset")
    BuffXOffset:SetSliderValues(-50, 50, 1)
    BuffXOffset:SetValue(Buffs.XOffset)
    BuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.XOffset = value MilaUI:UpdateFrames() end)
    BuffXOffset:SetRelativeWidth(0.5)
    positionGroup:AddChild(BuffXOffset)
    
    -- Y Offset
    local BuffYOffset = GUI:Create("Slider")
    BuffYOffset:SetLabel(lavender .. "Y Offset")
    BuffYOffset:SetSliderValues(-50, 50, 1)
    BuffYOffset:SetValue(Buffs.YOffset)
    BuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.YOffset = value MilaUI:UpdateFrames() end)
    BuffYOffset:SetRelativeWidth(0.5)
    positionGroup:AddChild(BuffYOffset)

    -- Buff Count Options Section
    MilaUI:CreateLargeHeading(pink .. "Buff Count Options", contentFrame)
    -- Buff Count Font Container
    local countfontGroup = GUI:Create("InlineGroup")
    countfontGroup:SetLayout("Flow")
    countfontGroup:SetRelativeWidth(1)
    countfontGroup:SetTitle(pink .. "Font Options")
    contentFrame:AddChild(countfontGroup)
    
    -- Buff Count Anchoring Options
    local countanchorGroup = GUI:Create("InlineGroup")
    countanchorGroup:SetLayout("Flow")
    countanchorGroup:SetRelativeWidth(0.5)
    countanchorGroup:SetTitle(pink .. "Count Text Anchor")
    contentFrame:AddChild(countanchorGroup)

    -- Buff Count Position Container
    local countpositionGroup = GUI:Create("InlineGroup")
    countpositionGroup:SetLayout("Flow")
    countpositionGroup:SetRelativeWidth(0.5)
    countpositionGroup:SetTitle(pink .. "Count Text Position")
    contentFrame:AddChild(countpositionGroup)
    
    -- Count Anchor From
    local BuffCountAnchorFrom = GUI:Create("Dropdown")
    BuffCountAnchorFrom:SetLabel(lavender .. "Anchor From")
    BuffCountAnchorFrom:SetList(AnchorPoints)
    BuffCountAnchorFrom:SetValue(Buffs.Count.AnchorFrom)
    BuffCountAnchorFrom:SetRelativeWidth(0.9)
    BuffCountAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.AnchorFrom = value MilaUI:UpdateFrames() end)
    countanchorGroup:AddChild(BuffCountAnchorFrom)
    
    -- Count Anchor To
    local BuffCountAnchorTo = GUI:Create("Dropdown")
    BuffCountAnchorTo:SetLabel(lavender .. "Anchor To")
    BuffCountAnchorTo:SetList(AnchorPoints)
    BuffCountAnchorTo:SetValue(Buffs.Count.AnchorTo)
    BuffCountAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.AnchorTo = value MilaUI:UpdateFrames() end)
    BuffCountAnchorTo:SetRelativeWidth(0.9)
    countanchorGroup:AddChild(BuffCountAnchorTo)
    
    -- Count X Offset
    local BuffCountXOffset = GUI:Create("Slider")
    BuffCountXOffset:SetLabel(lavender .. "X Offset")
    BuffCountXOffset:SetSliderValues(-64, 64, 1)
    BuffCountXOffset:SetValue(Buffs.Count.XOffset)
    BuffCountXOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.XOffset = value MilaUI:UpdateFrames() end)
    BuffCountXOffset:SetRelativeWidth(1)
    countpositionGroup:AddChild(BuffCountXOffset)
    
    -- Count Y Offset
    local BuffCountYOffset = GUI:Create("Slider")
    BuffCountYOffset:SetLabel(lavender .. "Y Offset")
    BuffCountYOffset:SetSliderValues(-64, 64, 1)
    BuffCountYOffset:SetValue(Buffs.Count.YOffset)
    BuffCountYOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.YOffset = value MilaUI:UpdateFrames() end)
    BuffCountYOffset:SetRelativeWidth(1)
    countpositionGroup:AddChild(BuffCountYOffset)
    
    -- Count Color
    local BuffCountColour = GUI:Create("ColorPicker")
    BuffCountColour:SetLabel(lavender .. "Colour")
    local BCR, BCG, BCB, BCA = unpack(Buffs.Count.Colour)
    BuffCountColour:SetColor(BCR, BCG, BCB, BCA)
    BuffCountColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Buffs.Count.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
    BuffCountColour:SetHasAlpha(true)
    BuffCountColour:SetRelativeWidth(0.5)
    countfontGroup:AddChild(BuffCountColour)
    -- Count Font Size
    local BuffCountFontSize = GUI:Create("Slider")
    BuffCountFontSize:SetLabel(lavender .. "Font Size")
    BuffCountFontSize:SetSliderValues(1, 64, 1)
    BuffCountFontSize:SetValue(Buffs.Count.FontSize)
    BuffCountFontSize:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.FontSize = value MilaUI:UpdateFrames() end)
    BuffCountFontSize:SetRelativeWidth(0.5)
    countfontGroup:AddChild(BuffCountFontSize)
    
    -- Font dropdown with preview
    local BuffCountFont = GUI:Create("LSM30_Font")
    BuffCountFont:SetLabel(lavender .. "Font")
    BuffCountFont:SetList(LSM:HashTable(LSM.MediaType.FONT))
    BuffCountFont:SetValue(Buffs.Count.Font)
    BuffCountFont:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.Font = value MilaUI:UpdateFrames() end)
    BuffCountFont:SetRelativeWidth(0.7)
    countfontGroup:AddChild(BuffCountFont)
    
    -- Font flags
    local fontFlags = {
        ["OUTLINE"] = "Outline",
        ["THICKOUTLINE"] = "Thick Outline",
        ["MONOCHROME"] = "Monochrome",
        ["NONE"] = "None"
    }
    
    local BuffCountFontFlags = GUI:Create("Dropdown")
    BuffCountFontFlags:SetLabel(lavender .. "Outline")
    BuffCountFontFlags:SetList(fontFlags)
    BuffCountFontFlags:SetValue(Buffs.Count.FontFlags)
    BuffCountFontFlags:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.FontFlags = value MilaUI:UpdateFrames() end)
    BuffCountFontFlags:SetRelativeWidth(0.3)
    countfontGroup:AddChild(BuffCountFontFlags)
end

function MilaUI:DrawAuraBlacklistContainer(contentFrame)
    -- Aura Blacklist Container
    MilaUI:CreateLargeHeading("Aura Blacklist", contentFrame)
    
    -- Create buff blacklist section manually
    local buffBlacklistGroup = GUI:Create("InlineGroup")
    buffBlacklistGroup:SetLayout("Flow")
    buffBlacklistGroup:SetTitle(pink .. "Buff Blacklist")
    buffBlacklistGroup:SetRelativeWidth(0.5)
    buffBlacklistGroup:SetHeight(350)
    buffBlacklistGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(buffBlacklistGroup)
    
    -- Buff Instructions
    local buffInstructions = GUI:Create("Label")
    buffInstructions:SetText("Hide specific buffs from all unit frames.")
    buffInstructions:SetFullWidth(true)
    buffBlacklistGroup:AddChild(buffInstructions)
    
    -- Buff Add section
    local buffAddGroup = GUI:Create("InlineGroup")
    buffAddGroup:SetLayout("Flow")
    buffAddGroup:SetTitle("Add Buff to Blacklist")
    buffAddGroup:SetFullWidth(true)
    buffAddGroup:SetHeight(70)
    buffAddGroup:SetAutoAdjustHeight(true)
    buffBlacklistGroup:AddChild(buffAddGroup)
    
    -- Buff Input field
    local buffSpellInput = GUI:Create("EditBox")
    buffSpellInput:SetLabel("Spell ID or Name")
    buffSpellInput:SetRelativeWidth(0.7)
    buffSpellInput:SetText("")
    buffAddGroup:AddChild(buffSpellInput)
    
    -- Buff Add button
    local buffAddButton = GUI:Create("Button")
    buffAddButton:SetText("Add")
    buffAddButton:SetRelativeWidth(0.3)
    buffAddButton:SetCallback("OnClick", function()
        MilaUI:HandleAddToBuffBlacklist(buffSpellInput, buffBlacklistGroup)
    end)
    buffAddGroup:AddChild(buffAddButton)
    
    -- Buff blacklist display
    local buffListGroup = GUI:Create("InlineGroup")
    buffListGroup:SetLayout("Fill")
    buffListGroup:SetTitle("Currently Blacklisted Buffs")
    buffListGroup:SetFullWidth(true)
    buffListGroup:SetHeight(200)
    buffListGroup:SetAutoAdjustHeight(false)
    buffBlacklistGroup:AddChild(buffListGroup)
    
    -- Buff scrollframe
    local buffScrollFrame = GUI:Create("ScrollFrame")
    buffScrollFrame:SetLayout("List")
    buffScrollFrame:SetFullWidth(true)
    buffScrollFrame:SetFullHeight(true)
    buffListGroup:AddChild(buffScrollFrame)
    
    -- Store buff references
    buffBlacklistGroup.scrollFrame = buffScrollFrame
    buffBlacklistGroup.auraType = "buff"
    
    -- Create debuff blacklist section manually
    local debuffBlacklistGroup = GUI:Create("InlineGroup")
    debuffBlacklistGroup:SetLayout("Flow")
    debuffBlacklistGroup:SetTitle(pink .. "Debuff Blacklist")
    debuffBlacklistGroup:SetRelativeWidth(0.5)
    debuffBlacklistGroup:SetHeight(350)
    debuffBlacklistGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(debuffBlacklistGroup)
    
    -- Debuff Instructions
    local debuffInstructions = GUI:Create("Label")
    debuffInstructions:SetText("Hide specific debuffs from all unit frames.")
    debuffInstructions:SetFullWidth(true)
    debuffBlacklistGroup:AddChild(debuffInstructions)
    
    -- Debuff Add section
    local debuffAddGroup = GUI:Create("InlineGroup")
    debuffAddGroup:SetLayout("Flow")
    debuffAddGroup:SetTitle("Add Debuff to Blacklist")
    debuffAddGroup:SetFullWidth(true)
    debuffAddGroup:SetHeight(70)
    debuffAddGroup:SetAutoAdjustHeight(true)
    debuffBlacklistGroup:AddChild(debuffAddGroup)
    
    -- Debuff Input field
    local debuffSpellInput = GUI:Create("EditBox")
    debuffSpellInput:SetLabel("Spell ID or Name")
    debuffSpellInput:SetRelativeWidth(0.7)
    debuffSpellInput:SetText("")
    debuffAddGroup:AddChild(debuffSpellInput)
    
    -- Debuff Add button
    local debuffAddButton = GUI:Create("Button")
    debuffAddButton:SetText("Add")
    debuffAddButton:SetRelativeWidth(0.3)
    debuffAddButton:SetCallback("OnClick", function()
        MilaUI:HandleAddToDebuffBlacklist(debuffSpellInput, debuffBlacklistGroup)
    end)
    debuffAddGroup:AddChild(debuffAddButton)
    
    -- Debuff blacklist display
    local debuffListGroup = GUI:Create("InlineGroup")
    debuffListGroup:SetLayout("Fill")
    debuffListGroup:SetTitle("Currently Blacklisted Debuffs")
    debuffListGroup:SetFullWidth(true)
    debuffListGroup:SetHeight(200)
    debuffListGroup:SetAutoAdjustHeight(false)
    debuffBlacklistGroup:AddChild(debuffListGroup)
    
    -- Debuff scrollframe
    local debuffScrollFrame = GUI:Create("ScrollFrame")
    debuffScrollFrame:SetLayout("List")
    debuffScrollFrame:SetFullWidth(true)
    debuffScrollFrame:SetFullHeight(true)
    debuffListGroup:AddChild(debuffScrollFrame)
    
    -- Store debuff references
    debuffBlacklistGroup.scrollFrame = debuffScrollFrame
    debuffBlacklistGroup.auraType = "debuff"
    
    -- Initial display for both
    MilaUI:RefreshBuffBlacklistDisplay(buffBlacklistGroup)
    MilaUI:RefreshDebuffBlacklistDisplay(debuffBlacklistGroup)
end

-- Buff blacklist handler
function MilaUI:HandleAddToBuffBlacklist(spellInput, blacklistGroup)
    local input = spellInput:GetText()
    if not input or input == "" then
        print("|cffff0000MilaUI:|r Please enter a spell name or ID")
        return
    end
    
    local spellID = tonumber(input)
    if not spellID then
        local name, _, _, _, _, _, id = GetSpellInfo(input)
        if id then
            spellID = id
        end
    end
    
    if not spellID or spellID <= 0 then
        print("|cffff0000MilaUI:|r Invalid input: '" .. input .. "' - must be a valid spell name or ID")
        return
    end
    
    local spellName = GetSpellInfo(spellID)
    if not spellName then
        print("|cffff0000MilaUI:|r Invalid spell ID: " .. spellID .. " - spell does not exist")
        return
    end
    
    if MilaUI.AddToBuffBlacklist then
        MilaUI:AddToBuffBlacklist(spellID)
        spellInput:SetText("")
        MilaUI:RefreshBuffBlacklistDisplay(blacklistGroup)
        print("|cff00ff00MilaUI:|r Added " .. spellName .. " (" .. spellID .. ") to buff blacklist")
    end
end

-- Debuff blacklist handler
function MilaUI:HandleAddToDebuffBlacklist(spellInput, blacklistGroup)
    local input = spellInput:GetText()
    if not input or input == "" then
        print("|cffff0000MilaUI:|r Please enter a spell name or ID")
        return
    end
    
    local spellID = tonumber(input)
    if not spellID then
        local name, _, _, _, _, _, id = GetSpellInfo(input)
        if id then
            spellID = id
        end
    end
    
    if not spellID or spellID <= 0 then
        print("|cffff0000MilaUI:|r Invalid input: '" .. input .. "' - must be a valid spell name or ID")
        return
    end
    
    local spellName = GetSpellInfo(spellID)
    if not spellName then
        print("|cffff0000MilaUI:|r Invalid spell ID: " .. spellID .. " - spell does not exist")
        return
    end
    
    if MilaUI.AddToDebuffBlacklist then
        MilaUI:AddToDebuffBlacklist(spellID)
        spellInput:SetText("")
        MilaUI:RefreshDebuffBlacklistDisplay(blacklistGroup)
        print("|cff00ff00MilaUI:|r Added " .. spellName .. " (" .. spellID .. ") to debuff blacklist")
    end
end

-- Buff blacklist display refresh
function MilaUI:RefreshBuffBlacklistDisplay(blacklistGroup)
    local scrollFrame = blacklistGroup.scrollFrame
    scrollFrame:ReleaseChildren()
    
    local blacklist = {}
    if MilaUI.GetBuffBlacklist then
        blacklist = MilaUI:GetBuffBlacklist()
    end
    
    for spellID, _ in pairs(blacklist) do
        local spellContainer = GUI:Create("InlineGroup")
        spellContainer:SetLayout("Flow")
        spellContainer:SetFullWidth(true)
        spellContainer:SetAutoAdjustHeight(true)
        spellContainer:SetTitle("")
        scrollFrame:AddChild(spellContainer)
        
        local spellName, _, spellIcon = GetSpellInfo(spellID)
        if not spellName then
            spellName = "Unknown Spell"
            spellIcon = "Interface\\Icons\\INV_Misc_QuestionMark"
        end
        
        local spellLabel = GUI:Create("Label")
        spellLabel:SetText("|T" .. spellIcon .. ":16|t " .. spellName .. " (" .. spellID .. ")")
        spellLabel:SetRelativeWidth(0.7)
        spellContainer:AddChild(spellLabel)
        
        local removeButton = GUI:Create("Button")
        removeButton:SetText("Remove")
        removeButton:SetRelativeWidth(0.3)
        removeButton:SetCallback("OnClick", function()
            if MilaUI.RemoveFromBuffBlacklist then
                MilaUI:RemoveFromBuffBlacklist(spellID)
                MilaUI:RefreshBuffBlacklistDisplay(blacklistGroup)
                print("|cff00ff00MilaUI:|r Removed " .. spellName .. " from buff blacklist")
            end
        end)
        spellContainer:AddChild(removeButton)
    end
    
    if not next(blacklist) then
        local emptyLabel = GUI:Create("Label")
        emptyLabel:SetText("No buffs currently blacklisted")
        emptyLabel:SetFullWidth(true)
        scrollFrame:AddChild(emptyLabel)
    end
end

-- Debuff blacklist display refresh
function MilaUI:RefreshDebuffBlacklistDisplay(blacklistGroup)
    local scrollFrame = blacklistGroup.scrollFrame
    scrollFrame:ReleaseChildren()
    
    local blacklist = {}
    if MilaUI.GetDebuffBlacklist then
        blacklist = MilaUI:GetDebuffBlacklist()
    end
    
    for spellID, _ in pairs(blacklist) do
        local spellContainer = GUI:Create("InlineGroup")
        spellContainer:SetLayout("Flow")
        spellContainer:SetFullWidth(true)
        spellContainer:SetAutoAdjustHeight(true)
        spellContainer:SetTitle("")
        scrollFrame:AddChild(spellContainer)
        
        local spellName, _, spellIcon = GetSpellInfo(spellID)
        if not spellName then
            spellName = "Unknown Spell"
            spellIcon = "Interface\\Icons\\INV_Misc_QuestionMark"
        end
        
        local spellLabel = GUI:Create("Label")
        spellLabel:SetText("|T" .. spellIcon .. ":16|t " .. spellName .. " (" .. spellID .. ")")
        spellLabel:SetRelativeWidth(0.7)
        spellContainer:AddChild(spellLabel)
        
        local removeButton = GUI:Create("Button")
        removeButton:SetText("Remove")
        removeButton:SetRelativeWidth(0.3)
        removeButton:SetCallback("OnClick", function()
            if MilaUI.RemoveFromDebuffBlacklist then
                MilaUI:RemoveFromDebuffBlacklist(spellID)
                MilaUI:RefreshDebuffBlacklistDisplay(blacklistGroup)
                print("|cff00ff00MilaUI:|r Removed " .. spellName .. " from debuff blacklist")
            end
        end)
        spellContainer:AddChild(removeButton)
    end
    
    if not next(blacklist) then
        local emptyLabel = GUI:Create("Label")
        emptyLabel:SetText("No debuffs currently blacklisted")
        emptyLabel:SetFullWidth(true)
        scrollFrame:AddChild(emptyLabel)
    end
end

function MilaUI:DrawDebuffsContainer(dbUnitName, contentFrame)
    local Debuffs = MilaUI.DB.profile.Unitframes[dbUnitName].Debuffs
    
    -- Debuffs Options Container
    MilaUI:CreateLargeHeading("Debuff Options", contentFrame)
    local DebuffsOptions = GUI:Create("InlineGroup")
    DebuffsOptions:SetLayout("Flow")
    DebuffsOptions:SetTitle(pink .. "General")
    DebuffsOptions:SetRelativeWidth(0.5)
    DebuffsOptions:SetHeight(170)
    DebuffsOptions:SetAutoAdjustHeight(false)
    contentFrame:AddChild(DebuffsOptions)

    --Size Container
    local sizeGroup = GUI:Create("InlineGroup")
    sizeGroup:SetLayout("Flow")
    sizeGroup:SetRelativeWidth(0.5)
    sizeGroup:SetTitle(pink .. "Size")
    sizeGroup:SetHeight(170)
    sizeGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(sizeGroup)
    
    --Icon Position Container
    local positionGroup = GUI:Create("InlineGroup")
    positionGroup:SetLayout("Flow")
    positionGroup:SetRelativeWidth(0.5)
    positionGroup:SetTitle(pink .. "Icon Position")
    positionGroup:SetHeight(130)
    positionGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(positionGroup)
    
    --Icon Anchor Container
    local anchorGroup = GUI:Create("InlineGroup")
    anchorGroup:SetLayout("Flow")
    anchorGroup:SetRelativeWidth(0.5)
    anchorGroup:SetTitle(pink .. "Icon Anchor")
    anchorGroup:SetHeight(130)
    anchorGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(anchorGroup)
    
    -- Enable Debuffs
    local DebuffsEnabled = GUI:Create("CheckBox")
    DebuffsEnabled:SetLabel("Enable Debuffs")
    DebuffsEnabled:SetValue(Debuffs.Enabled)
    DebuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Enabled = value MilaUI:UpdateFrames() end)
    DebuffsEnabled:SetRelativeWidth(0.5)
    DebuffsOptions:AddChild(DebuffsEnabled)
    
    -- Only Show Player Debuffs
    local OnlyShowPlayer = GUI:Create("CheckBox")
    OnlyShowPlayer:SetLabel("Only Show Player Debuffs")
    OnlyShowPlayer:SetValue(Debuffs.OnlyShowPlayer)
    OnlyShowPlayer:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.OnlyShowPlayer = value MilaUI:UpdateFrames() end)
    OnlyShowPlayer:SetRelativeWidth(0.5)
    DebuffsOptions:AddChild(OnlyShowPlayer)

    -- Smart Anchoring
    local SmartAnchoring = GUI:Create("CheckBox")
    SmartAnchoring:SetLabel("Smart Anchoring")
    SmartAnchoring:SetValue(Debuffs.SmartAnchoring)
    SmartAnchoring:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.SmartAnchoring = value MilaUI:UpdateFrames() end)
    SmartAnchoring:SetRelativeWidth(0.5)
    DebuffsOptions:AddChild(SmartAnchoring)

    -- Spacing
    local DebuffSpacing = GUI:Create("Slider")
    DebuffSpacing:SetLabel(lavender .. "Spacing")
    DebuffSpacing:SetSliderValues(0, 20, 1)
    DebuffSpacing:SetValue(Debuffs.Spacing)
    DebuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Spacing = value MilaUI:UpdateFrames() end)
    DebuffSpacing:SetRelativeWidth(0.5)
    DebuffsOptions:AddChild(DebuffSpacing)
    
    -- Growth Direction X
    local GrowthX = {
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right",
    }
    
    local DebuffGrowthX = GUI:Create("Dropdown")
    DebuffGrowthX:SetLabel(lavender .. "Growth Direction X")
    DebuffGrowthX:SetList(GrowthX)
    DebuffGrowthX:SetValue(Debuffs.GrowthX)
    DebuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthX = value MilaUI:UpdateFrames() end)
    DebuffGrowthX:SetRelativeWidth(0.5)
    DebuffsOptions:AddChild(DebuffGrowthX)
    
    -- Growth Direction Y
    local GrowthY = {
        ["UP"] = "Up",
        ["DOWN"] = "Down",
    }
    
    local DebuffGrowthY = GUI:Create("Dropdown")
    DebuffGrowthY:SetLabel(lavender .. "Growth Direction Y")
    DebuffGrowthY:SetList(GrowthY)
    DebuffGrowthY:SetValue(Debuffs.GrowthY)
    DebuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthY = value MilaUI:UpdateFrames() end)
    DebuffGrowthY:SetRelativeWidth(0.5)
    DebuffsOptions:AddChild(DebuffGrowthY)
    
    -- Size
    local DebuffSize = GUI:Create("Slider")
    DebuffSize:SetLabel(lavender .. "Size")
    DebuffSize:SetSliderValues(1, 64, 1)
    DebuffSize:SetValue(Debuffs.Size)
    DebuffSize:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Size = value MilaUI:UpdateFrames() end)
    DebuffSize:SetRelativeWidth(1)
    sizeGroup:AddChild(DebuffSize)
    
    -- Number to Show
    local DebuffNum = GUI:Create("Slider")
    DebuffNum:SetLabel(lavender .. "Amount To Show")
    DebuffNum:SetSliderValues(1, 40, 1)
    DebuffNum:SetValue(Debuffs.Num)
    DebuffNum:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Num = value MilaUI:UpdateFrames() end)
    DebuffNum:SetRelativeWidth(1)
    sizeGroup:AddChild(DebuffNum)

    -- Anchor Points
    local AnchorPoints = {
        ["TOPLEFT"] = "Top Left",
        ["TOP"] = "Top",
        ["TOPRIGHT"] = "Top Right",
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
        ["BOTTOMLEFT"] = "Bottom Left",
        ["BOTTOM"] = "Bottom",
        ["BOTTOMRIGHT"] = "Bottom Right",
    }
    -- Anchor Frame
    local AnchorFrameOptions = {
        ["HealthBar"] = "Health Bar",
        ["PowerBar"] = "Power Bar",
        ["Buffs"] = "Buffs",
        [Debuffs.AnchorFrame] = Debuffs.AnchorFrame, -- Add the current value if it's not in the list
    }
    
    local DebuffAnchorFrame = GUI:Create("Dropdown")
    DebuffAnchorFrame:SetLabel(lavender .. "Anchor Frame")
    DebuffAnchorFrame:SetList(AnchorFrameOptions)
    DebuffAnchorFrame:SetValue(Debuffs.AnchorFrame)
    DebuffAnchorFrame:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorFrame = value MilaUI:UpdateFrames() end)
    DebuffAnchorFrame:SetRelativeWidth(1)
    anchorGroup:AddChild(DebuffAnchorFrame)

    -- Anchor From
    local DebuffAnchorFrom = GUI:Create("Dropdown")
    DebuffAnchorFrom:SetLabel(lavender .. "Anchor From")
    DebuffAnchorFrom:SetList(AnchorPoints)
    DebuffAnchorFrom:SetValue(Debuffs.AnchorFrom)
    DebuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorFrom = value MilaUI:UpdateFrames() end)
    DebuffAnchorFrom:SetRelativeWidth(0.5)
    anchorGroup:AddChild(DebuffAnchorFrom)
    
    -- Anchor To
    local DebuffAnchorTo = GUI:Create("Dropdown")
    DebuffAnchorTo:SetLabel(lavender .. "Anchor To")
    DebuffAnchorTo:SetList(AnchorPoints)
    DebuffAnchorTo:SetValue(Debuffs.AnchorTo)
    DebuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorTo = value MilaUI:UpdateFrames() end)
    DebuffAnchorTo:SetRelativeWidth(0.5)
    anchorGroup:AddChild(DebuffAnchorTo)
    

    
    -- X Offset
    local DebuffXOffset = GUI:Create("Slider")
    DebuffXOffset:SetLabel(lavender .. "X Offset")
    DebuffXOffset:SetSliderValues(-50, 50, 1)
    DebuffXOffset:SetValue(Debuffs.XOffset)
    DebuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.XOffset = value MilaUI:UpdateFrames() end)
    DebuffXOffset:SetRelativeWidth(0.5)
    positionGroup:AddChild(DebuffXOffset)
    
    -- Y Offset
    local DebuffYOffset = GUI:Create("Slider")
    DebuffYOffset:SetLabel(lavender .. "Y Offset")
    DebuffYOffset:SetSliderValues(-50, 50, 1)
    DebuffYOffset:SetValue(Debuffs.YOffset)
    DebuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.YOffset = value MilaUI:UpdateFrames() end)
    DebuffYOffset:SetRelativeWidth(0.5)
    positionGroup:AddChild(DebuffYOffset)

    -- Debuff Count Options Section
    MilaUI:CreateLargeHeading(pink .. "Debuff Count Options", contentFrame)
    
    -- Debuff Count Font Container
    local countfontGroup = GUI:Create("InlineGroup")
    countfontGroup:SetLayout("Flow")
    countfontGroup:SetRelativeWidth(1)
    countfontGroup:SetTitle(pink .. "Font Options")
    contentFrame:AddChild(countfontGroup)
    
    -- Debuff Count Anchoring Options
    local countanchorGroup = GUI:Create("InlineGroup")
    countanchorGroup:SetLayout("Flow")
    countanchorGroup:SetRelativeWidth(0.5)
    countanchorGroup:SetTitle(pink .. "Count Text Anchor")
    contentFrame:AddChild(countanchorGroup)

    -- Debuff Count Position Container
    local countpositionGroup = GUI:Create("InlineGroup")
    countpositionGroup:SetLayout("Flow")
    countpositionGroup:SetRelativeWidth(0.5)
    countpositionGroup:SetTitle(pink .. "Count Text Position")
    contentFrame:AddChild(countpositionGroup)
    
    -- Count Anchor From
    local DebuffCountAnchorFrom = GUI:Create("Dropdown")
    DebuffCountAnchorFrom:SetLabel(lavender .. "Anchor From")
    DebuffCountAnchorFrom:SetList(AnchorPoints)
    DebuffCountAnchorFrom:SetValue(Debuffs.Count.AnchorFrom)
    DebuffCountAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.AnchorFrom = value MilaUI:UpdateFrames() end)
    DebuffCountAnchorFrom:SetRelativeWidth(1)
    countanchorGroup:AddChild(DebuffCountAnchorFrom)
    
    -- Count Anchor To
    local DebuffCountAnchorTo = GUI:Create("Dropdown")
    DebuffCountAnchorTo:SetLabel(lavender .. "Anchor To")
    DebuffCountAnchorTo:SetList(AnchorPoints)
    DebuffCountAnchorTo:SetValue(Debuffs.Count.AnchorTo)
    DebuffCountAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.AnchorTo = value MilaUI:UpdateFrames() end)
    DebuffCountAnchorTo:SetRelativeWidth(1)
    countanchorGroup:AddChild(DebuffCountAnchorTo)
    
    -- Count X Offset
    local DebuffCountXOffset = GUI:Create("Slider")
    DebuffCountXOffset:SetLabel(lavender .. "X Offset")
    DebuffCountXOffset:SetSliderValues(-64, 64, 1)
    DebuffCountXOffset:SetValue(Debuffs.Count.XOffset)
    DebuffCountXOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.XOffset = value MilaUI:UpdateFrames() end)
    DebuffCountXOffset:SetRelativeWidth(1)
    countpositionGroup:AddChild(DebuffCountXOffset)
    
    -- Count Y Offset
    local DebuffCountYOffset = GUI:Create("Slider")
    DebuffCountYOffset:SetLabel(lavender .. "Y Offset")
    DebuffCountYOffset:SetSliderValues(-64, 64, 1)
    DebuffCountYOffset:SetValue(Debuffs.Count.YOffset)
    DebuffCountYOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.YOffset = value MilaUI:UpdateFrames() end)
    DebuffCountYOffset:SetRelativeWidth(1)
    countpositionGroup:AddChild(DebuffCountYOffset)
    
    -- Count Color
    local DebuffCountColour = GUI:Create("ColorPicker")
    DebuffCountColour:SetLabel(lavender .. "Colour")
    local DCR, DCG, DCB, DCA = unpack(Debuffs.Count.Colour)
    DebuffCountColour:SetColor(DCR, DCG, DCB, DCA)
    DebuffCountColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Debuffs.Count.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
    DebuffCountColour:SetHasAlpha(true)
    DebuffCountColour:SetRelativeWidth(0.5)
    countfontGroup:AddChild(DebuffCountColour)
    
    -- Count Font Size
    local DebuffCountFontSize = GUI:Create("Slider")
    DebuffCountFontSize:SetLabel(lavender .. "Font Size")
    DebuffCountFontSize:SetSliderValues(1, 64, 1)
    DebuffCountFontSize:SetValue(Debuffs.Count.FontSize)
    DebuffCountFontSize:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.FontSize = value MilaUI:UpdateFrames() end)
    DebuffCountFontSize:SetRelativeWidth(0.5)
    countfontGroup:AddChild(DebuffCountFontSize)
    
    -- Font dropdown with preview
    local DebuffCountFont = GUI:Create("LSM30_Font")
    DebuffCountFont:SetLabel(lavender .. "Font")
    DebuffCountFont:SetList(LSM:HashTable(LSM.MediaType.FONT))
    DebuffCountFont:SetValue(Debuffs.Count.Font)
    DebuffCountFont:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.Font = value MilaUI:UpdateFrames() end)
    DebuffCountFont:SetRelativeWidth(0.7)
    countfontGroup:AddChild(DebuffCountFont)
    
    -- Font flags
    local fontFlags = {
        ["OUTLINE"] = "Outline",
        ["THICKOUTLINE"] = "Thick Outline",
        ["MONOCHROME"] = "Monochrome",
        ["NONE"] = "None"
    }
    
    local DebuffCountFontFlags = GUI:Create("Dropdown")
    DebuffCountFontFlags:SetLabel(lavender .. "Outline")
    DebuffCountFontFlags:SetList(fontFlags)
    DebuffCountFontFlags:SetValue(Debuffs.Count.FontFlags)
    DebuffCountFontFlags:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.FontFlags = value MilaUI:UpdateFrames() end)
    DebuffCountFontFlags:SetRelativeWidth(0.3)
    countfontGroup:AddChild(DebuffCountFontFlags)
end
