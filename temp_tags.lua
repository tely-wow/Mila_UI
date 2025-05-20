local _, MilaUI = ...
local MilaUI_GUI = LibStub("AceGUI-3.0")


function MilaUI:DrawTagsContainer(MilaUI_GUI_Container)
        local ScrollableContainer = MilaUI_GUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        MilaUI_GUI_Container:AddChild(ScrollableContainer)

        local TagUpdateInterval = MilaUI_GUI:Create("Slider")
        TagUpdateInterval:SetLabel("Tag Update Interval")
        TagUpdateInterval:SetSliderValues(0, 1, 0.1)
        TagUpdateInterval:SetValue(MilaUI.DB.global.TagUpdateInterval)
        TagUpdateInterval:SetCallback("OnMouseUp", function(widget, event, value) MilaUI.DB.global.TagUpdateInterval = value MilaUI:SetTagUpdateInterval() end)
        TagUpdateInterval:SetRelativeWidth(1)
        ScrollableContainer:AddChild(TagUpdateInterval)

        local function DrawHealthTagContainer(MilaUI_GUI_Container)
            local HealthTags = MilaUI:FetchHealthTagDescriptions()

            local HealthTagOptions = MilaUI_GUI:Create("InlineGroup")
            HealthTagOptions:SetTitle("Health Tags")
            HealthTagOptions:SetLayout("Flow")
            HealthTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(HealthTagOptions)

            for Title, TableData in pairs(HealthTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                HealthTagTitle = MilaUI_GUI:Create("Heading")
                HealthTagTitle:SetText(Title)
                HealthTagTitle:SetRelativeWidth(1)
                HealthTagOptions:AddChild(HealthTagTitle)

                local HealthTagTag = MilaUI_GUI:Create("EditBox")
                HealthTagTag:SetText(Tag)
                HealthTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                HealthTagTag:SetRelativeWidth(0.25)
                HealthTagOptions:AddChild(HealthTagTag)

                HealthTagDescription = MilaUI_GUI:Create("EditBox")
                HealthTagDescription:SetText(Desc)
                HealthTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                HealthTagDescription:SetRelativeWidth(0.75)
                HealthTagOptions:AddChild(HealthTagDescription)
            end
        end

        local function DrawPowerTagsContainer(MilaUI_GUI_Container)
            local PowerTags = MilaUI:FetchPowerTagDescriptions()

            local PowerTagOptions = MilaUI_GUI:Create("InlineGroup")
            PowerTagOptions:SetTitle("Power Tags")
            PowerTagOptions:SetLayout("Flow")
            PowerTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(PowerTagOptions)

            for Title, TableData in pairs(PowerTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                PowerTagTitle = MilaUI_GUI:Create("Label")
                PowerTagTitle:SetText(Title)
                PowerTagTitle:SetRelativeWidth(1)
                PowerTagOptions:AddChild(PowerTagTitle)

                local PowerTagTag = MilaUI_GUI:Create("EditBox")
                PowerTagTag:SetText(Tag)
                PowerTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                PowerTagTag:SetRelativeWidth(0.3)
                PowerTagOptions:AddChild(PowerTagTag)

                PowerTagDescription = MilaUI_GUI:Create("EditBox")
                PowerTagDescription:SetText(Desc)
                PowerTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                PowerTagDescription:SetRelativeWidth(0.7)
                PowerTagOptions:AddChild(PowerTagDescription)
            end
        end

        local function DrawNameTagsContainer(MilaUI_GUI_Container)
            local NameTags = MilaUI:FetchNameTagDescriptions()

            local NameTagOptions = MilaUI_GUI:Create("InlineGroup")
            NameTagOptions:SetTitle("Name Tags")
            NameTagOptions:SetLayout("Flow")
            NameTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(NameTagOptions)

            for Title, TableData in pairs(NameTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                NameTagTitle = MilaUI_GUI:Create("Heading")
                NameTagTitle:SetText(Title)
                NameTagTitle:SetRelativeWidth(1)
                NameTagOptions:AddChild(NameTagTitle)

                local NameTagTag = MilaUI_GUI:Create("EditBox")
                NameTagTag:SetText(Tag)
                NameTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NameTagTag:SetRelativeWidth(0.3)
                NameTagOptions:AddChild(NameTagTag)

                NameTagDescription = MilaUI_GUI:Create("EditBox")
                NameTagDescription:SetText(Desc)
                NameTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NameTagDescription:SetRelativeWidth(0.7)
                NameTagOptions:AddChild(NameTagDescription)
            end
        end


        local function DrawMiscTagsContainer(MilaUI_GUI_Container)
            local MiscTags = MilaUI:FetchMiscTagDescriptions()

            local MiscTagOptions = MilaUI_GUI:Create("InlineGroup")
            MiscTagOptions:SetTitle("Misc Tags")
            MiscTagOptions:SetLayout("Flow")
            MiscTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(MiscTagOptions)

            for Title, TableData in pairs(MiscTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                MiscTagTitle = MilaUI_GUI:Create("Heading")
                MiscTagTitle:SetText(Title)
                MiscTagTitle:SetRelativeWidth(1)
                MiscTagOptions:AddChild(MiscTagTitle)

                local MiscTagTag = MilaUI_GUI:Create("EditBox")
                MiscTagTag:SetText(Tag)
                MiscTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                MiscTagTag:SetRelativeWidth(0.3)
                MiscTagOptions:AddChild(MiscTagTag)

                MiscTagDescription = MilaUI_GUI:Create("EditBox")
                MiscTagDescription:SetText(Desc)
                MiscTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                MiscTagDescription:SetRelativeWidth(0.7)
                MiscTagOptions:AddChild(MiscTagDescription)
            end
        end

        local function SelectedGroup(MilaUI_GUI_Container, Event, Group)
            MilaUI_GUI_Container:ReleaseChildren()
            if Group == "Health" then
                DrawHealthTagContainer(MilaUI_GUI_Container)
            elseif Group == "Power" then
                DrawPowerTagsContainer(MilaUI_GUI_Container)
            elseif Group == "Name" then
                DrawNameTagsContainer(MilaUI_GUI_Container)
            elseif Group == "Misc" then
                DrawMiscTagsContainer(MilaUI_GUI_Container)
            end
        end

        GUIContainerTabGroup = MilaUI_GUI:Create("TabGroup")
        GUIContainerTabGroup:SetLayout("Flow")
        GUIContainerTabGroup:SetTabs({
            { text = "Health",                              value = "Health"},
            { text = "Power",                               value = "Power" },
            { text = "Name",                                value = "Name" },
            { text = "Misc",                                value = "Misc" },
        })
        GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
        GUIContainerTabGroup:SelectTab("Health")
        GUIContainerTabGroup:SetFullWidth(true)
        ScrollableContainer:AddChild(GUIContainerTabGroup)
end
