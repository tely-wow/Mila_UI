local _, MilaUI = ...
local MilaUI_GUI = LibStub("AceGUI-3.0")
local L = MilaUI.L or {}
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"
-- Function to safely fetch tag descriptions
local function SafeFetchTags(fetchFunc)
    if not fetchFunc then return {} end
    
    local success, result = pcall(function()
        return fetchFunc()
    end)
    
    if success and result then
        return result
    else
        return {}
    end
end

-- Simplified DrawTagsContainer function
function MilaUI:DrawTagsContainer(container)
    
    -- Create a container for the slider with spacers
    local sliderContainer = MilaUI_GUI:Create("SimpleGroup")
    sliderContainer:SetLayout("Flow")
    sliderContainer:SetFullWidth(true)
    container:AddChild(sliderContainer)
    
    -- Left spacer
    local leftSpacer = MilaUI_GUI:Create("Label")
    leftSpacer:SetText("")
    leftSpacer:SetRelativeWidth(0.33)
    sliderContainer:AddChild(leftSpacer)
    
    -- Add tag update interval slider
    local intervalSlider = MilaUI_GUI:Create("Slider")
    intervalSlider:SetLabel(lavender .. "Tag Update Interval (seconds)")
    intervalSlider:SetSliderValues(0.1, 1, 0.1)
    
    -- Default value
    local tagInterval = 0.5
    -- Try to safely get the value from DB
    if MilaUI.DB and MilaUI.DB.global and MilaUI.DB.global.TagUpdateInterval then
        tagInterval = MilaUI.DB.global.TagUpdateInterval
    end
    
    intervalSlider:SetValue(tagInterval)
    intervalSlider:SetCallback("OnValueChanged", function(_, _, value)
        if MilaUI.DB and MilaUI.DB.global then
            MilaUI.DB.global.TagUpdateInterval = value
        end
    end)
    
    intervalSlider:SetRelativeWidth(0.33)
    sliderContainer:AddChild(intervalSlider)
    
    -- Right spacer
    local rightSpacer = MilaUI_GUI:Create("Label")
    rightSpacer:SetText("")
    rightSpacer:SetRelativeWidth(0.33)
    sliderContainer:AddChild(rightSpacer)
    
    local healthHeader = MilaUI_GUI:Create("Heading")
    healthHeader:SetText(pink .. "Health Tags")
    healthHeader:SetFullWidth(true)
    container:AddChild(healthHeader)
    
    -- Create a simple group for Health Tags
    local healthGroup = MilaUI_GUI:Create("InlineGroup")
    healthGroup:SetFullWidth(true)
    container:AddChild(healthGroup)
    
    -- Get health tags
    local healthTags = SafeFetchTags(function() return MilaUI:FetchHealthTagDescriptions() end)
    
    -- Create a simple table to display health tags
    local healthTable = MilaUI_GUI:Create("SimpleGroup")
    healthTable:SetLayout("Flow")
    healthTable:SetFullWidth(true)
    healthGroup:AddChild(healthTable)
    
    -- Create a header row with fixed columns
    local headerGroup = MilaUI_GUI:Create("SimpleGroup")
    headerGroup:SetLayout("Flow")
    headerGroup:SetFullWidth(true)
    
    -- Create a table-like header
    local titleHeader = MilaUI_GUI:Create("Label")
    titleHeader:SetText(lavender .. "Tag Name")
    titleHeader:SetWidth(250)
    headerGroup:AddChild(titleHeader)
    
    local tagHeader = MilaUI_GUI:Create("Label")
    tagHeader:SetText(lavender .. "Tag Format")
    tagHeader:SetWidth(200)
    headerGroup:AddChild(tagHeader)
    
    local descHeader = MilaUI_GUI:Create("Label")
    descHeader:SetText(lavender .. "Description")
    descHeader:SetWidth(300)
    headerGroup:AddChild(descHeader)
    
    healthTable:AddChild(headerGroup)
    
    -- Add health tags
    for title, info in pairs(healthTags) do
        local row = MilaUI_GUI:Create("SimpleGroup")
        row:SetLayout("Flow")
        row:SetFullWidth(true)
        
        local titleLabel = MilaUI_GUI:Create("Label")
        titleLabel:SetText(title)
        titleLabel:SetWidth(250)
        row:AddChild(titleLabel)
        
        local tagLabel = MilaUI_GUI:Create("Label")
        tagLabel:SetText(info.Tag)
        tagLabel:SetWidth(200)
        row:AddChild(tagLabel)
        
        local descLabel = MilaUI_GUI:Create("Label")
        descLabel:SetText(info.Desc)
        descLabel:SetWidth(300)
        row:AddChild(descLabel)
        
        healthTable:AddChild(row)
    end
    
    -- Add a header for Power Tags
    local powerHeader = MilaUI_GUI:Create("Heading")
    powerHeader:SetText(pink .. "Power Tags")
    powerHeader:SetFullWidth(true)
    container:AddChild(powerHeader)
    
    -- Create a simple group for Power Tags
    local powerGroup = MilaUI_GUI:Create("InlineGroup")
    powerGroup:SetFullWidth(true)
    container:AddChild(powerGroup)
    
    -- Get power tags
    local powerTags = SafeFetchTags(function() return MilaUI:FetchPowerTagDescriptions() end)
    
    -- Create a simple table to display power tags
    local powerTable = MilaUI_GUI:Create("SimpleGroup")
    powerTable:SetLayout("Flow")
    powerTable:SetFullWidth(true)
    powerGroup:AddChild(powerTable)
    
    -- Create a header row with fixed columns
    local powerHeaderGroup = MilaUI_GUI:Create("SimpleGroup")
    powerHeaderGroup:SetLayout("Flow")
    powerHeaderGroup:SetFullWidth(true)
    
    -- Create a table-like header
    local powerTitleHeader = MilaUI_GUI:Create("Label")
    powerTitleHeader:SetText(lavender .. "Tag Name")
    powerTitleHeader:SetWidth(250)
    powerHeaderGroup:AddChild(powerTitleHeader)
    
    local powerTagHeader = MilaUI_GUI:Create("Label")
    powerTagHeader:SetText(lavender .. "Tag Format")
    powerTagHeader:SetWidth(200)
    powerHeaderGroup:AddChild(powerTagHeader)
    
    local powerDescHeader = MilaUI_GUI:Create("Label")
    powerDescHeader:SetText(lavender .. "Description")
    powerDescHeader:SetWidth(300)
    powerHeaderGroup:AddChild(powerDescHeader)
    
    powerTable:AddChild(powerHeaderGroup)
    
    -- Add power tags
    for title, info in pairs(powerTags) do
        local row = MilaUI_GUI:Create("SimpleGroup")
        row:SetLayout("Flow")
        row:SetFullWidth(true)
        
        local titleLabel = MilaUI_GUI:Create("Label")
        titleLabel:SetText(title)
        titleLabel:SetWidth(250)
        row:AddChild(titleLabel)
        
        local tagLabel = MilaUI_GUI:Create("Label")
        tagLabel:SetText(info.Tag)
        tagLabel:SetWidth(200)
        row:AddChild(tagLabel)
        
        local descLabel = MilaUI_GUI:Create("Label")
        descLabel:SetText(info.Desc)
        descLabel:SetWidth(300)
        row:AddChild(descLabel)
        
        powerTable:AddChild(row)
    end
    
    -- Add a header for Name Tags
    local nameHeader = MilaUI_GUI:Create("Heading")
    nameHeader:SetText(pink .. "Name Tags")
    nameHeader:SetFullWidth(true)
    container:AddChild(nameHeader)
    
    -- Create a simple group for Name Tags
    local nameGroup = MilaUI_GUI:Create("InlineGroup")
    nameGroup:SetFullWidth(true)
    container:AddChild(nameGroup)
    
    -- Get name tags
    local nameTags = SafeFetchTags(function() return MilaUI:FetchNameTagDescriptions() end)
    
    -- Create a simple table to display name tags
    local nameTable = MilaUI_GUI:Create("SimpleGroup")
    nameTable:SetLayout("Flow")
    nameTable:SetFullWidth(true)
    nameGroup:AddChild(nameTable)
    
    -- Create a header row with fixed columns
    local nameHeaderGroup = MilaUI_GUI:Create("SimpleGroup")
    nameHeaderGroup:SetLayout("Flow")
    nameHeaderGroup:SetFullWidth(true)
    
    -- Create a table-like header
    local nameTitleHeader = MilaUI_GUI:Create("Label")
    nameTitleHeader:SetText(lavender .. "Tag Name")
    nameTitleHeader:SetWidth(250)
    nameHeaderGroup:AddChild(nameTitleHeader)
    
    local nameTagHeader = MilaUI_GUI:Create("Label")
    nameTagHeader:SetText(lavender .. "Tag Format")
    nameTagHeader:SetWidth(200)
    nameHeaderGroup:AddChild(nameTagHeader)
    
    local nameDescHeader = MilaUI_GUI:Create("Label")
    nameDescHeader:SetText(lavender .. "Description")
    nameDescHeader:SetWidth(300)
    nameHeaderGroup:AddChild(nameDescHeader)
    
    nameTable:AddChild(nameHeaderGroup)
    
    -- Add name tags
    for title, info in pairs(nameTags) do
        local row = MilaUI_GUI:Create("SimpleGroup")
        row:SetLayout("Flow")
        row:SetFullWidth(true)
        
        local titleLabel = MilaUI_GUI:Create("Label")
        titleLabel:SetText(title)
        titleLabel:SetWidth(250)
        row:AddChild(titleLabel)
        
        local tagLabel = MilaUI_GUI:Create("Label")
        tagLabel:SetText(info.Tag)
        tagLabel:SetWidth(200)
        row:AddChild(tagLabel)
        
        local descLabel = MilaUI_GUI:Create("Label")
        descLabel:SetText(info.Desc)
        descLabel:SetWidth(300)
        row:AddChild(descLabel)
        
        nameTable:AddChild(row)
    end
end
