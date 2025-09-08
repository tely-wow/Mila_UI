local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0")
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")

-- Helper function to create consistent labels using proper AceGUI APIs
local function CreateLabel(text, width)
    local label = GUI:Create("Label")
    label:SetText(text or "")
    
    if width then
        if width < 1 then
            label:SetRelativeWidth(width)
        else
            label:SetFullWidth(true)
        end
    else
        label:SetFullWidth(true)
    end
    
    return label
end

-- Main function to draw the Aura Filters tab for a unit
function MilaUI:DrawAuraFiltersTab(container, unitName)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    local white = MilaUI.DB.global.Colors.white
    
    container:ReleaseChildren()
    container:SetLayout("Flow")
    
    -- Get the unit's filter configuration
    local unitFilters = MilaUI.DB.profile.AuraFilters.UnitFilters[unitName]
    if not unitFilters then
        local errorLabel = GUI:Create("Label")
        errorLabel:SetText("|cffff0000Error: No filter configuration found for " .. unitName .. "|r")
        container:AddChild(errorLabel)
        return
    end
    
    -- Main enable checkbox
    local mainEnable = GUI:Create("CheckBox")
    mainEnable:SetLabel(pink .. "Enable Aura Filtering for " .. unitName)
    mainEnable:SetValue(unitFilters.Buffs.enabled or unitFilters.Debuffs.enabled)
    mainEnable:SetFullWidth(true)
    mainEnable:SetCallback("OnValueChanged", function(widget, event, value)
        unitFilters.Buffs.enabled = value
        unitFilters.Debuffs.enabled = value
        MilaUI:UpdateFrames()
    end)
    container:AddChild(mainEnable)
    
    -- Add some spacing
    local spacer1 = GUI:Create("Label")
    spacer1:SetText(" ")
    spacer1:SetFullWidth(true)
    container:AddChild(spacer1)
    
    -- Create tab group for Buffs and Debuffs
    local tabGroup = GUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")  -- Changed to Fill for ScrollFrame compatibility
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    tabGroup:SetTabs({
        {text = "Buff Filters", value = "buffs"},
        {text = "Debuff Filters", value = "debuffs"}
    })
    
    tabGroup:SetCallback("OnGroupSelected", function(widget, event, group)
        widget:ReleaseChildren()
        
        local auraType = group == "buffs" and "Buffs" or "Debuffs"
        local filterConfig = unitFilters[auraType]
        
        -- Create container for ScrollFrame (required by AceGUI docs)
        local scrollContainer = GUI:Create("SimpleGroup")
        scrollContainer:SetFullWidth(true)
        scrollContainer:SetFullHeight(true)
        scrollContainer:SetLayout("Fill")  -- MUST be Fill for ScrollFrame
        widget:AddChild(scrollContainer)
        
        -- Create scrollable container for the content
        local scrollFrame = GUI:Create("ScrollFrame")
        scrollFrame:SetLayout("Flow")
        scrollFrame:SetFullWidth(true)
        scrollFrame:SetFullHeight(true)
        scrollContainer:AddChild(scrollFrame)
        
        -- Draw the filter configuration for this aura type
        MilaUI:DrawFilterConfig(scrollFrame, unitName, auraType, filterConfig)
        
        -- Force layout update for tab content - only call on outermost container
        widget:DoLayout()
    end)
    
    container:AddChild(tabGroup)
    
    -- Select default tab
    tabGroup:SelectTab("buffs")
end

-- Draw filter configuration for buffs or debuffs
function MilaUI:DrawFilterConfig(container, unitName, auraType, filterConfig)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    
    -- Enable checkbox for this aura type
    local enableCheck = GUI:Create("CheckBox")
    enableCheck:SetLabel(pink .. "Enable " .. auraType .. " Filtering")
    enableCheck:SetValue(filterConfig.enabled)
    enableCheck:SetFullWidth(true)
    enableCheck:SetCallback("OnValueChanged", function(widget, event, value)
        filterConfig.enabled = value
        MilaUI:UpdateFrames()
    end)
    container:AddChild(enableCheck)
    
    
    -- Rules section header
    MilaUI:CreateLargeHeading("Filter Rules (Priority Order)", container, 14)
    
    local rulesGroup = GUI:Create("InlineGroup")
    rulesGroup:SetLayout("Flow")
    rulesGroup:SetFullWidth(true)
    container:AddChild(rulesGroup)
    
    -- Draw existing rules
    MilaUI:DrawRulesList(rulesGroup, unitName, auraType, filterConfig)
    -- Don't call DoLayout here - it's called at the end of DrawFilterConfig
    
    -- Add new rule button
    local addRuleButton = GUI:Create("Button")
    addRuleButton:SetText("Add New Rule")
    addRuleButton:SetFullWidth(true)
    addRuleButton:SetCallback("OnClick", function()
        MilaUI:ShowAddRuleDialog(unitName, auraType, filterConfig)
    end)
    container:AddChild(addRuleButton)
    
    -- Force layout update only if not called from within a resize
    if not container:GetUserData("isLayouting") then
        container:SetUserData("isLayouting", true)
        container:DoLayout()
        container:SetUserData("isLayouting", false)
    end
end

-- Draw the list of rules
function MilaUI:DrawRulesList(container, unitName, auraType, filterConfig)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    
    -- Clear any existing children first
    container:ReleaseChildren()
    
    -- Count non-deleted rules
    local activeRulesCount = 0
    if filterConfig.rules then
        for _, rule in ipairs(filterConfig.rules) do
            if not rule.deleted then
                activeRulesCount = activeRulesCount + 1
            end
        end
    end
    
    if activeRulesCount == 0 then
        local noRulesLabel = CreateLabel("|cff888888No rules configured. Click 'Add New Rule' to create one.|r")
        container:AddChild(noRulesLabel)
        return
    end
    
    -- Sort rules by order
    local sortedRules = {}
    for i, rule in ipairs(filterConfig.rules) do
        table.insert(sortedRules, {index = i, rule = rule})
    end
    table.sort(sortedRules, function(a, b) 
        return (a.rule.order or 999) < (b.rule.order or 999)
    end)
    
    -- Draw each rule (skip deleted rules)
    for _, ruleData in ipairs(sortedRules) do
        local rule = ruleData.rule
        local index = ruleData.index
        
        -- Only draw non-deleted rules
        if not rule.deleted then
        
        local ruleGroup = GUI:Create("SimpleGroup")
        ruleGroup:SetLayout("Flow")
        ruleGroup:SetFullWidth(true)
        container:AddChild(ruleGroup)
        
        -- Priority controls (up/down)
        local upButton = GUI:Create("Button")
        upButton:SetText("↑")
        upButton:SetRelativeWidth(0.05)
        upButton:SetCallback("OnClick", function()
            if rule.order > 1 then
                -- Find rule with order - 1 and swap
                for _, otherRule in ipairs(filterConfig.rules) do
                    if otherRule.order == rule.order - 1 then
                        otherRule.order = rule.order
                        rule.order = rule.order - 1
                        break
                    end
                end
                -- Invalidate cache for this specific unit/aura type
                if MilaUI.FilterEngine then
                    MilaUI.FilterEngine:InvalidateCache(unitName, auraType)
                end
                MilaUI:UpdateFrames()
                -- Just redraw the rules list since we clear children in DrawRulesList now
                MilaUI:DrawRulesList(container, unitName, auraType, filterConfig)
                -- Don't call DoLayout here - DrawRulesList already does it
            end
        end)
        ruleGroup:AddChild(upButton)
        
        local downButton = GUI:Create("Button")
        downButton:SetText("↓")
        downButton:SetRelativeWidth(0.05)
        downButton:SetCallback("OnClick", function()
            local maxOrder = #filterConfig.rules
            if rule.order < maxOrder then
                -- Find rule with order + 1 and swap
                for _, otherRule in ipairs(filterConfig.rules) do
                    if otherRule.order == rule.order + 1 then
                        otherRule.order = rule.order
                        rule.order = rule.order + 1
                        break
                    end
                end
                -- Invalidate cache for this specific unit/aura type
                if MilaUI.FilterEngine then
                    MilaUI.FilterEngine:InvalidateCache(unitName, auraType)
                end
                MilaUI:UpdateFrames()
                -- Just redraw the rules list since we clear children in DrawRulesList now
                MilaUI:DrawRulesList(container, unitName, auraType, filterConfig)
                -- Don't call DoLayout here - DrawRulesList already does it
            end
        end)
        ruleGroup:AddChild(downButton)
        
        -- Enable checkbox
        local enableCheck = GUI:Create("CheckBox")
        enableCheck:SetLabel("Enabled")
        enableCheck:SetValue(rule.enabled)
        enableCheck:SetRelativeWidth(0.15) -- Increased for full word
        enableCheck:SetCallback("OnValueChanged", function(widget, event, value)
            rule.enabled = value
            -- Invalidate cache for this specific unit/aura type
            if MilaUI.FilterEngine then
                MilaUI.FilterEngine:InvalidateCache(unitName, auraType)
            end
            MilaUI:UpdateFrames()
        end)
        ruleGroup:AddChild(enableCheck)
        
        -- Rule type and name - adjust width to make room for checkbox
        local ruleTypeInfo = MilaUI.DB.profile.AuraFilters.RuleTypes[rule.type] or {name = rule.type}
        local actionColor = rule.action == "allow" and "|cff00ff00" or "|cffff0000"
        local actionText = rule.action == "allow" and "ALLOW" or "DENY"
        
        -- Build text with explicit color reset after each color section
        local ruleText = string.format("[%s%s|r] %s - %s", 
            actionColor, actionText, ruleTypeInfo.name, rule.name or "Unnamed Rule")
        
        local ruleLabel = CreateLabel(ruleText, 0.45) -- Adjusted for full button text
        ruleGroup:AddChild(ruleLabel)
        
        -- Edit button
        local editButton = GUI:Create("Button")
        editButton:SetText("Edit")
        editButton:SetRelativeWidth(0.15) -- Increased for consistency
        editButton:SetCallback("OnClick", function()
            MilaUI:ShowEditRuleDialog(unitName, auraType, filterConfig, index, rule)
        end)
        ruleGroup:AddChild(editButton)
        
        -- Delete button
        local deleteButton = GUI:Create("Button")
        deleteButton:SetText("Delete")
        deleteButton:SetRelativeWidth(0.15) -- Increased for full word
        deleteButton:SetCallback("OnClick", function()
            -- Mark the rule as deleted instead of removing it
            rule.deleted = true
            
            if MilaUI.DB.global.DebugMode then
                print("|cffff0000[FILTER DELETE]|r Marked rule '" .. (rule.name or "unnamed") .. "' as deleted")
            end
            
            -- Invalidate cache for this specific unit/aura type
            if MilaUI.FilterEngine then
                MilaUI.FilterEngine:InvalidateCache(unitName, auraType)
            end
            MilaUI:UpdateFrames()
            -- Just redraw the rules list since we clear children in DrawRulesList now
            MilaUI:DrawRulesList(container, unitName, auraType, filterConfig)
            -- Don't call DoLayout here - DrawRulesList already does it
        end)
        ruleGroup:AddChild(deleteButton)
        
        end -- End of if not rule.deleted
    end
    
    -- Force layout update after drawing all rules only if not already layouting
    if not container:GetUserData("isLayouting") then
        container:SetUserData("isLayouting", true)
        container:DoLayout()
        container:SetUserData("isLayouting", false)
    end
end

-- Show dialog to add a new rule
function MilaUI:ShowAddRuleDialog(unitName, auraType, filterConfig)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    
    -- Create frame
    local frame = GUI:Create("Frame")
    frame:SetTitle("Add New Filter Rule")
    frame:SetWidth(500)
    frame:SetHeight(400)
    frame:SetLayout("Flow")
    frame:SetCallback("OnClose", function(widget) GUI:Release(widget) end)
    
    -- Rule type dropdown
    local typeLabel = GUI:Create("Label")
    typeLabel:SetText(lavender .. "Rule Type:")
    typeLabel:SetFullWidth(true)
    frame:AddChild(typeLabel)
    
    local ruleTypes = MilaUI.DB.profile.AuraFilters.RuleTypes
    local typeList = {}
    local typeOrder = {"duration", "spellList", "caster", "dispellable", "stealable", "any"}
    
    for _, typeName in ipairs(typeOrder) do
        local typeInfo = ruleTypes[typeName]
        if typeInfo then
            typeList[typeName] = typeInfo.name .. " - " .. typeInfo.description
        end
    end
    
    local typeDropdown = GUI:Create("Dropdown")
    typeDropdown:SetList(typeList)
    typeDropdown:SetFullWidth(true)
    frame:AddChild(typeDropdown)
    
    -- Rule name
    local nameLabel = GUI:Create("Label")
    nameLabel:SetText(lavender .. "Rule Name (optional):")
    nameLabel:SetFullWidth(true)
    frame:AddChild(nameLabel)
    
    local nameInput = GUI:Create("EditBox")
    nameInput:SetFullWidth(true)
    frame:AddChild(nameInput)
    
    -- Action dropdown
    local actionLabel = GUI:Create("Label")
    actionLabel:SetText(lavender .. "Action:")
    actionLabel:SetFullWidth(true)
    frame:AddChild(actionLabel)
    
    local actionDropdown = GUI:Create("Dropdown")
    actionDropdown:SetList({
        ["allow"] = "Allow (Show matching auras)",
        ["deny"] = "Deny (Hide matching auras)"
    })
    actionDropdown:SetValue("deny")
    actionDropdown:SetFullWidth(true)
    frame:AddChild(actionDropdown)
    
    -- Parameters section (placeholder)
    local paramsGroup = GUI:Create("InlineGroup")
    paramsGroup:SetTitle("Rule Parameters")
    paramsGroup:SetLayout("Flow")
    paramsGroup:SetFullWidth(true)
    frame:AddChild(paramsGroup)
    
    local paramsLabel = GUI:Create("Label")
    paramsLabel:SetText("Select a rule type to configure parameters")
    paramsLabel:SetFullWidth(true)
    paramsGroup:AddChild(paramsLabel)
    
    -- Update parameters when type changes
    typeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        paramsGroup:ReleaseChildren()
        if value then
            nameInput:SetText(ruleTypes[value].name or value)
            MilaUI:DrawRuleParameters(paramsGroup, value, {})
            -- Force complete layout update after changing parameters
            -- Need to update from innermost to outermost
            paramsGroup:DoLayout()
            -- Small delay to ensure widgets are properly initialized
            C_Timer.After(0.01, function()
                frame:DoLayout()
            end)
        end
    end)
    
    -- Buttons
    local buttonGroup = GUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    frame:AddChild(buttonGroup)
    
    local createButton = GUI:Create("Button")
    createButton:SetText("Create Rule")
    createButton:SetRelativeWidth(0.5)
    createButton:SetCallback("OnClick", function()
        local ruleType = typeDropdown:GetValue()
        if not ruleType then
            print("|cffff0000Please select a rule type|r")
            return
        end
        
        -- Create new rule
        local newRule = {
            order = #filterConfig.rules + 1,
            enabled = true,
            type = ruleType,
            action = actionDropdown:GetValue(),
            name = nameInput:GetText(),
            params = {}
        }
        
        -- Get parameters from the form
        local paramGetters = paramsGroup:GetUserData("paramGetters")
        if paramGetters then
            for paramName, getter in pairs(paramGetters) do
                if paramName == "size" then
                    newRule.size = getter()
                else
                    newRule.params[paramName] = getter()
                end
            end
        end
        
        -- Add default parameters based on type
        local typeInfo = ruleTypes[ruleType]
        if typeInfo and typeInfo.params then
            for paramName, paramInfo in pairs(typeInfo.params) do
                if newRule.params[paramName] == nil then
                    newRule.params[paramName] = paramInfo.default
                end
            end
        end
        
        -- Add to rules list
        table.insert(filterConfig.rules, newRule)
        
        if MilaUI.DB.global.DebugMode then
            print("|cff00ff00[FILTER SAVE]|r Added rule '" .. newRule.name .. "' to " .. unitName .. " " .. auraType .. ". Total rules: " .. #filterConfig.rules)
        end
        
        -- Invalidate cache for this specific unit/aura type
        if MilaUI.FilterEngine then
            MilaUI.FilterEngine:InvalidateCache(unitName, auraType)
        end
        MilaUI:UpdateFrames()
        frame:Release()
    end)
    buttonGroup:AddChild(createButton)
    
    local cancelButton = GUI:Create("Button")
    cancelButton:SetText("Cancel")
    cancelButton:SetRelativeWidth(0.5)
    cancelButton:SetCallback("OnClick", function()
        frame:Release()
    end)
    buttonGroup:AddChild(cancelButton)
    
    -- Force initial layout
    frame:DoLayout()
end

-- Show dialog to edit an existing rule
function MilaUI:ShowEditRuleDialog(unitName, auraType, filterConfig, ruleIndex, rule)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    
    -- Create frame
    local frame = GUI:Create("Frame")
    frame:SetTitle("Edit Filter Rule")
    frame:SetWidth(500)
    frame:SetHeight(450)
    frame:SetLayout("Flow")
    frame:SetCallback("OnClose", function(widget) GUI:Release(widget) end)
    
    local ruleTypes = MilaUI.DB.profile.AuraFilters.RuleTypes
    local typeInfo = ruleTypes[rule.type] or {name = rule.type}
    
    -- Rule type (read-only)
    local typeLabel = GUI:Create("Label")
    typeLabel:SetText(lavender .. "Rule Type: " .. pink .. typeInfo.name)
    typeLabel:SetFullWidth(true)
    frame:AddChild(typeLabel)
    
    -- Rule name
    local nameLabel = GUI:Create("Label")
    nameLabel:SetText(lavender .. "Rule Name:")
    nameLabel:SetFullWidth(true)
    frame:AddChild(nameLabel)
    
    local nameInput = GUI:Create("EditBox")
    nameInput:SetText(rule.name or "")
    nameInput:SetFullWidth(true)
    frame:AddChild(nameInput)
    
    -- Action dropdown
    local actionLabel = GUI:Create("Label")
    actionLabel:SetText(lavender .. "Action:")
    actionLabel:SetFullWidth(true)
    frame:AddChild(actionLabel)
    
    local actionDropdown = GUI:Create("Dropdown")
    actionDropdown:SetList({
        ["allow"] = "Allow (Show matching auras)",
        ["deny"] = "Deny (Hide matching auras)"
    })
    actionDropdown:SetValue(rule.action)
    actionDropdown:SetFullWidth(true)
    frame:AddChild(actionDropdown)
    
    -- Parameters section
    local paramsGroup = GUI:Create("InlineGroup")
    paramsGroup:SetTitle("Rule Parameters")
    paramsGroup:SetLayout("Flow")
    paramsGroup:SetFullWidth(true)
    frame:AddChild(paramsGroup)
    
    -- Draw parameters for this rule type
    -- Combine params and size for the parameter drawer
    local paramsWithSize = {}
    for k, v in pairs(rule.params or {}) do
        paramsWithSize[k] = v
    end
    paramsWithSize.size = rule.size
    MilaUI:DrawRuleParameters(paramsGroup, rule.type, paramsWithSize)
    
    -- Force layout update for parameters
    paramsGroup:DoLayout()
    
    -- Buttons
    local buttonGroup = GUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    frame:AddChild(buttonGroup)
    
    local saveButton = GUI:Create("Button")
    saveButton:SetText("Save Changes")
    saveButton:SetRelativeWidth(0.5)
    saveButton:SetCallback("OnClick", function()
        -- Update rule
        rule.name = nameInput:GetText()
        rule.action = actionDropdown:GetValue()
        
        -- Get parameters from the form
        local paramGetters = paramsGroup:GetUserData("paramGetters")
        if paramGetters then
            for paramName, getter in pairs(paramGetters) do
                if paramName == "size" then
                    rule.size = getter()
                else
                    rule.params[paramName] = getter()
                end
            end
        end
        
        if MilaUI.DB.global.DebugMode then
            print("|cff00ffff[FILTER EDIT]|r Updated rule '" .. rule.name .. "'")
        end
        
        -- Invalidate cache for this specific unit/aura type
        if MilaUI.FilterEngine then
            MilaUI.FilterEngine:InvalidateCache(unitName, auraType)
        end
        MilaUI:UpdateFrames()
        frame:Release()
    end)
    buttonGroup:AddChild(saveButton)
    
    local cancelButton = GUI:Create("Button")
    cancelButton:SetText("Cancel")
    cancelButton:SetRelativeWidth(0.5)
    cancelButton:SetCallback("OnClick", function()
        frame:Release()
    end)
    buttonGroup:AddChild(cancelButton)
    
    -- Force initial layout
    frame:DoLayout()
end

-- Draw parameter controls for a specific rule type
function MilaUI:DrawRuleParameters(container, ruleType, currentParams)
    local pink = MilaUI.DB.global.Colors.pink
    local lavender = MilaUI.DB.global.Colors.lavender
    
    local ruleTypes = MilaUI.DB.profile.AuraFilters.RuleTypes
    local typeInfo = ruleTypes[ruleType]
    
    if not typeInfo or not typeInfo.params then
        local label = GUI:Create("Label")
        label:SetText("No parameters for this rule type")
        label:SetFullWidth(true)
        container:AddChild(label)
        return
    end
    
    -- Store getter functions for parameters using UserData
    local paramGetters = container:GetUserData("paramGetters")
    if not paramGetters then
        paramGetters = {}
        container:SetUserData("paramGetters", paramGetters)
    end
    
    -- Draw controls based on rule type
    if ruleType == "duration" then
        -- Min duration
        local minLabel = GUI:Create("Label")
        minLabel:SetText(lavender .. "Minimum Duration (seconds):")
        minLabel:SetFullWidth(true)
        container:AddChild(minLabel)
        
        local minSlider = GUI:Create("Slider")
        minSlider:SetSliderValues(0, 3600, 1)
        minSlider:SetValue(currentParams.minDuration or 0)
        minSlider:SetFullWidth(true)
        container:AddChild(minSlider)
        
        -- Max duration
        local maxLabel = GUI:Create("Label")
        maxLabel:SetText(lavender .. "Maximum Duration (seconds):")
        maxLabel:SetFullWidth(true)
        container:AddChild(maxLabel)
        
        local maxSlider = GUI:Create("Slider")
        maxSlider:SetSliderValues(1, 3600, 1)
        maxSlider:SetValue(currentParams.maxDuration or 60)
        maxSlider:SetFullWidth(true)
        container:AddChild(maxSlider)
        
        -- Include permanent
        local permCheck = GUI:Create("CheckBox")
        permCheck:SetLabel("Include permanent auras (no duration)")
        permCheck:SetValue(currentParams.includePermanent or false)
        permCheck:SetFullWidth(true)
        container:AddChild(permCheck)
        
        paramGetters.minDuration = function() return minSlider:GetValue() end
        paramGetters.maxDuration = function() return maxSlider:GetValue() end
        paramGetters.includePermanent = function() return permCheck:GetValue() end
        
    elseif ruleType == "spellList" then
        -- Spell ID management
        local spellLabel = GUI:Create("Label")
        spellLabel:SetText(lavender .. "Spell IDs (one per line):")
        spellLabel:SetFullWidth(true)
        container:AddChild(spellLabel)
        
        local spellInput = GUI:Create("MultiLineEditBox")
        spellInput:SetNumLines(8)
        spellInput:SetFullWidth(true)
        
        -- Convert current spell IDs to text
        local spellText = ""
        if currentParams.spellIds then
            for spellId, _ in pairs(currentParams.spellIds) do
                spellText = spellText .. spellId .. "\n"
            end
        end
        spellInput:SetText(spellText)
        container:AddChild(spellInput)
        
        paramGetters.spellIds = function()
            local ids = {}
            for line in spellInput:GetText():gmatch("[^\r\n]+") do
                local id = tonumber(line:match("%d+"))
                if id then
                    ids[id] = true
                end
            end
            return ids
        end
        
    elseif ruleType == "caster" then
        -- Caster checkboxes
        local playerCheck = GUI:Create("CheckBox")
        playerCheck:SetLabel("Player")
        playerCheck:SetValue(currentParams.player or false)
        playerCheck:SetRelativeWidth(0.25)
        container:AddChild(playerCheck)
        
        local petCheck = GUI:Create("CheckBox")
        petCheck:SetLabel("Pet")
        petCheck:SetValue(currentParams.pet or false)
        petCheck:SetRelativeWidth(0.25)
        container:AddChild(petCheck)
        
        local vehicleCheck = GUI:Create("CheckBox")
        vehicleCheck:SetLabel("Vehicle")
        vehicleCheck:SetValue(currentParams.vehicle or false)
        vehicleCheck:SetRelativeWidth(0.25)
        container:AddChild(vehicleCheck)
        
        local bossCheck = GUI:Create("CheckBox")
        bossCheck:SetLabel("Boss")
        bossCheck:SetValue(currentParams.boss or false)
        bossCheck:SetRelativeWidth(0.25)
        container:AddChild(bossCheck)
        
        local othersCheck = GUI:Create("CheckBox")
        othersCheck:SetLabel("Others")
        othersCheck:SetValue(currentParams.others ~= false)
        othersCheck:SetRelativeWidth(0.25)
        container:AddChild(othersCheck)
        
        paramGetters.player = function() return playerCheck:GetValue() end
        paramGetters.pet = function() return petCheck:GetValue() end
        paramGetters.vehicle = function() return vehicleCheck:GetValue() end
        paramGetters.boss = function() return bossCheck:GetValue() end
        paramGetters.others = function() return othersCheck:GetValue() end
        
    elseif ruleType == "dispellable" then
        -- Dispel type checkboxes
        local magicCheck = GUI:Create("CheckBox")
        magicCheck:SetLabel("Magic")
        magicCheck:SetValue(currentParams.magic or false)
        magicCheck:SetRelativeWidth(0.25)
        container:AddChild(magicCheck)
        
        local diseaseCheck = GUI:Create("CheckBox")
        diseaseCheck:SetLabel("Disease")
        diseaseCheck:SetValue(currentParams.disease or false)
        diseaseCheck:SetRelativeWidth(0.25)
        container:AddChild(diseaseCheck)
        
        local poisonCheck = GUI:Create("CheckBox")
        poisonCheck:SetLabel("Poison")
        poisonCheck:SetValue(currentParams.poison or false)
        poisonCheck:SetRelativeWidth(0.25)
        container:AddChild(poisonCheck)
        
        local curseCheck = GUI:Create("CheckBox")
        curseCheck:SetLabel("Curse")
        curseCheck:SetValue(currentParams.curse or false)
        curseCheck:SetRelativeWidth(0.25)
        container:AddChild(curseCheck)
        
        local onlyIfCanCheck = GUI:Create("CheckBox")
        onlyIfCanCheck:SetLabel("Only show if player can dispel")
        onlyIfCanCheck:SetValue(currentParams.onlyIfCanDispel ~= false)
        onlyIfCanCheck:SetFullWidth(true)
        container:AddChild(onlyIfCanCheck)
        
        paramGetters.magic = function() return magicCheck:GetValue() end
        paramGetters.disease = function() return diseaseCheck:GetValue() end
        paramGetters.poison = function() return poisonCheck:GetValue() end
        paramGetters.curse = function() return curseCheck:GetValue() end
        paramGetters.onlyIfCanDispel = function() return onlyIfCanCheck:GetValue() end
        
    elseif ruleType == "stealable" then
        -- Stealable options
        local onlyIfCanCheck = GUI:Create("CheckBox")
        onlyIfCanCheck:SetLabel("Only show if player can steal (is mage)")
        onlyIfCanCheck:SetValue(currentParams.onlyIfCanSteal ~= false)
        onlyIfCanCheck:SetFullWidth(true)
        container:AddChild(onlyIfCanCheck)
        
        paramGetters.onlyIfCanSteal = function() return onlyIfCanCheck:GetValue() end
        
    elseif ruleType == "any" then
        -- Any/Catch-all rule explanation
        local label = GUI:Create("Label")
        label:SetText("This rule matches ALL auras. Use as a final cleanup rule to allow or deny everything not matched by previous rules.")
        label:SetFullWidth(true)
        container:AddChild(label)
        
    else
        -- No parameters or unknown type
        local label = GUI:Create("Label")
        label:SetText("No configurable parameters for this rule type")
        label:SetFullWidth(true)
        container:AddChild(label)
    end
    
    -- Size control (common to all rule types)
    local sizeLabel = GUI:Create("Label")
    sizeLabel:SetText(" ")
    sizeLabel:SetFullWidth(true)
    container:AddChild(sizeLabel)
    
    local sizeHeaderLabel = GUI:Create("Label")
    sizeHeaderLabel:SetText(lavender .. "Aura Size (pixels):")
    sizeHeaderLabel:SetFullWidth(true)
    container:AddChild(sizeHeaderLabel)
    
    local sizeSlider = GUI:Create("Slider")
    sizeSlider:SetSliderValues(8, 64, 1)
    sizeSlider:SetValue(currentParams.size or 32) -- Use current size or default
    sizeSlider:SetFullWidth(true)
    container:AddChild(sizeSlider)
    
    -- Store getter for size parameter using UserData
    paramGetters.size = function() return sizeSlider:GetValue() end
end