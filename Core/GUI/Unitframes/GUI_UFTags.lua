local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0")
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

function MilaUI:DrawTagsContainer(container)
    local PowerTags = MilaUI:FetchPowerTagDescriptions()
    local HealthTags = MilaUI:FetchHealthTagDescriptions()
    local NameTags = MilaUI:FetchNameTagDescriptions()
    local MiscTags = MilaUI:FetchMiscTagDescriptions()

    MilaUI:CreateLargeHeading("Tags", container)

    local TagUpdateInterval = GUI:Create("Slider")
    TagUpdateInterval:SetLabel(lavender .. "Tag Update Interval")
    TagUpdateInterval:SetSliderValues(0, 1, 0.1)
    TagUpdateInterval:SetValue(MilaUI.DB.global.TagUpdateInterval)
    TagUpdateInterval:SetCallback("OnMouseUp", function(widget, event, value) MilaUI.DB.global.TagUpdateInterval = value MilaUI:SetTagUpdateInterval() end)
    TagUpdateInterval:SetRelativeWidth(1)
    container:AddChild(TagUpdateInterval)

    MilaUI:CreateLargeHeading("Health Tags", container)
    local HealthTagOptions = GUI:Create("InlineGroup")
    HealthTagOptions:SetLayout("Flow")
    HealthTagOptions:SetFullWidth(true)
    container:AddChild(HealthTagOptions)

    for Title, TableData in pairs(HealthTags) do
        local Tag, Desc = TableData.Tag, TableData.Desc

        local HealthTagTag = GUI:Create("EditBox")
        HealthTagTag:SetText(Tag)
        HealthTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        HealthTagTag:SetRelativeWidth(0.25)
        HealthTagOptions:AddChild(HealthTagTag)
        MilaUI:CreateHorizontalSpacer(0.1, HealthTagOptions)
        HealthTagDescription = GUI:Create("Label")
        HealthTagDescription:SetText(lavender .. Desc)
        if HealthTagDescription.label and HealthTagDescription.label.SetFont then
            local font, _, flags = HealthTagDescription.label:GetFont()
            HealthTagDescription.label:SetFont(font, 14, flags) -- 16 is the font size
        end
        HealthTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        HealthTagDescription:SetRelativeWidth(0.65)
        HealthTagOptions:AddChild(HealthTagDescription)
        MilaUI:CreateVerticalSpacer(10, HealthTagOptions)
    end

    MilaUI:CreateLargeHeading("Power Tags", container)
    local PowerTagOptions = GUI:Create("InlineGroup")
    PowerTagOptions:SetLayout("Flow")
    PowerTagOptions:SetFullWidth(true)
    container:AddChild(PowerTagOptions)

    for Title, TableData in pairs(PowerTags) do
        local Tag, Desc = TableData.Tag, TableData.Desc

        local PowerTagTag = GUI:Create("EditBox")
        PowerTagTag:SetText(Tag)
        PowerTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        PowerTagTag:SetRelativeWidth(0.25)
        PowerTagOptions:AddChild(PowerTagTag)
        MilaUI:CreateHorizontalSpacer(0.1, PowerTagOptions)
        PowerTagDescription = GUI:Create("Label")
        PowerTagDescription:SetText(lavender .. Desc)
        if PowerTagDescription.label and PowerTagDescription.label.SetFont then
            local font, _, flags = PowerTagDescription.label:GetFont()
            PowerTagDescription.label:SetFont(font, 14, flags) -- 16 is the font size
        end
        PowerTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        PowerTagDescription:SetRelativeWidth(0.65)
        PowerTagOptions:AddChild(PowerTagDescription)
        MilaUI:CreateVerticalSpacer(10, PowerTagOptions)
    end

    MilaUI:CreateLargeHeading("Name Tags", container)
    local NameTagOptions = GUI:Create("InlineGroup")
    NameTagOptions:SetLayout("Flow")
    NameTagOptions:SetFullWidth(true)
    container:AddChild(NameTagOptions)

    for Title, TableData in pairs(NameTags) do
        local Tag, Desc = TableData.Tag, TableData.Desc

        local NameTagTag = GUI:Create("EditBox")
        NameTagTag:SetText(Tag)
        NameTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        NameTagTag:SetRelativeWidth(0.25)
        NameTagOptions:AddChild(NameTagTag)
        MilaUI:CreateHorizontalSpacer(0.1, NameTagOptions)
        NameTagDescription = GUI:Create("Label")
        NameTagDescription:SetText(lavender .. Desc)
        if NameTagDescription.label and NameTagDescription.label.SetFont then
            local font, _, flags = NameTagDescription.label:GetFont()
            NameTagDescription.label:SetFont(font, 14, flags) -- 16 is the font size
        end
        NameTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        NameTagDescription:SetRelativeWidth(0.65)
        NameTagOptions:AddChild(NameTagDescription)
        MilaUI:CreateVerticalSpacer(10, NameTagOptions)
    end

    MilaUI:CreateLargeHeading("Misc Tags", container)
    local MiscTagOptions = GUI:Create("InlineGroup")
    MiscTagOptions:SetLayout("Flow")
    MiscTagOptions:SetFullWidth(true)
    container:AddChild(MiscTagOptions)

    for Title, TableData in pairs(MiscTags) do
        local Tag, Desc = TableData.Tag, TableData.Desc

        local MiscTagTag = GUI:Create("EditBox")
        MiscTagTag:SetText(Tag)
        MiscTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        MiscTagTag:SetRelativeWidth(0.25)
        MiscTagOptions:AddChild(MiscTagTag)
        MilaUI:CreateHorizontalSpacer(0.1, MiscTagOptions)
        MiscTagDescription = GUI:Create("Label")
        MiscTagDescription:SetText(lavender .. Desc)
        if MiscTagDescription.label and MiscTagDescription.label.SetFont then
            local font, _, flags = MiscTagDescription.label:GetFont()
            MiscTagDescription.label:SetFont(font, 14, flags) -- 16 is the font size
        end
        MiscTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
        MiscTagDescription:SetRelativeWidth(0.65)
        MiscTagOptions:AddChild(MiscTagDescription)
        MilaUI:CreateVerticalSpacer(10, MiscTagOptions)
    end

end