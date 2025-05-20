local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0") 
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"

function MilaUI:DrawProfileContainer(contentFrame)

    -- Profile Options Section
    MilaUI:CreateLargeHeading("Profile Options", contentFrame)
    local ProfileOptions = GUI:Create("InlineGroup")
    ProfileOptions:SetLayout("Flow")
    ProfileOptions:SetFullWidth(true)
    contentFrame:AddChild(ProfileOptions)

    local selectedProfile = nil
    local profileList = {}
    local profileKeys = {}

    for _, name in ipairs(MilaUI.DB:GetProfiles(profileList, true)) do
        profileKeys[name] = name
    end

    local NewProfileBox = GUI:Create("EditBox")
    NewProfileBox:SetLabel(lavender .. "Create New Profile")
    NewProfileBox:SetRelativeWidth(0.5)
    NewProfileBox:SetCallback("OnEnterPressed", function(widget, event, text)
        if text ~= "" then
            MilaUI.DB:SetProfile(text)
            MilaUI:CreateReloadPrompt()
            widget:SetText("")
        end
    end)
    ProfileOptions:AddChild(NewProfileBox)

    local ActiveProfileDropdown = GUI:Create("Dropdown")
    ActiveProfileDropdown:SetLabel(lavender .. "Active Profile")
    ActiveProfileDropdown:SetList(profileKeys)
    ActiveProfileDropdown:SetValue(MilaUI.DB:GetCurrentProfile())
    ActiveProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value) selectedProfile = value MilaUI.DB:SetProfile(value) MilaUI:UpdateFrames() MilaUI:CreateReloadPrompt() end)
    ActiveProfileDropdown:SetRelativeWidth(0.5)
    ProfileOptions:AddChild(ActiveProfileDropdown)

    local CopyProfileDropdown = GUI:Create("Dropdown")
    CopyProfileDropdown:SetLabel(lavender .. "Copy From Profile")
    CopyProfileDropdown:SetList(profileKeys)
    CopyProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value) selectedProfile = value MilaUI.DB:CopyProfile(selectedProfile) MilaUI:CreateReloadPrompt() end)
    CopyProfileDropdown:SetRelativeWidth(0.5)
    ProfileOptions:AddChild(CopyProfileDropdown)

    local DeleteProfileDropdown = GUI:Create("Dropdown")
    DeleteProfileDropdown:SetLabel(lavender .. "Delete Profile")
    DeleteProfileDropdown:SetList(profileKeys)
    DeleteProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        selectedProfile = value
        if selectedProfile and selectedProfile ~= MilaUI.DB:GetCurrentProfile() then
            MilaUI.DB:DeleteProfile(selectedProfile)
            profileKeys = {}
            for _, name in ipairs(MilaUI.DB:GetProfiles(profileList, true)) do
                profileKeys[name] = name
            end
            CopyProfileDropdown:SetList(profileKeys)
            DeleteProfileDropdown:SetList(profileKeys)
            ActiveProfileDropdown:SetList(profileKeys)
            DeleteProfileDropdown:SetValue(nil)
        else
            print("|cFF8080FFUnhalted Unit Frames|r: Unable to delete an active profile.")
        end
     end)
    DeleteProfileDropdown:SetRelativeWidth(0.5)
    ProfileOptions:AddChild(DeleteProfileDropdown)

    local ResetToDefault = GUI:Create("Button")
    ResetToDefault:SetText(lavender .. "Reset Profile")
    ResetToDefault:SetCallback("OnClick", function(widget, event, value) MilaUI:ResetDefaultSettings() end)
    ResetToDefault:SetRelativeWidth(0.3)
    ProfileOptions:AddChild(ResetToDefault)

    -- Sharing Options Section
    MilaUI:CreateLargeHeading("Sharing Options", contentFrame)
    local SharingOptionsContainer = GUI:Create("InlineGroup")
    SharingOptionsContainer:SetLayout("Flow")
    SharingOptionsContainer:SetFullWidth(true)
    contentFrame:AddChild(SharingOptionsContainer)

    -- Import Section
    local ImportOptionsContainer = GUI:Create("InlineGroup")
    ImportOptionsContainer:SetTitle(lavender .. "Import Options")
    ImportOptionsContainer:SetLayout("Flow")
    ImportOptionsContainer:SetFullWidth(true)
    SharingOptionsContainer:AddChild(ImportOptionsContainer)

    local ImportEditBox = GUI:Create("MultiLineEditBox")
    ImportEditBox:SetLabel(lavender .. "Import String")
    ImportEditBox:SetNumLines(5)
    ImportEditBox:SetFullWidth(true)
    ImportEditBox:DisableButton(true)
    ImportOptionsContainer:AddChild(ImportEditBox)

    local ImportButton = GUI:Create("Button")
    ImportButton:SetText(lavender .. "Import")
    ImportButton:SetCallback("OnClick", function()
        MilaUI:ImportSavedVariables(ImportEditBox:GetText())
        ImportEditBox:SetText("")
    end)
    ImportButton:SetRelativeWidth(1)
    ImportOptionsContainer:AddChild(ImportButton)

    -- Export Section
    local ExportOptionsContainer = GUI:Create("InlineGroup")
    ExportOptionsContainer:SetTitle(lavender .. "Export Options")
    ExportOptionsContainer:SetLayout("Flow")
    ExportOptionsContainer:SetFullWidth(true)
    SharingOptionsContainer:AddChild(ExportOptionsContainer)

    local ExportEditBox = GUI:Create("MultiLineEditBox")
    ExportEditBox:SetLabel(lavender .. "Export String")
    ExportEditBox:SetFullWidth(true)
    ExportEditBox:SetNumLines(5)
    ExportEditBox:DisableButton(true)
    ExportOptionsContainer:AddChild(ExportEditBox)

    local ExportButton = GUI:Create("Button")
    ExportButton:SetText(lavender .. "Generate Export String")
    ExportButton:SetCallback("OnClick", function()
        ExportEditBox:SetText(MilaUI:ExportSavedVariables())
        ExportEditBox:HighlightText()
        ExportEditBox:SetFocus()
    end)
    ExportButton:SetRelativeWidth(1)
    ExportOptionsContainer:AddChild(ExportButton)


end

