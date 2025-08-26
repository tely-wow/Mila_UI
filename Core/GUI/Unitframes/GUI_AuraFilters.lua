local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0") 
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
MilaUI.GUI = GUI


-- Draw buff filter container
function MilaUI:DrawBuffFilterContainer(contentFrame)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    if MilaUI.DB.global.DebugMode then
        print(pink .. "Opening Buff Filter GUI")
    end
    
    if MilaUI.DB and MilaUI.DB.profile then
        if MilaUI.DB.global.DebugMode then
            print("|cff00ff00[GUI DEBUG]|r Database exists")
        end
        local filters = MilaUI.DB.profile.AuraFilters
        if filters and filters.Buffs then
            if MilaUI.DB.global.DebugMode then
                print("|cff00ff00[GUI DEBUG]|r Buff filters exist")
            end
            if filters.Buffs.DurationFilter then
                if MilaUI.DB.global.DebugMode then
                    print("|cff00ff00[GUI DEBUG]|r DurationFilter exists - Enabled:", tostring(filters.Buffs.DurationFilter.Enabled), "MinDuration:", tostring(filters.Buffs.DurationFilter.MinDuration))
                end
            else
                if MilaUI.DB.global.DebugMode then
                    print("|cff00ff00[GUI DEBUG]|r DurationFilter does NOT exist")
                end
            end
        else
            if MilaUI.DB.global.DebugMode then
                print("|cff00ff00[GUI DEBUG]|r Buff filters do NOT exist")
            end
        end
    else
        if MilaUI.DB.global.DebugMode then
            print("|cff00ff00[GUI DEBUG]|r Database does NOT exist")
        end
    end
    
    -- Create buff duration filter section
    local buffDurationGroup = GUI:Create("InlineGroup")
    buffDurationGroup:SetLayout("Flow")
    buffDurationGroup:SetTitle(pink .. "Buff Duration Filter")
    buffDurationGroup:SetFullWidth(true)
    buffDurationGroup:SetHeight(120)
    buffDurationGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(buffDurationGroup)
    
    -- Duration filter instructions
    local durationInstructions = GUI:Create("Label")
    durationInstructions:SetText("Hide buffs with duration longer than the specified time (in seconds).")
    durationInstructions:SetFullWidth(true)
    buffDurationGroup:AddChild(durationInstructions)
    
    -- Duration filter enabled checkbox
    local durationEnabled = GUI:Create("CheckBox")
    durationEnabled:SetLabel("Enable Duration Filter")
    durationEnabled:SetValue(MilaUI.DB.profile.AuraFilters.Buffs.DurationFilter.Enabled)
    durationEnabled:SetCallback("OnValueChanged", function(widget, event, value)
        MilaUI.DB.profile.AuraFilters.Buffs.DurationFilter.Enabled = value
        MilaUI:UpdateAllUnitFrames()
    end)
    durationEnabled:SetRelativeWidth(0.5)
    buffDurationGroup:AddChild(durationEnabled)
    
    -- Duration threshold input
    local durationInput = GUI:Create("EditBox")
    durationInput:SetLabel("Max Duration (seconds)")
    durationInput:SetText(tostring(MilaUI.DB.profile.AuraFilters.Buffs.DurationFilter.MinDuration))
    durationInput:SetCallback("OnEnterPressed", function(widget, event, value)
        local duration = tonumber(value)
        if duration and duration > 0 then
            MilaUI.DB.profile.AuraFilters.Buffs.DurationFilter.MinDuration = duration
            MilaUI:UpdateAllUnitFrames()
            print("|cff00ff00MilaUI:|r Buff duration filter set to " .. duration .. " seconds")
        else
            print("|cffff0000MilaUI:|r Invalid duration value")
            widget:SetText(tostring(MilaUI.DB.profile.AuraFilters.Buffs.DurationFilter.MinDuration))
        end
    end)
    durationInput:SetRelativeWidth(0.5)
    buffDurationGroup:AddChild(durationInput)

    -- Create buff blacklist section
    local buffBlacklistGroup = GUI:Create("InlineGroup")
    buffBlacklistGroup:SetLayout("Flow")
    buffBlacklistGroup:SetTitle(pink .. "Buff Blacklist")
    buffBlacklistGroup:SetFullWidth(true)
    buffBlacklistGroup:SetHeight(450)
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
    buffAddGroup:SetHeight(80)
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
    buffListGroup:SetHeight(280)
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
    
    -- Initial display
    MilaUI:RefreshBuffBlacklistDisplay(buffBlacklistGroup)
end

-- Draw debuff filter container
function MilaUI:DrawDebuffFilterContainer(contentFrame)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    -- Create debuff duration filter section
    local debuffDurationGroup = GUI:Create("InlineGroup")
    debuffDurationGroup:SetLayout("Flow")
    debuffDurationGroup:SetTitle(pink .. "Debuff Duration Filter")
    debuffDurationGroup:SetFullWidth(true)
    debuffDurationGroup:SetHeight(120)
    debuffDurationGroup:SetAutoAdjustHeight(false)
    contentFrame:AddChild(debuffDurationGroup)
    
    -- Duration filter instructions
    local durationInstructions = GUI:Create("Label")
    durationInstructions:SetText("Hide debuffs with duration longer than the specified time (in seconds).")
    durationInstructions:SetFullWidth(true)
    debuffDurationGroup:AddChild(durationInstructions)
    
    -- Duration filter enabled checkbox
    local durationEnabled = GUI:Create("CheckBox")
    durationEnabled:SetLabel("Enable Duration Filter")
    durationEnabled:SetValue(MilaUI.DB.profile.AuraFilters.Debuffs.DurationFilter.Enabled)
    durationEnabled:SetCallback("OnValueChanged", function(widget, event, value)
        MilaUI.DB.profile.AuraFilters.Debuffs.DurationFilter.Enabled = value
        MilaUI:UpdateAllUnitFrames()
    end)
    durationEnabled:SetRelativeWidth(0.5)
    debuffDurationGroup:AddChild(durationEnabled)
    
    -- Duration threshold input
    local durationInput = GUI:Create("EditBox")
    durationInput:SetLabel("Max Duration (seconds)")
    durationInput:SetText(tostring(MilaUI.DB.profile.AuraFilters.Debuffs.DurationFilter.MinDuration))
    durationInput:SetCallback("OnEnterPressed", function(widget, event, value)
        local duration = tonumber(value)
        if duration and duration > 0 then
            MilaUI.DB.profile.AuraFilters.Debuffs.DurationFilter.MinDuration = duration
            MilaUI:UpdateAllUnitFrames()
            print("|cff00ff00MilaUI:|r Debuff duration filter set to " .. duration .. " seconds")
        else
            print("|cffff0000MilaUI:|r Invalid duration value")
            widget:SetText(tostring(MilaUI.DB.profile.AuraFilters.Debuffs.DurationFilter.MinDuration))
        end
    end)
    durationInput:SetRelativeWidth(0.5)
    debuffDurationGroup:AddChild(durationInput)

    -- Create debuff blacklist section
    local debuffBlacklistGroup = GUI:Create("InlineGroup")
    debuffBlacklistGroup:SetLayout("Flow")
    debuffBlacklistGroup:SetTitle(pink .. "Debuff Blacklist")
    debuffBlacklistGroup:SetFullWidth(true)
    debuffBlacklistGroup:SetHeight(450)
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
    debuffAddGroup:SetHeight(80)
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
    debuffListGroup:SetHeight(280)
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
    
    -- Initial display
    MilaUI:RefreshDebuffBlacklistDisplay(debuffBlacklistGroup)
end

-- Buff blacklist handler
function MilaUI:HandleAddToBuffBlacklist(spellInput, blacklistGroup)
    local pink = MilaUI.DB.global.Colors.pink
local lavender = MilaUI.DB.global.Colors.lavender
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
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
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
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
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
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
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