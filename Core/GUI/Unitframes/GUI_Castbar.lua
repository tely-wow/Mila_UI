local _, MilaUI = ...
local GUI = LibStub("AceGUI-3.0") 
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
MilaUI.GUI = GUI
local pink = "|cffFF77B5"
local lavender = "|cFFCBA0E3"
local unitSettingsContainer = nil

function MilaUI:DrawCastbarContainer(dbUnitName, contentFrame)
    local General = MilaUI.DB.profile.Unitframes.General
    local textures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
    local fonts = LSM and LSM:HashTable(LSM.MediaType.FONT) or {}
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

    local Castbar = MilaUI.DB.profile.Unitframes[dbUnitName].Castbar

    -- Appearance
    MilaUI:CreateLargeHeading("Appearance", contentFrame, 16)
    MilaUI:CreateVerticalSpacer(10, contentFrame)
    local Appearance = GUI:Create("InlineGroup")
    Appearance:SetLayout("Flow")
    Appearance:SetRelativeWidth(1)

    local Enabled = GUI:Create("CheckBox")
    Enabled:SetLabel("Enable Castbar")
    Enabled:SetValue(Castbar.Enabled)
    Enabled:SetCallback("OnValueChanged", function(widget, event, value) Castbar.Enabled = value MilaUI:CreateReloadPrompt() end)
    Enabled:SetRelativeWidth(0.3)
    Appearance:AddChild(Enabled)
    local CustomMask = GUI:Create("CheckBox")
    CustomMask:SetLabel("Custom Mask")
    CustomMask:SetValue(Castbar.CustomMask and Castbar.CustomMask.Enabled)
    CustomMask:SetCallback("OnValueChanged", function(widget, event, value) Castbar.CustomMask.Enabled = value MilaUI:CreateReloadPrompt() end)
    CustomMask:SetRelativeWidth(0.3)
    Appearance:AddChild(CustomMask)

    -- Custom Border
    local CustomBorder = GUI:Create("CheckBox")
    CustomBorder:SetLabel("Custom Border")
    CustomBorder:SetValue(Castbar.CustomBorder and Castbar.CustomBorder.Enabled)
    CustomBorder:SetCallback("OnValueChanged", function(widget, event, value) Castbar.CustomBorder.Enabled = value MilaUI:CreateReloadPrompt() end)
    CustomBorder:SetRelativeWidth(0.3)
    Appearance:AddChild(CustomBorder)
    
    -- Castbar Texture Pickers (per cast type)
    local CastTexturePicker = GUI:Create("LSM30_Statusbar")
    CastTexturePicker:SetLabel(lavender .. "Cast Texture")
    CastTexturePicker:SetList(LSM:HashTable("statusbar"))
    CastTexturePicker:SetValue(Castbar.textures and Castbar.textures.cast)
    CastTexturePicker:SetRelativeWidth(0.33)
    CastTexturePicker:SetCallback("OnValueChanged", function(widget, event, value)
        Castbar.textures = Castbar.textures or {}
        Castbar.textures.cast = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    Appearance:AddChild(CastTexturePicker)

    local ChannelTexturePicker = GUI:Create("LSM30_Statusbar")
    ChannelTexturePicker:SetLabel(lavender .. "Channel Texture")
    ChannelTexturePicker:SetList(LSM:HashTable("statusbar"))
    ChannelTexturePicker:SetValue(Castbar.textures and Castbar.textures.channel)
    ChannelTexturePicker:SetRelativeWidth(0.33)
    ChannelTexturePicker:SetCallback("OnValueChanged", function(widget, event, value)
        Castbar.textures = Castbar.textures or {}
        Castbar.textures.channel = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    Appearance:AddChild(ChannelTexturePicker)

    local UninterruptibleTexturePicker = GUI:Create("LSM30_Statusbar")
    UninterruptibleTexturePicker:SetLabel(lavender .. "Uninterruptible Texture")
    UninterruptibleTexturePicker:SetList(LSM:HashTable("statusbar"))
    UninterruptibleTexturePicker:SetValue(Castbar.textures and Castbar.textures.uninterruptible)
    UninterruptibleTexturePicker:SetRelativeWidth(0.33)
    UninterruptibleTexturePicker:SetCallback("OnValueChanged", function(widget, event, value)
        Castbar.textures = Castbar.textures or {}
        Castbar.textures.uninterruptible = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    Appearance:AddChild(UninterruptibleTexturePicker)
    MilaUI:CreateVerticalSpacer(10, Appearance)

    if dbUnitName == "Boss" then
        local DisplayFrames = GUI:Create("Button")
        DisplayFrames:SetText(pink .. "Display Frames")
        DisplayFrames:SetCallback("OnClick", function(widget, event, value) MilaUI.DB.profile.TestMode = not MilaUI.DB.profile.TestMode MilaUI:DisplayBossFrames() MilaUI:UpdateFrames() end)
        DisplayFrames:SetRelativeWidth(0.25)
        Appearance:AddChild(DisplayFrames)
        if not Frame.Enabled then DisplayFrames:SetDisabled(true) end
    end

    if dbUnitName == "Boss" then
        local FrameSpacing = GUI:Create("Slider")
        FrameSpacing:SetLabel(lavender .. "Frame Spacing")
        FrameSpacing:SetSliderValues(-999, 999, 0.1)
        FrameSpacing:SetValue(Frame.Spacing)
        FrameSpacing:SetCallback("OnMouseUp", function(widget, event, value) Frame.Spacing = value MilaUI:UpdateCastbarAppearance() end)
        FrameSpacing:SetRelativeWidth(0.25)
        Appearance:AddChild(FrameSpacing)

        local GrowthDirection = GUI:Create("Dropdown")
        GrowthDirection:SetLabel(lavender .. "Growth Direction")
        GrowthDirection:SetList({
            ["DOWN"] = "Down",
            ["UP"] = "Up",
        })
        GrowthDirection:SetValue(Frame.GrowthY)
        GrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) Frame.GrowthY = value MilaUI:UpdateCastbarAppearance() end)
        GrowthDirection:SetRelativeWidth(0.25)
        Appearance:AddChild(GrowthDirection)
    end
    
    contentFrame:AddChild(Appearance)

    -- Colours Section
    MilaUI:CreateLargeHeading("Colours", contentFrame)
    MilaUI:CreateVerticalSpacer(10, contentFrame)
    local Colours = GUI:Create("InlineGroup")
    Colours:SetLayout("Flow")
    Colours:SetRelativeWidth(1)

    -- Background Color
    local BackgroundColorPicker = GUI:Create("ColorPicker")
    BackgroundColorPicker:SetLabel(lavender .. "Background Color")
    BackgroundColorPicker:SetHasAlpha(true)
    BackgroundColorPicker:SetColor(unpack(Castbar.backgroundColor or {0.1, 0.1, 0.1, 0.8}))
    BackgroundColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        Castbar.backgroundColor = {r, g, b, a}
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    BackgroundColorPicker:SetRelativeWidth(0.25)
    Colours:AddChild(BackgroundColorPicker)

    -- Border Color
    local BorderColorPicker = GUI:Create("ColorPicker")
    BorderColorPicker:SetLabel(lavender .. "Border Color")
    BorderColorPicker:SetHasAlpha(true)
    BorderColorPicker:SetColor(unpack(Castbar.borderColor or {0, 0, 0, 1}))
    BorderColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        Castbar.borderColor = {r, g, b, a}
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    BorderColorPicker:SetRelativeWidth(0.25)
    Colours:AddChild(BorderColorPicker)

    -- Castbar Color Pickers (per cast type)
    local CastColorPicker = GUI:Create("ColorPicker")
    CastColorPicker:SetLabel(lavender .. "Cast Color")
    CastColorPicker:SetHasAlpha(true)
    CastColorPicker:SetColor(unpack((Castbar.textures and Castbar.textures.castcolor) or {1, 0.7, 0, 1}))
    CastColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        Castbar.textures = Castbar.textures or {}
        Castbar.textures.castcolor = {r, g, b, a}
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    CastColorPicker:SetRelativeWidth(0.25)
    Colours:AddChild(CastColorPicker)

    local ChannelColorPicker = GUI:Create("ColorPicker")
    ChannelColorPicker:SetLabel(lavender .. "Channel Color")
    ChannelColorPicker:SetHasAlpha(true)
    ChannelColorPicker:SetColor(unpack((Castbar.textures and Castbar.textures.channelcolor) or {0, 0.7, 1, 1}))
    ChannelColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        Castbar.textures = Castbar.textures or {}
        Castbar.textures.channelcolor = {r, g, b, a}
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    ChannelColorPicker:SetRelativeWidth(0.25)
    Colours:AddChild(ChannelColorPicker)

    local UninterruptibleColorPicker = GUI:Create("ColorPicker")
    UninterruptibleColorPicker:SetLabel(lavender .. "Uninterruptible Color")
    UninterruptibleColorPicker:SetHasAlpha(true)
    UninterruptibleColorPicker:SetColor(unpack((Castbar.textures and Castbar.textures.uninterruptiblecolor) or {0.7, 0, 0, 1}))
    UninterruptibleColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        Castbar.textures = Castbar.textures or {}
        Castbar.textures.uninterruptiblecolor = {r, g, b, a}
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    UninterruptibleColorPicker:SetRelativeWidth(0.25)
    Colours:AddChild(UninterruptibleColorPicker)

    local FailedColorPicker = GUI:Create("ColorPicker")
    FailedColorPicker:SetLabel(lavender .. "Failed Color")
    FailedColorPicker:SetHasAlpha(true)
    FailedColorPicker:SetColor(unpack((Castbar.textures and Castbar.textures.failedcolor) or {1, 0.3, 0.3, 1}))
    FailedColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        Castbar.textures = Castbar.textures or {}
        Castbar.textures.failedcolor = {r, g, b, a}
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    FailedColorPicker:SetRelativeWidth(0.25)
    Colours:AddChild(FailedColorPicker)

    contentFrame:AddChild(Colours)
    MilaUI:CreateVerticalSpacer(10, contentFrame)

    -- Spark Section
    MilaUI:CreateLargeHeading("Spark", contentFrame)
    MilaUI:CreateVerticalSpacer(10, contentFrame)
    local SparkGroup = GUI:Create("InlineGroup")
    SparkGroup:SetLayout("Flow")
    SparkGroup:SetRelativeWidth(1)

    -- Show Spark
    local ShowSpark = GUI:Create("CheckBox")
    ShowSpark:SetLabel("Show Spark")
    ShowSpark:SetValue(Castbar.Spark and Castbar.Spark.showSpark)
    ShowSpark:SetCallback("OnValueChanged", function(widget, event, value)
        if Castbar.Spark then
            Castbar.Spark.showSpark = value
            MilaUI:UpdateCastbarAppearance(dbUnitName)
        end
    end)
    ShowSpark:SetRelativeWidth(0.18)
    SparkGroup:AddChild(ShowSpark)

    -- Spark Width
    local SparkWidth = GUI:Create("Slider")
    SparkWidth:SetLabel(lavender .. "Spark Width")
    SparkWidth:SetSliderValues(1, 50, 1)
    SparkWidth:SetValue(Castbar.Spark and Castbar.Spark.sparkWidth or 10)
    SparkWidth:SetCallback("OnMouseUp", function(widget, event, value)
        if Castbar.Spark then
            Castbar.Spark.sparkWidth = value
            MilaUI:UpdateCastbarAppearance(dbUnitName)
        end
    end)
    SparkWidth:SetRelativeWidth(0.2)
    SparkGroup:AddChild(SparkWidth)

    -- Spark Height
    local SparkHeight = GUI:Create("Slider")
    SparkHeight:SetLabel(lavender .. "Spark Height")
    SparkHeight:SetSliderValues(1, 100, 1)
    SparkHeight:SetValue(Castbar.Spark and Castbar.Spark.sparkHeight or 30)
    SparkHeight:SetCallback("OnMouseUp", function(widget, event, value)
        if Castbar.Spark then
            Castbar.Spark.sparkHeight = value
            MilaUI:UpdateCastbarAppearance(dbUnitName)
        end
    end)
    SparkHeight:SetRelativeWidth(0.2)
    SparkGroup:AddChild(SparkHeight)

    -- Spark Texture
    local SparkTexturePicker = GUI:Create("LSM30_Statusbar")
    SparkTexturePicker:SetLabel(lavender .. "Spark Texture")
    SparkTexturePicker:SetList(LSM:HashTable("statusbar"))
    SparkTexturePicker:SetValue(Castbar.Spark and Castbar.Spark.sparkTexture or "Interface\\Buttons\\WHITE8X8")
    SparkTexturePicker:SetCallback("OnValueChanged", function(widget, event, value)
        if Castbar.Spark then
            Castbar.Spark.sparkTexture = value
            MilaUI:UpdateCastbarAppearance(dbUnitName)
        end
    end)
    SparkTexturePicker:SetRelativeWidth(0.25)
    SparkGroup:AddChild(SparkTexturePicker)

    -- Spark Color
    local SparkColorPicker = GUI:Create("ColorPicker")
    SparkColorPicker:SetLabel(lavender .. "Spark Color")
    SparkColorPicker:SetHasAlpha(true)
    SparkColorPicker:SetColor(unpack(Castbar.Spark and Castbar.Spark.sparkColor or {1, 1, 1, 1}))
    SparkColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        if Castbar.Spark then
            Castbar.Spark.sparkColor = {r, g, b, a}
            MilaUI:UpdateCastbarAppearance(dbUnitName)
        end
    end)
    SparkColorPicker:SetRelativeWidth(0.25)
    SparkGroup:AddChild(SparkColorPicker)

    contentFrame:AddChild(SparkGroup)
    MilaUI:CreateVerticalSpacer(10, contentFrame)

    -- Advanced Section
    MilaUI:CreateLargeHeading("Advanced", contentFrame)
    MilaUI:CreateVerticalSpacer(10, contentFrame)
    local Advanced = GUI:Create("InlineGroup")
    Advanced:SetLayout("Flow")
    Advanced:SetRelativeWidth(1)

    -- Hide Trade Skills
    local HideTradeSkills = GUI:Create("CheckBox")
    HideTradeSkills:SetLabel("Hide Trade Skills (Professions)")
    HideTradeSkills:SetValue(Castbar.hideTradeSkills)
    HideTradeSkills:SetCallback("OnValueChanged", function(widget, event, value)
        Castbar.hideTradeSkills = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    HideTradeSkills:SetRelativeWidth(0.25)
    Advanced:AddChild(HideTradeSkills)

    -- Show Border (enable/disable)
    local ShowBorder = GUI:Create("CheckBox")
    ShowBorder:SetLabel("Show Border")
    ShowBorder:SetValue(Castbar.border ~= false)
    ShowBorder:SetCallback("OnValueChanged", function(widget, event, value)
        Castbar.border = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    ShowBorder:SetRelativeWidth(0.25)
    Advanced:AddChild(ShowBorder)

    -- Player-only: Show Safe Zone and Color
    if dbUnitName == "Player" then
        local ShowSafeZone = GUI:Create("CheckBox")
        ShowSafeZone:SetLabel("Show Safe Zone (Latency)")
        ShowSafeZone:SetValue(Castbar.showSafeZone)
        ShowSafeZone:SetCallback("OnValueChanged", function(widget, event, value)
            Castbar.showSafeZone = value
            MilaUI:UpdateCastbarAppearance(dbUnitName)
        end)
        ShowSafeZone:SetRelativeWidth(0.25)
        Advanced:AddChild(ShowSafeZone)

        local SafeZoneColor = GUI:Create("ColorPicker")
        SafeZoneColor:SetLabel(lavender .. "Safe Zone Color")
        SafeZoneColor:SetHasAlpha(true)
        SafeZoneColor:SetColor(unpack(Castbar.safeZoneColor or {1, 0, 0, 0.6}))
        SafeZoneColor:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
            Castbar.safeZoneColor = {r, g, b, a}
            MilaUI:UpdateCastbarAppearance(dbUnitName)
        end)
        SafeZoneColor:SetRelativeWidth(0.25)
        Advanced:AddChild(SafeZoneColor)
    end

    contentFrame:AddChild(Advanced)
    MilaUI:CreateVerticalSpacer(10, contentFrame)

    -- Border Size
    local BorderSizeSlider = GUI:Create("Slider")
    BorderSizeSlider:SetLabel(lavender .. "Border Size")
    BorderSizeSlider:SetSliderValues(0, 10, 0.1)
    BorderSizeSlider:SetValue(Castbar.borderSize or 1)
    BorderSizeSlider:SetCallback("OnMouseUp", function(widget, event, value)
        Castbar.borderSize = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    BorderSizeSlider:SetRelativeWidth(0.3)
    contentFrame:AddChild(BorderSizeSlider)


    -- Show Shield
    local ShowShieldCheck = GUI:Create("CheckBox")
    ShowShieldCheck:SetLabel("Show Shield (Non-Interruptible)")
    ShowShieldCheck:SetValue(Castbar.showShield)
    ShowShieldCheck:SetCallback("OnValueChanged", function(widget, event, value)
        Castbar.showShield = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    ShowShieldCheck:SetRelativeWidth(0.3)
    contentFrame:AddChild(ShowShieldCheck)

    -- Hold Time
    local HoldTimeSlider = GUI:Create("Slider")
    HoldTimeSlider:SetLabel(lavender .. "Hold Time (s)")
    HoldTimeSlider:SetSliderValues(0, 5, 0.05)
    HoldTimeSlider:SetValue(Castbar.timeToHold or 0.5)
    HoldTimeSlider:SetCallback("OnMouseUp", function(widget, event, value)
        Castbar.timeToHold = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    HoldTimeSlider:SetRelativeWidth(0.3)
    contentFrame:AddChild(HoldTimeSlider)

    MilaUI:CreateVerticalSpacer(20, contentFrame)

    local iconContainer = MilaUI:CreateInlineGroup("Icon")
    iconContainer:SetLayout("Flow")
    iconContainer:SetRelativeWidth(1)
    
    local IconEnabled = GUI:Create("CheckBox")
    IconEnabled:SetLabel("Enable Icon")
    IconEnabled:SetValue(Castbar.Icon.showIcon)
    IconEnabled:SetCallback("OnValueChanged", function(widget, event, value) Castbar.Icon.showIcon = value MilaUI:UpdateCastbarAppearance() end)
    IconEnabled:SetRelativeWidth(0.25)
    iconContainer:AddChild(IconEnabled)
    
    local iconSize = GUI:Create("Slider")
    iconSize:SetLabel(lavender .. "Icon Size")
    iconSize:SetSliderValues(1, 100, 0.1)
    iconSize:SetValue(Castbar.Icon.iconSize)
    iconSize:SetCallback("OnMouseUp", function(widget, event, value) Castbar.Icon.iconSize = value MilaUI:UpdateCastbarAppearance() end)
    iconSize:SetRelativeWidth(0.25)
    iconContainer:AddChild(iconSize)
    
    local iconanchor = GUI:Create("Dropdown")
    iconanchor:SetLabel(lavender .. "Icon Anchor")
    iconanchor:SetList(AnchorPoints)
    iconanchor:SetValue(Castbar.Icon.iconPosition)
    iconanchor:SetCallback("OnValueChanged", function(widget, event, value) Castbar.Icon.iconPosition = value MilaUI:UpdateCastbarAppearance() end)
    iconanchor:SetRelativeWidth(0.25)
    iconContainer:AddChild(iconanchor)
    
    -- Add the icon container to the content frame after all children have been added
    contentFrame:AddChild(iconContainer)
    local textContainer = MilaUI:CreateInlineGroup("Text")
    textContainer:SetLayout("Flow")
    textContainer:SetRelativeWidth(1)

    local TextEnabled = GUI:Create("CheckBox")
    TextEnabled:SetLabel("Enable Text")
    TextEnabled:SetValue(Castbar.text.showText)
    TextEnabled:SetCallback("OnValueChanged", function(widget, event, value) Castbar.text.showText = value MilaUI:UpdateCastbarAppearance() end)
    TextEnabled:SetRelativeWidth(0.25)
    textContainer:AddChild(TextEnabled)

    -- Font Options
    local TextSizeSlider = GUI:Create("Slider")
    TextSizeSlider:SetLabel(lavender .. "Text Font Size")
    TextSizeSlider:SetSliderValues(6, 32, 1)
    TextSizeSlider:SetValue(Castbar.text.textsize or 12)
    TextSizeSlider:SetRelativeWidth(0.33)
    TextSizeSlider:SetCallback("OnMouseUp", function(widget, event, value)
        Castbar.text.textsize = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    textContainer:AddChild(TextSizeSlider)

    local TimeSizeSlider = GUI:Create("Slider")
    TimeSizeSlider:SetLabel(lavender .. "Time Font Size")
    TimeSizeSlider:SetSliderValues(6, 32, 1)
    TimeSizeSlider:SetValue(Castbar.text.timesize or 12)
    TimeSizeSlider:SetRelativeWidth(0.33)
    TimeSizeSlider:SetCallback("OnMouseUp", function(widget, event, value)
        Castbar.text.timesize = value
        MilaUI:UpdateCastbarAppearance(dbUnitName)
    end)
    textContainer:AddChild(TimeSizeSlider)

    local FontFlagsDropdown = GUI:Create("Dropdown")
    FontFlagsDropdown:SetLabel(lavender .. "Font Flags")
    FontFlagsDropdown:SetList({
        NONE = "None",
        OUTLINE = "Outline",
        THICKOUTLINE = "Thick Outline",
        MONOCHROME = "Monochrome",
        ["MONOCHROME,OUTLINE"] = "Mono+Outline",
        ["MONOCHROME,THICKOUTLINE"] = "Mono+Thick Outline"
    })
    FontFlagsDropdown:SetValue(Castbar.fontFlags or "OUTLINE")
    FontFlagsDropdown:SetRelativeWidth(0.33)
    FontFlagsDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Castbar.fontFlags = value
        MilaUI:UpdateCastbarAppearance()
    end)
    textContainer:AddChild(FontFlagsDropdown)
    
    local TextJustify = GUI:Create("Dropdown")
    TextJustify:SetLabel(lavender .. "Text Justify")
    TextJustify:SetList({
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
    })
    TextJustify:SetValue(Castbar.text.textJustify)
    TextJustify:SetCallback("OnValueChanged", function(widget, event, value) Castbar.text.textJustify = value MilaUI:UpdateCastbarAppearance() end)
    TextJustify:SetRelativeWidth(0.25)
    textContainer:AddChild(TextJustify)
    
    local TimeJustify = GUI:Create("Dropdown")
    TimeJustify:SetLabel(lavender .. "Time Justify")
    TimeJustify:SetList({
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
    })
    TimeJustify:SetValue(Castbar.text.timeJustify)
    TimeJustify:SetCallback("OnValueChanged", function(widget, event, value) Castbar.text.timeJustify = value MilaUI:UpdateCastbarAppearance() end)
    TimeJustify:SetRelativeWidth(0.25)
    textContainer:AddChild(TimeJustify)
    
    local ShowTime = GUI:Create("CheckBox")
    ShowTime:SetLabel("Show Time")
    ShowTime:SetValue(Castbar.text.showTime)
    ShowTime:SetCallback("OnValueChanged", function(widget, event, value) Castbar.text.showTime = value MilaUI:UpdateCastbarAppearance() end)
    ShowTime:SetRelativeWidth(0.25)
    textContainer:AddChild(ShowTime)
    
    local TimeFormat = GUI:Create("Dropdown")
    TimeFormat:SetLabel(lavender .. "Time Format")
    TimeFormat:SetList({
        ["%.1f"] = "%.1f",
        ["%.2f"] = "%.2f",
        ["%.3f"] = "%.3f",
    })
    TimeFormat:SetValue(Castbar.text.timeFormat)
    TimeFormat:SetCallback("OnValueChanged", function(widget, event, value) Castbar.text.timeFormat = value MilaUI:UpdateCastbarAppearance() end)
    TimeFormat:SetRelativeWidth(0.25)
    textContainer:AddChild(TimeFormat)
    
    -- Add the text container to the content frame after all children have been added
    contentFrame:AddChild(textContainer)
    
    -- Size and Position
    MilaUI:CreateLargeHeading("Size and Position", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    local Size = GUI:Create("InlineGroup")
    local Position = GUI:Create("InlineGroup")
    local Anchor = GUI:Create("InlineGroup")
    Size:SetLayout("Flow")
    Size:SetRelativeWidth(0.5)
    Size:SetTitle(pink .. "Size")
    Position:SetLayout("Flow")
    Position:SetRelativeWidth(0.5)
    Position:SetTitle(pink .. "Position")
    Anchor:SetLayout("Flow")
    Anchor:SetRelativeWidth(0.5)
    Anchor:SetTitle(pink .. "Anchor")
    contentFrame:AddChild(Size)
    contentFrame:AddChild(Position)
    contentFrame:AddChild(Anchor)
    -- Frame Scale
    local FrameScaleEnabled = GUI:Create("CheckBox")
    FrameScaleEnabled:SetLabel("Enable Custom Scale")
    FrameScaleEnabled:SetValue(Castbar.CustomScale)
    FrameScaleEnabled:SetCallback("OnValueChanged", function(widget, event, value) Castbar.CustomScale = value MilaUI:UpdateCastbarAppearance() end)
    FrameScaleEnabled:SetRelativeWidth(0.5)
    Size:AddChild(FrameScaleEnabled)
    local FrameScale = GUI:Create("Slider")
    FrameScale:SetLabel(lavender .. "Custom Scale")
    FrameScale:SetSliderValues(0, 1, 0.01)
    FrameScale:SetValue(Castbar.Scale)
    FrameScale:SetCallback("OnMouseUp", function(widget, event, value) Castbar.Scale = value MilaUI:UpdateCastbarSize(dbUnitName) end)
    FrameScale:SetRelativeWidth(1)
    Size:AddChild(FrameScale)
    -- Frame Width
    local FrameWidth = GUI:Create("Slider")
    FrameWidth:SetLabel(lavender .. "Width")
    FrameWidth:SetSliderValues(1, 500, 1)
    FrameWidth:SetValue(Castbar.width)
    FrameWidth:SetCallback("OnMouseUp", function(widget, event, value) Castbar.width = value MilaUI:UpdateCastbarSize(dbUnitName) end)
    FrameWidth:SetRelativeWidth(0.5)
    Size:AddChild(FrameWidth)

    -- Frame Height
    local FrameHeight = GUI:Create("Slider")
    FrameHeight:SetLabel(lavender .. "Height")
    FrameHeight:SetSliderValues(1, 500, 1)
    FrameHeight:SetValue(Castbar.height)
    FrameHeight:SetCallback("OnMouseUp", function(widget, event, value) Castbar.height = value MilaUI:UpdateCastbarSize(dbUnitName) end)
    FrameHeight:SetRelativeWidth(0.5)
    Size:AddChild(FrameHeight)

    -- Frame X Position
    local FrameXPosition = GUI:Create("Slider")
    FrameXPosition:SetLabel(lavender .. "Frame X Position")
    FrameXPosition:SetSliderValues(-999, 999, 0.1)
    FrameXPosition:SetValue(Castbar.position.xOffset)
    FrameXPosition:SetCallback("OnValueChanged", function(widget, event, value) Castbar.position.xOffset = value MilaUI:UpdateCastbarPosition(dbUnitName) end)
    FrameXPosition:SetRelativeWidth(0.5)
    Position:AddChild(FrameXPosition)
    
    -- Frame Y Position
    local FrameYPosition = GUI:Create("Slider")
    FrameYPosition:SetLabel(lavender .. "Frame Y Position")
    FrameYPosition:SetSliderValues(-999, 999, 0.1)
    FrameYPosition:SetValue(Castbar.position.yOffset)
    FrameYPosition:SetCallback("OnValueChanged", function(widget, event, value) Castbar.position.yOffset = value MilaUI:UpdateCastbarPosition(dbUnitName) end)
    FrameYPosition:SetRelativeWidth(0.5)
    Position:AddChild(FrameYPosition)
    
    -- Frame Anchor Parent
    local FrameAnchorParent = GUI:Create("EditBox")
    FrameAnchorParent:SetLabel(lavender .. "Anchor Parent")
    FrameAnchorParent:SetText(type(Castbar.position.anchorParent) == "string" and Castbar.position.anchorParent or "UIParent")
    FrameAnchorParent:SetCallback("OnEnterPressed", function(widget, event, value)
        local anchor = _G[value]
        if anchor and anchor.IsObjectType and anchor:IsObjectType("Frame") then
            Castbar.position.anchorParent = value
        else
            Castbar.position.anchorParent = "UIParent"
            widget:SetText("UIParent")
        end
        MilaUI:UpdateCastbarPosition(dbUnitName)
    end)
    FrameAnchorParent:SetRelativeWidth(1)
    Anchor:AddChild(FrameAnchorParent)
    FrameAnchorParent:SetCallback("OnEnter", function(widget, event)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("|cFF8080FFPLEASE NOTE|r: This will |cFFFF4040NOT|r work for WeakAuras.")
        GameTooltip:Show()
    end)
    FrameAnchorParent:SetCallback("OnLeave", function(widget, event) GameTooltip:Hide() end)

    -- Frame Anchor From
    local FrameAnchorFrom = GUI:Create("Dropdown")
    FrameAnchorFrom:SetLabel(lavender .. "Anchor From")
    FrameAnchorFrom:SetList(AnchorPoints)
    FrameAnchorFrom:SetValue(Castbar.position.anchorFrom)
    FrameAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Castbar.position.anchorFrom = value MilaUI:UpdateCastbarPosition(dbUnitName) end)
    FrameAnchorFrom:SetRelativeWidth(0.5)
    Anchor:AddChild(FrameAnchorFrom)

    -- Frame Anchor To
    local FrameAnchorTo = GUI:Create("Dropdown")
    FrameAnchorTo:SetLabel(lavender .. "Anchor To")
    FrameAnchorTo:SetList(AnchorPoints)
    FrameAnchorTo:SetValue(Castbar.position.anchorTo)
    FrameAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Castbar.position.anchorTo = value MilaUI:UpdateCastbarPosition(dbUnitName) end)
    FrameAnchorTo:SetRelativeWidth(0.5)
    Anchor:AddChild(FrameAnchorTo)
    C_Timer.After(0.1, function()
        local p = contentFrame
        while p and p.DoLayout do
            p:DoLayout()
            p = p.parent
        end
    end)


end

-- Helper functions for clean castbar settings
local function GetCleanCastbarSettings(unit)
    local profile = MilaUI.DB.profile
    if profile.castBars and profile.castBars[unit] then
        return profile.castBars[unit]
    end
    return nil
end

local function UpdateCleanCastbarSetting(unit, setting, value)
    local castbarSettings = GetCleanCastbarSettings(unit)
    if castbarSettings then
        if type(setting) == "table" then
            local current = castbarSettings
            for i = 1, #setting - 1 do
                if not current[setting[i]] then current[setting[i]] = {} end
                current = current[setting[i]]
            end
            current[setting[#setting]] = value
        else
            castbarSettings[setting] = value
        end
        
        -- Apply specific updates based on setting type
        if type(setting) == "table" and (setting[1] == "colors" or setting[1] == "flashColors") then
            if MilaUI.modules and MilaUI.modules.bars and MilaUI.modules.bars.UpdateCastBarColors then
                MilaUI.modules.bars.UpdateCastBarColors(unit)
            end
        end
        
        -- Update castbar settings
        if MilaUI.modules and MilaUI.modules.bars and MilaUI.modules.bars.UpdateCastBarSettings then
            MilaUI.modules.bars.UpdateCastBarSettings(unit)
        end
    end
end

function MilaUI:DrawCleanCastbarContainer(dbUnitName, contentFrame)
    local unitKey = dbUnitName:lower()
    local castbarSettings = GetCleanCastbarSettings(unitKey)
    
    if not castbarSettings then
        local errorLabel = GUI:Create("Label")
        errorLabel:SetText("|cffFF0000Error: Clean Castbar data not found for " .. dbUnitName)
        errorLabel:SetFullWidth(true)
        contentFrame:AddChild(errorLabel)
        return
    end
    
    local textures = LSM and LSM:HashTable(LSM.MediaType.STATUSBAR) or {}
    local fonts = LSM and LSM:HashTable(LSM.MediaType.FONT) or {}
    local AnchorPoints = {
        ["TOPLEFT"] = "Top Left",
        ["TOP"] = "Top",
        ["TOPRIGHT"] = "Top Right",
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
        ["BOTTOMLEFT"] = "Bottom Left",
        ["BOTTOM"] = "Bottom",
        ["BOTTOMRIGHT"] = "Bottom Right"
    }
    
    -- General Settings
    MilaUI:CreateLargeHeading("General Settings", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    
    local generalGroup = GUI:Create("InlineGroup")
    generalGroup:SetLayout("Flow")
    generalGroup:SetFullWidth(true)
    generalGroup:SetTitle(pink .. "General")
    contentFrame:AddChild(generalGroup)
    
    local enabledCB = GUI:Create("CheckBox")
    enabledCB:SetLabel("Enable Clean Castbar")
    enabledCB:SetValue(castbarSettings.enabled)
    enabledCB:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, "enabled", value)
    end)
    enabledCB:SetRelativeWidth(0.5)
    generalGroup:AddChild(enabledCB)
    
    -- Size Settings
    MilaUI:CreateLargeHeading("Size Settings", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    
    local sizeGroup = GUI:Create("InlineGroup")
    sizeGroup:SetLayout("Flow")
    sizeGroup:SetFullWidth(true)
    sizeGroup:SetTitle(pink .. "Size")
    contentFrame:AddChild(sizeGroup)
    
    local widthSlider = GUI:Create("Slider")
    widthSlider:SetLabel(lavender .. "Width")
    widthSlider:SetSliderValues(50, 400, 1)
    widthSlider:SetValue(castbarSettings.size and castbarSettings.size.width or 200)
    widthSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"size", "width"}, value)
    end)
    widthSlider:SetRelativeWidth(0.5)
    sizeGroup:AddChild(widthSlider)
    
    local heightSlider = GUI:Create("Slider")
    heightSlider:SetLabel(lavender .. "Height")
    heightSlider:SetSliderValues(10, 50, 1)
    heightSlider:SetValue(castbarSettings.size and castbarSettings.size.height or 18)
    heightSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"size", "height"}, value)
    end)
    heightSlider:SetRelativeWidth(0.5)
    sizeGroup:AddChild(heightSlider)
    
    local scaleSlider = GUI:Create("Slider")
    scaleSlider:SetLabel(lavender .. "Scale")
    scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
    scaleSlider:SetValue(castbarSettings.size and castbarSettings.size.scale or 1.0)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"size", "scale"}, value)
    end)
    scaleSlider:SetRelativeWidth(0.5)
    sizeGroup:AddChild(scaleSlider)
    
    -- Position Settings
    MilaUI:CreateLargeHeading("Position Settings", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    
    local positionGroup = GUI:Create("InlineGroup")
    positionGroup:SetLayout("Flow")
    positionGroup:SetFullWidth(true)
    positionGroup:SetTitle(pink .. "Position")
    contentFrame:AddChild(positionGroup)
    
    local anchorPointDD = GUI:Create("Dropdown")
    anchorPointDD:SetLabel(lavender .. "Anchor Point")
    anchorPointDD:SetList(AnchorPoints)
    anchorPointDD:SetValue(castbarSettings.position and castbarSettings.position.anchorPoint or "CENTER")
    anchorPointDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"position", "anchorPoint"}, value)
    end)
    anchorPointDD:SetRelativeWidth(0.5)
    positionGroup:AddChild(anchorPointDD)
    
    local anchorToDD = GUI:Create("Dropdown")
    anchorToDD:SetLabel(lavender .. "Anchor To")
    anchorToDD:SetList(AnchorPoints)
    anchorToDD:SetValue(castbarSettings.position and castbarSettings.position.anchorTo or "CENTER")
    anchorToDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"position", "anchorTo"}, value)
    end)
    anchorToDD:SetRelativeWidth(0.5)
    positionGroup:AddChild(anchorToDD)
    
    local xOffsetSlider = GUI:Create("Slider")
    xOffsetSlider:SetLabel(lavender .. "X Offset")
    xOffsetSlider:SetSliderValues(-1000, 1000, 1)
    xOffsetSlider:SetValue(castbarSettings.position and castbarSettings.position.xOffset or 0)
    xOffsetSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"position", "xOffset"}, value)
    end)
    xOffsetSlider:SetRelativeWidth(0.5)
    positionGroup:AddChild(xOffsetSlider)
    
    local yOffsetSlider = GUI:Create("Slider")
    yOffsetSlider:SetLabel(lavender .. "Y Offset")
    yOffsetSlider:SetSliderValues(-1000, 1000, 1)
    yOffsetSlider:SetValue(castbarSettings.position and castbarSettings.position.yOffset or -20)
    yOffsetSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"position", "yOffset"}, value)
    end)
    yOffsetSlider:SetRelativeWidth(0.5)
    positionGroup:AddChild(yOffsetSlider)
    
    local anchorFrameInput = GUI:Create("EditBox")
    anchorFrameInput:SetLabel(lavender .. "Anchor Frame")
    anchorFrameInput:SetText(castbarSettings.position and castbarSettings.position.anchorFrame or "MilaUI_Player")
    anchorFrameInput:SetCallback("OnEnterPressed", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"position", "anchorFrame"}, value)
    end)
    anchorFrameInput:SetRelativeWidth(0.5)
    positionGroup:AddChild(anchorFrameInput)
    
    -- Icon Settings
    MilaUI:CreateLargeHeading("Icon Settings", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    
    local iconGroup = GUI:Create("InlineGroup")
    iconGroup:SetLayout("Flow")
    iconGroup:SetFullWidth(true)
    iconGroup:SetTitle(pink .. "Icon")
    contentFrame:AddChild(iconGroup)
    
    local iconEnabledCB = GUI:Create("CheckBox")
    iconEnabledCB:SetLabel("Show Icon")
    iconEnabledCB:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.show)
    iconEnabledCB:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "icon", "show"}, value)
    end)
    iconEnabledCB:SetRelativeWidth(0.5)
    iconGroup:AddChild(iconEnabledCB)
    
    local iconSizeSlider = GUI:Create("Slider")
    iconSizeSlider:SetLabel(lavender .. "Icon Size")
    iconSizeSlider:SetSliderValues(10, 100, 1)
    iconSizeSlider:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.size or 24)
    iconSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "icon", "size"}, value)
    end)
    iconSizeSlider:SetRelativeWidth(0.5)
    iconGroup:AddChild(iconSizeSlider)
    
    local iconAnchorFromDD = GUI:Create("Dropdown")
    iconAnchorFromDD:SetLabel(lavender .. "Icon Anchor From")
    iconAnchorFromDD:SetList(AnchorPoints)
    iconAnchorFromDD:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.anchorFrom or "LEFT")
    iconAnchorFromDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "icon", "anchorFrom"}, value)
    end)
    iconAnchorFromDD:SetRelativeWidth(0.5)
    iconGroup:AddChild(iconAnchorFromDD)
    
    local iconAnchorToDD = GUI:Create("Dropdown")
    iconAnchorToDD:SetLabel(lavender .. "Icon Anchor To")
    iconAnchorToDD:SetList(AnchorPoints)
    iconAnchorToDD:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.anchorTo or "LEFT")
    iconAnchorToDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "icon", "anchorTo"}, value)
    end)
    iconAnchorToDD:SetRelativeWidth(0.5)
    iconGroup:AddChild(iconAnchorToDD)
    
    local iconXOffsetSlider = GUI:Create("Slider")
    iconXOffsetSlider:SetLabel(lavender .. "Icon X Offset")
    iconXOffsetSlider:SetSliderValues(-50, 50, 1)
    iconXOffsetSlider:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.xOffset or 4)
    iconXOffsetSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "icon", "xOffset"}, value)
    end)
    iconXOffsetSlider:SetRelativeWidth(0.5)
    iconGroup:AddChild(iconXOffsetSlider)
    
    local iconYOffsetSlider = GUI:Create("Slider")
    iconYOffsetSlider:SetLabel(lavender .. "Icon Y Offset")
    iconYOffsetSlider:SetSliderValues(-50, 50, 1)
    iconYOffsetSlider:SetValue(castbarSettings.display and castbarSettings.display.icon and castbarSettings.display.icon.yOffset or 0)
    iconYOffsetSlider:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "icon", "yOffset"}, value)
    end)
    iconYOffsetSlider:SetRelativeWidth(0.5)
    iconGroup:AddChild(iconYOffsetSlider)
    
    -- Text Settings
    MilaUI:CreateLargeHeading("Text Settings", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    
    local textGroup = GUI:Create("InlineGroup")
    textGroup:SetLayout("Flow")
    textGroup:SetFullWidth(true)
    textGroup:SetTitle(pink .. "Text")
    contentFrame:AddChild(textGroup)
    
    local textEnabledCB = GUI:Create("CheckBox")
    textEnabledCB:SetLabel("Show Text")
    textEnabledCB:SetValue(castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.show)
    textEnabledCB:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "text", "show"}, value)
    end)
    textEnabledCB:SetRelativeWidth(0.5)
    textGroup:AddChild(textEnabledCB)
    
    local timerEnabledCB = GUI:Create("CheckBox")
    timerEnabledCB:SetLabel("Show Timer")
    timerEnabledCB:SetValue(castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.show)
    timerEnabledCB:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "timer", "show"}, value)
    end)
    timerEnabledCB:SetRelativeWidth(0.5)
    textGroup:AddChild(timerEnabledCB)
    
    local textAnchorFromDD = GUI:Create("Dropdown")
    textAnchorFromDD:SetLabel(lavender .. "Text Anchor From")
    textAnchorFromDD:SetList(AnchorPoints)
    textAnchorFromDD:SetValue(castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.anchorFrom or "BOTTOM")
    textAnchorFromDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "text", "anchorFrom"}, value)
    end)
    textAnchorFromDD:SetRelativeWidth(0.5)
    textGroup:AddChild(textAnchorFromDD)
    
    local textAnchorToDD = GUI:Create("Dropdown")
    textAnchorToDD:SetLabel(lavender .. "Text Anchor To")
    textAnchorToDD:SetList(AnchorPoints)
    textAnchorToDD:SetValue(castbarSettings.display and castbarSettings.display.text and castbarSettings.display.text.anchorTo or "TOP")
    textAnchorToDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "text", "anchorTo"}, value)
    end)
    textAnchorToDD:SetRelativeWidth(0.5)
    textGroup:AddChild(textAnchorToDD)
    
    local timerAnchorFromDD = GUI:Create("Dropdown")
    timerAnchorFromDD:SetLabel(lavender .. "Timer Anchor From")
    timerAnchorFromDD:SetList(AnchorPoints)
    timerAnchorFromDD:SetValue(castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.anchorFrom or "RIGHT")
    timerAnchorFromDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "timer", "anchorFrom"}, value)
    end)
    timerAnchorFromDD:SetRelativeWidth(0.5)
    textGroup:AddChild(timerAnchorFromDD)
    
    local timerAnchorToDD = GUI:Create("Dropdown")
    timerAnchorToDD:SetLabel(lavender .. "Timer Anchor To")
    timerAnchorToDD:SetList(AnchorPoints)
    timerAnchorToDD:SetValue(castbarSettings.display and castbarSettings.display.timer and castbarSettings.display.timer.anchorTo or "RIGHT")
    timerAnchorToDD:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateCleanCastbarSetting(unitKey, {"display", "timer", "anchorTo"}, value)
    end)
    timerAnchorToDD:SetRelativeWidth(0.5)
    textGroup:AddChild(timerAnchorToDD)
    
    -- Colors Settings
    MilaUI:CreateLargeHeading("Colors", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    
    local colorsGroup = GUI:Create("InlineGroup")
    colorsGroup:SetLayout("Flow")
    colorsGroup:SetFullWidth(true)
    colorsGroup:SetTitle(pink .. "Bar Colors")
    contentFrame:AddChild(colorsGroup)
    
    local castColorPicker = GUI:Create("ColorPicker")
    castColorPicker:SetLabel(lavender .. "Cast Color")
    castColorPicker:SetColor(unpack(castbarSettings.colors and castbarSettings.colors.cast or {0, 1, 1, 1}))
    castColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"colors", "cast"}, {r, g, b, a})
    end)
    castColorPicker:SetRelativeWidth(0.5)
    colorsGroup:AddChild(castColorPicker)
    
    local channelColorPicker = GUI:Create("ColorPicker")
    channelColorPicker:SetLabel(lavender .. "Channel Color")
    channelColorPicker:SetColor(unpack(castbarSettings.colors and castbarSettings.colors.channel or {0.5, 0.3, 0.9, 1}))
    channelColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"colors", "channel"}, {r, g, b, a})
    end)
    channelColorPicker:SetRelativeWidth(0.5)
    colorsGroup:AddChild(channelColorPicker)
    
    local uninterruptibleColorPicker = GUI:Create("ColorPicker")
    uninterruptibleColorPicker:SetLabel(lavender .. "Uninterruptible Color")
    uninterruptibleColorPicker:SetColor(unpack(castbarSettings.colors and castbarSettings.colors.uninterruptible or {0.8, 0.8, 0.8, 1}))
    uninterruptibleColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"colors", "uninterruptible"}, {r, g, b, a})
    end)
    uninterruptibleColorPicker:SetRelativeWidth(0.5)
    colorsGroup:AddChild(uninterruptibleColorPicker)
    
    local interruptColorPicker = GUI:Create("ColorPicker")
    interruptColorPicker:SetLabel(lavender .. "Interrupt Color")
    interruptColorPicker:SetColor(unpack(castbarSettings.colors and castbarSettings.colors.interrupt or {1, 0.2, 0.2, 1}))
    interruptColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"colors", "interrupt"}, {r, g, b, a})
    end)
    interruptColorPicker:SetRelativeWidth(0.5)
    colorsGroup:AddChild(interruptColorPicker)
    
    local completionColorPicker = GUI:Create("ColorPicker")
    completionColorPicker:SetLabel(lavender .. "Completion Color")
    completionColorPicker:SetColor(unpack(castbarSettings.colors and castbarSettings.colors.completion or {0.2, 1.0, 1.0, 1.0}))
    completionColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"colors", "completion"}, {r, g, b, a})
    end)
    completionColorPicker:SetRelativeWidth(0.5)
    colorsGroup:AddChild(completionColorPicker)
    
    -- Flash Colors Settings
    MilaUI:CreateLargeHeading("Flash Colors", contentFrame)
    MilaUI:CreateVerticalSpacer(20, contentFrame)
    
    local flashColorsGroup = GUI:Create("InlineGroup")
    flashColorsGroup:SetLayout("Flow")
    flashColorsGroup:SetFullWidth(true)
    flashColorsGroup:SetTitle(pink .. "Flash Colors")
    contentFrame:AddChild(flashColorsGroup)
    
    local castFlashColorPicker = GUI:Create("ColorPicker")
    castFlashColorPicker:SetLabel(lavender .. "Cast Flash Color")
    castFlashColorPicker:SetColor(unpack(castbarSettings.flashColors and castbarSettings.flashColors.cast or {0.2, 0.8, 0.2, 1.0}))
    castFlashColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"flashColors", "cast"}, {r, g, b, a})
    end)
    castFlashColorPicker:SetRelativeWidth(0.5)
    flashColorsGroup:AddChild(castFlashColorPicker)
    
    local channelFlashColorPicker = GUI:Create("ColorPicker")
    channelFlashColorPicker:SetLabel(lavender .. "Channel Flash Color")
    channelFlashColorPicker:SetColor(unpack(castbarSettings.flashColors and castbarSettings.flashColors.channel or {1.0, 0.4, 1.0, 0.9}))
    channelFlashColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"flashColors", "channel"}, {r, g, b, a})
    end)
    channelFlashColorPicker:SetRelativeWidth(0.5)
    flashColorsGroup:AddChild(channelFlashColorPicker)
    
    local uninterruptibleFlashColorPicker = GUI:Create("ColorPicker")
    uninterruptibleFlashColorPicker:SetLabel(lavender .. "Uninterruptible Flash Color")
    uninterruptibleFlashColorPicker:SetColor(unpack(castbarSettings.flashColors and castbarSettings.flashColors.uninterruptible or {0.8, 0.8, 0.8, 0.9}))
    uninterruptibleFlashColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"flashColors", "uninterruptible"}, {r, g, b, a})
    end)
    uninterruptibleFlashColorPicker:SetRelativeWidth(0.5)
    flashColorsGroup:AddChild(uninterruptibleFlashColorPicker)
    
    local interruptFlashColorPicker = GUI:Create("ColorPicker")
    interruptFlashColorPicker:SetLabel(lavender .. "Interrupt Glow Color")
    interruptFlashColorPicker:SetColor(unpack(castbarSettings.flashColors and castbarSettings.flashColors.interrupt or {1, 1, 1, 1}))
    interruptFlashColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        UpdateCleanCastbarSetting(unitKey, {"flashColors", "interrupt"}, {r, g, b, a})
    end)
    interruptFlashColorPicker:SetRelativeWidth(0.5)
    flashColorsGroup:AddChild(interruptFlashColorPicker)
    
    -- Layout update
    C_Timer.After(0.1, function()
        local p = contentFrame
        while p and p.DoLayout do
            p:DoLayout()
            p = p.parent
        end
    end)
end
    